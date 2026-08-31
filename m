Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21E8F4A3F13;
	Mon, 31 Aug 2026 18:22:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200532; cv=none; b=ELmsQ1L+pgTqzbCEN6yHqKIL7om86nm68GHbsnBqUyMbstJUhJM2B+iloQPBaNKFHK3nWCPFOLIt7bjFBhSmHjZ30kAHgO+6SUDWWEOXoltWnnW4z3nNR3FfgQIIn+y4peHwwPikSev/82oWCsT1NhcSLT1uiuzRmiqNlJ0A/fs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200532; c=relaxed/simple;
	bh=vVF+1nLfEsYCYEe7bJXvQYnkeffWIDla56CaCSEaT38=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=IFtUUcB1I8ssxmwESn37FHVxiaw6JTI2MPiN5XUrNWY05uHXPcWz+hg7L+dk7xQ9A5CS66liPvTzuQPsN24IINoKTngNcj2c0cblO+u29ylAwvjwCp50tfhoZ0FT2HfDClGtSdnIURgtULa2ibWRORHjTHIYZqlzLoyT0W+g1mM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jknZyUO0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jknZyUO0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E0A51F000E9;
	Mon, 31 Aug 2026 18:22:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200530;
	bh=glbK/Pyh1W0SQOn60xP0+QoSWP4AQc/SXX426gdzA+8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jknZyUO0ypQB/AVtXXsD4Db9PVskgRKnP6OPUZNAn+iNspvJI7O6XVi+e5Bt6r4xy
	 FcM0nAymbGUovDlbJLVG/GSXW7BkOF5lo5QkD4k4InGGSZXI5Y7EcTDzKJvRGhQreR
	 sVK7/y8NZSLBZ6l3hU8ghAXt+r7/R9RNdz/l4eBE1inNJaqRnLw7wD2NwDol0ehfJ5
	 0dEgAgH1f13b9MLlU/Y33Z+3aOT+QDGJiayctK2Lib+2fHuZ3O2n7M+VU7RIUDJPsF
	 BJ4UARXbQQQfxEHLj2tkLSDGbhsdTTNdKgPuoxCoBhm3kpg4p00cm7+ZGNRG8pwAqM
	 tXy5ryFih1zFQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 31 Aug 2026 14:21:59 -0400
Subject: [PATCH RFC 3/8] SUNRPC: Split recv_lock out of xprt->queue_lock
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-performance-v1-3-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
In-Reply-To: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=14272; i=cel@kernel.org;
 h=from:subject:message-id; bh=vVF+1nLfEsYCYEe7bJXvQYnkeffWIDla56CaCSEaT38=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZPgPjC1te6pqQ9vWJE3vSbVY8ZL0j/Rr3fe
 yMgGcEdxpmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGTwAKCRAzarMzb2Z/
 l9CGEACzdUlO41//NKheRpD7LlfD8KDYFEYMP7NrLXkssTFdaMDUhiKapMp9rGiQSyMURYVTV0T
 Tq9qqQH3sVGOes3Tzl0zZehdv1JFaM23S9YDPGBdBlmH4T0ZFIBkIyrDkP34X8MWiLB1RUa5TH2
 FFtoOLHP6+6K7YLxoyEWikQ12uD86RwcVKzQwsXEmhY+Jp/RAATDupVkJNVL6pVKielDsL6pXRZ
 QyeFPpPBaKL0gw2u8119Es0a54/ypo72cCPCcA9EESQoInu6a1s+8Jhni/CpfSvCjyjP+WNAzGQ
 655QD5hjxVd890isqiwxwL8RQRdvH3u5iHFUDt0vNv6MfZ+GOBeJvFhfz7s6eZgTiJhFL8svK0V
 IDYlTwA13xxWT9zgTLQlxBm7CZs17W2gZKzwMX6gi+fDaWuyn4wABeK2rc/B/0DU3SZ70LpPLWF
 kMYddtwYDmd7wIv1DsoZHNC7xivHZzBpWLanclU1gADWLI2jrE1tVBYiQm7IlJxvjE+LIr+SSxP
 ki8Vbd5n2De9oKJ4PG0IFqmBc6AONunDX1xlOYM9+oA8qLAqtZMYMdZQGmyaBaC7ak2V0jyMwa1
 oqyapyl/TrJPf2OYVtaU9CLAs97iRlWmzUIW1kaGc/zKD12/98Kcm82L69hZtH4Jn3g1FdJZGYq
 xFvWwRqPIF/nEoA==
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

