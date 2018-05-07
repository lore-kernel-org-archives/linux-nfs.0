Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:53527 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbeEGT2B (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:28:01 -0400
Subject: [PATCH v1 13/19] svcrdma: Clean up Send SGE accounting
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:27:59 -0400
Message-ID: <20180507192759.4608.33075.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Since there's already a svc_rdma_op_ctxt being passed
around with the running count of mapped SGEs, drop unneeded
parameters to svc_rdma_post_send_wr().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h            |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   17 ++++++++---------
 4 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 95530bc..8827b4e 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -188,7 +188,7 @@ extern int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
 				  __be32 *rdma_resp, unsigned int len);
 extern int svc_rdma_post_send_wr(struct svcxprt_rdma *rdma,
 				 struct svc_rdma_op_ctxt *ctxt,
-				 int num_sge, u32 inv_rkey);
+				 u32 inv_rkey);
 extern int svc_rdma_sendto(struct svc_rqst *);
 
 /* svc_rdma_transport.c */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index d501521..0b9ba9f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -135,7 +135,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	 * the rq_buffer before all retransmits are complete.
 	 */
 	get_page(virt_to_page(rqst->rq_buffer));
-	ret = svc_rdma_post_send_wr(rdma, ctxt, 1, 0);
+	ret = svc_rdma_post_send_wr(rdma, ctxt, 0);
 	if (ret)
 		goto out_unmap;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 0445e75..af6d2f3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -639,7 +639,7 @@ static void svc_rdma_send_error(struct svcxprt_rdma *xprt,
 		return;
 	}
 
-	ret = svc_rdma_post_send_wr(xprt, ctxt, 1, 0);
+	ret = svc_rdma_post_send_wr(xprt, ctxt, 0);
 	if (ret) {
 		svc_rdma_unmap_dma(ctxt);
 		svc_rdma_put_context(ctxt, 1);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index ee9ba07..4591017 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -365,8 +365,7 @@ int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
 /* Load the xdr_buf into the ctxt's sge array, and DMA map each
  * element as it is added.
  *
- * Returns the number of sge elements loaded on success, or
- * a negative errno on failure.
+ * Returns zero on success, or a negative errno on failure.
  */
 static int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 				  struct svc_rdma_op_ctxt *ctxt,
@@ -429,7 +428,7 @@ static int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 			return ret;
 	}
 
-	return sge_no - 1;
+	return 0;
 }
 
 /* The svc_rqst and all resources it owns are released as soon as
@@ -453,7 +452,6 @@ static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
  * svc_rdma_post_send_wr - Set up and post one Send Work Request
  * @rdma: controlling transport
  * @ctxt: op_ctxt for transmitting the Send WR
- * @num_sge: number of SGEs to send
  * @inv_rkey: R_key argument to Send With Invalidate, or zero
  *
  * Returns:
@@ -463,18 +461,19 @@ static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
  *	%-ENOMEM if ib_post_send failed.
  */
 int svc_rdma_post_send_wr(struct svcxprt_rdma *rdma,
-			  struct svc_rdma_op_ctxt *ctxt, int num_sge,
+			  struct svc_rdma_op_ctxt *ctxt,
 			  u32 inv_rkey)
 {
 	struct ib_send_wr *send_wr = &ctxt->send_wr;
 
-	dprintk("svcrdma: posting Send WR with %u sge(s)\n", num_sge);
+	dprintk("svcrdma: posting Send WR with %u sge(s)\n",
+		ctxt->mapped_sges);
 
 	send_wr->next = NULL;
 	ctxt->cqe.done = svc_rdma_wc_send;
 	send_wr->wr_cqe = &ctxt->cqe;
 	send_wr->sg_list = ctxt->sge;
-	send_wr->num_sge = num_sge;
+	send_wr->num_sge = ctxt->mapped_sges;
 	send_wr->send_flags = IB_SEND_SIGNALED;
 	if (inv_rkey) {
 		send_wr->opcode = IB_WR_SEND_WITH_INV;
@@ -532,7 +531,7 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
 	inv_rkey = 0;
 	if (rdma->sc_snd_w_inv)
 		inv_rkey = svc_rdma_get_inv_rkey(rdma_argp, wr_lst, rp_ch);
-	ret = svc_rdma_post_send_wr(rdma, ctxt, 1 + ret, inv_rkey);
+	ret = svc_rdma_post_send_wr(rdma, ctxt, inv_rkey);
 	if (ret)
 		goto err;
 
@@ -574,7 +573,7 @@ static int svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
 
 	svc_rdma_save_io_pages(rqstp, ctxt);
 
-	ret = svc_rdma_post_send_wr(rdma, ctxt, 1 + ret, 0);
+	ret = svc_rdma_post_send_wr(rdma, ctxt, 0);
 	if (ret)
 		goto err;
 

