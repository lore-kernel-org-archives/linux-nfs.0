Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:65192 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab1FHCag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 22:30:36 -0400
Received: by vws1 with SMTP id 1so47269vws.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2011 19:30:35 -0700 (PDT)
Message-ID: <4DEEDECF.4090104@panasas.com>
Date: Tue, 07 Jun 2011 22:30:39 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFS: Cleanup of the nfs_pageio code in preparation
 for a pnfs bugfix
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com> <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-06 18:32, Trond Myklebust wrote:
> We need to ensure that the layouts are set up before we can decide to
> coalesce requests. To do so, we want to further split up the struct
> nfs_pageio_descriptor operations into an initialisation callback, a
> coalescing test callback, and a 'do i/o' callback.
> 
> This patch cleans up the existing callback methods before adding the
> 'initialisation' callback.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c      |   15 +++++++++++++--
>  fs/nfs/objlayout/objio_osd.c |   13 ++++++++++++-
>  fs/nfs/pagelist.c            |   12 +++++-------
>  fs/nfs/pnfs.h                |   29 ++++++++++++++++++++++-------
>  fs/nfs/read.c                |   42 +++++++++++++++++++++++++++++++-----------
>  fs/nfs/write.c               |   27 +++++++++++++++++++++++----
>  include/linux/nfs_page.h     |   17 ++++++++++++++---
>  7 files changed, 120 insertions(+), 35 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 4269088..e9b9b82 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -654,7 +654,7 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
>   * return true  : coalesce page
>   * return false : don't coalesce page
>   */
> -bool
> +static bool
>  filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>  		   struct nfs_page *req)
>  {
> @@ -676,6 +676,16 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>  	return (p_stripe == r_stripe);
>  }
>  
> +static const struct nfs_pageio_ops filelayout_pg_read_ops = {
> +	.pg_test = filelayout_pg_test,
> +	.pg_doio = nfs_generic_pg_readpages,
> +};
> +
> +static const struct nfs_pageio_ops filelayout_pg_write_ops = {
> +	.pg_test = filelayout_pg_test,
> +	.pg_doio = nfs_generic_pg_writepages,
> +};
> +
>  static bool filelayout_mark_pnfs_commit(struct pnfs_layout_segment *lseg)
>  {
>  	return !FILELAYOUT_LSEG(lseg)->commit_through_mds;
> @@ -873,7 +883,8 @@ static struct pnfs_layoutdriver_type filelayout_type = {
>  	.owner			= THIS_MODULE,
>  	.alloc_lseg		= filelayout_alloc_lseg,
>  	.free_lseg		= filelayout_free_lseg,
> -	.pg_test		= filelayout_pg_test,
> +	.pg_read_ops		= &filelayout_pg_read_ops,
> +	.pg_write_ops		= &filelayout_pg_write_ops,
>  	.mark_pnfs_commit	= filelayout_mark_pnfs_commit,
>  	.choose_commit_list	= filelayout_choose_commit_list,
>  	.commit_pagelist	= filelayout_commit_pagelist,
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index 4c41a60..31088f3 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -1008,6 +1008,16 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
>  			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
>  }
>  
> +static const struct nfs_pageio_ops objio_pg_read_ops = {
> +	.pg_test = objio_pg_test,
> +	.pg_doio = nfs_generic_pg_readpages,
> +};
> +
> +static const struct nfs_pageio_ops objio_pg_write_ops = {
> +	.pg_test = objio_pg_test,
> +	.pg_doio = nfs_generic_pg_writepages,

Hmm, for the non-files layouts we should ignore the server's wsize
for pnfs I/O.

How about using the follwing?

int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
{
	return desc->pg_lseg ? nfs_pagein_one(desc) : nfs_generic_pg_readpages(desc);
}
EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);

int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
{
	return desc->pg_lseg ? nfs_flush_one(desc) : nfs_generic_pg_writepages(desc);
}
EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);

Benny

