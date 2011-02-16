Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33144 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754525Ab1BPUqs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 15:46:48 -0500
Date: Wed, 16 Feb 2011 15:50:42 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
Message-ID: <20110216155042.383b420f@corrin.poochiereds.net>
In-Reply-To: <20110217072618.26a6c02a@notabene.brown>
References: <20110216171555.6642c630@notabene.brown>
	<20110216081150.49b50ffe@tlielax.poochiereds.net>
	<20110217072618.26a6c02a@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Feb 2011 07:26:18 +1100
NeilBrown <neilb@suse.de> wrote:

> On Wed, 16 Feb 2011 08:11:50 -0500 Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Wed, 16 Feb 2011 17:15:55 +1100
> > NeilBrown <neilb@suse.de> wrote:
> > 
> > > 
> > > Hi Trond,
> > >  I wonder if I might get your help/advice on an issue with NFS.
> > > 
> > >  It seems that NFS_DATA_SYNC is hardly used at all currently.  It is used for
> > >  O_DIRECT writes and for writes 'for_reclaim', and for handling some error
> > >  conditions, but that is about it.
> > > 
> > >  This appears to be a regression.
> > > 
> > >  Back in 2005, commit ab0a3dbedc5 in 2.6.13 says:
> > > 
> > >     [PATCH] NFS: Write optimization for short files and small O_SYNC writes.
> > >     
> > >      Use stable writes if we can see that we are only going to put a single
> > >      write on the wire.
> > > 
> > >  which seems like a sensible optimisation, and we have a customer which
> > >  values it.  Very roughly, they have an NFS server which optimises 'unstable'
> > >  writes for throughput and 'stable' writes for latency - these seems like a
> > >  reasonable approach.
> > >  With a 2.6.16 kernel an application which generates many small sync writes
> > >  gets adequate performance.  In 2.6.32 they see unstable writes followed by
> > >  commits, which cannot be (or at least aren't) optimised as well.
> > > 
> > >  It seems this was changed by commit c63c7b0513953
> > > 
> > >     NFS: Fix a race when doing NFS write coalescing
> > >     
> > >  in 2.6.22.
> > > 
> > >  Is it possible/easy/desirable to get this behaviour back.  i.e. to use
> > >  NFS_DATA_SYNC at least on sub-page writes triggered by a write to an
> > >  O_SYNC file.
> > > 
> > >  My (possibly naive) attempt is as follows.  It appears to work as I expect
> > >  (though it still uses SYNC for 1-page writes) but I'm not confident that it
> > >  is "right".
> > > 
> > > Thanks,
> > > 
> > > NeilBrown
> > > 
> > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > > index 10d648e..392bfa8 100644
> > > --- a/fs/nfs/write.c
> > > +++ b/fs/nfs/write.c
> > > @@ -178,6 +178,9 @@ static int wb_priority(struct writeback_control *wbc)
> > >  		return FLUSH_HIGHPRI | FLUSH_STABLE;
> > >  	if (wbc->for_kupdate || wbc->for_background)
> > >  		return FLUSH_LOWPRI;
> > > +	if (wbc->sync_mode == WB_SYNC_ALL &&
> > > +	    (wbc->range_end - wbc->range_start) < PAGE_SIZE)
> > > +		return FLUSH_STABLE;
> > >  	return 0;
> > >  }
> > >  
> > 
> > I'm not so sure about this change. wb_priority is called from
> > nfs_wb_page. The comments there say:
> > 
> > /*
> >  * Write back all requests on one page - we do this before reading it.
> >  */
> > 
> > ...do we really need those writes to be NFS_FILE_SYNC?
> 
> Thanks for taking a look.
> wb_priority is called from several places - yes.
> 
> In the nfs_wb_page case, I think we *do* want NFS_FILE_SYNC.
> nfs_wb_page calls nfs_writepage_locked and then nfs_commit_inode which calls
> nfs_scan_commit to send a COMMIT request for the page (if the write wasn't
> stable).
> 
> By using NFS_FILE_SYNC we can avoid that COMMIT, and lose nothing (that I can
> see).
> 

Good point.

> > 
> > I think that the difficulty here is determining when we really are
> > going to just be doing a single write. In that case, then clearly a
> > FILE_SYNC write is better than an unstable + COMMIT.
> > 
> > This is very workload dependent though. It's hard to know beforehand
> > whether a page that we intend to write will be redirtied soon
> > afterward. If it is, then FILE_SYNC writes may be worse than letting
> > the server cache the writes until a COMMIT comes in.
> > 
> 
> The hope is that sync_mode == WB_SYNC_ALL combined with a short 'range' are
> sufficient.
> 
> In particular, WB_SYNC_ALL essentially says that we want this page out to
> storage *now* so a 'flush' of some sort is likely to following.
> 

Also a good point.

I guess my main worry is that, at least in the Linux NFS server case,
these get translated to O_SYNC writes which can be very slow. If we
know though that we're not likely to have follow-on writes that could
be batched up then this is probably fine.

I guess I just don't have a good feel for how often (if ever) we do
multiple writes to the same file with different wbc ranges without an
intervening commit. If that happens and we end up doing FILE_SYNC
writes rather than unstable ones, then this change is probably not a
good one.

Do you have any idea as to why unstable writes get worse performance
for this customer? I know that base 2.6.32 did a *lot* more COMMITs
than were really necessary. Perhaps they are seeing the effect of that?
Or have they also tested something more recent and seen bad
performance?

> 
> BTW, I'm wondering if the length of 'range' that we test should be related to
> 'wsize' rather than PAGE_SIZE.  Any thoughts on that?
> 

Yeah, that seems like a more meaningful test than page size.

-- 
Jeff Layton <jlayton@redhat.com>
