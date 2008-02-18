From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/17] mount: support IPv6 in get_socket()
Date: Mon, 18 Feb 2008 13:36:12 -0500
Message-ID: <20080218183612.19060.82161.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:56285 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbYBRSgN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:13 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIaCMo018687
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:12 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIaCJn019354
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:12 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The get_socket() function is the heart of util/mount/network.c.  Change
the function's signature to accept a "struct sockaddr *", and add support
for AF_INET6 addresses inside get_socket().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |  109 ++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 80 insertions(+), 29 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 5720a4e..ee8aa28 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -254,6 +254,49 @@ static int __nfs_gs_err_connect(const int socket, const struct sockaddr *saddr,
 	return __nfs_gs_err_done(error);
 }
 
+static void __nfs_gs_init_any_ipv4(struct sockaddr *sap, socklen_t *len)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+
+	sin->sin_family = AF_INET;
+	sin->sin_addr.s_addr = htonl(INADDR_ANY);
+	sin->sin_port = 0;
+
+	*len = sizeof(struct sockaddr_in);
+}
+
+#ifdef IPV6_SUPPORTED
+static void __nfs_gs_init_any_ipv6(struct sockaddr *sap, socklen_t *len)
+{
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+
+	sin6->sin6_family = AF_INET6;
+	sin6->sin6_addr = in6addr_any;
+	sin6->sin6_port = 0;
+
+	*len = sizeof(struct sockaddr_in6);
+}
+
+static void __nfs_gs_init_any_address(const sa_family_t family,
+					struct sockaddr *sap, socklen_t *len)
+{
+	*len = 0;
+
+	switch (family) {
+	case AF_INET:
+		__nfs_gs_init_any_ipv4(sap, len);
+	case AF_INET6:
+		__nfs_gs_init_any_ipv6(sap, len);
+	}
+}
+#else
+static void __nfs_gs_init_any_address(const sa_family_t family,
+					struct sockaddr *sap, socklen_t *len)
+{
+	__nfs_gs_init_any_ipv4(sap, len);
+}
+#endif
+
 #ifdef IPV6_SUPPORTED
 static int __nfs_bindresvport(const int socket, struct sockaddr *sap)
 {
@@ -326,35 +369,40 @@ out:
 /*
  * Create a socket that is locally bound to a reserved or non-reserved port.
  *
- * The caller should check rpc_createerr to determine the cause of any error.
+ * Returns a positive integer representing a freshly created socket
+ * file descriptor, or the value RPC_ANYSOCK if an error occurs.  The caller
+ * should check rpc_createerr to determine the cause of the error.
  */
-static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
-			time_t timeout, int resvp, int conn)
+static int nfs_getsocket(const struct sockaddr *saddr,
+				const unsigned short protocol,
+				const time_t timeout,
+				const int resvp, const int conn)
 {
-	int so, type;
-	struct sockaddr_in laddr;
-	socklen_t namelen = sizeof(laddr);
+	struct sockaddr_in6 dummy;
+	struct sockaddr *any_addr = (struct sockaddr *)&dummy;
+	socklen_t addrlen;
+	int type = (protocol == IPPROTO_UDP) ? SOCK_DGRAM : SOCK_STREAM;
+	int so;
+
+	/* Use address family and protocol family interchangeably */
+	so = socket(saddr->sa_family, type, protocol);
+	if (so < 0)
+		return __nfs_gs_err_socket(protocol, errno);
 
-	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
-	if ((so = socket(AF_INET, type, p_prot)) < 0)
-		return __nfs_gs_err_socket(p_prot, errno);
+	__nfs_gs_init_any_address(saddr->sa_family, any_addr, &addrlen);
 
-	laddr.sin_family = AF_INET;
-	laddr.sin_port = 0;
-	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
 	if (resvp) {
-		if (__nfs_bindresvport(so, (struct sockaddr *)&laddr) < 0)
-			return __nfs_gs_err_bindresvport(so, p_prot, errno);
-	} else {
-		if (bind(so, (struct sockaddr *)&laddr, namelen) < 0)
-			return __nfs_gs_err_bind(so, p_prot, errno);
-	}
-	if (type == SOCK_STREAM || conn) {
-		if (__nfs_gs_connect_with_timeout(so, (struct sockaddr *)saddr,
-							namelen, timeout) < 0)
-			return __nfs_gs_err_connect(so, (struct sockaddr *)saddr,
-							errno);
-	}
+		if (__nfs_bindresvport(so, any_addr) < 0)
+			return __nfs_gs_err_bindresvport(so, protocol, errno);
+	} else
+		if (bind(so, any_addr, addrlen) < 0)
+			return __nfs_gs_err_bind(so, protocol, errno);
+
+	if (type == SOCK_STREAM || conn)
+		if (__nfs_gs_connect_with_timeout(so, saddr, addrlen,
+								timeout) < 0)
+			return __nfs_gs_err_connect(so, saddr, errno);
+
 	return so;
 }
 
@@ -381,7 +429,8 @@ static unsigned short getport(struct sockaddr_in *saddr,
 	bind_saddr = *saddr;
 	bind_saddr.sin_port = htons(PMAPPORT);
 
-	socket = get_socket(&bind_saddr, proto, PMAP_TIMEOUT, FALSE, FALSE);
+	socket = nfs_getsocket((struct sockaddr *)&bind_saddr, proto,
+				PMAP_TIMEOUT, FALSE, FALSE);
 	if (socket == RPC_ANYSOCK) {
 		if (proto == IPPROTO_TCP &&
 		    rpc_createerr.cf_error.re_errno == ETIMEDOUT)
@@ -674,8 +723,8 @@ CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
 	CLIENT *clnt = NULL;
 
 	mnt_saddr->sin_port = htons((u_short)mnt_pmap->pm_port);
-	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, MOUNT_TIMEOUT,
-				TRUE, FALSE);
+	*msock = nfs_getsocket((struct sockaddr *)mnt_saddr, mnt_pmap->pm_prot,
+				MOUNT_TIMEOUT, TRUE, FALSE);
 	if (*msock == RPC_ANYSOCK) {
 		if (rpc_createerr.cf_error.re_errno == EADDRINUSE)
 			/*
@@ -750,7 +799,8 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 	struct sockaddr dissolve;
 
 	rpc_createerr.cf_stat = stat = 0;
-	sock = get_socket(saddr, prot, CONNECT_TIMEOUT, FALSE, TRUE);
+	sock = nfs_getsocket((struct sockaddr *)saddr, prot,
+				CONNECT_TIMEOUT, FALSE, TRUE);
 	if (sock == RPC_ANYSOCK) {
 		if (rpc_createerr.cf_error.re_errno == ETIMEDOUT) {
 			/*
@@ -827,7 +877,8 @@ int get_client_address(struct sockaddr_in *saddr, struct sockaddr_in *caddr)
 	socklen_t len = sizeof(*caddr);
 	int socket, err;
 
-	socket = get_socket(saddr, IPPROTO_UDP, CONNECT_TIMEOUT, FALSE, TRUE);
+	socket = nfs_getsocket((struct sockaddr *)saddr, IPPROTO_UDP,
+				CONNECT_TIMEOUT, FALSE, TRUE);
 	if (socket == RPC_ANYSOCK)
 		return 0;
 

