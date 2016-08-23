Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32835 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932342AbcHWR4j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 13:56:39 -0400
Subject: [PATCH v2 22/22] xprtrdma: Eliminate rpcrdma_receive_worker()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 Aug 2016 13:55:03 -0400
Message-ID: <20160823175503.13038.17633.stgit@manet.1015granger.net>
In-Reply-To: <20160823174402.13038.84561.stgit@manet.1015granger.net>
References: <20160823174402.13038.84561.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: the extra layer of indirection doesn't add value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 +++-
 net/sunrpc/xprtrdma/verbs.c     |   11 +----------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 20115ad..e210fe6 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -977,8 +977,10 @@ rpcrdma_conn_func(struct rpcrdma_ep *ep)
  * allowed to timeout, to discover the errors at that time.
  */
 void
-rpcrdma_reply_handler(struct rpcrdma_rep *rep)
+rpcrdma_reply_handler(struct work_struct *work)
 {
+	struct rpcrdma_rep *rep =
+			container_of(work, struct rpcrdma_rep, rr_work);
 	struct rpcrdma_msg *headerp;
 	struct rpcrdma_req *req;
 	struct rpc_rqst *rqst;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 83f7886..4a1b341 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -128,15 +128,6 @@ rpcrdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 		       wc->status, wc->vendor_err);
 }
 
-static void
-rpcrdma_receive_worker(struct work_struct *work)
-{
-	struct rpcrdma_rep *rep =
-			container_of(work, struct rpcrdma_rep, rr_work);
-
-	rpcrdma_reply_handler(rep);
-}
-
 /* Perform basic sanity checking to avoid using garbage
  * to update the credit grant value.
  */
@@ -918,7 +909,7 @@ rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 	rep->rr_device = ia->ri_device;
 	rep->rr_cqe.done = rpcrdma_wc_receive;
 	rep->rr_rxprt = r_xprt;
-	INIT_WORK(&rep->rr_work, rpcrdma_receive_worker);
+	INIT_WORK(&rep->rr_work, rpcrdma_reply_handler);
 	rep->rr_recv_wr.next = NULL;
 	rep->rr_recv_wr.wr_cqe = &rep->rr_cqe;
 	rep->rr_recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0278f38..94c7ab5 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -534,7 +534,7 @@ rpcrdma_data_dir(bool writing)
  */
 void rpcrdma_connect_worker(struct work_struct *);
 void rpcrdma_conn_func(struct rpcrdma_ep *);
-void rpcrdma_reply_handler(struct rpcrdma_rep *);
+void rpcrdma_reply_handler(struct work_struct *);
 
 /*
  * RPC/RDMA protocol calls - xprtrdma/rpc_rdma.c

