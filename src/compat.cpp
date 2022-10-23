#include <stddef.h>

#ifdef WIN32

#include <windows.h>
#include <errno.h>
#include <sys/stat.h>
#include <string.h>
#include <malloc.h>
#include "compat.h"


struct DIR
{
  HANDLE hFind;
  char   szDirName[1];
};

static int countslashes(const char *dirname)
{
  const char *p;
  int n;

  n = 0;
  p = dirname;

  while (*p)
    if (*p++ == '\\')
      ++n;

  return n;
}

DIR * opendir ( const char * dirname )
{
  DIR * dir;
  int   nameLen;
  struct stat st;
  unsigned char flagNetPath;
  unsigned char flagRootOnly;

  if (dirname == NULL || *dirname == 0)
  {
    errno = EINVAL;
    return NULL;
  }

  nameLen = strlen( dirname );
  flagNetPath = 0;
  if (dirname[0] == '\\' && dirname[1] == '\\')
    flagNetPath = 1;
  /* we have to check for root-dir-only case */
  flagRootOnly = 0;
  if (flagNetPath)
  {
    if (countslashes(&dirname[2]) == 2)  /* only the separation for server_name and the root*/
      flagRootOnly = 1;
  }

  if ((dirname[nameLen-1] == '/' || dirname[nameLen-1] == '\\') &&
      (nameLen != 3 || dirname[1] != ':') && nameLen != 1 && !flagRootOnly)
  {
    char * t = (char*)alloca( nameLen );
    memcpy( t, dirname, nameLen );
    t[nameLen-1] = 0;
    dirname = t;
    --nameLen;
  }

  if (stat( dirname, &st ))
    return NULL;

  if ((st.st_mode & S_IFDIR) == 0)
  {
    // this is not a DIR
    errno = ENOTDIR;
    return NULL;
  }

  if ((dir = (DIR*)malloc( sizeof( DIR ) + nameLen + 2 )) == NULL)
  {
    errno = ENOMEM;
    return NULL;
  }

  dir->hFind = INVALID_HANDLE_VALUE;

  memcpy( dir->szDirName, dirname, nameLen );
  if (nameLen && dirname[nameLen-1] != ':' && dirname[nameLen-1] != '\\' &&
      dirname[nameLen-1] != '/')
  {
    dir->szDirName[nameLen++] = '\\';
  }
  dir->szDirName[nameLen] = '*';
  dir->szDirName[nameLen+1] = 0;

  return dir;
};

struct dirent * readdir ( DIR * dir )
{
  static WIN32_FIND_DATAA fData;

  if (dir == NULL)
  {
    errno = EBADF;
    return NULL;
  }

  do
  {
    int ok = 1;

    if (dir->hFind == INVALID_HANDLE_VALUE)
    {
      dir->hFind = FindFirstFileA( dir->szDirName, &fData );
      if (dir->hFind == INVALID_HANDLE_VALUE)
        ok = 0;
    }
    else
    if (!FindNextFileA( dir->hFind, &fData ))
      ok = 0;

    if (!ok)
    {
      switch (GetLastError())
      {
        case ERROR_NO_MORE_FILES:
        case ERROR_FILE_NOT_FOUND:
        case ERROR_PATH_NOT_FOUND:
          errno = ENOENT;
          break;

        case ERROR_NOT_ENOUGH_MEMORY:
          errno = ENOMEM;
          break;

        default:
          errno = EINVAL;
          break;
      }
      return NULL;
    }
  }
  while (fData.dwFileAttributes & FILE_ATTRIBUTE_HIDDEN);

  return (struct dirent *)&fData.cFileName;
};

int closedir ( DIR * dir )
{
  if (dir == NULL)
  {
    errno = EBADF;
    return -1;
  }
  if (dir->hFind != INVALID_HANDLE_VALUE)
    FindClose( dir->hFind );
  free( dir );
  return 0;
};

void rewinddir ( DIR * dir )
{
  if (dir)
  {
    if (dir->hFind != INVALID_HANDLE_VALUE)
      FindClose( dir->hFind );
    dir->hFind = INVALID_HANDLE_VALUE;
  }
};

void win32_display_error(const char* caption, const char* message)
{
	::MessageBoxA(NULL, message, caption, MB_ICONERROR|MB_OK);
}

