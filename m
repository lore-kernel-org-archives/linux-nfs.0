From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/17] mount: refactor error handling in get_socket()
Date: Mon, 18 Feb 2008 13:35:51 -0500
Message-ID: <20080218183551.19060.94032.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:55579 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbYBRSfx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:35:53 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIZpp8017634
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:35:52 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIZp7t019330
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:35:51 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor get_socket's error-handling exits.  This makes it cleaner to add
IPv6 address support to the error messages.

Note that we moved the socket close(2) out of mainline get_socket() for the
error cases.  We must preserve the order of referencing errno before
calling close(2), so that close(2) doesn't tromp on errno before we can
report the value set by the failing call.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac          |    1 
 utils/mount/network.c |  146 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 91 insertions(+), 56 deletions(-)

diff --git a/configure.ac b/configure.ac
index 233cd57..3e600b4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -297,6 +297,7 @@ AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
 have_bindresvport6=none
 if test "$enable_ipv6" = yes; then
     AC_CHECK_FUNC(bindresvport6, [have_bindresvport6=lib])
+    AC_CHECK_FUNC(inet_ntop, , , AC_MSG_ERROR(Function 'inet_ntop' not found.))
 fi
 AM_CONDITIONAL(CONFIG_BRP6, [test "$have_bindresvport6" = "none"])
 
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 92ccc3d..c54b312 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -175,6 +175,85 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
 	return 1;
 }
 
+static int __nfs_gs_err_done(const int error)
+{
+	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+	rpc_createerr.cf_error.re_errno = error;
+	return RPC_ANYSOCK;
+}
+
+static int __nfs_gs_err_socket(const unsigned short protocol, const int error)
+{
+	if (verbose)
+		nfs_error(_("%s: Unable to create %s socket: errno %d (%s)\n"),
+				progname, protocol == IPPROTO_UDP ?
+							_("UDP") : _("TCP"),
+				error, strerror(error));
+	return __nfs_gs_err_done(error);
+}
+
+static int __nfs_gs_err_bindresvport(const int socket,
+					const unsigned short protocol,
+					const int error)
+{
+	close(socket);
+	if (verbose)
+		nfs_error(_("%s: Unable to bindresvport %s socket: "
+							"errno %d (%s)\n"),
+				progname, protocol == IPPROTO_UDP ?
+							_("UDP") : _("TCP"),
+				error, strerror(error));
+	return __nfs_gs_err_done(error);
+}
+
+static int __nfs_gs_err_bind(const int socket, const unsigned short protocol,
+				const int error)
+{
+	close(socket);
+	if (verbose)
+		nfs_error(_("%s: Unable to bind to %s socket: errno %d (%s)\n"),
+				progname, protocol == IPPROTO_UDP ?
+							_("UDP") : _("TCP"),
+				error, strerror(error));
+	return __nfs_gs_err_done(error);
+}
+
+static int __nfs_gs_err_connect(const int socket, const struct sockaddr *saddr,
+				const int error)
+{
+	close(socket);
+	if (verbose) {
+#ifdef IPV6_SUPPORTED
+		char buf[INET6_ADDRSTRLEN];
+		unsigned short port = 0;
+		void *inet_addr = NULL;
+
+		buf[0] = '\0';
+
+		switch (saddr->sa_family) {
+		case AF_INET:
+			port = ntohs(((struct sockaddr_in *)saddr)->sin_port);
+			inet_addr = &((struct sockaddr_in *)saddr)->sin_addr;
+			break;
+		case AF_INET6:
+			port = ntohs(((struct sockaddr_in6 *)saddr)->sin6_port);
+			inet_addr = &((struct sockaddr_in6 *)saddr)->sin6_addr;
+			break;
+		}
+
+		inet_ntop(saddr->sa_family, inet_addr, buf, sizeof(buf));
+#else
+		struct sockaddr_in *sin = (struct sockaddr_in *)saddr;
+		char *buf = inet_ntoa(sin->sin_addr);
+		unsigned short port = ntohs(sin->sin_port);
+#endif
+
+		nfs_error(_("%s: Unable to connect to %s:%u, errno %d (%s)\n"),
+				progname, buf, port, error, strerror(error));
+	}
+	return __nfs_gs_err_done(error);
+}
+
 /*
  * Attempt to connect a socket, but time out after "timeout" seconds.
  *
@@ -231,76 +310,31 @@ out:
 static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 			unsigned int timeout, int resvp, int conn)
 {
-	int so, cc, type;
+	int so, type;
 	struct sockaddr_in laddr;
 	socklen_t namelen = sizeof(laddr);
 
 	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
-	if ((so = socket (AF_INET, type, p_prot)) < 0)
-		goto err_socket;
+	if ((so = socket(AF_INET, type, p_prot)) < 0)
+		return __nfs_gs_err_socket(p_prot, errno);
 
 	laddr.sin_family = AF_INET;
 	laddr.sin_port = 0;
 	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
 	if (resvp) {
 		if (bindresvport(so, &laddr) < 0)
-			goto err_bindresvport;
+			return __nfs_gs_err_bindresvport(so, p_prot, errno);
 	} else {
-		cc = bind(so, (struct sockaddr *)&laddr, namelen);
-		if (cc < 0)
-			goto err_bind;
+		if (bind(so, (struct sockaddr *)&laddr, namelen) < 0)
+			return __nfs_gs_err_bind(so, p_prot, errno);
 	}
-	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
-		cc = connect_to(so, (struct sockaddr *)saddr, namelen,
-				timeout);
-		if (cc < 0)
-			goto err_connect;
+	if (type == SOCK_STREAM || conn) {
+		if (connect_to(so, (struct sockaddr *)saddr, namelen,
+								timeout) < 0)
+			return __nfs_gs_err_connect(so, (struct sockaddr *)saddr,
+							errno);
 	}
 	return so;
-
-err_socket:
-	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-	rpc_createerr.cf_error.re_errno = errno;
-	if (verbose) {
-		nfs_error(_("%s: Unable to create %s socket: errno %d (%s)\n"),
-			progname, p_prot == IPPROTO_UDP ? _("UDP") : _("TCP"),
-			errno, strerror(errno));
-	}
-	return RPC_ANYSOCK;
-
-err_bindresvport:
-	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-	rpc_createerr.cf_error.re_errno = errno;
-	if (verbose) {
-		nfs_error(_("%s: Unable to bindresvport %s socket: errno %d"
-				" (%s)\n"),
-			progname, p_prot == IPPROTO_UDP ? _("UDP") : _("TCP"),
-			errno, strerror(errno));
-	}
-	close(so);
-	return RPC_ANYSOCK;
-
-err_bind:
-	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-	rpc_createerr.cf_error.re_errno = errno;
-	if (verbose) {
-		nfs_error(_("%s: Unable to bind to %s socket: errno %d (%s)\n"),
-			progname, p_prot == IPPROTO_UDP ? _("UDP") : _("TCP"),
-			errno, strerror(errno));
-	}
-	close(so);
-	return RPC_ANYSOCK;
-
-err_connect:
-	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-	rpc_createerr.cf_error.re_errno = errno;
-	if (verbose) {
-		nfs_error(_("%s: Unable to connect to %s:%d, errno %d (%s)\n"),
-			progname, inet_ntoa(saddr->sin_addr),
-			ntohs(saddr->sin_port), errno, strerror(errno));
-	}
-	close(so);
-	return RPC_ANYSOCK;
 }
 
 /*

