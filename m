Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49847 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753257Ab3FEM7q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 08:59:46 -0400
Date: Wed, 5 Jun 2013 08:59:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v1 07/11] locks: only pull entries off of blocked_list
 when they are really unblocked
Message-ID: <20130605125906.GC24193@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
 <1370056054-25449-8-git-send-email-jlayton@redhat.com>
 <20130604215839.GD15594@fieldses.org>
 <20130605073822.4d67c57c@corrin.poochiereds.net>
 <20130605122432.GA24193@fieldses.org>
 <20130605083859.72c855cd@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130605083859.72c855cd@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 05, 2013 at 08:38:59AM -0400, Jeff Layton wrote:
> On Wed, 5 Jun 2013 08:24:32 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Jun 05, 2013 at 07:38:22AM -0400, Jeff Layton wrote:
> > > On Tue, 4 Jun 2013 17:58:39 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Fri, May 31, 2013 at 11:07:30PM -0400, Jeff Layton wrote:
> > > > > Currently, when there is a lot of lock contention the kernel spends an
> > > > > inordinate amount of time taking blocked locks off of the global
> > > > > blocked_list and then putting them right back on again. When all of this
> > > > > code was protected by a single lock, then it didn't matter much, but now
> > > > > it means a lot of file_lock_lock thrashing.
> > > > > 
> > > > > Optimize this a bit by deferring the removal from the blocked_list until
> > > > > we're either applying or cancelling the lock. By doing this, and using a
> > > > > lockless list_empty check, we can avoid taking the file_lock_lock in
> > > > > many cases.
> > > > > 
> > > > > Because the fl_link check is lockless, we must ensure that only the task
> > > > > that "owns" the request manipulates the fl_link. Also, with this change,
> > > > > it's possible that we'll see an entry on the blocked_list that has a
> > > > > NULL fl_next pointer. In that event, just ignore it and continue walking
> > > > > the list.
> > > > 
> > > > OK, that sounds safe as in it shouldn't crash, but does the deadlock
> > > > detection still work, or can it miss loops?
> > > > 
> > > > Those locks that are temporarily NULL would previously not have been on
> > > > the list at all, OK, but...  I'm having trouble reasoning about how this
> > > > works now.
> > > > 
> > > > Previously a single lock was held interrupted across
> > > > posix_locks_deadlock and locks_insert_block() which guaranteed we
> > > > shouldn't be adding a loop, is that still true?
> > > > 
> > > > --b.
> > > > 
> > > 
> > > I had thought it was when I originally looked at this, but now that I
> > > consider it again I think you may be correct and that there are possible
> > > races here. Since we might end up reblocking behind a different lock
> > > without taking the global spinlock we could flip to blocking behind a
> > > different lock such that a loop is created if you had a complex (>2)
> > > chain of locks.
> > > 
> > > I think I'm going to have to drop this approach and instead make it so
> > > that the deadlock detection and insertion into the global blocker
> > > list/hash are atomic.
> > 
> > Right.  Once you drop the lock you can no longer be sure that what you
> > learned about the file-lock graph stays true.
> > 
> > > Ditto for locks_wake_up_blocks on posix locks and
> > > taking the entries off the list/hash.
> > 
> > Here I'm not sure what you mean.
> > 
> 
> Basically, I mean that rather than setting the fl_next pointer to NULL
> while holding only the inode lock and then ignoring those locks in the
> deadlock detection code, we should additionally take the global lock in
> locks_wake_up_blocks too and take the blocked locks off the global list
> and the i_flock list at the same time.

OK, thanks, got it.  I have a hard time thinking about that.... But yes
it bothers me that the deadlock detection code could see an out-of-date
value of fl_next, and I can't convince myself that this wouldn't result
in false positives or false negatives.

> That actually might not be completely necessary, but it'll make the
> logic clearer and easier to understand and probably won't hurt
> performance too much. Again, I'll need to do some perf testing to be
> sure.

OK!

--b.
