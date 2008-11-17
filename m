From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 65/85] nfs41: Backchannel bc_svc_process()
Date: Mon, 17 Nov 2008 15:55:14 +0200
Message-ID: <492177C2.3070600@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348990-9399-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:21164 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751911AbYKQNzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:55:17 -0500
In-Reply-To: <1226348990-9399-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:29 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> 
> Implement the NFSv4.1 backchannel service.  Invokes the common callback
> processing logic svc_process_common() to authenticate the call and
> dispatch the appropriate NFSv4.1 XDR decoder and operation procedure.
> It then invokes bc_send() to send the reply over the same connection.
> bc_send() is implemented in a separate patch.
> 
> At this time there is no slot validation or reply cache handling.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  net/sunrpc/svc.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 49 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index e4efeeb..906b992 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -25,6 +25,7 @@
>  #include <linux/sunrpc/stats.h>
>  #include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/clnt.h>
> +#include <linux/sunrpc/bc_xprt.h>
>  
>  #define RPCDBG_FACILITY	RPCDBG_SVCDSP
>  
> @@ -1253,6 +1254,54 @@ svc_process(struct svc_rqst *rqstp)
>  	return svc_send(rqstp);
>  }
>  
> +#if defined(CONFIG_NFS_V4_1)
> +/*
> + * Process a backchannel RPC request that arrived over an existing
> + * outbound connection
> + */
> +int
> +bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
> +	       struct svc_rqst *rqstp)
> +{
> +	struct kvec	*argv = &rqstp->rq_arg.head[0];
> +	struct kvec	*resv = &rqstp->rq_res.head[0];
> +	int 		error;
> +
> +	/* Build the svc_rqst used by the common processing routine */
> +	rqstp->rq_xid = req->rq_xid;
> +	rqstp->rq_prot = req->rq_xprt->prot;
> +	rqstp->rq_server = serv;
> +
> +	rqstp->rq_addrlen = sizeof(req->rq_xprt->addr);
> +	memcpy(&rqstp->rq_addr, &req->rq_xprt->addr, rqstp->rq_addrlen);
> +	memcpy(&rqstp->rq_arg, &req->rq_private_buf, sizeof(rqstp->rq_arg));
> +	memcpy(&rqstp->rq_res, &req->rq_snd_buf, sizeof(rqstp->rq_res));
> +
> +	/* reset result send buffer "put" position */
> +	resv->iov_len = 0;
> +
> +	if (rqstp->rq_prot != IPPROTO_TCP) {
> +		printk(KERN_ERR "No support for Non-TCP transports!\n");
> +		BUG();
> +	}
> +
> +	/*
> +	 * Skip the next two words because they've already been
> +	 * processed in the trasport
> +	 */
> +	svc_getu32(argv);	/* XID */
> +	svc_getnl(argv);	/* CALLDIR */
> +
> +	error = svc_process_common(rqstp, argv, resv);
> +	if (error <= 0)
> +		return error;
> +
> +	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));

review 11-14: just copy the pointers, not data.

> +	return bc_send(req);
> +}
> +EXPORT_SYMBOL(bc_svc_process);
> +#endif /* CONFIG_NFS_V4_1 */
> +
>  /*
>   * Return (transport-specific) limit on the rpc payload.
>   */
