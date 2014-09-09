Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:56433 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754164AbaIIRL5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 13:11:57 -0400
Message-ID: <540F34CF.7080709@Netapp.com>
Date: Tue, 9 Sep 2014 13:11:43 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/9] pnfs: force a layout commit when encountering busy
 segments during recall
References: <1410280853-3964-1-git-send-email-hch@lst.de> <1410280853-3964-2-git-send-email-hch@lst.de>
In-Reply-To: <1410280853-3964-2-git-send-email-hch@lst.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/09/2014 12:40 PM, Christoph Hellwig wrote:
> Expedite layout recall processing by forcing a layout commit when
> we see busy segments.  Without it the layout recall might have to wait
> until the VM decided to start writeback for the file, which can introduce
> long delays.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/callback_proc.c | 10 +++++++++-
>  fs/nfs/pnfs.c          |  4 ++++
>  2 files changed, 13 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 41db525..35f2712 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -171,6 +171,13 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>  		goto out;
>  
>  	ino = lo->plh_inode;
> +
> +	spin_lock(&ino->i_lock);
> +	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
> +	spin_unlock(&ino->i_lock);
> +
> +	pnfs_layoutcommit_inode(ino, false);
> +
>  	spin_lock(&ino->i_lock);
>  	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
>  	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
> @@ -178,10 +185,11 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>  		rv = NFS4ERR_DELAY;
>  	else
>  		rv = NFS4ERR_NOMATCHING_LAYOUT;
> -	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
>  	spin_unlock(&ino->i_lock);
> +
>  	pnfs_free_lseg_list(&free_me_list);
>  	pnfs_put_layout_hdr(lo);
> +
>  	iput(ino);
>  out:
>  	return rv;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 8827ab1..04050eb 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -594,6 +594,9 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
>  		dprintk("%s freeing layout for inode %lu\n", __func__,
>  			lo->plh_inode->i_ino);
>  		inode = lo->plh_inode;
> +
> +		pnfs_layoutcommit_inode(inode, false);
> +
>  		spin_lock(&inode->i_lock);
>  		list_del_init(&lo->plh_bulk_destroy);
>  		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
> @@ -604,6 +607,7 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
>  		spin_unlock(&inode->i_lock);
>  		pnfs_free_lseg_list(&lseg_list);
>  		pnfs_put_layout_hdr(lo);
> +
>  		iput(inode);

Any reason for the occasional spacing changes in this patch?

Anna
>  	}
>  	return ret;

