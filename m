Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EAB1C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:25:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 21212208E3
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 16:25:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730463AbfACQZR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 11:25:17 -0500
Received: from p3plsmtpa08-10.prod.phx3.secureserver.net ([173.201.193.111]:45586
        "EHLO p3plsmtpa08-10.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1729598AbfACQZR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 11:25:17 -0500
X-Greylist: delayed 439 seconds by postgrey-1.27 at vger.kernel.org; Thu, 03 Jan 2019 11:25:16 EST
Received: from [192.168.0.55] ([24.218.182.144])
        by :SMTPAUTH: with ESMTPSA
        id f5gyg5QzDfttIf5gzgbCNA; Thu, 03 Jan 2019 09:17:57 -0700
Subject: Re: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
 <20190102225313.2097-2-trond.myklebust@hammerspace.com>
 <1B5E1F96-246A-43AB-B9CE-FA41C595ADFF@oracle.com>
 <6e18b8ce25652bf17d6d1fa95c3a6127767cb45b.camel@hammerspace.com>
From:   Tom Talpey <tom@talpey.com>
Message-ID: <32eef80d-9129-3284-2f9d-15b9ca3930ec@talpey.com>
Date:   Thu, 3 Jan 2019 11:17:55 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <6e18b8ce25652bf17d6d1fa95c3a6127767cb45b.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfCPOPd+7jBUgLUKzhGGbENyUNW2XHWLwlpcszEcT/h5EYVHsP6l9kqxHVxLgRW7HAxcceFY416oJd7AHLAP6G6R1Wxhwp3Y4XpDngfh9oYBCXQUyQpQE
 tYPKPi2RpGN5196EG1FmTpNcWRuPQ7rcGKaQmTNh5q5QzyNJhbzl76j9LmKxoVRd88/yu9vdVIHX+5ZXWC32GVUY0v1LOltiP3onAjsEjmtG0DHL3Lk06Ths
 XvUPlt32iBhcO50mgLzp4g==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 1/3/2019 11:05 AM, Trond Myklebust wrote:
> On Thu, 2019-01-03 at 10:29 -0500, Chuck Lever wrote:
>> Hi Trond-
>>
>> I was curious about this one because yesterday I saw evidence (for
>> other reasons) that rq_bytes_sent wasn't always zeroed when it should
>> be.
>>
>>
>>> On Jan 2, 2019, at 5:53 PM, Trond Myklebust <trondmy@gmail.com>
>>> wrote:
>>>
>>> When we resend a request, ensure that the 'rq_bytes_sent' is reset
>>> to zero.
>>>
>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>>> ---
>>> net/sunrpc/clnt.c | 1 -
>>> net/sunrpc/xprt.c | 1 +
>>> 2 files changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> index 24cbddc44c88..2189fbc4c570 100644
>>> --- a/net/sunrpc/clnt.c
>>> +++ b/net/sunrpc/clnt.c
>>> @@ -1738,7 +1738,6 @@ rpc_xdr_encode(struct rpc_task *task)
>>> 	xdr_buf_init(&req->rq_rcv_buf,
>>> 		     req->rq_rbuffer,
>>> 		     req->rq_rcvsize);
>>> -	req->rq_bytes_sent = 0;
>>
>> I agree this line is not sufficient, and it should be moved.
>> Not every retransmission requires a re-encode. However, the
>> patch description should explain that, and it probably needs
>> a Fixes: tag.
>>
>> Can you now also remove the same line from xprt_request_init
>> and xprt_init_bc_request ?
>>
>> Also, I notice that UDP does not touch rq_bytes_sent. Since
>> RDMA also does not use rq_bytes_sent, maybe the same line
>> can be removed from xprtrdma/transport.c and
>> xprtrdma/backchannel.c ?
> 
> Sure.
> 
> So please note that rq_bytes_sent == 0 no longer means "this request
> needs to be retransmitted" and we no longer test for it in
> net/sunrpc/clnt.c. We do still have a couple of tests of rq_bytes_sent
> in net/sunrpc/xprt.c and net/sunrpc/xprtsock.c, but those are more
> about checking if a transmission of that request is currently in
> progress, in which case we don't want to queue anything in front of it
> on the transmission queue, and we don't want to abort the transmission
> unless we also close the socket.

I think rq_bytes_sent is all about managing sends atomically. On stream
transports (which allow buffering partial segments), it would be fatal 
to allow intermingling. On datagram transports, it's a non-issue since
no sends are ever partial.

IOW, couldn't rq_bytes_sent simply be a boolean?

Tom.

> The intention now is that if we know the request needs retransmission
> (due to a transport connection loss or a timeout), then we just add it
> to the transmission queue.
> 
> 
>>> 	p = rpc_encode_header(task);
>>> 	if (p == NULL) {
>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>> index 73547d17d3c6..9075ae150ae5 100644
>>> --- a/net/sunrpc/xprt.c
>>> +++ b/net/sunrpc/xprt.c
>>> @@ -1151,6 +1151,7 @@ xprt_request_enqueue_transmit(struct rpc_task
>>> *task)
>>> 	struct rpc_xprt *xprt = req->rq_xprt;
>>>
>>> 	if (xprt_request_need_enqueue_transmit(task, req)) {
>>> +		req->rq_bytes_sent = 0;
>>> 		spin_lock(&xprt->queue_lock);
>>> 		/*
>>> 		 * Requests that carry congestion control credits are
>>> added
>>
>> So I'm not convinced this covers every case. I need some
>> time to investigate.
> 
> It should normally cover all cases. As I said, the only remaining tests
> are in xprt.c and  xprtsock.c
> 
