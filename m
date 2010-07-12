From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/2] SQUASHME pnfs-submit: reinitialize pnfs_layout_type
Date: Mon, 12 Jul 2010 19:10:21 +0300
Message-ID: <4C3B3E6D.3070703@panasas.com>
References: <1278693571-3328-1-git-send-email-andros@netapp.com> <1278693571-3328-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43994 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753209Ab0GLQK3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 12:10:29 -0400
In-Reply-To: <1278693571-3328-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 09, 2010, 19:39 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> We do not free the pnfs_layout_type when the layout segment list is empty, but
> we do remove the layout from the nfs_client cl_layouts list, and we also need
> to re-initialize it. The next LAYOUTGET will set the layout values.
> 
> Note: API change: layoutdriver_io_operations free_layout now has a boolean
> to indicate initiaize_only, do not free.

I agree with Boaz that adding a new method (reinit_layout) will be much
better than overloading free_layout.

In any case, having the bool option stating exactly the opposite of
what the function name suggest is quite confusing :)

Benny

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/pnfs.c             |   30 ++++++++++++++++++++++++++++--
>  include/linux/nfs4_pnfs.h |    5 ++++-
>  2 files changed, 32 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 6832237..d8887ef 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -337,7 +337,7 @@ put_layout_locked(struct pnfs_layout_type *lo)
>  
>  		dprintk("%s: freeing layout cache %p\n", __func__, lo);
>  		WARN_ON(!list_empty(&lo->lo_layouts));
> -		io_ops->free_layout(lo);
> +		io_ops->free_layout(lo, false);
>  		nfsi->layout = NULL;
>  	}
>  }
> @@ -658,6 +658,31 @@ _pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
>  	return atomic_read(&lseg->kref.refcount) == 1;
>  }
>  
> +/*
> + * We don't free the pnfs_layout_type upon last LAYOUTRETURN, but we do
> + * un-initialize.  lo->segs is empty, and the layout has been removed from
> + * lo_layouts. Leave the lo->refcount un-touched.
> + *
> + * Called with inode->i_lock held.
> + *
> + * There still might be an outstanding async LAYOUTCOMMIT, but that's OK
> + * because the pnfs_layout_type is not referenced (exept for the refcount)
> + * by layoutcommit rpc_release.
> + *
> + * Call the layoutdriver free_layout with the initialze-only parameter set
> + * to true.
> + */
> +static void nfs4_uninitialize_layout(struct pnfs_layout_type *lo)
> +{
> +	dprintk("--> %s lo->refcount %d\n", __func__, lo->refcount);
> +	lo->roc_iomode = 0;
> +	pnfs_set_layout_stateid(lo, &zero_stateid);
> +	lo->pnfs_layout_state = 0;
> +	lo->pnfs_write_begin_pos = 0;
> +	lo->pnfs_write_end_pos = 0;
> +	/* True means initialize, do not free the layout */
> +	PNFS_LD_IO_OPS(lo)->free_layout(lo, true);
> +}
>  
>  static void
>  pnfs_free_layout(struct pnfs_layout_type *lo,
> @@ -686,6 +711,7 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
>  		spin_lock(&clp->cl_lock);
>  		list_del_init(&lo->lo_layouts);
>  		spin_unlock(&clp->cl_lock);
> +		nfs4_uninitialize_layout(lo);
>  	}
>  
>  	dprintk("%s:Return\n", __func__);
> @@ -959,7 +985,7 @@ nfs_lock_alloc_layout(struct inode *ino)
>  		/* Reference the layout accross i_lock release and grab */
>  		get_layout(NFS_I(ino)->layout);
>  		spin_unlock(&ino->i_lock);
> -		NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->free_layout(new);
> +		PNFS_LD_IO_OPS(NFS_I(ino)->layout)->free_layout(new, false);
>  		spin_lock(&ino->i_lock);
>  		put_layout_locked(NFS_I(ino)->layout);
>  	}
> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
> index 2c6ce4c..70e80cd 100644
> --- a/include/linux/nfs4_pnfs.h
> +++ b/include/linux/nfs4_pnfs.h
> @@ -145,7 +145,10 @@ struct layoutdriver_io_operations {
>  	 * inode specific layout structure.  Each subsequent layoutget operation results in
>  	 * a set_layout call to set the opaque layout in the layout driver.*/
>  	struct pnfs_layout_type * (*alloc_layout) (struct inode *inode);
> -	void (*free_layout) (struct pnfs_layout_type *);
> +
> +	/* init_only true, means do not free the layout, just re-initialize */
> +	void (*free_layout) (struct pnfs_layout_type *, bool init_only);
> +
>  	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
>  	void (*free_lseg) (struct pnfs_layout_segment *lseg);
>  
