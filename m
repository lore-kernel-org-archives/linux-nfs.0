Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33879 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbcDZUcD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:32:03 -0400
Subject: Re: [PATCH v2 18/18] xprtrdma: Faster server reboot recovery
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192315.3566.4175.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FD03A.2020100@grimberg.me>
Date: Tue, 26 Apr 2016 23:31:54 +0300
MIME-Version: 1.0
In-Reply-To: <20160425192315.3566.4175.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> In a cluster failover scenario, it is desirable for the client to
> attempt to reconnect quickly, as an alternate NFS server is already
> waiting to take over for the down server. The client can't see that
> a server IP address has moved to a new server until the existing
> connection is gone.
>
> For fabrics and devices where it is meaningful, set an upper bound
> on the amount of time before it is determined that a connection is
> no longer valid. This allows the RPC client to detect connection
> loss in a timely matter, then perform a fresh resolution of the
> server GUID in case it has changed (cluster failover).
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/sunrpc/xprtrdma/verbs.c |   28 ++++++++++++++++++++++++----
>   1 file changed, 24 insertions(+), 4 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index b7a5bc1..5cc57fb 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -211,9 +211,10 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
>   	struct rpcrdma_ep *ep = &xprt->rx_ep;
>   #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
>   	struct sockaddr *sap = (struct sockaddr *)&ep->rep_remote_addr;
> -#endif
> +	u64 timeout;
>   	struct ib_qp_attr *attr = &ia->ri_qp_attr;
>   	struct ib_qp_init_attr *iattr = &ia->ri_qp_init_attr;
> +#endif
>   	int connstate = 0;
>
>   	switch (event->event) {
> @@ -235,14 +236,23 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
>   		complete(&ia->ri_done);
>   		break;
>   	case RDMA_CM_EVENT_ESTABLISHED:
> -		connstate = 1;
> +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
> +		memset(attr, 0, sizeof(*attr));
>   		ib_query_qp(ia->ri_id->qp, attr,
> -			    IB_QP_MAX_QP_RD_ATOMIC | IB_QP_MAX_DEST_RD_ATOMIC,
> +			    IB_QP_MAX_QP_RD_ATOMIC |
> +			    IB_QP_MAX_DEST_RD_ATOMIC |
> +			    IB_QP_TIMEOUT,
>   			    iattr);
>   		dprintk("RPC:       %s: %d responder resources"
>   			" (%d initiator)\n",
>   			__func__, attr->max_dest_rd_atomic,
>   			attr->max_rd_atomic);
> +		timeout = 4096 * (1ULL << attr->timeout);
> +		do_div(timeout, NSEC_PER_SEC);
> +		dprintk("RPC:       %s: retry timeout: %llu seconds\n",
> +			__func__, timeout);
> +#endif

Can you put the debug in a separate patch, at first glance I was
confused how that helped reboot recovery...
