Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:45856 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754719AbdLOB4L (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:56:11 -0500
Subject: [PATCH v1 02/16] xprtrdma: Fix backchannel allocation of extra
 rpcrdma_reps
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:56:09 -0500
Message-ID: <20171215015609.13776.30088.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The backchannel code uses rpcrdma_recv_buffer_put to add new reps
to the free rep list. This also decrements rb_recv_count, which
spoofs the receive overrun logic in rpcrdma_buffer_get_rep.

Commit 9b06688bc3b9 ("xprtrdma: Fix additional uses of
spin_lock_irqsave(rb_lock)") replaced the original open-coded
list_add with a call to rpcrdma_recv_buffer_put(), but then a year
later, commit 05c974669ece ("xprtrdma: Fix receive buffer
accounting") added rep accounting to rpcrdma_recv_buffer_put.
It was an oversight to let the backchannel continue to use this
function.

The fix this, let's combine the "add to free list" logic with
rpcrdma_create_rep.

Also, do not allocate RPCRDMA_MAX_BC_REQUESTS rpcrdma_reps in
rpcrdma_buffer_create and then allocate additional rpcrdma_reps in
rpcrdma_bc_setup_reps. Allocating the extra reps during backchannel
set-up is sufficient.

Fixes: 05c974669ece ("xprtrdma: Fix receive buffer accounting")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   12 ++----------
 net/sunrpc/xprtrdma/verbs.c       |   32 +++++++++++++++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    2 +-
 3 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 8b818bb..256c67b 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -74,21 +74,13 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 static int rpcrdma_bc_setup_reps(struct rpcrdma_xprt *r_xprt,
 				 unsigned int count)
 {
-	struct rpcrdma_rep *rep;
 	int rc = 0;
 
 	while (count--) {
-		rep = rpcrdma_create_rep(r_xprt);
-		if (IS_ERR(rep)) {
-			pr_err("RPC:       %s: reply buffer alloc failed\n",
-			       __func__);
-			rc = PTR_ERR(rep);
+		rc = rpcrdma_create_rep(r_xprt);
+		if (rc)
 			break;
-		}
-
-		rpcrdma_recv_buffer_put(rep);
 	}
-
 	return rc;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 8607c02..6eecd97 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1093,10 +1093,17 @@ struct rpcrdma_req *
 	return req;
 }
 
-struct rpcrdma_rep *
+/**
+ * rpcrdma_create_rep - Allocate an rpcrdma_rep object
+ * @r_xprt: controlling transport
+ *
+ * Returns 0 on success or a negative errno on failure.
+ */
+int
 rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_rep *rep;
 	int rc;
 
@@ -1121,12 +1128,18 @@ struct rpcrdma_rep *
 	rep->rr_recv_wr.wr_cqe = &rep->rr_cqe;
 	rep->rr_recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
 	rep->rr_recv_wr.num_sge = 1;
-	return rep;
+
+	spin_lock(&buf->rb_lock);
+	list_add(&rep->rr_list, &buf->rb_recv_bufs);
+	spin_unlock(&buf->rb_lock);
+	return 0;
 
 out_free:
 	kfree(rep);
 out:
-	return ERR_PTR(rc);
+	dprintk("RPC:       %s: reply buffer %d alloc failed\n",
+		__func__, rc);
+	return rc;
 }
 
 int
@@ -1167,17 +1180,10 @@ struct rpcrdma_rep *
 	}
 
 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
-	for (i = 0; i < buf->rb_max_requests + RPCRDMA_MAX_BC_REQUESTS; i++) {
-		struct rpcrdma_rep *rep;
-
-		rep = rpcrdma_create_rep(r_xprt);
-		if (IS_ERR(rep)) {
-			dprintk("RPC:       %s: reply buffer %d alloc failed\n",
-				__func__, i);
-			rc = PTR_ERR(rep);
+	for (i = 0; i <= buf->rb_max_requests; i++) {
+		rc = rpcrdma_create_rep(r_xprt);
+		if (rc)
 			goto out;
-		}
-		list_add(&rep->rr_list, &buf->rb_recv_bufs);
 	}
 
 	rc = rpcrdma_sendctxs_create(r_xprt);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 1342f743..3b63e61 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -564,8 +564,8 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
  * Buffer calls - xprtrdma/verbs.c
  */
 struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
-struct rpcrdma_rep *rpcrdma_create_rep(struct rpcrdma_xprt *);
 void rpcrdma_destroy_req(struct rpcrdma_req *);
+int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
 struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf);

