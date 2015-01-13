Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34221 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbAMQYx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:24:53 -0500
Subject: [PATCH v2 01/20] xprtrdma: human-readable completion status
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Jan 2015 11:24:51 -0500
Message-ID: <20150113162451.14086.75470.stgit@manet.1015granger.net>
In-Reply-To: <20150113161440.14086.24801.stgit@manet.1015granger.net>
References: <20150113161440.14086.24801.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it easier to grep the system log for specific error conditions.

The wc.opcode field is not included because opcode numbers are
sparse, and because wc.opcode is not necessarily valid when
completion reports an error.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   70 +++++++++++++++++++++++++++++++++++--------
 1 file changed, 57 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c98e406..56f705d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -173,18 +173,54 @@ rpcrdma_cq_async_error_upcall(struct ib_event *event, void *context)
 	}
 }
 
+static const char * const wc_status[] = {
+	"success",
+	"local length error",
+	"local QP operation error",
+	"local EE context operation error",
+	"local protection error",
+	"WR flushed",
+	"memory management operation error",
+	"bad response error",
+	"local access error",
+	"remote invalid request error",
+	"remote access error",
+	"remote operation error",
+	"transport retry counter exceeded",
+	"RNR retrycounter exceeded",
+	"local RDD violation error",
+	"remove invalid RD request",
+	"operation aborted",
+	"invalid EE context number",
+	"invalid EE context state",
+	"fatal error",
+	"response timeout error",
+	"general error",
+};
+
+#define COMPLETION_MSG(status)					\
+	((status) < ARRAY_SIZE(wc_status) ?			\
+		wc_status[(status)] : "unexpected completion error")
+
 static void
 rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 {
-	struct rpcrdma_mw *frmr = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
+	if (likely(wc->status == IB_WC_SUCCESS))
+		return;
 
-	dprintk("RPC:       %s: frmr %p status %X opcode %d\n",
-		__func__, frmr, wc->status, wc->opcode);
+	/* WARNING: Only wr_id and status are reliable at this point */
+	if (wc->wr_id == 0ULL) {
+		if (wc->status != IB_WC_WR_FLUSH_ERR)
+			pr_err("RPC:       %s: SEND: %s\n",
+			       __func__, COMPLETION_MSG(wc->status));
+	} else {
+		struct rpcrdma_mw *r;
 
-	if (wc->wr_id == 0ULL)
-		return;
-	if (wc->status != IB_WC_SUCCESS)
-		frmr->r.frmr.fr_state = FRMR_IS_STALE;
+		r = (struct rpcrdma_mw *)(unsigned long)wc->wr_id;
+		r->r.frmr.fr_state = FRMR_IS_STALE;
+		pr_err("RPC:       %s: frmr %p (stale): %s\n",
+		       __func__, r, COMPLETION_MSG(wc->status));
+	}
 }
 
 static int
@@ -248,16 +284,17 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 	struct rpcrdma_rep *rep =
 			(struct rpcrdma_rep *)(unsigned long)wc->wr_id;
 
-	dprintk("RPC:       %s: rep %p status %X opcode %X length %u\n",
-		__func__, rep, wc->status, wc->opcode, wc->byte_len);
+	/* WARNING: Only wr_id and status are reliable at this point */
+	if (wc->status != IB_WC_SUCCESS)
+		goto out_fail;
 
-	if (wc->status != IB_WC_SUCCESS) {
-		rep->rr_len = ~0U;
-		goto out_schedule;
-	}
+	/* status == SUCCESS means all fields in wc are trustworthy */
 	if (wc->opcode != IB_WC_RECV)
 		return;
 
+	dprintk("RPC:       %s: rep %p opcode 'recv', length %u: success\n",
+		__func__, rep, wc->byte_len);
+
 	rep->rr_len = wc->byte_len;
 	ib_dma_sync_single_for_cpu(rdmab_to_ia(rep->rr_buffer)->ri_id->device,
 			rep->rr_iov.addr, rep->rr_len, DMA_FROM_DEVICE);
@@ -275,6 +312,13 @@ rpcrdma_recvcq_process_wc(struct ib_wc *wc, struct list_head *sched_list)
 
 out_schedule:
 	list_add_tail(&rep->rr_list, sched_list);
+	return;
+out_fail:
+	if (wc->status != IB_WC_WR_FLUSH_ERR)
+		pr_err("RPC:       %s: rep %p: %s\n",
+		       __func__, rep, COMPLETION_MSG(wc->status));
+	rep->rr_len = ~0U;
+	goto out_schedule;
 }
 
 static int

