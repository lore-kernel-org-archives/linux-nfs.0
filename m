Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:40920 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728301AbeIQSbp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:45 -0400
Received: by mail-qt0-f174.google.com with SMTP id h4-v6so15113327qtj.7
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:30 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.28
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:28 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 27/44] SUNRPC: Support for congestion control when queuing is enabled
Date: Mon, 17 Sep 2018 09:03:18 -0400
Message-Id: <20180917130335.112832-28-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-27-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both RDMA and UDP transports require the request to get a "congestion control"
credit before they can be transmitted. Right now, this is done when
the request locks the socket. We'd like it to happen when a request attempts
to be transmitted for the first time.
In order to support retransmission of requests that already hold such
credits, we also want to ensure that they get queued first, so that we
don't deadlock with requests that have yet to obtain a credit.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h       |   2 +
 net/sunrpc/clnt.c                 |   5 ++
 net/sunrpc/xprt.c                 | 128 +++++++++++++++++++++---------
 net/sunrpc/xprtrdma/backchannel.c |   3 +
 net/sunrpc/xprtrdma/transport.c   |   3 +
 net/sunrpc/xprtsock.c             |   4 +
 6 files changed, 109 insertions(+), 36 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index e377620b9744..0d0cc127615e 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -397,6 +397,7 @@ void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_pin_rqst(struct rpc_rqst *req);
 void			xprt_unpin_rqst(struct rpc_rqst *req);
 void			xprt_release_rqst_cong(struct rpc_task *task);
+bool			xprt_request_get_cong(struct rpc_xprt *xprt, struct rpc_rqst *req);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
@@ -415,6 +416,7 @@ void			xprt_unlock_connect(struct rpc_xprt *, void *);
 #define XPRT_BINDING		(5)
 #define XPRT_CLOSING		(6)
 #define XPRT_CONGESTED		(9)
+#define XPRT_CWND_WAIT		(10)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8dc3d33827c4..f03911f84953 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1996,6 +1996,11 @@ call_transmit_status(struct rpc_task *task)
 		dprint_status(task);
 		xprt_end_transmit(task);
 		break;
+	case -EBADSLT:
+		xprt_end_transmit(task);
+		task->tk_action = call_transmit;
+		task->tk_status = 0;
+		break;
 	case -EBADMSG:
 		xprt_end_transmit(task);
 		task->tk_status = 0;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3e68f35f71f6..e07a54fbe1e7 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -68,8 +68,6 @@
 static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
 static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
 static void	xprt_connect_status(struct rpc_task *task);
-static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
-static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst *);
 static void	 xprt_destroy(struct rpc_xprt *xprt);
 
 static DEFINE_SPINLOCK(xprt_list_lock);
@@ -221,6 +219,31 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
 		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
 }
 
+static bool
+xprt_need_congestion_window_wait(struct rpc_xprt *xprt)
+{
+	return test_bit(XPRT_CWND_WAIT, &xprt->state);
+}
+
+static void
+xprt_set_congestion_window_wait(struct rpc_xprt *xprt)
+{
+	if (!list_empty(&xprt->xmit_queue)) {
+		/* Peek at head of queue to see if it can make progress */
+		if (list_first_entry(&xprt->xmit_queue, struct rpc_rqst,
+					rq_xmit)->rq_cong)
+			return;
+	}
+	set_bit(XPRT_CWND_WAIT, &xprt->state);
+}
+
+static void
+xprt_test_and_clear_congestion_window_wait(struct rpc_xprt *xprt)
+{
+	if (!RPCXPRT_CONGESTED(xprt))
+		clear_bit(XPRT_CWND_WAIT, &xprt->state);
+}
+
 /*
  * xprt_reserve_xprt_cong - serialize write access to transports
  * @task: task that is requesting access to the transport
@@ -228,6 +251,7 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
  * Same as xprt_reserve_xprt, but Van Jacobson congestion control is
  * integrated into the decision of whether a request is allowed to be
  * woken up and given access to the transport.
+ * Note that the lock is only granted if we know there are free slots.
  */
 int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 {
@@ -243,14 +267,12 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 		xprt->snd_task = task;
 		return 1;
 	}
-	if (__xprt_get_cong(xprt, task)) {
+	if (!xprt_need_congestion_window_wait(xprt)) {
 		xprt->snd_task = task;
 		return 1;
 	}
 	xprt_clear_locked(xprt);
 out_sleep:
-	if (req)
-		__xprt_put_cong(xprt, req);
 	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
@@ -294,32 +316,14 @@ static void __xprt_lock_write_next(struct rpc_xprt *xprt)
 	xprt_clear_locked(xprt);
 }
 
-static bool __xprt_lock_write_cong_func(struct rpc_task *task, void *data)
-{
-	struct rpc_xprt *xprt = data;
-	struct rpc_rqst *req;
-
-	req = task->tk_rqstp;
-	if (req == NULL) {
-		xprt->snd_task = task;
-		return true;
-	}
-	if (__xprt_get_cong(xprt, task)) {
-		xprt->snd_task = task;
-		req->rq_ntrans++;
-		return true;
-	}
-	return false;
-}
-
 static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
 {
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		return;
-	if (RPCXPRT_CONGESTED(xprt))
+	if (xprt_need_congestion_window_wait(xprt))
 		goto out_unlock;
 	if (rpc_wake_up_first_on_wq(xprtiod_workqueue, &xprt->sending,
-				__xprt_lock_write_cong_func, xprt))
+				__xprt_lock_write_func, xprt))
 		return;
 out_unlock:
 	xprt_clear_locked(xprt);
