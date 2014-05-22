Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:59818 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbaEVA5A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 20:57:00 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v4 19/24] xprtrdma: Use macros for reconnection timeout
	constants
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Wed, 21 May 2014 20:56:59 -0400
Message-ID: <20140522005659.27190.54314.stgit@manet.1015granger.net>
In-Reply-To: <20140522004505.27190.58897.stgit@manet.1015granger.net>
References: <20140522004505.27190.58897.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Ensure the same max and min constant values are used
everywhere when setting reconnect timeouts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/transport.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d18b2a3..04b7452 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -149,6 +149,11 @@ static struct ctl_table sunrpc_table[] = {
 
 #endif
 
+#define RPCRDMA_BIND_TO		(60U * HZ)
+#define RPCRDMA_INIT_REEST_TO	(5U * HZ)
+#define RPCRDMA_MAX_REEST_TO	(30U * HZ)
+#define RPCRDMA_IDLE_DISC_TO	(5U * 60* HZ)
+
 static struct rpc_xprt_ops xprt_rdma_procs;	/* forward reference */
 
 static void
@@ -285,9 +290,9 @@ xprt_setup_rdma(struct xprt_create *args)
 
 	/* 60 second timeout, no retries */
 	xprt->timeout = &xprt_rdma_default_timeout;
-	xprt->bind_timeout = (60U * HZ);
-	xprt->reestablish_timeout = (5U * HZ);
-	xprt->idle_timeout = (5U * 60 * HZ);
+	xprt->bind_timeout = RPCRDMA_BIND_TO;
+	xprt->reestablish_timeout = RPCRDMA_INIT_REEST_TO;
+	xprt->idle_timeout = RPCRDMA_IDLE_DISC_TO;
 
 	xprt->resvport = 0;		/* privileged port not needed */
 	xprt->tsh_size = 0;		/* RPC-RDMA handles framing */
@@ -432,10 +437,10 @@ xprt_rdma_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 		schedule_delayed_work(&r_xprt->rdma_connect,
 			xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
-		if (xprt->reestablish_timeout > (30 * HZ))
-			xprt->reestablish_timeout = (30 * HZ);
-		else if (xprt->reestablish_timeout < (5 * HZ))
-			xprt->reestablish_timeout = (5 * HZ);
+		if (xprt->reestablish_timeout > RPCRDMA_MAX_REEST_TO)
+			xprt->reestablish_timeout = RPCRDMA_MAX_REEST_TO;
+		else if (xprt->reestablish_timeout < RPCRDMA_INIT_REEST_TO)
+			xprt->reestablish_timeout = RPCRDMA_INIT_REEST_TO;
 	} else {
 		schedule_delayed_work(&r_xprt->rdma_connect, 0);
 		if (!RPC_IS_ASYNC(task))

