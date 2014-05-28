Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:54017 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbaE1Oev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:34:51 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 21/24] SUNRPC: Move congestion window constants to header
	file
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:34:49 -0400
Message-ID: <20140528143449.23214.29020.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I would like to use one of the RPC client's congestion algorithm
constants in transport-specific code.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    6 ++++++
 net/sunrpc/xprt.c           |   28 +++++++++-------------------
 2 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 3e5efb2..5903d2c 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -24,6 +24,12 @@
 #define RPC_MAX_SLOT_TABLE_LIMIT	(65536U)
 #define RPC_MAX_SLOT_TABLE	RPC_MAX_SLOT_TABLE_LIMIT
 
+#define RPC_CWNDSHIFT		(8U)
+#define RPC_CWNDSCALE		(1U << RPC_CWNDSHIFT)
+#define RPC_INITCWND		RPC_CWNDSCALE
+#define RPC_MAXCWND(xprt)	((xprt)->max_reqs << RPC_CWNDSHIFT)
+#define RPCXPRT_CONGESTED(xprt) ((xprt)->cong >= (xprt)->cwnd)
+
 /*
  * This describes a timeout strategy
  */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d173f79..2d1d5a6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -71,24 +71,6 @@ static void	 xprt_destroy(struct rpc_xprt *xprt);
 static DEFINE_SPINLOCK(xprt_list_lock);
 static LIST_HEAD(xprt_list);
 
-/*
- * The transport code maintains an estimate on the maximum number of out-
- * standing RPC requests, using a smoothed version of the congestion
- * avoidance implemented in 44BSD. This is basically the Van Jacobson
- * congestion algorithm: If a retransmit occurs, the congestion window is
- * halved; otherwise, it is incremented by 1/cwnd when
- *
- *	-	a reply is received and
- *	-	a full number of requests are outstanding and
- *	-	the congestion window hasn't been updated recently.
- */
-#define RPC_CWNDSHIFT		(8U)
-#define RPC_CWNDSCALE		(1U << RPC_CWNDSHIFT)
-#define RPC_INITCWND		RPC_CWNDSCALE
-#define RPC_MAXCWND(xprt)	((xprt)->max_reqs << RPC_CWNDSHIFT)
-
-#define RPCXPRT_CONGESTED(xprt) ((xprt)->cong >= (xprt)->cwnd)
-
 /**
  * xprt_register_transport - register a transport implementation
  * @transport: transport to register
@@ -446,7 +428,15 @@ EXPORT_SYMBOL_GPL(xprt_release_rqst_cong);
  * @task: recently completed RPC request used to adjust window
  * @result: result code of completed RPC request
  *
- * We use a time-smoothed congestion estimator to avoid heavy oscillation.
+ * The transport code maintains an estimate on the maximum number of out-
+ * standing RPC requests, using a smoothed version of the congestion
+ * avoidance implemented in 44BSD. This is basically the Van Jacobson
+ * congestion algorithm: If a retransmit occurs, the congestion window is
+ * halved; otherwise, it is incremented by 1/cwnd when
+ *
+ *	-	a reply is received and
+ *	-	a full number of requests are outstanding and
+ *	-	the congestion window hasn't been updated recently.
  */
 void xprt_adjust_cwnd(struct rpc_xprt *xprt, struct rpc_task *task, int result)
 {

