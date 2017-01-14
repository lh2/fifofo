NAME = fifofo
VERSION = 1.0

PREFIX = /usr/local
MANPREFIX = ${PREFIX}/share/man

CC = cc
CPP = cpp
CFLAGS = -std=c99 -Wall -Wextra -pedantic -O3 -D_XOPEN_SOURCE=700 -DNAME=\"${NAME}\" -DVERSION=\"${VERSION}\" -DENABLE_INOTIFY

