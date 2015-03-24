Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33724 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbCXUcW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 16:32:22 -0400
Subject: [PATCH v2 12/15] xprtrdma: Add "destroy MRs" memreg op
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 24 Mar 2015 16:32:19 -0400
Message-ID: <20150324203219.2311.97979.stgit@manet.1015granger.net>
In-Reply-To: <20150324201849.2311.53599.stgit@manet.1015granger.net>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Memory Region objects associated with a transport instance are
destroyed before the instance is shutdown and destroyed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c      |   18 ++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   14 ++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |    6 ++++
 net/sunrpc/xprtrdma/verbs.c        |   52 +-----------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |    1 +
 5 files changed, 40 insertions(+), 51 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 93261b0..e9ca594 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -168,11 +168,29 @@ fmr_op_reset(struct rpcrdma_xprt *r_xprt)
 			__func__, rc);
 }
 
+static void
+fmr_op_destroy(struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_mw *r;
+	int rc;
+
+	while (!list_empty(&buf->rb_all)) {
+		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
+		list_del(&r->mw_all);
+		rc = ib_dealloc_fmr(r->r.fmr);
+		if (rc)
+			dprintk("RPC:       %s: ib_dealloc_fmr failed %i\n",
+				__func__, rc);
+		kfree(r);
+	}
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
 	.ro_map				= fmr_op_map,
 	.ro_unmap			= fmr_op_unmap,
 	.ro_maxpages			= fmr_op_maxpages,
 	.ro_init			= fmr_op_init,
 	.ro_reset			= fmr_op_reset,
+	.ro_destroy			= fmr_op_destroy,
 	.ro_displayname			= "fmr",
 };
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index c2bb29d..121e400 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -260,11 +260,25 @@ frwr_op_reset(struct rpcrdma_xprt *r_xprt)
 	}
 }
 
+static void
+frwr_op_destroy(struct rpcrdma_buffer *buf)
+{
+	struct rpcrdma_mw *r;
+
+	while (!list_empty(&buf->rb_all)) {
+		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
+		list_del(&r->mw_all);
+		__frwr_release(r);
+		kfree(r);
+	}
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
 	.ro_map				= frwr_op_map,
 	.ro_unmap			= frwr_op_unmap,
 	.ro_maxpages			= frwr_op_maxpages,
 	.ro_init			= frwr_op_init,
 	.ro_reset			= frwr_op_reset,
+	.ro_destroy			= frwr_op_destroy,
 	.ro_displayname			= "frwr",
 };
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index e060713..eb39011 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -64,11 +64,17 @@ physical_op_reset(struct rpcrdma_xprt *r_xprt)
 {
 }
 
+static void
+physical_op_destroy(struct rpcrdma_buffer *buf)
+{
+}
+
 const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
 	.ro_map				= physical_op_map,
 	.ro_unmap			= physical_op_unmap,
 	.ro_maxpages			= physical_op_maxpages,
 	.ro_init			= physical_op_init,
 	.ro_reset			= physical_op_reset,
+	.ro_destroy			= physical_op_destroy,
 	.ro_displayname			= "physical",
 };
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1b2c1f4..a7fb314 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1199,47 +1199,6 @@ rpcrdma_destroy_req(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 	kfree(req);
 }
 
-static void
-rpcrdma_destroy_fmrs(struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_mw *r;
-	int rc;
-
-	while (!list_empty(&buf->rb_all)) {
-		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
-		list_del(&r->mw_all);
-		list_del(&r->mw_list);
-
-		rc = ib_dealloc_fmr(r->r.fmr);
-		if (rc)
-			dprintk("RPC:       %s: ib_dealloc_fmr failed %i\n",
-				__func__, rc);
-
-		kfree(r);
-	}
-}
-
-static void
-rpcrdma_destroy_frmrs(struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_mw *r;
-	int rc;
-
-	while (!list_empty(&buf->rb_all)) {
-		r = list_entry(buf->rb_all.next, struct rpcrdma_mw, mw_all);
-		list_del(&r->mw_all);
-		list_del(&r->mw_list);
-
-		rc = ib_dereg_mr(r->r.frmr.fr_mr);
-		if (rc)
-			dprintk("RPC:       %s: ib_dereg_mr failed %i\n",
-				__func__, rc);
-		ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
-
-		kfree(r);
-	}
-}
-
 void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {
@@ -1260,16 +1219,7 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 			rpcrdma_destroy_req(ia, buf->rb_send_bufs[i]);
 	}
 
-	switch (ia->ri_memreg_strategy) {
-	case RPCRDMA_FRMR:
-		rpcrdma_destroy_frmrs(buf);
-		break;
-	case RPCRDMA_MTHCAFMR:
-		rpcrdma_destroy_fmrs(buf);
-		break;
-	default:
-		break;
-	}
+	ia->ri_ops->ro_destroy(buf);
 
 	kfree(buf->rb_pool);
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0680239..b95e223 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -343,6 +343,7 @@ struct rpcrdma_memreg_ops {
 	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
 	int		(*ro_init)(struct rpcrdma_xprt *);
 	void		(*ro_reset)(struct rpcrdma_xprt *);
+	void		(*ro_destroy)(struct rpcrdma_buffer *);
 	const char	*ro_displayname;
 };
 

