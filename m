Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:64849 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757354AbaDXRXy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 13:23:54 -0400
Received: by mail-ig0-f175.google.com with SMTP id h3so1167805igd.14
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 10:23:54 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 05/17] nfs: add support for multiple nfs reqs per page
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140424125248.64a12518@tlielax.poochiereds.net>
Date: Thu, 24 Apr 2014 13:23:51 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <1871C427-4D13-44EA-BA69-530A70FD6AA9@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com> <1398202165-78897-6-git-send-email-dros@primarydata.com> <20140424105000.665c159e@tlielax.poochiereds.net> <3DEC13E0-CC9B-498D-A97A-98D77628F672@primarydata.com> <20140424114507.39b24196@tlielax.poochiereds.net> <BC7AC59E-C362-4444-BD35-823193B073BE@primarydata.com> <20140424125248.64a12518@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 24, 2014, at 12:52 PM, Jeff Layton <jlayton@poochiereds.net> wrote:

> On Thu, 24 Apr 2014 12:15:08 -0400
> Weston Andros Adamson <dros@primarydata.com> wrote:
> 
>> On Apr 24, 2014, at 11:45 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
>> 
>>> On Thu, 24 Apr 2014 11:23:19 -0400
>>> Weston Andros Adamson <dros@primarydata.com> wrote:
>>> 
>>>> On Apr 24, 2014, at 10:50 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
>>>> 
>>>>> On Tue, 22 Apr 2014 17:29:13 -0400
>>>>> Weston Andros Adamson <dros@primarydata.com> wrote:
>>>>> 
>>>>>> Add "page groups" - a circular list of nfs requests (struct nfs_page)
>>>>>> that all reference the same page. This gives nfs read and write paths
>>>>>> the ability to account for sub-page regions independently.  This
>>>>>> somewhat follows the design of struct buffer_head's sub-page
>>>>>> accounting.
>>>>>> 
>>>>>> Only "head" requests are ever added/removed from the inode list in
>>>>>> the buffered write path. "head" and "sub" requests are treated the
>>>>>> same through the read path and the rest of the write/commit path.
>>>>>> Requests are given an extra reference across the life of the list.
>>>>>> 
>>>>>> Page groups are never rejoined after being split. If the read/write
>>>>>> request fails and the client falls back to another path (ie revert
>>>>>> to MDS in PNFS case), the already split requests are pushed through
>>>>>> the recoalescing code again, which may split them further and then
>>>>>> coalesce them into properly sized requests on the wire. Fragmentation
>>>>>> shouldn't be a problem with the current design, because we flush all
>>>>>> requests in page group when a non-contiguous request is added, so
>>>>>> the only time resplitting should occur is on a resend of a read or
>>>>>> write.
>>>>>> 
>>>>>> This patch lays the groundwork for sub-page splitting, but does not
>>>>>> actually do any splitting. For now all page groups have one request
>>>>>> as pg_test functions don't yet split pages. There are several related
>>>>>> patches that are needed support multiple requests per page group.
>>>>>> 
>>>>>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>>>>>> ---
>>>>>> fs/nfs/direct.c          |   7 +-
>>>>>> fs/nfs/pagelist.c        | 218 ++++++++++++++++++++++++++++++++++++++++++++---
>>>>>> fs/nfs/read.c            |   4 +-
>>>>>> fs/nfs/write.c           |  12 ++-
>>>>>> include/linux/nfs_page.h |  12 ++-
>>>>>> 5 files changed, 231 insertions(+), 22 deletions(-)
>>>>>> 
>>>>>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>>>>>> index a0c30c5..9d968ca 100644
>>>>>> --- a/fs/nfs/direct.c
>>>>>> +++ b/fs/nfs/direct.c
>>>>>> @@ -380,7 +380,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
>>>>>> 			struct nfs_page *req;
>>>>>> 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
>>>>>> 			/* XXX do we need to do the eof zeroing found in async_filler? */
>>>>>> -			req = nfs_create_request(dreq->ctx, pagevec[i],
>>>>>> +			req = nfs_create_request(dreq->ctx, pagevec[i], NULL,
>>>>>> 						 pgbase, req_len);
>>>>>> 			if (IS_ERR(req)) {
>>>>>> 				result = PTR_ERR(req);
>>>>>> @@ -749,7 +749,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
>>>>>> 			struct nfs_page *req;
>>>>>> 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
>>>>>> 
>>>>>> -			req = nfs_create_request(dreq->ctx, pagevec[i],
>>>>>> +			req = nfs_create_request(dreq->ctx, pagevec[i], NULL,
>>>>>> 						 pgbase, req_len);
>>>>>> 			if (IS_ERR(req)) {
>>>>>> 				result = PTR_ERR(req);
>>>>>> @@ -827,6 +827,8 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
>>>>>> 	spin_unlock(&dreq->lock);
>>>>>> 
>>>>>> 	while (!list_empty(&hdr->pages)) {
>>>>>> +		bool do_destroy = true;
>>>>>> +
>>>>>> 		req = nfs_list_entry(hdr->pages.next);
>>>>>> 		nfs_list_remove_request(req);
>>>>>> 		switch (bit) {
>>>>>> @@ -834,6 +836,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
>>>>>> 		case NFS_IOHDR_NEED_COMMIT:
>>>>>> 			kref_get(&req->wb_kref);
>>>>>> 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
>>>>>> +			do_destroy = false;
>>>>>> 		}
>>>>>> 		nfs_unlock_and_release_request(req);
>>>>>> 	}
>>>>>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>>>>>> index ac4fb64..8cb8e14 100644
>>>>>> --- a/fs/nfs/pagelist.c
>>>>>> +++ b/fs/nfs/pagelist.c
>>>>>> @@ -26,6 +26,8 @@
>>>>>> 
>>>>>> static struct kmem_cache *nfs_page_cachep;
>>>>>> 
>>>>>> +static void nfs_free_request(struct nfs_page *);
>>>>>> +
>>>>>> bool nfs_pgarray_set(struct nfs_page_array *p, unsigned int pagecount)
>>>>>> {
>>>>>> 	p->npages = pagecount;
>>>>>> @@ -133,10 +135,145 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
>>>>>> 	return __nfs_iocounter_wait(c);
>>>>>> }
>>>>>> 
>>>>>> +/*
>>>>>> + * nfs_page_group_lock - lock the head of the page group
>>>>>> + * @req - request in group that is to be locked
>>>>>> + *
>>>>>> + * this lock must be held if modifying the page group list
>>>>>> + */
>>>>>> +void
>>>>>> +nfs_page_group_lock(struct nfs_page *req)
>>>>>> +{
>>>>>> +	struct nfs_page *head = req->wb_head;
>>>>>> +	int err = -EAGAIN;
>>>>>> +
>>>>>> +	WARN_ON_ONCE(head != head->wb_head);
>>>>>> +
>>>>>> +	while (err)
>>>>>> +		err = wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
>>>>>> +			nfs_wait_bit_killable, TASK_KILLABLE);
>>>>>> +}
>>>>>> +
>>>>>> +/*
>>>>>> + * nfs_page_group_unlock - unlock the head of the page group
>>>>>> + * @req - request in group that is to be unlocked
>>>>>> + */
>>>>>> +void
>>>>>> +nfs_page_group_unlock(struct nfs_page *req)
>>>>>> +{
>>>>>> +	struct nfs_page *head = req->wb_head;
>>>>>> +
>>>>>> +	WARN_ON_ONCE(head != head->wb_head);
>>>>>> +
>>>>>> +	smp_mb__before_clear_bit();
>>>>>> +	clear_bit(PG_HEADLOCK, &head->wb_flags);
>>>>>> +	smp_mb__after_clear_bit();
>>>>>> +	wake_up_bit(&head->wb_flags, PG_HEADLOCK);
>>>>>> +}
>>>>>> +
>>>>>> +/*
>>>>>> + * nfs_page_group_sync_on_bit_locked
>>>>>> + *
>>>>>> + * must be called with page group lock held
>>>>>> + */
>>>>>> +static bool
>>>>>> +nfs_page_group_sync_on_bit_locked(struct nfs_page *req, unsigned int bit)
>>>>>> +{
>>>>>> +	struct nfs_page *head = req->wb_head;
>>>>>> +	struct nfs_page *tmp;
>>>>>> +
>>>>>> +	WARN_ON_ONCE(!test_bit(PG_HEADLOCK, &head->wb_flags));
>>>>>> +	WARN_ON_ONCE(test_and_set_bit(bit, &req->wb_flags));
>>>>>> +
>>>>>> +	tmp = req->wb_this_page;
>>>>>> +	while (tmp != req) {
>>>>>> +		if (!test_bit(bit, &tmp->wb_flags))
>>>>>> +			return false;
>>>>>> +		tmp = tmp->wb_this_page;
>>>>>> +	}
>>>>>> +
>>>>>> +	/* true! reset all bits */
>>>>>> +	tmp = req;
>>>>>> +	do {
>>>>>> +		clear_bit(bit, &tmp->wb_flags);
>>>>>> +		tmp = tmp->wb_this_page;
>>>>>> +	} while (tmp != req);
>>>>>> +
>>>>>> +	return true;
>>>>>> +}
>>>>>> +
>>>>>> +/*
>>>>>> + * nfs_page_group_sync_on_bit - set bit on current request, but only
>>>>>> + *   return true if the bit is set for all requests in page group
>>>>>> + * @req - request in page group
>>>>>> + * @bit - PG_* bit that is used to sync page group
>>>>>> + */
>>>>>> +bool nfs_page_group_sync_on_bit(struct nfs_page *req, unsigned int bit)
>>>>>> +{
>>>>>> +	bool ret;
>>>>>> +
>>>>>> +	nfs_page_group_lock(req);
>>>>>> +	ret = nfs_page_group_sync_on_bit_locked(req, bit);
>>>>>> +	nfs_page_group_unlock(req);
>>>>>> +
>>>>>> +	return ret;
>>>>>> +}
>>>>>> +
>>>>>> +/*
>>>>>> + * nfs_page_group_init - Initialize the page group linkage for @req
>>>>>> + * @req - a new nfs request
>>>>>> + * @prev - the previous request in page group, or NULL if @req is the first
>>>>>> + *         or only request in the group (the head).
>>>>>> + */
>>>>>> +static inline void
>>>>>> +nfs_page_group_init(struct nfs_page *req, struct nfs_page *prev)
>>>>>> +{
>>>>>> +	WARN_ON_ONCE(prev == req);
>>>>>> +
>>>>>> +	if (!prev) {
>>>>>> +		req->wb_head = req;
>>>>>> +		req->wb_this_page = req;
>>>>>> +	} else {
>>>>>> +		WARN_ON_ONCE(prev->wb_this_page != prev->wb_head);
>>>>>> +		WARN_ON_ONCE(!test_bit(PG_HEADLOCK, &prev->wb_head->wb_flags));
>>>>>> +		req->wb_head = prev->wb_head;
>>>>>> +		req->wb_this_page = prev->wb_this_page;
>>>>>> +		prev->wb_this_page = req;
>>>>>> +	}
>>>>>> +}
>>>>>> +
>>>>>> +/*
>>>>>> + * nfs_page_group_destroy - sync the destruction of page groups
>>>>>> + * @req - request that no longer needs the page group
>>>>>> + *
>>>>>> + * releases the page group reference from each member once all
>>>>>> + * members have called this function.
>>>>>> + */
>>>>>> +static void
>>>>>> +nfs_page_group_destroy(struct kref *kref)
>>>>>> +{
>>>>>> +	struct nfs_page *req = container_of(kref, struct nfs_page, wb_kref);
>>>>>> +	struct nfs_page *tmp, *next;
>>>>>> +
>>>>>> +	if (!nfs_page_group_sync_on_bit(req, PG_TEARDOWN))
>>>>>> +		return;
>>>>>> +
>>>>>> +	tmp = req;
>>>>>> +	do {
>>>>>> +		next = tmp->wb_this_page;
>>>>>> +		/* unlink and free */
>>>>>> +		tmp->wb_this_page = tmp;
>>>>>> +		tmp->wb_head = tmp;
>>>>>> +		nfs_free_request(tmp);
>>>>>> +		tmp = next;
>>>>>> +	} while (tmp != req);
>>>>>> +}
>>>>>> +
>>>>>> /**
>>>>>> * nfs_create_request - Create an NFS read/write request.
>>>>>> * @ctx: open context to use
>>>>>> * @page: page to write
>>>>>> + * @last: last nfs request created for this page group or NULL if head
>>>>>> * @offset: starting offset within the page for the write
>>>>>> * @count: number of bytes to read/write
>>>>>> *
>>>>>> @@ -146,7 +283,8 @@ nfs_iocounter_wait(struct nfs_io_counter *c)
>>>>>> */
>>>>>> struct nfs_page *
>>>>>> nfs_create_request(struct nfs_open_context *ctx, struct page *page,
>>>>>> -		   unsigned int offset, unsigned int count)
>>>>>> +		   struct nfs_page *last, unsigned int offset,
>>>>>> +		   unsigned int count)
>>>>>> {
>>>>>> 	struct nfs_page		*req;
>>>>>> 	struct nfs_lock_context *l_ctx;
>>>>>> @@ -178,6 +316,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
>>>>>> 	req->wb_bytes   = count;
>>>>>> 	req->wb_context = get_nfs_open_context(ctx);
>>>>>> 	kref_init(&req->wb_kref);
>>>>>> +	nfs_page_group_init(req, last);
>>>>>> 	return req;
>>>>>> }
>>>>>> 
>>>>>> @@ -235,16 +374,22 @@ static void nfs_clear_request(struct nfs_page *req)
>>>>>> 	}
>>>>>> }
>>>>>> 
>>>>>> -
>>>>>> /**
>>>>>> * nfs_release_request - Release the count on an NFS read/write request
>>>>>> * @req: request to release
>>>>>> *
>>>>>> * Note: Should never be called with the spinlock held!
>>>>>> */
>>>>>> -static void nfs_free_request(struct kref *kref)
>>>>>> +static void nfs_free_request(struct nfs_page *req)
>>>>>> {
>>>>>> -	struct nfs_page *req = container_of(kref, struct nfs_page, wb_kref);
>>>>>> +	WARN_ON_ONCE(req->wb_this_page != req);
>>>>>> +
>>>>>> +	/* extra debug: make sure no sync bits are still set */
>>>>>> +	WARN_ON_ONCE(test_bit(PG_TEARDOWN, &req->wb_flags));
>>>>>> +	WARN_ON_ONCE(test_bit(PG_UNLOCKPAGE, &req->wb_flags));
>>>>>> +	WARN_ON_ONCE(test_bit(PG_UPTODATE, &req->wb_flags));
>>>>>> +	WARN_ON_ONCE(test_bit(PG_WB_END, &req->wb_flags));
>>>>>> +	WARN_ON_ONCE(test_bit(PG_REMOVE, &req->wb_flags));
>>>>>> 
>>>>>> 	/* Release struct file and open context */
>>>>>> 	nfs_clear_request(req);
>>>>>> @@ -253,7 +398,7 @@ static void nfs_free_request(struct kref *kref)
>>>>>> 
>>>>>> void nfs_release_request(struct nfs_page *req)
>>>>>> {
>>>>>> -	kref_put(&req->wb_kref, nfs_free_request);
>>>>>> +	kref_put(&req->wb_kref, nfs_page_group_destroy);
>>>>>> }
>>>>>> 
>>>>>> static int nfs_wait_bit_uninterruptible(void *word)
>>>>>> @@ -439,21 +584,66 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
>>>>>> * @desc: destination io descriptor
>>>>>> * @req: request
>>>>>> *
>>>>>> + * This may split a request into subrequests which are all part of the
>>>>>> + * same page group.
>>>>>> + *
>>>>>> * Returns true if the request 'req' was successfully coalesced into the
>>>>>> * existing list of pages 'desc'.
>>>>>> */
>>>>>> static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
>>>>>> 			   struct nfs_page *req)
>>>>>> {
>>>>>> -	while (!nfs_pageio_do_add_request(desc, req)) {
>>>>>> -		desc->pg_moreio = 1;
>>>>>> -		nfs_pageio_doio(desc);
>>>>>> -		if (desc->pg_error < 0)
>>>>>> -			return 0;
>>>>>> -		desc->pg_moreio = 0;
>>>>>> -		if (desc->pg_recoalesce)
>>>>>> -			return 0;
>>>>>> -	}
>>>>>> +	struct nfs_page *subreq;
>>>>>> +	unsigned int bytes_left = 0;
>>>>>> +	unsigned int offset, pgbase;
>>>>>> +
>>>>>> +	nfs_page_group_lock(req);
>>>>>> +
>>>>>> +	subreq = req;
>>>>>> +	bytes_left = subreq->wb_bytes;
>>>>>> +	offset = subreq->wb_offset;
>>>>>> +	pgbase = subreq->wb_pgbase;
>>>>>> +
>>>>>> +	do {
>>>>>> +		if (!nfs_pageio_do_add_request(desc, subreq)) {
>>>>>> +			/* make sure pg_test call(s) did nothing */
>>>>>> +			WARN_ON_ONCE(subreq->wb_bytes != bytes_left);
>>>>>> +			WARN_ON_ONCE(subreq->wb_offset != offset);
>>>>>> +			WARN_ON_ONCE(subreq->wb_pgbase != pgbase);
>>>>>> +
>>>>>> +			nfs_page_group_unlock(req);
>>>>>> +			desc->pg_moreio = 1;
>>>>>> +			nfs_pageio_doio(desc);
>>>>>> +			if (desc->pg_error < 0)
>>>>>> +				return 0;
>>>>>> +			desc->pg_moreio = 0;
>>>>>> +			if (desc->pg_recoalesce)
>>>>>> +				return 0;
>>>>>> +			/* retry add_request for this subreq */
>>>>>> +			nfs_page_group_lock(req);
>>>>>> +			continue;
>>>>>> +		}
>>>>>> +
>>>>>> +		/* check for buggy pg_test call(s) */
>>>>>> +		WARN_ON_ONCE(subreq->wb_bytes + subreq->wb_pgbase > PAGE_SIZE);
>>>>>> +		WARN_ON_ONCE(subreq->wb_bytes > bytes_left);
>>>>>> +		WARN_ON_ONCE(subreq->wb_bytes == 0);
>>>>>> +
>>>>>> +		bytes_left -= subreq->wb_bytes;
>>>>>> +		offset += subreq->wb_bytes;
>>>>>> +		pgbase += subreq->wb_bytes;
>>>>>> +
>>>>>> +		if (bytes_left) {
>>>>>> +			subreq = nfs_create_request(req->wb_context,
>>>>>> +					req->wb_page,
>>>>>> +					subreq, pgbase, bytes_left);
>>>>>> +			nfs_lock_request(subreq);
>>>>>> +			subreq->wb_offset  = offset;
>>>>>> +			subreq->wb_index = req->wb_index;
>>>>>> +		}
>>>>>> +	} while (bytes_left > 0);
>>>>>> +
>>>>>> +	nfs_page_group_unlock(req);
>>>>>> 	return 1;
>>>>>> }
>>>>>> 
>>>>>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>>>>>> index 95a0855..ee0a3cd 100644
>>>>>> --- a/fs/nfs/read.c
>>>>>> +++ b/fs/nfs/read.c
>>>>>> @@ -139,7 +139,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
>>>>>> 	len = nfs_page_length(page);
>>>>>> 	if (len == 0)
>>>>>> 		return nfs_return_empty_page(page);
>>>>>> -	new = nfs_create_request(ctx, page, 0, len);
>>>>>> +	new = nfs_create_request(ctx, page, NULL, 0, len);
>>>>>> 	if (IS_ERR(new)) {
>>>>>> 		unlock_page(page);
>>>>>> 		return PTR_ERR(new);
>>>>>> @@ -600,7 +600,7 @@ readpage_async_filler(void *data, struct page *page)
>>>>>> 	if (len == 0)
>>>>>> 		return nfs_return_empty_page(page);
>>>>>> 
>>>>>> -	new = nfs_create_request(desc->ctx, page, 0, len);
>>>>>> +	new = nfs_create_request(desc->ctx, page, NULL, 0, len);
>>>>>> 	if (IS_ERR(new))
>>>>>> 		goto out_error;
>>>>>> 
>>>>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>>>>> index ca20ec7..d1453f2 100644
>>>>>> --- a/fs/nfs/write.c
>>>>>> +++ b/fs/nfs/write.c
>>>>>> @@ -461,7 +461,7 @@ static void nfs_inode_remove_request(struct nfs_page *req)
>>>>>> 	}
>>>>>> 	nfsi->npages--;
>>>>>> 	spin_unlock(&inode->i_lock);
>>>>>> -	nfs_release_request(req);
>>>>>> +	nfs_release_request(head);
>>>>>> }
>>>>>> 
>>>>>> static void
>>>>>> @@ -625,6 +625,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
>>>>>> {
>>>>>> 	struct nfs_commit_info cinfo;
>>>>>> 	unsigned long bytes = 0;
>>>>>> +	bool do_destroy;
>>>>>> 
>>>>>> 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
>>>>>> 		goto out;
>>>>>> @@ -654,6 +655,7 @@ remove_req:
>>>>>> next:
>>>>>> 		nfs_unlock_request(req);
>>>>>> 		nfs_end_page_writeback(req->wb_page);
>>>>>> +		do_destroy = !test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags);
>>>>>> 		nfs_release_request(req);
>>>>>> 	}
>>>>>> out:
>>>>>> @@ -758,6 +760,10 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
>>>>>> 		if (req == NULL)
>>>>>> 			goto out_unlock;
>>>>>> 
>>>>>> +		/* should be handled by nfs_flush_incompatible */
>>>>>> +		WARN_ON_ONCE(req->wb_head != req);
>>>>>> +		WARN_ON_ONCE(req->wb_this_page != req);
>>>>>> +
>>>>>> 		rqend = req->wb_offset + req->wb_bytes;
>>>>>> 		/*
>>>>>> 		 * Tell the caller to flush out the request if
>>>>>> @@ -819,7 +825,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
>>>>>> 	req = nfs_try_to_update_request(inode, page, offset, bytes);
>>>>>> 	if (req != NULL)
>>>>>> 		goto out;
>>>>>> -	req = nfs_create_request(ctx, page, offset, bytes);
>>>>>> +	req = nfs_create_request(ctx, page, NULL, offset, bytes);
>>>>>> 	if (IS_ERR(req))
>>>>>> 		goto out;
>>>>>> 	nfs_inode_add_request(inode, req);
>>>>>> @@ -863,6 +869,8 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
>>>>>> 			return 0;
>>>>>> 		l_ctx = req->wb_lock_context;
>>>>>> 		do_flush = req->wb_page != page || req->wb_context != ctx;
>>>>>> +		/* for now, flush if more than 1 request in page_group */
>>>>>> +		do_flush |= req->wb_this_page != req;
>>>>>> 		if (l_ctx && ctx->dentry->d_inode->i_flock != NULL) {
>>>>>> 			do_flush |= l_ctx->lockowner.l_owner != current->files
>>>>>> 				|| l_ctx->lockowner.l_pid != current->tgid;
>>>>>> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
>>>>>> index 214e098..1fb161b 100644
>>>>>> --- a/include/linux/nfs_page.h
>>>>>> +++ b/include/linux/nfs_page.h
>>>>>> @@ -26,6 +26,8 @@ enum {
>>>>>> 	PG_MAPPED,		/* page private set for buffered io */
>>>>>> 	PG_CLEAN,		/* write succeeded */
>>>>>> 	PG_COMMIT_TO_DS,	/* used by pnfs layouts */
>>>>>> +	PG_HEADLOCK,		/* page group lock of wb_head */
>>>>>> +	PG_TEARDOWN,		/* page group sync for destroy */
>>>>>> };
>>>>>> 
>>>>>> struct nfs_inode;
>>>>>> @@ -41,6 +43,8 @@ struct nfs_page {
>>>>>> 	struct kref		wb_kref;	/* reference count */
>>>>>> 	unsigned long		wb_flags;
>>>>>> 	struct nfs_write_verifier	wb_verf;	/* Commit cookie */
>>>>>> +	struct nfs_page		*wb_this_page;  /* list of reqs for this page */
>>>>>> +	struct nfs_page		*wb_head;       /* head pointer for req list */
>>>>> 
>>>>> Hmm ok, so to make sure I understand...
>>>>> 
>>>>> So page->private will point to the "head" req (struct page_private).
>>>> 
>>>> Only in the buffered write case.  Page->private is not set for read path / direct i/o path.
>>>> 
>>>>> Then we'll have a singly-linked list of reqs hanging off of
>>>>> wb_this_page. Is that right?
>>>>> 
>>>>> If so, then it seems like it would be clearer to use a standard
>>>>> list_head here. If you need to get to the wb_head, you could always do
>>>>> something like this:
>>>>> 
>>>>> 	list_first_entry(&req->wb_page->wb_this_page);
>>>> 
>>>> Well, wb_page is a struct page and doesn’t have wb_this_page (which is in struct
>>>> nfs_page), but I see where you’re going with this.
>>>> 
>>> 
>>> Doh, right! Sorry, I threw that together in haste, but you get the
>>> idea. I was thinking you could go back to the page and dereference
>>> ->private.
>>> 
>>>> A strategy like this only works if we always have page->private pointing to the head
>>>> request. We chose not to go that way because it messes with the buffered
>>>> write path’s setting / clearing of page private which interacts with the swappable
>>>> nfs pages code that everyone seems to be afraid to touch ;)
>>>> 
>>>> So we decided to go this route (not messing with page_private) as a first step - we
>>>> certainly could add it later, but the current approach makes things less complex.
>>>> 
>>> 
>>> Ok, that makes sense. Thanks...
>>> 
>>>>> 
>>>>> ...and could even turn that into a macro or static inline for some
>>>>> syntactic sugar. It's a little more pointer chasing to find the head,
>>>>> but it seems like that would be clearer than using yet another
>>>>> linked-list implementation.
>>>> 
>>>> So, I’m not against using list_head.. I didn’t go that route initially because I was:
>>>> 
>>>> 1) following the buffer_head example, which rolls it’s own list
>>>> 
>>> 
>>> I wouldn't be surprised if the buffer_head code predates the standard
>>> linked-list macros, so that probably explains why they did it that way.
>>> The file locking code has a similar construct in inode->i_flock list.
>> 
>> AFAIK the sub-page functionality was added somewhat recently. 
>> 
>>> 
>>>> 2) trying to grow nfs_page as little as possible - but we might have room within
>>>>    the allocator bucket it currently lives in…
>>>> 
>>> 
>>> nfs_page comes out of a dedicated slabcache, so that probably won't be the case.
>> 
>> Ah, right!
>> 
>>> 
>>>> 3) not sure list_head is suitable for a circular list (I haven’t ever looked into it).
>>>> 
>>>> and until we have a way to find the head request (via page private, etc) without
>>>> walking the circular list (chicken / egg problem needing to grab head lock before walking
>>>> list to find the head to lock it), we’ll still need the head pointer.
>>>> 
>>>> Thoughts?
>>>> 
>>>> -dros
>>>> 
>>> 
>>> If you can't rely on page->private pointing to the request, then that
>>> does make it tough to do what I was suggesting. struct list_head lists
>>> are doubly-linked and circular by nature, so that does seem to be a
>>> natural fit for what you're trying to do.
>> 
>> Oh I see -- you’re totally right about list_head being circular, one just has
>> to call for_each on whatever head they wish to start from.
>> 
>>> 
>>> The only problem is that struct list_head is two pointers instead of
>>> one, so it's not going to be as space-efficient as what you're doing
>>> here. If that's a large concern then you may have no choice but to do
>>> this after all.
>> 
>> Right. How much do we care about an extra pointer here?  It seems to me
>> that we should try to keep it as small as possible - I know Trond has been unwilling
>> to add members to rpc_task (for example) unless absolutely necessary and there will
>> be at least one (if not more) nfs_page structures per rpc_task.
>> 
> 
> Well there are potentially a lot of these structs, so an extra pointer
> in each adds up.

