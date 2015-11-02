Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932117AbbKBWM7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2015 17:12:59 -0500
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] handle_reply: Don't use the xp_auth pointer directly
Date: Mon,  2 Nov 2015 17:12:56 -0500
Message-Id: <1446502376-8252-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the latest libtirpc version to access the xp_auth
one must use the SVC_XP_AUTH macro. To be backwards
compatible a couple ifdefs were added to use the
macro when it exists.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpcb_svc_com.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
index 4ae93f1..22d6c84 100644
--- a/src/rpcb_svc_com.c
+++ b/src/rpcb_svc_com.c
@@ -1295,10 +1295,17 @@ handle_reply(int fd, SVCXPRT *xprt)
 	a.rmt_localvers = fi->versnum;
 
 	xprt_set_caller(xprt, fi);
+#if defined(SVC_XP_AUTH)
+	SVC_XP_AUTH(xprt) = svc_auth_none;
+#else 
 	xprt->xp_auth = &svc_auth_none;
+#endif
 	svc_sendreply(xprt, (xdrproc_t) xdr_rmtcall_result, (char *) &a);
+#if !defined(SVC_XP_AUTH)
 	SVCAUTH_DESTROY(xprt->xp_auth);
 	xprt->xp_auth = NULL;
+#endif
+
 done:
 	if (buffer)
 		free(buffer);
-- 
2.6.2

