Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34786 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014AbbGIUnJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:43:09 -0400
Subject: [PATCH v1 09/12] xprtrdma: Prepare rpcrdma_ep_post() for RDMA_NOMSG
 calls
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 09 Jul 2015 16:43:05 -0400
Message-ID: <20150709204305.26247.39173.stgit@manet.1015granger.net>
In-Reply-To: <20150709203242.26247.4848.stgit@manet.1015granger.net>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only the RPC/RDMA header is sent when making an RDMA_NOMSG call.
That header resides in the first element of the iovec array
passed to rpcrdma_ep_post().

Instead of special casing the iovec element with the pad, just
sync all the elements in the send iovec. Syncing the zero pad is
not strictly necessary, but the pad is rarely if ever used these
days, and the extra cost in that case is small.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 ++++
 net/sunrpc/xprtrdma/verbs.c     |   27 +++++++++++----------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   18 ++++++++++--------
 3 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index cb05233..2e721f2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -575,6 +575,10 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	req->rl_send_iov[0].length = hdrlen;
 	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
 
+	req->rl_niovs = 1;
+	if (rtype == rpcrdma_areadch)
+		return 0;
+
 	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
 	req->rl_send_iov[1].length = rpclen;
 	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cdf5220..9199436 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -651,7 +651,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	if (rc)
 		return rc;
 	ep->rep_attr.cap.max_recv_wr = cdata->max_requests;
-	ep->rep_attr.cap.max_send_sge = (cdata->padding ? 4 : 2);
+	ep->rep_attr.cap.max_send_sge = RPCRDMA_MAX_IOVS;
 	ep->rep_attr.cap.max_recv_sge = 1;
 	ep->rep_attr.cap.max_inline_data = 0;
 	ep->rep_attr.sq_sig_type = IB_SIGNAL_REQ_WR;
@@ -1303,9 +1303,11 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
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
@@ -1316,22 +1318,15 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 
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
index ce4e79e..90da480 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -256,16 +256,18 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 	char		*mr_offset;	/* kva if no page, else offset */
 };
 
+#define RPCRDMA_MAX_IOVS	(4)
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