> +};
> +
>  static struct pnfs_layoutdriver_type objlayout_type = {
>  	.id = LAYOUT_OSD2_OBJECTS,
>  	.name = "LAYOUT_OSD2_OBJECTS",
> @@ -1021,7 +1031,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
>  
>  	.read_pagelist           = objlayout_read_pagelist,
>  	.write_pagelist          = objlayout_write_pagelist,
> -	.pg_test                 = objio_pg_test,
> +	.pg_read_ops             = &objio_pg_read_ops,
> +	.pg_write_ops            = &objio_pg_write_ops,
>  
>  	.free_deviceid_node	 = objio_free_deviceid_node,
>  
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 7913961..2b71ad0 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -204,7 +204,7 @@ nfs_wait_on_request(struct nfs_page *req)
>  			TASK_UNINTERRUPTIBLE);
>  }
>  
> -static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
> +bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
>  {
>  	/*
>  	 * FIXME: ideally we should be able to coalesce all requests
> @@ -229,7 +229,7 @@ static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_p
>   */
>  void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>  		     struct inode *inode,
> -		     int (*doio)(struct nfs_pageio_descriptor *),
> +		     const struct nfs_pageio_ops *pg_ops,
>  		     size_t bsize,
>  		     int io_flags)
>  {
> @@ -240,12 +240,10 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>  	desc->pg_base = 0;
>  	desc->pg_moreio = 0;
>  	desc->pg_inode = inode;
> -	desc->pg_doio = doio;
> +	desc->pg_ops = pg_ops;
>  	desc->pg_ioflags = io_flags;
>  	desc->pg_error = 0;
>  	desc->pg_lseg = NULL;
> -	desc->pg_test = nfs_generic_pg_test;
> -	pnfs_pageio_init(desc, inode);
>  }
>  
>  /**
> @@ -275,7 +273,7 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
>  		return false;
>  	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
>  		return false;
> -	return pgio->pg_test(pgio, prev, req);
> +	return pgio->pg_ops->pg_test(pgio, prev, req);
>  }
>  
>  /**
> @@ -310,7 +308,7 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
>  static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
>  {
>  	if (!list_empty(&desc->pg_list)) {
> -		int error = desc->pg_doio(desc);
> +		int error = desc->pg_ops->pg_doio(desc);
>  		if (error < 0)
>  			desc->pg_error = error;
>  		else
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 48d0a8e..8d063c0 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -87,7 +87,8 @@ struct pnfs_layoutdriver_type {
>  	void (*free_lseg) (struct pnfs_layout_segment *lseg);
>  
>  	/* test for nfs page cache coalescing */
> -	bool (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
> +	const struct nfs_pageio_ops *pg_read_ops;
> +	const struct nfs_pageio_ops *pg_write_ops;
>  
>  	/* Returns true if layoutdriver wants to divert this request to
>  	 * driver's commit routine.
> @@ -292,13 +293,22 @@ static inline int pnfs_return_layout(struct inode *ino)
>  	return 0;
>  }
>  
> -static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio,
> -				    struct inode *inode)
> +static inline const struct nfs_pageio_ops *pnfs_get_read_ops(struct inode *inode)
>  {
>  	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
>  
> -	if (ld)
> -		pgio->pg_test = ld->pg_test;
> +	if (!ld)
> +		return NULL;
> +	return ld->pg_read_ops;
> +}
> +
> +static inline const struct nfs_pageio_ops *pnfs_get_write_ops(struct inode *inode)
> +{
> +	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
> +
> +	if (!ld)
> +		return NULL;
> +	return ld->pg_write_ops;
>  }
>  
>  #else  /* CONFIG_NFS_V4_1 */
> @@ -384,9 +394,14 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
>  {
>  }
>  
> -static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio,
> -				    struct inode *inode)
> +static inline const struct nfs_pageio_ops *pnfs_get_read_ops(struct inode *inode)
>  {
> +	return NULL;
> +}
> +
> +static inline const struct nfs_pageio_ops *pnfs_get_write_ops(struct inode *inode)
> +{
> +	return NULL;
>  }
>  
>  static inline void
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 20a7f95..b0f5c19 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -32,6 +32,7 @@
>  
>  static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc);
>  static int nfs_pagein_one(struct nfs_pageio_descriptor *desc);
> +static const struct nfs_pageio_ops nfs_pageio_read_ops;
>  static const struct rpc_call_ops nfs_read_partial_ops;
>  static const struct rpc_call_ops nfs_read_full_ops;
>  
> @@ -113,6 +114,19 @@ static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
>  	}
>  }
>  
> +static void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
> +		struct inode *inode)
> +{
> +	size_t rsize = NFS_SERVER(inode)->rsize;
> +	const struct nfs_pageio_ops *ops;
> +
> +	ops = pnfs_get_read_ops(inode);
> +	if (ops == NULL)
> +		ops = &nfs_pageio_read_ops;
> +
> +	nfs_pageio_init(pgio, inode, ops, rsize, 0);
> +}
> +
>  int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>  		       struct page *page)
>  {
> @@ -131,14 +145,11 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>  	if (len < PAGE_CACHE_SIZE)
>  		zero_user_segment(page, len, PAGE_CACHE_SIZE);
>  
> -	nfs_pageio_init(&pgio, inode, NULL, 0, 0);
> +	nfs_pageio_init_read(&pgio, inode);
>  	nfs_list_add_request(new, &pgio.pg_list);
>  	pgio.pg_count = len;
>  
> -	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
> -		nfs_pagein_multi(&pgio);
> -	else
> -		nfs_pagein_one(&pgio);
> +	nfs_pageio_complete(&pgio);
>  	return 0;
>  }
>  
> @@ -365,6 +376,20 @@ out:
>  	return ret;
>  }
>  
> +int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
> +{
> +	if (desc->pg_bsize < PAGE_CACHE_SIZE)
> +		return nfs_pagein_multi(desc);
> +	return nfs_pagein_one(desc);
> +}
> +EXPORT_SYMBOL_GPL(nfs_generic_pg_readpages);
> +
> +
> +static const struct nfs_pageio_ops nfs_pageio_read_ops = {
> +	.pg_test = nfs_generic_pg_test,
> +	.pg_doio = nfs_generic_pg_readpages,
> +};
> +
>  /*
>   * This is the callback from RPC telling us whether a reply was
>   * received or some error occurred (timeout or socket shutdown).
> @@ -635,8 +660,6 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
>  		.pgio = &pgio,
>  	};
>  	struct inode *inode = mapping->host;
> -	struct nfs_server *server = NFS_SERVER(inode);
> -	size_t rsize = server->rsize;
>  	unsigned long npages;
>  	int ret = -ESTALE;
>  
> @@ -664,10 +687,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
>  	if (ret == 0)
>  		goto read_complete; /* all pages were read */
>  
> -	if (rsize < PAGE_CACHE_SIZE)
> -		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
> -	else
> -		nfs_pageio_init(&pgio, inode, nfs_pagein_one, rsize, 0);
> +	nfs_pageio_init_read(&pgio, inode);
>  
>  	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index e268e3b..c379c86 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -977,6 +977,11 @@ out_bad:
>  	return -ENOMEM;
>  }
>  
> +static const struct nfs_pageio_ops nfs_flush_multi_ops = {
> +	.pg_test = nfs_generic_pg_test,
> +	.pg_doio = nfs_flush_multi,
> +};
> +
>  /*
>   * Create an RPC task for the given write request and kick it.
>   * The page must have been locked by the caller.
> @@ -1031,15 +1036,29 @@ out:
>  	return ret;
>  }
>  
> +int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
> +{
> +	if (desc->pg_bsize < PAGE_CACHE_SIZE)
> +		return nfs_flush_multi(desc);
> +	return nfs_flush_one(desc);
> +}
> +EXPORT_SYMBOL_GPL(nfs_generic_pg_writepages);
> +
> +static const struct nfs_pageio_ops nfs_pageio_write_ops = {
> +	.pg_test = nfs_generic_pg_test,
> +	.pg_doio = nfs_generic_pg_writepages,
> +};
> +
>  static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
>  				  struct inode *inode, int ioflags)
>  {
>  	size_t wsize = NFS_SERVER(inode)->wsize;
> +	const struct nfs_pageio_ops *ops;
> +	ops = pnfs_get_write_ops(inode);
> +	if (ops == NULL)
> +		ops = &nfs_pageio_write_ops;
>  
> -	if (wsize < PAGE_CACHE_SIZE)
> -		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
> -	else
> -		nfs_pageio_init(pgio, inode, nfs_flush_one, wsize, ioflags);
> +	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops, wsize, ioflags);
>  }
>  
>  /*
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index 3a34e80..b0e26c0 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -55,6 +55,12 @@ struct nfs_page {
>  	struct nfs_writeverf	wb_verf;	/* Commit cookie */
>  };
>  
> +struct nfs_pageio_descriptor;
> +struct nfs_pageio_ops {
> +	bool	(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
> +	int	(*pg_doio)(struct nfs_pageio_descriptor *);
> +};
> +
>  struct nfs_pageio_descriptor {
>  	struct list_head	pg_list;
>  	unsigned long		pg_bytes_written;
> @@ -64,11 +70,10 @@ struct nfs_pageio_descriptor {
>  	char			pg_moreio;
>  
>  	struct inode		*pg_inode;
> -	int			(*pg_doio)(struct nfs_pageio_descriptor *);
> +	const struct nfs_pageio_ops *pg_ops;
>  	int 			pg_ioflags;
>  	int			pg_error;
>  	struct pnfs_layout_segment *pg_lseg;
> -	bool			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
>  };
>  
>  #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
> @@ -85,18 +90,24 @@ extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *dst,
>  			  pgoff_t idx_start, unsigned int npages, int tag);
>  extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>  			     struct inode *inode,
> -			     int (*doio)(struct nfs_pageio_descriptor *desc),
> +			     const struct nfs_pageio_ops *pg_ops,
>  			     size_t bsize,
>  			     int how);
>  extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
>  				   struct nfs_page *);
>  extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
>  extern	void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *, pgoff_t);
> +extern	bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
> +				 struct nfs_page *prev,
> +				 struct nfs_page *req);
>  extern  int nfs_wait_on_request(struct nfs_page *);
>  extern	void nfs_unlock_request(struct nfs_page *req);
>  extern	int nfs_set_page_tag_locked(struct nfs_page *req);
>  extern  void nfs_clear_page_tag_locked(struct nfs_page *req);
>  
> +extern	int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
> +extern	int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
> +
>  
>  /*
>   * Lock the page of an asynchronous request without getting a new reference
