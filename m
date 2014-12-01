Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:43291 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbaLASpb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2014 13:45:31 -0500
Received: by mail-qg0-f47.google.com with SMTP id z60so8004235qgd.6
        for <linux-nfs@vger.kernel.org>; Mon, 01 Dec 2014 10:45:30 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: only call test_bit once in svc_xprt_received
Date: Mon,  1 Dec 2014 13:45:24 -0500
Message-Id: <1417459524-9086-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...move the WARN_ON_ONCE inside the following if block since they use
the same condition.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/svc_xprt.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 0ae1d78d934d..40ecda40c2ec 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -220,9 +220,11 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
  */
 static void svc_xprt_received(struct svc_xprt *xprt)
 {
-	WARN_ON_ONCE(!test_bit(XPT_BUSY, &xprt->xpt_flags));
-	if (!test_bit(XPT_BUSY, &xprt->xpt_flags))
+	if (!test_bit(XPT_BUSY, &xprt->xpt_flags)) {
+		WARN_ONCE(1, "xprt=0x%p already busy!", xprt);
 		return;
+	}
+
 	/* As soon as we clear busy, the xprt could be closed and
 	 * 'put', so we need a reference to call svc_xprt_do_enqueue with:
 	 */
-- 
2.1.0

