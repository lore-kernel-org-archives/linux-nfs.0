Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa06-09.prod.phx3.secureserver.net ([173.201.192.110]:58758
	"EHLO p3plsmtpa06-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752211AbbKXBWK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 20:22:10 -0500
Subject: Re: [PATCH v1 1/9] xprtrdma: Add a safety margin for receive buffers
To: Chuck Lever <chuck.lever@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221357.32702.59922.stgit@manet.1015granger.net>
 <5653B586.705@talpey.com> <D946BAC3-26D5-4801-BD50-9F026EEF6551@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Tom Talpey <tom@talpey.com>
Message-ID: <5653BBCB.8010107@talpey.com>
Date: Mon, 23 Nov 2015 20:22:19 -0500
MIME-Version: 1.0
In-Reply-To: <D946BAC3-26D5-4801-BD50-9F026EEF6551@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/23/2015 8:16 PM, Chuck Lever wrote:
>
>> On Nov 23, 2015, at 7:55 PM, Tom Talpey <tom@talpey.com> wrote:
>>
>> On 11/23/2015 5:13 PM, Chuck Lever wrote:
>>> Rarely, senders post a Send that is larger than the client's inline
>>> threshold. That can be due to a bug, or the client and server may
>>> not have communicated about their inline limits. RPC-over-RDMA
>>> currently doesn't specify any particular limit on inline size, so
>>> peers have to guess what it is.
>>>
>>> It is fatal to the connection if the size of a Send is larger than
>>> the client's receive buffer. The sender is likely to retry with the
>>> same message size, so the workload is stuck at that point.
>>>
>>> Follow Postel's robustness principal: Be conservative in what you
>>> do, be liberal in what you accept from others. Increase the size of
>>> client receive buffers by a safety margin, and add a warning when
>>> the inline threshold is exceeded during receive.
>>
>> Safety is good, but how do know the chosen value is enough?
>> Isn't it better to fail the badly-composed request and be done
>> with it? Even if the stupid sender loops, which it will do
>> anyway.
>
> It’s good enough to compensate for the most common sender bug,
> which is that the sender did not account for the 28 bytes of
> the RPC-over-RDMA header when it built the send buffer. The
> additional 100 byte margin is gravy.

I think it's good to have sympathy and resilience to differing
designs on the other end of the wire, but I fail to have it for
stupid bugs. Unless this can take down the receiver, fail it fast.

MHO.

>
> The loop occurs because the server gets a completion error.
> The client just sees a connection loss. There’s no way for it
> to know it should fail the RPC, so it keeps trying.
>
> Perhaps the server could remember that the reply failed, and
> when the client retransmits, it can simply return that XID
> with an RDMA_ERROR.
>
>
>>> Note the Linux server's receive buffers are already page-sized.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>   net/sunrpc/xprtrdma/rpc_rdma.c  |    7 +++++++
>>>   net/sunrpc/xprtrdma/verbs.c     |    6 +++++-
>>>   net/sunrpc/xprtrdma/xprt_rdma.h |    5 +++++
>>>   3 files changed, 17 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>>> index c10d969..a169252 100644
>>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>>> @@ -776,6 +776,7 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>>>   	int rdmalen, status;
>>>   	unsigned long cwnd;
>>>   	u32 credits;
>>> +	RPC_IFDEBUG(struct rpcrdma_create_data_internal *cdata);
>>>
>>>   	dprintk("RPC:       %s: incoming rep %p\n", __func__, rep);
>>>
>>> @@ -783,6 +784,12 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>>>   		goto out_badstatus;
>>>   	if (rep->rr_len < RPCRDMA_HDRLEN_MIN)
>>>   		goto out_shortreply;
>>> +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
>>> +	cdata = &r_xprt->rx_data;
>>> +	if (rep->rr_len > cdata->inline_rsize)
>>> +		pr_warn("RPC: %u byte reply exceeds inline threshold\n",
>>> +			rep->rr_len);
>>> +#endif
>>>
>>>   	headerp = rdmab_to_msg(rep->rr_rdmabuf);
>>>   	if (headerp->rm_vers != rpcrdma_version)
>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>> index eadd1655..e3f12e2 100644
>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>> @@ -924,7 +924,11 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
>>>   	if (rep == NULL)
>>>   		goto out;
>>>
>>> -	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(ia, cdata->inline_rsize,
>>> +	/* The actual size of our receive buffers is increased slightly
>>> +	 * to prevent small receive overruns from killing our connection.
>>> +	 */
>>> +	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(ia, cdata->inline_rsize +
>>> +					       RPCRDMA_RECV_MARGIN,
>>>   					       GFP_KERNEL);
>>>   	if (IS_ERR(rep->rr_rdmabuf)) {
>>>   		rc = PTR_ERR(rep->rr_rdmabuf);
>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> index ac7f8d4..1b72ab1 100644
>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> @@ -337,6 +337,11 @@ struct rpcrdma_create_data_internal {
>>>   #define RPCRDMA_INLINE_PAD_VALUE(rq)\
>>>   	rpcx_to_rdmad(rq->rq_xprt).padding
>>>
>>> +/* To help prevent spurious connection shutdown, allow senders to
>>> + * overrun our receive inline threshold by a small bit.
>>> + */
>>> +#define RPCRDMA_RECV_MARGIN	(128)
>>> +
>>>   /*
>>>    * Statistics for RPCRDMA
>>>    */
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>
> --
> Chuck Lever
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
