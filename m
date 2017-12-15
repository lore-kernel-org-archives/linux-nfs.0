Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36757 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754772AbdLOB5k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:57:40 -0500
Subject: [PATCH v1 13/16] xprtrdma: Don't clear RPC_BC_PA_IN_USE on
 pre-allocated rpc_rqst's
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:57:39 -0500
Message-ID: <20171215015739.13776.37379.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need for the overhead of atomically setting and clearing this bit
flag for every use of a pre-allocated backchannel rpc_rqst. These
are a distinct pool of rpc_rqsts that are used only for callback
operations, so it is safe to simply leave the bit set.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 6c66a4f..3c7998a 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -120,6 +120,7 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 		rqst->rq_xprt = &r_xprt->rx_xprt;
 		INIT_LIST_HEAD(&rqst->rq_list);
 		INIT_LIST_HEAD(&rqst->rq_bc_list);
+		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
 
 		if (rpcrdma_bc_setup_rqst(r_xprt, rqst))
 			goto out_free;
@@ -284,11 +285,6 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 	dprintk("RPC:       %s: freeing rqst %p (req %p)\n",
 		__func__, rqst, rpcr_to_rdmar(rqst));
 
-	smp_mb__before_atomic();
-	WARN_ON_ONCE(!test_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state));
-	clear_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
-	smp_mb__after_atomic();
-
 	spin_lock_bh(&xprt->bc_pa_lock);
 	list_add_tail(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
 	spin_unlock_bh(&xprt->bc_pa_lock);
@@ -343,7 +339,6 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	rqst->rq_xid = *p;
 
 	rqst->rq_private_buf.len = size;
-	set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
 
 	buf = &rqst->rq_rcv_buf;
 	memset(buf, 0, sizeof(*buf));

