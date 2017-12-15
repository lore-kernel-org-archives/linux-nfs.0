Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:38653 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754609AbdLOB5d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:57:33 -0500
Subject: [PATCH v1 12/16] xprtrdma: Split xprt_rdma_send_request
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:57:31 -0500
Message-ID: <20171215015731.13776.31961.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. @rqst is set up differently for backchannel Replies. For
example, rqst->rq_task and task->tk_client are both NULL. So it is
easier to understand and maintain this code path if it is separated.

Also, we can get rid of the confusing rl_connect_cookie hack in
rpcrdma_bc_receive_call.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   48 +++++++++++++++++++++++++++++--------
 net/sunrpc/xprtrdma/rpc_rdma.c    |    5 ----
 net/sunrpc/xprtrdma/transport.c   |   27 ++++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    2 +-
 4 files changed, 50 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 11fb38f..6c66a4f 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -187,13 +187,7 @@ size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *xprt)
 	return maxmsg - RPCRDMA_HDRLEN_MIN;
 }
 
-/**
- * rpcrdma_bc_marshal_reply - Send backwards direction reply
- * @rqst: buffer containing RPC reply data
- *
- * Returns zero on success.
- */
-int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
+static int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
@@ -221,6 +215,43 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 }
 
 /**
+ * xprt_rdma_bc_send_reply - marshal and send a backchannel reply
+ * @rqst: RPC rqst with a backchannel RPC reply in rq_snd_buf
+ *
+ * Caller holds the transport's write lock.
+ *
+ * Returns:
+ *	%0 if the RPC message has been sent
+ *	%-ENOTCONN if the caller should reconnect and call again
+ *	%-EIO if a permanent error occurred and the request was not
+ *		sent. Do not try to send this message again.
+ */
+int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
+{
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
+	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
+	int rc;
+
+	if (!xprt_connected(rqst->rq_xprt))
+		goto drop_connection;
+
+	rc = rpcrdma_bc_marshal_reply(rqst);
+	if (rc < 0)
+		goto failed_marshal;
+
+	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req))
+		goto drop_connection;
+	return 0;
+
+failed_marshal:
+	if (rc != -ENOTCONN)
+		return rc;
+drop_connection:
+	xprt_disconnect_done(rqst->rq_xprt);
+	return -ENOTCONN;
+}
+
+/**
  * xprt_rdma_bc_destroy - Release resources for handling backchannel requests
  * @xprt: transport associated with these backchannel resources
  * @reqs: number of incoming requests to destroy; ignored
@@ -330,9 +361,6 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 		__func__, rep, req);
 	req->rl_reply = rep;
 
-	/* Defeat the retransmit detection logic in send_request */
-	req->rl_connect_cookie = 0;
-
 	/* Queue rqst for ULP's callback service */
 	bc_serv = xprt->bc_serv;
 	spin_lock(&bc_serv->sv_cb_lock);
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index dd7c0aa..9207aea 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -754,11 +754,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	__be32 *p;
 	int ret;
 
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-	if (test_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state))
-		return rpcrdma_bc_marshal_reply(rqst);
-#endif
-
 	rpcrdma_set_xdrlen(&req->rl_hdrbuf, 0);
 	xdr_init_encode(xdr, &req->rl_hdrbuf,
 			req->rl_rdmabuf->rg_base);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d0cd6d4..be8c4e6 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -699,22 +699,12 @@
  *
  * Caller holds the transport's write lock.
  *
- * Return values:
- *        0:	The request has been sent
- * ENOTCONN:	Caller needs to invoke connect logic then call again
- *  ENOBUFS:	Call again later to send the request
- *      EIO:	A permanent error occurred. The request was not sent,
- *		and don't try it again
- *
- * send_request invokes the meat of RPC RDMA. It must do the following:
- *
- *  1.  Marshal the RPC request into an RPC RDMA request, which means
- *	putting a header in front of data, and creating IOVs for RDMA
- *	from those in the request.
- *  2.  In marshaling, detect opportunities for RDMA, and use them.
- *  3.  Post a recv message to set up asynch completion, then send
- *	the request (rpcrdma_ep_post).
- *  4.  No partial sends are possible in the RPC-RDMA protocol (as in UDP).
+ * Returns:
+ *	%0 if the RPC message has been sent
+ *	%-ENOTCONN if the caller should reconnect and call again
+ *	%-ENOBUFS if the caller should call again later
+ *	%-EIO if a permanent error occurred and the request was not
+ *		sent. Do not try to send this message again.
  */
 static int
 xprt_rdma_send_request(struct rpc_task *task)
@@ -725,6 +715,11 @@
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	int rc = 0;
 
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+	if (unlikely(!rqst->rq_buffer))
+		return xprt_rdma_bc_send_reply(rqst);
+#endif	/* CONFIG_SUNRPC_BACKCHANNEL */
+
 	if (!xprt_connected(xprt))
 		goto drop_connection;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index ed7e513..e084130 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -666,7 +666,7 @@ static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *);
 int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
 void rpcrdma_bc_receive_call(struct rpcrdma_xprt *, struct rpcrdma_rep *);
-int rpcrdma_bc_marshal_reply(struct rpc_rqst *);
+int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst);
 void xprt_rdma_bc_free_rqst(struct rpc_rqst *);
 void xprt_rdma_bc_destroy(struct rpc_xprt *, unsigned int);
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */

