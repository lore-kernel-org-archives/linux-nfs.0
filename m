Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25476 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932105AbbIUWeL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 18:34:11 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 15/18] svcrdma: Add svc_rdma_get_context() API that is allowed to fail
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55FEA951.8000106@dev.mellanox.co.il>
Date: Mon, 21 Sep 2015 15:34:07 -0700
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <958B9B71-C068-4ED2-8928-E93BCC537102@oracle.com>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net> <20150917204614.19671.61606.stgit@manet.1015granger.net> <55FEA951.8000106@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 20, 2015, at 5:40 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
> On 9/17/2015 11:46 PM, Chuck Lever wrote:
>> To support backward direction calls, I'm going to add an
>> svc_rdma_get_context() call in the client RDMA transport.
>> 
>> Called from ->buf_alloc(), we can't sleep waiting for memory.
>> So add an API that can get a server op_ctxt but won't sleep.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>  include/linux/sunrpc/svc_rdma.h          |    2 ++
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   28 +++++++++++++++++++++++-----
>>  2 files changed, 25 insertions(+), 5 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index 6ce7495..2500dd1 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -224,6 +224,8 @@ extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
>>  extern int svc_rdma_post_recv(struct svcxprt_rdma *);
>>  extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
>>  extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
>> +extern struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *,
>> +							 gfp_t);
>>  extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
>>  extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
>>  extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 23aba30..c4083a3 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -153,17 +153,35 @@ static void svc_rdma_bc_free(struct svc_xprt *xprt)
>>  }
>>  #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
>> 
>> -struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
>> +static void svc_rdma_init_context(struct svcxprt_rdma *xprt,
>> +				  struct svc_rdma_op_ctxt *ctxt)
>>  {
>> -	struct svc_rdma_op_ctxt *ctxt;
>> -
>> -	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
>> -				GFP_KERNEL | __GFP_NOFAIL);
>>  	ctxt->xprt = xprt;
>>  	INIT_LIST_HEAD(&ctxt->dto_q);
>>  	ctxt->count = 0;
>>  	ctxt->frmr = NULL;
>>  	atomic_inc(&xprt->sc_ctxt_used);
>> +}
>> +
>> +struct svc_rdma_op_ctxt *svc_rdma_get_context_gfp(struct svcxprt_rdma *xprt,
>> +						  gfp_t flags)
>> +{
>> +	struct svc_rdma_op_ctxt *ctxt;
>> +
>> +	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep, flags);
>> +	if (!ctxt)
>> +		return NULL;
>> +	svc_rdma_init_context(xprt, ctxt);
>> +	return ctxt;
>> +}
>> +
>> +struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
>> +{
> 
> Why not:
>       return svc_rdma_get_context_gfp(xprt, GFP_KERNEL | __GFP_NOFAIL);

The “if (!ctxt) return NULL;” is unneeded if __GFP_NOFAIL is
specified.

I’ll wait for additional comments on this one, I could go
either way.


> ?
> 
>> +	struct svc_rdma_op_ctxt *ctxt;
>> +
>> +	ctxt = kmem_cache_alloc(svc_rdma_ctxt_cachep,
>> +				GFP_KERNEL | __GFP_NOFAIL);
>> +	svc_rdma_init_context(xprt, ctxt);
>>  	return ctxt;
>>  }
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

—
Chuck Lever



