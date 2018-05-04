Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:44423 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbeEDTfQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:35:16 -0400
Subject: [PATCH v1 09/19] xprtrdma: Clean up Receive trace points
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:35:14 -0400
Message-ID: <20180504193514.31688.2261.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For clarity, report the posting and completion of Receive CQEs.

Also, the wc->byte_len field contains garbage if wc->status is
non-zero, and the vendor error field contains garbage if wc->status
is zero. For readability, don't save those fields in those cases.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   39 ++++++++++++++++++++-------------------
 net/sunrpc/xprtrdma/verbs.c    |    4 ++--
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 50ed3f8..99c0049 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -528,24 +528,21 @@
 
 TRACE_EVENT(xprtrdma_post_recv,
 	TP_PROTO(
-		const struct rpcrdma_rep *rep,
-		int status
+		const struct ib_cqe *cqe
 	),
 
-	TP_ARGS(rep, status),
+	TP_ARGS(cqe),
 
 	TP_STRUCT__entry(
-		__field(const void *, rep)
-		__field(int, status)
+		__field(const void *, cqe)
 	),
 
 	TP_fast_assign(
-		__entry->rep = rep;
-		__entry->status = status;
+		__entry->cqe = cqe;
 	),
 
-	TP_printk("rep=%p status=%d",
-		__entry->rep, __entry->status
+	TP_printk("cqe=%p",
+		__entry->cqe
 	)
 );
 
@@ -584,28 +581,32 @@
 
 TRACE_EVENT(xprtrdma_wc_receive,
 	TP_PROTO(
-		const struct rpcrdma_rep *rep,
 		const struct ib_wc *wc
 	),
 
-	TP_ARGS(rep, wc),
+	TP_ARGS(wc),
 
 	TP_STRUCT__entry(
-		__field(const void *, rep)
-		__field(unsigned int, byte_len)
+		__field(const void *, cqe)
+		__field(u32, byte_len)
 		__field(unsigned int, status)
-		__field(unsigned int, vendor_err)
+		__field(u32, vendor_err)
 	),
 
 	TP_fast_assign(
-		__entry->rep = rep;
-		__entry->byte_len = wc->byte_len;
+		__entry->cqe = wc->wr_cqe;
 		__entry->status = wc->status;
-		__entry->vendor_err = __entry->status ? wc->vendor_err : 0;
+		if (wc->status) {
+			__entry->byte_len = 0;
+			__entry->vendor_err = wc->vendor_err;
+		} else {
+			__entry->byte_len = wc->byte_len;
+			__entry->vendor_err = 0;
+		}
 	),
 
-	TP_printk("rep=%p, %u bytes: %s (%u/0x%x)",
-		__entry->rep, __entry->byte_len,
+	TP_printk("cqe=%p %u bytes: %s (%u/0x%x)",
+		__entry->cqe, __entry->byte_len,
 		rdma_show_wc_status(__entry->status),
 		__entry->status, __entry->vendor_err
 	)
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 581d0ae..f4ce7af 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -160,7 +160,7 @@
 					       rr_cqe);
 
 	/* WARNING: Only wr_id and status are reliable at this point */
-	trace_xprtrdma_wc_receive(rep, wc);
+	trace_xprtrdma_wc_receive(wc);
 	if (wc->status != IB_WC_SUCCESS)
 		goto out_fail;
 
@@ -1575,7 +1575,7 @@ struct rpcrdma_regbuf *
 	if (!rpcrdma_dma_map_regbuf(ia, rep->rr_rdmabuf))
 		goto out_map;
 	rc = ib_post_recv(ia->ri_id->qp, &rep->rr_recv_wr, &recv_wr_fail);
-	trace_xprtrdma_post_recv(rep, rc);
+	trace_xprtrdma_post_recv(rep->rr_recv_wr.wr_cqe);
 	if (rc)
 		return -ENOTCONN;
 	return 0;

