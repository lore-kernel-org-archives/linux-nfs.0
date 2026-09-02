Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C58A3921C0;
	Wed,  2 Sep 2026 19:29:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377361; cv=none; b=qQ0qPCNlzlVrF2o4Lu3IaIj/dMtZK0oFLFL7dcX/eyscCea3BsWAvjYq0U6K8gKtlHRK8FvTkRrZDCzOHjb+XEqjqVuvGXGSHCkvqdyvSJWKJJEoxJ7vASHbvwL+FjsC5lGZ5oXWtBr5ln0zLeuY0+s17RWmZqozXi67hV+WujY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377361; c=relaxed/simple;
	bh=kcw7JM5jtqpHMeCt4LZb3tnxTxZ899QMpy4Qy7hECnI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gTyYzxUU014uu8F98c199e/YX45hzeoqjQozfKApypZ91iNCIrI7peg0ckvqMsdV83T+KEXZ+5pxbKTZu5PyC9L+D4FM43KSRwjVPSTClWsfYiipAVgm4Fv/OB80iKVdNW/cgmXShYDK82isRRhAcEZrxponi16f2997jq98hlM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NAJTnxzh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NAJTnxzh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7E97A1F00A3A;
	Wed,  2 Sep 2026 19:29:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377347;
	bh=+eYTodiaUqlicVvz2NVCtjLK1G4eOJJQEJOrtPVpfso=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NAJTnxzhn6EQL2a90E2Av0JOJ7g+u/XvmW+LcPTkuyLyOpj+uOf1paQKGeuMyLfrW
	 LbUTDr9dgltyEAvfc8U+cySAQhntqiuxZBcu2fAskozmaxFHTlCh+G7fULqooxscZN
	 HNYvNjvpzWQPt4x/8amF9YrXViwezRQTmx+ugvT+bhVh7WDMLA06fmdgHGLOTh9U2p
	 +IYcDD2rJ0v4cBOTiYJp6sTn3J0hKEmhEfLxCjeQgnJbgakRd/oXyyBONzj/9ByxPH
	 vMkdnap6SXkUV/2khI3FZP3IjVFikzFdzjQMiqESsa0dDYskUZhACZG1AW91adCIOy
	 Qm3IqdKnhhdMg==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 02 Sep 2026 15:28:47 -0400
Subject: [PATCH RFC v2 2/8] SUNRPC: Split recv_lock out of xprt->queue_lock
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-performance-v2-2-b71c0c082f9d@kernel.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
In-Reply-To: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=15822; i=cel@kernel.org;
 h=from:subject:message-id; bh=kcw7JM5jtqpHMeCt4LZb3tnxTxZ899QMpy4Qy7hECnI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHkAlVFUPH0B6+sOQfT9XEWu71on3M96lhWgk
 JFSpoeUZeyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph5AAAKCRAzarMzb2Z/
 l7UXEAC6rB2BhRChU2fcMFdWDF6h1baCtd8VuGUK/nmNAiIkuMOJggVQXmSRVaIkRWsE5M/yRR3
 JUqfbaEQoMjeauQx82y4uAIB4XpZha6IiFhPOIRS8fGpq4Nq2ZOCMLOAbtc3z6DxlJmqZ2T2XIA
 8L9um5BieevuiL1jWWt+JoZhypsjmnsncNXpRz3HLyVJnPq2heglO3+lIzV86eEo3vzTSiNmxbR
 NLg++6eHjT3f0UqRf81yLTw7TYXikeF4jKYhNqJhBc0d2wpwdtuk01Fl6mQ7A3Nqk1eedS6RzFN
 HoCedUdElyWjhZIJuNxAl8/HFUmmdRg/Z6BwPZbqjiRgrFFnTgXKNne+LBpuPXeYtl+Jnzpbwx8
 rgnkT2SRb9m1t0EGgtW1tk245BLbOUEwOCq3VwzU11nrVSp+ga9KEpzln3rNQjxFlaBpytjEHt0
 XQfpaBX3medLRykHdng0HiY2HfjI0iXMDxX0mb9ACzytFMYivfOijhN8+98De3GWZcid5riZ4vG
 Fdn2fO9dR1iyIrZJzy9SqQLOWrfCMvkKV9Wrw8DAI0+luCCRC2KzJHzK1CkVSiAmFSnC9vnFllT
 ZlzqQKj6toWA5aGcBtNDI9TLBQ4ZXUwmjdvKENOhftWGN3gW+2fp9L+RbZBk3XiDmxGOhpK3but
 GvzXFIHlFO0fXwQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

