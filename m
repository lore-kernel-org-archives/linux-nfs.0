Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:40377 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbeCPO21 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2018 10:28:27 -0400
Subject: [PATCH 1/2] xprtrdma: Move Receive posting to rpcrdma_reply_handler
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 16 Mar 2018 10:28:24 -0400
Message-ID: <20180316142824.14085.21750.stgit@manet.1015granger.net>
In-Reply-To: <20180316141927.14085.31012.stgit@manet.1015granger.net>
References: <20180316141927.14085.31012.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Receive completion and Reply handling are done by a BOUND
workqueue, meaning they run on only one CPU.

Posting receives is currently done in the send_request path, which
on large systems is typically done on a different CPU than the one
handling Receive completions. This results in movement of
receive-related cachelines between the sending and receiving CPUs.
More importantly, it means that Receives are posted while the
transport's write lock is held, which is actually unnecessary.

So instead, post Receives in the Receive completion handler.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h    |    7 --
 net/sunrpc/xprtrdma/backchannel.c |   10 +-
 net/sunrpc/xprtrdma/rpc_rdma.c    |   17 ++--
 net/sunrpc/xprtrdma/transport.c   |    3 -
 net/sunrpc/xprtrdma/verbs.c       |  153 ++++++++++++++-----------------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    7 --
 6 files changed, 74 insertions(+), 123 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 50ed3f8..91c89eb 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -799,7 +799,6 @@
 		__field(unsigned int, task_id)
 		__field(unsigned int, client_id)
 		__field(const void *, req)
-		__field(const void *, rep)
 		__field(size_t, callsize)
 		__field(size_t, rcvsize)
 	),
@@ -808,15 +807,13 @@
 		__entry->task_id = task->tk_pid;
 		__entry->client_id = task->tk_client->cl_clid;
 		__entry->req = req;
-		__entry->rep = req ? req->rl_reply : NULL;
 		__entry->callsize = task->tk_rqstp->rq_callsize;
 		__entry->rcvsize = task->tk_rqstp->rq_rcvsize;
 	),
 
-	TP_printk("task:%u@%u req=%p rep=%p (%zu, %zu)",
+	TP_printk("task:%u@%u req=%p (%zu, %zu)",
 		__entry->task_id, __entry->client_id,
-		__entry->req, __entry->rep,
-		__entry->callsize, __entry->rcvsize
+		__entry->req, __entry->callsize, __entry->rcvsize
 	)
 );
 
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 6b21fb8..3c81181 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -99,9 +99,7 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 	if (rc)
 		goto out_free;
 
-	rc = rpcrdma_ep_post_extra_recv(r_xprt, reqs);
-	if (rc)
-		goto out_free;
+	rpcrdma_ep_post_recvs(r_xprt);
 
 	r_xprt->rx_buf.rb_bc_srv_max_requests = reqs;
 	request_module("svcrdma");
@@ -247,10 +245,14 @@ void xprt_rdma_bc_destroy(struct rpc_xprt *xprt, unsigned int reqs)
  */
 void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 {
+	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	struct rpc_xprt *xprt = rqst->rq_xprt;
 
 	dprintk("RPC:       %s: freeing rqst %p (req %p)\n",
-		__func__, rqst, rpcr_to_rdmar(rqst));
+		__func__, rqst, req);
+
+	rpcrdma_recv_buffer_put(req->rl_reply);
+	req->rl_reply = NULL;
 
 	spin_lock_bh(&xprt->bc_pa_lock);
 	list_add_tail(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d15aa27..5e4ec09 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1026,8 +1026,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 out_short:
 	pr_warn("RPC/RDMA short backward direction call\n");
-	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, rep))
-		xprt_disconnect_done(&r_xprt->rx_xprt);
 	return true;
 }
 #else	/* CONFIG_SUNRPC_BACKCHANNEL */
@@ -1334,7 +1332,10 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	int total;
 	__be32 *p;
 
+	--buf->rb_posted_receives;
+
 	total = buf->rb_max_requests + (buf->rb_bc_srv_max_requests << 1);
+	total += buf->rb_max_requests >> 3;
 	total -= buf->rb_reps;
 	if (total > 0)
 		while (total--)
