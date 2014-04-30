Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:59387 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945938AbaD3Tbc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 15:31:32 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH V3 14/17] xprtrdma: Limit work done by completion handler
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 30 Apr 2014 15:31:30 -0400
Message-ID: <20140430193130.5663.67909.stgit@manet.1015granger.net>
In-Reply-To: <20140430191433.5663.16217.stgit@manet.1015granger.net>
References: <20140430191433.5663.16217.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sagi Grimberg <sagig@dev.mellanox.co.il> points out that a steady
stream of CQ events could starve other work because of the boundless
loop pooling in rpcrdma_{send,recv}_poll().

Instead of a (potentially infinite) while loop, return after
collecting a budgeted number of completions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Sagi Grimberg <sagig@dev.mellanox.co.il>
---

 net/sunrpc/xprtrdma/verbs.c     |   10 ++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b8caee9..1d08366 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -165,8 +165,9 @@ static int
 rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 {
 	struct ib_wc *wcs;
-	int count, rc;
+	int budget, count, rc;
 
+	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
 	do {
 		wcs = ep->rep_send_wcs;
 
@@ -177,7 +178,7 @@ rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 		count = rc;
 		while (count-- > 0)
 			rpcrdma_sendcq_process_wc(wcs++);
-	} while (rc == RPCRDMA_POLLSIZE);
+	} while (rc == RPCRDMA_POLLSIZE && --budget);
 	return 0;
 }
 
@@ -254,8 +255,9 @@ static int
 rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 {
 	struct ib_wc *wcs;
-	int count, rc;
+	int budget, count, rc;
 
+	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
 	do {
 		wcs = ep->rep_recv_wcs;
 
@@ -266,7 +268,7 @@ rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 		count = rc;
 		while (count-- > 0)
 			rpcrdma_recvcq_process_wc(wcs++);
-	} while (rc == RPCRDMA_POLLSIZE);
+	} while (rc == RPCRDMA_POLLSIZE && --budget);
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index cb4c882..0c3b88e 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -74,6 +74,7 @@ struct rpcrdma_ia {
  * RDMA Endpoint -- one per transport instance
  */
 
+#define RPCRDMA_WC_BUDGET	(128)
 #define RPCRDMA_POLLSIZE	(16)
 
 struct rpcrdma_ep {

