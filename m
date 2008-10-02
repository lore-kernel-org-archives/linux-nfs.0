From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] nfs-utils: Clean up support/nfs/rpcmisc.c:closedown()
Date: Thu, 02 Oct 2008 11:54:12 -0400
Message-ID: <20081002155412.25618.89699.stgit@manray.1015granger.net>
References: <20081002154752.25618.18842.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:14694 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946AbYJBPyp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2008 11:54:45 -0400
In-Reply-To: <20081002154752.25618.18842.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: update closedown()'s synopsis to modern C style, and move the
function so we can remove the forward declaration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpcmisc.c |   48 +++++++++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index aa23601..dab2be8 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -37,7 +37,6 @@
 #define socklen_t int
 #endif
 
-static void	closedown(int sig);
 static int	makesock(int port, int proto);
 
 #define _RPCSVC_CLOSEDOWN	120
@@ -45,6 +44,31 @@ int	_rpcpmstart = 0;
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
@@ -139,28 +163,6 @@ rpc_init(char *name, int prog, int vers,
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
 /*
  * Create listener socket for a given port
  *

