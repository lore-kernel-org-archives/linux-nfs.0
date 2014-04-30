Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:30001 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759198AbaD3QWW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2014 12:22:22 -0400
Message-ID: <5361233A.9030109@netapp.com>
Date: Wed, 30 Apr 2014 12:22:18 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>
CC: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>, <hch@infradead.org>
Subject: Re: [PATCH v2 13/17] NFS: Create a generic_pgio function
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com> <1398459360-2093-14-git-send-email-Anna.Schumaker@Netapp.com> <C5086131-3247-461B-B4E1-EC7B5E042B8B@primarydata.com>
In-Reply-To: <C5086131-3247-461B-B4E1-EC7B5E042B8B@primarydata.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/30/2014 12:13 PM, Weston Andros Adamson wrote:
> On Apr 25, 2014, at 4:55 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
>> From: Anna Schumaker <Anna.Schumaker@netapp.com>
>>
>> These functions are almost identical on both the read and write side.
>> FLUSH_COND_STABLE will never be set for the read path, so leaving it in
>> the generic code won't hurt anything.
>>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>> ---
>> fs/nfs/internal.h |  10 +----
>> fs/nfs/pageio.c   | 108 +++++++++++++++++++++++++++++++++++++++++++++++++++---
>> fs/nfs/pnfs.c     |   4 +-
>> fs/nfs/read.c     |  81 +---------------------------------------
>> fs/nfs/write.c    |  97 +-----------------------------------------------
>> 5 files changed, 108 insertions(+), 192 deletions(-)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 383175e..6422b9d 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -396,14 +396,10 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool
>> struct nfs_pgio_completion_ops;
>>
>> /* pageio.c */
>> -extern const struct rpc_call_ops nfs_pgio_common_ops;
>> extern struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
>> extern void nfs_rw_header_free(struct nfs_pgio_header *);
>> -extern struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsigned int);
>> extern void nfs_pgio_data_release(struct nfs_pgio_data *);
>> -extern int nfs_pgio_error(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
>> -extern void nfs_pgio_rpcsetup(struct nfs_pgio_data *, unsigned int,
>> -			      unsigned int, int, struct nfs_commit_info *);
>> +extern int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
>>
>> /* read.c */
>> extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
>> @@ -413,8 +409,6 @@ extern int nfs_initiate_read(struct rpc_clnt *clnt,
>> 			     struct nfs_pgio_data *data,
>> 			     const struct rpc_call_ops *call_ops, int flags);
>> extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
>> -extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
>> -			      struct nfs_pgio_header *hdr);
>> extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
>>
>> /* super.c */
>> @@ -432,8 +426,6 @@ int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
>> extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
>> 			struct inode *inode, int ioflags, bool force_mds,
>> 			const struct nfs_pgio_completion_ops *compl_ops);
>> -extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
>> -			     struct nfs_pgio_header *hdr);
>> extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
>> extern void nfs_commit_free(struct nfs_commit_data *p);
>> extern int nfs_initiate_write(struct rpc_clnt *clnt,
>> diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
>> index ff8a702..70598a7 100644
>> --- a/fs/nfs/pageio.c
>> +++ b/fs/nfs/pageio.c
>> @@ -13,6 +13,9 @@
>>
>> #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
>>
>> +static const struct rpc_call_ops nfs_pgio_common_ops;
>> +
>> +
>> static inline struct nfs_rw_header *NFS_RW_HEADER(struct nfs_pgio_header *hdr)
>> {
>> 	return container_of(hdr, struct nfs_rw_header, header);
>> @@ -41,8 +44,8 @@ void nfs_rw_header_free(struct nfs_pgio_header *hdr)
>> }
>> EXPORT_SYMBOL_GPL(nfs_rw_header_free);
>>
>> -struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *hdr,
>> -					  unsigned int pagecount)
>> +static struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *hdr,
>> +						 unsigned int pagecount)
>> {
>> 	struct nfs_pgio_data *data, *prealloc;
>>
>> @@ -87,7 +90,7 @@ void nfs_pgio_data_release(struct nfs_pgio_data *data)
>> }
>> EXPORT_SYMBOL_GPL(nfs_pgio_data_release);
>>
>> -void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
>> +static void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
>> 			      unsigned int count, unsigned int offset,
>> 			      int how, struct nfs_commit_info *cinfo)
>> {
>> @@ -123,7 +126,7 @@ void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
>> 	nfs_fattr_init(&data->fattr);
>> }
>>
>> -int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
>> +static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
>> 			  struct nfs_pgio_header *hdr)
>> {
>> 	struct nfs_pgio_data *data;
>> @@ -138,6 +141,101 @@ int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
>> 	return -ENOMEM;
>> }
>>
>> +/*
>> + * Generate multiple small requests to read or write a single
>> + * contiguous dirty on one page.
>> + */
>> +static int nfs_pgio_multi(struct nfs_pageio_descriptor *desc,
>> +			  struct nfs_pgio_header *hdr)
>> +{
>> +	struct nfs_page *req = hdr->req;
>> +	struct page *page = req->wb_page;
>> +	struct nfs_pgio_data *data;
>> +	size_t wsize = desc->pg_bsize, nbytes;
>> +	unsigned int offset;
>> +	int requests = 0;
>> +	struct nfs_commit_info cinfo;
>> +
>> +	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
>> +
>> +	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
>> +	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo) ||
>> +	     desc->pg_count > wsize))
>> +		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
>> +
>> +	offset = 0;
>> +	nbytes = desc->pg_count;
>> +	do {
>> +		size_t len = min(nbytes, wsize);
>> +
>> +		data = nfs_pgio_data_alloc(hdr, 1);
>> +		if (!data)
>> +			return nfs_pgio_error(desc, hdr);
>> +		data->pages.pagevec[0] = page;
>> +		nfs_pgio_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
>> +		list_add(&data->list, &hdr->rpc_list);
>> +		requests++;
>> +		nbytes -= len;
>> +		offset += len;
>> +	} while (nbytes != 0);
>> +
>> +	nfs_list_remove_request(req);
>> +	nfs_list_add_request(req, &hdr->pages);
>> +	desc->pg_rpc_callops = &nfs_pgio_common_ops;
>> +	return 0;
>> +}
>> +
>> +/*
>> + * Create an RPC task for the given write request and kick it.
> 
> really minor comment nit:
> 
> ^ should be read/write request
> 

Agreed, I'll fix that!

Anna

> -dros
> 
>> + * The page must have been locked by the caller.
>> + *
>> + * It may happen that the page we're passed is not marked dirty.
>> + * This is the case if nfs_updatepage detects a conflicting request
>> + * that has been written but not committed.
>> + */
>> +static int nfs_pgio_one(struct nfs_pageio_descriptor *desc,
>> +			struct nfs_pgio_header *hdr)
>> +{
>> +	struct nfs_page		*req;
>> +	struct page		**pages;
>> +	struct nfs_pgio_data	*data;
>> +	struct list_head *head = &desc->pg_list;
>> +	struct nfs_commit_info cinfo;
>> +
>> +	data = nfs_pgio_data_alloc(hdr, nfs_page_array_len(desc->pg_base,
>> +							   desc->pg_count));
>> +	if (!data)
>> +		return nfs_pgio_error(desc, hdr);
>> +
>> +	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
>> +	pages = data->pages.pagevec;
>> +	while (!list_empty(head)) {
>> +		req = nfs_list_entry(head->next);
>> +		nfs_list_remove_request(req);
>> +		nfs_list_add_request(req, &hdr->pages);
>> +		*pages++ = req->wb_page;
>> +	}
>> +
>> +	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
>> +	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo)))
>> +		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
>> +
>> +	/* Set up the argument struct */
>> +	nfs_pgio_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
>> +	list_add(&data->list, &hdr->rpc_list);
>> +	desc->pg_rpc_callops = &nfs_pgio_common_ops;
>> +	return 0;
>> +}
>> +
>> +int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
>> +		     struct nfs_pgio_header *hdr)
>> +{
>> +	if (desc->pg_bsize < PAGE_CACHE_SIZE)
>> +		return nfs_pgio_multi(desc, hdr);
>> +	return nfs_pgio_one(desc, hdr);
>> +}
>> +EXPORT_SYMBOL_GPL(nfs_generic_pgio);
>> +
>> static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
>> {
>> 	struct nfs_pgio_data *data = calldata;
>> @@ -177,7 +275,7 @@ static void nfs_pgio_result_common(struct rpc_task *task, void *calldata)
>> 		data->header->rw_ops->rw_result_common(task, data);
>> }
>>
>> -const struct rpc_call_ops nfs_pgio_common_ops = {
>> +static const struct rpc_call_ops nfs_pgio_common_ops = {
>> 	.rpc_call_prepare = nfs_pgio_prepare,
>> 	.rpc_call_done = nfs_pgio_result_common,
>> 	.rpc_release = nfs_pgio_release_common,
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 54c84c1..0fe6701 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1607,7 +1607,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>> 	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
>> 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
>> 	atomic_inc(&hdr->refcnt);
>> -	ret = nfs_generic_flush(desc, hdr);
>> +	ret = nfs_generic_pgio(desc, hdr);
>> 	if (ret != 0) {
>> 		pnfs_put_lseg(desc->pg_lseg);
>> 		desc->pg_lseg = NULL;
>> @@ -1766,7 +1766,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
>> 	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
>> 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
>> 	atomic_inc(&hdr->refcnt);
>> -	ret = nfs_generic_pagein(desc, hdr);
>> +	ret = nfs_generic_pgio(desc, hdr);
>> 	if (ret != 0) {
>> 		pnfs_put_lseg(desc->pg_lseg);
>> 		desc->pg_lseg = NULL;
>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> index c623671..07c21bd 100644
>> --- a/fs/nfs/read.c
>> +++ b/fs/nfs/read.c
>> @@ -237,85 +237,6 @@ static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops = {
>> 	.completion = nfs_read_completion,
>> };
>>
>> -/*
>> - * Generate multiple requests to fill a single page.
>> - *
>> - * We optimize to reduce the number of read operations on the wire.  If we
>> - * detect that we're reading a page, or an area of a page, that is past the
>> - * end of file, we do not generate NFS read operations but just clear the
>> - * parts of the page that would have come back zero from the server anyway.
>> - *
>> - * We rely on the cached value of i_size to make this determination; another
>> - * client can fill pages on the server past our cached end-of-file, but we
>> - * won't see the new data until our attribute cache is updated.  This is more
>> - * or less conventional NFS client behavior.
>> - */
>> -static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
>> -			    struct nfs_pgio_header *hdr)
>> -{
>> -	struct nfs_page *req = hdr->req;
>> -	struct page *page = req->wb_page;
>> -	struct nfs_pgio_data *data;
>> -	size_t rsize = desc->pg_bsize, nbytes;
>> -	unsigned int offset;
>> -
>> -	offset = 0;
>> -	nbytes = desc->pg_count;
>> -	do {
>> -		size_t len = min(nbytes,rsize);
>> -
>> -		data = nfs_pgio_data_alloc(hdr, 1);
>> -		if (!data)
>> -			return nfs_pgio_error(desc, hdr);
>> -		data->pages.pagevec[0] = page;
>> -		nfs_pgio_rpcsetup(data, len, offset, 0, NULL);
>> -		list_add(&data->list, &hdr->rpc_list);
>> -		nbytes -= len;
>> -		offset += len;
>> -	} while (nbytes != 0);
>> -
>> -	nfs_list_remove_request(req);
>> -	nfs_list_add_request(req, &hdr->pages);
>> -	desc->pg_rpc_callops = &nfs_pgio_common_ops;
>> -	return 0;
>> -}
>> -
>> -static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
>> -			  struct nfs_pgio_header *hdr)
>> -{
>> -	struct nfs_page		*req;
>> -	struct page		**pages;
>> -	struct nfs_pgio_data	*data;
>> -	struct list_head *head = &desc->pg_list;
>> -
>> -	data = nfs_pgio_data_alloc(hdr, nfs_page_array_len(desc->pg_base,
>> -							  desc->pg_count));
>> -	if (!data)
>> -		return nfs_pgio_error(desc, hdr);
>> -
>> -	pages = data->pages.pagevec;
>> -	while (!list_empty(head)) {
>> -		req = nfs_list_entry(head->next);
>> -		nfs_list_remove_request(req);
>> -		nfs_list_add_request(req, &hdr->pages);
>> -		*pages++ = req->wb_page;
>> -	}
>> -
>> -	nfs_pgio_rpcsetup(data, desc->pg_count, 0, 0, NULL);
>> -	list_add(&data->list, &hdr->rpc_list);
>> -	desc->pg_rpc_callops = &nfs_pgio_common_ops;
>> -	return 0;
>> -}
>> -
>> -int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
>> -		       struct nfs_pgio_header *hdr)
>> -{
>> -	if (desc->pg_bsize < PAGE_CACHE_SIZE)
>> -		return nfs_pagein_multi(desc, hdr);
>> -	return nfs_pagein_one(desc, hdr);
>> -}
>> -EXPORT_SYMBOL_GPL(nfs_generic_pagein);
>> -
>> static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
>> {
>> 	struct nfs_rw_header *rhdr;
>> @@ -330,7 +251,7 @@ static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
>> 	hdr = &rhdr->header;
>> 	nfs_pgheader_init(desc, hdr, nfs_rw_header_free);
>> 	atomic_inc(&hdr->refcnt);
>> -	ret = nfs_generic_pagein(desc, hdr);
>> +	ret = nfs_generic_pgio(desc, hdr);
>> 	if (ret == 0)
>> 		ret = nfs_do_multiple_reads(&hdr->rpc_list,
>> 					    desc->pg_rpc_callops);
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index 1f98f31..8929e33 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -1044,101 +1044,6 @@ static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
>> 	.completion = nfs_write_completion,
>> };
>>
>> -/*
>> - * Generate multiple small requests to write out a single
>> - * contiguous dirty area on one page.
>> - */
>> -static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
>> -			   struct nfs_pgio_header *hdr)
>> -{
>> -	struct nfs_page *req = hdr->req;
>> -	struct page *page = req->wb_page;
>> -	struct nfs_pgio_data *data;
>> -	size_t wsize = desc->pg_bsize, nbytes;
>> -	unsigned int offset;
>> -	int requests = 0;
>> -	struct nfs_commit_info cinfo;
>> -
>> -	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
>> -
>> -	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
>> -	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo) ||
>> -	     desc->pg_count > wsize))
>> -		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
>> -
>> -
>> -	offset = 0;
>> -	nbytes = desc->pg_count;
>> -	do {
>> -		size_t len = min(nbytes, wsize);
>> -
>> -		data = nfs_pgio_data_alloc(hdr, 1);
>> -		if (!data)
>> -			return nfs_pgio_error(desc, hdr);
>> -		data->pages.pagevec[0] = page;
>> -		nfs_pgio_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
>> -		list_add(&data->list, &hdr->rpc_list);
>> -		requests++;
>> -		nbytes -= len;
>> -		offset += len;
>> -	} while (nbytes != 0);
>> -	nfs_list_remove_request(req);
>> -	nfs_list_add_request(req, &hdr->pages);
>> -	desc->pg_rpc_callops = &nfs_pgio_common_ops;
>> -	return 0;
>> -}
>> -
>> -/*
>> - * Create an RPC task for the given write request and kick it.
>> - * The page must have been locked by the caller.
>> - *
>> - * It may happen that the page we're passed is not marked dirty.
>> - * This is the case if nfs_updatepage detects a conflicting request
>> - * that has been written but not committed.
>> - */
>> -static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
>> -			 struct nfs_pgio_header *hdr)
>> -{
>> -	struct nfs_page		*req;
>> -	struct page		**pages;
>> -	struct nfs_pgio_data	*data;
>> -	struct list_head *head = &desc->pg_list;
>> -	struct nfs_commit_info cinfo;
>> -
>> -	data = nfs_pgio_data_alloc(hdr, nfs_page_array_len(desc->pg_base,
>> -							   desc->pg_count));
>> -	if (!data)
>> -		return nfs_pgio_error(desc, hdr);
>> -
>> -	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
>> -	pages = data->pages.pagevec;
>> -	while (!list_empty(head)) {
>> -		req = nfs_list_entry(head->next);
>> -		nfs_list_remove_request(req);
>> -		nfs_list_add_request(req, &hdr->pages);
>> -		*pages++ = req->wb_page;
>> -	}
>> -
>> -	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
>> -	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo)))
>> -		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
>> -
>> -	/* Set up the argument struct */
>> -	nfs_pgio_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
>> -	list_add(&data->list, &hdr->rpc_list);
>> -	desc->pg_rpc_callops = &nfs_pgio_common_ops;
>> -	return 0;
>> -}
>> -
>> -int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
>> -		      struct nfs_pgio_header *hdr)
>> -{
>> -	if (desc->pg_bsize < PAGE_CACHE_SIZE)
>> -		return nfs_flush_multi(desc, hdr);
>> -	return nfs_flush_one(desc, hdr);
>> -}
>> -EXPORT_SYMBOL_GPL(nfs_generic_flush);
>> -
>> static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>> {
>> 	struct nfs_rw_header *whdr;
>> @@ -1153,7 +1058,7 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>> 	hdr = &whdr->header;
>> 	nfs_pgheader_init(desc, hdr, nfs_rw_header_free);
>> 	atomic_inc(&hdr->refcnt);
>> -	ret = nfs_generic_flush(desc, hdr);
>> +	ret = nfs_generic_pgio(desc, hdr);
>> 	if (ret == 0)
>> 		ret = nfs_do_multiple_writes(&hdr->rpc_list,
>> 					     desc->pg_rpc_callops,
>> -- 
>> 1.9.2
>>
> 

