From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 05/16] SQUASHME pnfs-submit: rewrite layout allocation
Date: Mon, 12 Jul 2010 11:30:37 +0300
Message-ID: <4C3AD2AD.5010403@panasas.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com> <1278542063-4009-2-git-send-email-andros@netapp.com> <1278542063-4009-3-git-send-email-andros@netapp.com> <1278542063-4009-4-git-send-email-andros@netapp.com> <1278542063-4009-5-git-send-email-andros@netapp.com> <1278542063-4009-6-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:56275 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752029Ab0GLIan (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 04:30:43 -0400
In-Reply-To: <1278542063-4009-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 08, 2010, 1:34 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Don't wait on a bit if layout is not allocated. Instead, allocate,
> check for existance, and possibly free.
> 
> As per new layout refcounting scheme,don't take a reference on the layout.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/pnfs.c          |   84 +++++++++++++----------------------------------
>  include/linux/nfs_fs.h |    1 -
>  2 files changed, 23 insertions(+), 62 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 6d435ed..92b7772 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -914,7 +914,6 @@ alloc_init_layout(struct inode *ino)
>  	struct pnfs_layout_type *lo;
>  	struct layoutdriver_io_operations *io_ops;
>  
> -	BUG_ON(NFS_I(ino)->layout != NULL);
>  	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
>  	lo = io_ops->alloc_layout(ino);
>  	if (!lo) {
> @@ -923,84 +922,47 @@ alloc_init_layout(struct inode *ino)
>  			__func__);
>  		return NULL;
>  	}
> -	spin_lock(&ino->i_lock);
>  	lo->refcount = 1;
>  	INIT_LIST_HEAD(&lo->lo_layouts);
>  	INIT_LIST_HEAD(&lo->segs);
>  	seqlock_init(&lo->seqlock);
>  	lo->lo_inode = ino;
> -	NFS_I(ino)->layout = lo;
> -	spin_unlock(&ino->i_lock);
>  	return lo;
>  }
>  
> -static int pnfs_wait_schedule(void *word)
> -{
> -	if (signal_pending(current))
> -		return -ERESTARTSYS;
> -	schedule();
> -	return 0;
> -}
> -
>  /*
> - * get, possibly allocate, and lock current_layout
> + * Lock and possibly allocate the inode layout
>   *
> - * Note: If successful, ino->i_lock is taken and the caller
> - * must put and unlock current_layout when the returned layout is released.
> + * If successful, ino->i_lock is taken, and the caller must unlock.
>   */
>  static struct pnfs_layout_type *
> -get_lock_alloc_layout(struct inode *ino)
> +nfs_lock_alloc_layout(struct inode *ino)
>  {
> -	struct nfs_inode *nfsi = NFS_I(ino);
> -	struct pnfs_layout_type *lo;
> -	int res;
> +	struct pnfs_layout_type *new = NULL;
>  
>  	dprintk("%s Begin\n", __func__);
>  
>  	spin_lock(&ino->i_lock);
> -	while ((lo = grab_current_layout(nfsi)) == NULL) {
> +	if (NFS_I(ino)->layout == NULL) {
>  		spin_unlock(&ino->i_lock);

There's no real need to take the lock here just for checking for NULL,
only down below before actually committing the newly allocated struct.
[I'll make this fix)

Benny

> -		/* Compete against other threads on who's doing the allocation,
> -		 * wait until bit is cleared if we lost this race.
> -		 */
> -		res = wait_on_bit_lock(
> -			&nfsi->layout->pnfs_layout_state,
> -			NFS_INO_LAYOUT_ALLOC,
> -			pnfs_wait_schedule, TASK_KILLABLE);
> -		if (res) {
> -			lo = ERR_PTR(res);
> -			break;
> -		}
> -
> -		/* Was current_layout already allocated while we slept?
> -		 * If so, retry get_lock'ing it. Otherwise, allocate it.
> -		 */
> -		if (nfsi->layout) {
> -			spin_lock(&ino->i_lock);
> -			continue;
> +		new = alloc_init_layout(ino);
> +		if (new == NULL)
> +			return NULL;
> +		spin_lock(&ino->i_lock);
> +		if (NFS_I(ino)->layout == NULL) {
> +			NFS_I(ino)->layout = new;
> +			new = NULL;
>  		}
> -
> -		lo = alloc_init_layout(ino);
> -		if (lo)
> -			spin_lock(&ino->i_lock);
> -		else
> -			lo = ERR_PTR(-ENOMEM);
> -
> -		/* release the NFS_INO_LAYOUT_ALLOC bit and wake up waiters */
> -		clear_bit_unlock(NFS_INO_LAYOUT_ALLOC,
> -				 &nfsi->layout->pnfs_layout_state);
> -		wake_up_bit(&nfsi->layout->pnfs_layout_state,
> -			    NFS_INO_LAYOUT_ALLOC);
> -		break;
>  	}
> -
> -#ifdef NFS_DEBUG
> -	if (!IS_ERR(lo))
> -		dprintk("%s Return %p\n", __func__, lo);
> -	else
> -		dprintk("%s Return error %ld\n", __func__, PTR_ERR(lo));
> -#endif
> -	return lo;
> +	if (new) {
> +		/* Reference the layout accross i_lock release and grab */
> +		get_layout(NFS_I(ino)->layout);
> +		spin_unlock(&ino->i_lock);
> +		NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->free_layout(new);
> +		spin_lock(&ino->i_lock);
> +		put_layout(NFS_I(ino)->layout);
> +	}
> +	return NFS_I(ino)->layout;
>  }
>  
>  /*
> @@ -1088,8 +1050,8 @@ _pnfs_update_layout(struct inode *ino,
>  
>  	if (take_ref)
>  		*lsegpp = NULL;
> -	lo = get_lock_alloc_layout(ino);
> -	if (IS_ERR(lo)) {
> +	lo = nfs_lock_alloc_layout(ino);
> +	if (lo == NULL) {
>  		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
>  		goto out;
>  	}
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 7b999a4..005b3ea 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -107,7 +107,6 @@ struct pnfs_layout_type {
>  	unsigned long pnfs_layout_state;
>  	#define NFS_INO_RO_LAYOUT_FAILED 0      /* get ro layout failed stop trying */
>  	#define NFS_INO_RW_LAYOUT_FAILED 1      /* get rw layout failed stop trying */
> -	#define NFS_INO_LAYOUT_ALLOC     2      /* bit lock for layout allocation */
>  	#define NFS_INO_LAYOUTCOMMIT     3      /* LAYOUTCOMMIT needed */
>  	struct rpc_cred         *lo_cred; /* layoutcommit credential */
>  	/* DH: These vars keep track of the maximum write range
