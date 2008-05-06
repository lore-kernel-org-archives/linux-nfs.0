From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH  7/17] svcrdma: Fix error handling during listening
 endpoint creation
Date: Tue, 06 May 2008 09:48:06 -0500
Message-ID: <C445D9D6.4AB49%tom@opengridcomputing.com>
References: <20080505224140.GI12814@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:19778 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757324AbYEFOsV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 10:48:21 -0400
In-Reply-To: <20080505224140.GI12814@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 5/5/08 5:41 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 02, 2008 at 11:28:39AM -0500, Tom Tucker wrote:
>> A listening endpoint isn't known to the generic transport switch until
>> the svc_create_xprt function returns without error. Calling
>> svc_xprt_put within the xpo_create function causes the module reference
>> count to be erroneously decremented.
> 
> There's some redundant code in these three error paths; would the usual
> kernel-style "goto cleanup" thing help?

I think code-size it's a wash, but it might look more familiar. BTW, I
noticed that the error path above returns a positive errno :-\, so that
needs to be fixed too.

> 
> --b.
> 
>> 
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> 
>> ---
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++---
>>  1 files changed, 3 insertions(+), 3 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 83818cf..0d9a828 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -669,7 +669,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv
>> *serv,
>>  
>> listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP);
>> if (IS_ERR(listen_id)) {
>> -  svc_xprt_put(&cma_xprt->sc_xprt);
>> +  kfree(cma_xprt);
>> dprintk("svcrdma: rdma_create_id failed = %ld\n",
>> PTR_ERR(listen_id));
>> return (void *)listen_id;
>> @@ -677,7 +677,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv
>> *serv,
>> ret = rdma_bind_addr(listen_id, sa);
>> if (ret) {
>> rdma_destroy_id(listen_id);
>> -  svc_xprt_put(&cma_xprt->sc_xprt);
>> +  kfree(cma_xprt);
>> dprintk("svcrdma: rdma_bind_addr failed = %d\n", ret);
>> return ERR_PTR(ret);
>> }
>> @@ -686,7 +686,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv
>> *serv,
>> ret = rdma_listen(listen_id, RPCRDMA_LISTEN_BACKLOG);
>> if (ret) {
>> rdma_destroy_id(listen_id);
>> -  svc_xprt_put(&cma_xprt->sc_xprt);
>> +  kfree(cma_xprt);
>> dprintk("svcrdma: rdma_listen failed = %d\n", ret);
>> return ERR_PTR(ret);
>> }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


