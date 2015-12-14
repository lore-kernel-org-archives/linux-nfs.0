Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33804 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264AbbLNVSF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 16:18:05 -0500
Subject: [PATCH v3 03/11] xprtrdma: Disable RPC/RDMA backchannel debugging
 messages
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 14 Dec 2015 16:18:03 -0500
Message-ID: <20151214211802.16295.77428.stgit@manet.1015granger.net>
In-Reply-To: <20151214211317.16295.70115.stgit@manet.1015granger.net>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Fixes: 63cae47005af ('xprtrdma: Handle incoming backward direction')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 11d2cfb..cd31181 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -15,7 +15,7 @@
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
 
-#define RPCRDMA_BACKCHANNEL_DEBUG
+#undef RPCRDMA_BACKCHANNEL_DEBUG
 
 static void rpcrdma_bc_free_rqst(struct rpcrdma_xprt *r_xprt,
 				 struct rpc_rqst *rqst)
@@ -136,6 +136,7 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 			       __func__);
 			goto out_free;
 		}
+		dprintk("RPC:       %s: new rqst %p\n", __func__, rqst);
 
 		rqst->rq_xprt = &r_xprt->rx_xprt;
 		INIT_LIST_HEAD(&rqst->rq_list);
@@ -216,12 +217,14 @@ int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 
 	rpclen = rqst->rq_svec[0].iov_len;
 
+#ifdef RPCRDMA_BACKCHANNEL_DEBUG
 	pr_info("RPC:       %s: rpclen %zd headerp 0x%p lkey 0x%x\n",
 		__func__, rpclen, headerp, rdmab_lkey(req->rl_rdmabuf));
 	pr_info("RPC:       %s: RPC/RDMA: %*ph\n",
 		__func__, (int)RPCRDMA_HDRLEN_MIN, headerp);
 	pr_info("RPC:       %s:      RPC: %*ph\n",
 		__func__, (int)rpclen, rqst->rq_svec[0].iov_base);
+#endif
 
 	req->rl_send_iov[0].addr = rdmab_addr(req->rl_rdmabuf);
 	req->rl_send_iov[0].length = RPCRDMA_HDRLEN_MIN;
@@ -265,6 +268,9 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 {
 	struct rpc_xprt *xprt = rqst->rq_xprt;
 
+	dprintk("RPC:       %s: freeing rqst %p (req %p)\n",
+		__func__, rqst, rpcr_to_rdmar(rqst));
+
 	smp_mb__before_atomic();
 	WARN_ON_ONCE(!test_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state));
 	clear_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
@@ -329,9 +335,7 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 				struct rpc_rqst, rq_bc_pa_list);
 	list_del(&rqst->rq_bc_pa_list);
 	spin_unlock(&xprt->bc_pa_lock);
-#ifdef RPCRDMA_BACKCHANNEL_DEBUG
-	pr_info("RPC:       %s: using rqst %p\n", __func__, rqst);
-#endif
+	dprintk("RPC:       %s: using rqst %p\n", __func__, rqst);
 
 	/* Prepare rqst */
 	rqst->rq_reply_bytes_recvd = 0;
@@ -351,10 +355,8 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	 * direction reply.
 	 */
 	req = rpcr_to_rdmar(rqst);
-#ifdef RPCRDMA_BACKCHANNEL_DEBUG
-	pr_info("RPC:       %s: attaching rep %p to req %p\n",
+	dprintk("RPC:       %s: attaching rep %p to req %p\n",
 		__func__, rep, req);
-#endif
 	req->rl_reply = rep;
 
 	/* Defeat the retransmit detection logic in send_request */

