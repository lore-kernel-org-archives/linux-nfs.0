Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32768 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753302AbcHWRy4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 13:54:56 -0400
Subject: [PATCH v2 21/22] xprtrdma: Rename rpcrdma_receive_wc()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 Aug 2016 13:54:55 -0400
Message-ID: <20160823175454.13038.95325.stgit@manet.1015granger.net>
In-Reply-To: <20160823174402.13038.84561.stgit@manet.1015granger.net>
References: <20160823174402.13038.84561.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: When converting xprtrdma to use the new CQ API, I missed a
spot. The naming convention elsewhere is:

  {svc_rdma,rpcrdma}_wc_{operation}

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4b09ccf..83f7886 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -160,13 +160,13 @@ rpcrdma_update_granted_credits(struct rpcrdma_rep *rep)
 }
 
 /**
- * rpcrdma_receive_wc - Invoked by RDMA provider for each polled Receive WC
+ * rpcrdma_wc_receive - Invoked by RDMA provider for each polled Receive WC
  * @cq:	completion queue (ignored)
  * @wc:	completed WR
  *
  */
 static void
-rpcrdma_receive_wc(struct ib_cq *cq, struct ib_wc *wc)
+rpcrdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 {
 	struct ib_cqe *cqe = wc->wr_cqe;
 	struct rpcrdma_rep *rep = container_of(cqe, struct rpcrdma_rep,
@@ -916,7 +916,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 	}
 
 	rep->rr_device = ia->ri_device;
-	rep->rr_cqe.done = rpcrdma_receive_wc;
+	rep->rr_cqe.done = rpcrdma_wc_receive;
 	rep->rr_rxprt = r_xprt;
 	INIT_WORK(&rep->rr_work, rpcrdma_receive_worker);
 	rep->rr_recv_wr.next = NULL;

