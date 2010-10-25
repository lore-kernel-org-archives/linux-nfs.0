Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54549 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638Ab0JYBVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Oct 2010 21:21:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: neilb@suse.de, Menyhart Zoltan <Zoltan.Menyhart@bull.net>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] svcrpc: no need for XPT_DEAD check in svc_xprt_enqueue
Date: Sun, 24 Oct 2010 21:21:32 -0400
Message-Id: <1287969693-12340-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20101025010923.GB11470@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If any xprt marked DEAD is also left BUSY for the rest of its life, then
the XPT_DEAD check here is superfluous--we'll get the same result from
the XPT_BUSY check just after.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 409881a..3a771f0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -330,12 +330,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 		       "svc_xprt_enqueue: "
 		       "threads and transports both waiting??\n");
 
-	if (test_bit(XPT_DEAD, &xprt->xpt_flags)) {
-		/* Don't enqueue dead transports */
-		dprintk("svc: transport %p is dead, not enqueued\n", xprt);
-		goto out_unlock;
-	}
-
 	pool->sp_stats.packets++;
 
 	/* Mark transport as busy. It will remain in this state until
-- 
1.7.1

