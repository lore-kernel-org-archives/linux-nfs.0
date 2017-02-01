Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35656 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdBAOuT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2017 09:50:19 -0500
Subject: Re: [PATCH v2 7/7] sunrpc: Allow keepalive ping on a credit-full
 transport
To: Chuck Lever <chuck.lever@oracle.com>, anna.schumaker@netapp.com
References: <20170131183345.5325.47072.stgit@manet.1015granger.net>
 <20170131183906.5325.79683.stgit@manet.1015granger.net>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <6b94f05b-8601-9d31-bbe5-915e0bb015e1@gmail.com>
Date: Wed, 1 Feb 2017 09:50:17 -0500
MIME-Version: 1.0
In-Reply-To: <20170131183906.5325.79683.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 01/31/2017 01:39 PM, Chuck Lever wrote:
> Allow RPC-over-RDMA to send NULL pings even when the transport has
> hit its credit limit. One RPC-over-RDMA credit is reserved for
> operations like keepalive.
> 
> For transports that convey NFSv4, it seems like lease renewal would
> also be a candidate for using a priority transport slot. I'd like to
> see a mechanism better than RPCRDMA_PRIORITY that can ensure only
> one priority operation is in use at a time.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/sched.h    |    2 ++
>  net/sunrpc/xprt.c               |    4 ++++
>  net/sunrpc/xprtrdma/transport.c |    3 ++-
>  net/sunrpc/xprtrdma/verbs.c     |   13 ++++++++-----
>  net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
>  5 files changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> index 13822e6..fcea158 100644
> --- a/include/linux/sunrpc/sched.h
> +++ b/include/linux/sunrpc/sched.h
> @@ -127,6 +127,7 @@ struct rpc_task_setup {
>  #define RPC_TASK_TIMEOUT	0x1000		/* fail with ETIMEDOUT on timeout */
>  #define RPC_TASK_NOCONNECT	0x2000		/* return ENOTCONN if not connected */
>  #define RPC_TASK_NO_RETRANS_TIMEOUT	0x4000		/* wait forever for a reply */
> +#define RPC_TASK_NO_CONG	0x8000		/* skip congestion control */
>  
>  #define RPC_TASK_SOFTPING	(RPC_TASK_SOFT | RPC_TASK_SOFTCONN)
>  
> @@ -137,6 +138,7 @@ struct rpc_task_setup {
>  #define RPC_IS_SOFT(t)		((t)->tk_flags & (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
>  #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)
>  #define RPC_WAS_SENT(t)		((t)->tk_flags & RPC_TASK_SENT)
> +#define RPC_SKIP_CONG(t)	((t)->tk_flags & RPC_TASK_NO_CONG)
>  
>  #define RPC_TASK_RUNNING	0
>  #define RPC_TASK_QUEUED		1
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index b530a28..a477ee6 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -392,6 +392,10 @@ static inline void xprt_release_write(struct rpc_xprt *xprt, struct rpc_task *ta
>  {
>  	struct rpc_rqst *req = task->tk_rqstp;
>  
> +	if (RPC_SKIP_CONG(task)) {
> +		req->rq_cong = 0;
> +		return 1;
> +	}
>  	if (req->rq_cong)
>  		return 1;
>  	dprintk("RPC: %5u xprt_cwnd_limited cong = %lu cwnd = %lu\n",
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 3a5a805..073fecd 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -546,7 +546,8 @@ static void rpcrdma_keepalive_release(void *calldata)
>  
>  	data = xprt_get(xprt);
>  	null_task = rpc_call_null_helper(task->tk_client, xprt, NULL,
> -					 RPC_TASK_SOFTPING | RPC_TASK_ASYNC,
> +					 RPC_TASK_SOFTPING | RPC_TASK_ASYNC |
> +					 RPC_TASK_NO_CONG,
>  					 &rpcrdma_keepalive_call_ops, data);
>  	if (!IS_ERR(null_task))
>  		rpc_put_task(null_task);
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 81cd31a..d9b5fa7 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -136,19 +136,20 @@
>  static void
>  rpcrdma_update_granted_credits(struct rpcrdma_rep *rep)
>  {
> -	struct rpcrdma_msg *rmsgp = rdmab_to_msg(rep->rr_rdmabuf);
>  	struct rpcrdma_buffer *buffer = &rep->rr_rxprt->rx_buf;
> +	__be32 *p = rep->rr_rdmabuf->rg_base;
>  	u32 credits;
>  
>  	if (rep->rr_len < RPCRDMA_HDRLEN_ERR)
>  		return;
>  
> -	credits = be32_to_cpu(rmsgp->rm_credit);
> +	credits = be32_to_cpup(p + 2);
> +	if (credits > buffer->rb_max_requests)
> +		credits = buffer->rb_max_requests;
> +	/* Reserve one credit for keepalive ping */
> +	credits--;
>  	if (credits == 0)
>  		credits = 1;	/* don't deadlock */
> -	else if (credits > buffer->rb_max_requests)
> -		credits = buffer->rb_max_requests;
> -
>  	atomic_set(&buffer->rb_credits, credits);
>  }
>  
> @@ -915,6 +916,8 @@ struct rpcrdma_rep *
>  	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
>  	int i, rc;
>  
> +	if (r_xprt->rx_data.max_requests < 2)
> +		return -EINVAL;
>  	buf->rb_max_requests = r_xprt->rx_data.max_requests;
>  	buf->rb_bc_srv_max_requests = 0;
>  	atomic_set(&buf->rb_credits, 1);
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 95c1e3d..dd1340f 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -77,8 +77,8 @@ struct rpcrdma_ia {
>  	unsigned int		ri_max_send_sges;
>  	bool			ri_reminv_expected;
>  	bool			ri_implicit_roundup;
> -	unsigned long		ri_flags;
>  	enum ib_mr_type		ri_mrtype;
> +	unsigned long		ri_flags;

Any reason for the reordering here?

Thanks,
Anna

>  	struct ib_qp_attr	ri_qp_attr;
>  	struct ib_qp_init_attr	ri_qp_init_attr;
>  };
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
