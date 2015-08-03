Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:7781 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbbHCPUy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Aug 2015 11:20:54 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] NFSv4.1/pnfs: Fix atomicity of commit list updates
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Tom Haynes <thomas.haynes@primarydata.com>
References: <1438375070-4262-1-git-send-email-trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Message-ID: <55BF8551.2040505@Netapp.com>
Date: Mon, 3 Aug 2015 11:14:25 -0400
MIME-Version: 1.0
In-Reply-To: <1438375070-4262-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

On 07/31/2015 04:37 PM, Trond Myklebust wrote:
> pnfs_layout_mark_request_commit() needs to ensure that it adds the
> request to the commit list atomically with all the other updates
> in order to prevent corruption to buckets[ds_commit_idx].wlseg
> due to races with pnfs_generic_clear_request_commit().
> 
> Fixes: 338d00cfef07d ("pnfs: Refactor the *_layout_mark_request_commit...")
> Cc: stable@vger.kernel.org # v4.0+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/internal.h | 13 +++++++++----
>  fs/nfs/pnfs_nfs.c |  5 +++--
>  fs/nfs/write.c    | 28 +++++++++++++++++++++++-----
>  3 files changed, 35 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 9b372b845f6a..9553e024fa7d 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -490,6 +490,9 @@ void nfs_retry_commit(struct list_head *page_list,
>  void nfs_commitdata_release(struct nfs_commit_data *data);
>  void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
>  				 struct nfs_commit_info *cinfo);
> +void nfs_request_add_commit_list_locked(struct nfs_page *req,
> +		struct list_head *dst,
> +		struct nfs_commit_info *cinfo);
>  void nfs_request_remove_commit_list(struct nfs_page *req,
>  				    struct nfs_commit_info *cinfo);
>  void nfs_init_cinfo(struct nfs_commit_info *cinfo,
> @@ -623,13 +626,15 @@ void nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
>   * Record the page as unstable and mark its inode as dirty.
>   */
>  static inline
> -void nfs_mark_page_unstable(struct page *page)
> +void nfs_mark_page_unstable(struct page *page, struct nfs_commit_info *cinfo)
>  {
>  	struct inode *inode = page_file_mapping(page)->host;
>  
> -	inc_zone_page_state(page, NR_UNSTABLE_NFS);
> -	inc_wb_stat(&inode_to_bdi(inode)->wb, WB_RECLAIMABLE);
> -	 __mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> +	if (!cinfo->dreq) {
> +		inc_zone_page_state(page, NR_UNSTABLE_NFS);
> +		inc_wb_stat(&inode_to_bdi(inode)->wb, WB_RECLAIMABLE);
> +		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> +	}
>  }
>  
>  /*
> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
> index f37e25b6311c..7a282876662f 100644
> --- a/fs/nfs/pnfs_nfs.c
> +++ b/fs/nfs/pnfs_nfs.c
> @@ -863,9 +863,10 @@ pnfs_layout_mark_request_commit(struct nfs_page *req,
>  	}
>  	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
>  	cinfo->ds->nwritten++;
> -	spin_unlock(cinfo->lock);
>  
> -	nfs_request_add_commit_list(req, list, cinfo);
> +	nfs_request_add_commit_list_locked(req, list, cinfo);
> +	spin_unlock(cinfo->lock);
> +	nfs_mark_page_unstable(req->wb_page, cinfo);
>  }
>  EXPORT_SYMBOL_GPL(pnfs_layout_mark_request_commit);
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 75a35a1afa79..135a6b3aa4fb 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -768,6 +768,27 @@ nfs_page_search_commits_for_head_request_locked(struct nfs_inode *nfsi,
>  }
>  
>  /**
> + * nfs_request_add_commit_list_locked - add request to a commit list
> + * @req: pointer to a struct nfs_page
> + * @dst: commit list head
> + * @cinfo: holds list lock and accounting info
> + *
> + * This sets the PG_CLEAN bit, updates the cinfo count of
> + * number of outstanding requests requiring a commit as well as
> + * the MM page stats.
> + *
> + * The caller must hold the cinfo->lock, and the nfs_page lock.
> + */
> +void
> +nfs_request_add_commit_list_locked(struct nfs_page *req, struct list_head *dst,
> +			    struct nfs_commit_info *cinfo)
> +{
> +	set_bit(PG_CLEAN, &req->wb_flags);
> +	nfs_list_add_request(req, dst);
> +	cinfo->mds->ncommit++;
> +}

This function also needs to be exported for pnfs to use it:

  MODPOST 112 modules
ERROR: "nfs_request_add_commit_list_locked" [fs/nfs/nfsv4.ko] undefined!
scripts/Makefile.modpost:90: recipe for target '__modpost' failed

Thanks,
Anna

> +
> +/**
>   * nfs_request_add_commit_list - add request to a commit list
>   * @req: pointer to a struct nfs_page
>   * @dst: commit list head
> @@ -784,13 +805,10 @@ void
>  nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
>  			    struct nfs_commit_info *cinfo)
>  {
> -	set_bit(PG_CLEAN, &(req)->wb_flags);
>  	spin_lock(cinfo->lock);
> -	nfs_list_add_request(req, dst);
> -	cinfo->mds->ncommit++;
> +	nfs_request_add_commit_list_locked(req, dst, cinfo);
>  	spin_unlock(cinfo->lock);
> -	if (!cinfo->dreq)
> -		nfs_mark_page_unstable(req->wb_page);
> +	nfs_mark_page_unstable(req->wb_page, cinfo);
>  }
>  EXPORT_SYMBOL_GPL(nfs_request_add_commit_list);
>  
> 

