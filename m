From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Wed, 23 Dec 2009 22:49:12 +0100
Message-ID: <1261604952.18047.7.camel@localhost>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost>
	 <1261232747.1947.194.camel@serenity>
	 <20091222122557.GA604@atrey.karlin.mff.cuni.cz>
	 <1261498815.13028.63.camel@serenity>  <20091223183912.GE3159@quack.suse.cz>
	 <1261599385.13028.142.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>
To: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36492 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755493AbZLWVtU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Dec 2009 16:49:20 -0500
In-Reply-To: <1261599385.13028.142.camel@serenity>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-12-23 at 15:16 -0500, Steve Rago wrote: 
> On Wed, 2009-12-23 at 19:39 +0100, Jan Kara wrote:
> > On Tue 22-12-09 11:20:15, Steve Rago wrote:
> > > 
> > > On Tue, 2009-12-22 at 13:25 +0100, Jan Kara wrote:
> > > > > I originally spent several months playing with the balance_dirty_pages
> > > > > algorithm.  The main drawback is that it affects more than the inodes
> > > > > that the caller is writing and that the control of what to do is too
> > > >   Can you be more specific here please?
> > > 
> > > Sure;  balance_dirty_pages() will schedule writeback by the flusher
> > > thread once the number of dirty pages exceeds dirty_background_ratio.
> > > The flusher thread calls writeback_inodes_wb() to flush all dirty inodes
> > > associated with the bdi.  Similarly, the process dirtying the pages will
> > > call writeback_inodes_wbc() when it's bdi threshold has been exceeded.
> > > The first problem is that these functions process all dirty inodes with
> > > the same backing device, which can lead to excess (duplicate) flushing
> > > of the same inode.  Second, there is no distinction between pages that
> > > need to be committed and pages that have commits pending in
> > > NR_UNSTABLE_NFS/BDI_RECLAIMABLE (a page that has a commit pending won't
> > > be cleaned any faster by sending more commits).  This tends to overstate
> > > the amount of memory that can be cleaned, leading to additional commit
> > > requests.  Third, these functions generate a commit for each set of
> > > writes they do, which might not be appropriate.  For background writing,
> > > you'd like to delay the commit as long as possible.
> >   Ok, I get it. Thanks for explanation. The problem with more writing
> > threads bites us also for ordinary SATA drives (the IO pattern and thus
> > throughput gets worse and worse the more threads do writes). The plan is to
> > let only flusher thread do the IO and throttled thread in
> > balance_dirty_pages just waits for flusher thread to do the work. There
> > were even patches for this floating around but I'm not sure what's happened
> > to them. So that part of the problem should be easy to solve.
> >   Another part is about sending commits - if we have just one thread doing
> > flushing, we have no problems with excessive commits for one inode. You're
> > right that we may want to avoid sending commits for background writeback
> > but until we send the commit, pages are just accumulating in the unstable
> > state, aren't they? So we might want to periodically send the commit for
> > the inode anyway to get rid of those pages. So from this point of view,
> > sending commit after each writepages call does not seem like a so bad idea
> > - although it might be more appropriate to send it some time after the
> > writepages call when we are not close to dirty limit so that server has
> > more time to do more natural "unforced" writeback...
> 
> When to send the commit is a complex question to answer.  If you delay
> it long enough, the server's flusher threads will have already done most
> of the work for you, so commits can be cheap, but you don't have access
> to the necessary information to figure this out.  You can't delay it too
> long, though, because the unstable pages on the client will grow too
> large, creating memory pressure.  I have a second patch, which I haven't
> posted yet, that adds feedback piggy-backed on the NFS write response,
> which allows the NFS client to free pages proactively.  This greatly
> reduces the need to send commit messages, but it extends the protocol
> (in a backward-compatible manner), so it could be hard to convince
> people to accept.

There are only 2 cases when the client should send a COMMIT: 
     1. When it hits a synchronisation point (i.e. when the user calls
        f/sync(), or close(), or when the user sets/clears a file
        lock). 
     2. When memory pressure causes the VM to wants to free up those
        pages that are marked as clean but unstable.

We should never be sending COMMIT in any other situation, since that
would imply that the client somehow has better information on how to
manage dirty pages on the server than the server's own VM.

Cheers
  Trond
