Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36568 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbcD1POz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 11:14:55 -0400
Subject: [PATCH 03/10] svcrdma: svc_rdma_put_context() is invoked twice in
 Send error path
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 28 Apr 2016 11:14:53 -0400
Message-ID: <20160428151453.13068.6748.stgit@klimt.1015granger.net>
In-Reply-To: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
References: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get a fresh op_ctxt in send_reply() instead of in svc_rdma_sendto().
This ensures that svc_rdma_put_context() is invoked only once if
send_reply() fails.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 4f1b1c4..54d53330 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -463,25 +463,21 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		      struct svc_rqst *rqstp,
 		      struct page *page,
 		      struct rpcrdma_msg *rdma_resp,
-		      struct svc_rdma_op_ctxt *ctxt,
 		      struct svc_rdma_req_map *vec,
 		      int byte_count)
 {
+	struct svc_rdma_op_ctxt *ctxt;
 	struct ib_send_wr send_wr;
 	u32 xdr_off;
 	int sge_no;
 	int sge_bytes;
 	int page_no;
 	int pages;
-	int ret;
-
-	ret = svc_rdma_repost_recv(rdma, GFP_KERNEL);
-	if (ret) {
-		svc_rdma_put_context(ctxt, 0);
-		return -ENOTCONN;
-	}
+	int ret = -EIO;
 
 	/* Prepare the context */
+	ctxt = svc_rdma_get_context(rdma);
+	ctxt->direction = DMA_TO_DEVICE;
 	ctxt->pages[0] = page;
 	ctxt->count = 1;
 
@@ -565,8 +561,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
  err:
 	svc_rdma_unmap_dma(ctxt);
 	svc_rdma_put_context(ctxt, 1);
-	pr_err("svcrdma: failed to send reply, rc=%d\n", ret);
-	return -EIO;
+	return ret;
 }
 
 void svc_rdma_prep_reply_hdr(struct svc_rqst *rqstp)
@@ -585,7 +580,6 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	int ret;
 	int inline_bytes;
 	struct page *res_page;
-	struct svc_rdma_op_ctxt *ctxt;
 	struct svc_rdma_req_map *vec;
 
 	dprintk("svcrdma: sending response for rqstp=%p\n", rqstp);
@@ -598,8 +592,6 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	rp_ary = svc_rdma_get_reply_array(rdma_argp, wr_ary);
 
 	/* Build an req vec for the XDR */
-	ctxt = svc_rdma_get_context(rdma);
-	ctxt->direction = DMA_TO_DEVICE;
 	vec = svc_rdma_get_req_map(rdma);
 	ret = svc_rdma_map_xdr(rdma, &rqstp->rq_res, vec, wr_ary != NULL);
 	if (ret)
@@ -635,7 +627,12 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		inline_bytes -= ret;
 	}
 
-	ret = send_reply(rdma, rqstp, res_page, rdma_resp, ctxt, vec,
+	/* Post a fresh Receive buffer _before_ sending the reply */
+	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
+	if (ret)
+		goto err1;
+
+	ret = send_reply(rdma, rqstp, res_page, rdma_resp, vec,
 			 inline_bytes);
 	if (ret < 0)
 		goto err1;
@@ -648,7 +645,8 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	put_page(res_page);
  err0:
 	svc_rdma_put_req_map(rdma, vec);
-	svc_rdma_put_context(ctxt, 0);
+	pr_err("svcrdma: Could not send reply, err=%d. Closing transport.\n",
+	       ret);
 	set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
 	return -ENOTCONN;
 }

