#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#ifdef ENABLE_INOTIFY
#include <sys/inotify.h>
#include <limits.h>
#include <libgen.h>
#include <errno.h>
#endif

#include "license.h"

#ifdef ENABLE_INOTIFY
static const size_t BUF_LEN_INOTIFY = sizeof(struct inotify_event) + NAME_MAX + 1;
#endif

void
usage(FILE *out)
{
	fprintf(out, "Usage: %s [-m mode] FIFO\n", NAME);
}

void
version()
{
	//As if I will ever update this thing...
	printf("%s %s\n\n%.*s", NAME, VERSION, LICENSE_len, LICENSE);
#ifdef ENABLE_INOTIFY
	puts("\ncompiled with inotify support");
#endif
}

#ifdef ENABLE_INOTIFY
void
continue_on_delete(char *path)
{
	int fd;
	char *dir;
	char *file;
	char buf[BUF_LEN_INOTIFY];
	ssize_t readlen;
	struct inotify_event *event;

	if ((fd = inotify_init()) < 0) {
		perror("inotify_init");
		return;
	}
	dir = dirname(path);
	file = basename(path);
	if (inotify_add_watch(fd, dir, IN_DELETE) < 0) {
		perror("inotify_add_watch");
		goto error;
	}
	while ((readlen = read(fd, &buf, BUF_LEN_INOTIFY))) {
		event = (struct inotify_event *)&buf;
		if (strcmp(event->name, file) == 0) {
			break;
		}
	}
	if (readlen < 0 && readlen != EINTR) {
		perror("read");
	}
error:
	close(fd);
}
#endif

int
main(int argc, char *argv[])
{
	char *arg = NULL;
	FILE *file;
	char *mode = "a";

	for (int i = 1; i < argc; i++) {
		arg = argv[i];
		if (strcmp(arg, "-h") == 0 || strcmp(arg, "--help") == 0) {
			usage(stdout);
			exit(EXIT_SUCCESS);
		}
		if (strcmp(arg, "--version") == 0) {
			version();
			exit(EXIT_SUCCESS);
		}

		if (i + 1 == argc) {
			if (arg[0] != '-') {
				break;
			}
			usage(stderr);
			exit(EXIT_FAILURE);
		}

		if (strcmp(arg, "-m") == 0 || strcmp(arg, "--mode") == 0) {
			mode = argv[++i];
		} else if (arg[0] == '-') {
			usage(stderr);
			exit(EXIT_FAILURE);
		}
	}

	if (!arg) {
		usage(stderr);
		exit(EXIT_FAILURE);
	}

	if (access(arg, W_OK) < 0) {
		perror("access");
		exit(EXIT_FAILURE);
	}
	file = fopen(arg, mode);
	if (!file) {
		perror("fopen");
		exit(EXIT_FAILURE);
	}
#ifdef ENABLE_INOTIFY
	continue_on_delete(arg);
#else
	pause();
#endif
	fclose(file);
	return 0;
}
