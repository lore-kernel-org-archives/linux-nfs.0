From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: help understanding the current (and future) state of NFSv4
	locking?
Date: Fri, 21 Nov 2008 20:34:49 -0500
Message-ID: <20081122013449.GB28485@fieldses.org>
References: <170fa0d20811141234m3faee54dh241b9a374b7201c@mail.gmail.com> <20081116194822.GI21551@fieldses.org> <170fa0d20811171618l140a0e26ycfc58ae7f10e6e0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756642AbYKVBeu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Nov 2008 20:34:50 -0500
In-Reply-To: <170fa0d20811171618l140a0e26ycfc58ae7f10e6e0c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 17, 2008 at 07:18:32PM -0500, Mike Snitzer wrote:
> On Sun, Nov 16, 2008 at 2:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > A real-world test case (showing starvation of v4 clients) would be
> > interesting if anyone had one.
> 
> I'm not sure what your definition of "real-world test case" is (so
> maybe the following is moot) but the attached program (written by a
> co-worker) can be used to easily illustrate the starvation of v4
> clients.  The program tests to see how long it takes to lock/unlock a
> file 1000 times.  If ran locally on the nfs-server against an exported
> ext3 FS I get a "step time" of 11ms.  Ran from a v3 client: ~390ms.
> Ran from a v4 client: ~430ms.

Yeah, it's not surprising that it'd be reproduceable in the presence of
processes requesting and dropping a lock in a tight loop like that; I
just wonder under what workloads this would be common, and whether such
frequent file lock contention would already cause other problems.

Time to get a lock 1000 times is still going to be very long even after
adding the fair queueing for v4, since the client isn't required to poll
more than once a lease period, if I recall the spec correctly.  So,
you're right, we should also experiment with the 4.1 lock notification
callback.

--b.

> 
> ran simultaneously on the nfs-server and the v3 client; local=~30ms, v3=~440ms
> ran simultaneously on two v3 clients; both v3=~580ms
> ran simultaneously on the nfs-server and the two v3 clients; both
> v3=~580ms, but local ranges ~1500ms to ~9300ms
> ran simultaneously on two v4 clients; v4=~430ms but with frequent
> interleaved outliers ranging from ~1500ms to ~75000ms
> ran simultaneously on the nfs-server and the v4 client; local=~11ms, v4=STARVED
> ran simultaneously on the v3 and the v4 client; v3=~390ms, v4=STARVED
> 
> FYI, "STARVED" above doesn't mean the v4 client _never_ acquires the
> lock.   It eventually acquires the lock; albeit extremely rarely (e.g.
> after 5min) because v4 client polling is predisposed to lose the race
> with either the hyper-active v3 client or the local locker.
> 
> Mike

> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <sys/time.h>
> #include <string.h>
> #include <errno.h>
> 
> #define STEP 1000
> #define CMD F_SETLKW
> 
> int main(int argc, char **argv) {
> 	struct flock lc_rq = {F_WRLCK, SEEK_CUR, 0, 100, 0};
> 	int i, ret = 0;
> 	char str[10];
> 	unsigned long sleep_timeout = 0;
> 	struct timeval tv_start, tv_prev, tv_cur;
> 	int fd1 = open(argv[1], O_RDWR), fd2 = 0;
> 	off_t start = 0;
> 
> 	gettimeofday(&tv_start, NULL);
> 	tv_cur = tv_prev = tv_start;
> 
> 	for (i=0;;i++) {
> 		lc_rq.l_type = F_WRLCK;
> 		ret = fcntl(fd1, CMD, &lc_rq);
> 
> 		lc_rq.l_type = F_UNLCK;
> 		ret = fcntl(fd1, CMD, &lc_rq);
> 
> 		if (0 == i%STEP) {
> 			gettimeofday(&tv_cur, NULL);
> 			printf("i=%d tot time = %dms (step time= %dms)\n", i/STEP,
> 			       1000*(tv_cur.tv_sec - tv_start.tv_sec) + (tv_cur.tv_usec - tv_start.tv_usec)/1000,
> 			       1000*(tv_cur.tv_sec - tv_prev.tv_sec) + (tv_cur.tv_usec - tv_prev.tv_usec)/1000);
> 			tv_prev = tv_cur;
> 		}
> 	}
> 	return 0;
> }
> 

