Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:49457 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbbALAaI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 19:30:08 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 05/10] svcrdma: Find rmsgp more reliably
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <54B2B4E0.5060901@dev.mellanox.co.il>
Date: Sun, 11 Jan 2015 19:30:01 -0500
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3C09A798-2BA9-46A1-AA60-122C2274974C@oracle.com>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net> <20150109192237.4901.92644.stgit@klimt.1015granger.net> <54B2B4E0.5060901@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sagi-

Thanks for the review.

On Jan 11, 2015, at 12:37 PM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:

> On 1/9/2015 9:22 PM, Chuck Lever wrote:
>> xdr_start() can return the wrong rmsgp address if an assumption
>> about how the xdr_buf was constructed changes.  When it gets it
>> wrong, the client receives a reply that has gibberish in the
>> RPC/RDMA header, preventing it from matching a waiting RPC request.
>> 
>> Instead, make (and document) just one assumption: that the RDMA
>> header for the client's RPC call is at the start of the first page
>> in rq_pages.
> 
> Would it make more sense to add another pointer assigned at req
> initialization (maybe in the RDMA request context) instead of hard
> coding this assumption? I may be completely wrong here though...

I considered this. I couldn’t find an appropriate place to add
such a pointer.

I think that’s why xdr_start() was there in the first place: there
is no convenient place to save a pointer to the request’s RDMA
header.

Bruce might have other thoughts about this.

>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c |   18 ++++--------------
>>  1 files changed, 4 insertions(+), 14 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> index 7d79897..7de33d1 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> @@ -483,18 +483,6 @@ void svc_rdma_prep_reply_hdr(struct svc_rqst *rqstp)
>>  {
>>  }
>> 
>> -/*
>> - * Return the start of an xdr buffer.
>> - */
>> -static void *xdr_start(struct xdr_buf *xdr)
>> -{
>> -	return xdr->head[0].iov_base -
>> -		(xdr->len -
>> -		 xdr->page_len -
>> -		 xdr->tail[0].iov_len -
>> -		 xdr->head[0].iov_len);
>> -}
>> -
>>  int svc_rdma_sendto(struct svc_rqst *rqstp)
>>  {
>>  	struct svc_xprt *xprt = rqstp->rq_xprt;
>> @@ -512,8 +500,10 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>> 
>>  	dprintk("svcrdma: sending response for rqstp=%p\n", rqstp);
>> 
>> -	/* Get the RDMA request header. */
>> -	rdma_argp = xdr_start(&rqstp->rq_arg);
>> +	/* Get the RDMA request header. The receive logic always
>> +	 * places this at the start of page 0.
>> +	 */
>> +	rdma_argp = page_address(rqstp->rq_pages[0]);
>> 
>>  	/* Build an req vec for the XDR */
>>  	ctxt = svc_rdma_get_context(rdma);
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