int ClipboardGet( char *buffer, size_t size ) {
	HGLOBAL text;
	void *ptr;

	if( !IsClipboardFormatAvailable( CF_TEXT ) ) {
		*buffer = 0; 
		return 1;
	}
	if( !OpenClipboard( GetClipboardOwner() ) ) return 0; 
	if(	!( text = GetClipboardData( CF_TEXT ) ) ||
		!( ptr = GlobalLock( text ) )
	) {
		CloseClipboard();
		return 0;
	}
	strncpy( buffer, (const char*)ptr, size - 1 );
	buffer[size - 1] = 0;
	GlobalUnlock( text );
	CloseClipboard();
	return 1;
}

int ClipboardSet( const char *text ) {
	size_t len;
	HGLOBAL buffer;
	void *ptr;
	
	if( !OpenClipboard( 0 ) ) return 0;
	if( !EmptyClipboard() ) goto _ClipboardSet_Error1;
	len = strlen( text ) + 1;
	if( !( buffer = GlobalAlloc( GMEM_MOVEABLE, len ) ) ) goto _ClipboardSet_Error1;
	if( !( ptr = GlobalLock( buffer ) ) ) goto _ClipboardSet_Error2;
	memcpy( ptr, text, len );
	GlobalUnlock( buffer );
	if( !SetClipboardData( CF_TEXT, buffer ) ) goto _ClipboardSet_Error2;
	CloseClipboard();
	return 1;

_ClipboardSet_Error2:
	GlobalFree( buffer );
_ClipboardSet_Error1:
	CloseClipboard();
	return 0;
}

#elif defined( __linux__ )

#include <unistd.h>
#include <limits.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <SDL/SDL_events.h>
#include <SDL/SDL_syswm.h>
#include <SDL/SDL_version.h>

static Bool MatchSelNotify( Display *display, XEvent *event, XPointer arg ) {
	return event->type == SelectionNotify;
}

int ClipboardGet( char *buffer, size_t size ) {
	Atom type, clipboard, strfmt;
	Window window;
	XEvent event;
	int format;
	unsigned long bytes, overflow;
	unsigned char *text;
	SDL_SysWMinfo wm;

	memset( &wm, 0, sizeof( wm ) );
	wm.version.major = SDL_MAJOR_VERSION;
	wm.version.minor = SDL_MINOR_VERSION;
	if( SDL_GetWMInfo( &wm ) < 0 ) return 0;
	wm.info.x11.lock_func();
#ifdef COPYPASTE_UTF8
	if( ( strfmt = XInternAtom( wm.info.x11.display, "UTF8_STRING", 0 ) ) == None ) {
		goto _ClipboardGet_Error;
	}
#else
	strfmt = XA_STRING;
#endif
	if( ( clipboard = XInternAtom( wm.info.x11.display, "CLIPBOARD", 0 ) ) == None ) {
        goto _ClipboardGet_Error;
    }
    if(	( ( window = XGetSelectionOwner( wm.info.x11.display, clipboard ) ) == None ) ||
		( window == wm.info.x11.window )
	) {
        window = XDefaultRootWindow( wm.info.x11.display );
    } else {
		window = wm.info.x11.window;
        XConvertSelection(
			wm.info.x11.display, clipboard, strfmt, XA_CUT_BUFFER0,
			wm.info.x11.window, CurrentTime
		);
		// yuckyness ahead: waiting for selection notify outside of actual event
		// loop (yep, that could wait forever and make the app hang...)
		XIfEvent( wm.info.x11.display, &event, MatchSelNotify, NULL );
    }
    if( XGetWindowProperty(
			wm.info.x11.display, window, XA_CUT_BUFFER0, 0, INT_MAX / 4, False,
			strfmt, &type, &format, &bytes, &overflow, &text
		) != Success || type != strfmt || bytes > size - 1
	) {
		goto _ClipboardGet_Error;
	}
	memcpy( buffer, text, bytes );
	buffer[bytes] = 0;
	XFree( text );
	wm.info.x11.unlock_func();
	return 1;

_ClipboardGet_Error:
	wm.info.x11.unlock_func();
	return 0;
}

