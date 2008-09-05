From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/19] nfs-utils: Clean up support/nfs/rpcmisc.c:closedown()
Date: Fri, 05 Sep 2008 17:08:10 -0400
Message-ID: <20080905210809.10001.75136.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49148 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102AbYIEVOV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:14:21 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: update closedown()'s synopsis to modern C style, and move the
function so we can remove the forward declaration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpcmisc.c |   48 +++++++++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index 40c2102..ad53a43 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -38,7 +38,6 @@
 #define socklen_t int
 #endif
 
-static void	closedown(int sig);
 int	makesock(int port, int proto);
 
 #define _RPCSVC_CLOSEDOWN	120
@@ -46,6 +45,31 @@ int	_rpcpmstart = 0;
 int	_rpcfdtype = 0;
 int	_rpcsvcdirty = 0;
 
+static void
+closedown(int sig)
+{
+	(void) signal(sig, closedown);
+
+	if (_rpcsvcdirty == 0) {
+		static int size;
+		int i, openfd;
+
+		if (_rpcfdtype == SOCK_DGRAM)
+			exit(0);
+
+		if (size == 0)
+			size = getdtablesize();
+
+		for (i = 0, openfd = 0; i < size && openfd < 2; i++)
+			if (FD_ISSET(i, &svc_fdset))
+				openfd++;
+		if (openfd <= 1)
+			exit(0);
+	}
+
+	(void) alarm(_RPCSVC_CLOSEDOWN);
+}
+
 void
 rpc_init(char *name, int prog, int vers,
 	 void (*dispatch)(struct svc_req *, register SVCXPRT *),
@@ -144,28 +168,6 @@ rpc_init(char *name, int prog, int vers,
 	}
 }
 
-static void closedown(sig)
-int sig;
-{
-	(void) signal(sig, closedown);
-	if (_rpcsvcdirty == 0) {
-		static int size;
-		int i, openfd;
-
-		if (_rpcfdtype == SOCK_DGRAM)
-			exit(0);
-		if (size == 0) {
-			size = getdtablesize();
-		}
-		for (i = 0, openfd = 0; i < size && openfd < 2; i++)
-			if (FD_ISSET(i, &svc_fdset))
-				openfd++;
-		if (openfd <= 1)
-			exit(0);
-	}
-	(void) alarm(_RPCSVC_CLOSEDOWN);
-}
-
 int makesock(int port, int proto)
 {
 	struct sockaddr_in sin;

