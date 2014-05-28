Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59928 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbaE1Oc1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:32:27 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 04/24] xprtrdma: Remove BOUNCEBUFFERS memory registration
	mode
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:32:26 -0400
Message-ID: <20140528143225.23214.81898.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: This memory registration mode is slow and was never
meant for use in production environments. Remove it to reduce
implementation complexity.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c  |   11 -----------
 net/sunrpc/xprtrdma/transport.c |   13 -------------
 net/sunrpc/xprtrdma/verbs.c     |    5 +----
 3 files changed, 1 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c296468..02b2941 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -77,9 +77,6 @@ static const char transfertypes[][12] = {
  * Prepare the passed-in xdr_buf into representation as RPC/RDMA chunk
  * elements. Segments are then coalesced when registered, if possible
  * within the selected memreg mode.
- *
- * Note, this routine is never called if the connection's memory
- * registration strategy is 0 (bounce buffers).
  */
 
 static int
@@ -439,14 +436,6 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
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
index 9cb88f3..4a4e4ea 100644
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

