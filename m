Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33039 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752646AbdCPPwg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Mar 2017 11:52:36 -0400
Subject: [PATCH v1 01/14] svcrdma: Move send_wr to svc_rdma_op_ctxt
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 16 Mar 2017 11:52:34 -0400
Message-ID: <20170316155234.4482.94225.stgit@klimt.1015granger.net>
In-Reply-To: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move the ib_send_wr off the stack, and move common send WR
setup code into a helper.

This is a refactoring change only.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h            |    3 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   12 +-----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   57 ++++++++++++++++------------
 3 files changed, 37 insertions(+), 35 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index b105f73..fa3ef11 100644
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
@@ -227,6 +228,8 @@ extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
 /* svc_rdma_sendto.c */
 extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
 			    struct svc_rdma_req_map *, bool);
+extern void svc_rdma_build_send_wr(struct svc_rdma_op_ctxt *ctxt,
+				   int num_sge);
 extern int svc_rdma_sendto(struct svc_rqst *);
 extern void svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
 				int);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index ff1df40..6741ed0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -104,7 +104,6 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	struct xdr_buf *sndbuf = &rqst->rq_snd_buf;
 	struct svc_rdma_op_ctxt *ctxt;
 	struct svc_rdma_req_map *vec;
-	struct ib_send_wr send_wr;
 	int ret;
 
 	vec = svc_rdma_get_req_map(rdma);
@@ -132,15 +131,8 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
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
+	svc_rdma_build_send_wr(ctxt, 1);
+	ret = svc_rdma_send(rdma, &ctxt->send_wr);
 	if (ret) {
 		ret = -EIO;
 		goto out_unmap;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 515221b..fdf8e3d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -435,6 +435,28 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	return -EIO;
 }
 
+/**
+ * svc_rdma_build_send_wr - Set up a Send Work Request
+ * @ctxt: op_ctxt for transmitting the Send WR
+ *
+ */
+void svc_rdma_build_send_wr(struct svc_rdma_op_ctxt *ctxt, int num_sge)
+{
+	struct ib_send_wr *send_wr;
+
+	send_wr = &ctxt->send_wr;
+	send_wr->next = NULL;
+	ctxt->cqe.done = svc_rdma_wc_send;
+	send_wr->wr_cqe = &ctxt->cqe;
+	send_wr->sg_list = ctxt->sge;
+	send_wr->num_sge = num_sge;
+	send_wr->opcode = IB_WR_SEND;
+	send_wr->send_flags = IB_SEND_SIGNALED;
+
+	dprintk("svcrdma: posting Send WR with %u sge(s)\n",
+		send_wr->num_sge);
+}
+
 /* This function prepares the portion of the RPCRDMA message to be
  * sent in the RDMA_SEND. This function is called after data sent via
  * RDMA has already been transmitted. There are three cases:
@@ -460,7 +482,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		      u32 inv_rkey)
 {
 	struct svc_rdma_op_ctxt *ctxt;
-	struct ib_send_wr send_wr;
+	struct ib_send_wr *send_wr;
 	u32 xdr_off;
 	int sge_no;
 	int sge_bytes;
@@ -524,19 +546,14 @@ static int send_reply(struct svcxprt_rdma *rdma,
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
+	svc_rdma_build_send_wr(ctxt, sge_no);
+	send_wr = &ctxt->send_wr;
+	if (inv_rkey) {
+		send_wr->opcode = IB_WR_SEND_WITH_INV;
+		send_wr->ex.invalidate_rkey = inv_rkey;
+	}
+	ret = svc_rdma_send(rdma, send_wr);
 	if (ret)
 		goto err;
 
@@ -652,7 +669,6 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 			 int status)
 {
-	struct ib_send_wr err_wr;
 	struct page *p;
 	struct svc_rdma_op_ctxt *ctxt;
 	enum rpcrdma_errcode err;
@@ -692,17 +708,8 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
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
+	svc_rdma_build_send_wr(ctxt, 1);
+	ret = svc_rdma_send(xprt, &ctxt->send_wr);
 	if (ret) {
 		dprintk("svcrdma: Error %d posting send for protocol error\n",
 			ret);

