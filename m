Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45197 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab1CJH6M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 02:58:12 -0500
Message-ID: <4D78848E.1050902@panasas.com>
Date: Wed, 09 Mar 2011 23:58:06 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 8/9] NFSv4.1: rearrange ->doio args
References: <1299165229-3148-1-git-send-email-iisaman@netapp.com> <1299165229-3148-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1299165229-3148-9-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-03 07:13, Fred Isaman wrote:
> This will make it possible to clear the lseg pointer in the same
> function as it is put, instead of in the caller nfs_pageio_doio().

so much better this way :)
I'm glad we discussed this in the Connectathon!

Benny

> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/pagelist.c        |   10 ++--------
>  fs/nfs/read.c            |   42 +++++++++++++++++++++++++-----------------
>  fs/nfs/write.c           |   28 ++++++++++++++++------------
>  include/linux/nfs_page.h |    4 ++--
>  4 files changed, 45 insertions(+), 39 deletions(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 45b0fb8..9f62874 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -214,7 +214,7 @@ nfs_wait_on_request(struct nfs_page *req)
>   */
>  void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>  		     struct inode *inode,
> -		     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
> +		     int (*doio)(struct nfs_pageio_descriptor *),
>  		     size_t bsize,
>  		     int io_flags)
>  {
> @@ -311,13 +311,7 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
>  static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
>  {
>  	if (!list_empty(&desc->pg_list)) {
> -		int error = desc->pg_doio(desc->pg_inode,
> -					  &desc->pg_list,
> -					  nfs_page_array_len(desc->pg_base,
> -							     desc->pg_count),
> -					  desc->pg_count,
> -					  desc->pg_ioflags,
> -					  desc->pg_lseg);
> +		int error = desc->pg_doio(desc);
>  		desc->pg_lseg = NULL;
>  		if (error < 0)
>  			desc->pg_error = error;
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index f40c7f4..ab9c776 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -31,8 +31,8 @@
>  
>  #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
>  
> -static int nfs_pagein_multi(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
> -static int nfs_pagein_one(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
> +static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc);
> +static int nfs_pagein_one(struct nfs_pageio_descriptor *desc);
>  static const struct rpc_call_ops nfs_read_partial_ops;
>  static const struct rpc_call_ops nfs_read_full_ops;
>  
> @@ -117,9 +117,9 @@ static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
>  int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>  		       struct page *page)
>  {
> -	LIST_HEAD(one_request);
>  	struct nfs_page	*new;
>  	unsigned int len;
> +	struct nfs_pageio_descriptor pgio;
>  
>  	len = nfs_page_length(page);
>  	if (len == 0)
> @@ -132,11 +132,14 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>  	if (len < PAGE_CACHE_SIZE)
>  		zero_user_segment(page, len, PAGE_CACHE_SIZE);
>  
> -	nfs_list_add_request(new, &one_request);
> +	nfs_pageio_init(&pgio, inode, NULL, 0, 0);
> +	nfs_list_add_request(new, &pgio.pg_list);
> +	pgio.pg_count = len;
> +
>  	if (NFS_SERVER(inode)->rsize < PAGE_CACHE_SIZE)
> -		nfs_pagein_multi(inode, &one_request, 1, len, 0, NULL);
> +		nfs_pagein_multi(&pgio);
>  	else
> -		nfs_pagein_one(inode, &one_request, 1, len, 0, NULL);
> +		nfs_pagein_one(&pgio);
>  	return 0;
>  }
>  
> @@ -258,20 +261,21 @@ nfs_async_read_error(struct list_head *head)
>   * won't see the new data until our attribute cache is updated.  This is more
>   * or less conventional NFS client behavior.
>   */
> -static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
> +static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
>  {
> -	struct nfs_page *req = nfs_list_entry(head->next);
> +	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
>  	struct page *page = req->wb_page;
>  	struct nfs_read_data *data;
> -	size_t rsize = NFS_SERVER(inode)->rsize, nbytes;
> +	size_t rsize = NFS_SERVER(desc->pg_inode)->rsize, nbytes;
>  	unsigned int offset;
>  	int requests = 0;
>  	int ret = 0;
> +	struct pnfs_layout_segment *lseg;
>  	LIST_HEAD(list);
>  
>  	nfs_list_remove_request(req);
>  
> -	nbytes = count;
> +	nbytes = desc->pg_count;
>  	do {
>  		size_t len = min(nbytes,rsize);
>  
> @@ -284,11 +288,11 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
>  	} while(nbytes != 0);
>  	atomic_set(&req->wb_complete, requests);
>  
> -	/* We know lseg==NULL */
> -	lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_READ);
> +	BUG_ON(desc->pg_lseg != NULL);
> +	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ);
>  	ClearPageError(page);
>  	offset = 0;
> -	nbytes = count;
> +	nbytes = desc->pg_count;
>  	do {
>  		int ret2;
>  
> @@ -321,14 +325,17 @@ out_bad:
>  	return -ENOMEM;
>  }
>  
> -static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags, struct pnfs_layout_segment *lseg)
> +static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
>  {
>  	struct nfs_page		*req;
>  	struct page		**pages;
>  	struct nfs_read_data	*data;
> +	struct list_head *head = &desc->pg_list;
> +	struct pnfs_layout_segment *lseg = desc->pg_lseg;
>  	int ret = -ENOMEM;
>  
> -	data = nfs_readdata_alloc(npages);
> +	data = nfs_readdata_alloc(nfs_page_array_len(desc->pg_base,
> +						     desc->pg_count));
>  	if (!data) {
>  		nfs_async_read_error(head);
>  		goto out;
> @@ -344,9 +351,10 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
>  	}
>  	req = nfs_list_entry(data->pages.next);
>  	if ((!lseg) && list_is_singular(&data->pages))
> -		lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_READ);
> +		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ);
>  
> -	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0, lseg);
> +	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, desc->pg_count,
> +				0, lseg);
>  out:
>  	put_lseg(lseg);
>  	return ret;
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 06a1f3f..ccc7c22 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -898,20 +898,21 @@ static void nfs_redirty_request(struct nfs_page *req)
>   * Generate multiple small requests to write out a single
>   * contiguous dirty area on one page.
>   */
> -static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how, struct pnfs_layout_segment *lseg)
> +static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
>  {
> -	struct nfs_page *req = nfs_list_entry(head->next);
> +	struct nfs_page *req = nfs_list_entry(desc->pg_list.next);
>  	struct page *page = req->wb_page;
>  	struct nfs_write_data *data;
> -	size_t wsize = NFS_SERVER(inode)->wsize, nbytes;
> +	size_t wsize = NFS_SERVER(desc->pg_inode)->wsize, nbytes;
>  	unsigned int offset;
>  	int requests = 0;
>  	int ret = 0;
> +	struct pnfs_layout_segment *lseg;
>  	LIST_HEAD(list);
>  
>  	nfs_list_remove_request(req);
>  
> -	nbytes = count;
> +	nbytes = desc->pg_count;
>  	do {
>  		size_t len = min(nbytes, wsize);
>  
> @@ -924,11 +925,11 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
>  	} while (nbytes != 0);
>  	atomic_set(&req->wb_complete, requests);
>  
> -	BUG_ON(lseg);
> -	lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_RW);
> +	BUG_ON(desc->pg_lseg);
> +	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW);
>  	ClearPageError(page);
>  	offset = 0;
> -	nbytes = count;
> +	nbytes = desc->pg_count;
>  	do {
>  		int ret2;
>  
> @@ -940,7 +941,7 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
>  		if (nbytes < wsize)
>  			wsize = nbytes;
>  		ret2 = nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
> -					  wsize, offset, lseg, how);
> +					  wsize, offset, lseg, desc->pg_ioflags);
>  		if (ret == 0)
>  			ret = ret2;
>  		offset += wsize;
> @@ -968,14 +969,17 @@ out_bad:
>   * This is the case if nfs_updatepage detects a conflicting request
>   * that has been written but not committed.
>   */
> -static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int how, struct pnfs_layout_segment *lseg)
> +static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
>  {
>  	struct nfs_page		*req;
>  	struct page		**pages;
>  	struct nfs_write_data	*data;
> +	struct list_head *head = &desc->pg_list;
> +	struct pnfs_layout_segment *lseg = desc->pg_lseg;
>  	int ret;
>  
> -	data = nfs_writedata_alloc(npages);
> +	data = nfs_writedata_alloc(nfs_page_array_len(desc->pg_base,
> +						      desc->pg_count));
>  	if (!data) {
>  		while (!list_empty(head)) {
>  			req = nfs_list_entry(head->next);
> @@ -995,10 +999,10 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
>  	}
>  	req = nfs_list_entry(data->pages.next);
>  	if ((!lseg) && list_is_singular(&data->pages))
> -		lseg = pnfs_update_layout(inode, req->wb_context, IOMODE_RW);
> +		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW);
>  
>  	/* Set up the argument struct */
> -	ret = nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, lseg, how);
> +	ret = nfs_write_rpcsetup(req, data, &nfs_write_full_ops, desc->pg_count, 0, lseg, desc->pg_ioflags);
>  out:
>  	put_lseg(lseg); /* Cleans any gotten in ->pg_test */
>  	return ret;
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index ba88ff4..90907ad 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -59,7 +59,7 @@ struct nfs_pageio_descriptor {
>  	unsigned int		pg_base;
>  
>  	struct inode		*pg_inode;
> -	int			(*pg_doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *);
> +	int			(*pg_doio)(struct nfs_pageio_descriptor *);
>  	int 			pg_ioflags;
>  	int			pg_error;
>  	struct pnfs_layout_segment *pg_lseg;
> @@ -81,7 +81,7 @@ extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *dst,
>  			  pgoff_t idx_start, unsigned int npages, int tag);
>  extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>  			     struct inode *inode,
> -			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int, struct pnfs_layout_segment *),
> +			     int (*doio)(struct nfs_pageio_descriptor *desc),
>  			     size_t bsize,
>  			     int how);
>  extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
