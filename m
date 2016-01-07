Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36216 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbcAGTtG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2016 14:49:06 -0500
Subject: [PATCH v5 02/10] svcrdma: Clean up process_context()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org, dledford@redhat.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 07 Jan 2016 14:49:03 -0500
Message-ID: <20160107194903.2662.66447.stgit@klimt.1015granger.net>
In-Reply-To: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
References: <20160107194251.2662.88158.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Be sure the completed ctxt is put in every path.

The xprt enqueue can take a while, so put the completed ctxt back
in circulation _before_ enqueuing the xprt.

Remove/disable debugging.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Bruce Fields <bfields@fieldses.org>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   44 ++++++++++++++----------------
 1 file changed, 21 insertions(+), 23 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 45d1824..a100d56 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -386,46 +386,44 @@ static void rq_cq_reap(struct svcxprt_rdma *xprt)
 static void process_context(struct svcxprt_rdma *xprt,
 			    struct svc_rdma_op_ctxt *ctxt)
 {
+	struct svc_rdma_op_ctxt *read_hdr;
+	int free_pages = 0;
+
 	svc_rdma_unmap_dma(ctxt);
 
 	switch (ctxt->wr_op) {
 	case IB_WR_SEND:
-		if (ctxt->frmr)
-			pr_err("svcrdma: SEND: ctxt->frmr != NULL\n");
-		svc_rdma_put_context(ctxt, 1);
+		free_pages = 1;
 		break;
 
 	case IB_WR_RDMA_WRITE:
-		if (ctxt->frmr)
-			pr_err("svcrdma: WRITE: ctxt->frmr != NULL\n");
-		svc_rdma_put_context(ctxt, 0);
 		break;
 
 	case IB_WR_RDMA_READ:
 	case IB_WR_RDMA_READ_WITH_INV:
 		svc_rdma_put_frmr(xprt, ctxt->frmr);
-		if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
-			struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
-			if (read_hdr) {
-				spin_lock_bh(&xprt->sc_rq_dto_lock);
-				set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
-				list_add_tail(&read_hdr->dto_q,
-					      &xprt->sc_read_complete_q);
-				spin_unlock_bh(&xprt->sc_rq_dto_lock);
-			} else {
-				pr_err("svcrdma: ctxt->read_hdr == NULL\n");
-			}
-			svc_xprt_enqueue(&xprt->sc_xprt);
-		}
+
+		if (!test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags))
+			break;
+
+		read_hdr = ctxt->read_hdr;
 		svc_rdma_put_context(ctxt, 0);
-		break;
+
+		spin_lock_bh(&xprt->sc_rq_dto_lock);
+		set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
+		list_add_tail(&read_hdr->dto_q,
+			      &xprt->sc_read_complete_q);
+		spin_unlock_bh(&xprt->sc_rq_dto_lock);
+		svc_xprt_enqueue(&xprt->sc_xprt);
+		return;
 
 	default:
-		printk(KERN_ERR "svcrdma: unexpected completion type, "
-		       "opcode=%d\n",
-		       ctxt->wr_op);
+		dprintk("svcrdma: unexpected completion opcode=%d\n",
+			ctxt->wr_op);
 		break;
 	}
+
+	svc_rdma_put_context(ctxt, free_pages);
 }
 
 /*

