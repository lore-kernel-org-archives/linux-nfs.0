Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41989 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdGEOgW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jul 2017 10:36:22 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] sunrpc: Allocate up to RPCSVC_MAXPAGES per svc_rqst
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <794E47E1-E7D0-4B10-A5C7-0C5DF97F9DB9@oracle.com>
Date: Wed, 5 Jul 2017 10:36:17 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5E60EBFD-F5D6-4959-A590-34ACBDC95202@oracle.com>
References: <20170630160258.11995.10205.stgit@klimt.1015granger.net> <20170630201653.GD14868@fieldses.org> <222F5E88-CC11-418B-B9FF-1EF10DE60BEB@oracle.com> <20170630204733.GE14868@fieldses.org> <794E47E1-E7D0-4B10-A5C7-0C5DF97F9DB9@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-


> On Jun 30, 2017, at 5:23 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> 
>> On Jun 30, 2017, at 4:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>> On Fri, Jun 30, 2017 at 04:33:23PM -0400, Chuck Lever wrote:
>>> 
>>>> On Jun 30, 2017, at 4:16 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>> 
>>>> I like that better.
>>>> 
>>>> I'm still pretty confused.
>>>> 
>>>> The long comment above RPCSVC_MAXPAGES convinces me that it's
>>>> calculating the maximum number of pages a TCP request might need.  But
>>>> apparently rq_pages has never been large enough to hold that many pages.
>>>> Has nobody ever tried an unaligned 1MB read?
>>> 
>>> I'm not sure how the TCP transport works. If it tries to fill the
>>> head iovec completely, then goes into the page list, then it might
>>> not ever need the extra page on the end for the GETATTR.
>> 
>> I think an unaligned read of N pages ends up with rq_pages like:
>> 
>> 	1st page: read request
>> 	2nd page: head+tail of reply
>> 	3rd page: partial first page of read data
>> 	N-1 pages: read data
>> 	last page: partial last page of read data
>> 
>> So, N+3 pages.
> 
> OK. Again, I'm not aware of a workload that specifically asks
> for an unaligned 1MB READ. Payloads of that size are generally
> page-aligned at least, and probably aligned to 1MB, because
> they are usually reads into a client's page cache.
> 
> For an NFSv4.0 WRITE request on NFS/RDMA we need the same
> number of pages, but for different reasons:
> 
> 	1st page: transport header and head of Call
> 	N pages: write data
> 	N+1 page: trailing NFSv4 operations and MIC
> 	last page: reply
> 
> So, N+3 pages.
> 
> I would argue we probably want to accommodate an unaligned 1MB
> write here eventually, by adding one more page. But I don't
> know of a workload that would generate one today.
> 
> 
>>> For NFS/RDMA, the transport currently aligns the incoming data so
>>> it always starts at byte 0 of the first page in the xdr_buf's page
>>> list. That's going to have to change if we want direct placement
>>> of the write payload, and at that point an unaligned payload will
>>> be possible.
>>> 
>>> 
>>>> We could use comments each time elsewhere when we add another random 1
>>>> or 2 somewhere.  What does sv_max_mesg really mean, why are we adding 2
>>>> to it in svc_alloc_arg, etc.
>>> 
>>> I'm open to suggestions. A comment in svc_alloc_arg might just
>>> refer weary readers to the comment in front of the definition of
>>> RPCSVC_MAXPAGES.
>> 
>> There's 3 extra pages in rq_pages beyond what's needed to hold a max IO
>> size buffer, and I'd like the comment to explain *which* 2 of those
>> three pages we're accounting for here.  I could figure that out if I
>> knew what xv_max_mesg meant, but the comment there just says 1 page is
>> added for "overhead", which isn't helpful.
> 
> So here's how sv_max_mesg is set:
> 
> serv->sv_max_mesg  = roundup(serv->sv_max_payload + PAGE_SIZE, PAGE_SIZE);
> 
> It's the max payload size (1MB) plus a page. Let's assume this
> extra page accounts for a non-page-aligned payload.
> 
> In svc_alloc_arg, the "pages" calculation was adding just another
> page, which gives us only N+2 pages. It should be making the same
> calculation as the one described in front of RPCSVC_MAXPAGES to
> give us N+3.
> 
> At a guess, the two additional pages in svc_alloc_arg are for
> the request, and for the head+tail of the reply.
> 
> The problem is, the pages are accounted for differently for an
> NFS READ or an NFS WRITE (see above). So this kind of comment
> doesn't make sense to me in a generic function like svc_alloc_arg.
> 
> I would stick to saying "this allows the allocation of up to
> RPCSVC_MAXPAGES pages" and leave it to other areas of the code
> to decide how to use them.

I would like to get this resolved quickly so that my nfsd-rdma-for-4.13
series can be included in v4.13.

Is the v1 patch acceptable, or do we need a comment here? If a comment
is necessary, please provide the text you want to see.


