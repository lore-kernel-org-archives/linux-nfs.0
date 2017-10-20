Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:54797 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbdJTOr5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2017 10:47:57 -0400
Subject: [PATCH 3/9] xprtrdma: Change return value of
 rpcrdma_prepare_send_sges()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 20 Oct 2017 10:47:55 -0400
Message-ID: <20171020144755.14869.64770.stgit@manet.1015granger.net>
In-Reply-To: <20171020143635.14869.15714.stgit@manet.1015granger.net>
References: <20171020143635.14869.15714.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Make rpcrdma_prepare_send_sges() return a negative errno
instead of a bool. Soon callers will want distinct treatments of
different types of failures.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    4 +--
 net/sunrpc/xprtrdma/rpc_rdma.c    |   52 +++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    6 +++-
 3 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index d31d0ac..f0d5998 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -222,8 +222,8 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 	*p++ = xdr_zero;
 	*p = xdr_zero;
 
-	if (!rpcrdma_prepare_send_sges(&r_xprt->rx_ia, req, RPCRDMA_HDRLEN_MIN,
-				       &rqst->rq_snd_buf, rpcrdma_noch))
+	if (rpcrdma_prepare_send_sges(r_xprt, req, RPCRDMA_HDRLEN_MIN,
+				      &rqst->rq_snd_buf, rpcrdma_noch))
 		return -EIO;
 	return 0;
 }
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 4f6c539..e3ece98 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -544,7 +544,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	if (unlikely(!rpcrdma_regbuf_is_mapped(rb))) {
 		if (!__rpcrdma_dma_map_regbuf(ia, rb))
-			return false;
+			goto out_regbuf;
 		sge->addr = rdmab_addr(rb);
 		sge->lkey = rdmab_lkey(rb);
 	}
@@ -554,6 +554,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 				      sge->length, DMA_TO_DEVICE);
 	req->rl_send_wr.num_sge++;
 	return true;
+
+out_regbuf:
+	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
+	return false;
 }
 
 /* Prepare the Send SGEs. The head and tail iovec, and each entry
@@ -574,7 +578,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	 * DMA-mapped. Sync the content that has changed.
 	 */
 	if (!rpcrdma_dma_map_regbuf(ia, rb))
-		return false;
+		goto out_regbuf;
 	sge_no = 1;
 	sge[sge_no].addr = rdmab_addr(rb);
 	sge[sge_no].length = xdr->head[0].iov_len;
@@ -662,6 +666,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	req->rl_send_wr.num_sge += sge_no;
 	return true;
 
+out_regbuf:
+	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
+	return false;
+
 out_mapping_overflow:
 	rpcrdma_unmap_sges(ia, req);
 	pr_err("rpcrdma: too many Send SGEs (%u)\n", sge_no);
@@ -673,26 +681,32 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	return false;
 }
 
-bool
-rpcrdma_prepare_send_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
-			  u32 hdrlen, struct xdr_buf *xdr,
-			  enum rpcrdma_chunktype rtype)
+/**
+ * rpcrdma_prepare_send_sges - Construct SGEs for a Send WR
+ * @r_xprt: controlling transport
+ * @req: context of RPC Call being marshalled
+ * @hdrlen: size of transport header, in bytes
+ * @xdr: xdr_buf containing RPC Call
+ * @rtype: chunk type being encoded
+ *
+ * Returns 0 on success; otherwise a negative errno is returned.
+ */
+int
+rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
+			  struct rpcrdma_req *req, u32 hdrlen,
+			  struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
 {
 	req->rl_send_wr.num_sge = 0;
 	req->rl_mapped_sges = 0;
 
-	if (!rpcrdma_prepare_hdr_sge(ia, req, hdrlen))
-		goto out_map;
+	if (!rpcrdma_prepare_hdr_sge(&r_xprt->rx_ia, req, hdrlen))
+		return -EIO;
 
 	if (rtype != rpcrdma_areadch)
-		if (!rpcrdma_prepare_msg_sges(ia, req, xdr, rtype))
-			goto out_map;
-
-	return true;
+		if (!rpcrdma_prepare_msg_sges(&r_xprt->rx_ia, req, xdr, rtype))
+			return -EIO;
 
-out_map:
-	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
-	return false;
+	return 0;
 }
 
 /**
@@ -843,12 +857,10 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		transfertypes[rtype], transfertypes[wtype],
 		xdr_stream_pos(xdr));
 
-	if (!rpcrdma_prepare_send_sges(&r_xprt->rx_ia, req,
-				       xdr_stream_pos(xdr),
-				       &rqst->rq_snd_buf, rtype)) {
-		ret = -EIO;
+	ret = rpcrdma_prepare_send_sges(r_xprt, req, xdr_stream_pos(xdr),
+					&rqst->rq_snd_buf, rtype);
+	if (ret)
 		goto out_err;
-	}
 	return 0;
 
 out_err:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0e0ae61..0b8ca5e 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -613,8 +613,10 @@ enum rpcrdma_chunktype {
 	rpcrdma_replych
 };
 
-bool rpcrdma_prepare_send_sges(struct rpcrdma_ia *, struct rpcrdma_req *,
-			       u32, struct xdr_buf *, enum rpcrdma_chunktype);
+int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
+			      struct rpcrdma_req *req, u32 hdrlen,
+			      struct xdr_buf *xdr,
+			      enum rpcrdma_chunktype rtype);
 void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);

