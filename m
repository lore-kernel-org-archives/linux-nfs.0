Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36037 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727024AbeIEBdW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:22 -0400
Received: by mail-io0-f173.google.com with SMTP id q5-v6so4239158iop.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:30 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.29
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:29 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 25/34] SUNRPC: Support for congestion control when queuing is enabled
Date: Tue,  4 Sep 2018 17:05:40 -0400
Message-Id: <20180904210549.81673-26-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-25-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
 <20180904210549.81673-10-trond.myklebust@hammerspace.com>
 <20180904210549.81673-11-trond.myklebust@hammerspace.com>
 <20180904210549.81673-12-trond.myklebust@hammerspace.com>
 <20180904210549.81673-13-trond.myklebust@hammerspace.com>
 <20180904210549.81673-14-trond.myklebust@hammerspace.com>
 <20180904210549.81673-15-trond.myklebust@hammerspace.com>
 <20180904210549.81673-16-trond.myklebust@hammerspace.com>
 <20180904210549.81673-17-trond.myklebust@hammerspace.com>
 <20180904210549.81673-18-trond.myklebust@hammerspace.com>
 <20180904210549.81673-19-trond.myklebust@hammerspace.com>
 <20180904210549.81673-20-trond.myklebust@hammerspace.com>
 <20180904210549.81673-21-trond.myklebust@hammerspace.com>
 <20180904210549.81673-22-trond.myklebust@hammerspace.com>
 <20180904210549.81673-23-trond.myklebust@hammerspace.com>
 <20180904210549.81673-24-trond.myklebust@hammerspace.com>
 <20180904210549.81673-25-trond.myklebust@hammerspace.com>
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
 include/linux/sunrpc/xprt.h       |  1 +
 net/sunrpc/clnt.c                 |  5 +++
 net/sunrpc/xprt.c                 | 70 ++++++++++++++++++-------------
 net/sunrpc/xprtrdma/backchannel.c |  3 ++
 net/sunrpc/xprtrdma/transport.c   |  3 ++
 net/sunrpc/xprtsock.c             |  4 ++
 6 files changed, 57 insertions(+), 29 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 6d91acfe0644..b23c757bebfc 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -395,6 +395,7 @@ void			xprt_complete_rqst(struct rpc_task *task, int copied);
 void			xprt_pin_rqst(struct rpc_rqst *req);
 void			xprt_unpin_rqst(struct rpc_rqst *req);
 void			xprt_release_rqst_cong(struct rpc_task *task);
+bool			xprt_request_get_cong(struct rpc_xprt *xprt, struct rpc_rqst *req);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 00384bde593e..52494baca7bc 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2003,6 +2003,11 @@ call_transmit_status(struct rpc_task *task)
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
 		task->tk_action = call_encode;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e2f5b4668a66..a7a93d61567f 100644
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
@@ -228,6 +226,7 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
  * Same as xprt_reserve_xprt, but Van Jacobson congestion control is
  * integrated into the decision of whether a request is allowed to be
  * woken up and given access to the transport.
+ * Note that the lock is only granted if we know there are free slots.
  */
 int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 {
@@ -243,14 +242,12 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 		xprt->snd_task = task;
 		return 1;
 	}
-	if (__xprt_get_cong(xprt, task)) {
+	if (!RPCXPRT_CONGESTED(xprt)) {
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
@@ -294,24 +291,6 @@ static void __xprt_lock_write_next(struct rpc_xprt *xprt)
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
@@ -319,7 +298,7 @@ static void __xprt_lock_write_next_cong(struct rpc_xprt *xprt)
 	if (RPCXPRT_CONGESTED(xprt))
 		goto out_unlock;
 	if (rpc_wake_up_first_on_wq(xprtiod_workqueue, &xprt->sending,
-				__xprt_lock_write_cong_func, xprt))
+				__xprt_lock_write_func, xprt))
 		return;
 out_unlock:
 	xprt_clear_locked(xprt);
@@ -370,14 +349,12 @@ static inline void xprt_release_write(struct rpc_xprt *xprt, struct rpc_task *ta
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
+			req->rq_task->tk_pid, xprt->cong, xprt->cwnd);
 	if (RPCXPRT_CONGESTED(xprt))
 		return 0;
 	req->rq_cong = 1;
@@ -399,6 +376,25 @@ __xprt_put_cong(struct rpc_xprt *xprt, struct rpc_rqst *req)
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
@@ -1050,8 +1046,24 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 
 	spin_lock(&xprt->queue_lock);
 	if (list_empty(&req->rq_xmit) && xprt_request_need_transmit(task) &&
-	    test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+	    test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
+		/*
+		 * Requests that carry congestion control credits are added
+		 * to the head of the list to avoid starvation issues.
+		 */
+		if (req->rq_cong) {
+			struct rpc_rqst *pos;
+			list_for_each_entry(pos, &xprt->xmit_queue, rq_xmit) {
+				if (pos->rq_cong)
+					continue;
+				/* Note: req is added _before_ pos */
+				list_add_tail(&req->rq_xmit, &pos->rq_xmit);
+				goto out;
+			}
+		}
 		list_add_tail(&req->rq_xmit, &xprt->xmit_queue);
+	}
+out:
 	spin_unlock(&xprt->queue_lock);
 }
 
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index fc01fdabbbce..14fc4596075e 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -202,6 +202,9 @@ int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
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
