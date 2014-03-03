Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753241AbaCCSe3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Mar 2014 13:34:29 -0500
Date: Mon, 3 Mar 2014 13:34:22 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Dennis Jacobfeuerborn <dennisml@conversis.de>, linux-nfs@vger.kernel.org
Subject: Re: Temporary hangs when using locking with apache+nfsv4
Message-ID: <20140303133422.05f911f9@tlielax.poochiereds.net>
In-Reply-To: <0FBB168C-B923-4E83-A98B-250D9C9BE3E7@primarydata.com>
References: <53141788.9030209@conversis.de>
	<20140303104315.1f949cb4@tlielax.poochiereds.net>
	<2D6DA167-FD44-4D73-8D55-8084A8DF95BE@primarydata.com>
	<20140303114119.30f0a48f@tlielax.poochiereds.net>
	<0FBB168C-B923-4E83-A98B-250D9C9BE3E7@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 3 Mar 2014 13:22:29 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Mar 3, 2014, at 11:41, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Mon, 3 Mar 2014 10:46:37 -0500
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> >> 
> >> On Mar 3, 2014, at 10:43, Jeff Layton <jlayton@redhat.com> wrote:
> >> 
> >>> On Mon, 03 Mar 2014 06:47:52 +0100
> >>> Dennis Jacobfeuerborn <dennisml@conversis.de> wrote:
> >>> 
> >>>> Hi,
> >>>> I'm experimenting with using NFSv4 as storage for web servers and while 
> >>>> regular file access seems to work fine as soon as I bring flock() into 
> >>>> play things become more problematic.
> >>>> I've create a tiny test php script that basically opens a file, locks it 
> >>>> using flock(), writes that fact into a log file (on a local filesystem), 
> >>>> performs a usleep(1000), writes into the log that it is about to unlock 
> >>>> the file and finally unlocks it.
> >>>> I invoke that script using ab with a concurrency of 20 for a few 
> >>>> thousand requests.
> >>>> 
> >>> 
> >>> Is all the activity from a single client, or are multiple clients
> >>> contending for the lock?
> >>> 
> >>>> The result is that while 99% of the request respond quickly a few 
> >>>> request seem to hang for up to 30 seconds. According to the log file 
> >>>> they must eventually succeed since I see all expected entries and the 
> >>>> locking seems to work as well since all entries are in the expected order.
> >>>> 
> >>>> Is it expected that these long delays happen? When I comment the locking 
> >>>> function out these hangs disappear.
> >>>> Are there some knobs to tune NFS and make it behave better in these 
> >>>> situations?
> >>>> 
> >>> 
> >>> NFSv4 locking is inherently unfair. If you're doing a blocking lock,
> >>> then the client is expected to poll for it. So, long delays are
> >>> possible if you just happen to be unlucky and keep missing the lock.
> >>> 
> >>> There's no knob to tune, but there probably is room for improvement in
> >>> this code. In principle we could try to be more aggressive about
> >>> getting the lock by trying to wake up one or more blocked tasks whenever
> >>> a lock is released. You might still end up with delays, but it could
> >>> help improve responsiveness.
> >> 
> >> …or you could implement the NFSv4.1 lock callback functionality. That would scale better than more aggressive polling.
> > 
> > I had forgotten about those. I wonder what servers actually implement
> > them? I don't think Linux' knfsd does yet.
> > 
> > I wasn't really suggesting more aggressive polling. The timer semantics
> > seem fine as they are, but we could short circuit it when we know that
> > a lock on the inode has just become free.
> 
> How do we “know” that the lock is free? We already track all the locks that our client holds, and wait for those to be released. I can’t see what else there is to do.
> 

Right, we do that, but tasks that are polling for the lock don't get
woken up when a task releases a lock. They currently just wait until
the timeout occurs and then attempt to acquire the lock. The pessimal
case is that:

- try to acquire the lock and be denied
- task goes to sleep for 30s
- just after that, another task releases the lock

The first task will wait for 30s before retrying when it could have
gotten the lock soon afterward.

The idea would be to go ahead and wake up all the blocked waiters on an
inode when a task releases a lock. They'd then just re-attempt
acquiring the lock immediately instead of waiting on the timeout.

On a highly contended lock, most of the waiters would just go back to
sleep after being denied again, but one might end up getting the lock
and keeping things moving.

We could also try to be clever and only wake up tasks that are blocked
on the range being released, but in Dennis' case, he's using flock()
so that wouldn't really buy him anything.

-- 
Jeff Layton <jlayton@redhat.com>
