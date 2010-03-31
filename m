From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/3] Revert "sunrpc: fix peername failed on closed listener"
Date: Wed, 31 Mar 2010 15:34:08 -0400
Message-ID: <1270064050-5239-1-git-send-email-bfields@citi.umich.edu>
References: <20100331193029.GC4937@fieldses.org>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: stable@kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756631Ab0CaTb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Mar 2010 15:31:59 -0400
In-Reply-To: <20100331193029.GC4937@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit b292cf9ce70d221c3f04ff62db5ab13d9a249ca8.  The
commit that it attempted to patch up,
b0401d725334a94d57335790b8ac2404144748ee, was fundamentally wrong, and
will also be reverted.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svc_xprt.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index dafd341..929f6db 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -711,8 +711,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
-	if (test_bit(XPT_LISTENER, &xprt->xpt_flags) &&
-	    !test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
-- 
1.6.3.3

