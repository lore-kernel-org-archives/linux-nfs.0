Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:15581 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751712AbdDJUWs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Apr 2017 16:22:48 -0400
Subject: Re: [PATCH] NFS: fix usage of mempools.
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <87wpatvw6m.fsf@notabene.neil.brown.name>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <586583e7-58d4-2386-aa71-f0a63ca93002@Netapp.com>
Date: Mon, 10 Apr 2017 16:22:39 -0400
MIME-Version: 1.0
In-Reply-To: <87wpatvw6m.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On 04/09/2017 10:22 PM, NeilBrown wrote:
> 
> When passed GFP flags that allow sleeping (such as
> GFP_NOIO), mempool_alloc() will never return NULL, it will
> wait until memory is available.
> 
> This means that we don't need to handle failure, but that we
> do need to ensure one thread doesn't call mempool_alloc()
> twice on the one pool without queuing or freeing the first
> allocation.  If multiple threads did this during times of
> high memory pressure, the pool could be exhausted and a
> deadlock could result.
> 
> pnfs_generic_alloc_ds_commits() attempts to allocate from
> the nfs_commit_mempool while already holding an allocation
> from that pool.  This is not safe.  So change
> nfs_commitdata_alloc() to take a flag that indicates whether
> failure is acceptable.
> 
> In pnfs_generic_alloc_ds_commits(), accept failure and
> handle it as we currently do.  Else where, do not accept
> failure, and do not handle it.
> 
> Even when failure is acceptable, we want to succeed if
> possible.  That means both
>  - using an entry from the pool if there is one
>  - waiting for direct reclaim is there isn't.
> 
> We call mempool_alloc(GFP_NOWAIT) to achieve the first, then
> kmem_cache_alloc(GFP_NOIO|__GFP_NORETRY) to achieve the
> second.  Each of these can fail, but together they do the
> best they can without blocking indefinitely.
> 
> Also, don't test for failure when allocating from
> nfs_wdata_mempool.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/pnfs_nfs.c      | 16 +++++-----------
>  fs/nfs/write.c         | 35 +++++++++++++++++++++--------------
>  include/linux/nfs_fs.h |  2 +-
>  3 files changed, 27 insertions(+), 26 deletions(-)
> 
> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
> index 7250b95549ec..1edf5b84aba5 100644
> --- a/fs/nfs/pnfs_nfs.c
> +++ b/fs/nfs/pnfs_nfs.c
> @@ -217,7 +217,7 @@ pnfs_generic_alloc_ds_commits(struct nfs_commit_info *cinfo,
>  	for (i = 0; i < fl_cinfo->nbuckets; i++, bucket++) {
>  		if (list_empty(&bucket->committing))
>  			continue;
> -		data = nfs_commitdata_alloc();
> +		data = nfs_commitdata_alloc(false);
>  		if (!data)
>  			break;
>  		data->ds_commit_index = i;
> @@ -283,16 +283,10 @@ pnfs_generic_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
>  	unsigned int nreq = 0;
>  
>  	if (!list_empty(mds_pages)) {
> -		data = nfs_commitdata_alloc();
> -		if (data != NULL) {
> -			data->ds_commit_index = -1;
> -			list_add(&data->pages, &list);
> -			nreq++;
> -		} else {
> -			nfs_retry_commit(mds_pages, NULL, cinfo, 0);
> -			pnfs_generic_retry_commit(cinfo, 0);
> -			return -ENOMEM;
> -		}
> +		data = nfs_commitdata_alloc(true);
> +		data->ds_commit_index = -1;
> +		list_add(&data->pages, &list);
> +		nreq++;
>  	}
>  
>  	nreq += pnfs_generic_alloc_ds_commits(cinfo, &list);
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index abb2c8a3be42..bdfe5a7c5874 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -60,14 +60,28 @@ static mempool_t *nfs_wdata_mempool;
>  static struct kmem_cache *nfs_cdata_cachep;
>  static mempool_t *nfs_commit_mempool;
>  
> -struct nfs_commit_data *nfs_commitdata_alloc(void)
> +struct nfs_commit_data *nfs_commitdata_alloc(bool never_fail)
>  {
> -	struct nfs_commit_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOIO);
> +	struct nfs_commit_data *p;
>  
> -	if (p) {
> -		memset(p, 0, sizeof(*p));
> -		INIT_LIST_HEAD(&p->pages);
> +	if (never_fail)
> +		p = mempool_alloc(nfs_commit_mempool, GFP_NOIO);
> +	else {
> +		/* It is OK to do some reclaim, not no safe to wait
> +		 * for anything to be returned to the pool.
> +		 * mempool_alloc() cannot handle that particular combination,
> +		 * so we need two separate attempts.
> +		 */
> +		p = mempool_alloc(nfs_commit_mempool, GFP_NOWAIT);
> +		if (!p)
> +			p = kmem_cache_alloc(nfs_cdata_cachep, GFP_NOIO |
> +					     __GFP_NOWARN | __GFP_NORETRY);

Do we need to add something to the nfs_commit_data structure to properly free a kmem_cache_alloc()-ed object?  Right now it looks like nfs_commit_free() calls mempool_free() unconditionally.

Thanks,
Anna

> +		if (!p)
> +			return NULL;
>  	}
> +
> +	memset(p, 0, sizeof(*p));
> +	INIT_LIST_HEAD(&p->pages);
>  	return p;
>  }
>  EXPORT_SYMBOL_GPL(nfs_commitdata_alloc);
> @@ -82,8 +96,7 @@ static struct nfs_pgio_header *nfs_writehdr_alloc(void)
>  {
>  	struct nfs_pgio_header *p = mempool_alloc(nfs_wdata_mempool, GFP_NOIO);
>  
> -	if (p)
> -		memset(p, 0, sizeof(*p));
> +	memset(p, 0, sizeof(*p));
>  	return p;
>  }
>  
> @@ -1705,19 +1718,13 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how,
>  	if (list_empty(head))
>  		return 0;
>  
> -	data = nfs_commitdata_alloc();
> -
> -	if (!data)
> -		goto out_bad;
> +	data = nfs_commitdata_alloc(true);
>  
>  	/* Set up the argument struct */
>  	nfs_init_commit(data, head, NULL, cinfo);
>  	atomic_inc(&cinfo->mds->rpcs_out);
>  	return nfs_initiate_commit(NFS_CLIENT(inode), data, NFS_PROTO(inode),
>  				   data->mds_ops, how, 0);
> - out_bad:
> -	nfs_retry_commit(head, NULL, cinfo, 0);
> -	return -ENOMEM;
>  }
>  
>  int nfs_commit_file(struct file *file, struct nfs_write_verifier *verf)
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 287f34161086..1b29915247b2 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -502,7 +502,7 @@ extern int nfs_wb_all(struct inode *inode);
>  extern int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder);
>  extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
>  extern int  nfs_commit_inode(struct inode *, int);
> -extern struct nfs_commit_data *nfs_commitdata_alloc(void);
> +extern struct nfs_commit_data *nfs_commitdata_alloc(bool never_fail);
>  extern void nfs_commit_free(struct nfs_commit_data *data);
>  
>  static inline int
> 
