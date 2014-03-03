Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57109 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754298AbaCCUl6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Mar 2014 15:41:58 -0500
Date: Mon, 3 Mar 2014 15:41:54 -0500
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dennis Jacobfeuerborn <dennisml@conversis.de>,
        linux-nfs@vger.kernel.org
Subject: Re: Temporary hangs when using locking with apache+nfsv4
Message-ID: <20140303204154.GC10659@fieldses.org>
References: <53141788.9030209@conversis.de>
 <20140303104315.1f949cb4@tlielax.poochiereds.net>
 <2D6DA167-FD44-4D73-8D55-8084A8DF95BE@primarydata.com>
 <20140303114119.30f0a48f@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20140303114119.30f0a48f@tlielax.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 03, 2014 at 11:41:19AM -0500, Jeff Layton wrote:
> On Mon, 3 Mar 2014 10:46:37 -0500
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > 
> > On Mar 3, 2014, at 10:43, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > On Mon, 03 Mar 2014 06:47:52 +0100
> > > Dennis Jacobfeuerborn <dennisml@conversis.de> wrote:
> > > 
> > >> Hi,
> > >> I'm experimenting with using NFSv4 as storage for web servers and while 
> > >> regular file access seems to work fine as soon as I bring flock() into 
> > >> play things become more problematic.
> > >> I've create a tiny test php script that basically opens a file, locks it 
> > >> using flock(), writes that fact into a log file (on a local filesystem), 
> > >> performs a usleep(1000), writes into the log that it is about to unlock 
> > >> the file and finally unlocks it.
> > >> I invoke that script using ab with a concurrency of 20 for a few 
> > >> thousand requests.
> > >> 
> > > 
> > > Is all the activity from a single client, or are multiple clients
> > > contending for the lock?
> > > 
> > >> The result is that while 99% of the request respond quickly a few 
> > >> request seem to hang for up to 30 seconds. According to the log file 
> > >> they must eventually succeed since I see all expected entries and the 
> > >> locking seems to work as well since all entries are in the expected order.
> > >> 
> > >> Is it expected that these long delays happen? When I comment the locking 
> > >> function out these hangs disappear.
> > >> Are there some knobs to tune NFS and make it behave better in these 
> > >> situations?
> > >> 
> > > 
> > > NFSv4 locking is inherently unfair. If you're doing a blocking lock,
> > > then the client is expected to poll for it. So, long delays are
> > > possible if you just happen to be unlucky and keep missing the lock.
> > > 
> > > There's no knob to tune, but there probably is room for improvement in
> > > this code. In principle we could try to be more aggressive about
> > > getting the lock by trying to wake up one or more blocked tasks whenever
> > > a lock is released. You might still end up with delays, but it could
> > > help improve responsiveness.
> > 
> > …or you could implement the NFSv4.1 lock callback functionality. That would scale better than more aggressive polling.
> 
> I had forgotten about those. I wonder what servers actually implement
> them? I don't think Linux' knfsd does yet.

No.  How I'd imagined it would work:

	- on a failed blocking lock request, insert a waiter.
	- when the lock the waiter is blocking on is released or
	  downgraded, apply the waiting lock as a "provisional" lock:
	  add it to the i_flock list, but *don't* allow it to downgrade
	  or merge with any existing locks.  Then send the callback.
	- when the client resends the lock request, finish applying the
	  lock.  This is when we downgrade, merge, or split as
	  necessary.
	- Alternatively, if some timeout passes without the client
	  requesting the lock again, give up and remove the
	  "provisional" lock.

Then we need to implement the client side too.  And there are some more
(optional) suggestions in 9.6.

--b.

> I wasn't really suggesting more aggressive polling. The timer semantics
> seem fine as they are, but we could short circuit it when we know that
> a lock on the inode has just become free.
> 
> Maybe we could share the sillyrename waitqueue, and have clients sleep
> on that. When we go to send the LOCKU request, we'd wake up the queue.
> 
> It's not any more fair, but could improve latency in some cases.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