xprt->queue_lock protects two independent structures: the recv_queue
rb-tree for reply matching and the xmit_queue list for transmit
draining. No hot path touches both in one critical section, yet every
RPC submit and completion contends on the same lock. Under a 4KB
NFSv3 READ workload on 100GbE RDMA, 53% of non-idle CPU cycles are
spent in native_queued_spin_lock_slowpath: the CQ completion worker
running rpcrdma_reply_handler serializes against ~150 kworker threads
enqueuing receives and transmits.

Introduce xprt->recv_lock for the receive path -- recv_queue
operations, request lookup, receive-side pinning, and completion --
leaving queue_lock to the xmit_queue and the xprt_transmit drain
loop.

A request is pinned under the lock of the queue it was found through,
so xprt_request_dequeue_xprt() drains pins once under each lock
before it dequeues from that queue. The transmit dequeue has to see a
zero pin count under queue_lock: it frees the send buffer's bvec that
a transmitter is iterating, and it aborts a partial send only if the
request is still first in the queue. A receive-side unpin runs under
recv_lock rather than the lock that publishes RPC_TASK_MSG_PIN_WAIT,
so xprt_unpin_rqst() wakes the waiter whenever the count reaches
zero instead of testing the flag.

Also move the rq_private_buf memcpy in xprt_request_enqueue_receive
above the lock acquisition: until the rb-tree insert publishes the
request, the reply handler cannot see it, so the copy is safe
unlocked and the submitter's critical section shrinks to the insert
alone.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xprt.h                |  6 ++-
 net/sunrpc/svcsock.c                       |  6 +--
 net/sunrpc/xprt.c                          | 76 +++++++++++++++++++-----------
 net/sunrpc/xprtrdma/rpc_rdma.c             | 14 +++---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  8 ++--
 net/sunrpc/xprtsock.c                      | 18 +++----
 6 files changed, 77 insertions(+), 51 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 0d6c3f6bf97e..ed1e28b74f02 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -272,7 +272,7 @@ struct rpc_xprt {
 	atomic_long_t		queuelen;
 	spinlock_t		transport_lock;	/* lock transport info */
 	spinlock_t		reserve_lock;	/* lock slot table */
-	spinlock_t		queue_lock;	/* send/receive queue lock */
+	spinlock_t		queue_lock;	/* send queue lock */
 	atomic_t		xid;		/* Most recently issued XID */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
 
@@ -292,6 +292,10 @@ struct rpc_xprt {
 						 * backchannel rpc_rqst's */
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
+	/*
+	 * Receive stuff
+	 */
+	spinlock_t		recv_lock;	/* receive queue lock */
 	struct rb_root		recv_queue;	/* Receive queue */
 
 	struct {
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 50e5e7f5b762..8939ba604385 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1102,7 +1102,7 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 
 	if (!bc_xprt)
 		return -EAGAIN;
-	spin_lock(&bc_xprt->queue_lock);
+	spin_lock(&bc_xprt->recv_lock);
 	req = xprt_lookup_rqst(bc_xprt, xid);
 	if (!req)
 		goto unlock_eagain;
@@ -1120,10 +1120,10 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	memcpy(dst->iov_base, src->iov_base, src->iov_len);
 	xprt_complete_rqst(req->rq_task, rqstp->rq_arg.len);
 	rqstp->rq_arg.len = 0;
-	spin_unlock(&bc_xprt->queue_lock);
+	spin_unlock(&bc_xprt->recv_lock);
 	return 0;
 unlock_eagain:
-	spin_unlock(&bc_xprt->queue_lock);
+	spin_unlock(&bc_xprt->recv_lock);
 	return -EAGAIN;
 }
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 186c14f0f928..883123ec70b0 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1061,7 +1061,7 @@ xprt_request_rb_remove(struct rpc_xprt *xprt, struct rpc_rqst *req)
  * @xprt: transport on which the original request was transmitted
  * @xid: RPC XID of incoming reply
  *
- * Caller holds xprt->queue_lock.
+ * Caller holds xprt->recv_lock.
  */
 struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 {
@@ -1092,8 +1092,9 @@ xprt_is_pinned_rqst(struct rpc_rqst *req)
  * xprt_pin_rqst - Pin a request on the transport receive list
  * @req: Request to pin
  *
- * Caller must ensure this is atomic with the call to xprt_lookup_rqst()
- * so should be holding xprt->queue_lock.
+ * Caller must hold the lock that protects the queue through which
+ * it found the request: xprt->recv_lock for the receive path,
+ * xprt->queue_lock for the transmit drain path.
  */
 void xprt_pin_rqst(struct rpc_rqst *req)
 {
@@ -1105,14 +1106,10 @@ EXPORT_SYMBOL_GPL(xprt_pin_rqst);
  * xprt_unpin_rqst - Unpin a request on the transport receive list
  * @req: Request to pin
  *
- * Caller should be holding xprt->queue_lock.
+ * Caller holds the lock it held for the matching xprt_pin_rqst().
  */
 void xprt_unpin_rqst(struct rpc_rqst *req)
 {
-	if (!test_bit(RPC_TASK_MSG_PIN_WAIT, &req->rq_task->tk_runstate)) {
-		atomic_dec(&req->rq_pin);
-		return;
-	}
 	if (atomic_dec_and_test(&req->rq_pin))
 		wake_up_var(&req->rq_pin);
 }
@@ -1123,6 +1120,26 @@ static void xprt_wait_on_pinned_rqst(struct rpc_rqst *req)
 	wait_var_event(&req->rq_pin, !xprt_is_pinned_rqst(req));
 }
 
+/*
+ * A pin is taken under the lock of the queue the request was found
+ * through, so a zero count observed under @lock rules out any pinner
+ * that came through that queue. The lock is dropped to wait, and the
+ * re-test under it catches a pinner that arrived in the gap.
+ */
+static void xprt_request_drain_pins(struct rpc_task *task, spinlock_t *lock)
+	__must_hold(lock)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+
+	while (xprt_is_pinned_rqst(req)) {
+		set_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
+		spin_unlock(lock);
+		xprt_wait_on_pinned_rqst(req);
+		spin_lock(lock);
+		clear_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
+	}
+}
+
 static bool
 xprt_request_data_received(struct rpc_task *task)
 {
@@ -1155,16 +1172,16 @@ xprt_request_enqueue_receive(struct rpc_task *task)
 	ret = xprt_request_prepare(task->tk_rqstp, &req->rq_rcv_buf);
 	if (ret)
 		return ret;
-	spin_lock(&xprt->queue_lock);
-
-	/* Update the softirq receive buffer */
+	/* Reply handlers cannot find the request until the rb-tree
+	 * insert below publishes it, so the copy needs no lock.
+	 */
 	memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
 			sizeof(req->rq_private_buf));
 
-	/* Add request to the receive list */
+	spin_lock(&xprt->recv_lock);
 	xprt_request_rb_insert(xprt, req);
 	set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 
 	/* Turn off autodisconnect */
 	timer_delete_sync(&xprt->timer);
@@ -1175,7 +1192,7 @@ xprt_request_enqueue_receive(struct rpc_task *task)
  * xprt_request_dequeue_receive_locked - Remove a request from the receive queue
  * @task: RPC task
  *
- * Caller must hold xprt->queue_lock.
+ * Caller must hold xprt->recv_lock.
  */
 static void
 xprt_request_dequeue_receive_locked(struct rpc_task *task)
@@ -1190,7 +1207,7 @@ xprt_request_dequeue_receive_locked(struct rpc_task *task)
  * xprt_update_rtt - Update RPC RTT statistics
  * @task: RPC request that recently completed
  *
- * Caller holds xprt->queue_lock.
+ * Caller holds xprt->recv_lock.
  */
 void xprt_update_rtt(struct rpc_task *task)
 {
@@ -1212,7 +1229,7 @@ EXPORT_SYMBOL_GPL(xprt_update_rtt);
  * @task: RPC request that recently completed
  * @copied: actual number of bytes received from the transport
  *
- * Caller holds xprt->queue_lock.
+ * Caller holds xprt->recv_lock.
  */
 void xprt_complete_rqst(struct rpc_task *task, int copied)
 {
@@ -1309,7 +1326,7 @@ void xprt_request_wait_receive(struct rpc_task *task)
 	 * The spinlock ensures atomicity between the test of
 	 * req->rq_reply_bytes_recvd, and the call to rpc_sleep_on().
 	 */
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
 		xprt->ops->wait_for_reply_request(task);
 		/*
@@ -1321,7 +1338,7 @@ void xprt_request_wait_receive(struct rpc_task *task)
 			rpc_wake_up_queued_task_set_status(&xprt->pending,
 					task, -ENOTCONN);
 	}
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 }
 
 static bool
@@ -1439,7 +1456,12 @@ xprt_request_dequeue_transmit(struct rpc_task *task)
  * @task: pointer to rpc_task
  *
  * Remove a task from the transmit and receive queues, and ensure that
- * it is not pinned by the receive work item.
+ * it is not pinned by any concurrent work item.
+ *
+ * The transmit dequeue frees the send buffer's bvec and may abort a
+ * partial send, so it must not run while a transmitter holds a pin.
+ * Drain pins under each queue's lock before leaving that queue; once
+ * the request is off both, no new pin can be taken.
  */
 void
 xprt_request_dequeue_xprt(struct rpc_task *task)
@@ -1451,16 +1473,15 @@ xprt_request_dequeue_xprt(struct rpc_task *task)
 	    test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) ||
 	    xprt_is_pinned_rqst(req)) {
 		spin_lock(&xprt->queue_lock);
-		while (xprt_is_pinned_rqst(req)) {
-			set_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
-			spin_unlock(&xprt->queue_lock);
-			xprt_wait_on_pinned_rqst(req);
-			spin_lock(&xprt->queue_lock);
-			clear_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
-		}
+		xprt_request_drain_pins(task, &xprt->queue_lock);
 		xprt_request_dequeue_transmit_locked(task);
-		xprt_request_dequeue_receive_locked(task);
 		spin_unlock(&xprt->queue_lock);
+
+		spin_lock(&xprt->recv_lock);
+		xprt_request_drain_pins(task, &xprt->recv_lock);
+		xprt_request_dequeue_receive_locked(task);
+		spin_unlock(&xprt->recv_lock);
+
 		xdr_free_bvec(&req->rq_rcv_buf);
 	}
 }
@@ -2038,6 +2059,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 	spin_lock_init(&xprt->transport_lock);
 	spin_lock_init(&xprt->reserve_lock);
 	spin_lock_init(&xprt->queue_lock);
+	spin_lock_init(&xprt->recv_lock);
 
 	INIT_LIST_HEAD(&xprt->free);
 	xprt->recv_queue = RB_ROOT;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 1285f04cdac1..a82d3d9bc7ae 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1321,9 +1321,9 @@ void rpcrdma_unpin_rqst(struct rpcrdma_rep *rep)
 	req->rl_reply = NULL;
 	rep->rr_rqst = NULL;
 
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	xprt_unpin_rqst(rqst);
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 }
 
 /**
@@ -1363,10 +1363,10 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 		goto out_badheader;
 
 out:
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	xprt_complete_rqst(rqst->rq_task, status);
 	xprt_unpin_rqst(rqst);
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 	return;
 
 out_badheader:
@@ -1492,12 +1492,12 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	/* Match incoming rpcrdma_rep to an rpcrdma_req to
 	 * get context for handling any incoming chunks.
 	 */
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	rqst = xprt_lookup_rqst(xprt, rep->rr_xid);
 	if (!rqst)
 		goto out_norqst;
 	xprt_pin_rqst(rqst);
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 
 	if (buf->rb_credits != credits)
 		rpcrdma_update_cwnd(r_xprt, credits);