Also move the rq_private_buf memcpy in xprt_request_enqueue_receive
above the lock acquisition: until the rb-tree insert publishes the
request, the reply handler cannot see it, so the copy is safe
unlocked and the submitter's critical section shrinks to the insert
alone.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/xprt.h                |  6 +++-
 net/sunrpc/svcsock.c                       |  6 ++--
 net/sunrpc/xprt.c                          | 54 ++++++++++++++++--------------
 net/sunrpc/xprtrdma/rpc_rdma.c             | 14 ++++----
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  8 ++---
 net/sunrpc/xprtsock.c                      | 18 +++++-----
 6 files changed, 57 insertions(+), 49 deletions(-)

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
index 186c14f0f928..42c66464d8f3 100644
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
@@ -1155,16 +1152,16 @@ xprt_request_enqueue_receive(struct rpc_task *task)
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
@@ -1175,7 +1172,7 @@ xprt_request_enqueue_receive(struct rpc_task *task)
  * xprt_request_dequeue_receive_locked - Remove a request from the receive queue
  * @task: RPC task
  *
- * Caller must hold xprt->queue_lock.
+ * Caller must hold xprt->recv_lock.
  */
 static void
 xprt_request_dequeue_receive_locked(struct rpc_task *task)
@@ -1190,7 +1187,7 @@ xprt_request_dequeue_receive_locked(struct rpc_task *task)
  * xprt_update_rtt - Update RPC RTT statistics
  * @task: RPC request that recently completed
  *
- * Caller holds xprt->queue_lock.
+ * Caller holds xprt->recv_lock.
  */
 void xprt_update_rtt(struct rpc_task *task)
 {
@@ -1212,7 +1209,7 @@ EXPORT_SYMBOL_GPL(xprt_update_rtt);
  * @task: RPC request that recently completed
  * @copied: actual number of bytes received from the transport
  *
- * Caller holds xprt->queue_lock.
+ * Caller holds xprt->recv_lock.
  */
 void xprt_complete_rqst(struct rpc_task *task, int copied)
 {
@@ -1309,7 +1306,7 @@ void xprt_request_wait_receive(struct rpc_task *task)
 	 * The spinlock ensures atomicity between the test of
 	 * req->rq_reply_bytes_recvd, and the call to rpc_sleep_on().
 	 */
-	spin_lock(&xprt->queue_lock);
+	spin_lock(&xprt->recv_lock);
 	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
 		xprt->ops->wait_for_reply_request(task);
 		/*
@@ -1321,7 +1318,7 @@ void xprt_request_wait_receive(struct rpc_task *task)
 			rpc_wake_up_queued_task_set_status(&xprt->pending,
 					task, -ENOTCONN);
 	}
-	spin_unlock(&xprt->queue_lock);
+	spin_unlock(&xprt->recv_lock);
 }
 
 static bool
@@ -1439,7 +1436,11 @@ xprt_request_dequeue_transmit(struct rpc_task *task)
  * @task: pointer to rpc_task
  *
  * Remove a task from the transmit and receive queues, and ensure that
- * it is not pinned by the receive work item.
+ * it is not pinned by any concurrent work item.
+ *
+ * Dequeuing from both queues prevents new pins: xprt_lookup_rqst
+ * and xprt_transmit can no longer find the request. The wait for
+ * in-flight pins to drain then needs neither lock.
  */
 void
 xprt_request_dequeue_xprt(struct rpc_task *task)
@@ -1451,16 +1452,18 @@ xprt_request_dequeue_xprt(struct rpc_task *task)
 	    test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate) ||
 	    xprt_is_pinned_rqst(req)) {
 		spin_lock(&xprt->queue_lock);
-		while (xprt_is_pinned_rqst(req)) {
+		xprt_request_dequeue_transmit_locked(task);
+		spin_unlock(&xprt->queue_lock);
+
+		spin_lock(&xprt->recv_lock);
+		xprt_request_dequeue_receive_locked(task);
+		spin_unlock(&xprt->recv_lock);
+
+		if (xprt_is_pinned_rqst(req)) {
 			set_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
-			spin_unlock(&xprt->queue_lock);
 			xprt_wait_on_pinned_rqst(req);
-			spin_lock(&xprt->queue_lock);
 			clear_bit(RPC_TASK_MSG_PIN_WAIT, &task->tk_runstate);
 		}
-		xprt_request_dequeue_transmit_locked(task);
-		xprt_request_dequeue_receive_locked(task);
-		spin_unlock(&xprt->queue_lock);
 		xdr_free_bvec(&req->rq_rcv_buf);
 	}
 }
@@ -2038,6 +2041,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
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

