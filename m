From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NLM: Refactor make_socks() function
Date: Wed, 31 Dec 2008 16:06:04 -0500
Message-ID: <20081231210603.4959.97743.stgit@ingres.1015granger.net>
References: <20081231210449.4959.41094.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:31692 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbYLaVHB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Dec 2008 16:07:01 -0500
In-Reply-To: <20081231210449.4959.41094.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: extract common logic in NLM's make_socks() function
into a helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index fc7c453..955cfac 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -198,6 +198,19 @@ lockd(void *vrqstp)
 	return 0;
 }
 
+static int create_lockd_listener(struct svc_serv *serv, char *name,
+				 unsigned short port)
+{
+	struct svc_xprt *xprt;
+
+	xprt = svc_find_xprt(serv, name, 0, 0);
+	if (xprt == NULL)
+		return svc_create_xprt(serv, name, port, SVC_SOCK_DEFAULTS);
+
+	svc_xprt_put(xprt);
+	return 0;
+}
+
 /*
  * Ensure there are active UDP and TCP listeners for lockd.
  *
@@ -211,23 +224,11 @@ lockd(void *vrqstp)
 static int make_socks(struct svc_serv *serv)
 {
 	static int warned;
-	struct svc_xprt *xprt;
 	int err = 0;
 
-	xprt = svc_find_xprt(serv, "udp", 0, 0);
-	if (!xprt)
-		err = svc_create_xprt(serv, "udp", nlm_udpport,
-				      SVC_SOCK_DEFAULTS);
-	else
-		svc_xprt_put(xprt);
-	if (err >= 0) {
-		xprt = svc_find_xprt(serv, "tcp", 0, 0);
-		if (!xprt)
-			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
-					      SVC_SOCK_DEFAULTS);
-		else
-			svc_xprt_put(xprt);
-	}
+	err = create_lockd_listener(serv, "udp", nlm_udpport);
+	if (err >= 0)
+		err = create_lockd_listener(serv, "tcp", nlm_tcpport);
 	if (err >= 0) {
 		warned = 0;
 		err = 0;

