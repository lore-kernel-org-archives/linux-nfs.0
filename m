From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 12/15] RPC/RDMA: correct a 5 second pause on
	reconnecting to an idle server.
Date: Wed, 08 Oct 2008 13:35:48 -0400
Message-ID: <1223487348.7361.20.camel@localhost>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
	 <20081008154856.1336.18339.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Tom Talpey <talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:52470 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754416AbYJHRfw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:35:52 -0400
In-Reply-To: <20081008154856.1336.18339.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-10-08 at 11:48 -0400, Tom Talpey wrote:
> The RPC/RDMA code always performed a reconnect-with-backoff, even
> when re-establishing a connection to a server after the RPC layer
> closed it due to being idle.
> ---
> 
>  net/sunrpc/xprtrdma/transport.c |    5 +++--
>  net/sunrpc/xprtrdma/verbs.c     |    2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index c7d2380..278a544 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -486,8 +486,9 @@ xprt_rdma_connect(struct rpc_task *task)
>  	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
>  
>  	if (!xprt_test_and_set_connecting(xprt)) {
> -		if (r_xprt->rx_ep.rep_connected != 0) {
> -			/* Reconnect */
> +		if (r_xprt->rx_ep.rep_connected &&
> +		    r_xprt->rx_ep.rep_connected != -EPIPE) {
> +			/* Reconnect with backoff */
>  			schedule_delayed_work(&r_xprt->rdma_connect,
>  				xprt->reestablish_timeout);
>  		} else {
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index a63d0c0..9ef7e0d 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -317,7 +317,7 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
>  		connstate = -ECONNREFUSED;
>  		goto connected;
>  	case RDMA_CM_EVENT_DISCONNECTED:
> -		connstate = -ECONNABORTED;
> +		connstate = -EPIPE;
>  		goto connected;
>  	case RDMA_CM_EVENT_DEVICE_REMOVAL:
>  		connstate = -ENODEV;

Hmm... Why not rather do the same as the socket code: have the
disconnect handler paths that don't require exponential backoff just
reset xprt->reestablish_timeout to 0?

> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

