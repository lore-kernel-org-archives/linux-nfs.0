Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36825 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941503AbdAGRQk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2017 12:16:40 -0500
Subject: [PATCH v1 10/22] svcrdma: Backchannel sendto clean up
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 07 Jan 2017 12:16:38 -0500
Message-ID: <20170107171638.14126.70835.stgit@klimt.1015granger.net>
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The backchannel uses part of the sendto path to transmit callback
requests to clients. Refactor svc_rdma_bc_send_request to use the
new APIs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h            |    2 -
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   56 +++++++----------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   68 ----------------------------
 3 files changed, 16 insertions(+), 110 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 765f91b..ea7867a 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -246,8 +246,6 @@ extern int svc_rdma_send_reply_chunk(struct svcxprt_rdma *rdma,
 				     struct xdr_buf *xdr);
 
 /* svc_rdma_sendto.c */
-extern int svc_rdma_map_xdr(struct svcxprt_rdma *, struct xdr_buf *,
-			    struct svc_rdma_req_map *, bool);
 extern int svc_rdma_map_reply_hdr(struct svcxprt_rdma *rdma,
 				  struct svc_rdma_op_ctxt *ctxt,
 				  __be32 *rdma_resp, unsigned int len);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 288e35c..7d49545 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -89,9 +89,9 @@ int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt, struct rpcrdma_msg *rmsgp,
  * Caller holds the connection's mutex and has already marshaled
  * the RPC/RDMA request.
  *
- * This is similar to svc_rdma_reply, but takes an rpc_rqst
- * instead, does not support chunks, and avoids blocking memory
- * allocation.
+ * This is similar to svc_rdma_send_reply_msg, but takes a struct
+ * rpc_rqst instead, does not support chunks, and avoids blocking
+ * memory allocation.
  *
  * XXX: There is still an opportunity to block in svc_rdma_send()
  * if there are no SQ entries to post the Send. This may occur if
@@ -100,60 +100,36 @@ int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt, struct rpcrdma_msg *rmsgp,
 static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 			      struct rpc_rqst *rqst)
 {
-	struct xdr_buf *sndbuf = &rqst->rq_snd_buf;
 	struct svc_rdma_op_ctxt *ctxt;
-	struct svc_rdma_req_map *vec;
-	struct ib_send_wr send_wr;
 	int ret;
 
-	vec = svc_rdma_get_req_map(rdma);
-	ret = svc_rdma_map_xdr(rdma, sndbuf, vec, false);
-	if (ret)
+	ctxt = svc_rdma_get_context(rdma);
+
+	/* rpcrdma_bc_send_request builds the transport header and
+	 * the backchannel RPC message in the same buffer. Thus only
+	 * one SGE is needed to send both.
+	 */
+	ret = svc_rdma_map_reply_hdr(rdma, ctxt, rqst->rq_buffer,
+				     rqst->rq_snd_buf.len);
+	if (ret < 0)
 		goto out_err;
 
 	ret = svc_rdma_repost_recv(rdma, GFP_NOIO);
 	if (ret)
 		goto out_err;
 
-	ctxt = svc_rdma_get_context(rdma);
-	ctxt->pages[0] = virt_to_page(rqst->rq_buffer);
-	ctxt->count = 1;
-
-	ctxt->direction = DMA_TO_DEVICE;
-	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
-	ctxt->sge[0].length = sndbuf->len;
-	ctxt->sge[0].addr =
-	    ib_dma_map_page(rdma->sc_cm_id->device, ctxt->pages[0], 0,
-			    sndbuf->len, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(rdma->sc_cm_id->device, ctxt->sge[0].addr)) {
-		ret = -EIO;
-		goto out_unmap;
-	}
-	svc_rdma_count_mappings(rdma, ctxt);
-
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
+		svc_rdma_unmap_dma(ctxt);
+		svc_rdma_put_context(ctxt, 1);
 		ret = -EIO;
-		goto out_unmap;
 	}
 
 out_err:
-	svc_rdma_put_req_map(rdma, vec);
 	dprintk("svcrdma: %s returns %d\n", __func__, ret);
 	return ret;
 
-out_unmap:
-	svc_rdma_unmap_dma(ctxt);
-	svc_rdma_put_context(ctxt, 1);
-	goto out_err;
 }
 
 /* Server-side transport endpoint wants a whole page for its send
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 555daef..5e75187 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -111,74 +111,6 @@ static u32 xdr_padsize(u32 len)
 	return (len & 3) ? (4 - (len & 3)) : 0;
 }
 
-int svc_rdma_map_xdr(struct svcxprt_rdma *xprt,
-		     struct xdr_buf *xdr,
-		     struct svc_rdma_req_map *vec,
-		     bool write_chunk_present)
-{
-	int sge_no;
-	u32 sge_bytes;
-	u32 page_bytes;
-	u32 page_off;
-	int page_no;
-
-	if (xdr->len !=
-	    (xdr->head[0].iov_len + xdr->page_len + xdr->tail[0].iov_len)) {
-		pr_err("svcrdma: %s: XDR buffer length error\n", __func__);
-		return -EIO;
-	}
-
-	/* Skip the first sge, this is for the RPCRDMA header */
-	sge_no = 1;
-
-	/* Head SGE */
-	vec->sge[sge_no].iov_base = xdr->head[0].iov_base;
-	vec->sge[sge_no].iov_len = xdr->head[0].iov_len;
-	sge_no++;
-
-	/* pages SGE */
-	page_no = 0;
-	page_bytes = xdr->page_len;
-	page_off = xdr->page_base;
-	while (page_bytes) {
-		vec->sge[sge_no].iov_base =
-			page_address(xdr->pages[page_no]) + page_off;
-		sge_bytes = min_t(u32, page_bytes, (PAGE_SIZE - page_off));
-		page_bytes -= sge_bytes;
-		vec->sge[sge_no].iov_len = sge_bytes;
-
-		sge_no++;
-		page_no++;
-		page_off = 0; /* reset for next time through loop */
-	}
-
-	/* Tail SGE */
-	if (xdr->tail[0].iov_len) {
-		unsigned char *base = xdr->tail[0].iov_base;
-		size_t len = xdr->tail[0].iov_len;
-		u32 xdr_pad = xdr_padsize(xdr->page_len);
-
-		if (write_chunk_present && xdr_pad) {
-			base += xdr_pad;
-			len -= xdr_pad;
-		}
-
-		if (len) {
-			vec->sge[sge_no].iov_base = base;
-			vec->sge[sge_no].iov_len = len;
-			sge_no++;
-		}
-	}
-
-	dprintk("svcrdma: %s: sge_no %d page_no %d "
-		"page_base %u page_len %u head_len %zu tail_len %zu\n",
-		__func__, sge_no, page_no, xdr->page_base, xdr->page_len,
-		xdr->head[0].iov_len, xdr->tail[0].iov_len);
-
-	vec->count = sge_no;
-	return 0;
-}
-
 /* Parse the RPC Call's transport header.
  */
 static void svc_rdma_get_write_arrays(__be32 *rdma_argp,

