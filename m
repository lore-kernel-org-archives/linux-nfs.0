From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/3] Revert "sunrpc: move the close processing after do recvfrom method"
Date: Wed, 31 Mar 2010 15:34:09 -0400
Message-ID: <1270064050-5239-2-git-send-email-bfields@citi.umich.edu>
References: <20100331193029.GC4937@fieldses.org>
 <1270064050-5239-1-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: stable@kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33505 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756859Ab0CaTb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Mar 2010 15:31:59 -0400
In-Reply-To: <1270064050-5239-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit b0401d725334a94d57335790b8ac2404144748ee, which
moved svc_delete_xprt() outside of XPT_BUSY, and allowed it to be called
after svc_xpt_recived(), removing its last reference and destroying it
after it had already been queued for future processing.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svc_xprt.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 929f6db..3fbd6ba 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -711,7 +711,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
-	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+		dprintk("svc_recv: found XPT_CLOSE\n");
+		svc_delete_xprt(xprt);
+	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
@@ -737,7 +740,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(xprt);
-	} else if (!test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+	} else {
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
 			rqstp, pool->sp_id, xprt,
 			atomic_read(&xprt->xpt_ref.refcount));
@@ -750,11 +753,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		dprintk("svc: got len=%d\n", len);
 	}
 
-	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
-		dprintk("svc_recv: found XPT_CLOSE\n");
-		svc_delete_xprt(xprt);
-	}
-
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
 		rqstp->rq_res.len = 0;
-- 
1.6.3.3

