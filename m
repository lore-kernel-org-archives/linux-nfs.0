Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24169 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbbFCTqw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2015 15:46:52 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 08/10] svcrdma: Add backward direction service for RPC/RDMA transport
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150602153054.GB32413@fieldses.org>
Date: Wed, 3 Jun 2015 15:49:13 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4939D8DF-4AD0-477F-B06C-0E27F015BBE0@oracle.com>
References: <20150526174401.7061.43137.stgit@klimt.1015granger.net> <20150526174945.7061.58026.stgit@klimt.1015granger.net> <20150601202641.GD26972@fieldses.org> <C2428536-0784-4C42-B678-F2173C6CAB89@oracle.com> <20150602153054.GB32413@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2015, at 11:30 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Mon, Jun 01, 2015 at 04:45:26PM -0400, Chuck Lever wrote:
>> 
>> On Jun 1, 2015, at 4:26 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>>> On Tue, May 26, 2015 at 01:49:45PM -0400, Chuck Lever wrote:
>>>> Introduce some pre-requisite infrastructure needed for handling
>>>> RPC/RDMA bi-direction on the client side.
>>>> 
>>>> On NFSv4.1 mount points, the client uses this transport endpoint to
>>>> receive backward direction calls and route replies back to the
>>>> NFS server.
>>> 
>>> Am I missing something, or is this pretty much dead code for now?
>>> 
>>> In which case, I'd rather wait on it.
>> 
>> When I submit the client-side backchannel patches, should I submit
>> this patch through Anna and request your Acked-by?
> 
> Sure, feel free to add my Acked-by.
> 
> Or I guess I won't worry too much about some dead code if the
> client-side patches are coming soon.

There are more pre-requisites on the client than there are on the server.
I anticipate it will be at least two more merge windows before the client
will be ready to merge backchannel support.

I’ll add this patch back into the client backchannel series.


