.TH NAMEU 1 NAMEL\-VERSION
.SH NAME
fifofo - hold FIFO's open
.SH SYNOPSIS
NAMEL FIFO
.SH DESCRIPTION
NAMEL stands for
.I FIFO fopen\c
\&. It's a simple tool that calls
.BI fopen
on a FIFO\c
#ifdef ENABLE_INOTIFY
 and exits when the FIFO is deleted using
.BI inotify\c
#endif
\&.
.PP
This is useful for processes that are supposed to run as daemons but accept input from stdin to provide some kind of console functionality.
Some people run these in screen or tmux sessions to retain the console functionality, but lose the benefits of some kind of service supervisor.
The obvious solution is to create a FIFO and pipe it into the process.
But that has it's own problems.
The process that opens the FIFO for reading will hang until some other process opens the FIFO for writing.
Not useful if you do not need the console at all times.
Also, if the last writer closes the
FIFO, it will send
.I EOF
to the reading process and it will most likely stop reading.
Which means you will never be able to disconnect your console.
Not very practical.
.PP
This tool was written as a simple way to combat this problem.
Just start NAMEL with the filename of your FIFO as the first argument and fifofo will magically make everything work.
.SH OPTIONS
.TP
.B \-h, \-\-help
display a short help message
.TP
.B \-\-version
displays version and license information
.TP
.B \-m mode, \-\-mode mode
file mode which NAMEL uses to open the fifo instead of default "a" (see
.BR fopen (3))
.SH AUTHOR
Lukas Henkel <lh@gehweg.org>
.SH LICENSE
MIT