@@ -370,16 +374,16 @@ static inline void xprt_release_write(struct rpc_xprt *xprt, struct rpc_task *ta
  * overflowed. Put the task to sleep if this is the case.
  */
 static int
-__xprt_get_cong(struct rpc_xprt *xprt, struct rpc_task *task)
+__xprt_get_cong(struct rpc_xprt *xprt, struct rpc_rqst *req)
 {
-	struct rpc_rqst *req = task->tk_rqstp;
-
 	if (req->rq_cong)
 		return 1;
 	dprintk("RPC: %5u xprt_cwnd_limited cong = %lu cwnd = %lu\n",
-			task->tk_pid, xprt->cong, xprt->cwnd);
-	if (RPCXPRT_CONGESTED(xprt))
+			req->rq_task->tk_pid, xprt->cong, xprt->cwnd);
+	if (RPCXPRT_CONGESTED(xprt)) {
+		xprt_set_congestion_window_wait(xprt);
 		return 0;
+	}
 	req->rq_cong = 1;
 	xprt->cong += RPC_CWNDSCALE;
 	return 1;
@@ -396,9 +400,31 @@ __xprt_put_cong(struct rpc_xprt *xprt, struct rpc_rqst *req)
 		return;
 	req->rq_cong = 0;
 	xprt->cong -= RPC_CWNDSCALE;
+	xprt_test_and_clear_congestion_window_wait(xprt);
 	__xprt_lock_write_next_cong(xprt);
 }
 
+/**
+ * xprt_request_get_cong - Request congestion control credits
+ * @xprt: pointer to transport
+ * @req: pointer to RPC request
+ *
+ * Useful for transports that require congestion control.
+ */
+bool
+xprt_request_get_cong(struct rpc_xprt *xprt, struct rpc_rqst *req)
+{
+	bool ret = false;
+
+	if (req->rq_cong)
+		return true;
+	spin_lock_bh(&xprt->transport_lock);
+	ret = __xprt_get_cong(xprt, req) != 0;
+	spin_unlock_bh(&xprt->transport_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xprt_request_get_cong);
+
 /**
  * xprt_release_rqst_cong - housekeeping when request is complete
  * @task: RPC request that recently completed
@@ -413,6 +439,20 @@ void xprt_release_rqst_cong(struct rpc_task *task)
 }
 EXPORT_SYMBOL_GPL(xprt_release_rqst_cong);
 
+/*
+ * Clear the congestion window wait flag and wake up the next
+ * entry on xprt->sending
+ */
+static void
+xprt_clear_congestion_window_wait(struct rpc_xprt *xprt)
+{
+	if (test_and_clear_bit(XPRT_CWND_WAIT, &xprt->state)) {
+		spin_lock_bh(&xprt->transport_lock);
+		__xprt_lock_write_next_cong(xprt);
+		spin_unlock_bh(&xprt->transport_lock);
+	}
+}
+
 /**
  * xprt_adjust_cwnd - adjust transport congestion window
  * @xprt: pointer to xprt
@@ -1057,12 +1097,28 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 
 	if (xprt_request_need_enqueue_transmit(task, req)) {
 		spin_lock(&xprt->queue_lock);
-		list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
-			if (pos->rq_task->tk_owner != task->tk_owner)
-				continue;
-			list_add_tail(&req->rq_xmit2, &pos->rq_xmit2);
-			INIT_LIST_HEAD(&req->rq_xmit);
-			goto out;
+		/*
+		 * Requests that carry congestion control credits are added
+		 * to the head of the list to avoid starvation issues.
+		 */
+		if (req->rq_cong) {
+			xprt_clear_congestion_window_wait(xprt);
+			list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
+				if (pos->rq_cong)
+					continue;
+				/* Note: req is added _before_ pos */
+				list_add_tail(&req->rq_xmit, &pos->rq_xmit);
+				INIT_LIST_HEAD(&req->rq_xmit2);
+				goto out;
+			}
+		} else {
+			list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
+				if (pos->rq_task->tk_owner != task->tk_owner)
+					continue;
+				list_add_tail(&req->rq_xmit2, &pos->rq_xmit2);
+				INIT_LIST_HEAD(&req->rq_xmit);
+				goto out;
+			}
 		}
 		list_add_tail(&req->rq_xmit, &xprt->xmit_queue);
 		INIT_LIST_HEAD(&req->rq_xmit2);
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index ed58761e6b23..e7c445cee16f 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -200,6 +200,9 @@ int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
 	if (!xprt_connected(rqst->rq_xprt))
 		goto drop_connection;
 
+	if (!xprt_request_get_cong(rqst->rq_xprt, rqst))
+		return -EBADSLT;
+
 	rc = rpcrdma_bc_marshal_reply(rqst);
 	if (rc < 0)
 		goto failed_marshal;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index fa684bf4d090..9ff322e53f37 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -721,6 +721,9 @@ xprt_rdma_send_request(struct rpc_rqst *rqst, struct rpc_task *task)
 	if (!xprt_connected(xprt))
 		goto drop_connection;
 
+	if (!xprt_request_get_cong(xprt, rqst))
+		return -EBADSLT;
+
 	rc = rpcrdma_marshal_req(r_xprt, rqst);
 	if (rc < 0)
 		goto failed_marshal;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b8143eded4af..8831e84a058a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -609,6 +609,10 @@ static int xs_udp_send_request(struct rpc_rqst *req, struct rpc_task *task)
 
 	if (!xprt_bound(xprt))
 		return -ENOTCONN;
+
+	if (!xprt_request_get_cong(xprt, req))
+		return -EBADSLT;
+
 	req->rq_xtime = ktime_get();
 	status = xs_sendpages(transport->sock, xs_addr(xprt), xprt->addrlen,
 			      xdr, 0, true, &sent);
-- 
2.17.1
