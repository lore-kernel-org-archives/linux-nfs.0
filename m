Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:34154 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295AbbGTTDd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 15:03:33 -0400
Subject: [PATCH v3 07/15] xprtrdma: Remove logic that constructs RDMA_MSGP
 type calls
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jul 2015 15:03:30 -0400
Message-ID: <20150720190329.10997.97193.stgit@manet.1015granger.net>
In-Reply-To: <20150720185624.10997.51574.stgit@manet.1015granger.net>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RDMA_MSGP type calls insert a zero pad in the middle of the RPC
message to align the RPC request's data payload to the server's
alignment preferences. A server can then "page flip" the payload
into place to avoid a data copy in certain circumstances. However:

1. The client has to have a priori knowledge of the server's
   preferred alignment

2. Requests eligible for RDMA_MSGP are requests that are small
   enough to have been sent inline, and convey a data payload
   at the _end_ of the RPC message

Today 1. is done with a sysctl, and is a global setting that is
copied during mount. Linux does not support CCP to query the
server's preferences (RFC 5666, Section 6).

A small-ish NFSv3 WRITE might use RDMA_MSGP, but no NFSv4
compound fits bullet 2.

Thus the Linux client currently leaves RDMA_MSGP disabled. The
Linux server handles RDMA_MSGP, but does not use any special
page flipping, so it confers no benefit.

Clean up the marshaling code by removing the logic that constructs
RDMA_MSGP type calls. This also reduces the maximum send iovec size
from four to just two elements.

/proc/sys/sunrpc/rdma_inline_write_padding is a kernel API, and
thus is left in place.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   92 ++++++++++-----------------------------
 net/sunrpc/xprtrdma/verbs.c     |   47 +++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   19 ++++----
 3 files changed, 51 insertions(+), 107 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 84ea37d..8e9c564 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -297,8 +297,7 @@ out:
  * pre-registered memory buffer for this request. For small amounts
  * of data, this is efficient. The cutoff value is tunable.
  */
-static int
-rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
+static void rpcrdma_inline_pullup(struct rpc_rqst *rqst)
 {
 	int i, npages, curlen;
 	int copy_len;
@@ -310,16 +309,9 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 	destp = rqst->rq_svec[0].iov_base;
 	curlen = rqst->rq_svec[0].iov_len;
 	destp += curlen;
-	/*
-	 * Do optional padding where it makes sense. Alignment of write
-	 * payload can help the server, if our setting is accurate.
-	 */
-	pad -= (curlen + 36/*sizeof(struct rpcrdma_msg_padded)*/);
-	if (pad < 0 || rqst->rq_slen - curlen < RPCRDMA_INLINE_PAD_THRESH)
-		pad = 0;	/* don't pad this request */
 
-	dprintk("RPC:       %s: pad %d destp 0x%p len %d hdrlen %d\n",
-		__func__, pad, destp, rqst->rq_slen, curlen);
+	dprintk("RPC:       %s: destp 0x%p len %d hdrlen %d\n",
+		__func__, destp, rqst->rq_slen, curlen);
 
 	copy_len = rqst->rq_snd_buf.page_len;
 
@@ -355,7 +347,6 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 		page_base = 0;
 	}
 	/* header now contains entire send message */
