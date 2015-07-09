Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34995 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188AbbGIUpk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:45:40 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 4/5] svcrdma: Remove svc_rdma_fastreg()
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Thu, 09 Jul 2015 16:45:37 -0400
Message-ID: <20150709204537.8481.26204.stgit@klimt.1015granger.net>
In-Reply-To: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
References: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 0bf4828983df ("svcrdma: refactor marshalling logic") removed
the last call site for svc_rdma_fastreg().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h          |    1 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   34 ------------------------------
 2 files changed, 0 insertions(+), 35 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index ca4d86a..13af61b 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -227,7 +227,6 @@ extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
 extern void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt);
 extern struct svc_rdma_req_map *svc_rdma_get_req_map(void);
 extern void svc_rdma_put_req_map(struct svc_rdma_req_map *);
-extern int svc_rdma_fastreg(struct svcxprt_rdma *, struct svc_rdma_fastreg_mr *);
 extern struct svc_rdma_fastreg_mr *svc_rdma_get_frmr(struct svcxprt_rdma *);
 extern void svc_rdma_put_frmr(struct svcxprt_rdma *,
 			      struct svc_rdma_fastreg_mr *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f4b9732..4054a9d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1202,40 +1202,6 @@ static int svc_rdma_secure_port(struct svc_rqst *rqstp)
 	return 1;
 }
 
-/*
- * Attempt to register the kvec representing the RPC memory with the
- * device.
- *
- * Returns:
- *  NULL : The device does not support fastreg or there were no more
- *         fastreg mr.
- *  frmr : The kvec register request was successfully posted.
- *    <0 : An error was encountered attempting to register the kvec.
- */
-int svc_rdma_fastreg(struct svcxprt_rdma *xprt,
-		     struct svc_rdma_fastreg_mr *frmr)
-{
-	struct ib_send_wr fastreg_wr;
-	u8 key;
-
-	/* Bump the key */
-	key = (u8)(frmr->mr->lkey & 0x000000FF);
-	ib_update_fast_reg_key(frmr->mr, ++key);
-
-	/* Prepare FASTREG WR */
-	memset(&fastreg_wr, 0, sizeof fastreg_wr);
-	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
-	fastreg_wr.send_flags = IB_SEND_SIGNALED;
-	fastreg_wr.wr.fast_reg.iova_start = (unsigned long)frmr->kva;
-	fastreg_wr.wr.fast_reg.page_list = frmr->page_list;
-	fastreg_wr.wr.fast_reg.page_list_len = frmr->page_list_len;
-	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
-	fastreg_wr.wr.fast_reg.length = frmr->map_len;
-	fastreg_wr.wr.fast_reg.access_flags = frmr->access_flags;
-	fastreg_wr.wr.fast_reg.rkey = frmr->mr->lkey;
-	return svc_rdma_send(xprt, &fastreg_wr);
-}
-
 int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 {
 	struct ib_send_wr *bad_wr, *n_wr;

