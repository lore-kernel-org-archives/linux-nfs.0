Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f196.google.com ([209.85.166.196]:35923 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725975AbeJBAzF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 20:55:05 -0400
Subject: [PATCH v1 2/4] svcrdma: Remove ->release_rqst call in bc reply
 handler
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:16:01 -0400
Message-ID: <20181001181601.2305.43928.stgit@klimt.1015granger.net>
In-Reply-To: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Similar to a change made in the client's forward channel reply
handler: The xprt_release_rqst_cong() call is not necessary.

Also, release xprt->recv_lock when taking xprt->transport_lock
to avoid disabling and enabling BH's while holding another
spin lock.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index a681800..642f031 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -32,7 +32,6 @@ int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt, __be32 *rdma_resp,
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct kvec *dst, *src = &rcvbuf->head[0];
 	struct rpc_rqst *req;
-	unsigned long cwnd;
 	u32 credits;
 	size_t len;
 	__be32 xid;
@@ -66,6 +65,8 @@ int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt, __be32 *rdma_resp,
 	if (dst->iov_len < len)
 		goto out_unlock;
 	memcpy(dst->iov_base, p, len);
+	xprt_pin_rqst(req);
+	spin_unlock(&xprt->recv_lock);
 
 	credits = be32_to_cpup(rdma_resp + 2);
 	if (credits == 0)
@@ -74,15 +75,13 @@ int svc_rdma_handle_bc_reply(struct rpc_xprt *xprt, __be32 *rdma_resp,
 		credits = r_xprt->rx_buf.rb_bc_max_requests;
 
 	spin_lock_bh(&xprt->transport_lock);
-	cwnd = xprt->cwnd;
 	xprt->cwnd = credits << RPC_CWNDSHIFT;
-	if (xprt->cwnd > cwnd)
-		xprt_release_rqst_cong(req->rq_task);
 	spin_unlock_bh(&xprt->transport_lock);
 
-
+	spin_lock(&xprt->recv_lock);
 	ret = 0;
 	xprt_complete_rqst(req->rq_task, rcvbuf->len);
+	xprt_unpin_rqst(req);
 	rcvbuf->len = 0;
 
 out_unlock:
