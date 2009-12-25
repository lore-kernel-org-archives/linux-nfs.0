From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Fri, 25 Dec 2009 13:56:17 +0800
Message-ID: <20091225055617.GA8595@localhost>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost> <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz> <1261595574.6775.2.camel@localhost> <20091224025228.GA12477@localhost> <1261656281.3596.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26005 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947AbZLYF4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Dec 2009 00:56:21 -0500
In-Reply-To: <1261656281.3596.1.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 24, 2009 at 08:04:41PM +0800, Trond Myklebust wrote:
> On Thu, 2009-12-24 at 10:52 +0800, Wu Fengguang wrote: 
> > Trond,
> > 
> > On Thu, Dec 24, 2009 at 03:12:54AM +0800, Trond Myklebust wrote:
> > > On Wed, 2009-12-23 at 19:05 +0100, Jan Kara wrote: 
> > > > On Wed 23-12-09 15:21:47, Trond Myklebust wrote:
> > > > > @@ -474,6 +482,18 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
> > > > >  	}
> > > > >  
> > > > >  	spin_lock(&inode_lock);
> > > > > +	/*
> > > > > +	 * Special state for cleaning NFS unstable pages
> > > > > +	 */
> > > > > +	if (inode->i_state & I_UNSTABLE_PAGES) {
> > > > > +		int err;
> > > > > +		inode->i_state &= ~I_UNSTABLE_PAGES;
> > > > > +		spin_unlock(&inode_lock);
> > > > > +		err = commit_unstable_pages(inode, wait);
> > > > > +		if (ret == 0)
> > > > > +			ret = err;
> > > > > +		spin_lock(&inode_lock);
> > > > > +	}
> > > >   I don't quite understand this chunk: We've called writeback_single_inode
> > > > because it had some dirty pages. Thus it has I_DIRTY_DATASYNC set and a few
> > > > lines above your chunk, we've called nfs_write_inode which sent commit to
> > > > the server. Now here you sometimes send the commit again? What's the
> > > > purpose?
> > > 
> > > We no longer set I_DIRTY_DATASYNC. We only set I_DIRTY_PAGES (and later
> > > I_UNSTABLE_PAGES).
> > > 
> > > The point is that we now do the commit only _after_ we've sent all the
> > > dirty pages, and waited for writeback to complete, whereas previously we
> > > did it in the wrong order.
> > 
> > Sorry I still don't get it. The timing used to be:
> > 
> > write 4MB   ==> WRITE block 0 (ie. first 512KB)
> >                 WRITE block 1
> >                 WRITE block 2
> >                 WRITE block 3         ack from server for WRITE block 0 => mark 0 as unstable (inode marked need-commit)
> >                 WRITE block 4         ack from server for WRITE block 1 => mark 1 as unstable
> >                 WRITE block 5         ack from server for WRITE block 2 => mark 2 as unstable
> >                 WRITE block 6         ack from server for WRITE block 3 => mark 3 as unstable
> >                 WRITE block 7         ack from server for WRITE block 4 => mark 4 as unstable
> >                                       ack from server for WRITE block 5 => mark 5 as unstable
> > write_inode ==> COMMIT blocks 0-5
> >                                       ack from server for WRITE block 6 => mark 6 as unstable (inode marked need-commit)
> >                                       ack from server for WRITE block 7 => mark 7 as unstable 
> > 
> >                                       ack from server for COMMIT blocks 0-5 => mark 0-5 as clean
> > 
> > write_inode ==> COMMIT blocks 6-7
> > 
> >                                       ack from server for COMMIT blocks 6-7 => mark 6-7 as clean
> > 
> > Note that the first COMMIT is submitted before receiving all ACKs for
> > the previous writes, hence the second COMMIT is necessary. It seems
> > that your patch does not improve the timing at all.
> 
> That would indicate that we're cycling through writeback_single_inode()
> more than once. Why?

Yes. The above sequence can happen for a 4MB sized dirty file.
The first COMMIT is done by L547, while the second COMMIT will be
scheduled either by __mark_inode_dirty(), or scheduled by L583
(depending on the time ACKs for L543 but missed L547 arrives:
if an ACK missed L578, the inode will be queued into b_dirty list,
but if any ACK arrives between L547 and L578, the inode will enter
b_more_io_wait, which is a to-be-introduced new dirty list). 

         537         dirty = inode->i_state & I_DIRTY;
         538         inode->i_state |= I_SYNC;
         539         inode->i_state &= ~I_DIRTY;
         540 
         541         spin_unlock(&inode_lock);
         542 
==>      543         ret = do_writepages(mapping, wbc);
         544 
         545         /* Don't write the inode if only I_DIRTY_PAGES was set */
         546         if (dirty & (I_DIRTY_SYNC | I_DIRTY_DATASYNC)) {
==>      547                 int err = write_inode(inode, wait);
         548                 if (ret == 0)
         549                         ret = err;
         550         }
         551 
         552         if (wait) {
         553                 int err = filemap_fdatawait(mapping);
         554                 if (ret == 0)
         555                         ret = err;
         556         }
         557 
         558         spin_lock(&inode_lock);
         559         inode->i_state &= ~I_SYNC;
         560         if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
         561                 if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
         562                         /*
         563                          * We didn't write back all the pages.  nfs_writepages()
         564                          * sometimes bales out without doing anything.
         565                          */
         566                         inode->i_state |= I_DIRTY_PAGES;
         567                         if (wbc->nr_to_write <= 0) {
         568                                 /*
         569                                  * slice used up: queue for next turn
         570                                  */
         571                                 requeue_io(inode);
         572                         } else {
         573                                 /*
         574                                  * somehow blocked: retry later
         575                                  */
         576                                 requeue_io_wait(inode);
         577                         }
==>      578                 } else if (inode->i_state & I_DIRTY) {
         579                         /*
         580                          * At least XFS will redirty the inode during the
         581                          * writeback (delalloc) and on io completion (isize).
         582                          */
==>      583                         requeue_io_wait(inode);

Thanks,
Fengguang
