Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:50721 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757488Ab3CULZJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 07:25:09 -0400
Received: by mail-wi0-f169.google.com with SMTP id hi8so1181872wib.4
        for <linux-nfs@vger.kernel.org>; Thu, 21 Mar 2013 04:25:08 -0700 (PDT)
Message-ID: <514AEE11.1030705@tonian.com>
Date: Thu, 21 Mar 2013 13:25:05 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>,
        Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH 2/3] NFSv4.1: Always clear the NFS_INO_LAYOUTCOMMIT in
 layoutreturn
References: <1363801148-29998-1-git-send-email-Trond.Myklebust@netapp.com> <1363801148-29998-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363801148-29998-2-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-20 19:39, Trond Myklebust wrote:
> Note that clearing NFS_INO_LAYOUTCOMMIT is tricky, since it requires
> you to also clear the NFS_LSEG_LAYOUTCOMMIT bits from the layout
> segments.
> The only two sites that need to do this are the ones that call
> pnfs_return_layout() without first doing a layout commit.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Benny Halevy <bhalevy@tonian.com>

ACK

> Cc: stable@vger.kernel.org
> ---
>  fs/nfs/nfs4filelayout.c |  1 -
>  fs/nfs/pnfs.c           | 35 +++++++++++++++++++++++++++--------
>  2 files changed, 27 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index c5656c5..22d1062 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -129,7 +129,6 @@ static void filelayout_fenceme(struct inode *inode, struct pnfs_layout_hdr *lo)
>  {
>  	if (!test_and_clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
>  		return;
> -	clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
>  	pnfs_return_layout(inode);
>  }
>  
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 6f6b356..45badca 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -417,6 +417,16 @@ should_free_lseg(struct pnfs_layout_range *lseg_range,
>  	       lo_seg_intersecting(lseg_range, recall_range);
>  }
>  
> +static bool lseg_dec_and_remove_zero(struct pnfs_layout_segment *lseg,
> +		struct list_head *tmp_list)
> +{
> +	if (!atomic_dec_and_test(&lseg->pls_refcount))
> +		return false;
> +	pnfs_layout_remove_lseg(lseg->pls_layout, lseg);
> +	list_add(&lseg->pls_list, tmp_list);
> +	return true;
> +}
> +
>  /* Returns 1 if lseg is removed from list, 0 otherwise */
>  static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
>  			     struct list_head *tmp_list)
> @@ -430,11 +440,8 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
>  		 */
>  		dprintk("%s: lseg %p ref %d\n", __func__, lseg,
>  			atomic_read(&lseg->pls_refcount));
> -		if (atomic_dec_and_test(&lseg->pls_refcount)) {
> -			pnfs_layout_remove_lseg(lseg->pls_layout, lseg);
> -			list_add(&lseg->pls_list, tmp_list);
> +		if (lseg_dec_and_remove_zero(lseg, tmp_list))
>  			rv = 1;
> -		}
>  	}
>  	return rv;
>  }
> @@ -779,6 +786,21 @@ send_layoutget(struct pnfs_layout_hdr *lo,
>  	return lseg;
>  }
>  
> +static void pnfs_clear_layoutcommit(struct inode *inode,
> +		struct list_head *head)
> +{
> +	struct nfs_inode *nfsi = NFS_I(inode);
> +	struct pnfs_layout_segment *lseg, *tmp;
> +
> +	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
> +		return;
> +	list_for_each_entry_safe(lseg, tmp, &nfsi->layout->plh_segs, pls_list) {
> +		if (!test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
> +			continue;
> +		lseg_dec_and_remove_zero(lseg, head);
> +	}
> +}
> +
>  /*
>   * Initiates a LAYOUTRETURN(FILE), and removes the pnfs_layout_hdr
>   * when the layout segment list is empty.
> @@ -810,6 +832,7 @@ _pnfs_return_layout(struct inode *ino)
>  	/* Reference matched in nfs4_layoutreturn_release */
>  	pnfs_get_layout_hdr(lo);
>  	empty = list_empty(&lo->plh_segs);
> +	pnfs_clear_layoutcommit(ino, &tmp_list);
>  	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
>  	/* Don't send a LAYOUTRETURN if list was initially empty */
>  	if (empty) {
> @@ -822,8 +845,6 @@ _pnfs_return_layout(struct inode *ino)
>  	spin_unlock(&ino->i_lock);
>  	pnfs_free_lseg_list(&tmp_list);
>  
> -	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
> -
>  	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
>  	if (unlikely(lrp == NULL)) {
>  		status = -ENOMEM;
> @@ -1460,7 +1481,6 @@ static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
>  	dprintk("pnfs write error = %d\n", hdr->pnfs_error);
>  	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
>  	    PNFS_LAYOUTRET_ON_ERROR) {
> -		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(hdr->inode)->flags);
>  		pnfs_return_layout(hdr->inode);
>  	}
>  	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
> @@ -1615,7 +1635,6 @@ static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
>  	dprintk("pnfs read error = %d\n", hdr->pnfs_error);
>  	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
>  	    PNFS_LAYOUTRET_ON_ERROR) {
> -		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(hdr->inode)->flags);
>  		pnfs_return_layout(hdr->inode);
>  	}
>  	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
> 
