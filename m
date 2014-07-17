Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57453 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbaGQSgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2014 14:36:22 -0400
Date: Thu, 17 Jul 2014 14:36:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: Select NFSv4.1 backchannel transport based on
 forward channel
Message-ID: <20140717183621.GA30442@fieldses.org>
References: <20140716193542.7847.95868.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140716193542.7847.95868.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 03:38:32PM -0400, Chuck Lever wrote:
> The current code always selects XPRT_TRANSPORT_BC_TCP for the back
> channel, even when the forward channel was not TCP (eg, RDMA). When
> a 4.1 mount is attempted with RDMA, the server panics in the TCP BC
> code when trying to send CB_NULL.
> 
> Instead, construct the transport protocol number from the forward
> channel transport or'd with XPRT_TRANSPORT_BC. Transports that do
> not support bi-directional RPC will not have registered a "BC"
> transport, causing create_backchannel_client() to fail immediately.
> 
> Fixes: https://bugzilla.linux-nfs.org/show_bug.cgi?id=265
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Hi Bruce-
> 
> What do you think of this approach?

OK by me.  (So clients use a separate tcp connection for the
backchannel?)

--b.

> 
> 
>  fs/nfsd/nfs4callback.c                   |    3 ++-
>  include/linux/sunrpc/svc_xprt.h          |    1 +
>  net/sunrpc/svcsock.c                     |    2 ++
>  net/sunrpc/xprt.c                        |    2 +-
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
>  5 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 2c73cae..0f23ad0 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -689,7 +689,8 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
>  		clp->cl_cb_session = ses;
>  		args.bc_xprt = conn->cb_xprt;
>  		args.prognumber = clp->cl_cb_session->se_cb_prog;
> -		args.protocol = XPRT_TRANSPORT_BC_TCP;
> +		args.protocol = conn->cb_xprt->xpt_class->xcl_ident |
> +				XPRT_TRANSPORT_BC;
>  		args.authflavor = ses->se_cb_sec.flavor;
>  	}
>  	/* Create RPC client */
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> index 7235040..5d9d6f8 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -33,6 +33,7 @@ struct svc_xprt_class {
>  	struct svc_xprt_ops	*xcl_ops;
>  	struct list_head	xcl_list;
>  	u32			xcl_max_payload;
> +	int			xcl_ident;
>  };
>  
>  /*
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index b507cd3..b2437ee 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -692,6 +692,7 @@ static struct svc_xprt_class svc_udp_class = {
>  	.xcl_owner = THIS_MODULE,
>  	.xcl_ops = &svc_udp_ops,
>  	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
> +	.xcl_ident = XPRT_TRANSPORT_UDP,
>  };
>  
>  static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
> @@ -1292,6 +1293,7 @@ static struct svc_xprt_class svc_tcp_class = {
>  	.xcl_owner = THIS_MODULE,
>  	.xcl_ops = &svc_tcp_ops,
>  	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
> +	.xcl_ident = XPRT_TRANSPORT_TCP,
>  };
>  
>  void svc_init_xprt_sock(void)
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index c3b2b33..51c6316 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1306,7 +1306,7 @@ struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
>  		}
>  	}
>  	spin_unlock(&xprt_list_lock);
> -	printk(KERN_ERR "RPC: transport (%d) not supported\n", args->ident);
> +	dprintk("RPC: transport (%d) not supported\n", args->ident);
>  	return ERR_PTR(-EIO);
>  
>  found:
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index e7323fb..06a5d92 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -92,6 +92,7 @@ struct svc_xprt_class svc_rdma_class = {
>  	.xcl_owner = THIS_MODULE,
>  	.xcl_ops = &svc_rdma_ops,
>  	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
> +	.xcl_ident = XPRT_TRANSPORT_RDMA,
>  };
>  
>  struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *xprt)
> 
