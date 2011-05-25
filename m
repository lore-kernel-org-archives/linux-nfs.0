Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:39533 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab1EYQzi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2011 12:55:38 -0400
Message-ID: <4DDD3487.5060300@panasas.com>
Date: Wed, 25 May 2011 19:55:35 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH V3] SQUASHME: pnfs: Fix NULL dereference and leak in the
 -ENOMEM path
References: <4DDA8C3D.5080706@panasas.com> <1306168714-11721-1-git-send-email-bhalevy@panasas.com> <4DDD2933.3000209@panasas.com> <4DDD30F8.5020304@panasas.com>
In-Reply-To: <4DDD30F8.5020304@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-25 19:40, Boaz Harrosh wrote:
> 
> In _pnfs_return_layout:
> 
> lrp pointer is checked for NULL after it was already accessed.
> 
> The rational here is that in _pnfs_return_layout we want to
> de-ref and release the layout regardless of if we sent the
> return or not (forgetfull). An eventual recall can return -ENOMATCHING
> instead of -EDELAY.
> 
> So to keep the reasoning above, copy the stateid twice.
> 
> Benny if it is OK to not release the layout on -ENOMEM then the check
> could just be moved above the spin_lock(), and the put_layout_hdr removed.
> 
> Also the error returns would leak the lrp so fix it.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/pnfs.c |   15 +++++++++------
>  1 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index a07b007..9b749f2 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -627,22 +627,20 @@ _pnfs_return_layout(struct inode *ino)
>  	struct pnfs_layout_hdr *lo = NULL;
>  	struct nfs_inode *nfsi = NFS_I(ino);
>  	LIST_HEAD(tmp_list);
> -	struct nfs4_layoutreturn *lrp;
> +	struct nfs4_layoutreturn *lrp = NULL;
> +	nfs4_stateid stateid;
>  	int status = 0;
>  
>  	dprintk("--> %s\n", __func__);
>  
> -	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
> -
>  	spin_lock(&ino->i_lock);
>  	lo = nfsi->layout;
>  	if (!lo || !mark_matching_lsegs_invalid(lo, &tmp_list, NULL)) {
>  		spin_unlock(&ino->i_lock);
>  		dprintk("%s: no layout segments to return\n", __func__);
> -		kfree(lrp);
>  		goto out;
>  	}
> -	lrp->args.stateid = nfsi->layout->plh_stateid;
> +	stateid = nfsi->layout->plh_stateid;
>  	/* Reference matched in nfs4_layoutreturn_release */
>  	get_layout_hdr(lo);
>  	spin_unlock(&ino->i_lock);
> @@ -650,11 +648,14 @@ _pnfs_return_layout(struct inode *ino)
>  
>  	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
>  
> -	if (lrp == NULL) {

I prefer to simply move this test up before the condition calling
mark_matching_lsegs_invalid

> +	/* lrp is freed in nfs4_layoutreturn_release */
> +	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
> +	if (unlikely(!lrp)) {
>  		put_layout_hdr(NFS_I(ino)->layout);
>  		status = -ENOMEM;
>  		goto out;
>  	}
> +	lrp->args.stateid = stateid;
>  	lrp->args.reclaim = 0;
>  	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
>  	lrp->args.inode = ino;
> @@ -662,6 +663,8 @@ _pnfs_return_layout(struct inode *ino)
>  
>  	status = nfs4_proc_layoutreturn(lrp);
>  out:
> +	if (unlikely(status))
> +		kfree(lrp);

I wonder where this leak you're seeing is coming from.
rpc_release is supposed to be called even on task allocation error,
see rpc_new_task.

Benny

>  	dprintk("<-- %s status: %d\n", __func__, status);
>  	return status;
>  }
