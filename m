Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33443 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753331AbcIOO4E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 10:56:04 -0400
Subject: [PATCH v3 08/22] xprtrdma: Use smaller buffers for RPC-over-RDMA
 headers
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 15 Sep 2016 10:56:02 -0400
Message-ID: <20160915145601.11080.32594.stgit@manet.1015granger.net>
In-Reply-To: <20160915143440.11080.89241.stgit@manet.1015granger.net>
References: <20160915143440.11080.89241.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 949317464bc2 ("xprtrdma: Limit number of RDMA segments in
RPC-over-RDMA headers") capped the number of chunks that may appear
in RPC-over-RDMA headers. The maximum header size can be estimated
and fixed to avoid allocating buffer space that is never used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    5 ++---
 net/sunrpc/xprtrdma/transport.c   |    2 +-
 net/sunrpc/xprtrdma/xprt_rdma.h   |    5 ++++-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index c4904f8..60fc991 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -45,13 +45,12 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 		return PTR_ERR(req);
 	req->rl_backchannel = true;
 
-	size = r_xprt->rx_data.inline_wsize;
-	rb = rpcrdma_alloc_regbuf(ia, size, GFP_KERNEL);
+	rb = rpcrdma_alloc_regbuf(ia, RPCRDMA_HDRBUF_SIZE, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
 	req->rl_rdmabuf = rb;
 
-	size += r_xprt->rx_data.inline_rsize;
+	size = r_xprt->rx_data.inline_rsize;
 	rb = rpcrdma_alloc_regbuf(ia, size, GFP_KERNEL);
 	if (IS_ERR(rb))
 		goto out_fail;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ecdc3ad..94dbfd3 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -484,7 +484,7 @@ static bool
 rpcrdma_get_rdmabuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		    gfp_t flags)
 {
-	size_t size = r_xprt->rx_data.inline_wsize;
+	size_t size = RPCRDMA_HDRBUF_SIZE;
 	struct rpcrdma_regbuf *rb;
 
 	if (req->rl_rdmabuf)
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 444f637..cc426b1 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -160,7 +160,10 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
  * The smallest inline threshold is 1024 bytes, ensuring that
  * at least 750 bytes are available for RPC messages.
  */
-#define RPCRDMA_MAX_HDR_SEGS	(8)
+enum {
+	RPCRDMA_MAX_HDR_SEGS = 8,
+	RPCRDMA_HDRBUF_SIZE = 256,
+};
 
 /*
  * struct rpcrdma_rep -- this structure encapsulates state required to recv

