Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f68.google.com ([209.85.166.68]:44953 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726178AbeJBBEQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:04:16 -0400
Subject: [PATCH v2 01/20] xprtrdma: xprt_release_rqst_cong is called outside
 of transport_lock
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:25:09 -0400
Message-ID: <20181001182509.18578.83129.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit ce7c252a8c74 ("SUNRPC: Add a separate spinlock to
protect the RPC request receive list") the RPC/RDMA reply handler
has been calling xprt_release_rqst_cong without holding
xprt->transport_lock.

I think the only way this call is ever made is if the credit grant
increases and there are RPCs pending. Current server implementations
do not change their credit grant during operation (except at
connect time).

Commit e7ce710a8802 ("xprtrdma: Avoid deadlock when credit window is
reset") added the ->release_rqst call because UDP invokes
xprt_adjust_cwnd(), which calls __xprt_put_cong() after adjusting
xprt->cwnd. Both xprt_release() and ->xprt_release_xprt already wake
another task in this case, so it is safe to remove this call from
the reply handler.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c8ae983..293b3d3 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1216,7 +1216,6 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
 	struct rpc_rqst *rqst = rep->rr_rqst;
-	unsigned long cwnd;
 	int status;
 
 	xprt->reestablish_timeout = 0;
@@ -1239,11 +1238,6 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 
 out:
 	spin_lock(&xprt->recv_lock);
-	cwnd = xprt->cwnd;
-	xprt->cwnd = r_xprt->rx_buf.rb_credits << RPC_CWNDSHIFT;
-	if (xprt->cwnd > cwnd)
-		xprt_release_rqst_cong(rqst->rq_task);
-
 	xprt_complete_rqst(rqst->rq_task, status);
 	xprt_unpin_rqst(rqst);
 	spin_unlock(&xprt->recv_lock);
@@ -1350,14 +1344,18 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	if (!rqst)
 		goto out_norqst;
 	xprt_pin_rqst(rqst);
+	spin_unlock(&xprt->recv_lock);
 
 	if (credits == 0)
 		credits = 1;	/* don't deadlock */
 	else if (credits > buf->rb_max_requests)
 		credits = buf->rb_max_requests;
-	buf->rb_credits = credits;
-
-	spin_unlock(&xprt->recv_lock);
+	if (buf->rb_credits != credits) {
+		spin_lock_bh(&xprt->transport_lock);
+		buf->rb_credits = credits;
+		xprt->cwnd = credits << RPC_CWNDSHIFT;
+		spin_unlock_bh(&xprt->transport_lock);
+	}
 
 	req = rpcr_to_rdmar(rqst);
 	req->rl_reply = rep;
