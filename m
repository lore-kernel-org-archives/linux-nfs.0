Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:39879 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728229AbeIQSbi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:38 -0400
Received: by mail-qt0-f196.google.com with SMTP id o15-v6so15128114qtk.6
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:23 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.21
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:21 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 21/44] SUNRPC: Fix up the back channel transmit
Date: Mon, 17 Sep 2018 09:03:12 -0400
Message-Id: <20180917130335.112832-22-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-21-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up the back channel code to recognise that it has already been
transmitted, so does not need to be called again.
Also ensure that we set req->rq_task.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/bc_xprt.h |  1 +
 net/sunrpc/clnt.c              | 19 +++++--------------
 net/sunrpc/xprt.c              | 27 ++++++++++++++++++++++++++-
 3 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index 4397a4824c81..28721cf73ec3 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -34,6 +34,7 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #ifdef CONFIG_SUNRPC_BACKCHANNEL
 struct rpc_rqst *xprt_lookup_bc_request(struct rpc_xprt *xprt, __be32 xid);
 void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied);
+void xprt_init_bc_request(struct rpc_rqst *req, struct rpc_task *task);
 void xprt_free_bc_request(struct rpc_rqst *req);
 int xprt_setup_backchannel(struct rpc_xprt *, unsigned int min_reqs);
 void xprt_destroy_backchannel(struct rpc_xprt *, unsigned int max_reqs);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 64159716be30..dcefbf406482 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1138,7 +1138,6 @@ EXPORT_SYMBOL_GPL(rpc_call_async);
 struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 {
 	struct rpc_task *task;
-	struct xdr_buf *xbufp = &req->rq_snd_buf;
 	struct rpc_task_setup task_setup_data = {
 		.callback_ops = &rpc_default_ops,
 		.flags = RPC_TASK_SOFTCONN |
@@ -1150,14 +1149,7 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	 * Create an rpc_task to send the data
 	 */
 	task = rpc_new_task(&task_setup_data);
-	task->tk_rqstp = req;
-
-	/*
-	 * Set up the xdr_buf length.
-	 * This also indicates that the buffer is XDR encoded already.
-	 */
-	xbufp->len = xbufp->head[0].iov_len + xbufp->page_len +
-			xbufp->tail[0].iov_len;
+	xprt_init_bc_request(req, task);
 
 	task->tk_action = call_bc_transmit;
 	atomic_inc(&task->tk_count);
@@ -2064,6 +2056,8 @@ call_bc_transmit(struct rpc_task *task)
 
 	if (rpc_task_need_encode(task))
 		xprt_request_enqueue_transmit(task);
+	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
+		goto out_wakeup;
 
 	if (!xprt_prepare_transmit(task))
 		goto out_retry;
@@ -2073,13 +2067,11 @@ call_bc_transmit(struct rpc_task *task)
 			"error: %d\n", task->tk_status);
 		goto out_done;
 	}
-	if (req->rq_connect_cookie != req->rq_xprt->connect_cookie)
-		req->rq_bytes_sent = 0;
 
 	xprt_transmit(task);
 
 	if (task->tk_status == -EAGAIN)
-		goto out_nospace;
+		goto out_retry;
 
 	xprt_end_transmit(task);
 	dprint_status(task);
@@ -2119,12 +2111,11 @@ call_bc_transmit(struct rpc_task *task)
 			"error: %d\n", task->tk_status);
 		break;
 	}
+out_wakeup:
 	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
 out_done:
 	task->tk_action = rpc_exit_task;
 	return;
-out_nospace:
-	req->rq_connect_cookie = req->rq_xprt->connect_cookie;
 out_retry:
 	task->tk_status = 0;
 }
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 426a3a05e075..d418bd4db7ff 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1389,6 +1389,12 @@ void xprt_free(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_free);
 
+static void
+xprt_init_connect_cookie(struct rpc_rqst *req, struct rpc_xprt *xprt)
+{
+	req->rq_connect_cookie = xprt_connect_cookie(xprt) - 1;
+}
+
 static __be32
 xprt_alloc_xid(struct rpc_xprt *xprt)
 {
@@ -1417,7 +1423,7 @@ xprt_request_init(struct rpc_task *task)
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
 	req->rq_xid	= xprt_alloc_xid(xprt);
-	req->rq_connect_cookie = xprt_connect_cookie(xprt) - 1;
+	xprt_init_connect_cookie(req, xprt);
 	req->rq_bytes_sent = 0;
 	req->rq_snd_buf.len = 0;
 	req->rq_snd_buf.buflen = 0;
@@ -1551,6 +1557,25 @@ void xprt_release(struct rpc_task *task)
 		xprt_free_bc_request(req);
 }
 
+#ifdef CONFIG_SUNRPC_BACKCHANNEL
+void
+xprt_init_bc_request(struct rpc_rqst *req, struct rpc_task *task)
+{
+	struct xdr_buf *xbufp = &req->rq_snd_buf;
+
+	task->tk_rqstp = req;
+	req->rq_task = task;
+	xprt_init_connect_cookie(req, req->rq_xprt);
+	/*
+	 * Set up the xdr_buf length.
+	 * This also indicates that the buffer is XDR encoded already.
+	 */
+	xbufp->len = xbufp->head[0].iov_len + xbufp->page_len +
+		xbufp->tail[0].iov_len;
+	req->rq_bytes_sent = 0;
+}
+#endif
+
 static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 {
 	kref_init(&xprt->kref);
-- 
2.17.1
