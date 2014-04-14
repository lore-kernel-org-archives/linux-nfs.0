Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:61248 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339AbaDNWWn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2014 18:22:43 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] xprtrdma: Remove BOUNCEBUFFERS memory registration mode
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 14 Apr 2014 18:22:41 -0400
Message-ID: <20140414222241.20646.23399.stgit@manet.1015granger.net>
In-Reply-To: <20140414220041.20646.63991.stgit@manet.1015granger.net>
References: <20140414220041.20646.63991.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: This memory registration mode is slow and was never
meant for use in production environments. Remove it to reduce
implementation complexity.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c  |    8 --------
 net/sunrpc/xprtrdma/transport.c |   13 -------------
 net/sunrpc/xprtrdma/verbs.c     |    5 +----
 3 files changed, 1 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c296468..b963e50 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -439,14 +439,6 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 		wtype = rpcrdma_noch;
 	BUG_ON(rtype != rpcrdma_noch && wtype != rpcrdma_noch);
 
-	if (r_xprt->rx_ia.ri_memreg_strategy == RPCRDMA_BOUNCEBUFFERS &&
-	    (rtype != rpcrdma_noch || wtype != rpcrdma_noch)) {
-		/* forced to "pure inline"? */
-		dprintk("RPC:       %s: too much data (%d/%d) for inline\n",
-			__func__, rqst->rq_rcv_buf.len, rqst->rq_snd_buf.len);
-		return -1;
-	}
-
 	hdrlen = 28; /*sizeof *headerp;*/
 	padlen = 0;
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 1eb9c46..8c5035a 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -503,18 +503,6 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 		 * If the allocation or registration fails, the RPC framework
 		 * will (doggedly) retry.
 		 */
-		if (rpcx_to_rdmax(xprt)->rx_ia.ri_memreg_strategy ==
-				RPCRDMA_BOUNCEBUFFERS) {
-			/* forced to "pure inline" */
-			dprintk("RPC:       %s: too much data (%zd) for inline "
-					"(r/w max %d/%d)\n", __func__, size,
-					rpcx_to_rdmad(xprt).inline_rsize,
-					rpcx_to_rdmad(xprt).inline_wsize);
-			size = req->rl_size;
-			rpc_exit(task, -EIO);		/* fail the operation */
-			rpcx_to_rdmax(xprt)->rx_stats.failed_marshal_count++;
-			goto out;
-		}
 		if (task->tk_flags & RPC_TASK_SWAPPER)
 			nreq = kmalloc(sizeof *req + size, GFP_ATOMIC);
 		else
@@ -543,7 +531,6 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 		req = nreq;
 	}
 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
-out:
 	req->rl_connect_cookie = 0;	/* our reserved value */
 	return req->rl_xdr_buf;
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 422cf89..1fe554f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -557,7 +557,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	 * adapter.
 	 */
 	switch (memreg) {
-	case RPCRDMA_BOUNCEBUFFERS:
 	case RPCRDMA_REGISTER:
 	case RPCRDMA_FRMR:
 		break;
@@ -778,9 +777,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	/* Client offers RDMA Read but does not initiate */
 	ep->rep_remote_cma.initiator_depth = 0;
-	if (ia->ri_memreg_strategy == RPCRDMA_BOUNCEBUFFERS)
-		ep->rep_remote_cma.responder_resources = 0;
-	else if (devattr.max_qp_rd_atom > 32)	/* arbitrary but <= 255 */
+	if (devattr.max_qp_rd_atom > 32)	/* arbitrary but <= 255 */
 		ep->rep_remote_cma.responder_resources = 32;
 	else
 		ep->rep_remote_cma.responder_resources = devattr.max_qp_rd_atom;

