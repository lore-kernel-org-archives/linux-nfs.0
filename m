Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:57877 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbZLVM0P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Dec 2009 07:26:15 -0500
Date: Tue, 22 Dec 2009 13:25:57 +0100
From: Jan Kara <jack@suse.cz>
To: Steve Rago <sar@nec-labs.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>,
        Peter Zijlstra <peterz@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "jens.axboe" <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS workloads
Message-ID: <20091222122557.GA604@atrey.karlin.mff.cuni.cz>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1261232747.1947.194.camel@serenity>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Hi,

> On Sat, 2009-12-19 at 20:20 +0800, Wu Fengguang wrote:
> > Hi Steve,
> > 
> > // I should really read the NFS code, but maybe you can help us better
> > // understand the problem :)
> > 
> > On Thu, Dec 17, 2009 at 04:17:57PM +0800, Peter Zijlstra wrote:
> > > On Wed, 2009-12-16 at 21:03 -0500, Steve Rago wrote:
> > > > Eager Writeback for NFS Clients
> > > > -------------------------------
> > > > Prevent applications that write large sequential streams of data (like backup, for example)
> > > > from entering into a memory pressure state, which degrades performance by falling back to
> > > > synchronous operations (both synchronous writes and additional commits).
> > 
> > What exactly is the "memory pressure state" condition?  What's the
> > code to do the "synchronous writes and additional commits" and maybe
> > how they are triggered?
> 
> Memory pressure occurs when most of the client pages have been dirtied
> by an application (think backup server writing multi-gigabyte files that
> exceed the size of main memory).  The system works harder to be able to
> free dirty pages so that they can be reused.  For a local file system,
> this means writing the pages to disk.  For NFS, however, the writes
> leave the pages in an "unstable" state until the server responds to a
> commit request.  Generally speaking, commit processing is far more
> expensive than write processing on the server; both are done with the
> inode locked, but since the commit takes so long, all writes are
> blocked, which stalls the pipeline.
  I'm not sure I understand the problem you are trying to solve. So we
generate dirty pages on an NFS filesystem. At some point we reach the
dirty_threshold so writing process is throttled and forced to do some
writes. For NFS it takes a longer time before we can really free the
pages because sever has to acknowledge the write (BTW e.g. for optical
media like DVD-RW it also takes a long time to really write the data).
  Now the problem you are trying to solve is that the system basically
gets out of free memory (so that it has to start doing synchronous
writeback from the allocator) because the writer manages to dirty
remaining free memory before the submitted writes are acknowledged from
the server? If that is so, then it might make sence to introduce also
per-bdi equivalent of dirty_background_ratio so that we can start
background writeback of dirty data at different times for different
backing devices - that would make sence to me in general, not only
for NFS.
  Another complementary piece to my above proposal would be something
like Fenguang's patches that actually don't let the process dirty too
much memory by throttling it in balance_dirty_pages until number of
unstable pages gets lower.

> > > > This is accomplished by preventing the client application from
> > > > dirtying pages faster than they can be written to the server:
> > > > clients write pages eagerly instead of lazily.
> > 
> > We already have the balance_dirty_pages() based global throttling.
> > So what makes the performance difference in your proposed "per-inode" throttling?
> > balance_dirty_pages() does have much larger threshold than yours. 
> 
> I originally spent several months playing with the balance_dirty_pages
> algorithm.  The main drawback is that it affects more than the inodes
> that the caller is writing and that the control of what to do is too
  Can you be more specific here please?

> coarse.  My final changes (which worked well for 1Gb connections) were
> more heuristic than the changes in the patch -- I basically had to come
> up with alternate ways to write pages without generating commits on
> inodes.  Doing this was distasteful, as I was adjusting generic system
> behavior for an NFS-only problem.  Then a colleague found Peter
> Staubach's patch, which worked just as well in less code, and isolated
> the change to the NFS component, which is where it belongs.
  As I said above, the problem of slow writes happens also in other
cases. What's specific to NFS is that pages aren't in writeback state
for long but they instead stay in unstable state. But
balance_dirty_pages should handle that and if it does not, it should be
fixed.

> > > > The eager writeback is controlled by a sysctl: fs.nfs.nfs_max_woutstanding set to 0 disables
> > > > the feature.  Otherwise it contains the maximum number of outstanding NFS writes that can be
> > > > in flight for a given file.  This is used to block the application from dirtying more pages
> > > > until the writes are complete.
> > 
> > What if we do heuristic write-behind for sequential NFS writes?
> 
> Part of the patch does implement a heuristic write-behind.  See where
> nfs_wb_eager() is called.
  I believe that if we had per-bdi dirty_background_ratio and set it low
for NFS's bdi, then the write-behind logic would not be needed
(essentially the flusher thread should submit the writes to the server
early).

								Honza
-- 
Jan Kara <jack@suse.cz>
SuSE CR Labs
