Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37317 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727393AbeICTux (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:53 -0400
Received: by mail-io0-f194.google.com with SMTP id v14-v6so695865iob.4
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:13 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.10
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:10 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/27] SUNRPC: Rename xprt->recv_lock to xprt->queue_lock
Date: Mon,  3 Sep 2018 11:29:22 -0400
Message-Id: <20180903152936.24325-14-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-13-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
 <20180903152936.24325-6-trond.myklebust@hammerspace.com>
 <20180903152936.24325-7-trond.myklebust@hammerspace.com>
 <20180903152936.24325-8-trond.myklebust@hammerspace.com>
 <20180903152936.24325-9-trond.myklebust@hammerspace.com>
 <20180903152936.24325-10-trond.myklebust@hammerspace.com>
 <20180903152936.24325-11-trond.myklebust@hammerspace.com>
 <20180903152936.24325-12-trond.myklebust@hammerspace.com>
 <20180903152936.24325-13-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We will use the same lock to protect both the transmit and receive queues.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h                |  2 +-
 net/sunrpc/svcsock.c                       |  6 ++---
 net/sunrpc/xprt.c                          | 24 ++++++++---------
 net/sunrpc/xprtrdma/rpc_rdma.c             | 10 ++++----
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  4 +--
 net/sunrpc/xprtsock.c                      | 30 +++++++++++-----------
 6 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index bd743c51a865..c25d0a5fda69 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -235,7 +235,7 @@ struct rpc_xprt {
 	 */
 	spinlock_t		transport_lock;	/* lock transport info */
 	spinlock_t		reserve_lock;	/* lock slot table */
-	spinlock_t		recv_lock;	/* lock receive list */
+	spinlock_t		queue_lock;	/* send/receive queue lock */
 	u32			xid;		/* Next XID value to use */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 5445145e639c..db8bb6b3a2b0 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1004,7 +1004,7 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 
 	if (!bc_xprt)
 		return -EAGAIN;
-	spin_lock(&bc_xprt->recv_lock);
+	spin_lock(&bc_xprt->queue_lock);
 	req = xprt_lookup_rqst(bc_xprt, xid);
 	if (!req)
 		goto unlock_notfound;
@@ -1022,7 +1022,7 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	memcpy(dst->iov_base, src->iov_base, src->iov_len);
 	xprt_complete_rqst(req->rq_task, rqstp->rq_arg.len);
 	rqstp->rq_arg.len = 0;
-	spin_unlock(&bc_xprt->recv_lock);
+	spin_unlock(&bc_xprt->queue_lock);
 	return 0;
 unlock_notfound:
 	printk(KERN_NOTICE
@@ -1031,7 +1031,7 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		__func__, ntohl(calldir),
 		bc_xprt, ntohl(xid));
 unlock_eagain:
-	spin_unlock(&bc_xprt->recv_lock);
+	spin_unlock(&bc_xprt->queue_lock);
 	return -EAGAIN;
 }
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 0441e6c8153d..eda305de9f77 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -826,7 +826,7 @@ static void xprt_connect_status(struct rpc_task *task)
  * @xprt: transport on which the original request was transmitted
  * @xid: RPC XID of incoming reply
  *
