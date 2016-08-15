Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35890 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbcHOUvF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:51:05 -0400
Subject: [PATCH v1 06/22] SUNRPC: Add a transport-specific private field in
 rpc_rqst
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:51:03 -0400
Message-ID: <20160815205103.11652.85522.stgit@manet.1015granger.net>
In-Reply-To: <20160815195649.11652.32252.stgit@manet.1015granger.net>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently there's a hidden and indirect mechanism for finding the
rpcrdma_req that goes with an rpc_rqst. It depends on getting from
the rq_buffer pointer in struct rpc_rqst to the struct
rpcrdma_regbuf that controls that buffer, and then to the struct
rpcrdma_req it goes with.

This was done back in the day to avoid the need to add a per-rqst
pointer or to alter the buf_free API when support for RPC-over-RDMA
was introduced.

I'm about to change the way regbuf's work to support larger inline
thresholds. Now is a good time to replace this indirect mechanism
with something that is more straightforward. I guess this should be
considered a clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h       |    1 +
 net/sunrpc/xprtrdma/backchannel.c |    6 ++----
 net/sunrpc/xprtrdma/transport.c   |    2 +-
 net/sunrpc/xprtrdma/verbs.c       |    1 -
 net/sunrpc/xprtrdma/xprt_rdma.h   |   13 +++++++------
 5 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8e3f292..6080482 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -83,6 +83,7 @@ struct rpc_rqst {
 	void (*rq_release_snd_buf)(struct rpc_rqst *); /* release rq_enc_pages */
 	struct list_head	rq_list;
 
+	void			*rq_xprtdata;	/* Per-xprt private data */
 	__be32			*rq_buffer;	/* Call XDR encode buffer */
 	size_t			rq_callsize;
 	__be32			*rq_rbuffer;	/* Reply XDR decode buffer */
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index d3cfaf2..c4904f8 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -55,11 +55,9 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 	rb = rpcrdma_alloc_regbuf(ia, size, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
-	rb->rg_owner = req;
 	req->rl_sendbuf = rb;
-	/* so that rpcr_to_rdmar works when receiving a request */
-	rqst->rq_buffer = (void *)req->rl_sendbuf->rg_base;
-	xdr_buf_init(&rqst->rq_snd_buf, rqst->rq_buffer, size);
+	xdr_buf_init(&rqst->rq_snd_buf, rb->rg_base, size);
+	rpcrdma_set_xprtdata(rqst, req);
 	return 0;
 
 out_fail:
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 1f5dc19..343bb31 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -523,6 +523,7 @@ xprt_rdma_allocate(struct rpc_task *task)
 out:
 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
 	req->rl_connect_cookie = 0;	/* our reserved value */
+	rpcrdma_set_xprtdata(rqst, req);
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
 	rqst->rq_rbuffer = (__be32 *)((char *)rqst->rq_buffer +
 				      rqst->rq_rcvsize);
@@ -560,7 +561,6 @@ out_sendbuf:
 	rb = rpcrdma_alloc_regbuf(&r_xprt->rx_ia, size, flags);
 	if (IS_ERR(rb))
 		goto out_fail;
-	rb->rg_owner = req;
 
 	r_xprt->rx_stats.hardway_register_count += size;
 	rpcrdma_free_regbuf(&r_xprt->rx_ia, req->rl_sendbuf);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 536d0be..baf7f43 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1191,7 +1191,6 @@ rpcrdma_alloc_regbuf(struct rpcrdma_ia *ia, size_t size, gfp_t flags)
 	iov->length = size;
 	iov->lkey = ia->ri_pd->local_dma_lkey;
 	rb->rg_size = size;
-	rb->rg_owner = NULL;
 	return rb;
 
 out_free:
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 296d9ab..d8ba118 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -113,7 +113,6 @@ struct rpcrdma_ep {
 
 struct rpcrdma_regbuf {
 	size_t			rg_size;
-	struct rpcrdma_req	*rg_owner;
 	struct ib_sge		rg_iov;
 	__be32			rg_base[0] __attribute__ ((aligned(256)));
 };
@@ -297,14 +296,16 @@ struct rpcrdma_req {
 	struct rpcrdma_mr_seg	rl_segments[RPCRDMA_MAX_SEGS];
 };
 
+static inline void
+rpcrdma_set_xprtdata(struct rpc_rqst *rqst, struct rpcrdma_req *req)
+{
+	rqst->rq_xprtdata = (void *)req;
+}
+
 static inline struct rpcrdma_req *
 rpcr_to_rdmar(struct rpc_rqst *rqst)
 {
-	void *buffer = rqst->rq_buffer;
-	struct rpcrdma_regbuf *rb;
-
-	rb = container_of(buffer, struct rpcrdma_regbuf, rg_base);
-	return rb->rg_owner;
+	return (struct rpcrdma_req *)rqst->rq_xprtdata;
 }
 
 /*

