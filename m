Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f68.google.com ([209.85.166.68]:40197 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726317AbeJBBF3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:05:29 -0400
Subject: [PATCH v2 15/20] xprtrdma: Don't disable BH's in backchannel server
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:26:24 -0400
Message-ID: <20181001182624.18578.80389.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: This code was copied from xprtsock.c and
backchannel_rqst.c. For rpcrdma, the backchannel server runs
exclusively in process context, thus disabling bottom-halves is
unnecessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 90adeff..675b530 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -54,9 +54,9 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 		INIT_LIST_HEAD(&rqst->rq_list);
 		INIT_LIST_HEAD(&rqst->rq_bc_list);
 		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
-		spin_lock_bh(&xprt->bc_pa_lock);
+		spin_lock(&xprt->bc_pa_lock);
 		list_add(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
-		spin_unlock_bh(&xprt->bc_pa_lock);
+		spin_unlock(&xprt->bc_pa_lock);
 
 		size = r_xprt->rx_data.inline_rsize;
 		rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, GFP_KERNEL);
@@ -228,16 +228,16 @@ void xprt_rdma_bc_destroy(struct rpc_xprt *xprt, unsigned int reqs)
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpc_rqst *rqst, *tmp;
 
-	spin_lock_bh(&xprt->bc_pa_lock);
+	spin_lock(&xprt->bc_pa_lock);
 	list_for_each_entry_safe(rqst, tmp, &xprt->bc_pa_list, rq_bc_pa_list) {
 		list_del(&rqst->rq_bc_pa_list);
-		spin_unlock_bh(&xprt->bc_pa_lock);
+		spin_unlock(&xprt->bc_pa_lock);
 
 		rpcrdma_bc_free_rqst(r_xprt, rqst);
 
-		spin_lock_bh(&xprt->bc_pa_lock);
+		spin_lock(&xprt->bc_pa_lock);
 	}
-	spin_unlock_bh(&xprt->bc_pa_lock);
+	spin_unlock(&xprt->bc_pa_lock);
 }
 
 /**
@@ -255,9 +255,9 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 	rpcrdma_recv_buffer_put(req->rl_reply);
 	req->rl_reply = NULL;
 
-	spin_lock_bh(&xprt->bc_pa_lock);
+	spin_lock(&xprt->bc_pa_lock);
 	list_add_tail(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
-	spin_unlock_bh(&xprt->bc_pa_lock);
+	spin_unlock(&xprt->bc_pa_lock);
 }
 
 /**
