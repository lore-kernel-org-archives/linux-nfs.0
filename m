Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33256 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755045AbcK2Pxj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 10:53:39 -0500
Subject: [PATCH v3 12/12] xprtrdma: Relocate connection helper functions
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 10:53:37 -0500
Message-ID: <20161129155337.23061.55308.stgit@manet.1015granger.net>
In-Reply-To: <20161129154845.23061.29385.stgit@manet.1015granger.net>
References: <20161129154845.23061.29385.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Disentangle connection helpers from RPC-over-RDMA reply
decoding functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   34 ----------------------------------
 net/sunrpc/xprtrdma/transport.c |   28 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |   10 +++-------
 3 files changed, 31 insertions(+), 41 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 01f5cbc..c52e0f2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -906,28 +906,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return fixup_copy_count;
 }
 
-void
-rpcrdma_connect_worker(struct work_struct *work)
-{
-	struct rpcrdma_ep *ep =
-		container_of(work, struct rpcrdma_ep, rep_connect_worker.work);
-	struct rpcrdma_xprt *r_xprt =
-		container_of(ep, struct rpcrdma_xprt, rx_ep);
-	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
-
-	spin_lock_bh(&xprt->transport_lock);
-	if (++xprt->connect_cookie == 0)	/* maintain a reserved value */
-		++xprt->connect_cookie;
-	if (ep->rep_connected > 0) {
-		if (!xprt_test_and_set_connected(xprt))
-			xprt_wake_pending_tasks(xprt, 0);
-	} else {
-		if (xprt_test_and_clear_connected(xprt))
-			xprt_wake_pending_tasks(xprt, -ENOTCONN);
-	}
-	spin_unlock_bh(&xprt->transport_lock);
-}
-
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 /* By convention, backchannel calls arrive via rdma_msg type
  * messages, and never populate the chunk lists. This makes
@@ -959,18 +937,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 }
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
-/*
- * This function is called when an async event is posted to
- * the connection which changes the connection state. All it
- * does at this point is mark the connection up/down, the rpc
- * timers do the rest.
- */
-void
-rpcrdma_conn_func(struct rpcrdma_ep *ep)
-{
-	schedule_delayed_work(&ep->rep_connect_worker, 0);
-}
-
 /* Process received RPC/RDMA messages.
  *
  * Errors must result in the RPC task either being awakened, or
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 545d3fc..534c178 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -219,6 +219,34 @@
 		}
 }
 
+void
+rpcrdma_conn_func(struct rpcrdma_ep *ep)
+{
+	schedule_delayed_work(&ep->rep_connect_worker, 0);
+}
+
+void
+rpcrdma_connect_worker(struct work_struct *work)
+{
+	struct rpcrdma_ep *ep =
+		container_of(work, struct rpcrdma_ep, rep_connect_worker.work);
+	struct rpcrdma_xprt *r_xprt =
+		container_of(ep, struct rpcrdma_xprt, rx_ep);
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+
+	spin_lock_bh(&xprt->transport_lock);
+	if (++xprt->connect_cookie == 0)	/* maintain a reserved value */
+		++xprt->connect_cookie;
+	if (ep->rep_connected > 0) {
+		if (!xprt_test_and_set_connected(xprt))
+			xprt_wake_pending_tasks(xprt, 0);
+	} else {
+		if (xprt_test_and_clear_connected(xprt))
+			xprt_wake_pending_tasks(xprt, -ENOTCONN);
+	}
+	spin_unlock_bh(&xprt->transport_lock);
+}
+
 static void
 xprt_rdma_connect_worker(struct work_struct *work)
 {
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b8424fa..e35efd4 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -490,6 +490,7 @@ int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
 				struct rpcrdma_create_data_internal *);
 void rpcrdma_ep_destroy(struct rpcrdma_ep *, struct rpcrdma_ia *);
 int rpcrdma_ep_connect(struct rpcrdma_ep *, struct rpcrdma_ia *);
+void rpcrdma_conn_func(struct rpcrdma_ep *ep);
 void rpcrdma_ep_disconnect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 
 int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
@@ -549,13 +550,6 @@ struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
 }
 
 /*
- * RPC/RDMA connection management calls - xprtrdma/rpc_rdma.c
- */
-void rpcrdma_connect_worker(struct work_struct *);
-void rpcrdma_conn_func(struct rpcrdma_ep *);
-void rpcrdma_reply_handler(struct work_struct *);
-
-/*
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c
  */
 
@@ -572,12 +566,14 @@ bool rpcrdma_prepare_send_sges(struct rpcrdma_ia *, struct rpcrdma_req *,
 void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
 int rpcrdma_marshal_req(struct rpc_rqst *);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
+void rpcrdma_reply_handler(struct work_struct *work);
 
 /* RPC/RDMA module init - xprtrdma/transport.c
  */
 extern unsigned int xprt_rdma_max_inline_read;
 void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);
 void xprt_rdma_free_addresses(struct rpc_xprt *xprt);
+void rpcrdma_connect_worker(struct work_struct *work);
 void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq);
 int xprt_rdma_init(void);
 void xprt_rdma_cleanup(void);

