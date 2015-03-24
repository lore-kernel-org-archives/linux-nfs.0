Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33218 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbbCXUck (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 16:32:40 -0400
Subject: [PATCH v2 14/15] xprtrdma: Handle non-SEND completions via a callout
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 24 Mar 2015 16:32:38 -0400
Message-ID: <20150324203238.2311.58032.stgit@manet.1015granger.net>
In-Reply-To: <20150324201849.2311.53599.stgit@manet.1015granger.net>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow each memory registration mode to plug in a callout that handles
the completion of a memory registration operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   17 +++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c     |   16 ++++++----------
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 +++++
 3 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e17d54d..ea59c1b 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -117,6 +117,22 @@ frwr_op_maxpages(struct rpcrdma_xprt *r_xprt)
 		     rpcrdma_max_segments(r_xprt) * ia->ri_max_frmr_depth);
 }
 
+/* If FAST_REG or LOCAL_INV failed, indicate the frmr needs to be reset. */
+static void
+frwr_sendcompletion(struct ib_wc *wc)
+{
+	struct rpcrdma_mw *r;
+
+	if (likely(wc->status == IB_WC_SUCCESS))
+		return;
+
+	/* WARNING: Only wr_id and status are reliable at this point */
+	r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
+	dprintk("RPC:       %s: frmr %p (stale), status %d\n",
+		__func__, r, wc->status);
+	r->r.frmr.fr_state = FRMR_IS_STALE;
+}
+
 static int
 frwr_op_init(struct rpcrdma_xprt *r_xprt)
 {
@@ -148,6 +164,7 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 
 		list_add(&r->mw_list, &buf->rb_mws);
 		list_add(&r->mw_all, &buf->rb_all);
+		r->mw_sendcompletion = frwr_sendcompletion;
 	}
 
 	return 0;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b697b3e..cac06f2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -186,7 +186,7 @@ static const char * const wc_status[] = {
 	"remote access error",
 	"remote operation error",
 	"transport retry counter exceeded",
-	"RNR retrycounter exceeded",
+	"RNR retry counter exceeded",
 	"local RDD violation error",
 	"remove invalid RD request",
 	"operation aborted",
@@ -204,21 +204,17 @@ static const char * const wc_status[] = {
 static void
 rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 {
-	if (likely(wc->status == IB_WC_SUCCESS))
-		return;
-
 	/* WARNING: Only wr_id and status are reliable at this point */
-	if (wc->wr_id == 0ULL) {
-		if (wc->status != IB_WC_WR_FLUSH_ERR)
+	if (wc->wr_id == RPCRDMA_IGNORE_COMPLETION) {
+		if (wc->status != IB_WC_SUCCESS &&
+		    wc->status != IB_WC_WR_FLUSH_ERR)
 			pr_err("RPC:       %s: SEND: %s\n",
 			       __func__, COMPLETION_MSG(wc->status));
 	} else {
 		struct rpcrdma_mw *r;
 
 		r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
-		r->r.frmr.fr_state = FRMR_IS_STALE;
-		pr_err("RPC:       %s: frmr %p (stale): %s\n",
-		       __func__, r, COMPLETION_MSG(wc->status));
+		r->mw_sendcompletion(wc);
 	}
 }
 
@@ -1622,7 +1618,7 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 	}
 
 	send_wr.next = NULL;
-	send_wr.wr_id = 0ULL;	/* no send cookie */
+	send_wr.wr_id = RPCRDMA_IGNORE_COMPLETION;
 	send_wr.sg_list = req->rl_send_iov;
 	send_wr.num_sge = req->rl_niovs;
 	send_wr.opcode = IB_WR_SEND;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 9036fb4..54bcbe4 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -106,6 +106,10 @@ struct rpcrdma_ep {
 #define INIT_CQCOUNT(ep) atomic_set(&(ep)->rep_cqcount, (ep)->rep_cqinit)
 #define DECR_CQCOUNT(ep) atomic_sub_return(1, &(ep)->rep_cqcount)
 
+/* Force completion handler to ignore the signal
+ */
+#define RPCRDMA_IGNORE_COMPLETION	(0ULL)
+
 /* Registered buffer -- registered kmalloc'd memory for RDMA SEND/RECV
  *
  * The below structure appears at the front of a large region of kmalloc'd
@@ -206,6 +210,7 @@ struct rpcrdma_mw {
 		struct ib_fmr		*fmr;
 		struct rpcrdma_frmr	frmr;
 	} r;
+	void			(*mw_sendcompletion)(struct ib_wc *);
 	struct list_head	mw_list;
 	struct list_head	mw_all;
 };

