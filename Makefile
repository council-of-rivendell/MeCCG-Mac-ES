.PHONY: clean sdl

ifndef OS
OS = nix
endif

ifeq "$(OS)" "nix"
HOST :=
PLATFORM := $(shell uname -s)
BITS := $(shell getconf LONG_BIT)
BINEXT :=
CXX := g++
CC := gcc
LD := g++
STRIP := strip
CFLAGS := $(shell sdl-config --cflags)
CXXFLAGS :=
LDFLAGS :=
LDFLAGS_GUI :=
LDFLAGS_TEXT :=
endif

ifeq "$(OS)" "linux32"
HOST :=
PLATFORM := Linux
BITS := 32
BINEXT :=
CXX := g++
CC := gcc
LD := g++
STRIP := strip
CFLAGS := -m32 -Itmp/sys-linux32/usr/include -Itmp/sys-linux32/usr/include/SDL
CXXFLAGS :=
LDFLAGS := \
	-m32 -lX11 -Ltmp/sys-linux32/lib/i386-linux-gnu \
	-Ltmp/sys-linux32/usr/lib/i386-linux-gnu \
	-Wl,-rpath-link=tmp/sys-linux32/usr/lib/i386-linux-gnu/pulseaudio \
	-Wl,-rpath-link=tmp/sys-linux32/usr/lib/i386-linux-gnu \
	-Wl,-rpath-link=tmp/sys-linux32/lib/i386-linux-gnu \
	-Wl,-rpath-link=tmp/sys-linux32/usr/lib
LDFLAGS_GUI :=
LDFLAGS_TEXT :=
DLCMD := tools/debget tmp/sys-linux32 tmp/deb-linux32 i386
endif

ifeq "$(OS)" "linux64"
HOST :=
PLATFORM := Linux
BITS := 64
BINEXT :=
CXX := g++
CC := gcc
LD := g++
STRIP := strip
CFLAGS := -m64 -Itmp/sys-linux64/usr/include -Itmp/sys-linux64/usr/include/SDL
CXXFLAGS :=
LDFLAGS := \
	-m64 -lX11 \
	-Ltmp/sys-linux64/lib/x86_64-linux-gnu \
	-Ltmp/sys-linux64/usr/lib/x86_64-linux-gnu \
	-Wl,-rpath-link=tmp/sys-linux64/usr/lib/x86_64-linux-gnu/pulseaudio \
	-Wl,-rpath-link=tmp/sys-linux64/usr/lib/x86_64-linux-gnu \
	-Wl,-rpath-link=tmp/sys-linux64/lib/x86_64-linux-gnu \
	-Wl,-rpath-link=tmp/sys-linux64/usr/lib
LDFLAGS_GUI :=
LDFLAGS_TEXT :=
DLCMD := tools/debget tmp/sys-linux64 tmp/deb-linux64 amd64
endif

ifeq "$(OS)" "win32"
HOST := i686-w64-mingw32
PLATFORM := Windows
BITS := 32
BINEXT := .exe
CXX := $(HOST)-g++
CC := $(HOST)-gcc
LD := $(HOST)-g++
STRIP := $(HOST)-strip
CFLAGS := \
	-m32 -Itmp/sdl/include -Itmp/sdl/include/SDL -Wno-unknown-pragmas \
	-D_MSC_VER -DCINTERFACE
CXXFLAGS := -fpermissive
LDFLAGS := -m32 -static-libgcc -static-libstdc++ -Ltmp/sdl/lib
LDFLAGS_GUI := -mwindows -lmingw32
LDFLAGS_TEXT := -mconsole
DLCMD := $(SHELL) -c 'rm -rf "$$0"; mkdir "$$0" || exit 1; \
	[ -f "$$0.tgz" ] && [ ! "`cat "$$0.tgz" | sha256sum | sed "s/ .*//"`" = \
	"$$2" ] && rm "$$0.tgz"; if [ ! -f "$$0.tgz" ]; then curl -L -o "$$0.tgz" \
	"$$1"; if [ ! -f "$$0.tgz" ] || [ ! "`cat "$$0.tgz" | sha256sum | sed \
	"s/ .*//"`" = "$$2" ]; then rm -f "$$0.tgz"; echo "ERROR: downloading $$1 \
	failed."; exit 1; fi; fi; tar xzf "$$0.tgz" -C "$$0" --strip 1 || exit 1; \
	exit 0'
endif

ifndef PLATFORM
$(error ERROR: unsupported OS)
endif
ifdef DEBUG
ifneq "$(DEBUG)" "1"
$(error ERROR: invalid DEBUG value)
endif
endif

