Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36073 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754409AbcKRPLA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 10:11:00 -0500
Subject: [PATCH v2 06/10] svcrdma: Remove svc_rdma_op_ctxt::wc_status
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 10:10:58 -0500
Message-ID: <20161118151058.13658.72946.stgit@klimt.1015granger.net>
In-Reply-To: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
References: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Completion status is already reported in the individual
completion handlers. Save a few bytes in struct svc_rdma_op_ctxt.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    1 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    4 ++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 -
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 43d7c70..757fb96 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -79,7 +79,6 @@ struct svc_rdma_op_ctxt {
 	struct ib_cqe reg_cqe;
 	struct ib_cqe inv_cqe;
 	struct list_head dto_q;
-	enum ib_wc_status wc_status;
 	u32 byte_len;
 	u32 position;
 	struct svcxprt_rdma *xprt;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 283246e..428ab4ef 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -640,8 +640,8 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 			goto defer;
 		goto out;
 	}
-	dprintk("svcrdma: processing ctxt=%p on xprt=%p, rqstp=%p, status=%d\n",
-		ctxt, rdma_xprt, rqstp, ctxt->wc_status);
+	dprintk("svcrdma: processing ctxt=%p on xprt=%p, rqstp=%p\n",
+		ctxt, rdma_xprt, rqstp);
 	atomic_inc(&rdma_stat_recv);
 
 	/* Build up the XDR from the receive buffers. */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index a613ebd..f9d961c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -393,7 +393,6 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 
 	/* WARNING: Only wc->wr_cqe and wc->status are reliable */
 	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
-	ctxt->wc_status = wc->status;
 	svc_rdma_unmap_dma(ctxt);
 
 	if (wc->status != IB_WC_SUCCESS)

