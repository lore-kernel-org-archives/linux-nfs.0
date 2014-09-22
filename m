Return-Path: linux-nfs-owner@vger.kernel.org
Received: from linode.aoot.com ([69.164.194.13]:36573 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbaIVTNI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 15:13:08 -0400
Message-ID: <542074B8.8080503@opengridcomputing.com>
Date: Mon, 22 Sep 2014 14:12:56 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH] svcrdma: Advertise the correct max payload
References: <20140922183653.19376.14276.stgit@build.ogc.int> <20140922183922.GB26763@fieldses.org> <54206D7F.6070603@opengridcomputing.com> <20140922185550.GC26763@fieldses.org>
In-Reply-To: <20140922185550.GC26763@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/22/2014 1:55 PM, J. Bruce Fields wrote:
> On Mon, Sep 22, 2014 at 01:42:07PM -0500, Steve Wise wrote:
>> On 9/22/2014 1:39 PM, J. Bruce Fields wrote:
>>> On Mon, Sep 22, 2014 at 01:36:53PM -0500, Steve Wise wrote:
>>>> Svcrdma currently advertises 1MB, which is too large.  The correct value
>>>> is the max scatter-gather allowed in an NFSRDMA IO chunk * the host page
>>>> size. This bug is usually benign because the Linux X64 NFSRDMA client
>>>> correctly limits the payload size to the correct value (64*4096 = 256KB).
>>>> But if the Linux client is PPC64 with a 64KB page size, then the client
>>>> will indeed use a payload size that will overflow the server.
>>>>
>>>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>>>> ---
>>>>
>>>>   net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
>>>>   net/sunrpc/xprtrdma/xprt_rdma.h          |    2 ++
>>>>   2 files changed, 3 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> index 374feb4..4e61880 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> @@ -91,7 +91,7 @@ struct svc_xprt_class svc_rdma_class = {
>>>>   	.xcl_name = "rdma",
>>>>   	.xcl_owner = THIS_MODULE,
>>>>   	.xcl_ops = &svc_rdma_ops,
>>>> -	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
>>>> +	.xcl_max_payload = RPCSVC_MAXPAYLOAD_RDMA,
>>>>   	.xcl_ident = XPRT_TRANSPORT_RDMA,
>>>>   };
>>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> index c419498..467a77c 100644
>>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> @@ -392,4 +392,6 @@ extern struct kmem_cache *svc_rdma_ctxt_cachep;
>>>>   /* Workqueue created in svc_rdma.c */
>>>>   extern struct workqueue_struct *svc_rdma_wq;
>>>> +#define RPCSVC_MAXPAYLOAD_RDMA	(RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
>>> Do you want to define this as the minimum of this and
>>> RPCSVC_MAXPAYLOAD_TCP, in case RPCRDMA_MAX_DATA_SEGS gets increased some
>>> day?
>> Why would it need to be limited by MAXPAYLOAD_TCP?
> Because you're also limited by the size of the rq_pages array, which is
> determined by RPCSVC_MAXPAGES, calculated from RPCSVC_MAXPAYLOAD.
>
> (Actually you probably want RPCSVC_MAXPAYLOAD, not MAXPAYLOAD_TCP.)
>
>

I see.  I agree.