> Whatever's simplest for you.
> 
> --b.
> 
>> 
>> 
>>> --b.
>>> 
>>>> 
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> 
>>>> include/linux/sunrpc/svc_rdma.h          |    6 +++
>>>> include/linux/sunrpc/xprt.h              |    1 +
>>>> net/sunrpc/xprtrdma/svc_rdma.c           |    6 +++
>>>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   59 ++++++++++++++++++++++++++++++
>>>> 4 files changed, 71 insertions(+), 1 deletions(-)
>>>> 
>>>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>>>> index cb94ee4..0e7234d 100644
>>>> --- a/include/linux/sunrpc/svc_rdma.h
>>>> +++ b/include/linux/sunrpc/svc_rdma.h
>>>> @@ -231,9 +231,13 @@ extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
>>>> 			      struct svc_rdma_fastreg_mr *);
>>>> extern void svc_sq_reap(struct svcxprt_rdma *);
>>>> extern void svc_rq_reap(struct svcxprt_rdma *);
>>>> -extern struct svc_xprt_class svc_rdma_class;
>>>> extern void svc_rdma_prep_reply_hdr(struct svc_rqst *);
>>>> 
>>>> +extern struct svc_xprt_class svc_rdma_class;
>>>> +#ifdef CONFIG_SUNRPC_BACKCHANNEL
>>>> +extern struct svc_xprt_class svc_rdma_bc_class;
>>>> +#endif
>>>> +
>>>> /* svc_rdma.c */
>>>> extern int svc_rdma_init(void);
>>>> extern void svc_rdma_cleanup(void);
>>>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>>>> index 8b93ef5..693f9f1 100644
>>>> --- a/include/linux/sunrpc/xprt.h
>>>> +++ b/include/linux/sunrpc/xprt.h
>>>> @@ -150,6 +150,7 @@ enum xprt_transports {
>>>> 	XPRT_TRANSPORT_TCP	= IPPROTO_TCP,
>>>> 	XPRT_TRANSPORT_BC_TCP	= IPPROTO_TCP | XPRT_TRANSPORT_BC,
>>>> 	XPRT_TRANSPORT_RDMA	= 256,
>>>> +	XPRT_TRANSPORT_BC_RDMA	= XPRT_TRANSPORT_RDMA | XPRT_TRANSPORT_BC,
>>>> 	XPRT_TRANSPORT_LOCAL	= 257,
>>>> };
>>>> 
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
>>>> index 8eedb60..7a18ae4 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
>>>> @@ -244,6 +244,9 @@ void svc_rdma_cleanup(void)
>>>> 		unregister_sysctl_table(svcrdma_table_header);
>>>> 		svcrdma_table_header = NULL;
>>>> 	}
>>>> +#ifdef CONFIG_SUNRPC_BACKCHANNEL
>>>> +	svc_unreg_xprt_class(&svc_rdma_bc_class);
>>>> +#endif
>>>> 	svc_unreg_xprt_class(&svc_rdma_class);
>>>> 	kmem_cache_destroy(svc_rdma_map_cachep);
>>>> 	kmem_cache_destroy(svc_rdma_ctxt_cachep);
>>>> @@ -291,6 +294,9 @@ int svc_rdma_init(void)
>>>> 
>>>> 	/* Register RDMA with the SVC transport switch */
>>>> 	svc_reg_xprt_class(&svc_rdma_class);
>>>> +#ifdef CONFIG_SUNRPC_BACKCHANNEL
>>>> +	svc_reg_xprt_class(&svc_rdma_bc_class);
>>>> +#endif
>>>> 	return 0;
>>>> err1:
>>>> 	kmem_cache_destroy(svc_rdma_map_cachep);
>>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> index 3b4c2ff..9b8bccd 100644
>>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>>> @@ -56,6 +56,7 @@
>>>> 
>>>> #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>>>> 
>>>> +static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *, int);
>>>> static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>>>> 					struct net *net,
>>>> 					struct sockaddr *sa, int salen,
>>>> @@ -95,6 +96,64 @@ struct svc_xprt_class svc_rdma_class = {
>>>> 	.xcl_ident = XPRT_TRANSPORT_RDMA,
>>>> };
>>>> 
>>>> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
>>>> +static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *, struct net *,
>>>> +					   struct sockaddr *, int, int);
>>>> +static void svc_rdma_bc_detach(struct svc_xprt *);
>>>> +static void svc_rdma_bc_free(struct svc_xprt *);
>>>> +
>>>> +static struct svc_xprt_ops svc_rdma_bc_ops = {
>>>> +	.xpo_create = svc_rdma_bc_create,
>>>> +	.xpo_detach = svc_rdma_bc_detach,
>>>> +	.xpo_free = svc_rdma_bc_free,
>>>> +	.xpo_prep_reply_hdr = svc_rdma_prep_reply_hdr,
>>>> +	.xpo_secure_port = svc_rdma_secure_port,
>>>> +};
>>>> +
>>>> +struct svc_xprt_class svc_rdma_bc_class = {
>>>> +	.xcl_name = "rdma-bc",
>>>> +	.xcl_owner = THIS_MODULE,
>>>> +	.xcl_ops = &svc_rdma_bc_ops,
>>>> +	.xcl_max_payload = (1024 - RPCRDMA_HDRLEN_MIN),
>>>> +	.xcl_ident = XPRT_TRANSPORT_BC_RDMA,
>>>> +};
>>>> +
>>>> +static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
>>>> +					   struct net *net,
>>>> +					   struct sockaddr *sa, int salen,
>>>> +					   int flags)
>>>> +{
>>>> +	struct svcxprt_rdma *cma_xprt;
>>>> +	struct svc_xprt *xprt;
>>>> +
>>>> +	cma_xprt = rdma_create_xprt(serv, 0);
>>>> +	if (!cma_xprt)
>>>> +		return ERR_PTR(-ENOMEM);
>>>> +	xprt = &cma_xprt->sc_xprt;
>>>> +
>>>> +	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
>>>> +	serv->sv_bc_xprt = xprt;
>>>> +
>>>> +	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
>>>> +	return xprt;
>>>> +}
>>>> +
>>>> +static void svc_rdma_bc_detach(struct svc_xprt *xprt)
>>>> +{
>>>> +	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
>>>> +}
>>>> +
>>>> +static void svc_rdma_bc_free(struct svc_xprt *xprt)
>>>> +{
>>>> +	struct svcxprt_rdma *rdma =
>>>> +		container_of(xprt, struct svcxprt_rdma, sc_xprt);
>>>> +
>>>> +	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
>>>> +	if (xprt)
>>>> +		kfree(rdma);
>>>> +}
>>>> +#endif	/* CONFIG_SUNRPC_BACKCHANNEL */
>>>> +
>>>> struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
>>>> {
>>>> 	struct svc_rdma_op_ctxt *ctxt;
>> 
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



