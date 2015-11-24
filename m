Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa08-06.prod.phx3.secureserver.net ([173.201.193.107]:49058
	"EHLO p3plsmtpa08-06.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752211AbbKXB0l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 20:26:41 -0500
Subject: Re: [PATCH v1 2/8] svcrdma: Define maximum number of backchannel
 requests
To: Chuck Lever <chuck.lever@oracle.com>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
 <20151123222030.13040.19373.stgit@klimt.1015granger.net>
 <5653B1A6.3010707@talpey.com>
 <BABDB763-B4D6-4538-82FB-11F494BAC27C@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Tom Talpey <tom@talpey.com>
Message-ID: <5653BB2C.4040209@talpey.com>
Date: Mon, 23 Nov 2015 20:19:40 -0500
MIME-Version: 1.0
In-Reply-To: <BABDB763-B4D6-4538-82FB-11F494BAC27C@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/23/2015 8:09 PM, Chuck Lever wrote:
>
>> On Nov 23, 2015, at 7:39 PM, Tom Talpey <tom@talpey.com> wrote:
>>
>> On 11/23/2015 5:20 PM, Chuck Lever wrote:
>>> Extra resources for handling backchannel requests have to be
>>> pre-allocated when a transport instance is created. Set a limit.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>   include/linux/sunrpc/svc_rdma.h          |    5 +++++
>>>   net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++++-
>>>   2 files changed, 10 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>>> index f869807..478aa30 100644
>>> --- a/include/linux/sunrpc/svc_rdma.h
>>> +++ b/include/linux/sunrpc/svc_rdma.h
>>> @@ -178,6 +178,11 @@ struct svcxprt_rdma {
>>>   #define RPCRDMA_SQ_DEPTH_MULT   8
>>>   #define RPCRDMA_MAX_REQUESTS    32
>>>   #define RPCRDMA_MAX_REQ_SIZE    4096
>>> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
>>
>> Why is this a config option? Why wouldn't you always want
>> this? It's needed for any post-1990 NFS dialect.
>
> I think some distros want to be able to compile out NFSv4.x
> on small systems, and take all the backchannel cruft with it.

So shouldn't it follow the NFSv4.x config options then?

>
>
>>> +#define RPCRDMA_MAX_BC_REQUESTS	8
>>
>> Why a constant 8? The forward channel value is apparently
>> configurable, just a few lines down.
>
> The client side backward direction credit limit, now
> in 4.4, is already a constant.
>
> The client side ULP uses a constant for the slot table
> size: NFS4_MAX_BACK_CHANNEL_OPS. I’m not 100% sure but
> the server seems to just echo that number back to the
> client.
>
> I’d rather not add an admin knob for this. Why would it
> be necessary?

Because no constant is ever correct. Why isn't it "1"? Do
you allow multiple credits? Why not that value?

For instance.

>
>
>>> +#else
>>> +#define RPCRDMA_MAX_BC_REQUESTS	0
>>> +#endif
>>>
>>>   #define RPCSVC_MAXPAYLOAD_RDMA	RPCSVC_MAXPAYLOAD
>>>
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> index b348b4a..01c7b36 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> @@ -923,8 +923,10 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>>   				  (size_t)RPCSVC_MAXPAGES);
>>>   	newxprt->sc_max_sge_rd = min_t(size_t, devattr.max_sge_rd,
>>>   				       RPCSVC_MAXPAGES);
>>> +	/* XXX: what if HCA can't support enough WRs for bc operation? */
>>>   	newxprt->sc_max_requests = min((size_t)devattr.max_qp_wr,
>>> -				   (size_t)svcrdma_max_requests);
>>> +				       (size_t)(svcrdma_max_requests +
>>> +				       RPCRDMA_MAX_BC_REQUESTS));
>>>   	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_max_requests;
>>>
>>>   	/*
>>> @@ -964,7 +966,9 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>>   	qp_attr.event_handler = qp_event_handler;
>>>   	qp_attr.qp_context = &newxprt->sc_xprt;
>>>   	qp_attr.cap.max_send_wr = newxprt->sc_sq_depth;
>>> +	qp_attr.cap.max_send_wr += RPCRDMA_MAX_BC_REQUESTS;
>>>   	qp_attr.cap.max_recv_wr = newxprt->sc_max_requests;
>>> +	qp_attr.cap.max_recv_wr += RPCRDMA_MAX_BC_REQUESTS;
>>>   	qp_attr.cap.max_send_sge = newxprt->sc_max_sge;
>>>   	qp_attr.cap.max_recv_sge = newxprt->sc_max_sge;
>>>   	qp_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
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
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
