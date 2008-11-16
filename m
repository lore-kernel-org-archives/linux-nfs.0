From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: help understanding the current (and future) state of NFSv4
	locking?
Date: Sun, 16 Nov 2008 14:48:22 -0500
Message-ID: <20081116194822.GI21551@fieldses.org>
References: <170fa0d20811141234m3faee54dh241b9a374b7201c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59070 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922AbYKPTsY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Nov 2008 14:48:24 -0500
In-Reply-To: <170fa0d20811141234m3faee54dh241b9a374b7201c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 14, 2008 at 03:34:56PM -0500, Mike Snitzer wrote:
> Hello,
> 
> I'd like to understand the state of Linux's NFSv4 server regarding the
> NFSv4 spec's _optional_ ordered blocking lock list implementation.
> Without something like the following patch isn't there still concern
> for NFSv4 clients being starved from ever getting a conflicting lock
> (local POSIX or lockd waiters would race to get it first)?

Yes.  I have patches that approach the problem by:

	- Defining a new type of lock type, the "provisional" lock,
	  which is just like a posix lock type, *except* that it
	  doesn't merge with other locks, and hence can still be cancelled
	  safely.
	- Modifies the process of waking up waiters for a just-released
	  lock to make it a two-step process:
		1. Apply a "provisional" lock, if there are no
		   conflicts, and wake whoever was waiting for it.  (If
		   there are still conflicts, put the lock on the new
		   list without waking anyone.)
		2. Allow the waiter to upgrade the provisional lock to a
		   real posix lock (or, alternatively, to cancel it).
	- Take advantage of the above to implement fair queuing for v4,
	  by stretching out the gap between steps 1 and 2 up to a lease
	  period, thus allowing a lock that is available but that a
	  client has yet polled for to be temporarily represented by a
	  provisional lock.

The thought was that we'd also solve a couple other problems along the
way, by:

	- Preventing thundering herd problems on posix locks with lots
	  of waiters.
	- Increasing fairness of posix locking (even among local
	  lockers).

But we weren't able to actually show any improvement for posix locks
with local waiters, and it's unclear whether anyone cares much about
posix lock fairness.

So it's unclear whether it's worth doing the 2-step process above for
all posix lockers.  So maybe the patches should be written to instead
implement provisional locks as an optional extra for use of the v4
server.

A real-world test case (showing starvation of v4 clients) would be
interesting if anyone had one. 

> "fair queuing" in Linux's fs/locks.c was developed but the patch was
> never merged upstream:
> http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.13-1/linux-2.6.13-032-locks-posix-fair-queue.dif
> 
> http://wiki.linux-nfs.org/wiki/index.php/Cluster_Coherent_NFS_and_Byte_Range_Locking
> http://www.eisler.com/2008-05-09/draft-ietf-nfsv4-minorversion1-23.html#blocking_locks
> 
> 
> I'd also like to understand: what Linux NFSv4.1 support is intended
> for the _optional_ CB_NOTIFY_LOCK?:

None currently.  It shouldn't be hard to do.

--b.

> 20.11.  Operation 13: CB_NOTIFY_LOCK - Notify of possible lock availability:
> http://www.eisler.com/2008-05-09/draft-ietf-nfsv4-minorversion1-23.html#OP_CB_NOTIFY_LOCK
