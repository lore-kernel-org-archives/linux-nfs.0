From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Wed, 23 Dec 2009 19:39:12 +0100
Message-ID: <20091223183912.GE3159@quack.suse.cz>
References: <1261015420.1947.54.camel@serenity>
 <1261037877.27920.36.camel@laptop>
 <20091219122033.GA11360@localhost>
 <1261232747.1947.194.camel@serenity>
 <20091222122557.GA604@atrey.karlin.mff.cuni.cz>
 <1261498815.13028.63.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>
To: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54699 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754893AbZLWSjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Dec 2009 13:39:19 -0500
In-Reply-To: <1261498815.13028.63.camel@serenity>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 22-12-09 11:20:15, Steve Rago wrote:
> 
> On Tue, 2009-12-22 at 13:25 +0100, Jan Kara wrote:
> > > I originally spent several months playing with the balance_dirty_pages
> > > algorithm.  The main drawback is that it affects more than the inodes
> > > that the caller is writing and that the control of what to do is too
> >   Can you be more specific here please?
> 
> Sure;  balance_dirty_pages() will schedule writeback by the flusher
> thread once the number of dirty pages exceeds dirty_background_ratio.
> The flusher thread calls writeback_inodes_wb() to flush all dirty inodes
> associated with the bdi.  Similarly, the process dirtying the pages will
> call writeback_inodes_wbc() when it's bdi threshold has been exceeded.
> The first problem is that these functions process all dirty inodes with
> the same backing device, which can lead to excess (duplicate) flushing
> of the same inode.  Second, there is no distinction between pages that
> need to be committed and pages that have commits pending in
> NR_UNSTABLE_NFS/BDI_RECLAIMABLE (a page that has a commit pending won't
> be cleaned any faster by sending more commits).  This tends to overstate
> the amount of memory that can be cleaned, leading to additional commit
> requests.  Third, these functions generate a commit for each set of
> writes they do, which might not be appropriate.  For background writing,
> you'd like to delay the commit as long as possible.
  Ok, I get it. Thanks for explanation. The problem with more writing
threads bites us also for ordinary SATA drives (the IO pattern and thus
throughput gets worse and worse the more threads do writes). The plan is to
let only flusher thread do the IO and throttled thread in
balance_dirty_pages just waits for flusher thread to do the work. There
were even patches for this floating around but I'm not sure what's happened
to them. So that part of the problem should be easy to solve.
  Another part is about sending commits - if we have just one thread doing
flushing, we have no problems with excessive commits for one inode. You're
right that we may want to avoid sending commits for background writeback
but until we send the commit, pages are just accumulating in the unstable
state, aren't they? So we might want to periodically send the commit for
the inode anyway to get rid of those pages. So from this point of view,
sending commit after each writepages call does not seem like a so bad idea
- although it might be more appropriate to send it some time after the
writepages call when we are not close to dirty limit so that server has
more time to do more natural "unforced" writeback...

> > > Part of the patch does implement a heuristic write-behind.  See where
> > > nfs_wb_eager() is called.
> >   I believe that if we had per-bdi dirty_background_ratio and set it low
> > for NFS's bdi, then the write-behind logic would not be needed
> > (essentially the flusher thread should submit the writes to the server
> > early).
> > 
> Maybe so, but you still need something to prevent the process that is
> dirtying pages from continuing, because a process can always write to
> memory faster than writing to disk/network, so the flusher won't be able
> to keep up.
  Yes, I agree that part is needed. But Fengguang already had patches in
that direction if my memory serves me well.

  So to recap: If we block tasks in balance_dirty_pages until unstable
pages are committed and make just one thread do the writing, what else is
missing to make you happy? :)
								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
