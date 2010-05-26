From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 2/8] pnfs-submit: clean locking infrastructure
Date: Wed, 26 May 2010 11:28:35 +0300
Message-ID: <4BFCDBB3.7010406@panasas.com>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com> <1274119004-30213-2-git-send-email-batsakis@netapp.com> <1274119004-30213-3-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39678 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037Ab0EZI2k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 04:28:40 -0400
Received: by fxm5 with SMTP id 5so4097642fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 01:28:38 -0700 (PDT)
In-Reply-To: <1274119004-30213-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 17, 2010, 20:56 +0300, Alexandros Batsakis <batsakis@netapp.com> wrote:
> (also minor cleanup of pnfs_free_layout())
> 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> 
> Conflicts:
> 
> 	fs/nfs/pnfs.c
> ---
>  fs/nfs/pnfs.c |   80 +++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 53 insertions(+), 27 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index b72c013..74cb998 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1,4 +1,4 @@
> -/*
> + /*

just picking nit...

Benny

>   *  linux/fs/nfs/pnfs.c
>   *
>   *  pNFS functions to call and manage layout drivers.
> @@ -60,6 +60,8 @@ static int pnfs_initialized;
>  static void pnfs_free_layout(struct pnfs_layout_type *lo,
>  			     struct nfs4_pnfs_layout_segment *range);
>  static enum pnfs_try_status pnfs_commit(struct nfs_write_data *data, int sync);
> +static inline void lock_current_layout(struct nfs_inode *nfsi);
> +static inline void unlock_current_layout(struct nfs_inode *nfsi);
>  
>  /* Locking:
>   *
> @@ -153,16 +155,17 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
>  {
>  	dprintk("%s: has_layout=%d layoutcommit_ctx=%p ctx=%p\n", __func__,
>  		has_layout(nfsi), nfsi->layout.layoutcommit_ctx, ctx);
> -	spin_lock(&nfsi->lo_lock);
> +
> +	lock_current_layout(nfsi);
>  	if (has_layout(nfsi) && !nfsi->layout.layoutcommit_ctx) {
>  		nfsi->layout.layoutcommit_ctx = get_nfs_open_context(ctx);
>  		nfsi->change_attr++;
> -		spin_unlock(&nfsi->lo_lock);
> +		unlock_current_layout(nfsi);
>  		dprintk("%s: Set layoutcommit_ctx=%p\n", __func__,
>  			nfsi->layout.layoutcommit_ctx);
>  		return;
>  	}
> -	spin_unlock(&nfsi->lo_lock);
> +	unlock_current_layout(nfsi);
>  }
>  
>  /* Update last_write_offset for layoutcommit.
> @@ -175,7 +178,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
>  {
>  	loff_t end_pos;
>  
> -	spin_lock(&nfsi->lo_lock);
> +	lock_current_layout(nfsi);
>  	if (offset < nfsi->layout.pnfs_write_begin_pos)
>  		nfsi->layout.pnfs_write_begin_pos = offset;
>  	end_pos = offset + extent - 1; /* I'm being inclusive */
> @@ -187,7 +190,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
>  		(unsigned long) offset ,
>  		(unsigned long) nfsi->layout.pnfs_write_begin_pos,
>  		(unsigned long) nfsi->layout.pnfs_write_end_pos);
> -	spin_unlock(&nfsi->lo_lock);
> +	unlock_current_layout(nfsi);
>  }
>  
>  /* Unitialize a mountpoint in a layout driver */
> @@ -296,12 +299,27 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
>   * pNFS client layout cache
>   */
>  #if defined(CONFIG_SMP)
> +#define BUG_ON_LOCKED_LO(lo) \
> +	BUG_ON(spin_is_locked(&PNFS_NFS_INODE(lo)->lo_lock))
>  #define BUG_ON_UNLOCKED_LO(lo) \
>  	BUG_ON(!spin_is_locked(&PNFS_NFS_INODE(lo)->lo_lock))
>  #else /* CONFIG_SMP */
> +#define BUG_ON_LOCKED_LO(lo) do {} while (0)
>  #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
>  #endif /* CONFIG_SMP */
>  
> +static inline void lock_current_layout(struct nfs_inode *nfsi)
> +{
> +	BUG_ON_LOCKED_LO((&nfsi->layout));
> +	spin_lock(&nfsi->lo_lock);
> +}
> +
> +static inline void unlock_current_layout(struct nfs_inode *nfsi)
> +{
> +	BUG_ON_UNLOCKED_LO((&nfsi->layout));
> +	spin_unlock(&nfsi->lo_lock);
> +}
> +
>  /*
>   * get and lock nfsi->layout
>   */
> @@ -310,10 +328,10 @@ get_lock_current_layout(struct nfs_inode *nfsi)
>  {
>  	struct pnfs_layout_type *lo;
>  
> +	lock_current_layout(nfsi);
>  	lo = &nfsi->layout;
> -	spin_lock(&nfsi->lo_lock);
>  	if (!lo->ld_data) {
> -		spin_unlock(&nfsi->lo_lock);
> +		unlock_current_layout(nfsi);
>  		return NULL;
>  	}
>  
> @@ -333,7 +351,12 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
>  	BUG_ON_UNLOCKED_LO(lo);
>  	BUG_ON(lo->refcount <= 0);
>  
> -	if (--lo->refcount == 0 && list_empty(&lo->segs)) {
> +	lo->refcount--;
> +
> +	if (lo->refcount > 0)
> +		goto out;
> +
> +	if (list_empty(&lo->segs)) {
>  		struct layoutdriver_io_operations *io_ops =
>  			PNFS_LD_IO_OPS(lo);
>  
> @@ -347,7 +370,8 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
>  		list_del_init(&nfsi->lo_inodes);
>  		spin_unlock(&clp->cl_lock);
>  	}
> -	spin_unlock(&nfsi->lo_lock);
> +out:
> +	unlock_current_layout(nfsi);
>  }
>  
>  void
> @@ -356,7 +380,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo, atomic_t *count,
>  {
>  	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
>  
> -	spin_lock(&nfsi->lo_lock);
> +	lock_current_layout(nfsi);
>  	if (range)
>  		pnfs_free_layout(lo, range);
>  	atomic_dec(count);
> @@ -375,6 +399,8 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
>  	};
>  
>  	lo = get_lock_current_layout(nfsi);
> +	if (!lo)
> +		return;
>  	pnfs_free_layout(lo, &range);
>  	put_unlock_current_layout(lo);
>  }
> @@ -652,7 +678,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>  	struct pnfs_layout_segment *lseg;
>  	bool ret = false;
>  
> -	spin_lock(&nfsi->lo_lock);
> +	lock_current_layout(nfsi);
>  	list_for_each_entry (lseg, &nfsi->layout.segs, fi_list) {
>  		if (!should_free_lseg(lseg, range))
>  			continue;
> @@ -666,7 +692,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>  	}
>  	if (atomic_read(&nfsi->layout.lgetcount))
>  		ret = true;
> -	spin_unlock(&nfsi->lo_lock);
> +	unlock_current_layout(nfsi);
>  
>  	dprintk("%s:Return %d\n", __func__, ret);
>  	return ret;
> @@ -756,7 +782,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
>  		/* unlock w/o put rebalanced by eventual call to
>  		 * pnfs_layout_release
>  		 */
> -		spin_unlock(&nfsi->lo_lock);
> +		unlock_current_layout(nfsi);
>  
>  		if (pnfs_return_layout_barrier(nfsi, &arg)) {
>  			dprintk("%s: waiting\n", __func__);
> @@ -887,7 +913,7 @@ static int pnfs_wait_schedule(void *word)
>   *
>   * Note: If successful, nfsi->lo_lock is taken and the caller
>   * must put and unlock current_layout by using put_unlock_current_layout()
> - * when the returned layout is released.
> + * directly or pnfs_layout_release() when the returned layout is released.
>   */
>  static struct pnfs_layout_type *
>  get_lock_alloc_layout(struct inode *ino)
> @@ -922,7 +948,7 @@ get_lock_alloc_layout(struct inode *ino)
>  			struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
>  
>  			/* must grab the layout lock before the client lock */
> -			spin_lock(&nfsi->lo_lock);
> +			lock_current_layout(nfsi);
>  
>  			spin_lock(&clp->cl_lock);
>  			if (list_empty(&nfsi->lo_inodes))
> @@ -1038,10 +1064,10 @@ void drain_layoutreturns(struct pnfs_layout_type *lo)
>  	while (atomic_read(&lo->lretcount)) {
>  		struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
>  
> -		spin_unlock(&nfsi->lo_lock);
> +		unlock_current_layout(nfsi);
>  		dprintk("%s: waiting\n", __func__);
>  		wait_event(nfsi->lo_waitq, (atomic_read(&lo->lretcount) == 0));
> -		spin_lock(&nfsi->lo_lock);
> +		lock_current_layout(nfsi);
>  	}
>  }
>  
> @@ -1080,13 +1106,13 @@ pnfs_update_layout(struct inode *ino,
>  	/* Check to see if the layout for the given range already exists */
>  	lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
>  	if (lseg && !lseg->valid) {
> -		spin_unlock(&nfsi->lo_lock);
> +		unlock_current_layout(nfsi);
>  		if (take_ref)
>  			put_lseg(lseg);
>  		for (;;) {
>  			prepare_to_wait(&nfsi->lo_waitq, &__wait,
>  					TASK_KILLABLE);
> -			spin_lock(&nfsi->lo_lock);
> +			lock_current_layout(nfsi);
>  			lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
>  			if (!lseg || lseg->valid)
>  				break;
> @@ -1099,7 +1125,7 @@ pnfs_update_layout(struct inode *ino,
>  				result = -ERESTARTSYS;
>  				break;
>  			}
> -			spin_unlock(&nfsi->lo_lock);
> +			unlock_current_layout(nfsi);
>  			schedule();
>  		}
>  		finish_wait(&nfsi->lo_waitq, &__wait);
> @@ -1136,7 +1162,7 @@ pnfs_update_layout(struct inode *ino,
>  	/* Matching dec is done in .rpc_release (on non-error paths) */
>  	atomic_inc(&lo->lgetcount);
>  	/* Lose lock, but not reference, match this with pnfs_layout_release */
> -	spin_unlock(&nfsi->lo_lock);
> +	unlock_current_layout(nfsi);
>  
>  	result = get_layout(ino, ctx, &arg, lsegpp, lo);
>  out:
> @@ -1286,7 +1312,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
>  		*lgp->lsegpp = lseg;
>  	}
>  
> -	spin_lock(&nfsi->lo_lock);
> +	lock_current_layout(nfsi);
>  	pnfs_insert_layout(lo, lseg);
>  
>  	if (res->return_on_close) {
> @@ -1297,7 +1323,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
>  
>  	/* Done processing layoutget. Set the layout stateid */
>  	pnfs_set_layout_stateid(lo, &res->stateid);
> -	spin_unlock(&nfsi->lo_lock);
> +	unlock_current_layout(nfsi);
>  out:
>  	return status;
>  }
> @@ -2212,7 +2238,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>  	if (!data)
>  		return -ENOMEM;
>  
> -	spin_lock(&nfsi->lo_lock);
> +	lock_current_layout(nfsi);
>  	if (!nfsi->layout.layoutcommit_ctx)
>  		goto out_unlock;
>  
> @@ -2233,7 +2259,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>  	nfsi->layout.layoutcommit_ctx = NULL;
>  
>  	/* release lock on pnfs layoutcommit attrs */
> -	spin_unlock(&nfsi->lo_lock);
> +	unlock_current_layout(nfsi);
>  
>  	data->is_sync = sync;
>  	status = pnfs4_proc_layoutcommit(data);
> @@ -2242,7 +2268,7 @@ out:
>  	return status;
>  out_unlock:
>  	pnfs_layoutcommit_free(data);
> -	spin_unlock(&nfsi->lo_lock);
> +	unlock_current_layout(nfsi);
>  	goto out;
>  }
>  
