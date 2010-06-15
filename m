From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] pnfs-submit: Remove lo_lock and use i_lock instead
Date: Tue, 15 Jun 2010 17:06:14 -0400
Message-ID: <4C17EB46.5010701@panasas.com>
References: <1276588792-9212-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:61264 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103Ab0FOVGR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 17:06:17 -0400
Received: by gwj15 with SMTP id 15so3589262gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 14:06:17 -0700 (PDT)
In-Reply-To: <1276588792-9212-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-06-15 03:59, Fred Isaman wrote:
> Signed-off-by: Fred Isaman <iisaman@netapp.com>

Thanks!
I queued it in pnfs-submit.
Should go out in the next batch.

Benny

> ---
>  fs/nfs/inode.c         |    2 +-
>  fs/nfs/pnfs.c          |   54 ++++++++++++++++++++++++------------------------
>  include/linux/nfs_fs.h |    1 -
>  3 files changed, 28 insertions(+), 29 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index cdec539..e51f882 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1417,7 +1417,7 @@ static void pnfs_init_once(struct nfs_inode *nfsi)
>  {
>  #ifdef CONFIG_NFS_V4_1
>  	init_waitqueue_head(&nfsi->lo_waitq);
> -	spin_lock_init(&nfsi->lo_lock);
> +	spin_lock_init(&nfsi->vfs_inode.i_lock);
>  	seqlock_init(&nfsi->layout.seqlock);
>  	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
>  	INIT_LIST_HEAD(&nfsi->layout.segs);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 7d322c9..4afa4cf 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -152,15 +152,15 @@ void
>  pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
>  {
>  	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi), ctx);
> -	spin_lock(&nfsi->lo_lock);
> +	spin_lock(&nfsi->vfs_inode.i_lock);
>  	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
>  		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
>  		nfsi->change_attr++;
> -		spin_unlock(&nfsi->lo_lock);
> +		spin_unlock(&nfsi->vfs_inode.i_lock);
>  		dprintk("%s: Set layoutcommit\n", __func__);
>  		return;
>  	}
> -	spin_unlock(&nfsi->lo_lock);
> +	spin_unlock(&nfsi->vfs_inode.i_lock);
>  }
>  
>  /* Update last_write_offset for layoutcommit.
> @@ -173,7 +173,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
>  {
>  	loff_t end_pos;
>  
> -	spin_lock(&nfsi->lo_lock);
> +	spin_lock(&nfsi->vfs_inode.i_lock);
>  	if (offset < nfsi->layout.pnfs_write_begin_pos)
>  		nfsi->layout.pnfs_write_begin_pos = offset;
>  	end_pos = offset + extent - 1; /* I'm being inclusive */
> @@ -185,7 +185,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
>  		(unsigned long) offset ,
>  		(unsigned long) nfsi->layout.pnfs_write_begin_pos,
>  		(unsigned long) nfsi->layout.pnfs_write_end_pos);
> -	spin_unlock(&nfsi->lo_lock);
> +	spin_unlock(&nfsi->vfs_inode.i_lock);
>  }
>  
>  /* Unitialize a mountpoint in a layout driver */
> @@ -315,7 +315,7 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
>   */
>  #if defined(CONFIG_SMP)
>  #define BUG_ON_UNLOCKED_LO(lo) \
> -	BUG_ON(!spin_is_locked(&PNFS_NFS_INODE(lo)->lo_lock))
> +	BUG_ON(!spin_is_locked(&PNFS_INODE(lo)->i_lock))
>  #else /* CONFIG_SMP */
>  #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
>  #endif /* CONFIG_SMP */
> @@ -329,9 +329,9 @@ get_lock_current_layout(struct nfs_inode *nfsi)
>  	struct pnfs_layout_type *lo;
>  
>  	lo = &nfsi->layout;
> -	spin_lock(&nfsi->lo_lock);
> +	spin_lock(&nfsi->vfs_inode.i_lock);
>  	if (!lo->ld_data) {
> -		spin_unlock(&nfsi->lo_lock);
> +		spin_unlock(&nfsi->vfs_inode.i_lock);
>  		return NULL;
>  	}
>  
> @@ -345,7 +345,7 @@ get_lock_current_layout(struct nfs_inode *nfsi)
>  static inline void
>  put_unlock_current_layout(struct pnfs_layout_type *lo)
>  {
> -	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
> +	struct inode *inode = PNFS_INODE(lo);
>  	struct nfs_client *clp;
>  
>  	BUG_ON_UNLOCKED_LO(lo);
> @@ -360,12 +360,12 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
>  		lo->ld_data = NULL;
>  
>  		/* Unlist the layout. */
> -		clp = NFS_SERVER(&nfsi->vfs_inode)->nfs_client;
> +		clp = NFS_SERVER(inode)->nfs_client;
>  		spin_lock(&clp->cl_lock);
>  		list_del_init(&lo->lo_layouts);
>  		spin_unlock(&clp->cl_lock);
>  	}
> -	spin_unlock(&nfsi->lo_lock);
> +	spin_unlock(&inode->i_lock);
>  }
>  
>  void
> @@ -374,7 +374,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
>  {
>  	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
>  
> -	spin_lock(&nfsi->lo_lock);
> +	spin_lock(&nfsi->vfs_inode.i_lock);
>  	if (range)
>  		pnfs_free_layout(lo, range);
>  	put_unlock_current_layout(lo);
> @@ -446,9 +446,9 @@ put_lseg(struct pnfs_layout_segment *lseg)
>  		atomic_read(&lseg->kref.refcount), lseg->valid);
>  	do_wake_up = !lseg->valid;
>  	nfsi = PNFS_NFS_INODE(lseg->layout);
> -	spin_lock(&nfsi->lo_lock);
> +	spin_lock(&nfsi->vfs_inode.i_lock);
>  	kref_put(&lseg->kref, destroy_lseg);
> -	spin_unlock(&nfsi->lo_lock);
> +	spin_unlock(&nfsi->vfs_inode.i_lock);
>  	if (do_wake_up)
>  		wake_up(&nfsi->lo_waitq);
>  }
> @@ -686,7 +686,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>  	struct pnfs_layout_segment *lseg;
>  	bool ret = false;
>  
> -	spin_lock(&nfsi->lo_lock);
> +	spin_lock(&nfsi->vfs_inode.i_lock);
>  	list_for_each_entry (lseg, &nfsi->layout.segs, fi_list) {
>  		if (!should_free_lseg(lseg, range))
>  			continue;
> @@ -698,7 +698,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>  			ret = true;
>  		}
>  	}
> -	spin_unlock(&nfsi->lo_lock);
> +	spin_unlock(&nfsi->vfs_inode.i_lock);
>  	dprintk("%s:Return %d\n", __func__, ret);
>  	return ret;
>  }
> @@ -772,12 +772,12 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
>  		/* unlock w/o put rebalanced by eventual call to
>  		 * pnfs_layout_release
>  		 */
> -		spin_unlock(&nfsi->lo_lock);
> +		spin_unlock(&ino->i_lock);
>  
>  		if (pnfs_return_layout_barrier(nfsi, &arg)) {
>  			if (stateid) { /* callback */
>  				status = -EAGAIN;
> -				spin_lock(&nfsi->lo_lock);
> +				spin_lock(&ino->i_lock);
>  				put_unlock_current_layout(lo);
>  				goto out;
>  			}
> @@ -922,7 +922,7 @@ static int pnfs_wait_schedule(void *word)
>  /*
>   * get, possibly allocate, and lock current_layout
>   *
> - * Note: If successful, nfsi->lo_lock is taken and the caller
> + * Note: If successful, ino->i_lock is taken and the caller
>   * must put and unlock current_layout by using put_unlock_current_layout()
>   * when the returned layout is released.
>   */
> @@ -959,7 +959,7 @@ get_lock_alloc_layout(struct inode *ino)
>  			struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
>  
>  			/* must grab the layout lock before the client lock */
> -			spin_lock(&nfsi->lo_lock);
> +			spin_lock(&ino->i_lock);
>  
>  			spin_lock(&clp->cl_lock);
>  			if (list_empty(&lo->lo_layouts))
> @@ -1111,7 +1111,7 @@ _pnfs_update_layout(struct inode *ino,
>  	}
>  
>  	/* Lose lock, but not reference, match this with pnfs_layout_release */
> -	spin_unlock(&nfsi->lo_lock);
> +	spin_unlock(&ino->i_lock);
>  
>  	get_layout(ino, ctx, &arg, lsegpp, lo);
>  out:
> @@ -1235,7 +1235,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
>  	struct pnfs_layout_type *lo = lgp->lo;
>  	struct nfs4_pnfs_layoutget_res *res = &lgp->res;
>  	struct pnfs_layout_segment *lseg;
> -	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
> +	struct inode *ino = PNFS_INODE(lo);
>  	int status = 0;
>  
>  	/* Inject layout blob into I/O device driver */
> @@ -1257,7 +1257,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
>  		*lgp->lsegpp = lseg;
>  	}
>  
> -	spin_lock(&nfsi->lo_lock);
> +	spin_lock(&ino->i_lock);
>  	pnfs_insert_layout(lo, lseg);
>  
>  	if (res->return_on_close) {
> @@ -1268,7 +1268,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
>  
>  	/* Done processing layoutget. Set the layout stateid */
>  	pnfs_set_layout_stateid(lo, &res->stateid);
> -	spin_unlock(&nfsi->lo_lock);
> +	spin_unlock(&ino->i_lock);
>  out:
>  	return status;
>  }
> @@ -1785,9 +1785,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>  	if (!data)
>  		return -ENOMEM;
>  
> -	spin_lock(&nfsi->lo_lock);
> +	spin_lock(&inode->i_lock);
>  	if (!layoutcommit_needed(nfsi)) {
> -		spin_unlock(&nfsi->lo_lock);
> +		spin_unlock(&inode->i_lock);
>  		goto out_free;
>  	}
>  
> @@ -1802,7 +1802,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>  	nfsi->layout.lo_cred = NULL;
>  	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
>  
> -	spin_unlock(&nfsi->lo_lock);
> +	spin_unlock(&inode->i_lock);
>  
>  	/* Set up layout commit args */
>  	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 41026cb..a60d880 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -206,7 +206,6 @@ struct nfs_inode {
>  	/* pNFS layout information */
>  #if defined(CONFIG_NFS_V4_1)
>  	wait_queue_head_t lo_waitq;
> -	spinlock_t lo_lock;
>  	struct pnfs_layout_type layout;
>  #endif /* CONFIG_NFS_V4_1 */
>  #endif /* CONFIG_NFS_V4*/

