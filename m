Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33480 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752283AbdHJQrO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Aug 2017 12:47:14 -0400
Received: by mail-io0-f193.google.com with SMTP id q64so1940473ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 09:47:13 -0700 (PDT)
Subject: [PATCH v1 1/5] xprtrdma: Clean up rpcrdma_marshal_req() synopsis
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 10 Aug 2017 12:47:12 -0400
Message-ID: <20170810164712.23774.99282.stgit@manet.1015granger.net>
In-Reply-To: <20170810164425.23774.91430.stgit@manet.1015granger.net>
References: <20170810164425.23774.91430.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The caller already has rpcrdma_xprt, so pass that directly
instead. And provide a documenting comment for this critical
function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   25 +++++++++++++++++--------
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6219861..d916e59 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -651,18 +651,27 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	req->rl_mapped_sges = 0;
 }
 
-/*
- * Marshal a request: the primary job of this routine is to choose
- * the transfer modes. See comments below.
+/**
+ * rpcrdma_marshal_req - Marshal and send one RPC request
+ * @r_xprt: controlling transport
+ * @rqst: RPC request to be marshaled
  *
- * Returns zero on success, otherwise a negative errno.
+ * For the RPC in "rqst", this function:
+ *  - Chooses the transfer mode (eg., RDMA_MSG or RDMA_NOMSG)
+ *  - Registers Read, Write, and Reply chunks
+ *  - Constructs the transport header
+ *  - Posts a Send WR to send the transport header and request
+ *
+ * Returns:
+ *	%0 if the RPC was sent successfully,
+ *	%-ENOTCONN if the connection was lost,
+ *	%-EAGAIN if not enough pages are available for on-demand reply buffer,
+ *	%-ENOBUFS if no MRs are available to register chunks,
+ *	%-EIO if a permanent problem occurred while marshaling.
  */
-
 int
-rpcrdma_marshal_req(struct rpc_rqst *rqst)
+rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst)
 {
-	struct rpc_xprt *xprt = rqst->rq_xprt;
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	enum rpcrdma_chunktype rtype, wtype;
 	struct rpcrdma_msg *headerp;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 42752e4..a43b8280 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -730,7 +730,7 @@
 	if (unlikely(!list_empty(&req->rl_registered)))
 		r_xprt->rx_ia.ri_ops->ro_unmap_safe(r_xprt, req, false);
 
-	rc = rpcrdma_marshal_req(rqst);
+	rc = rpcrdma_marshal_req(r_xprt, rqst);
 	if (rc < 0)
 		goto failed_marshal;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 52e73ea..78958e9 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -637,7 +637,7 @@ enum rpcrdma_chunktype {
 bool rpcrdma_prepare_send_sges(struct rpcrdma_ia *, struct rpcrdma_req *,
 			       u32, struct xdr_buf *, enum rpcrdma_chunktype);
 void rpcrdma_unmap_sges(struct rpcrdma_ia *, struct rpcrdma_req *);
-int rpcrdma_marshal_req(struct rpc_rqst *);
+int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 void rpcrdma_reply_handler(struct work_struct *work);
 

