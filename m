Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4882 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755787Ab1CQXxX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 19:53:23 -0400
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110216171555.6642c630@notabene.brown>
References: <20110216171555.6642c630@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Mar 2011 19:53:07 -0400
Message-ID: <1300405987.4621.10.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-02-16 at 17:15 +1100, NeilBrown wrote:
> Hi Trond,
>  I wonder if I might get your help/advice on an issue with NFS.
> 
>  It seems that NFS_DATA_SYNC is hardly used at all currently.  It is used for
>  O_DIRECT writes and for writes 'for_reclaim', and for handling some error
>  conditions, but that is about it.
> 
>  This appears to be a regression.
> 
>  Back in 2005, commit ab0a3dbedc5 in 2.6.13 says:
> 
>     [PATCH] NFS: Write optimization for short files and small O_SYNC writes.
>     
>      Use stable writes if we can see that we are only going to put a single
>      write on the wire.
> 
>  which seems like a sensible optimisation, and we have a customer which
>  values it.  Very roughly, they have an NFS server which optimises 'unstable'
>  writes for throughput and 'stable' writes for latency - these seems like a
>  reasonable approach.
>  With a 2.6.16 kernel an application which generates many small sync writes
>  gets adequate performance.  In 2.6.32 they see unstable writes followed by
>  commits, which cannot be (or at least aren't) optimised as well.
> 
>  It seems this was changed by commit c63c7b0513953
> 
>     NFS: Fix a race when doing NFS write coalescing
>     
>  in 2.6.22.
> 
>  Is it possible/easy/desirable to get this behaviour back.  i.e. to use
>  NFS_DATA_SYNC at least on sub-page writes triggered by a write to an
>  O_SYNC file.
> 
>  My (possibly naive) attempt is as follows.  It appears to work as I expect
>  (though it still uses SYNC for 1-page writes) but I'm not confident that it
>  is "right".
> 
> Thanks,
> 
> NeilBrown
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 10d648e..392bfa8 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -178,6 +178,9 @@ static int wb_priority(struct writeback_control *wbc)
>  		return FLUSH_HIGHPRI | FLUSH_STABLE;
>  	if (wbc->for_kupdate || wbc->for_background)
>  		return FLUSH_LOWPRI;
> +	if (wbc->sync_mode == WB_SYNC_ALL &&
> +	    (wbc->range_end - wbc->range_start) < PAGE_SIZE)
> +		return FLUSH_STABLE;
>  	return 0;
>  }

Would it ever be wrong to set the FILE_SYNC flag for the very last rpc
call in a writeback series? I'm thinking that we might want to set
FLUSH_STABLE before the call to pageio_complete in
nfs_writepage_locked() and nfs_writepages().

The only thing that makes me uncomfortable with that idea is the
possible repercussions for pNFS.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

