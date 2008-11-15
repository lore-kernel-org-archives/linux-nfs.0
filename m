From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: [NLM] 2.6.27 broken
Date: Sat, 15 Nov 2008 14:28:31 +0100
Message-ID: <20081115132831.GA11329@janus>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:58520 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754081AbYKON2d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Nov 2008 08:28:33 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Try running multiple instances of attached program on 1 NFS client
against a 2.6.27(.5) NFSv3 server:

	gcc -Wall -Wstrict-prototypes -o lck lck.c
	for i in `seq 30`
	do
		lck &
	done

Depending on the client linux version one or more processes hang
indefinately (on 2.6.22) or receive a ENOLCK (on 2.6.27), printing:

	lck: fcntl: No locks available

Either way, /proc/locks on the server grows indefinately.

-- 
Frank

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="lck.c"

#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>

void die(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
void die(const char *fmt, ...)
{
	va_list	ap;

	va_start(ap, fmt);
	fprintf(stderr, "lck: ");
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	exit(1);
}

int main(int argc, char **argv)
{
	struct flock flock = {0};
	int i, d, locktime, cmd;
	const char *name;

	flock.l_type = F_WRLCK;		/* -w */
	flock.l_whence = SEEK_SET;
	cmd = F_SETLKW;			/* no -t */
	name = NULL;
	locktime = 10;
	for (i = 1; i < argc; ++i) {
		if (strcmp(argv[i], "-r") == 0)
			flock.l_type = F_RDLCK;		/* lock for N readers */
		else if (strcmp(argv[i], "-w") == 0)
			flock.l_type = F_WRLCK;		/* lock for 1 writer */
		else if (strcmp(argv[i], "-t") == 0)
			cmd = F_SETLK;			/* test for a lock, don't wait */
		else if (argv[i][0] == '-')
			die("Usage: lck [-r|-w] [-t] [<filename> [<locktime>]]\n");
		else if (name && isdigit(argv[i][0]))
			locktime = atoi(argv[i]);	/* after acquiring lock, wait locktime seconds */
		else
			name = argv[i];
	}
	if (!name)
		name = "lck-filename";
	d = open(name, O_RDWR|O_CREAT, 0666);
	if (d == -1)
		die("open %s: %s\n", name, strerror(errno));
	if (fcntl(d, cmd, &flock) == -1)
		die("fcntl: %s\n", strerror(errno));
	printf("locked...");
	fflush(NULL);
	sleep(locktime);
	if (close(d))
		die("close: %s\n", strerror(errno));
	printf("unlocked.\n");
	return 0;
}

--ibTvN161/egqYuK8--
