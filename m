From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 09/16] SQUASHME pnfs-submit: pnfs_update_layout always
 references the lseg
Date: Mon, 12 Jul 2010 12:13:04 +0300
Message-ID: <4C3ADCA0.4060904@panasas.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com> <1278542063-4009-2-git-send-email-andros@netapp.com> <1278542063-4009-3-git-send-email-andros@netapp.com> <1278542063-4009-4-git-send-email-andros@netapp.com> <1278542063-4009-5-git-send-email-andros@netapp.com> <1278542063-4009-6-git-send-email-andros@netapp.com> <1278542063-4009-7-git-send-email-andros@netapp.com> <1278542063-4009-8-git-send-email-andros@netapp.com> <1278542063-4009-9-git-send-email-andros@netapp.com> <1278542063-4009-10-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24303 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752029Ab0GLJNH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 05:13:07 -0400
In-Reply-To: <1278542063-4009-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 08, 2010, 1:34 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> So remove test_ref
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>

OK, but this has to be reintroduced in post submit for
better synchronization with parallel layout gets and returns.

Benny

> ---
>  fs/nfs/pnfs.c |   30 ++++++++++--------------------
>  1 files changed, 10 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 118d34c..d4ffd1c 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -997,9 +997,7 @@ has_matching_lseg(struct pnfs_layout_segment *lseg,
>   */
>  static struct pnfs_layout_segment *
>  pnfs_has_layout(struct pnfs_layout_type *lo,
> -		struct nfs4_pnfs_layout_segment *range,
> -		bool take_ref,
> -		bool only_valid)
> +		struct nfs4_pnfs_layout_segment *range)
>  {
>  	struct pnfs_layout_segment *lseg, *ret = NULL;
>  
> @@ -1007,28 +1005,24 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
>  
>  	BUG_ON_UNLOCKED_LO(lo);
>  	list_for_each_entry (lseg, &lo->segs, fi_list) {
> -		if (has_matching_lseg(lseg, range) &&
> -		    (lseg->valid || !only_valid)) {
> +		if (has_matching_lseg(lseg, range)) {
>  			ret = lseg;
> -			if (take_ref)
> -				get_lseg(ret);
> +			get_lseg(ret);
>  			break;
>  		}
>  		if (cmp_layout(range, &lseg->range) > 0)
>  			break;
>  	}
>  
> -	dprintk("%s:Return lseg %p take_ref %d ref %d valid %d\n",
> -		__func__, ret, take_ref,
> -		ret ? atomic_read(&ret->kref.refcount) : 0,
> +	dprintk("%s:Return lseg %p ref %d valid %d\n",
> +		__func__, ret, ret ? atomic_read(&ret->kref.refcount) : 0,
>  		ret ? ret->valid : 0);
>  	return ret;
>  }
>  
>  /* Update the file's layout for the given range and iomode.
>   * Layout is retreived from the server if needed.
> - * If lsegpp is given, the appropriate layout segment is referenced and
> - * returned to the caller.
> + * The appropriate layout segment is referenced and returned to the caller.
>   */
>  void
>  _pnfs_update_layout(struct inode *ino,
> @@ -1046,10 +1040,8 @@ _pnfs_update_layout(struct inode *ino,
>  	struct nfs_inode *nfsi = NFS_I(ino);
>  	struct pnfs_layout_type *lo;
>  	struct pnfs_layout_segment *lseg = NULL;
> -	bool take_ref = (lsegpp != NULL);
>  
> -	if (take_ref)
> -		*lsegpp = NULL;
> +	*lsegpp = NULL;
>  	lo = nfs_lock_alloc_layout(ino);
>  	if (lo == NULL) {
>  		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
> @@ -1057,10 +1049,9 @@ _pnfs_update_layout(struct inode *ino,
>  	}
>  
>  	/* Check to see if the layout for the given range already exists */
> -	lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
> +	lseg = pnfs_has_layout(lo, &arg);
>  	if (lseg && !lseg->valid) {
> -		if (take_ref)
> -			put_lseg_locked(lseg);
> +		put_lseg_locked(lseg);
>  		/* someone is cleaning the layout */
>  		lseg = NULL;
>  		goto out_unlock;
> @@ -1099,8 +1090,7 @@ out:
>  		nfsi->layout->pnfs_layout_state, lseg);
>  	return;
>  out_unlock:
> -	if (lsegpp)
> -		*lsegpp = lseg;
> +	*lsegpp = lseg;
>  	spin_unlock(&ino->i_lock);
>  	goto out;
>  }
