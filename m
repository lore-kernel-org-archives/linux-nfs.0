From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: nfs: lock stuck after interrupt
Date: Fri, 18 Apr 2008 13:07:16 +0200
Message-ID: <E1JmoR2-0005j2-VU@pomaz-ex.szeredi.hu>
References: <E1JmY9Y-0004e4-7R@pomaz-ex.szeredi.hu> <e7ca40f70804171230l31aa6978x6ebfb41f9e4e7ba7@mail.gmail.com>
Cc: miklos@szeredi.hu, bfields@fieldses.org,
	trond.myklebust@fys.uio.no, eshel@almaden.ibm.com, neilb@suse.de,
	akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: epiphani@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753124AbYDRLIZ@vger.kernel.org>
In-reply-to: <e7ca40f70804171230l31aa6978x6ebfb41f9e4e7ba7@mail.gmail.com>
	(epiphani@gmail.com)
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> We brought up this specific issue a few weeks ago in this thread:
> 
> http://marc.info/?l=linux-nfs&m=120663578712912&w=2
> 
> While we had a fix that tested out properly (third reply in the
> thread), I believe Trond fixed this recently in a more "correct"
> method with this patch (and series):
> 
> http://marc.info/?l=linux-nfs&m=120726349027607&w=2
> 
> We haven't had the opportunity to check Tronds' patch yet though.

Thanks for the info.

1) I pulled the devel branch of nfs-2.6.git and tested the same setup,
   with exactly the same result as previously.

2) then I added your patch on top of that, which did change something
   but not really for the better: now even the restarted lock request
   doesn't succeed after the interrupt.

According to my suspicion, this is an issue in the server, while both
referenced patches touch only the client.

Appended little test program which I'm trying out locking with.

Miklos
---

#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <signal.h>

static void int_handler(int s)
{
	(void) s;
	fprintf(stderr, "signal caught\n");
}

int main(int argc, char *argv[])
{
	char *filename = argv[1];
	int res;
	int fd;

	if (argc != 2) {
		fprintf(stderr, "usage: %s filename\n", argv[0]);
		return 1;
	}

	signal(SIGINT, int_handler);

	fd = open(filename, O_RDWR | O_CREAT, 0666);
	if (fd == -1) {
		perror("open");
		return 1;
	}

	res = lockf(fd, F_LOCK, 100);
	if (res == -1) {
		perror("lockf");
		return 1;
	}
	printf("locked\n");
	pause();
	return 0;
}
