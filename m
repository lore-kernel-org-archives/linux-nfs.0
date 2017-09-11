Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38175 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdIKPQA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Sep 2017 11:16:00 -0400
Subject: [PATCH v1 2/7] xprtrdma: Change return value of
 rpcrdma_prepare_send_sges()
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Sep 2017 11:17:54 -0400
Message-ID: <150514306906.1307.8979554419454501550.stgit@lebasque.1015granger.net>
In-Reply-To: <150514269466.1307.1991885208569456320.stgit@lebasque.1015granger.net>
References: <150514269466.1307.1991885208569456320.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Make rpcrdma_prepare_send_sges() return a negative errno
instead of a bool. Soon callers will want distinct treatments of
different types of failures.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    6 +++-
 net/sunrpc/xprtrdma/rpc_rdma.c    |   52 +++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    6 +++-
 3 files changed, 40 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index d31d0ac..90a0438 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -206,6 +206,7 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	__be32 *p;
+	int rc;
 
 	rpcrdma_set_xdrlen(&req->rl_hdrbuf, 0);
 	xdr_init_encode(&req->rl_stream, &req->rl_hdrbuf,
@@ -222,8 +223,9 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 	*p++ = xdr_zero;
 	*p = xdr_zero;
 
-	if (!rpcrdma_prepare_send_sges(&r_xprt->rx_ia, req, RPCRDMA_HDRLEN_MIN,
-				       &rqst->rq_snd_buf, rpcrdma_noch))
+	rc = rpcrdma_prepare_send_sges(r_xprt, req, RPCRDMA_HDRLEN_MIN,
+				       &rqst->rq_snd_buf, rpcrdma_noch);
+	if (rc)
 		return -EIO;
 	return 0;
 }
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index bc464b1..0db7ba0 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -522,7 +522,7 @@ rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 
 	if (unlikely(!rpcrdma_regbuf_is_mapped(rb))) {
 		if (!__rpcrdma_dma_map_regbuf(ia, rb))
-			return false;
+			goto out_regbuf;
 		sge->addr = rdmab_addr(rb);
 		sge->lkey = rdmab_lkey(rb);
 	}
@@ -532,6 +532,10 @@ rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 				      sge->length, DMA_TO_DEVICE);
 	req->rl_send_wr.num_sge++;
 	return true;
+
+out_regbuf:
+	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
+	return false;
 }
 
 /* Prepare the Send SGEs. The head and tail iovec, and each entry
@@ -552,7 +556,7 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 	 * DMA-mapped. Sync the content that has changed.
 	 */
 	if (!rpcrdma_dma_map_regbuf(ia, rb))
-		return false;
+		goto out_regbuf;
 	sge_no = 1;
 	sge[sge_no].addr = rdmab_addr(rb);
 	sge[sge_no].length = xdr->head[0].iov_len;
@@ -639,6 +643,10 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 	req->rl_mapped_sges = sge_no - 1;
 	return true;
 
+out_regbuf:
+	pr_err("rpcrdma: failed to DMA map a Send buffer\n");
+	return false;
+
 out_mapping_overflow:
 	pr_err("rpcrdma: too many Send SGEs (%u)\n", sge_no);
 	return false;
@@ -648,25 +656,31 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
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
 
 void
@@ -833,12 +847,10 @@ rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst)
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
index 45dab24..93f3a36 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -640,8 +640,10 @@ enum rpcrdma_chunktype {
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

