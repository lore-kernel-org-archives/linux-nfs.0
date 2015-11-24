Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-09.prod.phx3.secureserver.net ([68.178.252.110]:53319
	"EHLO p3plsmtpa11-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751843AbbKXA46 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 19:56:58 -0500
Subject: Re: [PATCH v1 6/8] xprtrdma: Add class for RDMA backwards direction
 transport
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
 <20151123222102.13040.13340.stgit@klimt.1015granger.net>
From: Tom Talpey <tom@talpey.com>
Message-ID: <5653B435.2040509@talpey.com>
Date: Mon, 23 Nov 2015 19:49:57 -0500
MIME-Version: 1.0
In-Reply-To: <20151123222102.13040.13340.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/23/2015 5:21 PM, Chuck Lever wrote:
> To support the server-side of an NFSv4.1 backchannel on RDMA
> connections, add a transport class for backwards direction
> operation.

So, what's special here is that it re-uses an existing forward
channel's connection? If not, it would seem unnecessary to
define a new type/transport semantic. Say this?

>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   include/linux/sunrpc/xprt.h              |    1
>   net/sunrpc/xprt.c                        |    1
>   net/sunrpc/xprtrdma/svc_rdma_transport.c |   14 +-
>   net/sunrpc/xprtrdma/transport.c          |  243 ++++++++++++++++++++++++++++++
>   net/sunrpc/xprtrdma/xprt_rdma.h          |    2
>   5 files changed, 256 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 69ef5b3..7637ccd 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -85,6 +85,7 @@ struct rpc_rqst {
>   	__u32 *			rq_buffer;	/* XDR encode buffer */
>   	size_t			rq_callsize,
>   				rq_rcvsize;
> +	void *			rq_privdata; /* xprt-specific per-rqst data */
>   	size_t			rq_xmit_bytes_sent;	/* total bytes sent */
>   	size_t			rq_reply_bytes_recvd;	/* total reply bytes */
>   							/* received */
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 2e98f4a..37edea6 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1425,3 +1425,4 @@ void xprt_put(struct rpc_xprt *xprt)
>   	if (atomic_dec_and_test(&xprt->count))
>   		xprt_destroy(xprt);
>   }
> +EXPORT_SYMBOL_GPL(xprt_put);
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 58ec362..3768a7f 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -1182,12 +1182,14 @@ static void __svc_rdma_free(struct work_struct *work)
>   {
>   	struct svcxprt_rdma *rdma =
>   		container_of(work, struct svcxprt_rdma, sc_work);
> -	dprintk("svcrdma: svc_rdma_free(%p)\n", rdma);
> +	struct svc_xprt *xprt = &rdma->sc_xprt;
> +
> +	dprintk("svcrdma: %s(%p)\n", __func__, rdma);
>
>   	/* We should only be called from kref_put */
> -	if (atomic_read(&rdma->sc_xprt.xpt_ref.refcount) != 0)
> +	if (atomic_read(&xprt->xpt_ref.refcount) != 0)
>   		pr_err("svcrdma: sc_xprt still in use? (%d)\n",
> -		       atomic_read(&rdma->sc_xprt.xpt_ref.refcount));
> +		       atomic_read(&xprt->xpt_ref.refcount));
>
>   	/*
>   	 * Destroy queued, but not processed read completions. Note
> @@ -1222,6 +1224,12 @@ static void __svc_rdma_free(struct work_struct *work)
>   		pr_err("svcrdma: dma still in use? (%d)\n",
>   		       atomic_read(&rdma->sc_dma_used));
>
> +	/* Final put of backchannel client transport */
> +	if (xprt->xpt_bc_xprt) {
> +		xprt_put(xprt->xpt_bc_xprt);
> +		xprt->xpt_bc_xprt = NULL;
> +	}
> +
>   	/* De-allocate fastreg mr */
>   	rdma_dealloc_frmr_q(rdma);
>
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 8c545f7..fda7488 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -51,6 +51,7 @@
>   #include <linux/slab.h>
>   #include <linux/seq_file.h>
>   #include <linux/sunrpc/addr.h>
> +#include <linux/sunrpc/svc_rdma.h>
>
>   #include "xprt_rdma.h"
>
> @@ -148,7 +149,10 @@ static struct ctl_table sunrpc_table[] = {
>   #define RPCRDMA_MAX_REEST_TO	(30U * HZ)
>   #define RPCRDMA_IDLE_DISC_TO	(5U * 60 * HZ)
>
> -static struct rpc_xprt_ops xprt_rdma_procs;	/* forward reference */
> +static struct rpc_xprt_ops xprt_rdma_procs;
> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
> +static struct rpc_xprt_ops xprt_rdma_bc_procs;
> +#endif
>
>   static void
>   xprt_rdma_format_addresses4(struct rpc_xprt *xprt, struct sockaddr *sap)
> @@ -499,7 +503,7 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
>   	if (req == NULL)
>   		return NULL;
>
> -	flags = GFP_NOIO | __GFP_NOWARN;
> +	flags = RPCRDMA_DEF_GFP;
>   	if (RPC_IS_SWAPPER(task))
>   		flags = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
>
> @@ -684,6 +688,199 @@ xprt_rdma_disable_swap(struct rpc_xprt *xprt)
>   {
>   }
>
> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
> +
> +/* Server-side transport endpoint wants a whole page for its send
> + * buffer. The client RPC code constructs the RPC header in this
> + * buffer before it invokes ->send_request.
> + */
> +static void *
> +xprt_rdma_bc_allocate(struct rpc_task *task, size_t size)
> +{
> +	struct rpc_rqst *rqst = task->tk_rqstp;
> +	struct svc_rdma_op_ctxt *ctxt;
> +	struct svcxprt_rdma *rdma;
> +	struct svc_xprt *sxprt;
> +	struct page *page;
> +
> +	if (size > PAGE_SIZE) {
> +		WARN_ONCE(1, "failed to handle buffer allocation (size %zu)\n",
> +			  size);
> +		return NULL;
> +	}
> +
> +	page = alloc_page(RPCRDMA_DEF_GFP);
> +	if (!page)
> +		return NULL;
> +
> +	sxprt = rqst->rq_xprt->bc_xprt;
> +	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
> +	ctxt = svc_rdma_get_context_gfp(rdma, RPCRDMA_DEF_GFP);
> +	if (!ctxt) {
> +		put_page(page);
> +		return NULL;
> +	}
> +
> +	rqst->rq_privdata = ctxt;
> +	ctxt->pages[0] = page;
> +	ctxt->count = 1;
> +	return page_address(page);
> +}
> +
> +static void
> +xprt_rdma_bc_free(void *buffer)
> +{
> +	/* No-op: ctxt and page have already been freed. */
> +}
> +
> +static int
> +rpcrdma_bc_send_request(struct svcxprt_rdma *rdma, struct rpc_rqst *rqst)
> +{
> +	struct rpc_xprt *xprt = rqst->rq_xprt;
> +	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
> +	struct rpcrdma_msg *headerp = (struct rpcrdma_msg *)rqst->rq_buffer;
> +	struct svc_rdma_op_ctxt *ctxt;
> +	int rc;
> +
> +	/* Space in the send buffer for an RPC/RDMA header is reserved
> +	 * via xprt->tsh_size */
> +	headerp->rm_xid = rqst->rq_xid;
> +	headerp->rm_vers = rpcrdma_version;
> +	headerp->rm_credit = cpu_to_be32(r_xprt->rx_buf.rb_bc_max_requests);
> +	headerp->rm_type = rdma_msg;
> +	headerp->rm_body.rm_chunks[0] = xdr_zero;
> +	headerp->rm_body.rm_chunks[1] = xdr_zero;
> +	headerp->rm_body.rm_chunks[2] = xdr_zero;
> +
> +	pr_info("%s: %*ph\n", __func__, 64, rqst->rq_buffer);
> +
> +	ctxt = (struct svc_rdma_op_ctxt *)rqst->rq_privdata;
> +	rc = svc_rdma_bc_post_send(rdma, ctxt, &rqst->rq_snd_buf);
> +	if (rc)
> +		goto drop_connection;
> +	return rc;
> +
> +drop_connection:
> +	pr_info("Failed to send backwards request\n");

This is going to be a very strange message to see out of context.
What's a "backwards request"?

> +	svc_rdma_put_context(ctxt, 1);
> +	xprt_disconnect_done(xprt);
> +	return -ENOTCONN;
> +}
> +
> +/* Take an RPC request and sent it on the passive end of a
> + * transport connection.
> + */

Typo 'send".

> +static int
> +xprt_rdma_bc_send_request(struct rpc_task *task)
> +{
> +	struct rpc_rqst *rqst = task->tk_rqstp;
> +	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
> +	struct svcxprt_rdma *rdma;
> +	u32 len;
> +
> +	pr_info("%s: sending request with xid: %08x\n",
> +		__func__, be32_to_cpu(rqst->rq_xid));
> +
> +	if (!mutex_trylock(&sxprt->xpt_mutex)) {
> +		rpc_sleep_on(&sxprt->xpt_bc_pending, task, NULL);
> +		if (!mutex_trylock(&sxprt->xpt_mutex))
> +			return -EAGAIN;
> +		rpc_wake_up_queued_task(&sxprt->xpt_bc_pending, task);
> +	}
> +
> +	len = -ENOTCONN;
> +	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
> +	if (!test_bit(XPT_DEAD, &sxprt->xpt_flags))
> +		len = rpcrdma_bc_send_request(rdma, rqst);
> +
> +	mutex_unlock(&sxprt->xpt_mutex);
> +
> +	if (len < 0)
> +		return len;
> +	return 0;
> +}
> +
> +static void
> +xprt_rdma_bc_close(struct rpc_xprt *xprt)
> +{
> +	pr_info("RPC:       %s: xprt %p\n", __func__, xprt);
> +}
> +
> +static void
> +xprt_rdma_bc_put(struct rpc_xprt *xprt)
> +{
> +	pr_info("RPC:       %s: xprt %p\n", __func__, xprt);
> +
> +	xprt_free(xprt);
> +	module_put(THIS_MODULE);
> +}
> +
> +/* It shouldn't matter if the number of backchannel session slots
> + * doesn't match the number of RPC/RDMA credits. That just means
> + * one or the other will have extra slots that aren't used.
> + */
> +static struct rpc_xprt *
> +xprt_setup_rdma_bc(struct xprt_create *args)
> +{
> +	struct rpc_xprt *xprt;
> +	struct rpcrdma_xprt *new_xprt;
> +
> +	if (args->addrlen > sizeof(xprt->addr)) {
> +		dprintk("RPC:       %s: address too large\n", __func__);
> +		return ERR_PTR(-EBADF);
> +	}
> +
> +	xprt = xprt_alloc(args->net, sizeof(*new_xprt),
> +			  RPCRDMA_MAX_BC_REQUESTS,
> +			  RPCRDMA_MAX_BC_REQUESTS);
> +	if (xprt == NULL) {
> +		dprintk("RPC:       %s: couldn't allocate rpc_xprt\n",
> +			__func__);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	xprt->timeout = &xprt_rdma_default_timeout;
> +	xprt_set_bound(xprt);
> +	xprt_set_connected(xprt);
> +	xprt->bind_timeout = RPCRDMA_BIND_TO;
> +	xprt->reestablish_timeout = RPCRDMA_INIT_REEST_TO;
> +	xprt->idle_timeout = RPCRDMA_IDLE_DISC_TO;
> +
> +	xprt->prot = XPRT_TRANSPORT_BC_RDMA;
> +	xprt->tsh_size = RPCRDMA_HDRLEN_MIN / sizeof(__be32);
> +	xprt->ops = &xprt_rdma_bc_procs;
> +
> +	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
> +	xprt->addrlen = args->addrlen;
> +	xprt_rdma_format_addresses(xprt, (struct sockaddr *)&xprt->addr);
> +	xprt->resvport = 0;
> +
> +	xprt->max_payload = xprt_rdma_max_inline_read;
> +
> +	new_xprt = rpcx_to_rdmax(xprt);
> +	new_xprt->rx_buf.rb_bc_max_requests = xprt->max_reqs;
> +
> +	xprt_get(xprt);
> +	args->bc_xprt->xpt_bc_xprt = xprt;
> +	xprt->bc_xprt = args->bc_xprt;
> +
> +	if (!try_module_get(THIS_MODULE))
> +		goto out_fail;
> +
> +	/* Final put for backchannel xprt is in __svc_rdma_free */
> +	xprt_get(xprt);
> +	return xprt;
> +
> +out_fail:
> +	xprt_rdma_free_addresses(xprt);
> +	args->bc_xprt->xpt_bc_xprt = NULL;
> +	xprt_put(xprt);
> +	xprt_free(xprt);
> +	return ERR_PTR(-EINVAL);
> +}
> +
> +#endif	/* CONFIG_SUNRPC_BACKCHANNEL */
> +
>   /*
>    * Plumbing for rpc transport switch and kernel module
>    */
> @@ -722,6 +919,32 @@ static struct xprt_class xprt_rdma = {
>   	.setup			= xprt_setup_rdma,
>   };
>
> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
> +
> +static struct rpc_xprt_ops xprt_rdma_bc_procs = {
> +	.reserve_xprt		= xprt_reserve_xprt_cong,
> +	.release_xprt		= xprt_release_xprt_cong,
> +	.alloc_slot		= xprt_alloc_slot,
> +	.release_request	= xprt_release_rqst_cong,
> +	.buf_alloc		= xprt_rdma_bc_allocate,
> +	.buf_free		= xprt_rdma_bc_free,
> +	.send_request		= xprt_rdma_bc_send_request,
> +	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
> +	.close			= xprt_rdma_bc_close,
> +	.destroy		= xprt_rdma_bc_put,
> +	.print_stats		= xprt_rdma_print_stats
> +};
> +
> +static struct xprt_class xprt_rdma_bc = {
> +	.list			= LIST_HEAD_INIT(xprt_rdma_bc.list),
> +	.name			= "rdma backchannel",
> +	.owner			= THIS_MODULE,
> +	.ident			= XPRT_TRANSPORT_BC_RDMA,
> +	.setup			= xprt_setup_rdma_bc,
> +};
> +
> +#endif	/* CONFIG_SUNRPC_BACKCHANNEL */
> +
>   void xprt_rdma_cleanup(void)
>   {
>   	int rc;
> @@ -740,6 +963,13 @@ void xprt_rdma_cleanup(void)
>
>   	rpcrdma_destroy_wq();
>   	frwr_destroy_recovery_wq();
> +
> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
> +	rc = xprt_unregister_transport(&xprt_rdma_bc);
> +	if (rc)
> +		dprintk("RPC:       %s: xprt_unregister(bc) returned %i\n",
> +			__func__, rc);
> +#endif
>   }
>
>   int xprt_rdma_init(void)
> @@ -763,6 +993,15 @@ int xprt_rdma_init(void)
>   		return rc;
>   	}
>
> +#if defined(CONFIG_SUNRPC_BACKCHANNEL)
> +	rc = xprt_register_transport(&xprt_rdma_bc);
> +	if (rc) {
> +		xprt_unregister_transport(&xprt_rdma);
> +		frwr_destroy_recovery_wq();
> +		return rc;
> +	}
> +#endif
> +
>   	dprintk("RPCRDMA Module Init, register RPC RDMA transport\n");
>
>   	dprintk("Defaults:\n");
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 9aeff2b..485027e 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -148,6 +148,8 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
>   	return (struct rpcrdma_msg *)rb->rg_base;
>   }
>
> +#define RPCRDMA_DEF_GFP		(GFP_NOIO | __GFP_NOWARN)
> +
>   /*
>    * struct rpcrdma_rep -- this structure encapsulates state required to recv
>    * and complete a reply, asychronously. It needs several pieces of
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
