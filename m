Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:54856 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751844AbdJTOsa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2017 10:48:30 -0400
Subject: [PATCH 7/9] xprtrdma: Refactor rpcrdma_deferred_completion
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 20 Oct 2017 10:48:28 -0400
Message-ID: <20171020144828.14869.81727.stgit@manet.1015granger.net>
In-Reply-To: <20171020143635.14869.15714.stgit@manet.1015granger.net>
References: <20171020143635.14869.15714.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Invoke a common routine for releasing hardware resources (for
example, invalidating MRs). This needs to be done whether an
RPC Reply has arrived or the RPC was terminated early.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   26 ++++++++++++++++----------
 net/sunrpc/xprtrdma/transport.c |    6 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    3 +++
 3 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9951c81..853dede 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1293,6 +1293,20 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 	goto out;
 }
 
+void rpcrdma_release_rqst(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
+{
+	/* Invalidate and unmap the data payloads before waking
+	 * the waiting application. This guarantees the memory
+	 * regions are properly fenced from the server before the
+	 * application accesses the data. It also ensures proper
+	 * send flow control: waking the next RPC waits until this
+	 * RPC has relinquished all its Send Queue entries.
+	 */
+	if (!list_empty(&req->rl_registered))
+		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt,
+						    &req->rl_registered);
+}
+
 /* Reply handling runs in the poll worker thread. Anything that
  * might wait is deferred to a separate workqueue.
  */
@@ -1301,18 +1315,9 @@ void rpcrdma_deferred_completion(struct work_struct *work)
 	struct rpcrdma_rep *rep =
 			container_of(work, struct rpcrdma_rep, rr_work);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rep->rr_rqst);
-	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 
-	/* Invalidate and unmap the data payloads before waking
-	 * the waiting application. This guarantees the memory
-	 * regions are properly fenced from the server before the
-	 * application accesses the data. It also ensures proper
-	 * send flow control: waking the next RPC waits until this
-	 * RPC has relinquished all its Send Queue entries.
-	 */
 	rpcrdma_mark_remote_invalidation(&req->rl_registered, rep);
-	r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt, &req->rl_registered);
-
+	rpcrdma_release_rqst(rep->rr_rxprt, req);
 	rpcrdma_complete_rqst(rep);
 }
 
@@ -1374,6 +1379,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	req = rpcr_to_rdmar(rqst);
 	req->rl_reply = rep;
 	rep->rr_rqst = rqst;
+	clear_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
 
 	dprintk("RPC:       %s: reply %p completes request %p (xid 0x%08x)\n",
 		__func__, rep, req, be32_to_cpu(rep->rr_xid));
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 74f3cef..0c73439 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -678,15 +678,14 @@
 	struct rpc_rqst *rqst = task->tk_rqstp;
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
 	if (test_bit(RPCRDMA_REQ_F_BACKCHANNEL, &req->rl_flags))
 		return;
 
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
-	if (!list_empty(&req->rl_registered))
-		ia->ri_ops->ro_unmap_sync(r_xprt, &req->rl_registered);
+	if (test_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags))
+		rpcrdma_release_rqst(r_xprt, req);
 	rpcrdma_buffer_put(req);
 }
 
@@ -745,6 +744,7 @@
 		goto drop_connection;
 	req->rl_connect_cookie = xprt->connect_cookie;
 
+	set_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req))
 		goto drop_connection;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4175320..c260475 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -386,6 +386,7 @@ struct rpcrdma_req {
 /* rl_flags */
 enum {
 	RPCRDMA_REQ_F_BACKCHANNEL = 0,
+	RPCRDMA_REQ_F_PENDING,
 };
 
 static inline void
@@ -655,6 +656,8 @@ int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 void rpcrdma_complete_rqst(struct rpcrdma_rep *rep);
 void rpcrdma_reply_handler(struct rpcrdma_rep *rep);
+void rpcrdma_release_rqst(struct rpcrdma_xprt *r_xprt,
+			  struct rpcrdma_req *req);
 void rpcrdma_deferred_completion(struct work_struct *work);
 
 static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)

