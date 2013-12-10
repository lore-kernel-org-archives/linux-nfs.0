Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:2426 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040Ab3LJTLb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2013 14:11:31 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Tue, 10 Dec 2013 19:11:30 +0000
Message-ID: <1556485E-F391-4F58-AEE3-07C829DA2DB1@netapp.com>
References: <1385068813-5491-1-git-send-email-dros@netapp.com>
 <1386699230.2879.26.camel@leira.trondhjem.org>
In-Reply-To: <1386699230.2879.26.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 10, 2013, at 1:13 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, 2013-11-21 at 16:20 -0500, Weston Andros Adamson wrote:
>> Fix a bug where getxattr returns ERANGE when the attr buffer
>> length is close enough to the nearest PAGE_SIZE multiple that adding
>> the extra bytes leaves too little room for the ACL buffer.
>> 
>> Besides storing the ACL buffer, the getacl decoder uses the inline
>> pages for the attr bitmap and buffer length. __nfs4_get_acl_uncached
>> must allocate enough page space for all of the data to be decoded.
>> 
>> This patch uses xdr_partial_copy_from_skb to allocate any needed
>> pages past the first one. This allows the client to always cache the acl
>> on the first getacl call and not just if it fits in one page.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> 
>> Version 2 of this patch changes things up a bit:
>> 
>> - rely on xdr_partial_copy_from_skb to allocate pages as needed
>> - always allocate 1 page as there will be some data
>> - allow xdr_partial_copy_from_skb to allocate up to NFS4ACL_MAXPAGES + 1 pages
>>   to hold the max size ACL and the extra page for the bitmap and acl length
>> - this allows the first request for an ACL to be cached - not just when it
>>   fits in one page
>> 
>> fs/nfs/nfs4proc.c | 40 +++++++++++++++-------------------------
>> fs/nfs/nfs4xdr.c  |  2 --
>> 2 files changed, 15 insertions(+), 27 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index ca36d0d..dc8e4f5 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -4430,20 +4430,17 @@ out:
>> /*
>>  * The getxattr API returns the required buffer length when called with a
>>  * NULL buf. The NFSv4 acl tool then calls getxattr again after allocating
>> - * the required buf.  On a NULL buf, we send a page of data to the server
>> - * guessing that the ACL request can be serviced by a page. If so, we cache
>> - * up to the page of ACL data, and the 2nd call to getxattr is serviced by
>> - * the cache. If not so, we throw away the page, and cache the required
>> - * length. The next getxattr call will then produce another round trip to
>> - * the server, this time with the input buf of the required size.
>> + * the required buf. Cache the result from the first getxattr call to avoid
>> + * sending another RPC.
>>  */
>> static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
>> {
>> -	struct page *pages[NFS4ACL_MAXPAGES] = {NULL, };
>> +	/* enough pages to hold ACL data plus the bitmap and acl length */
>> +	struct page *pages[NFS4ACL_MAXPAGES + 1] = {NULL, };
> 
> Why the change to the array length? From what I can see, you are making
> everything else depend on ARRAY_LENGTH(pages).

So we can fit NFS4ACL_MAXPAGES (which is XATTR_SIZE_MAX / PAGE_SIZE) AND the bitmap (which being variable length must also use the inline pages), otherwise we will always fail for ACL data sized near XATTR_SIZE_MAX, even though we should support it.  I figure that a page is more than enough for the bitmap even when future-proofing nfsv4.X, but we’ll always need that extra page when the actual ACL data is XATTR_SIZE bytes long. 

> 
>> 	struct nfs_getaclargs args = {
>> 		.fh = NFS_FH(inode),
>> +		/* The xdr layer may allocate pages here. */
>> 		.acl_pages = pages,
>> -		.acl_len = buflen,
>> 	};
>> 	struct nfs_getaclres res = {
>> 		.acl_len = buflen,
>> @@ -4453,32 +4450,25 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>> 		.rpc_argp = &args,
>> 		.rpc_resp = &res,
>> 	};
>> -	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
>> 	int ret = -ENOMEM, i;
>> 
>> -	/* As long as we're doing a round trip to the server anyway,
>> -	 * let's be prepared for a page of acl data. */
>> -	if (npages == 0)
>> -		npages = 1;
>> -	if (npages > ARRAY_SIZE(pages))
>> -		return -ERANGE;
>> -
>> -	for (i = 0; i < npages; i++) {
>> -		pages[i] = alloc_page(GFP_KERNEL);
>> -		if (!pages[i])
>> -			goto out_free;
>> -	}
>> +	/*
>> +	 * There will be some data returned by the server, how much is not
>> +	 * known yet. Allocate one page and let the XDR layer allocate
>> +	 * more if needed.
>> +	 */
>> +	pages[0] = alloc_page(GFP_KERNEL);
>> 
>> 	/* for decoding across pages */
>> 	res.acl_scratch = alloc_page(GFP_KERNEL);
>> 	if (!res.acl_scratch)
>> 		goto out_free;
>> 
>> -	args.acl_len = npages * PAGE_SIZE;
>> +	args.acl_len = ARRAY_SIZE(pages) << PAGE_SHIFT;
>> 	args.acl_pgbase = 0;
>> 
>> -	dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
>> -		__func__, buf, buflen, npages, args.acl_len);
>> +	dprintk("%s  buf %p buflen %zu args.acl_len %zu\n",
>> +		__func__, buf, buflen, args.acl_len);
>> 	ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
>> 			     &msg, &args.seq_args, &res.seq_res, 0);
>> 	if (ret)
>> @@ -4503,7 +4493,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
>> out_ok:
>> 	ret = res.acl_len;
>> out_free:
>> -	for (i = 0; i < npages; i++)
>> +	for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
>> 		if (pages[i])
>> 			__free_page(pages[i]);
> 
> What happens now when the server tries to return an ACL that won't fit
> in the above array? Do we still return ERANGE?

Yes, the XDR layer will set NFS4_ACL_TRUNC if the ACL data doesn’t fit in args.acl_len, and __nfs4_get_acl_uncached still checks for this flag, returning -ERANGE if set.

> 
> Also, are we still safe w.r.t. checking that we don't copy more than
> 'buflen' bytes of data?

Yes, the xdr inline page filler enforces this - and we set the max in nfs4_xdr_enc_getacl:

      xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
                args->acl_pages, args->acl_pgbase, args->acl_len);

> 
>> 	if (res.acl_scratch)
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 5be2868..4e2e2da 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -5207,8 +5207,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
>> 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
>> 		goto out;
>> 
>> -	xdr_enter_page(xdr, xdr->buf->page_len);
> 
> Why is this being removed?

Because it BUG()s! ;)

I must admit that I don’t get why xdr_enter_page() doesn’t work when the XDR layer does the page allocation, but it does not — and the nfs3xdr ACL code (which uses the XDR layer allocation) also doesn’t call this.  It worked well without this, so I just removed it and didn’t investigate why.

-dros

> 
>> -
>> 	/* Calculate the offset of the page data */
>> 	pg_offset = xdr->buf->head[0].iov_len;
>> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