@@ -1344,6 +1345,10 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	if (rep->rr_hdrbuf.head[0].iov_len == 0)
 		goto out_badstatus;
 
+	if (buf->rb_posted_receives <
+	    buf->rb_reps - (buf->rb_max_requests >> 3))
+		rpcrdma_ep_post_recvs(r_xprt);
+
 	xdr_init_decode(&rep->rr_stream, &rep->rr_hdrbuf,
 			rep->rr_hdrbuf.head[0].iov_base);
 
@@ -1391,10 +1396,6 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 
 out_badstatus:
 	rpcrdma_recv_buffer_put(rep);
-	if (r_xprt->rx_ep.rep_connected == 1) {
-		r_xprt->rx_ep.rep_connected = -EIO;
-		rpcrdma_conn_func(&r_xprt->rx_ep);
-	}
 	return;
 
 out_badversion:
@@ -1416,7 +1417,5 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
  * receive buffer before returning.
  */
 repost:
-	r_xprt->rx_stats.bad_reply_count++;
-	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, rep))
-		rpcrdma_recv_buffer_put(rep);
+	rpcrdma_recv_buffer_put(rep);
 }
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index e0ab2b2..6dac2e1 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -721,9 +721,6 @@
 	if (rc < 0)
 		goto failed_marshal;
 
-	if (req->rl_reply == NULL) 		/* e.g. reconnection */
-		rpcrdma_recv_buffer_get(req);
-
 	/* Must suppress retransmit to maintain credits */
 	if (rqst->rq_connect_cookie == xprt->connect_cookie)
 		goto drop_connection;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index af74953..201b4ad 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -278,6 +278,7 @@
 		connstate = -ECONNABORTED;
 connected:
 		xprt->rx_buf.rb_credits = 1;
+		xprt->rx_buf.rb_posted_receives = 0;
 		ep->rep_connected = connstate;
 		rpcrdma_conn_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
@@ -736,7 +737,6 @@
 {
 	struct rpcrdma_xprt *r_xprt = container_of(ia, struct rpcrdma_xprt,
 						   rx_ia);
-	unsigned int extras;
 	int rc;
 
 retry:
@@ -780,9 +780,7 @@
 	}
 
 	dprintk("RPC:       %s: connected\n", __func__);
-	extras = r_xprt->rx_buf.rb_bc_srv_max_requests;
-	if (extras)
-		rpcrdma_ep_post_extra_recv(r_xprt, extras);
+	rpcrdma_ep_post_recvs(r_xprt);
 
 out:
 	if (rc)
@@ -1280,7 +1278,6 @@ struct rpcrdma_req *
 		rep = rpcrdma_buffer_get_rep_locked(buf);
 		rpcrdma_destroy_rep(rep);
 	}
-	buf->rb_send_count = 0;
 
 	spin_lock(&buf->rb_reqslock);
 	while (!list_empty(&buf->rb_allreqs)) {
@@ -1295,7 +1292,6 @@ struct rpcrdma_req *
 		spin_lock(&buf->rb_reqslock);
 	}
 	spin_unlock(&buf->rb_reqslock);
-	buf->rb_recv_count = 0;
 
 	rpcrdma_mrs_destroy(buf);
 }
@@ -1368,27 +1364,11 @@ struct rpcrdma_mr *
 	__rpcrdma_mr_put(&r_xprt->rx_buf, mr);
 }
 
-static struct rpcrdma_rep *
-rpcrdma_buffer_get_rep(struct rpcrdma_buffer *buffers)
-{
-	/* If an RPC previously completed without a reply (say, a
-	 * credential problem or a soft timeout occurs) then hold off
-	 * on supplying more Receive buffers until the number of new
-	 * pending RPCs catches up to the number of posted Receives.
-	 */
-	if (unlikely(buffers->rb_send_count < buffers->rb_recv_count))
-		return NULL;
-
-	if (unlikely(list_empty(&buffers->rb_recv_bufs)))
-		return NULL;
-	buffers->rb_recv_count++;
-	return rpcrdma_buffer_get_rep_locked(buffers);
-}
-
-/*
- * Get a set of request/reply buffers.
+/**
+ * rpcrdma_buffer_get - Get a request buffer
+ * @buffers: Buffer pool from which to obtain a buffer
  *
- * Reply buffer (if available) is attached to send buffer upon return.
+ * Returns a fresh rpcrdma_req, or NULL if none are available.
  */
 struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