static int FilterSelRequest( const SDL_Event *sdlevent ) {
	XSelectionRequestEvent *sreq;
	XEvent event;
	Atom targets, formats[2];
	int format;
	unsigned long bytes, overflow;
	unsigned char *text;
	
	if(	sdlevent->type != SDL_SYSWMEVENT ||
		sdlevent->syswm.msg->subsystem != SDL_SYSWM_X11 ||
		sdlevent->syswm.msg->event.xevent.type != SelectionRequest
	) {
		return 1;
	}
	sreq = (XSelectionRequestEvent*)&sdlevent->syswm.msg->event.xevent;
	if( ( targets = XInternAtom( sreq->display, "TARGETS", 0 ) ) == None ) {
        return 0;
    }
	memset( &event, 0, sizeof( event ) );
	event.xany.type = SelectionNotify;
	event.xselection.selection = sreq->selection;
	event.xselection.target = None;
	event.xselection.property = None;
	event.xselection.requestor = sreq->requestor;
	event.xselection.time = sreq->time;
	if(	XGetWindowProperty(
			sreq->display, XDefaultRootWindow( sreq->display ), XA_CUT_BUFFER0,
			0, INT_MAX / 4, False, sreq->target, &event.xselection.target,
			&format, &bytes, &overflow, &text
		) == Success
	) {
		if( sreq->target == event.xselection.target ) {
			XChangeProperty(
				sreq->display, sreq->requestor, sreq->property, sreq->target,
				format, PropModeReplace, (const unsigned char*)text, bytes
			);
			event.xselection.property = sreq->property;
		} else if( sreq->target == targets ) {
			formats[0] = event.xselection.target;
			formats[1] = targets;
			XChangeProperty(
				sreq->display, sreq->requestor, sreq->property, XA_ATOM, 32,
				PropModeReplace, (const unsigned char*)formats, 2
			);
			event.xselection.property = sreq->property;
		}	
		XFree( text );
	}
	XSendEvent( sreq->display, sreq->requestor, False, 0, &event );
	XSync( sreq->display, False );
	return 0;
}

int ClipboardSet( const char *text ) {
	Atom clipboard, strfmt;
	SDL_SysWMinfo wm;
	static int init = 0;

	if( !init ) {
		init = 1;
		SDL_EventState( SDL_SYSWMEVENT, SDL_ENABLE );
		// FIXME?: dont hog the filter for clipboard only
		SDL_SetEventFilter( FilterSelRequest );
	}
	memset( &wm, 0, sizeof( wm ) );
	wm.version.major = SDL_MAJOR_VERSION;
	wm.version.minor = SDL_MINOR_VERSION;
	if( SDL_GetWMInfo( &wm ) < 0 ) return 0;
	wm.info.x11.lock_func();
#ifdef COPYPASTE_UTF8
	if( ( strfmt = XInternAtom( wm.info.x11.display, "UTF8_STRING", 0 ) ) == None ) {
		goto _ClipboardSet_Error;
	}
#else
	strfmt = XA_STRING;
#endif
	if( ( clipboard = XInternAtom( wm.info.x11.display, "CLIPBOARD", 0 ) ) == None ) {
        goto _ClipboardSet_Error;
    }
	XChangeProperty(
		wm.info.x11.display, XDefaultRootWindow( wm.info.x11.display ), XA_CUT_BUFFER0,
		strfmt, 8, PropModeReplace, (const unsigned char*)text, strlen( text )
	);
	if( XGetSelectionOwner( wm.info.x11.display, clipboard ) != wm.info.x11.window ) {
		XSetSelectionOwner( wm.info.x11.display, clipboard, wm.info.x11.window, CurrentTime );
	}
	if( XGetSelectionOwner( wm.info.x11.display, XA_PRIMARY ) != wm.info.x11.window ) {
		XSetSelectionOwner( wm.info.x11.display, XA_PRIMARY, wm.info.x11.window, CurrentTime );
	}
	wm.info.x11.unlock_func();
	return 1;

_ClipboardSet_Error:
	wm.info.x11.unlock_func();
	return 0;
}

#else

int ClipboardSet( const char *text ) {
	return 1;
}

int ClipboardGet( char *buffer, size_t size ) {
	*buffer = 0;
	return 1;
}

#endif
