Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33190 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964931AbdAGRRE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:17:04 -0500
Subject: [PATCH v1 13/22] svcrdma: Remove old RDMA Write completion handlers
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:17:02 -0500
Message-ID: <20170107171702.14126.66998.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. RDMA Write completions are now handled by the rdma_rw API.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    1 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   18 ------------------
 2 files changed, 19 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 538a220..0e681b1 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -263,7 +263,6 @@ extern void svc_rdma_send_error(struct svcxprt_rdma *rdma, __be32 *rdma_argp,
 
 /* svc_rdma_transport.c */
 extern void svc_rdma_wc_send(struct ib_cq *, struct ib_wc *);
-extern void svc_rdma_wc_write(struct ib_cq *, struct ib_wc *);
 extern void svc_rdma_wc_reg(struct ib_cq *, struct ib_wc *);
 extern void svc_rdma_wc_read(struct ib_cq *, struct ib_wc *);
 extern void svc_rdma_wc_inv(struct ib_cq *, struct ib_wc *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index a6ddd8f..d930f70 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -473,24 +473,6 @@ void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 }
 
 /**
- * svc_rdma_wc_write - Invoked by RDMA provider for each polled Write WC
- * @cq:        completion queue
- * @wc:        completed WR
- *
- */
-void svc_rdma_wc_write(struct ib_cq *cq, struct ib_wc *wc)
-{
-	struct ib_cqe *cqe = wc->wr_cqe;
-	struct svc_rdma_op_ctxt *ctxt;
-
-	svc_rdma_send_wc_common_put(cq, wc, "write");
-
-	ctxt = container_of(cqe, struct svc_rdma_op_ctxt, cqe);
-	svc_rdma_unmap_dma(ctxt);
-	svc_rdma_put_context(ctxt, 0);
-}
-
-/**
  * svc_rdma_wc_reg - Invoked by RDMA provider for each polled FASTREG WC
  * @cq:        completion queue
  * @wc:        completed WR

