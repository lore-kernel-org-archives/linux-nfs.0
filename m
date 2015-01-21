Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:44313 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbAUQET (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 11:04:19 -0500
Subject: [PATCH v3 17/20] xprtrdma: Allocate RPC/RDMA send buffer separately
 from struct rpcrdma_req
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 21 Jan 2015 11:04:16 -0500
Message-ID: <20150121160416.17297.71523.stgit@manet.1015granger.net>
In-Reply-To: <20150121155303.17297.47423.stgit@manet.1015granger.net>
References: <20150121155303.17297.47423.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rl_base field is currently the buffer where each RPC/RDMA call
header is built.

The inline threshold is an agreed-on size limit to for RDMA SEND
operations that pass between client and server. The sum of the
RPC/RDMA header size and the RPC header size must be less than or
equal to this threshold.

Increasing the r/wsize maximum will require MAX_SEGS to grow
significantly, but the inline threshold size won't change (both
sides agree on it). The server's inline threshold doesn't change.

Since an RPC/RDMA header can never be larger than the inline
threshold, make all RPC/RDMA header buffers the size of the
inline threshold.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   11 +++++------
 net/sunrpc/xprtrdma/transport.c |    9 +++++++++
 net/sunrpc/xprtrdma/verbs.c     |   22 +++-------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 ++----
 4 files changed, 19 insertions(+), 29 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 8a6bdbd..c1d4a09 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -294,7 +294,7 @@ ssize_t
 rpcrdma_marshal_chunks(struct rpc_rqst *rqst, ssize_t result)
 {
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
-	struct rpcrdma_msg *headerp = (struct rpcrdma_msg *)req->rl_base;
+	struct rpcrdma_msg *headerp = rdmab_to_msg(req->rl_rdmabuf);
 
 	if (req->rl_rtype != rpcrdma_noch)
 		result = rpcrdma_create_chunks(rqst, &rqst->rq_snd_buf,
@@ -406,8 +406,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	base = rqst->rq_svec[0].iov_base;
 	rpclen = rqst->rq_svec[0].iov_len;
 
-	/* build RDMA header in private area at front */
-	headerp = (struct rpcrdma_msg *) req->rl_base;
+	headerp = rdmab_to_msg(req->rl_rdmabuf);
 	/* don't byte-swap XID, it's already done in request */
 	headerp->rm_xid = rqst->rq_xid;
 	headerp->rm_vers = rpcrdma_version;
@@ -528,7 +527,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd padlen %zd"
 		" headerp 0x%p base 0x%p lkey 0x%x\n",
 		__func__, transfertypes[req->rl_wtype], hdrlen, rpclen, padlen,
-		headerp, base, req->rl_iov.lkey);
+		headerp, base, rdmab_lkey(req->rl_rdmabuf));
 
 	/*
 	 * initialize send_iov's - normally only two: rdma chunk header and
@@ -537,9 +536,9 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 * header and any write data. In all non-rdma cases, any following
 	 * data has been copied into the RPC header buffer.
 	 */
-	req->rl_send_iov[0].addr = req->rl_iov.addr;
+	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
 	req->rl_send_iov[0].length = hdrlen;
-	req->rl_send_iov[0].lkey = req->rl_iov.lkey;
+	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
 
 	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
 	req->rl_send_iov[1].length = rpclen;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index a9d5662..2c2fabe 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -470,6 +470,8 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 	if (req == NULL)
 		return NULL;
 
+	if (req->rl_rdmabuf == NULL)
+		goto out_rdmabuf;
 	if (req->rl_sendbuf == NULL)
 		goto out_sendbuf;
 	if (size > req->rl_sendbuf->rg_size)
@@ -480,6 +482,13 @@ out:
 	req->rl_connect_cookie = 0;	/* our reserved value */
 	return req->rl_sendbuf->rg_base;
 
+out_rdmabuf:
+	min_size = RPCRDMA_INLINE_WRITE_THRESHOLD(task->tk_rqstp);
+	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, min_size, flags);
+	if (IS_ERR(rb))
+		goto out_fail;
+	req->rl_rdmabuf = rb;
+
 out_sendbuf:
 	/* XDR encoding and RPC/RDMA marshaling of this request has not
 	 * yet occurred. Thus a lower bound is needed to prevent buffer
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4089440..c81749b 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1078,30 +1078,14 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 static struct rpcrdma_req *
 rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 {
-	struct rpcrdma_create_data_internal *cdata = &r_xprt->rx_data;
-	size_t wlen = cdata->inline_wsize;
-	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct rpcrdma_req *req;
-	int rc;
 
-	rc = -ENOMEM;
-	req = kmalloc(sizeof(*req) + wlen, GFP_KERNEL);
+	req = kzalloc(sizeof(*req), GFP_KERNEL);
 	if (req == NULL)
-		goto out;
-	memset(req, 0, sizeof(*req));
-
-	rc = rpcrdma_register_internal(ia, req->rl_base, wlen,
-				       &req->rl_handle, &req->rl_iov);
-	if (rc)
-		goto out_free;
+		return ERR_PTR(-ENOMEM);
 
 	req->rl_buffer = &r_xprt->rx_buf;
 	return req;
-
-out_free:
-	kfree(req);
-out:
-	return ERR_PTR(rc);
 }
 
 static struct rpcrdma_rep *
@@ -1333,7 +1317,7 @@ rpcrdma_destroy_req(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 		return;
 
 	rpcrdma_free_regbuf(ia, req->rl_sendbuf);
-	rpcrdma_deregister_internal(ia, req->rl_handle, &req->rl_iov);
+	rpcrdma_free_regbuf(ia, req->rl_rdmabuf);
 	kfree(req);
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index aa82f8d..84ad863 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -268,12 +268,10 @@ struct rpcrdma_req {
 	enum rpcrdma_chunktype	rl_rtype, rl_wtype;
 	struct rpcrdma_buffer *rl_buffer; /* home base for this structure */
 	struct rpcrdma_rep	*rl_reply;/* holder for reply buffer */
-	struct rpcrdma_mr_seg rl_segments[RPCRDMA_MAX_SEGS];/* chunk segments */
 	struct ib_sge	rl_send_iov[4];	/* for active requests */
+	struct rpcrdma_regbuf *rl_rdmabuf;
 	struct rpcrdma_regbuf *rl_sendbuf;
-	struct ib_sge	rl_iov;		/* for posting */
-	struct ib_mr	*rl_handle;	/* handle for mem in rl_iov */
-	char		rl_base[MAX_RPCRDMAHDR]; /* start of actual buffer */
+	struct rpcrdma_mr_seg rl_segments[RPCRDMA_MAX_SEGS];
 };
 
 static inline struct rpcrdma_req *

