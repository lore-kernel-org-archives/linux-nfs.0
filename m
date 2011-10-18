Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47602 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596Ab1JRRdC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 13:33:02 -0400
Subject: Re: nfs4: serialize layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>, Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 18 Oct 2011 10:32:58 -0700
In-Reply-To: <20111018170123.GB2876@umich.edu>
References: <20111018170123.GB2876@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1318959178.3213.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-10-18 at 13:01 -0400, Jim Rees wrote: 
> I believe this one is still needed, and is missing from your tree.  I can't
> remember the status, there was a lot of discussion, but I think this was the
> final result.  Bergwolf?  Others?
> 
> commit 54cf1a33598abbe6431b573563116d8ecc8343b1
> Author: Peng Tao <bergwolf@gmail.com>
> Date:   Mon Sep 12 20:47:21 2011 -0700
> 
>     nfs4: serialize layoutcommit
>     
>     Current pnfs_layoutcommit_inode can not handle parallel layoutcommit.
>     And as Trond suggested , there is no need for client to optimize for
>     parallel layoutcommit. So add NFS_INO_LAYOUTCOMMITTING flag to mark
>     inflight layoutcommit and serialize lalyoutcommit with it. Also call
>     mark_inode_dirty_sync if pnfs_layoutcommit_inode fails to issue
>     layoutcommit, so that layoutcommit can be retried later.
>     It also fixes the pls_lc_list corruption that Vitaliy found.
>     
>     Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 4700fae..a7ce210 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5970,6 +5970,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>  {
>  	struct nfs4_layoutcommit_data *data = calldata;
>  	struct pnfs_layout_segment *lseg, *tmp;
> +	unsigned long *bitlock = &NFS_I(data->args.inode)->flags;
>  
>  	pnfs_cleanup_layoutcommit(data);
>  	/* Matched by references in pnfs_set_layoutcommit */
> @@ -5979,6 +5980,11 @@ static void nfs4_layoutcommit_release(void *calldata)
>  				       &lseg->pls_flags))
>  			put_lseg(lseg);
>  	}
> +
> +	clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
> +	smp_mb__after_clear_bit();
> +	wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
> +
>  	put_rpccred(data->cred);
>  	kfree(data);
>  }
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index e550e88..0715fda 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1443,17 +1443,30 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>  	/* Note kzalloc ensures data->res.seq_res.sr_slot == NULL */
>  	data = kzalloc(sizeof(*data), GFP_NOFS);
>  	if (!data) {
> -		mark_inode_dirty_sync(inode);
>  		status = -ENOMEM;
>  		goto out;
>  	}
>  
> +	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
> +		goto out_free;
> +	else if (test_and_set_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags)) {

We don't need an 'else' after a 'goto out' :-)

> +		if (!sync) {
> +			status = -EAGAIN;
> +			goto out_free;
> +		}
> +		status = wait_on_bit_lock(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING,
> +					nfs_wait_bit_killable, TASK_KILLABLE);
> +		if (status)
> +			goto out_free;
> +	}
> +
>  	INIT_LIST_HEAD(&data->lseg_list);

Why do this before the test of NFS_INO_LAYOUTCOMMIT?

> 	spin_lock(&inode->i_lock);
>  	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
> +		clear_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags);
>  		spin_unlock(&inode->i_lock);
> -		kfree(data);
> -		goto out;
> +		wake_up_bit(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING);
> +		goto out_free;
>  	}
>  
>  	pnfs_list_write_lseg(inode, &data->lseg_list);
> @@ -1475,6 +1488,11 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>  
>  	status = nfs4_proc_layoutcommit(data, sync);
>  out:
> +	if (status)
> +		mark_inode_dirty_sync(inode);

Shouldn't we be doing this in nfs4_layoutcommit_release() too?

> 	dprintk("<-- %s status %d\n", __func__, status);
>  	return status;
> +out_free:
> +	kfree(data);
> +	goto out;
>  }
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index eaac770..c5b2b30 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -230,6 +230,7 @@ struct nfs_inode {
>  #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
>  #define NFS_INO_PNFS_COMMIT	(8)		/* use pnfs code for commit */
>  #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
> +#define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
>  
>  static inline struct nfs_inode *NFS_I(const struct inode *inode)
>  {

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