@@ -1396,23 +1376,21 @@ struct rpcrdma_req *
 	struct rpcrdma_req *req;
 
 	spin_lock(&buffers->rb_lock);
-	if (list_empty(&buffers->rb_send_bufs))
-		goto out_reqbuf;
-	buffers->rb_send_count++;
+	if (unlikely(list_empty(&buffers->rb_send_bufs)))
+		goto out_noreqs;
 	req = rpcrdma_buffer_get_req_locked(buffers);
-	req->rl_reply = rpcrdma_buffer_get_rep(buffers);
 	spin_unlock(&buffers->rb_lock);
-
 	return req;
 
-out_reqbuf:
+out_noreqs:
 	spin_unlock(&buffers->rb_lock);
 	return NULL;
 }
 
-/*
- * Put request/reply buffers back into pool.
- * Pre-decrement counter/array index.
+/**
+ * rpcrdma_buffer_put - Put request/reply buffers back into pool
+ * @req: object to return
+ *
  */
 void
 rpcrdma_buffer_put(struct rpcrdma_req *req)
@@ -1423,10 +1401,8 @@ struct rpcrdma_req *
 	req->rl_reply = NULL;
 
 	spin_lock(&buffers->rb_lock);
-	buffers->rb_send_count--;
 	list_add(&req->rl_list, &buffers->rb_send_bufs);
 	if (rep) {
-		buffers->rb_recv_count--;
 		if (!rep->rr_temp) {
 			list_add(&rep->rr_list, &buffers->rb_recv_bufs);
 			rep = NULL;
@@ -1447,7 +1423,8 @@ struct rpcrdma_req *
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
 
 	spin_lock(&buffers->rb_lock);
-	req->rl_reply = rpcrdma_buffer_get_rep(buffers);
+	if (!list_empty(&buffers->rb_recv_bufs))
+		req->rl_reply = rpcrdma_buffer_get_rep_locked(buffers);
 	spin_unlock(&buffers->rb_lock);
 }
 
@@ -1460,15 +1437,13 @@ struct rpcrdma_req *
 {
 	struct rpcrdma_buffer *buffers = &rep->rr_rxprt->rx_buf;
 
-	spin_lock(&buffers->rb_lock);
-	buffers->rb_recv_count--;
 	if (!rep->rr_temp) {
+		spin_lock(&buffers->rb_lock);
 		list_add(&rep->rr_list, &buffers->rb_recv_bufs);
-		rep = NULL;
-	}
-	spin_unlock(&buffers->rb_lock);
-	if (rep)
+		spin_unlock(&buffers->rb_lock);
+	} else {
 		rpcrdma_destroy_rep(rep);
+	}
 }
 
 /**
@@ -1564,13 +1539,6 @@ struct rpcrdma_regbuf *
 	struct ib_send_wr *send_wr = &req->rl_sendctx->sc_wr;
 	int rc;
 
-	if (req->rl_reply) {
-		rc = rpcrdma_ep_post_recv(ia, req->rl_reply);
-		if (rc)
-			return rc;
-		req->rl_reply = NULL;
-	}
-
 	if (!ep->rep_send_count ||
 	    test_bit(RPCRDMA_REQ_F_TX_RESOURCES, &req->rl_flags)) {
 		send_wr->send_flags |= IB_SEND_SIGNALED;
@@ -1587,61 +1555,52 @@ struct rpcrdma_regbuf *
 	return 0;
 }
 
-int
-rpcrdma_ep_post_recv(struct rpcrdma_ia *ia,
-		     struct rpcrdma_rep *rep)
-{
-	struct ib_recv_wr *recv_wr_fail;
-	int rc;
-
-	if (!rpcrdma_dma_map_regbuf(ia, rep->rr_rdmabuf))
-		goto out_map;
-	rc = ib_post_recv(ia->ri_id->qp, &rep->rr_recv_wr, &recv_wr_fail);
-	trace_xprtrdma_post_recv(rep, rc);
-	if (rc)
-		return -ENOTCONN;
-	return 0;
-
-out_map:
-	pr_err("rpcrdma: failed to DMA map the Receive buffer\n");
-	return -EIO;
-}
-
 /**
- * rpcrdma_ep_post_extra_recv - Post buffers for incoming backchannel requests
- * @r_xprt: transport associated with these backchannel resources
- * @count: minimum number of incoming requests expected
+ * rpcrdma_ep_post_recvs - Post all available rpcrdma_reps
+ * @r_xprt: controlling transport
  *
- * Returns zero if all requested buffers were posted, or a negative errno.
  */
