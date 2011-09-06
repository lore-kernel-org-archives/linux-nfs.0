Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38238 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754807Ab1IFTaZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2011 15:30:25 -0400
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@gmail.com>
Cc: peng_tao@emc.com, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Date: Tue, 06 Sep 2011 15:29:42 -0400
In-Reply-To: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1315337382.16274.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2011-08-28 at 10:22 +0400, Vitaliy Gusev wrote: 
> pnfs_layout_segment can be already under handling LAYOUTCOMMIT,
> so adding list twice causes hang:
> 
>    BUG: soft lockup - CPU#0 stuck for 22s! [kworker/0:0:4]
>    Call Trace:
> 
>      nfs4_layoutcommit_release+0x5a/0x9c [nfs]
>      rpc_release_calldata+0x17/0x19 [sunrpc]
>      rpc_free_task+0x5e/0x66 [sunrpc]
>      __rpc_execute+0x29e/0x2ad [sunrpc]
>      rpc_async_schedule+0x15/0x17 [sunrpc]
>      process_one_work+0x213/0x3ba
>      process_one_work+0x142/0x3ba
>      __rpc_execute+0x2ad/0x2ad [sunrpc]
>      worker_thread+0xfd/0x181
> 
> Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
> ---
>  fs/nfs/pnfs.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index e550e88..1465f44 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1376,7 +1376,8 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
>  
>  	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
>  		if (lseg->pls_range.iomode == IOMODE_RW &&
> -		    test_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
> +		    test_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags) &&
> +		    list_empty(&lseg->pls_lc_list))
>  			list_add(&lseg->pls_lc_list, listp);
>  	}
>  }

If the lseg is already part of one layoutcommit, but we're sending a
second one for the same range (presumably because we wrote more data in
the same region), then the above causes the lseg to be excluded.

I agree that the current code causes list corruption, but before
applying something like the above patch, I'd like to understand why it
is correct.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

