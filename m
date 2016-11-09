Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33329 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752634AbcKIRwM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 12:52:12 -0500
Subject: [PATCH v1 4/7] svcrdma: Remove BH-disabled spin locking in
 svc_rdma_send()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 12:34:10 -0500
Message-ID: <20161109173410.15735.12286.stgit@klimt.1015granger.net>
In-Reply-To: <20161109165814.15735.47815.stgit@klimt.1015granger.net>
References: <20161109165814.15735.47815.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svcrdma's current SQ accounting algorithm takes sc_lock and disables
bottom-halves while posting all RDMA Read, Write, and Send WRs.

This is relatively heavyweight serialization. And note that Write and
Send are already fully serialized by the xpt_mutex.

Using a single atomic_t should be all that is necessary to guarantee
that ib_post_send() is called only when there is enough space on the
send queue. This is what the other RDMA-enabled storage targets do.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    7 ++++++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   18 +++++++-----------
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 6aef63b..601cb07 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -139,7 +139,7 @@ struct svcxprt_rdma {
 	int                  sc_max_sge_rd;	/* max sge for read target */
 	bool		     sc_snd_w_inv;	/* OK to use Send With Invalidate */
 
-	atomic_t             sc_sq_count;	/* Number of SQ WR on queue */
+	atomic_t             sc_sq_avail;	/* SQEs ready to be consumed */
 	unsigned int	     sc_sq_depth;	/* Depth of SQ */
 	unsigned int	     sc_rq_depth;	/* Depth of RQ */
 	u32		     sc_max_requests;	/* Forward credits */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 0a58d40..30eeab5 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -594,7 +594,12 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		goto err0;
 	inline_bytes = rqstp->rq_res.len;
 
-	/* Create the RDMA response header */
+	/* Create the RDMA response header. xprt->xpt_mutex,
+	 * acquired in svc_send(), serializes RPC replies. The
+	 * code path below that inserts the credit grant value
+	 * into each transport header runs only inside this
+	 * critical section.
+	 */
 	ret = -ENOMEM;
 	res_page = alloc_page(GFP_KERNEL);
 	if (!res_page)
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 6864fb9..f7dd6494 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -434,7 +434,7 @@ static void svc_rdma_send_wc_common(struct svcxprt_rdma *xprt,
 		goto err;
 
 out:
-	atomic_dec(&xprt->sc_sq_count);
+	atomic_inc(&xprt->sc_sq_avail);
 	wake_up(&xprt->sc_send_wait);
 	return;
 
@@ -1008,6 +1008,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	newxprt->sc_rq_depth = newxprt->sc_max_requests +
 			       newxprt->sc_max_bc_requests;
 	newxprt->sc_sq_depth = RPCRDMA_SQ_DEPTH_MULT * newxprt->sc_rq_depth;
+	atomic_set(&newxprt->sc_sq_avail, newxprt->sc_sq_depth);
 
 	if (!svc_rdma_prealloc_ctxts(newxprt))
 		goto errout;
@@ -1333,15 +1334,13 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 
 	/* If the SQ is full, wait until an SQ entry is available */
 	while (1) {
-		spin_lock_bh(&xprt->sc_lock);
-		if (xprt->sc_sq_depth < atomic_read(&xprt->sc_sq_count) + wr_count) {
-			spin_unlock_bh(&xprt->sc_lock);
+		if ((atomic_sub_return(wr_count, &xprt->sc_sq_avail) < 0)) {
 			atomic_inc(&rdma_stat_sq_starve);
 
 			/* Wait until SQ WR available if SQ still full */
+			atomic_add(wr_count, &xprt->sc_sq_avail);
 			wait_event(xprt->sc_send_wait,
-				   atomic_read(&xprt->sc_sq_count) <
-				   xprt->sc_sq_depth);
+				   atomic_read(&xprt->sc_sq_avail) > wr_count);
 			if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
 				return -ENOTCONN;
 			continue;
@@ -1351,19 +1350,16 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 			svc_xprt_get(&xprt->sc_xprt);
 
 		/* Bump used SQ WR count and post */
-		atomic_add(wr_count, &xprt->sc_sq_count);
 		ret = ib_post_send(xprt->sc_qp, wr, &bad_wr);
 		if (ret) {
 			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
-			atomic_sub(wr_count, &xprt->sc_sq_count);
 			for (i = 0; i < wr_count; i ++)
 				svc_xprt_put(&xprt->sc_xprt);
 			dprintk("svcrdma: failed to post SQ WR rc=%d, "
-			       "sc_sq_count=%d, sc_sq_depth=%d\n",
-			       ret, atomic_read(&xprt->sc_sq_count),
+			       "sc_sq_avail=%d, sc_sq_depth=%d\n",
+			       ret, atomic_read(&xprt->sc_sq_avail),
 			       xprt->sc_sq_depth);
 		}
-		spin_unlock_bh(&xprt->sc_lock);
 		if (ret)
 			wake_up(&xprt->sc_send_wait);
 		break;

