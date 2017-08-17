Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34024 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751856AbdHQBwY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 21:52:24 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 5/5] SUNRPC: Add a separate spinlock to protect the RPC request receive list
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170816230008.20006-6-trond.myklebust@primarydata.com>
Date: Wed, 16 Aug 2017 21:52:19 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E4FB27DD-7B08-4924-A5E6-C068FC741274@oracle.com>
References: <20170816230008.20006-1-trond.myklebust@primarydata.com> <20170816230008.20006-2-trond.myklebust@primarydata.com> <20170816230008.20006-3-trond.myklebust@primarydata.com> <20170816230008.20006-4-trond.myklebust@primarydata.com> <20170816230008.20006-5-trond.myklebust@primarydata.com> <20170816230008.20006-6-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 16, 2017, at 7:00 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> This further reduces contention with the transport_lock, and allows us
> to convert to using a non-bh-safe spinlock, since the list is now never
> accessed from a bh context.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> include/linux/sunrpc/xprt.h    |  1 +
> net/sunrpc/xprt.c              | 20 ++++++++++++--------
> net/sunrpc/xprtrdma/rpc_rdma.c |  8 ++++----
> net/sunrpc/xprtsock.c          | 30 ++++++++++++++++--------------
> 4 files changed, 33 insertions(+), 26 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 65b9e0224753..a97e6de5f9f2 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -232,6 +232,7 @@ struct rpc_xprt {
> 	 */
> 	spinlock_t		transport_lock;	/* lock transport info */
> 	spinlock_t		reserve_lock;	/* lock slot table */
> +	spinlock_t		recv_lock;	/* lock receive list */

It might be better to put xprt->recv_lock in the same cacheline as xprt->recv.

The rpcrdma_reply_handler changes look correct.

I'll carve out some time tomorrow or Friday to try these out.


> 	u32			xid;		/* Next XID value to use */
> 	struct rpc_task *	snd_task;	/* Task blocked in send */
> 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 3eb9ec16eec4..2af189c5ac3e 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -872,17 +872,17 @@ void xprt_unpin_rqst(struct rpc_rqst *req)
> }
> 
> static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
> -__must_hold(&req->rq_xprt->transport_lock)
> +__must_hold(&req->rq_xprt->recv_lock)
> {
> 	struct rpc_task *task = req->rq_task;
> 	
> 	if (task && test_bit(RPC_TASK_MSG_RECV, &task->tk_runstate)) {
> -		spin_unlock_bh(&req->rq_xprt->transport_lock);
> +		spin_unlock(&req->rq_xprt->recv_lock);
> 		set_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
> 		wait_on_bit(&task->tk_runstate, RPC_TASK_MSG_RECV,
> 				TASK_UNINTERRUPTIBLE);
> 		clear_bit(RPC_TASK_MSG_RECV_WAIT, &task->tk_runstate);
> -		spin_lock_bh(&req->rq_xprt->transport_lock);
> +		spin_lock(&req->rq_xprt->recv_lock);
> 	}
> }
> 
> @@ -1008,13 +1008,13 @@ void xprt_transmit(struct rpc_task *task)
> 			/*
> 			 * Add to the list only if we're expecting a reply
> 			 */
> -			spin_lock_bh(&xprt->transport_lock);
> 			/* Update the softirq receive buffer */
> 			memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
> 					sizeof(req->rq_private_buf));
> 			/* Add request to the receive list */
> +			spin_lock(&xprt->recv_lock);
> 			list_add_tail(&req->rq_list, &xprt->recv);
> -			spin_unlock_bh(&xprt->transport_lock);
> +			spin_unlock(&xprt->recv_lock);
> 			xprt_reset_majortimeo(req);
> 			/* Turn off autodisconnect */
> 			del_singleshot_timer_sync(&xprt->timer);
> @@ -1329,15 +1329,18 @@ void xprt_release(struct rpc_task *task)
> 		task->tk_ops->rpc_count_stats(task, task->tk_calldata);
> 	else if (task->tk_client)
> 		rpc_count_iostats(task, task->tk_client->cl_metrics);
> +	spin_lock(&xprt->recv_lock);
> +	if (!list_empty(&req->rq_list)) {
> +		list_del(&req->rq_list);
> +		xprt_wait_on_pinned_rqst(req);
> +	}
> +	spin_unlock(&xprt->recv_lock);
> 	spin_lock_bh(&xprt->transport_lock);
> 	xprt->ops->release_xprt(xprt, task);
> 	if (xprt->ops->release_request)
> 		xprt->ops->release_request(task);
> -	if (!list_empty(&req->rq_list))
> -		list_del(&req->rq_list);
> 	xprt->last_used = jiffies;
> 	xprt_schedule_autodisconnect(xprt);
> -	xprt_wait_on_pinned_rqst(req);
> 	spin_unlock_bh(&xprt->transport_lock);
> 	if (req->rq_buffer)
> 		xprt->ops->buf_free(task);
> @@ -1361,6 +1364,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
> 
> 	spin_lock_init(&xprt->transport_lock);
> 	spin_lock_init(&xprt->reserve_lock);
> +	spin_lock_init(&xprt->recv_lock);
> 
> 	INIT_LIST_HEAD(&xprt->free);
> 	INIT_LIST_HEAD(&xprt->recv);
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index ca4d6e4528f3..dfa748a0c8de 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -1051,7 +1051,7 @@ rpcrdma_reply_handler(struct work_struct *work)
> 	 * RPC completion while holding the transport lock to ensure
> 	 * the rep, rqst, and rq_task pointers remain stable.
> 	 */
> -	spin_lock_bh(&xprt->transport_lock);
> +	spin_lock(&xprt->recv_lock);
> 	rqst = xprt_lookup_rqst(xprt, headerp->rm_xid);
> 	if (!rqst)
> 		goto out_norqst;
> @@ -1136,7 +1136,7 @@ rpcrdma_reply_handler(struct work_struct *work)
> 		xprt_release_rqst_cong(rqst->rq_task);
> 
> 	xprt_complete_rqst(rqst->rq_task, status);
> -	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> 	dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
> 		__func__, xprt, rqst, status);
> 	return;
> @@ -1187,12 +1187,12 @@ rpcrdma_reply_handler(struct work_struct *work)
> 	r_xprt->rx_stats.bad_reply_count++;
> 	goto out;
> 
> -/* The req was still available, but by the time the transport_lock
> +/* The req was still available, but by the time the recv_lock
>  * was acquired, the rqst and task had been released. Thus the RPC
>  * has already been terminated.
>  */
> out_norqst:
> -	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> 	rpcrdma_buffer_put(req);
> 	dprintk("RPC:       %s: race, no rqst left for req %p\n",
> 		__func__, req);
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index a344bea15fc7..2b918137aaa0 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -969,12 +969,12 @@ static void xs_local_data_read_skb(struct rpc_xprt *xprt,
> 		return;
> 
> 	/* Look up and lock the request corresponding to the given XID */
> -	spin_lock_bh(&xprt->transport_lock);
> +	spin_lock(&xprt->recv_lock);
> 	rovr = xprt_lookup_rqst(xprt, *xp);
> 	if (!rovr)
> 		goto out_unlock;
> 	xprt_pin_rqst(rovr);
> -	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> 	task = rovr->rq_task;
> 
> 	copied = rovr->rq_private_buf.buflen;
> @@ -983,16 +983,16 @@ static void xs_local_data_read_skb(struct rpc_xprt *xprt,
> 
> 	if (xs_local_copy_to_xdr(&rovr->rq_private_buf, skb)) {
> 		dprintk("RPC:       sk_buff copy failed\n");
> -		spin_lock_bh(&xprt->transport_lock);
> +		spin_lock(&xprt->recv_lock);
> 		goto out_unpin;
> 	}
> 
> -	spin_lock_bh(&xprt->transport_lock);
> +	spin_lock(&xprt->recv_lock);
> 	xprt_complete_rqst(task, copied);
> out_unpin:
> 	xprt_unpin_rqst(rovr);
>  out_unlock:
> -	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> }
> 
> static void xs_local_data_receive(struct sock_xprt *transport)
> @@ -1055,12 +1055,12 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
> 		return;
> 
> 	/* Look up and lock the request corresponding to the given XID */
> -	spin_lock_bh(&xprt->transport_lock);
> +	spin_lock(&xprt->recv_lock);
> 	rovr = xprt_lookup_rqst(xprt, *xp);
> 	if (!rovr)
> 		goto out_unlock;
> 	xprt_pin_rqst(rovr);
> -	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> 	task = rovr->rq_task;
> 
> 	if ((copied = rovr->rq_private_buf.buflen) > repsize)
> @@ -1069,7 +1069,7 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
> 	/* Suck it into the iovec, verify checksum if not done by hw. */
> 	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
> 		__UDPX_INC_STATS(sk, UDP_MIB_INERRORS);
> -		spin_lock_bh(&xprt->transport_lock);
> +		spin_lock(&xprt->recv_lock);
> 		goto out_unpin;
> 	}
> 
> @@ -1077,11 +1077,13 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
> 
> 	spin_lock_bh(&xprt->transport_lock);
> 	xprt_adjust_cwnd(xprt, task, copied);
> +	spin_unlock_bh(&xprt->transport_lock);
> +	spin_lock(&xprt->recv_lock);
> 	xprt_complete_rqst(task, copied);
> out_unpin:
> 	xprt_unpin_rqst(rovr);
>  out_unlock:
> -	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> }
> 
> static void xs_udp_data_receive(struct sock_xprt *transport)
> @@ -1344,24 +1346,24 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
> 	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->tcp_xid));
> 
> 	/* Find and lock the request corresponding to this xid */
> -	spin_lock_bh(&xprt->transport_lock);
> +	spin_lock(&xprt->recv_lock);
> 	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
> 	if (!req) {
> 		dprintk("RPC:       XID %08x request not found!\n",
> 				ntohl(transport->tcp_xid));
> -		spin_unlock_bh(&xprt->transport_lock);
> +		spin_unlock(&xprt->recv_lock);
> 		return -1;
> 	}
> 	xprt_pin_rqst(req);
> -	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> 
> 	xs_tcp_read_common(xprt, desc, req);
> 
> -	spin_lock_bh(&xprt->transport_lock);
> +	spin_lock(&xprt->recv_lock);
> 	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
> 		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
> 	xprt_unpin_rqst(req);
> -	spin_unlock_bh(&xprt->transport_lock);
> +	spin_unlock(&xprt->recv_lock);
> 	return 0;
> }
> 
> -- 
> 2.13.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



