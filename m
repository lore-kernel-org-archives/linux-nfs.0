From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] nfs-utils: make makesock() static
Date: Thu, 02 Oct 2008 11:54:18 -0400
Message-ID: <20081002155417.25618.16561.stgit@manray.1015granger.net>
References: <20081002154752.25618.18842.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:14675 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbYJBPyp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2008 11:54:45 -0400
In-Reply-To: <20081002154752.25618.18842.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  The makesock() function can become static since it is only used in
rpcmisc.c, where it is defined.  Fix some minor nits while we're in the area:

 o  Move it so we can remove it's forward declaration.

 o  Get rid of unneeded newlines in the xlog() format strings.

 o  Use htonl(INADDR_ANY) instead of INADDR_ANY to initialize sin_addr.
    Should make no run-time difference, but is slightly more proper,
    as the standard definition of INADDR_ANY is in host byte-order.

 o  Remove the parentheses in the "return" statements.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpcmisc.c |   82 ++++++++++++++++++++++++-------------------------
 1 files changed, 40 insertions(+), 42 deletions(-)

diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index dab2be8..a0854e7 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -37,8 +37,6 @@
 #define socklen_t int
 #endif
 
-static int	makesock(int port, int proto);
-
 #define _RPCSVC_CLOSEDOWN	120
 int	_rpcpmstart = 0;
 int	_rpcfdtype = 0;
@@ -69,6 +67,46 @@ closedown(int sig)
 	(void) alarm(_RPCSVC_CLOSEDOWN);
 }
 
+/*
+ * Create listener socket for a given port
+ *
+ * Return an open network socket on success; otherwise return -1
+ * if some error occurs.
+ */
+static int
+makesock(int port, int proto)
+{
+	struct sockaddr_in sin;
+	int	sock, sock_type, val;
+
+	sock_type = (proto == IPPROTO_UDP) ? SOCK_DGRAM : SOCK_STREAM;
+	sock = socket(AF_INET, sock_type, proto);
+	if (sock < 0) {
+		xlog(L_FATAL, "Could not make a socket: %s",
+					strerror(errno));
+		return -1;
+	}
+	memset((char *) &sin, 0, sizeof(sin));
+	sin.sin_family = AF_INET;
+	sin.sin_addr.s_addr = htonl(INADDR_ANY);
+	sin.sin_port = htons(port);
+
+	val = 1;
+	if (proto == IPPROTO_TCP)
+		if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
+			       &val, sizeof(val)) < 0)
+			xlog(L_ERROR, "setsockopt failed: %s",
+			     strerror(errno));
+
+	if (bind(sock, (struct sockaddr *) &sin, sizeof(sin)) == -1) {
+		xlog(L_FATAL, "Could not bind name to socket: %s",
+					strerror(errno));
+		return -1;
+	}
+
+	return sock;
+}
+
 void
 rpc_init(char *name, int prog, int vers,
 	 void (*dispatch)(struct svc_req *, register SVCXPRT *),
@@ -162,43 +200,3 @@ rpc_init(char *name, int prog, int vers,
 		alarm(_RPCSVC_CLOSEDOWN);
 	}
 }
-
-/*
- * Create listener socket for a given port
- *
- * Return an open network socket on success; otherwise return -1
- * if some error occurs.
- */
-static int
-makesock(int port, int proto)
-{
-	struct sockaddr_in sin;
-	int	sock, sock_type, val;
-
-	sock_type = (proto == IPPROTO_UDP) ? SOCK_DGRAM : SOCK_STREAM;
-	sock = socket(AF_INET, sock_type, proto);
-	if (sock < 0) {
-		xlog(L_FATAL, "Could not make a socket: %s",
-					strerror(errno));
-		return -1;
-	}
-	memset((char *) &sin, 0, sizeof(sin));
-	sin.sin_family = AF_INET;
-	sin.sin_addr.s_addr = htonl(INADDR_ANY);
-	sin.sin_port = htons(port);
-
-	val = 1;
-	if (proto == IPPROTO_TCP)
-		if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
-			       &val, sizeof(val)) < 0)
-			xlog(L_ERROR, "setsockopt failed: %s",
-			     strerror(errno));
-
-	if (bind(sock, (struct sockaddr *) &sin, sizeof(sin)) == -1) {
-		xlog(L_FATAL, "Could not bind name to socket: %s",
-					strerror(errno));
-		return -1;
-	}
-
- 	return sock;
-}

