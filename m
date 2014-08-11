Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:51450 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbaHKNbC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 09:31:02 -0400
Received: by mail-qc0-f176.google.com with SMTP id m20so1550055qcx.35
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2014 06:31:01 -0700 (PDT)
Message-ID: <53E8C593.6030705@gmail.com>
Date: Mon, 11 Aug 2014 09:30:59 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>,
        trond.myklebust@primarydata.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/5] pnfs: find swapped pages on pnfs commit lists too
References: <1407510816-7002-1-git-send-email-dros@primarydata.com> <1407510816-7002-4-git-send-email-dros@primarydata.com>
In-Reply-To: <1407510816-7002-4-git-send-email-dros@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/08/2014 11:13 AM, Weston Andros Adamson wrote:
> nfs_page_find_head_request_locked looks through the regular nfs commit lists
> when the page is swapped out, but doesn't look through the pnfs commit lists.
>
> I'm not sure if anyone has hit any issues caused by this.
>
> Suggested-by: Peng Tao <tao.peng@primarydata.com>
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/filelayout/filelayout.c | 31 ++++++++++++++++++++++++++
>  fs/nfs/pnfs.h                  | 20 +++++++++++++++++
>  fs/nfs/write.c                 | 49 +++++++++++++++++++++++++++++++-----------
>  3 files changed, 88 insertions(+), 12 deletions(-)
>
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index 2576d28b..524e66f 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -1237,6 +1237,36 @@ restart:
>  	spin_unlock(cinfo->lock);
>  }
>  
> +/* filelayout_search_commit_reqs - Search lists in @cinfo for the head reqest
> + *				   for @page
> + * @cinfo - commit info for current inode
> + * @page - page to search for matching head request
> + *
> + * Returns a the head request if one is found, otherwise returns NULL.
> + */
> +static struct nfs_page *
> +filelayout_search_commit_reqs(struct nfs_commit_info *cinfo, struct page *page)
> +{
> +	struct nfs_page *freq, *t;
> +	struct pnfs_commit_bucket *b;
> +	int i;
> +
> +	/* Linearly search the commit lists for each bucket until a matching
> +	 * request is found */
> +	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
> +		list_for_each_entry_safe(freq, t, &b->written, wb_list) {
> +			if (freq->wb_page == page)
> +				return freq->wb_head;
> +		}
> +		list_for_each_entry_safe(freq, t, &b->committing, wb_list) {
> +			if (freq->wb_page == page)
> +				return freq->wb_head;
> +		}
> +	}
> +
> +	return NULL;
> +}
> +
>  static void filelayout_retry_commit(struct nfs_commit_info *cinfo, int idx)
>  {
>  	struct pnfs_ds_commit_info *fl_cinfo = cinfo->ds;
> @@ -1386,6 +1416,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
>  	.clear_request_commit	= filelayout_clear_request_commit,
>  	.scan_commit_lists	= filelayout_scan_commit_lists,
>  	.recover_commit_reqs	= filelayout_recover_commit_reqs,
> +	.search_commit_reqs	= filelayout_search_commit_reqs,
>  	.commit_pagelist	= filelayout_commit_pagelist,
>  	.read_pagelist		= filelayout_read_pagelist,
>  	.write_pagelist		= filelayout_write_pagelist,
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 27ddecd..203b6c9 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -104,6 +104,8 @@ struct pnfs_layoutdriver_type {
>  				  int max);
>  	void (*recover_commit_reqs) (struct list_head *list,
>  				     struct nfs_commit_info *cinfo);
> +	struct nfs_page * (*search_commit_reqs)(struct nfs_commit_info *cinfo,
> +						struct page *page);
>  	int (*commit_pagelist)(struct inode *inode,
>  			       struct list_head *mds_pages,
>  			       int how,
> @@ -341,6 +343,17 @@ pnfs_recover_commit_reqs(struct inode *inode, struct list_head *list,
>  	NFS_SERVER(inode)->pnfs_curr_ld->recover_commit_reqs(list, cinfo);
>  }
>  
> +static inline struct nfs_page *
> +pnfs_search_commit_reqs(struct inode *inode, struct nfs_commit_info *cinfo,
> +			struct page *page)
> +{
> +	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
> +
> +	if (ld == NULL || ld->search_commit_reqs == NULL)
> +		return NULL;
> +	return ld->search_commit_reqs(cinfo, page);
> +}
> +
>  /* Should the pNFS client commit and return the layout upon a setattr */
>  static inline bool
>  pnfs_ld_layoutret_on_setattr(struct inode *inode)
> @@ -492,6 +505,13 @@ pnfs_recover_commit_reqs(struct inode *inode, struct list_head *list,
>  {
>  }
>  
> +static inline struct nfs_page *
> +pnfs_search_commit_reqs(struct inode *inode, struct nfs_commit_info *cinfo,
> +			struct page *page)
> +{
> +	return NULL;
> +}
> +
>  static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>  {
>  	return 0;
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index e6bc5b5..ba41769 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -47,6 +47,8 @@ static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops;
>  static const struct nfs_commit_completion_ops nfs_commit_completion_ops;
>  static const struct nfs_rw_ops nfs_rw_write_ops;
>  static void nfs_clear_request_commit(struct nfs_page *req);
> +static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
> +				      struct inode *inode);
>  
>  static struct kmem_cache *nfs_wdata_cachep;
>  static mempool_t *nfs_wdata_mempool;
> @@ -93,6 +95,38 @@ static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
>  }
>  
>  /*
> + * nfs_page_search_commits_for_head_request_locked
> + *
> + * Search through commit lists on @inode for the head request for @page.
> + * Must be called while holding the inode (which is cinfo) lock.
> + *
> + * Returns the head request if found, or NULL if not found.
> + */
> +static struct nfs_page *
> +nfs_page_search_commits_for_head_request_locked(struct nfs_inode *nfsi,
> +						struct page *page)
> +{
> +	struct nfs_page *freq, *t;
> +	struct nfs_commit_info cinfo;
> +	struct inode *inode = &nfsi->vfs_inode;
> +
> +	nfs_init_cinfo_from_inode(&cinfo, inode);
This has a compiler warning when CONFIG_NFS_V4=n, CONFIG_NFS_V3=n, CONFIG_NFS_V2=y:

fs/nfs/write.c: In function ‘nfs_page_find_head_request_locked.isra.16’:
include/linux/kernel.h:834:39: error: ‘cinfo.mds’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
  const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                                       ^
fs/nfs/write.c:110:25: note: ‘cinfo.mds’ was declared here
  struct nfs_commit_info cinfo;

Probably because nfs_init_cinfo_from_inode() is empty without v3 or v4.

Anna
> +
> +	/* search through pnfs commit lists */
> +	freq = pnfs_search_commit_reqs(inode, &cinfo, page);
> +	if (freq)
> +		return freq->wb_head;
> +
> +	/* Linearly search the commit list for the correct request */
> +	list_for_each_entry_safe(freq, t, &cinfo.mds->list, wb_list) {
> +		if (freq->wb_page == page)
> +			return freq->wb_head;
> +	}
> +
> +	return NULL;
> +}
> +
> +/*
>   * nfs_page_find_head_request_locked - find head request associated with @page
>   *
>   * must be called while holding the inode lock.
> @@ -106,21 +140,12 @@ nfs_page_find_head_request_locked(struct nfs_inode *nfsi, struct page *page)
>  
>  	if (PagePrivate(page))
>  		req = (struct nfs_page *)page_private(page);
> -	else if (unlikely(PageSwapCache(page))) {
> -		struct nfs_page *freq, *t;
> -
> -		/* Linearly search the commit list for the correct req */
> -		list_for_each_entry_safe(freq, t, &nfsi->commit_info.list, wb_list) {
> -			if (freq->wb_page == page) {
> -				req = freq->wb_head;
> -				break;
> -			}
> -		}
> -	}
> +	else if (unlikely(PageSwapCache(page)))
> +		req = nfs_page_search_commits_for_head_request_locked(nfsi,
> +			page);
>  
>  	if (req) {
>  		WARN_ON_ONCE(req->wb_head != req);
> -
>  		kref_get(&req->wb_kref);
>  	}
>  

