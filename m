Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:43458 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756958Ab2JWOxa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:30 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 16/25] SUNRPC: remove BUG_ON in svc_xprt_received
Date: Tue, 23 Oct 2012 10:43:40 -0400
Message-Id: <1351003429-18887-17-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with a WARN_ON_ONCE() and early return.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/svc_xprt.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 194d865..be89bb6 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -218,7 +218,9 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
  */
 static void svc_xprt_received(struct svc_xprt *xprt)
 {
-	BUG_ON(!test_bit(XPT_BUSY, &xprt->xpt_flags));
+	WARN_ON_ONCE(!test_bit(XPT_BUSY, &xprt->xpt_flags));
+	if (!test_bit(XPT_BUSY, &xprt->xpt_flags))
+		return;
 	/* As soon as we clear busy, the xprt could be closed and
 	 * 'put', so we need a reference to call svc_xprt_enqueue with:
 	 */
-- 
1.7.9.6 (Apple Git-31.1)

