#ifndef COMPAT_H
#define COMPAT_H

#ifdef WIN32

#include <stdio.h>

struct dirent
{
  char d_name[FILENAME_MAX+1];
};

typedef struct DIR DIR;

DIR * opendir ( const char * dirname );
struct dirent * readdir ( DIR * dir );
int closedir ( DIR * dir );
void rewinddir ( DIR * dir );

// following POSIX function are deprecated, using ISO C++ conformant names
#undef unlink
#define unlink _unlink

void win32_display_error(const char* caption, const char* message);

#endif

int ClipboardSet( const char *text );
int ClipboardGet( char *buffer, size_t size );

#endif // COMPAT_H

