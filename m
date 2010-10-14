Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34974 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab0JNPVe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Oct 2010 11:21:34 -0400
Received: by fxm4 with SMTP id 4so2508875fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 14 Oct 2010 08:21:33 -0700 (PDT)
Date: Thu, 14 Oct 2010 11:21:33 -0400
Message-ID: <AANLkTin8tXxRFA5G8c9jKLv6aeEM8YLRX54YT5GozxK+@mail.gmail.com>
Subject: Thread scheduling issues
From: Lyle Seaman <lyleseaman@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ok.  I've been trying to figure out a performance problem with some of
my production servers (I'm just not able to get enough simultaneous
I/Os queued up to get decent performance out of my disk subsystem),
and I have run into something that strikes me as odd.  For reference,
the code I'm looking at is from a 2.6.35.22 kernel, and I know there
have been some relevant changes since then but I am not seeing the
discussion of this in the mailing list archives. If I have to figure
out the new source control system to look at the head-of-line code,
say so.

in sunrpc/svc_xprt.c:svc_recv() I find this:

        /* now allocate needed pages.  If we get a failure, sleep briefly */
 620        pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
 621        for (i = 0; i < pages ; i++)
 622                while (rqstp->rq_pages[i] == NULL) {
 623                        struct page *p = alloc_page(GFP_KERNEL);
 624                        if (!p) {
 625                                set_current_state(TASK_INTERRUPTIBLE);
 626                                if (signalled() || kthread_should_stop()) {
 627                                        set_current_state(TASK_RUNNING);
 628                                        return -EINTR;
 629                                }
 630                                schedule_timeout(msecs_to_jiffies(500));
 631                        }
 632                        rqstp->rq_pages[i] = p;
 633                }

First of all, 500ms is a long way from "brief".  Second, it seems like
a really bad idea to sleep while holding a contended resource.
Shouldn't you drop those pages before sleeping?  It's been a long time
since I knew anything about the Linux vm system, but presumably the
reason that alloc_page has failed is because there aren't 26 pages
available*.  So now I'm going to sleep while holding, say, the last 24
free pages?  This looks like deadlock city, except for the valiant
efforts by the vm system to keep freeing pages, and other adjustments
to vary sv_max_mesg depending on the number of threads which mean that
in practice, deadlock is unlikely.  But figuring out the interaction
of all those other systems requires global knowledge, which is asking
for trouble in the long run.  And there are intermediate degrees of
cascading interlocked interdependencies that result in poor
performance which aren't technically a complete deadlock.

(* I'm going to have to do some more digging here, because in my
specific situation, vmstat generally reports between 100M and 600M
free, so I'm admittedly not clear on why alloc_page is failing me,
unless there is a difference between "free" and "available for nfsd".)

And then there's this, in svc_xprt_enqueue()

 360 process:
 361        /* Work out whether threads are available */
 362        thread_avail = !list_empty(&pool->sp_threads);  /* threads
are asleep */
 363        if (pool->sp_nwaking >= SVC_MAX_WAKING) {
//  == 5 -lws
 364                /* too many threads are runnable and trying to wake up */
 365                thread_avail = 0;
 366                pool->sp_stats.overloads_avoided++;
 367        }

Now, the sp_nwaking counter is only decremented after that snippet of
code earlier, so if I've got five threads that happen to all run into
a transient problem getting the pages they need, they're going to
sleep for 500 millis and -nothing- is going to happen.

I see that this overloads_avoided branch disappeared in more recent
kernels, was there some discussion of it that you can point me to so I
don't have to rehash an old topic? I think that removing it actually
increases the likelihood of deadlock.

Finally, zero-copy is great, awesome, I love it.  But it seems
profligate to allocate an entire 26 pages for every operation when
only 9% of them (at least in my workload) are writes.  All the rest of
the operations only need a small fraction of that to be preallocated.
I don't have a concrete suggestion here, I'd have to do some tinkering
with the code first.  I'm just... saying.  Maybe allocate two pages up
front, then wait to see if the others are needed and allocate them at
that time.  If you're willing to sleep in svc_recv while holding lots
of pages, it's no worse to sleep while holding one or two.
