Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:60306 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753215AbbBMUFm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Feb 2015 15:05:42 -0500
Message-ID: <54DE5914.2060608@Netapp.com>
Date: Fri, 13 Feb 2015 15:05:40 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: Provide and use helper functions for marking a page
 as unstable
References: <1423855103-88401-1-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1423855103-88401-1-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/13/2015 02:18 PM, Tom Haynes wrote:
> Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> ---
>  fs/nfs/filelayout/filelayout.c         |  9 ++-------
>  fs/nfs/flexfilelayout/flexfilelayout.c |  9 ++-------
>  fs/nfs/internal.h                      | 13 +++++++++++++
>  fs/nfs/write.c                         | 16 ++++------------
>  4 files changed, 21 insertions(+), 26 deletions(-)
> 
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index 7ae1c26..e1e5ea2 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -1000,13 +1000,8 @@ mds_commit:
>  	nfs_list_add_request(req, list);
>  	cinfo->mds->ncommit++;
>  	spin_unlock(cinfo->lock);
> -	if (!cinfo->dreq) {
> -		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> -		inc_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
> -			     BDI_RECLAIMABLE);
> -		__mark_inode_dirty(req->wb_context->dentry->d_inode,
> -				   I_DIRTY_DATASYNC);
> -	}
> +	if (!cinfo->dreq)
> +		nfs_mark_page_unstable(req->wb_page);
>  }
>  
>  static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index c22ecaa..423c2bc 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -1364,13 +1364,8 @@ ff_layout_mark_request_commit(struct nfs_page *req,
>  	nfs_list_add_request(req, list);
>  	cinfo->mds->ncommit++;
>  	spin_unlock(cinfo->lock);
> -	if (!cinfo->dreq) {
> -		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> -		inc_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
> -			     BDI_RECLAIMABLE);
> -		__mark_inode_dirty(req->wb_context->dentry->d_inode,
> -				   I_DIRTY_DATASYNC);
> -	}
> +	if (!cinfo->dreq)
> +		nfs_mark_page_unstable(req->wb_page);
>  }
>  
>  static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 212b8c8..b802fb3 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -598,6 +598,19 @@ void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
>  }
>  
>  /*
> + * Record the page as unstable and mark its inode as dirty.
> + */
> +static inline
> +void nfs_mark_page_unstable(struct page *page)
> +{
> +	struct inode *inode = page_file_mapping(page)->host;
> +
> +	inc_zone_page_state(page, NR_UNSTABLE_NFS);
> +	inc_bdi_stat(inode_to_bdi(inode), BDI_RECLAIMABLE);
> +	 __mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> +}
> +
> +/*
>   * Determine the number of bytes of data the page contains
>   */
>  static inline
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 88a6d21..595d81e 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -789,13 +789,8 @@ nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
>  	nfs_list_add_request(req, dst);
>  	cinfo->mds->ncommit++;
>  	spin_unlock(cinfo->lock);
> -	if (!cinfo->dreq) {
> -		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> -		inc_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
> -			     BDI_RECLAIMABLE);
> -		__mark_inode_dirty(req->wb_context->dentry->d_inode,
> -				   I_DIRTY_DATASYNC);
> -	}
> +	if (!cinfo->dreq)
> +		nfs_mark_page_unstable(req->wb_page);
>  }
>  EXPORT_SYMBOL_GPL(nfs_request_add_commit_list);
>  
> @@ -1605,11 +1600,8 @@ void nfs_retry_commit(struct list_head *page_list,
>  		req = nfs_list_entry(page_list->next);
>  		nfs_list_remove_request(req);
>  		nfs_mark_request_commit(req, lseg, cinfo, ds_commit_idx);
> -		if (!cinfo->dreq) {
> -			dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> -			dec_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
> -				     BDI_RECLAIMABLE);
> -		}
> +		if (!cinfo->dreq)
> +			nfs_clear_page_commit(req->wb_page);

This looks like a separate change than what the patch is advertising...  Can you please send it as a separate patch?

Thanks,
Anna

>  		nfs_unlock_and_release_request(req);
>  	}
>  }
> 

