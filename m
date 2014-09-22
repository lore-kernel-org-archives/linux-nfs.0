Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45461 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbaIVSr2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2014 14:47:28 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] svcrdma: Advertise the correct max payload
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140922183922.GB26763@fieldses.org>
Date: Mon, 22 Sep 2014 11:47:15 -0700
Cc: Steve Wise <swise@opengridcomputing.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Message-Id: <5D045AB5-71D5-4ACB-9394-FE27A9F37DA7@oracle.com>
References: <20140922183653.19376.14276.stgit@build.ogc.int> <20140922183922.GB26763@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 22, 2014, at 11:39 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Mon, Sep 22, 2014 at 01:36:53PM -0500, Steve Wise wrote:
>> Svcrdma currently advertises 1MB, which is too large.  The correct value
>> is the max scatter-gather allowed in an NFSRDMA IO chunk * the host page
>> size. This bug is usually benign because the Linux X64 NFSRDMA client
>> correctly limits the payload size to the correct value (64*4096 = 256KB).
>> But if the Linux client is PPC64 with a 64KB page size, then the client
>> will indeed use a payload size that will overflow the server.
>> 
>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>> ---
>> 
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
>> net/sunrpc/xprtrdma/xprt_rdma.h          |    2 ++
>> 2 files changed, 3 insertions(+), 1 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 374feb4..4e61880 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -91,7 +91,7 @@ struct svc_xprt_class svc_rdma_class = {
>> 	.xcl_name = "rdma",
>> 	.xcl_owner = THIS_MODULE,
>> 	.xcl_ops = &svc_rdma_ops,
>> -	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
>> +	.xcl_max_payload = RPCSVC_MAXPAYLOAD_RDMA,
>> 	.xcl_ident = XPRT_TRANSPORT_RDMA,
>> };
>> 
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index c419498..467a77c 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -392,4 +392,6 @@ extern struct kmem_cache *svc_rdma_ctxt_cachep;
>> /* Workqueue created in svc_rdma.c */
>> extern struct workqueue_struct *svc_rdma_wq;
>> 
>> +#define RPCSVC_MAXPAYLOAD_RDMA	(RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT)
> 
> Do you want to define this as the minimum of this and
> RPCSVC_MAXPAYLOAD_TCP, in case RPCRDMA_MAX_DATA_SEGS gets increased some
> day?

Hey Bruce-

I don’t see the _TCP and _RDMA settings are related.

> --b.
> 
>> +
>> #endif				/* _LINUX_SUNRPC_XPRT_RDMA_H */
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



