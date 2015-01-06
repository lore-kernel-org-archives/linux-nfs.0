Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33922 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932241AbbAFSiI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 13:38:08 -0500
Received: by mail-ie0-f178.google.com with SMTP id vy18so4265267iec.9
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 10:38:07 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH v2 35/49] nfs: add mirroring support to pgio layer
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <54AC2A29.2040509@Netapp.com>
Date: Tue, 6 Jan 2015 13:38:05 -0500
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <D5501E10-5951-47BE-BEEE-9A745E46E498@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com> <1419405208-25975-36-git-send-email-loghyr@primarydata.com> <54AC255A.7070002@Netapp.com> <70A88B3B-0BB8-4B37-A7D3-CC2174F3EB27@primarydata.com> <54AC2A29.2040509@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 6, 2015, at 1:32 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> On 01/06/2015 01:27 PM, Weston Andros Adamson wrote:
>> These issues are addressed and the comments are removed in subsequent patches
>> from the same series.
>> 
>> Instead of having one huge patch that implements all of mirroring, I chose split
>> it out into smaller patches. These notes were useful in making sure that the issues
>> were addressed and should be useful as a guide to someone bisecting, etc.
> 
> Got it.  I'm still working my way through these patches, so I haven't seen the ones that remove the comments yet.
> 
> Thanks!
>> 

Thanks for reviewing!

-dros

