From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NLM] 2.6.27 broken
Date: Thu, 20 Nov 2008 17:27:31 -0500
Message-ID: <20081120222731.GA591@fieldses.org>
References: <20081115132831.GA11329@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57577 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827AbYKTW1e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Nov 2008 17:27:34 -0500
In-Reply-To: <20081115132831.GA11329@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 15, 2008 at 02:28:31PM +0100, Frank van Maarseveen wrote:
> Try running multiple instances of attached program on 1 NFS client
> against a 2.6.27(.5) NFSv3 server:
> 
> 	gcc -Wall -Wstrict-prototypes -o lck lck.c
> 	for i in `seq 30`
> 	do
> 		lck &
> 	done

Or reproduceable using the "flock" utility with:

	for i in `seq 30`
	do
		flock /mnt/foo sleep 10
	done

Hm.  What's the last known good server version?

--b.

> 
> Depending on the client linux version one or more processes hang
> indefinately (on 2.6.22) or receive a ENOLCK (on 2.6.27), printing:
> 
> 	lck: fcntl: No locks available
> 
> Either way, /proc/locks on the server grows indefinately.
> 
> -- 
> Frank

> #include <stdio.h>
> #include <ctype.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <errno.h>
> #include <string.h>
> #include <stdarg.h>
> #include <stdlib.h>
> 
> void die(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
> void die(const char *fmt, ...)
> {
> 	va_list	ap;
> 
> 	va_start(ap, fmt);
> 	fprintf(stderr, "lck: ");
> 	vfprintf(stderr, fmt, ap);
> 	va_end(ap);
> 	exit(1);
> }
> 
> int main(int argc, char **argv)
> {
> 	struct flock flock = {0};
> 	int i, d, locktime, cmd;
> 	const char *name;
> 
> 	flock.l_type = F_WRLCK;		/* -w */
> 	flock.l_whence = SEEK_SET;
> 	cmd = F_SETLKW;			/* no -t */
> 	name = NULL;
> 	locktime = 10;
> 	for (i = 1; i < argc; ++i) {
> 		if (strcmp(argv[i], "-r") == 0)
> 			flock.l_type = F_RDLCK;		/* lock for N readers */
> 		else if (strcmp(argv[i], "-w") == 0)
> 			flock.l_type = F_WRLCK;		/* lock for 1 writer */
> 		else if (strcmp(argv[i], "-t") == 0)
> 			cmd = F_SETLK;			/* test for a lock, don't wait */
> 		else if (argv[i][0] == '-')
> 			die("Usage: lck [-r|-w] [-t] [<filename> [<locktime>]]\n");
> 		else if (name && isdigit(argv[i][0]))
> 			locktime = atoi(argv[i]);	/* after acquiring lock, wait locktime seconds */
> 		else
> 			name = argv[i];
> 	}
> 	if (!name)
> 		name = "lck-filename";
> 	d = open(name, O_RDWR|O_CREAT, 0666);
> 	if (d == -1)
> 		die("open %s: %s\n", name, strerror(errno));
> 	if (fcntl(d, cmd, &flock) == -1)
> 		die("fcntl: %s\n", strerror(errno));
> 	printf("locked...");
> 	fflush(NULL);
> 	sleep(locktime);
> 	if (close(d))
> 		die("close: %s\n", strerror(errno));
> 	printf("unlocked.\n");
> 	return 0;
> }

