Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:23428 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168AbbKXTyk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 14:54:40 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v1 7/9] SUNRPC: Introduct xprt_commit_rqst()
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221446.32702.24797.stgit@manet.1015granger.net>
Message-ID: <5654C079.7060507@Netapp.com>
Date: Tue, 24 Nov 2015 14:54:33 -0500
MIME-Version: 1.0
In-Reply-To: <20151123221446.32702.24797.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 11/23/2015 05:14 PM, Chuck Lever wrote:
> I'm about to add code in the RPC/RDMA reply handler between the
> xprt_lookup_rqst() and xprt_complete_rqst() call site that needs
> to execute outside of spinlock critical sections.
> 
> Add a hook to remove an rpc_rqst from the pending list once
> the transport knows its going to invoke xprt_complete_rqst().
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/xprt.h    |    1 +
>  net/sunrpc/xprt.c              |   14 ++++++++++++++
>  net/sunrpc/xprtrdma/rpc_rdma.c |    4 ++++
>  3 files changed, 19 insertions(+)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 69ef5b3..ab6c3a5 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -366,6 +366,7 @@ void			xprt_wait_for_buffer_space(struct rpc_task *task, rpc_action action);
>  void			xprt_write_space(struct rpc_xprt *xprt);
>  void			xprt_adjust_cwnd(struct rpc_xprt *xprt, struct rpc_task *task, int result);
>  struct rpc_rqst *	xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid);
> +void			xprt_commit_rqst(struct rpc_task *task);
>  void			xprt_complete_rqst(struct rpc_task *task, int copied);
>  void			xprt_release_rqst_cong(struct rpc_task *task);
>  void			xprt_disconnect_done(struct rpc_xprt *xprt);
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 2e98f4a..a5be4ab 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -837,6 +837,20 @@ static void xprt_update_rtt(struct rpc_task *task)
>  }
>  
>  /**
> + * xprt_commit_rqst - remove rqst from pending list early
> + * @task: RPC request to remove

Is xprt_commit_rqst() the right name for this function?  Removing a request from a list isn't how I would expect a commit to work.

Anna

> + *
> + * Caller holds transport lock.
> + */
> +void xprt_commit_rqst(struct rpc_task *task)
> +{
> +	struct rpc_rqst *req = task->tk_rqstp;
> +
> +	list_del_init(&req->rq_list);
> +}
> +EXPORT_SYMBOL_GPL(xprt_commit_rqst);
> +
> +/**
>   * xprt_complete_rqst - called when reply processing is complete
>   * @task: RPC request that recently completed
>   * @copied: actual number of bytes received from the transport
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index a169252..d7b9156 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -811,6 +811,9 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>  	if (req->rl_reply)
>  		goto out_duplicate;
>  
> +	xprt_commit_rqst(rqst->rq_task);
> +	spin_unlock_bh(&xprt->transport_lock);
> +
>  	dprintk("RPC:       %s: reply 0x%p completes request 0x%p\n"
>  		"                   RPC request 0x%p xid 0x%08x\n",
>  			__func__, rep, req, rqst,
> @@ -901,6 +904,7 @@ badheader:
>  	else if (credits > r_xprt->rx_buf.rb_max_requests)
>  		credits = r_xprt->rx_buf.rb_max_requests;
>  
> +	spin_lock_bh(&xprt->transport_lock);
>  	cwnd = xprt->cwnd;
>  	xprt->cwnd = credits << RPC_CWNDSHIFT;
>  	if (xprt->cwnd > cwnd)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

