Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:59879 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251AbaIIPCt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 11:02:49 -0400
Received: by mail-ie0-f177.google.com with SMTP id rd18so1100621iec.22
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 08:02:48 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFS: Fix a compile warning when !(CONFIG_NFS_V3 || CONFIG_NFS_V4)
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1410240419-43111-1-git-send-email-trond.myklebust@primarydata.com>
Date: Tue, 9 Sep 2014 11:02:43 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Message-Id: <3144C892-4461-4AD6-AB6B-352AC32490C7@primarydata.com>
References: <1410240419-43111-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Trond,

This looks good. Sorry for breaking the NFSv2 only case.

-dros



On Sep 9, 2014, at 1:26 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> gcc reports:
> 
> linux/fs/nfs/write.c: In function ‘nfs_page_find_head_request_locked.isra.17’:
> linux/fs/nfs/write.c:121:64: warning: ‘cinfo.mds’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>  list_for_each_entry_safe(freq, t, &cinfo.mds->list, wb_list) {
>                                                                  ^
> linux/fs/nfs/write.c:110:25: note: ‘cinfo.mds’ was declared here
>  struct nfs_commit_info cinfo;
> 
> Reported-by: Anna Schumaker <Anna.Schumaker@netapp.com>
> Cc: Weston Andros Adamson <dros@primarydata.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/write.c | 74 +++++++++++++++++++++++++++++++++-------------------------
> 1 file changed, 42 insertions(+), 32 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 3c5638f381cd..128d97f01d1c 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -49,6 +49,9 @@ static const struct nfs_rw_ops nfs_rw_write_ops;
> static void nfs_clear_request_commit(struct nfs_page *req);
> static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
> 				      struct inode *inode);
> +static struct nfs_page *
> +nfs_page_search_commits_for_head_request_locked(struct nfs_inode *nfsi,
> +						struct page *page);
> 
> static struct kmem_cache *nfs_wdata_cachep;
> static mempool_t *nfs_wdata_mempool;
> @@ -95,38 +98,6 @@ static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
> }
> 
> /*
> - * nfs_page_search_commits_for_head_request_locked
> - *
> - * Search through commit lists on @inode for the head request for @page.
> - * Must be called while holding the inode (which is cinfo) lock.
> - *
> - * Returns the head request if found, or NULL if not found.
> - */
> -static struct nfs_page *
> -nfs_page_search_commits_for_head_request_locked(struct nfs_inode *nfsi,
> -						struct page *page)
> -{
> -	struct nfs_page *freq, *t;
> -	struct nfs_commit_info cinfo;
> -	struct inode *inode = &nfsi->vfs_inode;
> -
> -	nfs_init_cinfo_from_inode(&cinfo, inode);
> -
> -	/* search through pnfs commit lists */
> -	freq = pnfs_search_commit_reqs(inode, &cinfo, page);
> -	if (freq)
> -		return freq->wb_head;
> -
> -	/* Linearly search the commit list for the correct request */
> -	list_for_each_entry_safe(freq, t, &cinfo.mds->list, wb_list) {
> -		if (freq->wb_page == page)
> -			return freq->wb_head;
> -	}
> -
> -	return NULL;
> -}
> -
> -/*
>  * nfs_page_find_head_request_locked - find head request associated with @page
>  *
>  * must be called while holding the inode lock.
> @@ -750,6 +721,38 @@ nfs_mark_request_dirty(struct nfs_page *req)
> }
> 
> #if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
> +/*
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
> /**
>  * nfs_request_add_commit_list - add request to a commit list
>  * @req: pointer to a struct nfs_page
> @@ -868,6 +871,13 @@ int nfs_write_need_commit(struct nfs_pgio_header *hdr)
> }
> 
> #else
> +static struct nfs_page *
> +nfs_page_search_commits_for_head_request_locked(struct nfs_inode *nfsi,
> +						struct page *page)
> +{
> +	return NULL;
> +}
> +
> static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
> 				      struct inode *inode)
> {
> -- 
> 1.9.3
> 

