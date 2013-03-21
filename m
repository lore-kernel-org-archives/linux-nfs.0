Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:63126 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932771Ab3CUOcf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 10:32:35 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Benny Halevy <bhalevy@tonian.com>, Boaz Harrosh <bharrosh@panasas.com>,
        Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH v2 1/3] NFSv4.1: Fix a race in pNFS layoutcommit
Date: Thu, 21 Mar 2013 14:32:34 +0000
Message-ID: <1363876352.3557.10.camel@leira.trondhjem.org>
References: <1363875181-7147-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363875181-7147-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-21 at 10:12 -0400, Trond Myklebust wrote:
> We need to clear the NFS_LSEG_LAYOUTCOMMIT bits atomically with the
> NFS_INO_LAYOUTCOMMIT bit, otherwise we may end up with situations
> where the two are out of sync.
> The first half of the problem is to ensure that pnfs_layoutcommit_inode
> clears the NFS_LSEG_LAYOUTCOMMIT bit through pnfs_list_write_lseg.
> We still need to keep the reference to those segments until the RPC call
> is finished, so in order to make it clear _where_ those references come
> from, we add a helper pnfs_list_write_lseg_done() that cleans up after
> pnfs_list_write_lseg.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Acked-by: Benny Halevy <bhalevy@tonian.com>
> Cc: stable@vger.kernel.org
> ---
>  fs/nfs/nfs4proc.c | 14 --------------
>  fs/nfs/pnfs.c     | 19 ++++++++++++++++++-
>  2 files changed, 18 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index b2671cb..6ccdd4f 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6416,22 +6416,8 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
>  static void nfs4_layoutcommit_release(void *calldata)
>  {
>  	struct nfs4_layoutcommit_data *data = calldata;
> -	struct pnfs_layout_segment *lseg, *tmp;
> -	unsigned long *bitlock = &NFS_I(data->args.inode)->flags;
>  
>  	pnfs_cleanup_layoutcommit(data);
> -	/* Matched by references in pnfs_set_layoutcommit */
> -	list_for_each_entry_safe(lseg, tmp, &data->lseg_list, pls_lc_list) {
> -		list_del_init(&lseg->pls_lc_list);
> -		if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT,
> -				       &lseg->pls_flags))
> -			pnfs_put_lseg(lseg);
> -	}
> -
> -	clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
> -	smp_mb__after_clear_bit();
> -	wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
> -
>  	put_rpccred(data->cred);
>  	kfree(data);
>  }
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 48ac5aa..c6bbb53 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1746,11 +1746,27 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
>  
>  	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
>  		if (lseg->pls_range.iomode == IOMODE_RW &&
> -		    test_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
> +		    test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
>  			list_add(&lseg->pls_lc_list, listp);
>  	}
>  }
>  
> +void pnfs_list_write_lseg_done(struct inode *inode, struct list_head *listp)

Doh! This needs to be declared static... Will fix.

> +{
> +	struct pnfs_layout_segment *lseg, *tmp;
> +	unsigned long *bitlock = &NFS_I(inode)->flags;
> +
> +	/* Matched by references in pnfs_set_layoutcommit */
> +	list_for_each_entry_safe(lseg, tmp, listp, pls_lc_list) {
> +		list_del_init(&lseg->pls_lc_list);
> +		pnfs_put_lseg(lseg);
> +	}
> +
> +	clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
> +	smp_mb__after_clear_bit();
> +	wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
> +}
> +
>  void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg)
>  {
>  	pnfs_layout_io_set_failed(lseg->pls_layout, lseg->pls_range.iomode);
> @@ -1795,6 +1811,7 @@ void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
>  
>  	if (nfss->pnfs_curr_ld->cleanup_layoutcommit)
>  		nfss->pnfs_curr_ld->cleanup_layoutcommit(data);
> +	pnfs_list_write_lseg_done(data->args.inode, &data->lseg_list);
>  }
>  
>  /*


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
