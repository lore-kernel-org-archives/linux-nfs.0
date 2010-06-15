From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 03/10] pnfs-submit: remove list_empty check from put_layout
Date: Tue, 15 Jun 2010 12:56:58 -0400
Message-ID: <4C17B0DA.8010206@panasas.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com> <1276566375-24566-2-git-send-email-iisaman@netapp.com> <1276566375-24566-3-git-send-email-iisaman@netapp.com> <1276566375-24566-4-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:59744 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756863Ab0FOQ5C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 12:57:02 -0400
Received: by pxi8 with SMTP id 8so3478321pxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 09:57:01 -0700 (PDT)
In-Reply-To: <1276566375-24566-4-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 14, 2010, 21:46 -0400, Fred Isaman <iisaman@netapp.com> wrote:
> The check on list empty before destroying a layout has always bothered me.
> Get rid of it by having lsegs take a reference on their backpointer.

OK, that should work and be somewhat cleaner than what we have today.
Please see notes below...

> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/pnfs.c |   36 +++++++++++++++++++++++++-----------
>  1 files changed, 25 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 924e6fd..21192b6 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -348,19 +348,27 @@ put_layout(struct pnfs_layout_type *lo)
>  	BUG_ON_UNLOCKED_LO(lo);
>  	BUG_ON(lo->refcount <= 0);
>  
> -	if (--lo->refcount == 0 && list_empty(&lo->segs)) {
> +	lo->refcount--;
> +
> +	if (lo->refcount > 1)
> +		return;
> +
> +	/* Make sure is removed from inode list */
> +	clp = NFS_SERVER(&nfsi->vfs_inode)->nfs_client;
> +	spin_lock(&clp->cl_lock);
> +	if (!list_empty(&lo->lo_layouts)) {
> +		list_del_init(&lo->lo_layouts);
> +		lo->refcount--;
> +	}
> +	spin_unlock(&clp->cl_lock);

This is awkward.
If we're already doing this overhaul the right thing to do
is separate out listing/unlisting of the layout on the clp list
so that the lo is added to the clp list when its lo->segs list
goes from empty to not empty (and in this case get_layout can be called
as you did as there's a reference from the clp to the lo)
and when its segs list empties it should be unlisted and
put_layout(), then if its refcount will go back to 0
it can be destroyed.

> +
> +	if (lo->refcount == 0) {

In this case I'd like to add a
		WARN_ON(!list_empty(&lo->segs))
to make sure that the refcounting agrees with the list manipulation.

Thanks!

Benny

>  		struct layoutdriver_io_operations *io_ops =
>  			PNFS_LD_IO_OPS(lo);
>  
>  		dprintk("%s: freeing layout %p\n", __func__, lo->ld_data);
>  		io_ops->free_layout(lo->ld_data);
>  		lo->ld_data = NULL;
> -
> -		/* Unlist the layout. */
> -		clp = NFS_SERVER(&nfsi->vfs_inode)->nfs_client;
> -		spin_lock(&clp->cl_lock);
> -		list_del_init(&lo->lo_layouts);
> -		spin_unlock(&clp->cl_lock);
>  	}
>  }
>  
> @@ -404,6 +412,7 @@ init_lseg(struct pnfs_layout_type *lo, struct pnfs_layout_segment *lseg)
>  	kref_init(&lseg->kref);
>  	lseg->valid = true;
>  	lseg->layout = lo;
> +	get_layout(lo);
>  }
>  
>  static void
> @@ -413,6 +422,7 @@ destroy_lseg(struct kref *kref)
>  		container_of(kref, struct pnfs_layout_segment, kref);
>  
>  	dprintk("--> %s\n", __func__);
> +	put_layout(lseg->layout);
>  	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
>  }
>  
> @@ -897,9 +907,10 @@ alloc_init_layout(struct inode *ino)
>  	void *ld_data;
>  	struct pnfs_layout_type *lo;
>  	struct layoutdriver_io_operations *io_ops;
> +	struct nfs_inode *nfsi = NFS_I(ino);
>  
>  	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
> -	lo = &NFS_I(ino)->layout;
> +	lo  = &nfsi->layout;
>  	ld_data = io_ops->alloc_layout(ino);
>  	if (!ld_data) {
>  		printk(KERN_ERR
> @@ -908,11 +919,13 @@ alloc_init_layout(struct inode *ino)
>  		return NULL;
>  	}
>  
> +	spin_lock(&nfsi->lo_lock);
>  	BUG_ON(lo->ld_data != NULL);
>  	lo->ld_data = ld_data;
>  	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
>  	lo->refcount = 1;
>  	lo->roc_iomode = 0;
> +	spin_unlock(&nfsi->lo_lock);
>  	return lo;
>  }
>  
> @@ -970,8 +983,10 @@ get_lock_alloc_layout(struct inode *ino)
>  			spin_lock(&nfsi->lo_lock);
>  
>  			spin_lock(&clp->cl_lock);
> -			if (list_empty(&lo->lo_layouts))
> +			if (list_empty(&lo->lo_layouts)) {
>  				list_add_tail(&lo->lo_layouts, &clp->cl_layouts);
> +				get_layout(lo);
> +			}
>  			spin_unlock(&clp->cl_lock);
>  		} else
>  			lo = ERR_PTR(-ENOMEM);
> @@ -1259,14 +1274,13 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
>  		goto out;
>  	}
>  
> +	spin_lock(&nfsi->lo_lock);
>  	init_lseg(lo, lseg);
>  	lseg->range = res->lseg;
>  	if (lgp->lsegpp) {
>  		get_lseg(lseg);
>  		*lgp->lsegpp = lseg;
>  	}
> -
> -	spin_lock(&nfsi->lo_lock);
>  	pnfs_insert_layout(lo, lseg);
>  
>  	if (res->return_on_close) {

