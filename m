Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34264 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755195AbbK3WZX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 17:25:23 -0500
Subject: [PATCH v2 7/7] svcrdma: No need to count WRs in svc_rdma_send()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Nov 2015 17:25:22 -0500
Message-ID: <20151130222522.13029.72960.stgit@klimt.1015granger.net>
In-Reply-To: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
References: <20151130222141.13029.98664.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Minor optimization: Instead of counting WRs in a chain, have callers
pass in the number of WRs they've prepared.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    9 ++++++---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    6 +++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   17 ++++++-----------
 4 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 6f52995..f96d641 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -215,7 +215,7 @@ extern int svc_rdma_bc_post_send(struct svcxprt_rdma *,
 				 struct svc_rdma_op_ctxt *, struct xdr_buf *);
 
 /* svc_rdma_transport.c */
-extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
+extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *, int);
 extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				enum rpcrdma_errcode);
 extern int svc_rdma_post_recv(struct svcxprt_rdma *);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index be89aa0..17b0835 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -190,7 +190,7 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
 	read_wr.wr.sg_list = ctxt->sge;
 	read_wr.wr.num_sge = pages_needed;
 
-	ret = svc_rdma_send(xprt, &read_wr.wr);
+	ret = svc_rdma_send(xprt, &read_wr.wr, 1);
 	if (ret) {
 		pr_err("svcrdma: Error %d posting RDMA_READ\n", ret);
 		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
@@ -227,7 +227,7 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	int nents = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
 	struct svc_rdma_op_ctxt *ctxt = svc_rdma_get_context(xprt);
 	struct svc_rdma_fastreg_mr *frmr = svc_rdma_get_frmr(xprt);
-	int ret, read, pno, dma_nents, n;
+	int ret, read, pno, num_wrs, dma_nents, n;
 	u32 pg_off = *page_offset;
 	u32 pg_no = *page_no;
 
@@ -299,6 +299,8 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	ctxt->count = 1;
 	ctxt->read_hdr = head;
 
+	num_wrs = 2;
+
 	/* Prepare REG WR */
 	reg_wr.wr.opcode = IB_WR_REG_MR;
 	reg_wr.wr.wr_id = 0;
@@ -329,11 +331,12 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 		inv_wr.opcode = IB_WR_LOCAL_INV;
 		inv_wr.send_flags = IB_SEND_SIGNALED | IB_SEND_FENCE;
 		inv_wr.ex.invalidate_rkey = frmr->mr->lkey;
+		num_wrs++;
 	}
 	ctxt->wr_op = read_wr.wr.opcode;
 
 	/* Post the chain */
-	ret = svc_rdma_send(xprt, &reg_wr.wr);
+	ret = svc_rdma_send(xprt, &reg_wr.wr, num_wrs);
 	if (ret) {
 		pr_err("svcrdma: Error %d posting RDMA_READ\n", ret);
 		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 846df63..65b2fd6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -292,7 +292,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 
 	/* Post It */
 	atomic_inc(&rdma_stat_write);
-	if (svc_rdma_send(xprt, &write_wr.wr))
+	if (svc_rdma_send(xprt, &write_wr.wr, 1))
 		goto err;
 	return write_len - bc;
  err:
@@ -557,7 +557,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	send_wr.opcode = IB_WR_SEND;
 	send_wr.send_flags =  IB_SEND_SIGNALED;
 
-	ret = svc_rdma_send(rdma, &send_wr);
+	ret = svc_rdma_send(rdma, &send_wr, 1);
 	if (ret)
 		goto err;
 
@@ -698,7 +698,7 @@ int svc_rdma_bc_post_send(struct svcxprt_rdma *rdma,
 	send_wr.opcode = IB_WR_SEND;
 	send_wr.send_flags = IB_SEND_SIGNALED;
 
-	ret = svc_rdma_send(rdma, &send_wr);
+	ret = svc_rdma_send(rdma, &send_wr, 1);
 	if (ret) {
 		svc_rdma_unmap_dma(ctxt);
 		ret = -EIO;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index ab5e376..77eeb23 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1274,20 +1274,15 @@ static int svc_rdma_secure_port(struct svc_rqst *rqstp)
 	return 1;
 }
 
-int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
+int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr,
+		  int wr_count)
 {
-	struct ib_send_wr *bad_wr, *n_wr;
-	int wr_count;
-	int i;
-	int ret;
+	struct ib_send_wr *bad_wr;
+	int i, ret;
 
 	if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
 		return -ENOTCONN;
 
-	wr_count = 1;
-	for (n_wr = wr->next; n_wr; n_wr = n_wr->next)
-		wr_count++;
-
 	/* If the SQ is full, wait until an SQ entry is available */
 	while (1) {
 		spin_lock_bh(&xprt->sc_lock);
@@ -1316,7 +1311,7 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 		if (ret) {
 			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
 			atomic_sub(wr_count, &xprt->sc_sq_count);
-			for (i = 0; i < wr_count; i ++)
+			for (i = 0; i < wr_count; i++)
 				svc_xprt_put(&xprt->sc_xprt);
 			dprintk("svcrdma: failed to post SQ WR rc=%d, "
 			       "sc_sq_count=%d, sc_sq_depth=%d\n",
@@ -1374,7 +1369,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	err_wr.send_flags = IB_SEND_SIGNALED;
 
 	/* Post It */
-	ret = svc_rdma_send(xprt, &err_wr);
+	ret = svc_rdma_send(xprt, &err_wr, 1);
 	if (ret) {
 		dprintk("svcrdma: Error %d posting send for protocol error\n",
 			ret);