>> 
>> 
>>> On Jan 6, 2015, at 1:11 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>> 
>>> Hey Dros and Tom,
>>> 
>>> I see you're adding some new FIXME and TODOs in the comments.  Is there a plan for addressing these eventually?
>>> 
>>> Thanks,
>>> Anna
>>> 
>>> On 12/24/2014 02:13 AM, Tom Haynes wrote:
>>>> From: Weston Andros Adamson <dros@primarydata.com>
>>>> 
>>>> This patch adds mirrored write support to the pgio layer. The default
>>>> is to use one mirror, but pgio callers may define callbacks to change
>>>> this to any value up to the (arbitrarily selected) limit of 16.
>>>> 
>>>> The basic idea is to break out members of nfs_pageio_descriptor that cannot
>>>> be shared between mirrored DSes and put them in a new structure.
>>>> 
>>>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>>>> ---
>>>> fs/nfs/direct.c              |  17 ++-
>>>> fs/nfs/internal.h            |   1 +
>>>> fs/nfs/objlayout/objio_osd.c |   3 +-
>>>> fs/nfs/pagelist.c            | 270 +++++++++++++++++++++++++++++++++++--------
>>>> fs/nfs/pnfs.c                |  26 +++--
>>>> fs/nfs/read.c                |  30 ++++-
>>>> fs/nfs/write.c               |  10 +-
>>>> include/linux/nfs_page.h     |  20 +++-
>>>> include/linux/nfs_xdr.h      |   1 +
>>>> 9 files changed, 311 insertions(+), 67 deletions(-)
>>>> 
>>>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>>>> index 1ee41d7..0178d4f 100644
>>>> --- a/fs/nfs/direct.c
>>>> +++ b/fs/nfs/direct.c
>>>> @@ -360,8 +360,14 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
>>>> 	spin_lock(&dreq->lock);
>>>> 	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) && (hdr->good_bytes == 0))
>>>> 		dreq->error = hdr->error;
>>>> -	else
>>>> -		dreq->count += hdr->good_bytes;
>>>> +	else {
>>>> +		/*
>>>> +		 * FIXME: right now this only accounts for bytes written
>>>> +		 *        to the first mirror
>>>> +		 */
>>>> +		if (hdr->pgio_mirror_idx == 0)
>>>> +			dreq->count += hdr->good_bytes;
>>>> +	}
>>>> 	spin_unlock(&dreq->lock);
>>>> 
>>>> 	while (!list_empty(&hdr->pages)) {
>>>> @@ -724,7 +730,12 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
>>>> 		dreq->error = hdr->error;
>>>> 	}
>>>> 	if (dreq->error == 0) {
>>>> -		dreq->count += hdr->good_bytes;
>>>> +		/*
>>>> +		 * FIXME: right now this only accounts for bytes written
>>>> +		 *        to the first mirror
>>>> +		 */
>>>> +		if (hdr->pgio_mirror_idx == 0)
>>>> +			dreq->count += hdr->good_bytes;
>>>> 		if (nfs_write_need_commit(hdr)) {
>>>> 			if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES)
>>>> 				request_commit = true;
>>>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>>>> index 05f9a87..ef1c703 100644
>>>> --- a/fs/nfs/internal.h
>>>> +++ b/fs/nfs/internal.h
>>>> @@ -469,6 +469,7 @@ void nfs_init_cinfo(struct nfs_commit_info *cinfo,
>>>> 		    struct nfs_direct_req *dreq);
>>>> int nfs_key_timeout_notify(struct file *filp, struct inode *inode);
>>>> bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx);
>>>> +void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio);
>>>> 
>>>> #ifdef CONFIG_MIGRATION
>>>> extern int nfs_migrate_page(struct address_space *,
>>>> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
>>>> index d007780..9a5f2ee 100644
>>>> --- a/fs/nfs/objlayout/objio_osd.c
>>>> +++ b/fs/nfs/objlayout/objio_osd.c
>>>> @@ -537,11 +537,12 @@ int objio_write_pagelist(struct nfs_pgio_header *hdr, int how)
>>>> static size_t objio_pg_test(struct nfs_pageio_descriptor *pgio,
>>>> 			  struct nfs_page *prev, struct nfs_page *req)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &pgio->pg_mirrors[pgio->pg_mirror_idx];
>>>> 	unsigned int size;
>>>> 
>>>> 	size = pnfs_generic_pg_test(pgio, prev, req);
>>>> 
>>>> -	if (!size || pgio->pg_count + req->wb_bytes >
>>>> +	if (!size || mirror->pg_count + req->wb_bytes >
>>>> 	    (unsigned long)pgio->pg_layout_private)
>>>> 		return 0;
>>>> 
>>>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>>>> index 1c03187..eec12b7 100644
>>>> --- a/fs/nfs/pagelist.c
>>>> +++ b/fs/nfs/pagelist.c
>>>> @@ -46,17 +46,22 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
>>>> 		       struct nfs_pgio_header *hdr,
>>>> 		       void (*release)(struct nfs_pgio_header *hdr))
>>>> {
>>>> -	hdr->req = nfs_list_entry(desc->pg_list.next);
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> +
>>>> +	hdr->req = nfs_list_entry(mirror->pg_list.next);
>>>> 	hdr->inode = desc->pg_inode;
>>>> 	hdr->cred = hdr->req->wb_context->cred;
>>>> 	hdr->io_start = req_offset(hdr->req);
>>>> -	hdr->good_bytes = desc->pg_count;
>>>> +	hdr->good_bytes = mirror->pg_count;
>>>> 	hdr->dreq = desc->pg_dreq;
>>>> 	hdr->layout_private = desc->pg_layout_private;
>>>> 	hdr->release = release;
>>>> 	hdr->completion_ops = desc->pg_completion_ops;
>>>> 	if (hdr->completion_ops->init_hdr)
>>>> 		hdr->completion_ops->init_hdr(hdr);
>>>> +
>>>> +	hdr->pgio_mirror_idx = desc->pg_mirror_idx;
>>>> }
>>>> EXPORT_SYMBOL_GPL(nfs_pgheader_init);
>>>> 
>>>> @@ -480,7 +485,10 @@ nfs_wait_on_request(struct nfs_page *req)
>>>> size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
>>>> 			   struct nfs_page *prev, struct nfs_page *req)
>>>> {
>>>> -	if (desc->pg_count > desc->pg_bsize) {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> +
>>>> +	if (mirror->pg_count > mirror->pg_bsize) {
>>>> 		/* should never happen */
>>>> 		WARN_ON_ONCE(1);
>>>> 		return 0;
>>>> @@ -490,11 +498,11 @@ size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
>>>> 	 * Limit the request size so that we can still allocate a page array
>>>> 	 * for it without upsetting the slab allocator.
>>>> 	 */
>>>> -	if (((desc->pg_count + req->wb_bytes) >> PAGE_SHIFT) *
>>>> +	if (((mirror->pg_count + req->wb_bytes) >> PAGE_SHIFT) *
>>>> 			sizeof(struct page) > PAGE_SIZE)
>>>> 		return 0;
>>>> 
>>>> -	return min(desc->pg_bsize - desc->pg_count, (size_t)req->wb_bytes);
>>>> +	return min(mirror->pg_bsize - mirror->pg_count, (size_t)req->wb_bytes);
>>>> }
>>>> EXPORT_SYMBOL_GPL(nfs_generic_pg_test);
>>>> 
>>>> @@ -651,10 +659,18 @@ EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
>>>> static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
>>>> 			  struct nfs_pgio_header *hdr)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror;
>>>> +	u32 midx;
>>>> +
>>>> 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
>>>> 	nfs_pgio_data_destroy(hdr);
>>>> 	hdr->completion_ops->completion(hdr);
>>>> -	desc->pg_completion_ops->error_cleanup(&desc->pg_list);
>>>> +	/* TODO: Make sure it's right to clean up all mirrors here
>>>> +	 *       and not just hdr->pgio_mirror_idx */
>>>> +	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
>>>> +		mirror = &desc->pg_mirrors[midx];
>>>> +		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
>>>> +	}
>>>> 	return -ENOMEM;
>>>> }
>>>> 
>>>> @@ -671,6 +687,17 @@ static void nfs_pgio_release(void *calldata)
>>>> 	hdr->completion_ops->completion(hdr);
>>>> }
>>>> 
>>>> +static void nfs_pageio_mirror_init(struct nfs_pgio_mirror *mirror,
>>>> +				   unsigned int bsize)
>>>> +{
>>>> +	INIT_LIST_HEAD(&mirror->pg_list);
>>>> +	mirror->pg_bytes_written = 0;
>>>> +	mirror->pg_count = 0;
>>>> +	mirror->pg_bsize = bsize;
>>>> +	mirror->pg_base = 0;
>>>> +	mirror->pg_recoalesce = 0;
>>>> +}
>>>> +
>>>> /**
>>>> * nfs_pageio_init - initialise a page io descriptor
>>>> * @desc: pointer to descriptor
>>>> @@ -687,13 +714,10 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>>>> 		     size_t bsize,
>>>> 		     int io_flags)
>>>> {
>>>> -	INIT_LIST_HEAD(&desc->pg_list);
>>>> -	desc->pg_bytes_written = 0;
>>>> -	desc->pg_count = 0;
>>>> -	desc->pg_bsize = bsize;
>>>> -	desc->pg_base = 0;
>>>> +	struct nfs_pgio_mirror *new;
>>>> +	int i;
>>>> +
>>>> 	desc->pg_moreio = 0;
>>>> -	desc->pg_recoalesce = 0;
>>>> 	desc->pg_inode = inode;
>>>> 	desc->pg_ops = pg_ops;
>>>> 	desc->pg_completion_ops = compl_ops;
>>>> @@ -703,6 +727,26 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>>>> 	desc->pg_lseg = NULL;
>>>> 	desc->pg_dreq = NULL;
>>>> 	desc->pg_layout_private = NULL;
>>>> +	desc->pg_bsize = bsize;
>>>> +
>>>> +	desc->pg_mirror_count = 1;
>>>> +	desc->pg_mirror_idx = 0;
>>>> +
>>>> +	if (pg_ops->pg_get_mirror_count) {
>>>> +		/* until we have a request, we don't have an lseg and no
>>>> +		 * idea how many mirrors there will be */
>>>> +		new = kcalloc(NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX,
>>>> +			      sizeof(struct nfs_pgio_mirror), GFP_KERNEL);
>>>> +		desc->pg_mirrors_dynamic = new;
>>>> +		desc->pg_mirrors = new;
>>>> +
>>>> +		for (i = 0; i < NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX; i++)
>>>> +			nfs_pageio_mirror_init(&desc->pg_mirrors[i], bsize);
>>>> +	} else {
>>>> +		desc->pg_mirrors_dynamic = NULL;
>>>> +		desc->pg_mirrors = desc->pg_mirrors_static;
>>>> +		nfs_pageio_mirror_init(&desc->pg_mirrors[0], bsize);
>>>> +	}
>>>> }
>>>> EXPORT_SYMBOL_GPL(nfs_pageio_init);
>>>> 
>>>> @@ -738,14 +782,16 @@ static void nfs_pgio_result(struct rpc_task *task, void *calldata)
>>>> int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
>>>> 		     struct nfs_pgio_header *hdr)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> 	struct nfs_page		*req;
>>>> 	struct page		**pages,
>>>> 				*last_page;
>>>> -	struct list_head *head = &desc->pg_list;
>>>> +	struct list_head *head = &mirror->pg_list;
>>>> 	struct nfs_commit_info cinfo;
>>>> 	unsigned int pagecount, pageused;
>>>> 
>>>> -	pagecount = nfs_page_array_len(desc->pg_base, desc->pg_count);
>>>> +	pagecount = nfs_page_array_len(mirror->pg_base, mirror->pg_count);
>>>> 	if (!nfs_pgarray_set(&hdr->page_array, pagecount))
>>>> 		return nfs_pgio_error(desc, hdr);
>>>> 
>>>> @@ -773,7 +819,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
>>>> 		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
>>>> 
>>>> 	/* Set up the argument struct */
>>>> -	nfs_pgio_rpcsetup(hdr, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
>>>> +	nfs_pgio_rpcsetup(hdr, mirror->pg_count, 0, desc->pg_ioflags, &cinfo);
>>>> 	desc->pg_rpc_callops = &nfs_pgio_common_ops;
>>>> 	return 0;
>>>> }
>>>> @@ -781,12 +827,17 @@ EXPORT_SYMBOL_GPL(nfs_generic_pgio);
>>>> 
>>>> static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror;
>>>> 	struct nfs_pgio_header *hdr;
>>>> 	int ret;
>>>> 
>>>> +	mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
>>>> 	if (!hdr) {
>>>> -		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
>>>> +		/* TODO: make sure this is right with mirroring - or
>>>> +		 *       should it back out all mirrors? */
>>>> +		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
>>>> 		return -ENOMEM;
>>>> 	}
>>>> 	nfs_pgheader_init(desc, hdr, nfs_pgio_header_free);
>>>> @@ -801,6 +852,49 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
>>>> 	return ret;
>>>> }
>>>> 
>>>> +/*
>>>> + * nfs_pageio_setup_mirroring - determine if mirroring is to be used
>>>> + *				by calling the pg_get_mirror_count op
>>>> + */
>>>> +static int nfs_pageio_setup_mirroring(struct nfs_pageio_descriptor *pgio,
>>>> +				       struct nfs_page *req)
>>>> +{
>>>> +	int mirror_count = 1;
>>>> +
>>>> +	if (!pgio->pg_ops->pg_get_mirror_count)
>>>> +		return 0;
>>>> +
>>>> +	mirror_count = pgio->pg_ops->pg_get_mirror_count(pgio, req);
>>>> +
>>>> +	if (!mirror_count || mirror_count > NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX)
>>>> +		return -EINVAL;
>>>> +
>>>> +	if (WARN_ON_ONCE(!pgio->pg_mirrors_dynamic))
>>>> +		return -EINVAL;
>>>> +
>>>> +	pgio->pg_mirror_count = mirror_count;
>>>> +
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +/*
>>>> + * nfs_pageio_stop_mirroring - stop using mirroring (set mirror count to 1)
>>>> + */
>>>> +void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio)
>>>> +{
>>>> +	pgio->pg_mirror_count = 1;
>>>> +	pgio->pg_mirror_idx = 0;
>>>> +}
>>>> +
>>>> +static void nfs_pageio_cleanup_mirroring(struct nfs_pageio_descriptor *pgio)
>>>> +{
>>>> +	pgio->pg_mirror_count = 1;
>>>> +	pgio->pg_mirror_idx = 0;
>>>> +	pgio->pg_mirrors = pgio->pg_mirrors_static;
>>>> +	kfree(pgio->pg_mirrors_dynamic);
>>>> +	pgio->pg_mirrors_dynamic = NULL;
>>>> +}
>>>> +
>>>> static bool nfs_match_open_context(const struct nfs_open_context *ctx1,
>>>> 		const struct nfs_open_context *ctx2)
>>>> {
>>>> @@ -867,19 +961,22 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
>>>> static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
>>>> 				     struct nfs_page *req)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> 	struct nfs_page *prev = NULL;
>>>> -	if (desc->pg_count != 0) {
>>>> -		prev = nfs_list_entry(desc->pg_list.prev);
>>>> +
>>>> +	if (mirror->pg_count != 0) {
>>>> +		prev = nfs_list_entry(mirror->pg_list.prev);
>>>> 	} else {
>>>> 		if (desc->pg_ops->pg_init)
>>>> 			desc->pg_ops->pg_init(desc, req);
>>>> -		desc->pg_base = req->wb_pgbase;
>>>> +		mirror->pg_base = req->wb_pgbase;
>>>> 	}
>>>> 	if (!nfs_can_coalesce_requests(prev, req, desc))
>>>> 		return 0;
>>>> 	nfs_list_remove_request(req);
>>>> -	nfs_list_add_request(req, &desc->pg_list);
>>>> -	desc->pg_count += req->wb_bytes;
>>>> +	nfs_list_add_request(req, &mirror->pg_list);
>>>> +	mirror->pg_count += req->wb_bytes;
>>>> 	return 1;
>>>> }
>>>> 
>>>> @@ -888,16 +985,19 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
>>>> */
>>>> static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
>>>> {
>>>> -	if (!list_empty(&desc->pg_list)) {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> +
>>>> +	if (!list_empty(&mirror->pg_list)) {
>>>> 		int error = desc->pg_ops->pg_doio(desc);
>>>> 		if (error < 0)
>>>> 			desc->pg_error = error;
>>>> 		else
>>>> -			desc->pg_bytes_written += desc->pg_count;
>>>> +			mirror->pg_bytes_written += mirror->pg_count;
>>>> 	}
>>>> -	if (list_empty(&desc->pg_list)) {
>>>> -		desc->pg_count = 0;
>>>> -		desc->pg_base = 0;
>>>> +	if (list_empty(&mirror->pg_list)) {
>>>> +		mirror->pg_count = 0;
>>>> +		mirror->pg_base = 0;
>>>> 	}
>>>> }
>>>> 
>>>> @@ -915,10 +1015,14 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
>>>> static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>>>> 			   struct nfs_page *req)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> 	struct nfs_page *subreq;
>>>> 	unsigned int bytes_left = 0;
>>>> 	unsigned int offset, pgbase;
>>>> 
>>>> +	WARN_ON_ONCE(desc->pg_mirror_idx >= desc->pg_mirror_count);
>>>> +
>>>> 	nfs_page_group_lock(req, false);
>>>> 
>>>> 	subreq = req;
>>>> @@ -938,7 +1042,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>>>> 			nfs_pageio_doio(desc);
>>>> 			if (desc->pg_error < 0)
>>>> 				return 0;
>>>> -			if (desc->pg_recoalesce)
>>>> +			if (mirror->pg_recoalesce)
>>>> 				return 0;
>>>> 			/* retry add_request for this subreq */
>>>> 			nfs_page_group_lock(req, false);
>>>> @@ -976,14 +1080,16 @@ err_ptr:
>>>> 
>>>> static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> 	LIST_HEAD(head);
>>>> 
>>>> 	do {
>>>> -		list_splice_init(&desc->pg_list, &head);
>>>> -		desc->pg_bytes_written -= desc->pg_count;
>>>> -		desc->pg_count = 0;
>>>> -		desc->pg_base = 0;
>>>> -		desc->pg_recoalesce = 0;
>>>> +		list_splice_init(&mirror->pg_list, &head);
>>>> +		mirror->pg_bytes_written -= mirror->pg_count;
>>>> +		mirror->pg_count = 0;
>>>> +		mirror->pg_base = 0;
>>>> +		mirror->pg_recoalesce = 0;
>>>> +
>>>> 		desc->pg_moreio = 0;
>>>> 
>>>> 		while (!list_empty(&head)) {
>>>> @@ -997,11 +1103,11 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
>>>> 				return 0;
>>>> 			break;
>>>> 		}
>>>> -	} while (desc->pg_recoalesce);
>>>> +	} while (mirror->pg_recoalesce);
>>>> 	return 1;
>>>> }
>>>> 
>>>> -int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>>>> +static int nfs_pageio_add_request_mirror(struct nfs_pageio_descriptor *desc,
>>>> 		struct nfs_page *req)
>>>> {
>>>> 	int ret;
>>>> @@ -1014,9 +1120,78 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>>>> 			break;
>>>> 		ret = nfs_do_recoalesce(desc);
>>>> 	} while (ret);
>>>> +
>>>> 	return ret;
>>>> }
>>>> 
>>>> +int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>>>> +			   struct nfs_page *req)
>>>> +{
>>>> +	u32 midx;
>>>> +	unsigned int pgbase, offset, bytes;
>>>> +	struct nfs_page *dupreq, *lastreq;
>>>> +
>>>> +	pgbase = req->wb_pgbase;
>>>> +	offset = req->wb_offset;
>>>> +	bytes = req->wb_bytes;
>>>> +
>>>> +	nfs_pageio_setup_mirroring(desc, req);
>>>> +
>>>> +	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
>>>> +		if (midx) {
>>>> +			nfs_page_group_lock(req, false);
>>>> +
>>>> +			/* find the last request */
>>>> +			for (lastreq = req->wb_head;
>>>> +			     lastreq->wb_this_page != req->wb_head;
>>>> +			     lastreq = lastreq->wb_this_page)
>>>> +				;
>>>> +
>>>> +			dupreq = nfs_create_request(req->wb_context,
>>>> +					req->wb_page, lastreq, pgbase, bytes);
>>>> +
>>>> +			if (IS_ERR(dupreq)) {
>>>> +				nfs_page_group_unlock(req);
>>>> +				return 0;
>>>> +			}
>>>> +
>>>> +			nfs_lock_request(dupreq);
>>>> +			nfs_page_group_unlock(req);
>>>> +			dupreq->wb_offset = offset;
>>>> +			dupreq->wb_index = req->wb_index;
>>>> +		} else
>>>> +			dupreq = req;
>>>> +
>>>> +		desc->pg_mirror_idx = midx;
>>>> +		if (!nfs_pageio_add_request_mirror(desc, dupreq))
>>>> +			return 0;
>>>> +	}
>>>> +
>>>> +	return 1;
>>>> +}
>>>> +
>>>> +/*
>>>> + * nfs_pageio_complete_mirror - Complete I/O on the current mirror of an
>>>> + *				nfs_pageio_descriptor
>>>> + * @desc: pointer to io descriptor
>>>> + */
>>>> +static void nfs_pageio_complete_mirror(struct nfs_pageio_descriptor *desc,
>>>> +				       u32 mirror_idx)
>>>> +{
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[mirror_idx];
>>>> +	u32 restore_idx = desc->pg_mirror_idx;
>>>> +
>>>> +	desc->pg_mirror_idx = mirror_idx;
>>>> +	for (;;) {
>>>> +		nfs_pageio_doio(desc);
>>>> +		if (!mirror->pg_recoalesce)
>>>> +			break;
>>>> +		if (!nfs_do_recoalesce(desc))
>>>> +			break;
>>>> +	}
>>>> +	desc->pg_mirror_idx = restore_idx;
>>>> +}
>>>> +
>>>> /*
>>>> * nfs_pageio_resend - Transfer requests to new descriptor and resend
>>>> * @hdr - the pgio header to move request from
>>>> @@ -1055,16 +1230,14 @@ EXPORT_SYMBOL_GPL(nfs_pageio_resend);
>>>> */
>>>> void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
>>>> {
>>>> -	for (;;) {
>>>> -		nfs_pageio_doio(desc);
>>>> -		if (!desc->pg_recoalesce)
>>>> -			break;
>>>> -		if (!nfs_do_recoalesce(desc))
>>>> -			break;
>>>> -	}
>>>> +	u32 midx;
>>>> +
>>>> +	for (midx = 0; midx < desc->pg_mirror_count; midx++)
>>>> +		nfs_pageio_complete_mirror(desc, midx);
>>>> 
>>>> 	if (desc->pg_ops->pg_cleanup)
>>>> 		desc->pg_ops->pg_cleanup(desc);
>>>> +	nfs_pageio_cleanup_mirroring(desc);
>>>> }
>>>> 
>>>> /**
>>>> @@ -1080,10 +1253,17 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
>>>> */
>>>> void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
>>>> {
>>>> -	if (!list_empty(&desc->pg_list)) {
>>>> -		struct nfs_page *prev = nfs_list_entry(desc->pg_list.prev);
>>>> -		if (index != prev->wb_index + 1)
>>>> -			nfs_pageio_complete(desc);
>>>> +	struct nfs_pgio_mirror *mirror;
>>>> +	struct nfs_page *prev;
>>>> +	u32 midx;
>>>> +
>>>> +	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
>>>> +		mirror = &desc->pg_mirrors[midx];
>>>> +		if (!list_empty(&mirror->pg_list)) {
>>>> +			prev = nfs_list_entry(mirror->pg_list.prev);
>>>> +			if (index != prev->wb_index + 1)
>>>> +				nfs_pageio_complete_mirror(desc, midx);
>>>> +		}
>>>> 	}
>>>> }
>>>> 
>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>> index 2da2e77..5f7c422 100644
>>>> --- a/fs/nfs/pnfs.c
>>>> +++ b/fs/nfs/pnfs.c
>>>> @@ -1646,8 +1646,8 @@ EXPORT_SYMBOL_GPL(pnfs_generic_pg_cleanup);
>>>> * of bytes (maximum @req->wb_bytes) that can be coalesced.
>>>> */
>>>> size_t
>>>> -pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>>>> -		     struct nfs_page *req)
>>>> +pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
>>>> +		     struct nfs_page *prev, struct nfs_page *req)
>>>> {
>>>> 	unsigned int size;
>>>> 	u64 seg_end, req_start, seg_left;
>>>> @@ -1729,10 +1729,12 @@ static void
>>>> pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
>>>> 		struct nfs_pgio_header *hdr)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
>>>> -		list_splice_tail_init(&hdr->pages, &desc->pg_list);
>>>> +		list_splice_tail_init(&hdr->pages, &mirror->pg_list);
>>>> 		nfs_pageio_reset_write_mds(desc);
>>>> -		desc->pg_recoalesce = 1;
>>>> +		mirror->pg_recoalesce = 1;
>>>> 	}
>>>> 	nfs_pgio_data_destroy(hdr);
>>>> }
>>>> @@ -1781,12 +1783,14 @@ EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
>>>> int
>>>> pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> 	struct nfs_pgio_header *hdr;
>>>> 	int ret;
>>>> 
>>>> 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
>>>> 	if (!hdr) {
>>>> -		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
>>>> +		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
>>>> 		return -ENOMEM;
>>>> 	}
>>>> 	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
>>>> @@ -1795,6 +1799,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>>>> 	ret = nfs_generic_pgio(desc, hdr);
>>>> 	if (!ret)
>>>> 		pnfs_do_write(desc, hdr, desc->pg_ioflags);
>>>> +
>>>> 	return ret;
>>>> }
>>>> EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
>>>> @@ -1839,10 +1844,13 @@ static void
>>>> pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
>>>> 		struct nfs_pgio_header *hdr)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> +
>>>> 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
>>>> -		list_splice_tail_init(&hdr->pages, &desc->pg_list);
>>>> +		list_splice_tail_init(&hdr->pages, &mirror->pg_list);
>>>> 		nfs_pageio_reset_read_mds(desc);
>>>> -		desc->pg_recoalesce = 1;
>>>> +		mirror->pg_recoalesce = 1;
>>>> 	}
>>>> 	nfs_pgio_data_destroy(hdr);
>>>> }
>>>> @@ -1893,12 +1901,14 @@ EXPORT_SYMBOL_GPL(pnfs_readhdr_free);
>>>> int
>>>> pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[desc->pg_mirror_idx];
>>>> +
>>>> 	struct nfs_pgio_header *hdr;
>>>> 	int ret;
>>>> 
>>>> 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
>>>> 	if (!hdr) {
>>>> -		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
>>>> +		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
>>>> 		return -ENOMEM;
>>>> 	}
>>>> 	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
>>>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>>>> index 092ab49..568ecf0 100644
>>>> --- a/fs/nfs/read.c
>>>> +++ b/fs/nfs/read.c
>>>> @@ -70,8 +70,15 @@ EXPORT_SYMBOL_GPL(nfs_pageio_init_read);
>>>> 
>>>> void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror;
>>>> +
>>>> 	pgio->pg_ops = &nfs_pgio_rw_ops;
>>>> -	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->rsize;
>>>> +
>>>> +	/* read path should never have more than one mirror */
>>>> +	WARN_ON_ONCE(pgio->pg_mirror_count != 1);
>>>> +
>>>> +	mirror = &pgio->pg_mirrors[0];
>>>> +	mirror->pg_bsize = NFS_SERVER(pgio->pg_inode)->rsize;
>>>> }
>>>> EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
>>>> 
>>>> @@ -81,6 +88,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>>>> 	struct nfs_page	*new;
>>>> 	unsigned int len;
>>>> 	struct nfs_pageio_descriptor pgio;
>>>> +	struct nfs_pgio_mirror *pgm;
>>>> 
>>>> 	len = nfs_page_length(page);
>>>> 	if (len == 0)
>>>> @@ -97,7 +105,13 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>>>> 			     &nfs_async_read_completion_ops);
>>>> 	nfs_pageio_add_request(&pgio, new);
>>>> 	nfs_pageio_complete(&pgio);
>>>> -	NFS_I(inode)->read_io += pgio.pg_bytes_written;
>>>> +
>>>> +	/* It doesn't make sense to do mirrored reads! */
>>>> +	WARN_ON_ONCE(pgio.pg_mirror_count != 1);
>>>> +
>>>> +	pgm = &pgio.pg_mirrors[0];
>>>> +	NFS_I(inode)->read_io += pgm->pg_bytes_written;
>>>> +
>>>> 	return 0;
>>>> }
>>>> 
>>>> @@ -352,6 +366,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
>>>> 		struct list_head *pages, unsigned nr_pages)
>>>> {
>>>> 	struct nfs_pageio_descriptor pgio;
>>>> +	struct nfs_pgio_mirror *pgm;
>>>> 	struct nfs_readdesc desc = {
>>>> 		.pgio = &pgio,
>>>> 	};
>>>> @@ -387,10 +402,15 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
>>>> 			     &nfs_async_read_completion_ops);
>>>> 
>>>> 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
>>>> -
>>>> 	nfs_pageio_complete(&pgio);
>>>> -	NFS_I(inode)->read_io += pgio.pg_bytes_written;
>>>> -	npages = (pgio.pg_bytes_written + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>>>> +
>>>> +	/* It doesn't make sense to do mirrored reads! */
>>>> +	WARN_ON_ONCE(pgio.pg_mirror_count != 1);
>>>> +
>>>> +	pgm = &pgio.pg_mirrors[0];
>>>> +	NFS_I(inode)->read_io += pgm->pg_bytes_written;
>>>> +	npages = (pgm->pg_bytes_written + PAGE_CACHE_SIZE - 1) >>
>>>> +		 PAGE_CACHE_SHIFT;
>>>> 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
>>>> read_complete:
>>>> 	put_nfs_open_context(desc.ctx);
>>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>>> index db802d9..2f6ee8e 100644
>>>> --- a/fs/nfs/write.c
>>>> +++ b/fs/nfs/write.c
>>>> @@ -906,7 +906,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
>>>> 		if (nfs_write_need_commit(hdr)) {
>>>> 			memcpy(&req->wb_verf, &hdr->verf.verifier, sizeof(req->wb_verf));
>>>> 			nfs_mark_request_commit(req, hdr->lseg, &cinfo,
>>>> -				0);
>>>> +				hdr->pgio_mirror_idx);
>>>> 			goto next;
>>>> 		}
>>>> remove_req:
>>>> @@ -1305,8 +1305,14 @@ EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
>>>> 
>>>> void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
>>>> {
>>>> +	struct nfs_pgio_mirror *mirror;
>>>> +
>>>> 	pgio->pg_ops = &nfs_pgio_rw_ops;
>>>> -	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
>>>> +
>>>> +	nfs_pageio_stop_mirroring(pgio);
>>>> +
>>>> +	mirror = &pgio->pg_mirrors[0];
>>>> +	mirror->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
>>>> }
>>>> EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
>>>> 
>>>> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
>>>> index 479c566..3eb072d 100644
>>>> --- a/include/linux/nfs_page.h
>>>> +++ b/include/linux/nfs_page.h
>>>> @@ -58,6 +58,8 @@ struct nfs_pageio_ops {
>>>> 	size_t	(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *,
>>>> 			   struct nfs_page *);
>>>> 	int	(*pg_doio)(struct nfs_pageio_descriptor *);
>>>> +	unsigned int	(*pg_get_mirror_count)(struct nfs_pageio_descriptor *,
>>>> +				       struct nfs_page *);
>>>> 	void	(*pg_cleanup)(struct nfs_pageio_descriptor *);
>>>> };
>>>> 
>>>> @@ -74,15 +76,17 @@ struct nfs_rw_ops {
>>>> 			    struct rpc_task_setup *, int);
>>>> };
>>>> 
>>>> -struct nfs_pageio_descriptor {
>>>> +struct nfs_pgio_mirror {
>>>> 	struct list_head	pg_list;
>>>> 	unsigned long		pg_bytes_written;
>>>> 	size_t			pg_count;
>>>> 	size_t			pg_bsize;
>>>> 	unsigned int		pg_base;
>>>> -	unsigned char		pg_moreio : 1,
>>>> -				pg_recoalesce : 1;
>>>> +	unsigned char		pg_recoalesce : 1;
>>>> +};
>>>> 
>>>> +struct nfs_pageio_descriptor {
>>>> +	unsigned char		pg_moreio : 1;
>>>> 	struct inode		*pg_inode;
>>>> 	const struct nfs_pageio_ops *pg_ops;
>>>> 	const struct nfs_rw_ops *pg_rw_ops;
>>>> @@ -93,8 +97,18 @@ struct nfs_pageio_descriptor {
>>>> 	struct pnfs_layout_segment *pg_lseg;
>>>> 	struct nfs_direct_req	*pg_dreq;
>>>> 	void			*pg_layout_private;
>>>> +	unsigned int		pg_bsize;	/* default bsize for mirrors */
>>>> +
>>>> +	u32			pg_mirror_count;
>>>> +	struct nfs_pgio_mirror	*pg_mirrors;
>>>> +	struct nfs_pgio_mirror	pg_mirrors_static[1];
>>>> +	struct nfs_pgio_mirror	*pg_mirrors_dynamic;
>>>> +	u32			pg_mirror_idx;	/* current mirror */
>>>> };
>>>> 
>>>> +/* arbitrarily selected limit to number of mirrors */
>>>> +#define NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX 16
>>>> +
>>>> #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
>>>> 
>>>> extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
>>>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>>>> index 5bc99f0..6400a1e 100644
>>>> --- a/include/linux/nfs_xdr.h
>>>> +++ b/include/linux/nfs_xdr.h
>>>> @@ -1329,6 +1329,7 @@ struct nfs_pgio_header {
>>>> 	struct nfs_page_array	page_array;
>>>> 	struct nfs_client	*ds_clp;	/* pNFS data server */
>>>> 	int			ds_commit_idx;	/* ds index if ds_clp is set */
>>>> +	int			pgio_mirror_idx;/* mirror index in pgio layer */
>>>> };
>>>> 
>>>> struct nfs_mds_commit_info {
>>>> 
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 