-int
-rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *r_xprt, unsigned int count)
+void
+rpcrdma_ep_post_recvs(struct rpcrdma_xprt *r_xprt)
 {
-	struct rpcrdma_buffer *buffers = &r_xprt->rx_buf;
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct ib_recv_wr *wr, *bad_wr;
 	struct rpcrdma_rep *rep;
+	unsigned int count;
 	int rc;
 
-	while (count--) {
-		spin_lock(&buffers->rb_lock);
-		if (list_empty(&buffers->rb_recv_bufs))
-			goto out_reqbuf;
-		rep = rpcrdma_buffer_get_rep_locked(buffers);
-		spin_unlock(&buffers->rb_lock);
-
-		rc = rpcrdma_ep_post_recv(ia, rep);
-		if (rc)
-			goto out_rc;
-	}
+	rc = 0;
+	count = 0;
+	wr = NULL;
+	spin_lock(&buf->rb_lock);
+	while (!list_empty(&buf->rb_recv_bufs)) {
+		rep = rpcrdma_buffer_get_rep_locked(buf);
 
-	return 0;
+		if (!rpcrdma_regbuf_is_mapped(rep->rr_rdmabuf)) {
+			spin_unlock(&buf->rb_lock);
+			if (!__rpcrdma_dma_map_regbuf(ia, rep->rr_rdmabuf)) {
+				rpcrdma_recv_buffer_put(rep);
+				goto post;
+			}
+			spin_lock(&buf->rb_lock);
+		}
 
-out_reqbuf:
-	spin_unlock(&buffers->rb_lock);
-	trace_xprtrdma_noreps(r_xprt);
-	return -ENOMEM;
+		rep->rr_recv_wr.next = wr;
+		wr = &rep->rr_recv_wr;
+		++count;
+	}
+	spin_unlock(&buf->rb_lock);
 
-out_rc:
-	rpcrdma_recv_buffer_put(rep);
-	return rc;
+post:
+	if (wr)
+		rc = ib_post_recv(ia->ri_id->qp, wr, &bad_wr);
+	if (rc) {
+		for (wr = bad_wr; wr; wr = wr->next) {
+			rep = container_of(wr, struct rpcrdma_rep, rr_recv_wr);
+			rpcrdma_recv_buffer_put(rep);
+			--count;
+		}
+	}
+	buf->rb_posted_receives += count;
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 5f069c7..9cbe6e7 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -397,12 +397,11 @@ struct rpcrdma_buffer {
 	struct rpcrdma_sendctx	**rb_sc_ctxs;
 
 	spinlock_t		rb_lock;	/* protect buf lists */
-	int			rb_send_count, rb_recv_count;
 	struct list_head	rb_send_bufs;
 	struct list_head	rb_recv_bufs;
 	u32			rb_max_requests;
 	u32			rb_credits;	/* most recent credit grant */
-	unsigned int		rb_reps;
+	int			rb_reps, rb_posted_receives;
 
 	u32			rb_bc_srv_max_requests;
 	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
@@ -558,7 +557,7 @@ int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
 
 int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 				struct rpcrdma_req *);
-int rpcrdma_ep_post_recv(struct rpcrdma_ia *, struct rpcrdma_rep *);
+void rpcrdma_ep_post_recvs(struct rpcrdma_xprt *r_xprt);
 
 /*
  * Buffer calls - xprtrdma/verbs.c
@@ -600,8 +599,6 @@ struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
 	return __rpcrdma_dma_map_regbuf(ia, rb);
 }
 
-int rpcrdma_ep_post_extra_recv(struct rpcrdma_xprt *, unsigned int);
-
 int rpcrdma_alloc_wq(void);
 void rpcrdma_destroy_wq(void);
 

