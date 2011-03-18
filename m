Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55406 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755611Ab1CRBE1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 21:04:27 -0400
Date: Fri, 18 Mar 2011 12:04:17 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
Message-ID: <20110318120417.435551da@notabene.brown>
In-Reply-To: <1300405987.4621.10.camel@lade.trondhjem.org>
References: <20110216171555.6642c630@notabene.brown>
	<1300405987.4621.10.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Mar 2011 19:53:07 -0400 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> On Wed, 2011-02-16 at 17:15 +1100, NeilBrown wrote:
> > Hi Trond,
> >  I wonder if I might get your help/advice on an issue with NFS.
> > 
> >  It seems that NFS_DATA_SYNC is hardly used at all currently.  It is used for
> >  O_DIRECT writes and for writes 'for_reclaim', and for handling some error
> >  conditions, but that is about it.
> > 
> >  This appears to be a regression.
> > 
> >  Back in 2005, commit ab0a3dbedc5 in 2.6.13 says:
> > 
> >     [PATCH] NFS: Write optimization for short files and small O_SYNC writes.
> >     
> >      Use stable writes if we can see that we are only going to put a single
> >      write on the wire.
> > 
> >  which seems like a sensible optimisation, and we have a customer which
> >  values it.  Very roughly, they have an NFS server which optimises 'unstable'
> >  writes for throughput and 'stable' writes for latency - these seems like a
> >  reasonable approach.
> >  With a 2.6.16 kernel an application which generates many small sync writes
> >  gets adequate performance.  In 2.6.32 they see unstable writes followed by
> >  commits, which cannot be (or at least aren't) optimised as well.
> > 
> >  It seems this was changed by commit c63c7b0513953
> > 
> >     NFS: Fix a race when doing NFS write coalescing
> >     
> >  in 2.6.22.
> > 
> >  Is it possible/easy/desirable to get this behaviour back.  i.e. to use
> >  NFS_DATA_SYNC at least on sub-page writes triggered by a write to an
> >  O_SYNC file.
> > 
> >  My (possibly naive) attempt is as follows.  It appears to work as I expect
> >  (though it still uses SYNC for 1-page writes) but I'm not confident that it
> >  is "right".
> > 
> > Thanks,
> > 
> > NeilBrown
> > 
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 10d648e..392bfa8 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -178,6 +178,9 @@ static int wb_priority(struct writeback_control *wbc)
> >  		return FLUSH_HIGHPRI | FLUSH_STABLE;
> >  	if (wbc->for_kupdate || wbc->for_background)
> >  		return FLUSH_LOWPRI;
> > +	if (wbc->sync_mode == WB_SYNC_ALL &&
> > +	    (wbc->range_end - wbc->range_start) < PAGE_SIZE)
> > +		return FLUSH_STABLE;
> >  	return 0;
> >  }
> 
> Would it ever be wrong to set the FILE_SYNC flag for the very last rpc
> call in a writeback series? I'm thinking that we might want to set
> FLUSH_STABLE before the call to pageio_complete in
> nfs_writepage_locked() and nfs_writepages().

Interesting idea.

Am I correct in assuming you only mean if wbc->sync_mode == WB_SYNC_ALL.
It wouldn't seem to make any sense for WB_SYNC_NONE.

In that case that last RPC would be immediately followed by a COMMIT. So it
could be reasonable to make it NFS_DATA_SYNC.

However the server would be seeing something a bit odd - a sequence of
unstable writes, then a stable write, then a commit.  This could cause it to
'sync' things in the 'wrong' order which might be less than optimal.  It
would depend a lot on the particular server and filesystem of course, but it
seems to be mis-communicating.  So I think I would avoid this approach
(assuming I understand it correctly).

> 
> The only thing that makes me uncomfortable with that idea is the
> possible repercussions for pNFS.
> 

Cannot comment there - I don't have a deep enough understanding of the issues
with pNFS.

Thanks,
NeilBrown