-	return pad;
 }
 
 /*
@@ -380,7 +371,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	char *base;
-	size_t rpclen, padlen;
+	size_t rpclen;
 	ssize_t hdrlen;
 	enum rpcrdma_chunktype rtype, wtype;
 	struct rpcrdma_msg *headerp;
@@ -458,7 +449,6 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	}
 
 	hdrlen = RPCRDMA_HDRLEN_MIN;
-	padlen = 0;
 
 	/*
 	 * Pull up any extra send data into the preregistered buffer.
@@ -467,43 +457,24 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 */
 	if (rtype == rpcrdma_noch) {
 
-		padlen = rpcrdma_inline_pullup(rqst,
-						RPCRDMA_INLINE_PAD_VALUE(rqst));
-
-		if (padlen) {
-			headerp->rm_type = rdma_msgp;
-			headerp->rm_body.rm_padded.rm_align =
-				cpu_to_be32(RPCRDMA_INLINE_PAD_VALUE(rqst));
-			headerp->rm_body.rm_padded.rm_thresh =
-				cpu_to_be32(RPCRDMA_INLINE_PAD_THRESH);
-			headerp->rm_body.rm_padded.rm_pempty[0] = xdr_zero;
-			headerp->rm_body.rm_padded.rm_pempty[1] = xdr_zero;
-			headerp->rm_body.rm_padded.rm_pempty[2] = xdr_zero;
-			hdrlen += 2 * sizeof(u32); /* extra words in padhdr */
-			if (wtype != rpcrdma_noch) {
-				dprintk("RPC:       %s: invalid chunk list\n",
-					__func__);
-				return -EIO;
-			}
-		} else {
-			headerp->rm_body.rm_nochunks.rm_empty[0] = xdr_zero;
-			headerp->rm_body.rm_nochunks.rm_empty[1] = xdr_zero;
-			headerp->rm_body.rm_nochunks.rm_empty[2] = xdr_zero;
-			/* new length after pullup */
-			rpclen = rqst->rq_svec[0].iov_len;
-			/*
-			 * Currently we try to not actually use read inline.
-			 * Reply chunks have the desirable property that
-			 * they land, packed, directly in the target buffers
-			 * without headers, so they require no fixup. The
-			 * additional RDMA Write op sends the same amount
-			 * of data, streams on-the-wire and adds no overhead
-			 * on receive. Therefore, we request a reply chunk
-			 * for non-writes wherever feasible and efficient.
-			 */
-			if (wtype == rpcrdma_noch)
-				wtype = rpcrdma_replych;
-		}
+		rpcrdma_inline_pullup(rqst);
+
+		headerp->rm_body.rm_nochunks.rm_empty[0] = xdr_zero;
+		headerp->rm_body.rm_nochunks.rm_empty[1] = xdr_zero;
+		headerp->rm_body.rm_nochunks.rm_empty[2] = xdr_zero;
+		/* new length after pullup */
+		rpclen = rqst->rq_svec[0].iov_len;
+		/* Currently we try to not actually use read inline.
+		 * Reply chunks have the desirable property that
+		 * they land, packed, directly in the target buffers
+		 * without headers, so they require no fixup. The
+		 * additional RDMA Write op sends the same amount
+		 * of data, streams on-the-wire and adds no overhead
+		 * on receive. Therefore, we request a reply chunk
+		 * for non-writes wherever feasible and efficient.
+		 */
+		if (wtype == rpcrdma_noch)
+			wtype = rpcrdma_replych;
 	}
 
 	if (rtype != rpcrdma_noch) {
@@ -518,9 +489,9 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	if (hdrlen < 0)
 		return hdrlen;
 
-	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd padlen %zd"
+	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd"
 		" headerp 0x%p base 0x%p lkey 0x%x\n",
-		__func__, transfertypes[wtype], hdrlen, rpclen, padlen,
+		__func__, transfertypes[wtype], hdrlen, rpclen,
 		headerp, base, rdmab_lkey(req->rl_rdmabuf));
 
 	/*
@@ -539,21 +510,6 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
 
 	req->rl_niovs = 2;
-
-	if (padlen) {
-		struct rpcrdma_ep *ep = &r_xprt->rx_ep;
-
-		req->rl_send_iov[2].addr = rdmab_addr(ep->rep_padbuf);
-		req->rl_send_iov[2].length = padlen;
-		req->rl_send_iov[2].lkey = rdmab_lkey(ep->rep_padbuf);
-
-		req->rl_send_iov[3].addr = req->rl_send_iov[1].addr + rpclen;
-		req->rl_send_iov[3].length = rqst->rq_slen - rpclen;
-		req->rl_send_iov[3].lkey = rdmab_lkey(req->rl_sendbuf);
-
-		req->rl_niovs = 4;
-	}
-
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 8516d98..b4d4f63 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -605,6 +605,12 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	struct ib_cq_init_attr cq_attr = {};
 	int rc, err;
 
+	if (devattr->max_sge < RPCRDMA_MAX_IOVS) {
+		dprintk("RPC:       %s: insufficient sge's available\n",
+			__func__);
+		return -ENOMEM;
+	}
+
 	/* check provider's send/recv wr limits */
 	if (cdata->max_requests > devattr->max_qp_wr)
 		cdata->max_requests = devattr->max_qp_wr;
@@ -617,23 +623,13 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	if (rc)
 		return rc;
 	ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
-	ep->rep_attr.cap.max_send_sge = (cdata->padding ? 4 : 2);
+	ep->rep_attr.cap.max_send_sge = RPCRDMA_MAX_IOVS;
 	ep->rep_attr.cap.max_recv_sge = 1;
 	ep->rep_attr.cap.max_inline_data = 0;
 	ep->rep_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
 	ep->rep_attr.qp_type = IB_QPT_RC;
 	ep->rep_attr.port_num = ~0;
 