ifeq "$(BUILDER)" "-"
BUILDER :=
else
BUILDER := $(shell echo " build by `whoami`@`hostname`")
endif
BUILDID := $(shell \
	(	echo '$(DEBUG)'; cat Makefile; \
		find src -name '*.h' -exec cat {} \;; \
		find src -name '*.c*' -exec cat {} \; \
	) | md5sum | sed 's/ .*//' \
)
BUILDDATE := $(shell date +'%Y-%m-%d')
ifdef DEBUG
BUILDTYPE := Debug
else
BUILDTYPE := Release
endif
SYSTEM := "$(PLATFORM) $(BITS)bit $(BUILDTYPE)$(BUILDER) $(BUILDDATE) ($(BUILDID))"

CFLAGS := -Isrc/include -Wall $(CFLAGS)
ifdef DEBUG
CFLAGS := $(CFLAGS) -g
else
CFLAGS := $(CFLAGS) -O3
endif
CXXFLAGS := -ftemplate-depth-30  $(CFLAGS) $(CXXFLAGS)

LIBS_COMMON := -lSDLmain -lSDL -lSDL_net -framework Cocoa
LIBS_GUI := $(LIBS_COMMON) -lSDL_image -lSDL_ttf -lSDL_mixer
LIBS_TEXT := $(LIBS_COMMON) -lSDL -lSDL_net

OBJS_COMMON := \
	src/parser_libcards.o src/parser_libnet.o src/parser.o \
	src/data_filedb.o src/parser_lib.o src/tools.o src/carddata.o \
	src/xml_parser.o src/security.o src/data.o src/localization.o src/compat.o
OBJS_CLIENT := \
	$(OBJS_COMMON) src/client.o src/driver.o src/game.o src/interpreter.o \
	src/SDL_rotozoom.o
OBJS_CLIENT_GUI := $(OBJS_CLIENT) src/sdl-driver.o src/game-sdl-version.o
OBJS_CLIENT_TEXT := $(OBJS_CLIENT) src/text-driver.o src/game-text-version.o
OBJS_SERVER := $(OBJS_COMMON) src/server.o
OBJS_SH := $(OBJS_COMMON) src/gccg.o
OBJS_STATS := $(OBJS_COMMON) src/parse_stats.o

DEFINES := \
	-DPACKAGE=\"GCCG\" -DSYSTEM=\"$(SYSTEM)\" -DCCG_DATADIR=\".\" \
	-DCCG_SAVEDIR=\"./save\" -DSTACK_TRACE

CXXCMD := $(CXX) $(DEFINES) $(CXXFLAGS) -c
CCCMD := $(CC) $(DEFINES) $(CFLAGS) -c
LDCMD := $(LD) $(LDFLAGS)
ifdef DEBUG
STRIPCMD := \# DEBUG BUILD: not stripping
else
STRIPCMD := $(STRIP) -s
endif

###############################################################################

all: client server

