Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32783 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdDIRFi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Apr 2017 13:05:38 -0400
Subject: [PATCH v3 01/14] svcrdma: Move send_wr to svc_rdma_op_ctxt
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sun, 09 Apr 2017 13:05:36 -0400
Message-ID: <20170409170536.15073.60128.stgit@klimt.1015granger.net>
In-Reply-To: <20170409163820.15073.43257.stgit@klimt.1015granger.net>
References: <20170409163820.15073.43257.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move the ib_send_wr off the stack, and move common code
to post a Send Work Request into a helper.

This is a refactoring change only.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h            |    4 ++
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   11 -----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   64 +++++++++++++++++-----------
 3 files changed, 44 insertions(+), 35 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index b105f73..287db5c 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -85,6 +85,7 @@ struct svc_rdma_op_ctxt {
 	enum dma_data_direction direction;
 	int count;
 	unsigned int mapped_sges;
+	struct ib_send_wr send_wr;
 	struct ib_sge sge[RPCSVC_MAXPAGES];
 	struct page *pages[RPCSVC_MAXPAGES];
 };
@@ -227,6 +228,9 @@ extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
 /* svc_rdma_sendto.c */
 extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
 			    struct svc_rdma_req_map *, bool);
+extern int svc_rdma_post_send_wr(struct svcxprt_rdma *rdma,
+				 struct svc_rdma_op_ctxt *ctxt,
+				 int num_sge, u32 inv_rkey);
 extern int svc_rdma_sendto(struct svc_rqst *);
 extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				int);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index ff1df40..f12f39c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -104,7 +104,6 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	struct xdr_buf *sndbuf = &rqst->rq_snd_buf;
 	struct svc_rdma_op_ctxt *ctxt;
 	struct svc_rdma_req_map *vec;
-	struct ib_send_wr send_wr;
 	int ret;
 
 	vec = svc_rdma_get_req_map(rdma);
@@ -132,15 +131,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	}
 	svc_rdma_count_mappings(rdma, ctxt);
 
-	memset(&send_wr, 0, sizeof(send_wr));
-	ctxt->cqe.done = svc_rdma_wc_send;
-	send_wr.wr_cqe = &ctxt->cqe;
-	send_wr.sg_list = ctxt->sge;
-	send_wr.num_sge = 1;
-	send_wr.opcode = IB_WR_SEND;
-	send_wr.send_flags = IB_SEND_SIGNALED;
-
-	ret = svc_rdma_send(rdma, &send_wr);
+	ret = svc_rdma_post_send_wr(rdma, ctxt, 1, 0);
 	if (ret) {
 		ret = -EIO;
 		goto out_unmap;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 515221b..f90b40d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -435,6 +435,43 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	return -EIO;
 }
 
+/**
+ * svc_rdma_post_send_wr - Set up and post one Send Work Request
+ * @rdma: controlling transport
+ * @ctxt: op_ctxt for transmitting the Send WR
+ * @num_sge: number of SGEs to send
+ * @inv_rkey: R_key argument to Send With Invalidate, or zero
+ *
+ * Returns:
+ *	%0 if the Send* was posted successfully,
+ *	%-ENOTCONN if the connection was lost or dropped,
+ *	%-EINVAL if there was a problem with the Send we built,
+ *	%-ENOMEM if ib_post_send failed.
+ */
+int svc_rdma_post_send_wr(struct svcxprt_rdma *rdma,
+			  struct svc_rdma_op_ctxt *ctxt, int num_sge,
+			  u32 inv_rkey)
+{
+	struct ib_send_wr *send_wr = &ctxt->send_wr;
+
+	dprintk("svcrdma: posting Send WR with %u sge(s)\n", num_sge);
+
+	send_wr->next = NULL;
+	ctxt->cqe.done = svc_rdma_wc_send;
+	send_wr->wr_cqe = &ctxt->cqe;
+	send_wr->sg_list = ctxt->sge;
+	send_wr->num_sge = num_sge;
+	send_wr->send_flags = IB_SEND_SIGNALED;
+	if (inv_rkey) {
+		send_wr->opcode = IB_WR_SEND_WITH_INV;
+		send_wr->ex.invalidate_rkey = inv_rkey;
+	} else {
+		send_wr->opcode = IB_WR_SEND;
+	}
+
+	return svc_rdma_send(rdma, send_wr);
+}
+
 /* This function prepares the portion of the RPCRDMA message to be
  * sent in the RDMA_SEND. This function is called after data sent via
  * RDMA has already been transmitted. There are three cases:
@@ -460,7 +497,6 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		      u32 inv_rkey)
 {
 	struct svc_rdma_op_ctxt *ctxt;
-	struct ib_send_wr send_wr;
 	u32 xdr_off;
 	int sge_no;
 	int sge_bytes;
@@ -524,19 +560,8 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		pr_err("svcrdma: Too many sges (%d)\n", sge_no);
 		goto err;
 	}
-	memset(&send_wr, 0, sizeof send_wr);
-	ctxt->cqe.done = svc_rdma_wc_send;
-	send_wr.wr_cqe = &ctxt->cqe;
-	send_wr.sg_list = ctxt->sge;
-	send_wr.num_sge = sge_no;
-	if (inv_rkey) {
-		send_wr.opcode = IB_WR_SEND_WITH_INV;
-		send_wr.ex.invalidate_rkey = inv_rkey;
-	} else
-		send_wr.opcode = IB_WR_SEND;
-	send_wr.send_flags =  IB_SEND_SIGNALED;
 
-	ret = svc_rdma_send(rdma, &send_wr);
+	ret = svc_rdma_post_send_wr(rdma, ctxt, sge_no, inv_rkey);
 	if (ret)
 		goto err;
 
@@ -652,7 +677,6 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 			 int status)
 {
-	struct ib_send_wr err_wr;
 	struct page *p;
 	struct svc_rdma_op_ctxt *ctxt;
 	enum rpcrdma_errcode err;
@@ -692,17 +716,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	}
 	svc_rdma_count_mappings(xprt, ctxt);
 
-	/* Prepare SEND WR */
-	memset(&err_wr, 0, sizeof(err_wr));
-	ctxt->cqe.done = svc_rdma_wc_send;
-	err_wr.wr_cqe = &ctxt->cqe;
-	err_wr.sg_list = ctxt->sge;
-	err_wr.num_sge = 1;
-	err_wr.opcode = IB_WR_SEND;
-	err_wr.send_flags = IB_SEND_SIGNALED;
-
-	/* Post It */
-	ret = svc_rdma_send(xprt, &err_wr);
+	ret = svc_rdma_post_send_wr(xprt, ctxt, 1, 0);
 	if (ret) {
 		dprintk("svcrdma: Error %d posting send for protocol error\n",
 			ret);

