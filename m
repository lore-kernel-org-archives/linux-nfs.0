Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35981 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbbJXV04 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 17:26:56 -0400
Subject: [PATCH v4 04/16] xprtrdma: Refactor reply handler error handling
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 24 Oct 2015 17:26:54 -0400
Message-ID: <20151024212654.4715.36377.stgit@manet.1015granger.net>
In-Reply-To: <20151024211707.4715.61650.stgit@manet.1015granger.net>
References: <20151024211707.4715.61650.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The error cases in rpcrdma_reply_handler() almost never
execute. Ensure the compiler places them out of the hot path.

No behavior change expected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   89 ++++++++++++++++++++++-----------------
 net/sunrpc/xprtrdma/verbs.c     |    2 -
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +
 3 files changed, 53 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index bc8bd65..60ffa63 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -741,52 +741,27 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	unsigned long cwnd;
 	u32 credits;
 
-	/* Check status. If bad, signal disconnect and return rep to pool */
-	if (rep->rr_len == ~0U) {
-		rpcrdma_recv_buffer_put(rep);
-		if (r_xprt->rx_ep.rep_connected == 1) {
-			r_xprt->rx_ep.rep_connected = -EIO;
-			rpcrdma_conn_func(&r_xprt->rx_ep);
-		}
-		return;
-	}
-	if (rep->rr_len < RPCRDMA_HDRLEN_MIN) {
-		dprintk("RPC:       %s: short/invalid reply\n", __func__);
-		goto repost;
-	}
+	dprintk("RPC:       %s: incoming rep %p\n", __func__, rep);
+
+	if (rep->rr_len == RPCRDMA_BAD_LEN)
+		goto out_badstatus;
+	if (rep->rr_len < RPCRDMA_HDRLEN_MIN)
+		goto out_shortreply;
+
 	headerp = rdmab_to_msg(rep->rr_rdmabuf);
-	if (headerp->rm_vers != rpcrdma_version) {
-		dprintk("RPC:       %s: invalid version %d\n",
-			__func__, be32_to_cpu(headerp->rm_vers));
-		goto repost;
-	}
+	if (headerp->rm_vers != rpcrdma_version)
+		goto out_badversion;
 
 	/* Get XID and try for a match. */
 	spin_lock(&xprt->transport_lock);
 	rqst = xprt_lookup_rqst(xprt, headerp->rm_xid);
-	if (rqst == NULL) {
-		spin_unlock(&xprt->transport_lock);
-		dprintk("RPC:       %s: reply 0x%p failed "
-			"to match any request xid 0x%08x len %d\n",
-			__func__, rep, be32_to_cpu(headerp->rm_xid),
-			rep->rr_len);
-repost:
-		r_xprt->rx_stats.bad_reply_count++;
-		if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, &r_xprt->rx_ep, rep))
-			rpcrdma_recv_buffer_put(rep);
-
-		return;
-	}
+	if (!rqst)
+		goto out_nomatch;
 
 	/* get request object */
 	req = rpcr_to_rdmar(rqst);
-	if (req->rl_reply) {
-		spin_unlock(&xprt->transport_lock);
-		dprintk("RPC:       %s: duplicate reply 0x%p to RPC "
-			"request 0x%p: xid 0x%08x\n", __func__, rep, req,
-			be32_to_cpu(headerp->rm_xid));
-		goto repost;
-	}
+	if (req->rl_reply)
+		goto out_duplicate;
 
 	dprintk("RPC:       %s: reply 0x%p completes request 0x%p\n"
 		"                   RPC request 0x%p xid 0x%08x\n",
@@ -883,8 +858,44 @@ badheader:
 	if (xprt->cwnd > cwnd)
 		xprt_release_rqst_cong(rqst->rq_task);
 
+	xprt_complete_rqst(rqst->rq_task, status);
+	spin_unlock(&xprt->transport_lock);
 	dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
 			__func__, xprt, rqst, status);
-	xprt_complete_rqst(rqst->rq_task, status);
+	return;
+
+out_badstatus:
+	rpcrdma_recv_buffer_put(rep);
+	if (r_xprt->rx_ep.rep_connected == 1) {
+		r_xprt->rx_ep.rep_connected = -EIO;
+		rpcrdma_conn_func(&r_xprt->rx_ep);
+	}
+	return;
+
+out_shortreply:
+	dprintk("RPC:       %s: short/invalid reply\n", __func__);
+	goto repost;
+
+out_badversion:
+	dprintk("RPC:       %s: invalid version %d\n",
+		__func__, be32_to_cpu(headerp->rm_vers));
+	goto repost;
+
+out_nomatch:
+	spin_unlock(&xprt->transport_lock);
+	dprintk("RPC:       %s: no match for incoming xid 0x%08x len %d\n",
+		__func__, be32_to_cpu(headerp->rm_xid),
+		rep->rr_len);
+	goto repost;
+
+out_duplicate:
 	spin_unlock(&xprt->transport_lock);
+	dprintk("RPC:       %s: "
+		"duplicate reply %p to RPC request %p: xid 0x%08x\n",
+		__func__, rep, req, be32_to_cpu(headerp->rm_xid));
+
+repost:
+	r_xprt->rx_stats.bad_reply_count++;
+	if (rpcrdma_ep_post_recv(&r_xprt->rx_ia, &r_xprt->rx_ep, rep))
+		rpcrdma_recv_buffer_put(rep);
 }
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6661b1b..a60b4c4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -225,7 +225,7 @@ out_fail:
 	if (wc->status != IB_WC_WR_FLUSH_ERR)
 		pr_err("RPC:       %s: rep %p: %s\n",
 		       __func__, rep, ib_wc_status_msg(wc->status));
-	rep->rr_len = ~0U;
+	rep->rr_len = RPCRDMA_BAD_LEN;
 	goto out_schedule;
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 42c8d44..a13508b 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -168,6 +168,8 @@ struct rpcrdma_rep {
 	struct rpcrdma_regbuf	*rr_rdmabuf;
 };
 
+#define RPCRDMA_BAD_LEN		(~0U)
+
 /*
  * struct rpcrdma_mw - external memory region metadata
  *