Indeed.

> 
> In fact, if only the head req is ever on the per-inode list, then I
> guess the wb_list is unused for sub requests, right? That might be an
> opportunity for space savings too -- you could union wb_head and
> wb_list, and use a wb_flag to indicate which is valid…

There isn’t actually an inode list, even though I think I mentioned something like that 
recently ;)

The write path uses nfs_inode_(add|remove)_request to:

 - hold an extra reference to handle handoff between write list and commit list.
 - handle setting / clearing page_private for swappable page semantics
 - per inode page counting book keeping.

wb_list is used on sub requests exactly like head requests - for keeping them on
read/write/commit lists for passing through pgio layer.
 
-dros

> 
>> One immediate takeaway: I need to add much better comments about this.
>> 
>> As far as eventually removing the wb_head pointer, it gets really ugly to do without
>> changing the buffered write path (and swappable page semantics) because page_group
>> operations happen *after* nfs_inode_remove_request() clears page_private (syncing the
>> destruction of the page group). This means that nfs_release_request and 
>> nfs_unlock_and_release_request will both have to be passed a previously cached head
>> pointer.  yuck.
>> 
> 
> Ahh right -- that is tricky then. I'd have to ponder that a bit more...
> -- 
> Jeff Layton <jlayton@poochiereds.net>

