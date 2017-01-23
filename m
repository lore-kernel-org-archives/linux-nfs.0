Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35787 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750723AbdAWUyH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 15:54:07 -0500
Subject: [PATCH v2 4/5] xprtrdma: Reduce required number of send SGEs
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jan 2017 15:53:10 -0500
Message-ID: <20170123205310.21699.47397.stgit@manet.1015granger.net>
In-Reply-To: <20170123205159.21699.47373.stgit@manet.1015granger.net>
References: <20170123205159.21699.47373.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The MAX_SEND_SGES check introduced in commit 655fec6987be
("xprtrdma: Use gathered Send for large inline messages") fails
for devices that have a small max_sge.

Instead of checking for a large fixed maximum number of SGEs,
check for a minimum small number. RPC-over-RDMA will switch to
using a Read chunk if an xdr_buf has more pages than can fit in
the device's max_sge limit. This is considerably better than
failing all together to mount the server.

This fix supports devices that have as few as three send SGEs
available.

Reported-By: Selvin Xavier <selvin.xavier@broadcom.com>
Reported-By: Devesh Sharma <devesh.sharma@broadcom.com>
Reported-by: Honggang Li <honli@redhat.com>
Reported-by: Ram Amrani <Ram.Amrani@cavium.com>
Fixes: 655fec6987be ("xprtrdma: Use gathered Send for large ...")
Tested-by: Honggang Li <honli@redhat.com>
Tested-by: Ram Amrani <Ram.Amrani@cavium.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Parav Pandit <parav@mellanox.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   26 +++++++++++++++++++++++---
 net/sunrpc/xprtrdma/verbs.c     |   13 +++++++------
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
 3 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c634f0f..d889883 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -125,14 +125,34 @@ void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *r_xprt)
 /* The client can send a request inline as long as the RPCRDMA header
  * plus the RPC call fit under the transport's inline limit. If the
  * combined call message size exceeds that limit, the client must use
- * the read chunk list for this operation.
+ * a Read chunk for this operation.
+ *
+ * A Read chunk is also required if sending the RPC call inline would
+ * exceed this device's max_sge limit.
  */
 static bool rpcrdma_args_inline(struct rpcrdma_xprt *r_xprt,
 				struct rpc_rqst *rqst)
 {
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
+	struct xdr_buf *xdr = &rqst->rq_snd_buf;
+	unsigned int count, remaining, offset;
+
+	if (xdr->len > r_xprt->rx_ia.ri_max_inline_write)
+		return false;
 
-	return rqst->rq_snd_buf.len <= ia->ri_max_inline_write;
+	if (xdr->page_len) {
+		remaining = xdr->page_len;
+		offset = xdr->page_base & ~PAGE_MASK;
+		count = 0;
+		while (remaining) {
+			remaining -= min_t(unsigned int,
+					   PAGE_SIZE - offset, remaining);
+			offset = 0;
+			if (++count > r_xprt->rx_ia.ri_max_send_sges)
+				return false;
+		}
+	}
+
+	return true;
 }
 
 /* The client can't know how large the actual reply will be. Thus it
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 23f4da4..61d16c3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -488,18 +488,19 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
  */
 int
 rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
-				struct rpcrdma_create_data_internal *cdata)
+		  struct rpcrdma_create_data_internal *cdata)
 {
 	struct rpcrdma_connect_private *pmsg = &ep->rep_cm_private;
+	unsigned int max_qp_wr, max_sge;
 	struct ib_cq *sendcq, *recvcq;
-	unsigned int max_qp_wr;
 	int rc;
 
-	if (ia->ri_device->attrs.max_sge < RPCRDMA_MAX_SEND_SGES) {
-		dprintk("RPC:       %s: insufficient sge's available\n",
-			__func__);
+	max_sge = min(ia->ri_device->attrs.max_sge, RPCRDMA_MAX_SEND_SGES);
+	if (max_sge < RPCRDMA_MIN_SEND_SGES) {
+		pr_warn("rpcrdma: HCA provides only %d send SGEs\n", max_sge);
 		return -ENOMEM;
 	}
+	ia->ri_max_send_sges = max_sge - RPCRDMA_MIN_SEND_SGES;
 
 	if (ia->ri_device->attrs.max_qp_wr <= RPCRDMA_BACKWARD_WRS) {
 		dprintk("RPC:       %s: insufficient wqe's available\n",
@@ -524,7 +525,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 	ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
 	ep->rep_attr.cap.max_recv_wr += RPCRDMA_BACKWARD_WRS;
 	ep->rep_attr.cap.max_recv_wr += 1;	/* drain cqe */
-	ep->rep_attr.cap.max_send_sge = RPCRDMA_MAX_SEND_SGES;
+	ep->rep_attr.cap.max_send_sge = max_sge;
 	ep->rep_attr.cap.max_recv_sge = 1;
 	ep->rep_attr.cap.max_inline_data = 0;
 	ep->rep_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c137154..3d7e9c9 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -74,6 +74,7 @@ struct rpcrdma_ia {
 	unsigned int		ri_max_frmr_depth;
 	unsigned int		ri_max_inline_write;
 	unsigned int		ri_max_inline_read;
+	unsigned int		ri_max_send_sges;
 	bool			ri_reminv_expected;
 	bool			ri_implicit_roundup;
 	enum ib_mr_type		ri_mrtype;
@@ -311,6 +312,7 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
  * - xdr_buf tail iovec
  */
 enum {
+	RPCRDMA_MIN_SEND_SGES = 3,
 	RPCRDMA_MAX_SEND_PAGES = PAGE_SIZE + RPCRDMA_MAX_INLINE - 1,
 	RPCRDMA_MAX_PAGE_SGES = (RPCRDMA_MAX_SEND_PAGES >> PAGE_SHIFT) + 1,
 	RPCRDMA_MAX_SEND_SGES = 1 + 1 + RPCRDMA_MAX_PAGE_SGES + 1,

