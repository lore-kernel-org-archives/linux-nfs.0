Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36315 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752877AbcHWRy3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 13:54:29 -0400
Subject: [PATCH v2 13/22] xprtrdma: Move send_wr to struct rpcrdma_req
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 Aug 2016 13:53:50 -0400
Message-ID: <20160823175350.13038.83307.stgit@manet.1015granger.net>
In-Reply-To: <20160823174402.13038.84561.stgit@manet.1015granger.net>
References: <20160823174402.13038.84561.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Most of the fields in each send_wr do not vary. There is
no need to initialize them before each ib_post_send(). This removes
a large-ish data structure from the stack.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    3 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c    |    5 +++--
 net/sunrpc/xprtrdma/verbs.c       |   36 +++++++++++++++++-------------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    4 ++--
 4 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 887ef44..61a58f5 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -241,7 +241,8 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 	req->rl_send_iov[1].length = rpclen;
 	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
 
-	req->rl_niovs = 2;
+	req->rl_send_wr.num_sge = 2;
+
 	return 0;
 
 out_map:
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6187cee..c2906e3 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -687,7 +687,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	req->rl_send_iov[0].length = hdrlen;
 	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
 
-	req->rl_niovs = 1;
+	req->rl_send_wr.num_sge = 1;
 	if (rtype == rpcrdma_areadch)
 		return 0;
 
@@ -697,7 +697,8 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	req->rl_send_iov[1].length = rpclen;
 	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);
 
-	req->rl_niovs = 2;
+	req->rl_send_wr.num_sge = 2;
+
 	return 0;
 
 out_overflow:
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 81cae65..d5e88ee 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -848,6 +848,10 @@ rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 	req->rl_cqe.done = rpcrdma_wc_send;
 	req->rl_buffer = &r_xprt->rx_buf;
 	INIT_LIST_HEAD(&req->rl_registered);
+	req->rl_send_wr.next = NULL;
+	req->rl_send_wr.wr_cqe = &req->rl_cqe;
+	req->rl_send_wr.sg_list = req->rl_send_iov;
+	req->rl_send_wr.opcode = IB_WR_SEND;
 	return req;
 }
 
@@ -1112,7 +1116,7 @@ rpcrdma_buffer_put(struct rpcrdma_req *req)
 	struct rpcrdma_buffer *buffers = req->rl_buffer;
 	struct rpcrdma_rep *rep = req->rl_reply;
 
-	req->rl_niovs = 0;
+	req->rl_send_wr.num_sge = 0;
 	req->rl_reply = NULL;
 
 	spin_lock(&buffers->rb_lock);
@@ -1240,38 +1244,32 @@ rpcrdma_ep_post(struct rpcrdma_ia *ia,
 		struct rpcrdma_req *req)
 {
 	struct ib_device *device = ia->ri_device;
-	struct ib_send_wr send_wr, *send_wr_fail;
-	struct rpcrdma_rep *rep = req->rl_reply;
-	struct ib_sge *iov = req->rl_send_iov;
+	struct ib_send_wr *send_wr = &req->rl_send_wr;
+	struct ib_send_wr *send_wr_fail;
+	struct ib_sge *sge = req->rl_send_iov;
 	int i, rc;
 
-	if (rep) {
-		rc = rpcrdma_ep_post_recv(ia, rep);
+	if (req->rl_reply) {
+		rc = rpcrdma_ep_post_recv(ia, req->rl_reply);
 		if (rc)
 			return rc;
 		req->rl_reply = NULL;
 	}
 
-	send_wr.next = NULL;
-	send_wr.wr_cqe = &req->rl_cqe;
-	send_wr.sg_list = iov;
-	send_wr.num_sge = req->rl_niovs;
-	send_wr.opcode = IB_WR_SEND;
-
-	for (i = 0; i < send_wr.num_sge; i++)
-		ib_dma_sync_single_for_device(device, iov[i].addr,
-					      iov[i].length, DMA_TO_DEVICE);
+	for (i = 0; i < send_wr->num_sge; i++)
+		ib_dma_sync_single_for_device(device, sge[i].addr,
+					      sge[i].length, DMA_TO_DEVICE);
 	dprintk("RPC:       %s: posting %d s/g entries\n",
-		__func__, send_wr.num_sge);
+		__func__, send_wr->num_sge);
 
 	if (DECR_CQCOUNT(ep) > 0)
-		send_wr.send_flags = 0;
+		send_wr->send_flags = 0;
 	else { /* Provider must take a send completion every now and then */
 		INIT_CQCOUNT(ep);
-		send_wr.send_flags = IB_SEND_SIGNALED;
+		send_wr->send_flags = IB_SEND_SIGNALED;
 	}
 
-	rc = ib_post_send(ia->ri_id->qp, &send_wr, &send_wr_fail);
+	rc = ib_post_send(ia->ri_id->qp, send_wr, &send_wr_fail);
 	if (rc)
 		goto out_postsend_err;
 	return 0;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 44efff7..a6a0336 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -284,10 +284,10 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_free;
-	unsigned int		rl_niovs;
 	unsigned int		rl_connect_cookie;
 	struct rpcrdma_buffer	*rl_buffer;
-	struct rpcrdma_rep	*rl_reply;/* holder for reply buffer */
+	struct rpcrdma_rep	*rl_reply;
+	struct ib_send_wr	rl_send_wr;
 	struct ib_sge		rl_send_iov[RPCRDMA_MAX_IOVS];
 	struct rpcrdma_regbuf	*rl_rdmabuf;	/* xprt header */
 	struct rpcrdma_regbuf	*rl_sendbuf;	/* rq_snd_buf */