clean:
	rm -f src/*.o

src/%.o: src/%.cpp src/include/*.h
	$(CXXCMD) -o $@ $<

src/game-sdl-version.o: src/game-draw.cpp
	$(CXXCMD) -DSDL_VERSION -o src/game-sdl-version.o src/game-draw.cpp

src/game-text-version.o: src/game-draw.cpp
	$(CXXCMD) -DTEXT_VERSION -o src/game-text-version.o src/game-draw.cpp

src/SDL_rotozoom.o: src/SDL_rotozoom.c
	$(CCCMD) -o src/SDL_rotozoom.o src/SDL_rotozoom.c

ccg_client$(BINEXT): $(OBJS_CLIENT_GUI)
	$(LDCMD) $(LDFLAGS_GUI) -o ccg_client$(BINEXT) $(OBJS_CLIENT_GUI) $(LIBS_GUI)
	$(STRIPCMD) ccg_client$(BINEXT)

ccg_text_client$(BINEXT): $(OBJS_CLIENT_TEXT)
	$(LDCMD) $(LDFLAGS_TEXT) -o ccg_text_client$(BINEXT) $(OBJS_CLIENT_TEXT) \
		$(LIBS_TEXT)
	$(STRIPCMD) ccg_text_client$(BINEXT)

ccg_server$(BINEXT): $(OBJS_SERVER)
	$(LDCMD) $(LDFLAGS_TEXT) -o ccg_server$(BINEXT) $(OBJS_SERVER) $(LIBS_TEXT)
	$(STRIPCMD) ccg_server$(BINEXT)

ccg_sh$(BINEXT): $(OBJS_SH)
	$(LDCMD) $(LDFLAGS_TEXT) -o ccg_sh$(BINEXT) $(OBJS_SH) $(LIBS_TEXT)
	$(STRIPCMD) ccg_sh$(BINEXT)

ccg_stats$(BINEXT): $(OBJS_STATS)
	$(LDCMD) $(LDFLAGS_TEXT) -o ccg_stats$(BINEXT) $(OBJS_STATS) $(LIBS_TEXT)
	$(STRIPCMD) ccg_stats$(BINEXT)

client: ccg_client$(BINEXT)
client-text: ccg_text_client$(BINEXT)
server: ccg_server$(BINEXT)
shell: ccg_sh$(BINEXT)
stats: ccg_stats$(BINEXT)

###############################################################################

sdl:
ifndef DLCMD
	$(error ERROR: not crossbuilding)
endif
ifeq "$(OS)" "win32"
	rm -rf tmp/jpeg tmp/zlib tmp/png tmp/ft2 tmp/ogg tmp/vorbis tmp/sdl
	mkdir -p tmp/jpeg tmp/zlib/include tmp/zlib/lib tmp/zlib/bin tmp/png \
		tmp/ft2 tmp/ogg tmp/vorbis tmp/sdl
	$(DLCMD) tmp/sdl-src https://www.libsdl.org/release/SDL-1.2.15.tar.gz \
		d6d316a793e5e348155f0dd93b979798933fb98aa1edebcc108829d6474aad00
	$(DLCMD) tmp/sdl-net-src \
		https://www.libsdl.org/projects/SDL_net/release/SDL_net-1.2.8.tar.gz \
		5f4a7a8bb884f793c278ac3f3713be41980c5eedccecff0260411347714facb4
	$(DLCMD) tmp/jpeg-src http://www.ijg.org/files/jpegsrc.v9a.tar.gz \
		3a753ea48d917945dd54a2d97de388aa06ca2eb1066cbfdc6652036349fe05a7
	$(DLCMD) tmp/zlib-src http://zlib.net/zlib-1.2.8.tar.gz \
		36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d
	$(DLCMD) tmp/png-src \
		ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/libpng-1.6.17.tar.gz \
		a18233c99e1dc59a256180e6871d9305a42e91b3f98799b3ceb98e87e9ec5e31
	$(DLCMD) tmp/sdl-image-src \
		https://www.libsdl.org/projects/SDL_image/release/SDL_image-1.2.12.tar.gz \
		0b90722984561004de84847744d566809dbb9daf732a9e503b91a1b5a84e5699
	$(DLCMD) tmp/ft2-src \
		http://download.savannah.gnu.org/releases/freetype/freetype-2.5.5.tar.gz \
		5d03dd76c2171a7601e9ce10551d52d4471cf92cd205948e60289251daddffa8
	$(DLCMD) tmp/sdl-ttf-src \
		https://www.libsdl.org/projects/SDL_ttf/release/SDL_ttf-2.0.11.tar.gz \
		724cd895ecf4da319a3ef164892b72078bd92632a5d812111261cde248ebcdb7
	$(DLCMD) tmp/ogg-src \
		http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz \
		e19ee34711d7af328cb26287f4137e70630e7261b17cbe3cd41011d73a654692
	$(DLCMD) tmp/vorbis-src \
		http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz \
		6efbcecdd3e5dfbf090341b485da9d176eb250d893e3eb378c428a2db38301ce
	$(DLCMD) tmp/sdl-mixer-src \
		https://www.libsdl.org/projects/SDL_mixer/release/SDL_mixer-1.2.12.tar.gz \
		1644308279a975799049e4826af2cfc787cad2abb11aa14562e402521f86992a
	cd tmp/sdl-src && ./configure --host=$(HOST) "--prefix=`pwd`/../sdl"
	cd tmp/sdl-src && make install
	sed -i'' 's/#error You.*//' tmp/sdl/include/SDL/SDL_config.h
	cd tmp/sdl-net-src && SDL_CONFIG="`pwd`/../sdl/bin/sdl-config" \
		CPPFLAGS="-I`pwd`/../sdl/include/SDL" LDFLAGS="-L`pwd`/../sdl/lib" \
		./configure --host=$(HOST) "--prefix=`pwd`/../sdl"
	cd tmp/sdl-net-src && make install-libLTLIBRARIES \
		install-libSDL_netincludeHEADERS
	cd tmp/jpeg-src && ./configure --host=$(HOST) "--prefix=`pwd`/../jpeg"
	cd tmp/jpeg-src && make install
	cd tmp/zlib-src && sed 's/^PREFIX =.*$$//' win32/Makefile.gcc | \
		PREFIX="$(HOST)-" $(MAKE) -f -
	cp tmp/zlib-src/*.h tmp/zlib/include
	cp tmp/zlib-src/*.a tmp/zlib/lib
	cp tmp/zlib-src/*.dll tmp/zlib/bin
	cd tmp/png-src && LDFLAGS="-L`pwd`/../zlib/lib" \
		CPPFLAGS="-I`pwd`/../zlib/include" ./configure --host=$(HOST) \
		"--prefix=`pwd`/../png"
	cd tmp/png-src && make install
	cd tmp/sdl-image-src && SDL_CONFIG="`pwd`/../sdl/bin/sdl-config" \
		CPPFLAGS="-I`pwd`/../jpeg/include -I`pwd`/../png/include \
		-I`pwd`/../zlib/include -I`pwd`/../sdl/include/SDL" \
		LDFLAGS="-L`pwd`/../jpeg/lib -L`pwd`/../png/lib -L`pwd`/../sdl/lib" \
		./configure --host=$(HOST) "--prefix=`pwd`/../sdl" \
		--enable-jpg-shared=no --enable-png-shared=no --enable-tif-shared=no \
		--enable-webp-shared=no --enable-lbm=no --enable-pnm=no \
		--enable-tga=no --enable-tif=no --enable-xcf=no --enable-xcm=no \
		--enable-xv=no --enable-webp=no
	sed -i'' 's|-I/usr/include/libpng12||' tmp/sdl-image-src/Makefile
	cd tmp/sdl-image-src && make install-libLTLIBRARIES \
		install-libSDL_imageincludeHEADERS
	cd tmp/ft2-src && ./configure --host=$(HOST) "--prefix=`pwd`/../ft2" \
		--with-zlib=no --with-png=no
	cd tmp/ft2-src && make all install
	cd tmp/sdl-ttf-src && SDL_CONFIG="`pwd`/../sdl/bin/sdl-config" \
		CPPFLAGS="-I`pwd`/../sdl/include/SDL" LDFLAGS="-L`pwd`/../sdl/lib" \
		./configure --host=$(HOST) "--prefix=`pwd`/../sdl" \
		"--with-freetype-prefix=`pwd`/../ft2"
	cd tmp/sdl-ttf-src && make install-libLTLIBRARIES \
		install-libSDL_ttfincludeHEADERS
	cd tmp/ogg-src && ./configure --host=$(HOST) "--prefix=`pwd`/../ogg"
	cd tmp/ogg-src && make install
	cd tmp/vorbis-src && CFLAGS="-I`pwd`/../ogg/include" \
		LDFLAGS="-L`pwd`/../ogg/lib" ./configure --host=$(HOST) \
		"--prefix=`pwd`/../vorbis" "--with-ogg=`pwd`/../ogg" --enable-shared=yes
	cd tmp/vorbis-src && make install
	cd tmp/sdl-mixer-src && SDL_CONFIG="`pwd`/../sdl/bin/sdl-config" \
		CPPFLAGS="-I`pwd`/../sdl/include/SDL -I`pwd`/../vorbis/include \
		-I`pwd`/../ogg/include" LDFLAGS="-L`pwd`/../vorbis/lib \
		-L`pwd`/../sdl/lib -L`pwd`/../ogg/lib -logg" ./configure --host=$(HOST) \
		"--prefix=`pwd`/../sdl" --enable-music-ogg-shared=no \
		--enable-music-mod=no --enable-music-midi=no --enable-music-flac=no \
		--enable-music-mp3=no
	sed -i'' 's| -pthread||;s|-I/usr/include/SDL||' tmp/sdl-mixer-src/Makefile
	cd tmp/sdl-mixer-src && make install-lib install-hdrs
	cp tmp/sdl/bin/*.dll .
	cp tmp/jpeg/bin/*.dll .
	cp tmp/png/bin/*.dll .
	cp tmp/zlib/bin/*.dll .
	cp tmp/ft2/bin/*.dll .
	cp tmp/ogg/bin/*.dll .
	cp tmp/vorbis/bin/libvorbis-*.dll .
	cp tmp/vorbis/bin/libvorbisfile-*.dll .
endif
ifeq "$(PLATFORM)" "Linux"
	$(DLCMD) libsdl1.2-dev
	$(DLCMD) libsdl-image1.2-dev
	$(DLCMD) libsdl-net1.2-dev
	$(DLCMD) libsdl-ttf2.0-dev
	$(DLCMD) libsdl-mixer1.2-dev
endif
