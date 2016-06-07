Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33377 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161167AbcFGTtE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:49:04 -0400
Subject: [PATCH v1 20/20] xprtrdma: Relocate connection helper functions
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:49:02 -0400
Message-ID: <20160607194902.18401.47750.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
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
index 48a8dc9..f07a77c 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -848,28 +848,6 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
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
@@ -901,18 +879,6 @@ rpcrdma_is_bcall(struct rpcrdma_msg *headerp)
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
index 970f102..8b9bb6e 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -219,6 +219,34 @@ xprt_rdma_free_addresses(struct rpc_xprt *xprt)
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
index 63d59f1..aea309b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -447,6 +447,7 @@ void rpcrdma_ia_close(struct rpcrdma_ia *);
 int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
 				struct rpcrdma_create_data_internal *);
 void rpcrdma_ep_destroy(struct rpcrdma_ep *, struct rpcrdma_ia *);
+void rpcrdma_conn_func(struct rpcrdma_ep *);
 int rpcrdma_ep_connect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 void rpcrdma_ep_disconnect(struct rpcrdma_ep *, struct rpcrdma_ia *);
 
@@ -494,25 +495,20 @@ rpcrdma_data_dir(bool writing)
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
 int rpcrdma_marshal_req(struct rpc_rqst *);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_ia *,
 				  struct rpcrdma_create_data_internal *,
 				  unsigned int);
+void rpcrdma_reply_handler(struct work_struct *);
 
 /* RPC/RDMA module init - xprtrdma/transport.c
  */
 extern unsigned int xprt_rdma_max_inline_read;
 void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);
 void xprt_rdma_free_addresses(struct rpc_xprt *xprt);
+void rpcrdma_connect_worker(struct work_struct *);
 void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq);
 int xprt_rdma_init(void);
 void xprt_rdma_cleanup(void);