- * Caller holds xprt->recv_lock.
+ * Caller holds xprt->queue_lock.
  */
 struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 {
@@ -888,7 +888,7 @@ static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
  * xprt_update_rtt - Update RPC RTT statistics
  * @task: RPC request that recently completed
  *
- * Caller holds xprt->recv_lock.
+ * Caller holds xprt->queue_lock.
  */
 void xprt_update_rtt(struct rpc_task *task)
 {
@@ -910,7 +910,7 @@ EXPORT_SYMBOL_GPL(xprt_update_rtt);
  * @task: RPC request that recently completed
  * @copied: actual number of bytes received from the transport
  *
- * Caller holds xprt->recv_lock.
+ * Caller holds xprt->queue_lock.
  */
 void xprt_complete_rqst(struct rpc_task *task, int copied)
 {
@@ -1030,10 +1030,10 @@ void xprt_transmit(struct rpc_task *task)
 			memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
 					sizeof(req->rq_private_buf));
 			/* Add request to the receive list */
-			spin_lock(&xprt->recv_lock);
+			spin_lock(&xprt->queue_lock);
 			list_add_tail(&req->rq_list, &xprt->recv);
 			set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
-			spin_unlock(&xprt->recv_lock);
+			spin_unlock(&xprt->queue_lock);
 			xprt_reset_majortimeo(req);
 			/* Turn off autodisconnect */
 			del_singleshot_timer_sync(&xprt->timer);
@@ -1072,7 +1072,7 @@ void xprt_transmit(struct rpc_task *task)
 		 * The spinlock ensures atomicity between the test of
 		 * req->rq_reply_bytes_recvd, and the call to rpc_sleep_on().
 		 */
-		spin_lock(&xprt->recv_lock);
+		spin_lock(&xprt->queue_lock);
 		if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
 			rpc_sleep_on(&xprt->pending, task, xprt_timer);
 			/* Wake up immediately if the connection was dropped */
@@ -1080,7 +1080,7 @@ void xprt_transmit(struct rpc_task *task)
 				rpc_wake_up_queued_task_set_status(&xprt->pending,
 						task, -ENOTCONN);
 		}
-		spin_unlock(&xprt->recv_lock);
+		spin_unlock(&xprt->queue_lock);
 	}
 }
 
@@ -1375,16 +1375,16 @@ void xprt_release(struct rpc_task *task)
 		task->tk_ops->rpc_count_stats(task, task->tk_calldata);
 	else if (task->tk_client)
 		rpc_count_iostats(task, task->tk_client->cl_metrics);
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	if (!list_empty(&req->rq_list)) {
 		list_del_init(&req->rq_list);
 		if (atomic_read(&req->rq_pin)) {
-			spin_unlock(&xprt->recv_lock);
+			spin_unlock(&xprt->queue_lock);
 			xprt_wait_on_pinned_rqst(req);
-			spin_lock(&xprt->recv_lock);
+			spin_lock(&xprt->queue_lock);
 		}
 	}
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt->ops->release_xprt(xprt, task);
 	if (xprt->ops->release_request)
@@ -1414,7 +1414,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 
 	spin_lock_init(&xprt->transport_lock);
 	spin_lock_init(&xprt->reserve_lock);
-	spin_lock_init(&xprt->recv_lock);
+	spin_lock_init(&xprt->queue_lock);
 
 	INIT_LIST_HEAD(&xprt->free);
 	INIT_LIST_HEAD(&xprt->recv);
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c8ae983c6cc0..0020dc401215 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1238,7 +1238,7 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 		goto out_badheader;
 
 out:
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	cwnd = xprt->cwnd;
 	xprt->cwnd = r_xprt->rx_buf.rb_credits << RPC_CWNDSHIFT;
 	if (xprt->cwnd > cwnd)
@@ -1246,7 +1246,7 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 
 	xprt_complete_rqst(rqst->rq_task, status);
 	xprt_unpin_rqst(rqst);
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 	return;
 
 /* If the incoming reply terminated a pending RPC, the next
@@ -1345,7 +1345,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	/* Match incoming rpcrdma_rep to an rpcrdma_req to
 	 * get context for handling any incoming chunks.
 	 */
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	rqst = xprt_lookup_rqst(xprt, rep->rr_xid);
 	if (!rqst)
 		goto out_norqst;
@@ -1357,7 +1357,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		credits = buf->rb_max_requests;
 	buf->rb_credits = credits;
 
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 
 	req = rpcr_to_rdmar(rqst);
 	req->rl_reply = rep;
