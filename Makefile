include config.mk

SRC = $(shell find . -name *.c)
OBJ = ${SRC:.c=.o}

all: ${NAME} README

license.h: LICENSE
	xxd -i $< $@

.c.o: config.mk
	@echo CC -c $<
	@${CC} -c $< ${CFLAGS}

${NAME}: license.h ${OBJ}
	@echo CC $@
	@${CC} -o $@ ${OBJ} ${LDFLAGS}

${NAME}.1: ${NAME}.1.tpl config.mk
	@echo CPP $<
	@${CPP} -DNAMEL=${NAME}\
		-DNAMEU=$(shell echo ${NAME} | awk '{print toupper($$0)}')\
		-DVERSION=${VERSION}\
		${ENABLE_INOTIFY} $< | sed '/^#.*/d' | sed '/^$$/d' > $@

README: ${NAME}.1
	@MANWIDTH=80 man ./$< > $@

clean:
	-rm -- *.o
	-rm -- ${NAME}
	-rm -- license.h
	-rm -- ${NAME}.1

install: all
	@echo installing to ${DESTDIR}${PREFIX}
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f ${NAME} ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/${NAME}
	@mkdir -p ${DESTDIR}${MANPREFIX}/man1
	@cp -f ${NAME}.1 ${DESTDIR}${MANPREFIX}/man1
	@chmod 644 ${DESTDIR}${MANPREFIX}/man1/${NAME}.1

uninstall:
	@echo uninstalling from ${DESTDIR}${PREFIX}
	@rm -f ${DESTDIR}${PREFIX}/bin/${NAME}
	@rm -f ${DESTDIR}${MANPREFIX}/man1/${NAME}.1

.PHONY: all clean install uninstall

