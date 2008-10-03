From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 06/12] svcrdma: Add support to svc_rdma_send to handle chained WR
Date: Fri,  3 Oct 2008 16:33:43 -0500
Message-ID: <1223069629-5267-7-git-send-email-tom@opengridcomputing.com>
References: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-2-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-5-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-6-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40982 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753409AbYJCVdv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:51 -0400
In-Reply-To: <1223069629-5267-6-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

WR can be submitted as linked lists of WR. Update the svc_rdma_send
routine to handle WR chains. This will be used to submit a WR that
uses an FRMR with another WR that invalidates the FRMR.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   29 +++++++++++++++++++++--------
 1 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index a144fab..5ea7901 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1241,17 +1241,23 @@ int svc_rdma_fastreg(struct svcxprt_rdma *xprt,
 
 int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 {
-	struct ib_send_wr *bad_wr;
+	struct ib_send_wr *bad_wr, *n_wr;
+	int wr_count;
+	int i;
 	int ret;
 
 	if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
 		return -ENOTCONN;
 
 	BUG_ON(wr->send_flags != IB_SEND_SIGNALED);
+	wr_count = 1;
+	for (n_wr = wr->next; n_wr; n_wr = n_wr->next)
+		wr_count++;
+
 	/* If the SQ is full, wait until an SQ entry is available */
 	while (1) {
 		spin_lock_bh(&xprt->sc_lock);
-		if (xprt->sc_sq_depth == atomic_read(&xprt->sc_sq_count)) {
+		if (xprt->sc_sq_depth < atomic_read(&xprt->sc_sq_count) + wr_count) {
 			spin_unlock_bh(&xprt->sc_lock);
 			atomic_inc(&rdma_stat_sq_starve);
 
@@ -1266,19 +1272,26 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
 				return 0;
 			continue;
 		}
-		/* Bumped used SQ WR count and post */
-		svc_xprt_get(&xprt->sc_xprt);
+		/* Take a transport ref for each WR posted */
+		for (i = 0; i < wr_count; i++)
+			svc_xprt_get(&xprt->sc_xprt);
+
+		/* Bump used SQ WR count and post */
+		atomic_add(wr_count, &xprt->sc_sq_count);
 		ret = ib_post_send(xprt->sc_qp, wr, &bad_wr);
-		if (!ret)
-			atomic_inc(&xprt->sc_sq_count);
-		else {
-			svc_xprt_put(&xprt->sc_xprt);
+		if (ret) {
+			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
+			atomic_sub(wr_count, &xprt->sc_sq_count);
+			for (i = 0; i < wr_count; i ++)
+				svc_xprt_put(&xprt->sc_xprt);
 			dprintk("svcrdma: failed to post SQ WR rc=%d, "
 			       "sc_sq_count=%d, sc_sq_depth=%d\n",
 			       ret, atomic_read(&xprt->sc_sq_count),
 			       xprt->sc_sq_depth);
 		}
 		spin_unlock_bh(&xprt->sc_lock);
+		if (ret)
+			wake_up(&xprt->sc_send_wait);
 		break;
 	}
 	return ret;