@@ -1378,7 +1378,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
  * is corrupt.
  */
 out_norqst:
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 	trace_xprtrdma_reply_rqst(rep);
 	goto repost;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index a68180090554..09b12b7568fe 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -56,7 +56,7 @@ int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt, __be32 *rdma_resp,
 	if (src->iov_len < 24)
 		goto out_shortreply;
 
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	req = xprt_lookup_rqst(xprt, xid);
 	if (!req)
 		goto out_notfound;
@@ -86,7 +86,7 @@ int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt, __be32 *rdma_resp,
 	rcvbuf->len = 0;
 
 out_unlock:
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 out:
 	return ret;
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3fbccebd0b10..8d6404259ff9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -966,12 +966,12 @@ static void xs_local_data_read_skb(struct rpc_xprt *xprt,
 		return;
 
 	/* Look up and lock the request corresponding to the given XID */
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	rovr = xprt_lookup_rqst(xprt, *xp);
 	if (!rovr)
 		goto out_unlock;
 	xprt_pin_rqst(rovr);
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 	task = rovr->rq_task;
 
 	copied = rovr->rq_private_buf.buflen;
@@ -980,16 +980,16 @@ static void xs_local_data_read_skb(struct rpc_xprt *xprt,
 
 	if (xs_local_copy_to_xdr(&rovr->rq_private_buf, skb)) {
 		dprintk("RPC:       sk_buff copy failed\n");
-		spin_lock(&xprt->recv_lock);
+		spin_lock(&xprt->queue_lock);
 		goto out_unpin;
 	}
 
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	xprt_complete_rqst(task, copied);
 out_unpin:
 	xprt_unpin_rqst(rovr);
  out_unlock:
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 }
 
 static void xs_local_data_receive(struct sock_xprt *transport)
@@ -1058,13 +1058,13 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 		return;
 
 	/* Look up and lock the request corresponding to the given XID */
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	rovr = xprt_lookup_rqst(xprt, *xp);
 	if (!rovr)
 		goto out_unlock;
 	xprt_pin_rqst(rovr);
 	xprt_update_rtt(rovr->rq_task);
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 	task = rovr->rq_task;
 
 	if ((copied = rovr->rq_private_buf.buflen) > repsize)
@@ -1072,7 +1072,7 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 
 	/* Suck it into the iovec, verify checksum if not done by hw. */
 	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
-		spin_lock(&xprt->recv_lock);
+		spin_lock(&xprt->queue_lock);
 		__UDPX_INC_STATS(sk, UDP_MIB_INERRORS);
 		goto out_unpin;
 	}
@@ -1081,13 +1081,13 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 	spin_lock_bh(&xprt->transport_lock);
 	xprt_adjust_cwnd(xprt, task, copied);
 	spin_unlock_bh(&xprt->transport_lock);
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	xprt_complete_rqst(task, copied);
 	__UDPX_INC_STATS(sk, UDP_MIB_INDATAGRAMS);
 out_unpin:
 	xprt_unpin_rqst(rovr);
  out_unlock:
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 }
 
 static void xs_udp_data_receive(struct sock_xprt *transport)
@@ -1356,24 +1356,24 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
 	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->recv.xid));
 
 	/* Find and lock the request corresponding to this xid */
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	req = xprt_lookup_rqst(xprt, transport->recv.xid);
 	if (!req) {
 		dprintk("RPC:       XID %08x request not found!\n",
 				ntohl(transport->recv.xid));
-		spin_unlock(&xprt->recv_lock);
+		spin_unlock(&xprt->queue_lock);
 		return -1;
 	}
 	xprt_pin_rqst(req);
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 
 	xs_tcp_read_common(xprt, desc, req);
 
-	spin_lock(&xprt->recv_lock);
+	spin_lock(&xprt->queue_lock);
 	if (!(transport->recv.flags & TCP_RCV_COPY_DATA))
 		xprt_complete_rqst(req->rq_task, transport->recv.copied);
 	xprt_unpin_rqst(req);
-	spin_unlock(&xprt->recv_lock);
+	spin_unlock(&xprt->queue_lock);
 	return 0;
 }
 
-- 
2.17.1
