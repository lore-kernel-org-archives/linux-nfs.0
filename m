Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26518 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932541AbaHYNuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 09:50:37 -0400
Message-ID: <53FB3F2A.409@Netapp.com>
Date: Mon, 25 Aug 2014 09:50:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 08/19] pnfs: add return_range method
References: <pnfs block layout driver fixes V2> <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-9-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-9-git-send-email-hch@lst.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/21/2014 12:09 PM, Christoph Hellwig wrote:
> If a layout driver keeps per-inode state outside of the layout segments it
> needs to be notified of any layout returns or recalls on an inode, and not
> just about the freeing of layout segments.  Add a method to acomplish this,
> which will allow the block layout driver to handle the case of truncated
> and re-expanded files properly.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/callback_proc.c |  6 +++++-
>  fs/nfs/pnfs.c          | 10 ++++++++++
>  fs/nfs/pnfs.h          |  3 +++
>  3 files changed, 18 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index bf017b0..86541e0 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -179,8 +179,12 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>  			&args->cbl_range)) {
>  		need_commit = true;
>  		rv = NFS4ERR_DELAY;
> +	} else {
> +		if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
> +			NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
> +				&args->cbl_range);
> +		}
>  	}
Is there a reason you're nesting the else-if here?

Anna
> -
>  	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
>  	spin_unlock(&ino->i_lock);
>  	pnfs_free_lseg_list(&free_me_list);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index bce7f1b..e481d1c 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -857,6 +857,16 @@ _pnfs_return_layout(struct inode *ino)
>  	empty = list_empty(&lo->plh_segs);
>  	pnfs_clear_layoutcommit(ino, &tmp_list);
>  	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
> +
> +	if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
> +		struct pnfs_layout_range range = {
> +			.iomode		= IOMODE_ANY,
> +			.offset		= 0,
> +			.length		= NFS4_MAX_UINT64,
> +		};
> +		NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo, &range);
> +	}
> +
>  	/* Don't send a LAYOUTRETURN if list was initially empty */
>  	if (empty) {
>  		spin_unlock(&ino->i_lock);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 302b279..044c071 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -94,6 +94,9 @@ struct pnfs_layoutdriver_type {
>  	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
>  	void (*free_lseg) (struct pnfs_layout_segment *lseg);
>  
> +	void (*return_range) (struct pnfs_layout_hdr *lo,
> +			      struct pnfs_layout_range *range);
> +
>  	/* test for nfs page cache coalescing */
>  	const struct nfs_pageio_ops *pg_read_ops;
>  	const struct nfs_pageio_ops *pg_write_ops;

