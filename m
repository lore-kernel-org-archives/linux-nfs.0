From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/19] nfs-utils: make makesock() static
Date: Fri, 05 Sep 2008 17:08:15 -0400
Message-ID: <20080905210815.10001.41734.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49164 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbYIEVOW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:14:22 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

 support/include/rpcmisc.h |    1 -
 support/nfs/rpcmisc.c     |   76 ++++++++++++++++++++++++---------------------
 2 files changed, 40 insertions(+), 37 deletions(-)

diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
index 35c5011..5814a63 100644
--- a/support/include/rpcmisc.h
+++ b/support/include/rpcmisc.h
@@ -42,7 +42,6 @@ struct rpc_dtable {
 	}
 
 
-int		makesock(int port, int proto);
 void		rpc_init(char *name, int prog, int vers,
 				void (*dispatch)(struct svc_req *, SVCXPRT *),
 				int defport);
diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index ad53a43..9d76e5d 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -38,8 +38,6 @@
 #define socklen_t int
 #endif
 
-int	makesock(int port, int proto);
-
 #define _RPCSVC_CLOSEDOWN	120
 int	_rpcpmstart = 0;
 int	_rpcfdtype = 0;
@@ -70,6 +68,46 @@ closedown(int sig)
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
@@ -167,37 +205,3 @@ rpc_init(char *name, int prog, int vers,
 		alarm (_RPCSVC_CLOSEDOWN);
 	}
 }
-
-int makesock(int port, int proto)
-{
-	struct sockaddr_in sin;
-	int	s;
-	int	sock_type;
-	int	val;
-
-	sock_type = (proto == IPPROTO_UDP) ? SOCK_DGRAM : SOCK_STREAM;
-	s = socket(AF_INET, sock_type, proto);
-	if (s < 0) {
-		xlog(L_FATAL, "Could not make a socket: %s\n",
-					strerror(errno));
-		return (-1);
-	}
-	memset((char *) &sin, 0, sizeof(sin));
-	sin.sin_family = AF_INET;
-	sin.sin_addr.s_addr = INADDR_ANY;
-	sin.sin_port = htons(port);
-
-	val = 1;
-	if (proto == IPPROTO_TCP)
-		if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR,
-			       &val, sizeof(val)) < 0)
-			xlog(L_ERROR, "setsockopt failed: %s\n",
-			     strerror(errno));
-
-	if (bind(s, (struct sockaddr *) &sin, sizeof(sin)) == -1) {
-		xlog(L_FATAL, "Could not bind name to socket: %s\n",
-					strerror(errno));
-		return (-1);
-	}
-	return (s);
-}

