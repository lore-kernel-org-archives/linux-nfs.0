Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:50548 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934609AbeB1UbH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 15:31:07 -0500
Subject: [PATCH 8/8] xprtrdma: Move creation of rl_rdmabuf to
 rpcrdma_create_req
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 28 Feb 2018 15:31:05 -0500
Message-ID: <20180228203105.25968.91937.stgit@manet.1015granger.net>
In-Reply-To: <20180228202916.25968.21750.stgit@manet.1015granger.net>
References: <20180228202916.25968.21750.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor: Both rpcrdma_create_req call sites have to allocate the
buffer where the transport header is built, so just move that
allocation into rpcrdma_create_req.

This buffer is a fixed size. There's no needed information available
in call_allocate that is not also available when the transport is
created.

The original purpose for allocating these buffers on demand was to
reduce the possibility that an allocation failure during transport
creation will hork the mount operation during low memory scenarios.
Some relief for this rare possibility is coming up in the next few
patches.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    7 -------
 net/sunrpc/xprtrdma/transport.c   |   25 -------------------------
 net/sunrpc/xprtrdma/verbs.c       |   14 ++++++++++++--
 3 files changed, 12 insertions(+), 34 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index ed1a4a3..47ebac9 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -44,13 +44,6 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
-	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE,
-				  DMA_TO_DEVICE, GFP_KERNEL);
-	if (IS_ERR(rb))
-		goto out_fail;
-	req->rl_rdmabuf = rb;
-	xdr_buf_init(&req->rl_hdrbuf, rb->rg_base, rdmab_length(rb));
-
 	size = r_xprt->rx_data.inline_rsize;
 	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, GFP_KERNEL);
 	if (IS_ERR(rb))
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 7e39faa..67e4386 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -537,29 +537,6 @@
 	}
 }
 
-/* Allocate a fixed-size buffer in which to construct and send the
- * RPC-over-RDMA header for this request.
- */
-static bool
-rpcrdma_get_rdmabuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
-		    gfp_t flags)
-{
-	size_t size = RPCRDMA_HDRBUF_SIZE;
-	struct rpcrdma_regbuf *rb;
-
-	if (req->rl_rdmabuf)
-		return true;
-
-	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, flags);
-	if (IS_ERR(rb))
-		return false;
-
-	r_xprt->rx_stats.hardway_register_count += size;
-	req->rl_rdmabuf = rb;
-	xdr_buf_init(&req->rl_hdrbuf, rb->rg_base, rdmab_length(rb));
-	return true;
-}
-
 static bool
 rpcrdma_get_sendbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		    size_t size, gfp_t flags)
@@ -641,8 +618,6 @@
 	if (RPC_IS_SWAPPER(task))
 		flags = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
 
-	if (!rpcrdma_get_rdmabuf(r_xprt, req, flags))
-		goto out_fail;
 	if (!rpcrdma_get_sendbuf(r_xprt, req, rqst->rq_callsize, flags))
 		goto out_fail;
 	if (!rpcrdma_get_recvbuf(r_xprt, req, rqst->rq_rcvsize, flags))
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 626fd30..6a7a5a2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1068,17 +1068,27 @@ struct rpcrdma_req *
 rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buffer = &r_xprt->rx_buf;
+	struct rpcrdma_regbuf *rb;
 	struct rpcrdma_req *req;
 
 	req = kzalloc(sizeof(*req), GFP_KERNEL);
 	if (req == NULL)
 		return ERR_PTR(-ENOMEM);
 
+	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE,
+				  DMA_TO_DEVICE, GFP_KERNEL);
+	if (IS_ERR(rb)) {
+		kfree(req);
+		return ERR_PTR(-ENOMEM);
+	}
+	req->rl_rdmabuf = rb;
+	xdr_buf_init(&req->rl_hdrbuf, rb->rg_base, rdmab_length(rb));
+	req->rl_buffer = buffer;
+	INIT_LIST_HEAD(&req->rl_registered);
+
 	spin_lock(&buffer->rb_reqslock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
 	spin_unlock(&buffer->rb_reqslock);
-	req->rl_buffer = &r_xprt->rx_buf;
-	INIT_LIST_HEAD(&req->rl_registered);
 	return req;
 }
 