>>> Let me know if there's anything else you want to see changed, or
>>> if this patch is now acceptable.
>>> 
>>> 
>>>> Might make more sense if RPCSVC_MAXPAYLOAD was explicitly calculated as
>>>> a max over the compiled-in transports, too.
>>> 
>>> IMO sv_max_mesg could be expressed in pages, instead of bytes, so
>>> that the computation in svc_alloc_arg isn't repeated for every RPC.
>> 
>> Makes sense to me.
>> 
>>> 
>>> 
>>>> I feel like we've actually been through this before, but somehow I'm
>>>> still confused every time I look at it.
>>>> 
>>>> --b.
>>>> 
>>>> On Fri, Jun 30, 2017 at 12:03:54PM -0400, Chuck Lever wrote:
>>>>> svcrdma needs 259 pages for 1MB NFSv4.0 READ requests:
>>> 
>>> This should be
>>> 
>>> "svcrdma needs 259 pages for 1MB NFSv4.0 WRITE requests:"
>> 
>> Oh, got it.
>> 
>> --b.
>> 
>>> 
>>> 
>>>>> - 1 page for the transport header and head iovec
>>>>> - 256 pages for the data payload
>>>>> - 1 page for the trailing GETATTR request (since NFSD XDR decoding
>>>>> does not look for a tail iovec, the GETATTR is stuck at the end
>>>>> of the rqstp->rq_arg.pages list)
>>>>> - 1 page for building the reply xdr_buf
>>>>> 
>>>>> But RPCSVC_MAXPAGES is already 259 (on x86_64). The problem is that
>>>>> svc_alloc_arg never allocates that many pages. To address this:
>>>>> 
>>>>> 1. The final element of rq_pages always points to NULL. To
>>>>> accommodate up to 259 pages in rq_pages, add an extra element
>>>>> to rq_pages for the array termination sentinel.
>>>>> 
>>>>> 2. Adjust the calculation of "pages" to match how RPCSVC_MAXPAGES
>>>>> is calculated, so it can go up to 259. Bruce noted that the
>>>>> calculation assumes sv_max_mesg is a multiple of PAGE_SIZE,
>>>>> which might not always be true. I didn't change this assumption.
>>>>> 
>>>>> 3. Change the loop boundaries to allow 259 pages to be allocated.
>>>>> 
>>>>> Additional clean-up: WARN_ON_ONCE adds an extra conditional branch,
>>>>> which is basically never taken. And there's no need to dump the
>>>>> stack here because svc_alloc_arg has only one caller.
>>>>> 
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>> Hi Bruce-
>>>>> 
>>>>> This is what I proposed yesterday evening. Instead of changing
>>>>> the value of RPCSVC_MAXPAGES, ensure that svc_alloc_arg can
>>>>> safely allocate that many pages.
>>>>> 
>>>>> 
>>>>> include/linux/sunrpc/svc.h |    2 +-
>>>>> net/sunrpc/svc_xprt.c      |   10 ++++++----
>>>>> 2 files changed, 7 insertions(+), 5 deletions(-)
>>>>> 
>>>>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>>>>> index 11cef5a..d741399 100644
>>>>> --- a/include/linux/sunrpc/svc.h
>>>>> +++ b/include/linux/sunrpc/svc.h
>>>>> @@ -246,7 +246,7 @@ struct svc_rqst {
>>>>> 	size_t			rq_xprt_hlen;	/* xprt header len */
>>>>> 	struct xdr_buf		rq_arg;
>>>>> 	struct xdr_buf		rq_res;
>>>>> -	struct page *		rq_pages[RPCSVC_MAXPAGES];
>>>>> +	struct page		*rq_pages[RPCSVC_MAXPAGES + 1];
>>>>> 	struct page *		*rq_respages;	/* points into rq_pages */
>>>>> 	struct page *		*rq_next_page; /* next reply page to use */
>>>>> 	struct page *		*rq_page_end;  /* one past the last page */
>>>>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>>>>> index 7bfe1fb..d16a8b4 100644
>>>>> --- a/net/sunrpc/svc_xprt.c
>>>>> +++ b/net/sunrpc/svc_xprt.c
>>>>> @@ -659,11 +659,13 @@ static int svc_alloc_arg(struct svc_rqst *rqstp)
>>>>> 	int i;
>>>>> 
>>>>> 	/* now allocate needed pages.  If we get a failure, sleep briefly */
>>>>> -	pages = (serv->sv_max_mesg + PAGE_SIZE) / PAGE_SIZE;
>>>>> -	WARN_ON_ONCE(pages >= RPCSVC_MAXPAGES);
>>>>> -	if (pages >= RPCSVC_MAXPAGES)
>>>>> +	pages = (serv->sv_max_mesg + 2 * PAGE_SIZE) >> PAGE_SHIFT;
>>>>> +	if (pages > RPCSVC_MAXPAGES) {
>>>>> +		pr_warn_once("svc: warning: pages=%u > RPCSVC_MAXPAGES=%lu\n",
>>>>> +			     pages, RPCSVC_MAXPAGES);
>>>>> 		/* use as many pages as possible */
>>>>> -		pages = RPCSVC_MAXPAGES - 1;
>>>>> +		pages = RPCSVC_MAXPAGES;
>>>>> +	}
>>>>> 	for (i = 0; i < pages ; i++)
>>>>> 		while (rqstp->rq_pages[i] == NULL) {
>>>>> 			struct page *p = alloc_page(GFP_KERNEL);
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
>>> --
>>> Chuck Lever
>>> 
>>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