@@ -1524,7 +1524,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	return;
 
 out_norqst:
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 	trace_xprtrdma_reply_rqst_err(rep);
 	rpcrdma_rep_put(buf, rep);
 	goto out_post;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index e5a78b761012..3c7b85427f33 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -28,7 +28,7 @@ void svc_rdma_handle_bc_reply(struct svc_rqst *rqstp,
 	struct rpc_rqst *req;
 	u32 credits;
 
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	req = xprt_lookup_rqst(xprt, *rdma_resp);
 	if (!req)
 		goto out_unlock;
@@ -39,7 +39,7 @@ void svc_rdma_handle_bc_reply(struct svc_rqst *rqstp,
 		goto out_unlock;
 	memcpy(dst->iov_base, src->iov_base, src->iov_len);
 	xprt_pin_rqst(req);
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 
 	credits = be32_to_cpup(rdma_resp + 2);
 	if (credits == 0)
@@ -50,13 +50,13 @@ void svc_rdma_handle_bc_reply(struct svc_rqst *rqstp,
 	xprt->cwnd = credits << RPC_CWNDSHIFT;
 	spin_unlock(&xprt->transport_lock);
 
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	xprt_complete_rqst(req->rq_task, rcvbuf->len);
 	xprt_unpin_rqst(req);
 	rcvbuf->len = 0;
 
 out_unlock:
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 }
 
 /* Send a reverse-direction RPC Call.
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7f60723fa64d..1454da9575b3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -673,25 +673,25 @@ xs_read_stream_reply(struct sock_xprt *transport, struct msghdr *msg, int flags)
 	ssize_t ret = 0;
 
 	/* Look up and lock the request corresponding to the given XID */
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	req = xprt_lookup_rqst(xprt, transport->recv.xid);
 	if (!req || (transport->recv.copied && !req->rq_private_buf.len)) {
 		msg->msg_flags |= MSG_TRUNC;
 		goto out;
 	}
 	xprt_pin_rqst(req);
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 
 	ret = xs_read_stream_request(transport, msg, flags, req);
 
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	if (msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 		xprt_complete_rqst(req->rq_task, transport->recv.copied);
 	else
 		req->rq_private_buf.len = transport->recv.copied;
 	xprt_unpin_rqst(req);
 out:
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 	return ret;
 }
 
@@ -1398,13 +1398,13 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 		return;
 
 	/* Look up and lock the request corresponding to the given XID */
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	rovr = xprt_lookup_rqst(xprt, *xp);
 	if (!rovr)
 		goto out_unlock;
 	xprt_pin_rqst(rovr);
 	xprt_update_rtt(rovr->rq_task);
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 	task = rovr->rq_task;
 
 	if ((copied = rovr->rq_private_buf.buflen) > repsize)
@@ -1412,7 +1412,7 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 
 	/* Suck it into the iovec, verify checksum if not done by hw. */
 	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
-		spin_lock(&xprt->queue_lock);
+		spin_lock(&xprt->recv_lock);
 		__UDPX_INC_STATS(sk, UDP_MIB_INERRORS);
 		goto out_unpin;
 	}
@@ -1421,13 +1421,13 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 	spin_lock(&xprt->transport_lock);
 	xprt_adjust_cwnd(xprt, task, copied);
 	spin_unlock(&xprt->transport_lock);
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	xprt_complete_rqst(task, copied);
 	__UDPX_INC_STATS(sk, UDP_MIB_INDATAGRAMS);
 out_unpin:
 	xprt_unpin_rqst(rovr);
  out_unlock:
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 }
 
 static void xs_udp_data_receive(struct sock_xprt *transport)

-- 
2.55.0

