Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f47.google.com ([74.125.82.47]:53965 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755565Ab3CULW7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 07:22:59 -0400
Received: by mail-wg0-f47.google.com with SMTP id dt14so404135wgb.14
        for <linux-nfs@vger.kernel.org>; Thu, 21 Mar 2013 04:22:57 -0700 (PDT)
Message-ID: <514AED8E.9010705@tonian.com>
Date: Thu, 21 Mar 2013 13:22:54 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>,
        Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH 1/3] NFSv4.1: Fix a race in pNFS layoutcommit
References: <1363801148-29998-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363801148-29998-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-20 19:39, Trond Myklebust wrote:
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
> Cc: Benny Halevy <bhalevy@tonian.com>

ACK

> Cc: stable@vger.kernel.org
> ---
>  fs/nfs/nfs4proc.c | 14 --------------
>  fs/nfs/pnfs.c     | 19 ++++++++++++++++++-
>  2 files changed, 18 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index dcda2fa..5122753 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6568,22 +6568,8 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
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
> index e86e35f..6f6b356 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1748,11 +1748,27 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
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

Out of curiousity, should this be done the same way in pnfs_layoutcommit_inode()
in the following block?
	spin_lock(&inode->i_lock);
	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
		clear_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags);
		spin_unlock(&inode->i_lock);
		wake_up_bit(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING);
		goto out_free;
	}

Benny

> +	wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
> +}
> +
>  void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg)
>  {
>  	pnfs_layout_io_set_failed(lseg->pls_layout, lseg->pls_range.iomode);
> @@ -1797,6 +1813,7 @@ void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
>  
>  	if (nfss->pnfs_curr_ld->cleanup_layoutcommit)
>  		nfss->pnfs_curr_ld->cleanup_layoutcommit(data);
> +	pnfs_list_write_lseg_done(data->args.inode, &data->lseg_list);
>  }
>  
>  /*
> 

