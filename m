Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:45029 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaDYNco convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 09:32:44 -0400
Received: by mail-ig0-f170.google.com with SMTP id uq10so2249434igb.5
        for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2014 06:32:43 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 06/18 v2] nfs: add support for multiple nfs reqs per page
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <F4537580-2CE3-42C2-9849-DFEE95563FB2@primarydata.com>
Date: Fri, 25 Apr 2014 09:32:43 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <A8046112-4E61-4541-AD21-082AB6219D99@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com> <1398363328-7100-7-git-send-email-dros@primarydata.com> <535978CB.90008@netapp.com> <53597C28.6050504@netapp.com> <F4537580-2CE3-42C2-9849-DFEE95563FB2@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 24, 2014, at 7:06 PM, Weston Andros Adamson <dros@primarydata.com> wrote:

> Ah my bad, I’ll fix that up.
> 
> -dros
> 
> On Apr 24, 2014, at 5:03 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
>> On 04/24/2014 04:49 PM, Anna Schumaker wrote:
>>> On 04/24/2014 02:15 PM, Weston Andros Adamson wrote:
>>>> Add "page groups" - a circular list of nfs requests (struct nfs_page)
>>>> that all reference the same page. This gives nfs read and write paths
>>>> the ability to account for sub-page regions independently.  This
>>>> somewhat follows the design of struct buffer_head's sub-page
>>>> accounting.
>>>> 
>>>> Only "head" requests are ever added/removed from the inode list in
>>>> the buffered write path. "head" and "sub" requests are treated the
>>>> same through the read path and the rest of the write/commit path.
>>>> Requests are given an extra reference across the life of the list.
>>>> 
>>>> Page groups are never rejoined after being split. If the read/write
>>>> request fails and the client falls back to another path (ie revert
>>>> to MDS in PNFS case), the already split requests are pushed through
>>>> the recoalescing code again, which may split them further and then
>>>> coalesce them into properly sized requests on the wire. Fragmentation
>>>> shouldn't be a problem with the current design, because we flush all
>>>> requests in page group when a non-contiguous request is added, so
>>>> the only time resplitting should occur is on a resend of a read or
>>>> write.
>>>> 
>>>> This patch lays the groundwork for sub-page splitting, but does not
>>>> actually do any splitting. For now all page groups have one request
>>>> as pg_test functions don't yet split pages. There are several related
>>>> patches that are needed support multiple requests per page group.
>>>> 
>>>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>>>> ---
>>>> fs/nfs/direct.c          |   7 +-
>>>> fs/nfs/pagelist.c        | 224 ++++++++++++++++++++++++++++++++++++++++++++---
>>>> fs/nfs/read.c            |   4 +-
>>>> fs/nfs/write.c           |  13 ++-
>>>> include/linux/nfs_page.h |  13 ++-
>>>> 5 files changed, 240 insertions(+), 21 deletions(-)
>>>> 
>>>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>>>> index 1dd8c62..2c0e08f 100644
>>>> --- a/fs/nfs/direct.c
>>>> +++ b/fs/nfs/direct.c
>>>> @@ -380,7 +380,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
>>>> 			struct nfs_page *req;
>>>> 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
>>>> 			/* XXX do we need to do the eof zeroing found in async_filler? */
>>>> -			req = nfs_create_request(dreq->ctx, pagevec[i],
>>>> +			req = nfs_create_request(dreq->ctx, pagevec[i], NULL,
>>>> 						 pgbase, req_len);
>>>> 			if (IS_ERR(req)) {
>>>> 				result = PTR_ERR(req);
>>>> @@ -749,7 +749,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
>>>> 			struct nfs_page *req;
>>>> 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
>>>> 
>>>> -			req = nfs_create_request(dreq->ctx, pagevec[i],
>>>> +			req = nfs_create_request(dreq->ctx, pagevec[i], NULL,
>>>> 						 pgbase, req_len);
>>>> 			if (IS_ERR(req)) {
>>>> 				result = PTR_ERR(req);
>>>> @@ -827,6 +827,8 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
>>>> 	spin_unlock(&dreq->lock);
>>>> 
>>>> 	while (!list_empty(&hdr->pages)) {
>>>> +		bool do_destroy = true;
>>>> +
>>>> 		req = nfs_list_entry(hdr->pages.next);
>>>> 		nfs_list_remove_request(req);
>>>> 		switch (bit) {
>>>> @@ -834,6 +836,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
>>>> 		case NFS_IOHDR_NEED_COMMIT:
>>>> 			kref_get(&req->wb_kref);
>>>> 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
>>>> +			do_destroy = false;
>>>> 		}
>>>> 		nfs_unlock_and_release_request(req);
>>>> 	}
>>>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>>>> index b120728..d57d675 100644
>>>> --- a/fs/nfs/pagelist.c
>>>> +++ b/fs/nfs/pagelist.c
>>>> @@ -26,6 +26,8 @@
>>>> 
>>>> static struct kmem_cache *nfs_page_cachep;
>>>> 
>>>> +static void nfs_free_request(struct nfs_page *);
>>>> +
>>>> bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount)
>>>> {
>>>> 	p->npages = pagecount;
>>>> @@ -133,10 +135,151 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
>>>> 	return __nfs_iocounter_wait(c);
>>>> }
>>>> 
>>>> +/*
>>>> + * nfs_page_group_lock - lock the head of the page group
>>>> + * @req - request in group that is to be locked
>>>> + *
>>>> + * this lock must be held if modifying the page group list
>>>> + */
>>>> +void
>>>> +nfs_page_group_lock(struct nfs_page *req)
>>>> +{
>>>> +	struct nfs_page *head = req->wb_head;
>>>> +	int err = -EAGAIN;
>>>> +
>>>> +	WARN_ON_ONCE(head != head->wb_head);
>>>> +
>>>> +	while (err)
>>>> +		err = wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
>>>> +			nfs_wait_bit_killable, TASK_KILLABLE);
>>>> +}
>>>> +
>>>> +/*
>>>> + * nfs_page_group_unlock - unlock the head of the page group
>>>> + * @req - request in group that is to be unlocked
>>>> + */
>>>> +void
>>>> +nfs_page_group_unlock(struct nfs_page *req)
>>>> +{
>>>> +	struct nfs_page *head = req->wb_head;
>>>> +
>>>> +	WARN_ON_ONCE(head != head->wb_head);
>>>> +
>>>> +	smp_mb__before_clear_bit();
>>>> +	clear_bit(PG_HEADLOCK, &head->wb_flags);
>>>> +	smp_mb__after_clear_bit();
>>>> +	wake_up_bit(&head->wb_flags, PG_HEADLOCK);
>>>> +}
>>>> +
>>>> +/*
>>>> + * nfs_page_group_sync_on_bit_locked
>>>> + *
>>>> + * must be called with page group lock held
>>>> + */
>>>> +static bool
>>>> +nfs_page_group_sync_on_bit_locked(struct nfs_page *req, unsigned int bit)
>>>> +{
>>>> +	struct nfs_page *head = req->wb_head;
>>>> +	struct nfs_page *tmp;
>>>> +
>>>> +	WARN_ON_ONCE(!test_bit(PG_HEADLOCK, &head->wb_flags));
>>>> +	WARN_ON_ONCE(test_and_set_bit(bit, &req->wb_flags));
>>>> +
>>>> +	tmp = req->wb_this_page;
>>>> +	while (tmp != req) {
>>>> +		if (!test_bit(bit, &tmp->wb_flags))
>>>> +			return false;
>>>> +		tmp = tmp->wb_this_page;
>>>> +	}
>>>> +
>>>> +	/* true! reset all bits */
>>>> +	tmp = req;
>>>> +	do {
>>>> +		clear_bit(bit, &tmp->wb_flags);
>>>> +		tmp = tmp->wb_this_page;
>>>> +	} while (tmp != req);
>>>> +
>>>> +	return true;
>>>> +}
>>>> +
>>>> +/*
>>>> + * nfs_page_group_sync_on_bit - set bit on current request, but only
>>>> + *   return true if the bit is set for all requests in page group
>>>> + * @req - request in page group
>>>> + * @bit - PG_* bit that is used to sync page group
>>>> + */
>>>> +bool nfs_page_group_sync_on_bit(struct nfs_page *req, unsigned int bit)
>>>> +{
>>>> +	bool ret;
>>>> +
>>>> +	nfs_page_group_lock(req);
>>>> +	ret = nfs_page_group_sync_on_bit_locked(req, bit);
>>>> +	nfs_page_group_unlock(req);
>>>> +
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +/*
>>>> + * nfs_page_group_init - Initialize the page group linkage for @req
>>>> + * @req - a new nfs request
>>>> + * @prev - the previous request in page group, or NULL if @req is the first
>>>> + *         or only request in the group (the head).
>>>> + */
>>>> +static inline void
>>>> +nfs_page_group_init(struct nfs_page *req, struct nfs_page *prev)
>>>> +{
>>>> +	WARN_ON_ONCE(prev == req);
>>>> +
>>>> +	if (!prev) {
>>>> +		req->wb_head = req;
>>>> +		req->wb_this_page = req;
>>>> +	} else {
>>>> +		WARN_ON_ONCE(prev->wb_this_page != prev->wb_head);
>>>> +		WARN_ON_ONCE(!test_bit(PG_HEADLOCK, &prev->wb_head->wb_flags));
>>>> +		req->wb_head = prev->wb_head;
>>>> +		req->wb_this_page = prev->wb_this_page;
>>>> +		prev->wb_this_page = req;
>>>> +
>>>> +		/* grab extra ref if head request has extra ref from
>>>> +		 * the write/commit path to handle handoff between write
>>>> +		 * and commit lists */
>>>> +		if (test_bit(PG_INODE_REF, &prev->wb_head->wb_flags))
>>>> +			kref_get(&req->wb_kref);
>>>> +	}
>>>> +}
>>>> +
>>>> +/*
>>>> + * nfs_page_group_destroy - sync the destruction of page groups
>>>> + * @req - request that no longer needs the page group
>>>> + *
>>>> + * releases the page group reference from each member once all
>>>> + * members have called this function.
>>>> + */
>>>> +static void
>>>> +nfs_page_group_destroy(struct kref *kref)
>>>> +{
>>>> +	struct nfs_page *req = container_of(kref, struct nfs_page, wb_kref);
>>>> +	struct nfs_page *tmp, *next;
>>>> +
>>>> +	if (!nfs_page_group_sync_on_bit(req, PG_TEARDOWN))
>>>> +		return;
>>>> +
>>>> +	tmp = req;
>>>> +	do {
>>>> +		next = tmp->wb_this_page;
>>>> +		/* unlink and free */
>>>> +		tmp->wb_this_page = tmp;
>>>> +		tmp->wb_head = tmp;
>>>> +		nfs_free_request(tmp);
>>>> +		tmp = next;
>>>> +	} while (tmp != req);
>>>> +}
>>>> +
>>>> /**
>>>> * nfs_create_request - Create an NFS read/write request.
>>>> * @ctx: open context to use
>>>> * @page: page to write
>>>> + * @last: last nfs request created for this page group or NULL if head
>>>> * @offset: starting offset within the page for the write
>>>> * @count: number of bytes to read/write
>>>> *
>>>> @@ -146,7 +289,8 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
>>>> */
>>>> struct nfs_page *
>>>> nfs_create_request(struct nfs_open_context *ctx, struct page *page,
>>>> -		   unsigned int offset, unsigned int count)
>>>> +		   struct nfs_page *last, unsigned int offset,
>>>> +		   unsigned int count)
>>>> {
>>>> 	struct nfs_page		*req;
>>>> 	struct nfs_lock_context *l_ctx;
>>>> @@ -178,6 +322,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
>>>> 	req->wb_bytes   = count;
>>>> 	req->wb_context = get_nfs_open_context(ctx);
>>>> 	kref_init(&req->wb_kref);
>>>> +	nfs_page_group_init(req, last);
>>>> 	return req;
>>>> }
>>>> 
>>>> @@ -235,16 +380,22 @@ static void nfs_clear_request(struct nfs_page *req)
>>>> 	}
>>>> }
>>>> 
>>>> -
>>>> /**
>>>> * nfs_release_request - Release the count on an NFS read/write request
>>>> * @req: request to release
>>>> *
>>>> * Note: Should never be called with the spinlock held!
>>>> */
>>>> -static void nfs_free_request(struct kref *kref)
>>>> +static void nfs_free_request(struct nfs_page *req)
>>>> {
>>>> -	struct nfs_page *req = container_of(kref, struct nfs_page, wb_kref);
>>>> +	WARN_ON_ONCE(req->wb_this_page != req);
>>>> +
>>>> +	/* extra debug: make sure no sync bits are still set */
>>>> +	WARN_ON_ONCE(test_bit(PG_TEARDOWN, &req->wb_flags));
>>>> +	WARN_ON_ONCE(test_bit(PG_UNLOCKPAGE, &req->wb_flags));
>>>> +	WARN_ON_ONCE(test_bit(PG_UPTODATE, &req->wb_flags));
>>>> +	WARN_ON_ONCE(test_bit(PG_WB_END, &req->wb_flags));
>>> My compiler doesn't know about PG_UNLOCKPAGE, PG_UPTODATE or PG_WB_END.  Did you forget to add something?
>>> 
>>> Anna
>> 
>> Ah, patches 7 and 8 introduce these flags.  Can you either reorder the patches or add the flags in this one?
>> 
>> Anna
>> 

This has been fixed in my public tree’s “pgio” branch.  I’m going to hold off on reposting untilI get
more comments.

-dros

>>>> +	WARN_ON_ONCE(test_bit(PG_REMOVE, &req->wb_flags));
>>>> 
>>>> 	/* Release struct file and open context */
>>>> 	nfs_clear_request(req);
>>>> @@ -253,7 +404,7 @@ static void nfs_free_request(struct kref *kref)
>>>> 
>>>> void nfs_release_request(struct nfs_page *req)
>>>> {
>>>> -	kref_put(&req->wb_kref, nfs_free_request);
>>>> +	kref_put(&req->wb_kref, nfs_page_group_destroy);
>>>> }
>>>> 
>>>> static int nfs_wait_bit_uninterruptible(void *word)
>>>> @@ -441,21 +592,66 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
>>>> * @desc: destination io descriptor
>>>> * @req: request
>>>> *
>>>> + * This may split a request into subrequests which are all part of the
>>>> + * same page group.
>>>> + *
>>>> * Returns true if the request 'req' was successfully coalesced into the
>>>> * existing list of pages 'desc'.
>>>> */
>>>> static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>>>> 			   struct nfs_page *req)
>>>> {
>>>> -	while (!nfs_pageio_do_add_request(desc, req)) {
>>>> -		desc->pg_moreio = 1;
>>>> -		nfs_pageio_doio(desc);
>>>> -		if (desc->pg_error < 0)
>>>> -			return 0;
>>>> -		desc->pg_moreio = 0;
>>>> -		if (desc->pg_recoalesce)
>>>> -			return 0;
>>>> -	}
>>>> +	struct nfs_page *subreq;
>>>> +	unsigned int bytes_left = 0;
>>>> +	unsigned int offset, pgbase;
>>>> +
>>>> +	nfs_page_group_lock(req);
>>>> +
>>>> +	subreq = req;
>>>> +	bytes_left = subreq->wb_bytes;
>>>> +	offset = subreq->wb_offset;
>>>> +	pgbase = subreq->wb_pgbase;
>>>> +
>>>> +	do {
>>>> +		if (!nfs_pageio_do_add_request(desc, subreq)) {
>>>> +			/* make sure pg_test call(s) did nothing */
>>>> +			WARN_ON_ONCE(subreq->wb_bytes != bytes_left);
>>>> +			WARN_ON_ONCE(subreq->wb_offset != offset);
>>>> +			WARN_ON_ONCE(subreq->wb_pgbase != pgbase);
>>>> +
>>>> +			nfs_page_group_unlock(req);
>>>> +			desc->pg_moreio = 1;
>>>> +			nfs_pageio_doio(desc);
>>>> +			if (desc->pg_error < 0)
>>>> +				return 0;
>>>> +			desc->pg_moreio = 0;
>>>> +			if (desc->pg_recoalesce)
>>>> +				return 0;
>>>> +			/* retry add_request for this subreq */
>>>> +			nfs_page_group_lock(req);
>>>> +			continue;
>>>> +		}
>>>> +
>>>> +		/* check for buggy pg_test call(s) */
>>>> +		WARN_ON_ONCE(subreq->wb_bytes + subreq->wb_pgbase > PAGE_SIZE);
>>>> +		WARN_ON_ONCE(subreq->wb_bytes > bytes_left);
>>>> +		WARN_ON_ONCE(subreq->wb_bytes == 0);
>>>> +
>>>> +		bytes_left -= subreq->wb_bytes;
>>>> +		offset += subreq->wb_bytes;
>>>> +		pgbase += subreq->wb_bytes;
>>>> +
>>>> +		if (bytes_left) {
>>>> +			subreq = nfs_create_request(req->wb_context,
>>>> +					req->wb_page,
>>>> +					subreq, pgbase, bytes_left);
>>>> +			nfs_lock_request(subreq);
>>>> +			subreq->wb_offset  = offset;
>>>> +			subreq->wb_index = req->wb_index;
>>>> +		}
>>>> +	} while (bytes_left > 0);
>>>> +
>>>> +	nfs_page_group_unlock(req);
>>>> 	return 1;
>>>> }
>>>> 
>>>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>>>> index a48b909..f814e8a 100644
>>>> --- a/fs/nfs/read.c
>>>> +++ b/fs/nfs/read.c
>>>> @@ -85,7 +85,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>>>> 	len = nfs_page_length(page);
>>>> 	if (len == 0)
>>>> 		return nfs_return_empty_page(page);
>>>> -	new = nfs_create_request(ctx, page, 0, len);
>>>> +	new = nfs_create_request(ctx, page, NULL, 0, len);
>>>> 	if (IS_ERR(new)) {
>>>> 		unlock_page(page);
>>>> 		return PTR_ERR(new);
>>>> @@ -311,7 +311,7 @@ readpage_async_filler(void *data, struct page *page)
>>>> 	if (len == 0)
>>>> 		return nfs_return_empty_page(page);
>>>> 
>>>> -	new = nfs_create_request(desc->ctx, page, 0, len);
>>>> +	new = nfs_create_request(desc->ctx, page, NULL, 0, len);
>>>> 	if (IS_ERR(new))
>>>> 		goto out_error;
>>>> 
>>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>>> index 5f1c965..a65755a 100644
>>>> --- a/fs/nfs/write.c
>>>> +++ b/fs/nfs/write.c
>>>> @@ -367,6 +367,8 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
>>>> {
>>>> 	struct nfs_inode *nfsi = NFS_I(inode);
>>>> 
>>>> +	WARN_ON_ONCE(req->wb_this_page != req);
>>>> +
>>>> 	/* Lock the request! */
>>>> 	nfs_lock_request(req);
>>>> 
>>>> @@ -383,6 +385,7 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
>>>> 		set_page_private(req->wb_page, (unsigned long)req);
>>>> 	}
>>>> 	nfsi->npages++;
>>>> +	set_bit(PG_INODE_REF, &req->wb_flags);
>>>> 	kref_get(&req->wb_kref);
>>>> 	spin_unlock(&inode->i_lock);
>>>> }
>>>> @@ -567,6 +570,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
>>>> {
>>>> 	struct nfs_commit_info cinfo;
>>>> 	unsigned long bytes = 0;
>>>> +	bool do_destroy;
>>>> 
>>>> 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
>>>> 		goto out;
>>>> @@ -596,6 +600,7 @@ remove_req:
>>>> next:
>>>> 		nfs_unlock_request(req);
>>>> 		nfs_end_page_writeback(req->wb_page);
>>>> +		do_destroy = !test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags);
>>>> 		nfs_release_request(req);
>>>> 	}
>>>> out:
>>>> @@ -700,6 +705,10 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
>>>> 		if (req == NULL)
>>>> 			goto out_unlock;
>>>> 
>>>> +		/* should be handled by nfs_flush_incompatible */
>>>> +		WARN_ON_ONCE(req->wb_head != req);
>>>> +		WARN_ON_ONCE(req->wb_this_page != req);
>>>> +
>>>> 		rqend = req->wb_offset + req->wb_bytes;
>>>> 		/*
>>>> 		 * Tell the caller to flush out the request if
>>>> @@ -761,7 +770,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
>>>> 	req = nfs_try_to_update_request(inode, page, offset, bytes);
>>>> 	if (req != NULL)
>>>> 		goto out;
>>>> -	req = nfs_create_request(ctx, page, offset, bytes);
>>>> +	req = nfs_create_request(ctx, page, NULL, offset, bytes);
>>>> 	if (IS_ERR(req))
>>>> 		goto out;
>>>> 	nfs_inode_add_request(inode, req);
>>>> @@ -805,6 +814,8 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
>>>> 			return 0;
>>>> 		l_ctx = req->wb_lock_context;
>>>> 		do_flush = req->wb_page != page || req->wb_context != ctx;
>>>> +		/* for now, flush if more than 1 request in page_group */
>>>> +		do_flush |= req->wb_this_page != req;
>>>> 		if (l_ctx && ctx->dentry->d_inode->i_flock != NULL) {
>>>> 			do_flush |= l_ctx->lockowner.l_owner != current->files
>>>> 				|| l_ctx->lockowner.l_pid != current->tgid;
>>>> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
>>>> index 40faddd..b99deb7 100644
>>>> --- a/include/linux/nfs_page.h
>>>> +++ b/include/linux/nfs_page.h
>>>> @@ -26,6 +26,9 @@ enum {
>>>> 	PG_MAPPED,		/* page private set for buffered io */
>>>> 	PG_CLEAN,		/* write succeeded */
>>>> 	PG_COMMIT_TO_DS,	/* used by pnfs layouts */
>>>> +	PG_INODE_REF,		/* extra ref held by inode (head req only) */
>>>> +	PG_HEADLOCK,		/* page group lock of wb_head */
>>>> +	PG_TEARDOWN,		/* page group sync for destroy */
>>>> };
>>>> 
>>>> struct nfs_inode;
>>>> @@ -41,6 +44,8 @@ struct nfs_page {
>>>> 	struct kref		wb_kref;	/* reference count */
>>>> 	unsigned long		wb_flags;
>>>> 	struct nfs_write_verifier	wb_verf;	/* Commit cookie */
>>>> +	struct nfs_page		*wb_this_page;  /* list of reqs for this page */
>>>> +	struct nfs_page		*wb_head;       /* head pointer for req list */
>>>> };
>>>> 
>>>> struct nfs_pageio_descriptor;
>>>> @@ -87,9 +92,10 @@ struct nfs_pageio_descriptor {
>>>> 
>>>> extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
>>>> 					    struct page *page,
>>>> +					    struct nfs_page *last,
>>>> 					    unsigned int offset,
>>>> 					    unsigned int count);
>>>> -extern	void nfs_release_request(struct nfs_page *req);
>>>> +extern	void nfs_release_request(struct nfs_page *);
>>>> 
>>>> 
>>>> extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
>>>> @@ -108,7 +114,10 @@ extern size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
>>>> 				struct nfs_page *req);
>>>> extern  int nfs_wait_on_request(struct nfs_page *);
>>>> extern	void nfs_unlock_request(struct nfs_page *req);
>>>> -extern	void nfs_unlock_and_release_request(struct nfs_page *req);
>>>> +extern	void nfs_unlock_and_release_request(struct nfs_page *);
>>>> +extern void nfs_page_group_lock(struct nfs_page *);
>>>> +extern void nfs_page_group_unlock(struct nfs_page *);
>>>> +extern bool nfs_page_group_sync_on_bit(struct nfs_page *, unsigned int);
>>>> 
>>>> /*
>>>> * Lock the page of an asynchronous request
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