-	if (cdata->padding) {
-		ep->rep_padbuf = rpcrdma_alloc_regbuf(ia, cdata->padding,
-						      GFP_KERNEL);
-		if (IS_ERR(ep->rep_padbuf)) {
-			rc = PTR_ERR(ep->rep_padbuf);
-			goto out0;
-		}
-	} else
-		ep->rep_padbuf = NULL;
-
 	dprintk("RPC:       %s: requested max: dtos: send %d recv %d; "
 		"iovs: send %d recv %d\n",
 		__func__,
@@ -716,8 +712,6 @@ out2:
 		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
 			__func__, err);
 out1:
-	rpcrdma_free_regbuf(ia, ep->rep_padbuf);
-out0:
 	if (ia->ri_dma_mr)
 		ib_dereg_mr(ia->ri_dma_mr);
 	return rc;
@@ -746,8 +740,6 @@ rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 		ia->ri_id->qp = NULL;
 	}
 
-	rpcrdma_free_regbuf(ia, ep->rep_padbuf);
-
 	rpcrdma_clean_cq(ep->rep_attr.recv_cq);
 	rc = ib_destroy_cq(ep->rep_attr.recv_cq);
 	if (rc)
@@ -1279,9 +1271,11 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 		struct rpcrdma_ep *ep,
 		struct rpcrdma_req *req)
 {
+	struct ib_device *device = ia->ri_device;
 	struct ib_send_wr send_wr, *send_wr_fail;
 	struct rpcrdma_rep *rep = req->rl_reply;
-	int rc;
+	struct ib_sge *iov = req->rl_send_iov;
+	int i, rc;
 
 	if (rep) {
 		rc = rpcrdma_ep_post_recv(ia, ep, rep);
@@ -1292,22 +1286,15 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 
 	send_wr.next = NULL;
 	send_wr.wr_id = RPCRDMA_IGNORE_COMPLETION;
-	send_wr.sg_list = req->rl_send_iov;
+	send_wr.sg_list = iov;
 	send_wr.num_sge = req->rl_niovs;
 	send_wr.opcode = IB_WR_SEND;
-	if (send_wr.num_sge == 4)	/* no need to sync any pad (constant) */
-		ib_dma_sync_single_for_device(ia->ri_device,
-					      req->rl_send_iov[3].addr,
-					      req->rl_send_iov[3].length,
-					      DMA_TO_DEVICE);
-	ib_dma_sync_single_for_device(ia->ri_device,
-				      req->rl_send_iov[1].addr,
-				      req->rl_send_iov[1].length,
-				      DMA_TO_DEVICE);
-	ib_dma_sync_single_for_device(ia->ri_device,
-				      req->rl_send_iov[0].addr,
-				      req->rl_send_iov[0].length,
-				      DMA_TO_DEVICE);
+
+	for (i = 0; i < send_wr.num_sge; i++)
+		ib_dma_sync_single_for_device(device, iov[i].addr,
+					      iov[i].length, DMA_TO_DEVICE);
+	dprintk("RPC:       %s: posting %d s/g entries\n",
+		__func__, send_wr.num_sge);
 
 	if (DECR_CQCOUNT(ep) > 0)
 		send_wr.send_flags = 0;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 8219011..8422c09 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -88,7 +88,6 @@ struct rpcrdma_ep {
 	int			rep_connected;
 	struct ib_qp_init_attr	rep_attr;
 	wait_queue_head_t 	rep_connect_wait;
-	struct rpcrdma_regbuf	*rep_padbuf;
 	struct rdma_conn_param	rep_remote_cma;
 	struct sockaddr_storage	rep_remote_addr;
 	struct delayed_work	rep_connect_worker;
@@ -255,16 +254,18 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 	char		*mr_offset;	/* kva if no page, else offset */
 };
 
+#define RPCRDMA_MAX_IOVS	(2)
+
 struct rpcrdma_req {
-	unsigned int	rl_niovs;	/* 0, 2 or 4 */
-	unsigned int	rl_nchunks;	/* non-zero if chunks */
-	unsigned int	rl_connect_cookie;	/* retry detection */
-	struct rpcrdma_buffer *rl_buffer; /* home base for this structure */
+	unsigned int		rl_niovs;
+	unsigned int		rl_nchunks;
+	unsigned int		rl_connect_cookie;
+	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;/* holder for reply buffer */
-	struct ib_sge	rl_send_iov[4];	/* for active requests */
-	struct rpcrdma_regbuf *rl_rdmabuf;
-	struct rpcrdma_regbuf *rl_sendbuf;
-	struct rpcrdma_mr_seg rl_segments[RPCRDMA_MAX_SEGS];
+	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
+	struct rpcrdma_regbuf	*rl_rdmabuf;
+	struct rpcrdma_regbuf	*rl_sendbuf;
+	struct rpcrdma_mr_seg	rl_segments[RPCRDMA_MAX_SEGS];
 };
 
 static inline struct rpcrdma_req *

