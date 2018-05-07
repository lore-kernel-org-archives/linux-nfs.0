Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:56208 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752721AbeEGT2R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:28:17 -0400
Subject: [PATCH v1 16/19] svcrdma: Remove post_send_wr
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:28:15 -0400
Message-ID: <20180507192815.4608.24419.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Now that the send_wr is part of the svc_rdma_send_ctxt,
svc_rdma_post_send_wr is nearly empty.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h            |    3 --
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    3 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |    3 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   47 +++++++---------------------
 4 files changed, 16 insertions(+), 40 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index bfb8824..a8bfc21 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -202,9 +202,6 @@ extern void svc_rdma_send_ctxt_put(struct svcxprt_rdma *rdma,
 extern int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
 				  struct svc_rdma_send_ctxt *ctxt,
 				  __be32 *rdma_resp, unsigned int len);
-extern int svc_rdma_post_send_wr(struct svcxprt_rdma *rdma,
-				 struct svc_rdma_send_ctxt *ctxt,
-				 u32 inv_rkey);
 extern int svc_rdma_sendto(struct svc_rqst *);
 
 /* svc_rdma_transport.c */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 95e3351..40f5e4a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -139,7 +139,8 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	 * the rq_buffer before all retransmits are complete.
 	 */
 	get_page(virt_to_page(rqst->rq_buffer));
-	ret = svc_rdma_post_send_wr(rdma, ctxt, 0);
+	ctxt->sc_send_wr.opcode = IB_WR_SEND;
+	ret = svc_rdma_send(rdma, &ctxt->sc_send_wr);
 	if (ret)
 		goto out_unmap;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 2d1e0db..68648e6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -642,7 +642,8 @@ static void svc_rdma_send_error(struct svcxprt_rdma *xprt,
 		return;
 	}
 
-	ret = svc_rdma_post_send_wr(xprt, ctxt, 0);
+	ctxt->sc_send_wr.opcode = IB_WR_SEND;
+	ret = svc_rdma_send(xprt, &ctxt->sc_send_wr);
 	if (ret)
 		svc_rdma_send_ctxt_put(xprt, ctxt);
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 53d8db6..0ebdc0c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -630,35 +630,6 @@ static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
 	rqstp->rq_next_page = rqstp->rq_respages + 1;
 }
 
-/**
- * svc_rdma_post_send_wr - Set up and post one Send Work Request
- * @rdma: controlling transport
- * @ctxt: op_ctxt for transmitting the Send WR
- * @inv_rkey: R_key argument to Send With Invalidate, or zero
- *
- * Returns:
- *	%0 if the Send* was posted successfully,
- *	%-ENOTCONN if the connection was lost or dropped,
- *	%-EINVAL if there was a problem with the Send we built,
- *	%-ENOMEM if ib_post_send failed.
- */
-int svc_rdma_post_send_wr(struct svcxprt_rdma *rdma,
-			  struct svc_rdma_send_ctxt *ctxt,
-			  u32 inv_rkey)
-{
-	dprintk("svcrdma: posting Send WR with %u sge(s)\n",
-		ctxt->sc_send_wr.num_sge);
-
-	if (inv_rkey) {
-		ctxt->sc_send_wr.opcode = IB_WR_SEND_WITH_INV;
-		ctxt->sc_send_wr.ex.invalidate_rkey = inv_rkey;
-	} else {
-		ctxt->sc_send_wr.opcode = IB_WR_SEND;
-	}
-
-	return svc_rdma_send(rdma, &ctxt->sc_send_wr);
-}
-
 /* Prepare the portion of the RPC Reply that will be transmitted
  * via RDMA Send. The RPC-over-RDMA transport header is prepared
  * in sc_sges[0], and the RPC xdr_buf is prepared in following sges.
@@ -683,7 +654,6 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
 				   __be32 *wr_lst, __be32 *rp_ch)
 {
 	struct svc_rdma_send_ctxt *ctxt;
-	u32 inv_rkey;
 	int ret;
 
 	ctxt = svc_rdma_send_ctxt_get(rdma);
@@ -704,10 +674,16 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
 
 	svc_rdma_save_io_pages(rqstp, ctxt);
 
-	inv_rkey = 0;
-	if (rdma->sc_snd_w_inv)
-		inv_rkey = svc_rdma_get_inv_rkey(rdma_argp, wr_lst, rp_ch);
-	ret = svc_rdma_post_send_wr(rdma, ctxt, inv_rkey);
+	ctxt->sc_send_wr.opcode = IB_WR_SEND;
+	if (rdma->sc_snd_w_inv) {
+		ctxt->sc_send_wr.ex.invalidate_rkey =
+			svc_rdma_get_inv_rkey(rdma_argp, wr_lst, rp_ch);
+		if (ctxt->sc_send_wr.ex.invalidate_rkey)
+			ctxt->sc_send_wr.opcode = IB_WR_SEND_WITH_INV;
+	}
+	dprintk("svcrdma: posting Send WR with %u sge(s)\n",
+		ctxt->sc_send_wr.num_sge);
+	ret = svc_rdma_send(rdma, &ctxt->sc_send_wr);
 	if (ret)
 		goto err;
 
@@ -750,7 +726,8 @@ static int svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
 
 	svc_rdma_save_io_pages(rqstp, ctxt);
 
-	ret = svc_rdma_post_send_wr(rdma, ctxt, 0);
+	ctxt->sc_send_wr.opcode = IB_WR_SEND;
+	ret = svc_rdma_send(rdma, &ctxt->sc_send_wr);
 	if (ret)
 		goto err;
 

