Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:49152 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbaILStY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Sep 2014 14:49:24 -0400
Received: by mail-ie0-f178.google.com with SMTP id tp5so1496019ieb.9
        for <linux-nfs@vger.kernel.org>; Fri, 12 Sep 2014 11:49:24 -0700 (PDT)
From: Chris Perl <chris.perl@gmail.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Chris Perl <chris.perl@gmail.com>
Subject: [PATCH] nfs-utils: nfs_get_tcpclient/nfs_get_udpclient - make bind(2) implicit
Date: Fri, 12 Sep 2014 14:49:22 -0400
Message-Id: <1410547762-27285-1-git-send-email-chris.perl@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When attempting to establish a local ephemeral endpoint for a TCP or UDP
socket, do not explicitly call bind(2), instead let it happen implicilty when
the socket is first used.

The main motivating factor for this change is when TCP runs out of unique
ephemeral ports (i.e.  cannot find any ephemeral ports which are not a part of
*any* TCP connection).  In this situation if you explicitly call bind(2), then
the call will fail with EADDRINUSE.  However, if you allow the allocation of an
ephemeral port to happen implicitly as part of connect(2) (or other functions),
then ephemeral ports can be reused, so long as the combination of (local_ip,
local_port, remote_ip, remote_port) is unique for TCP sockets on the system.

This doesn't matter for UDP sockets, but it seemed easiest to treat TCP and UDP
sockets the same.

This can allow mount.nfs(8) to continue to function successfully, even in the
face of misbehaving applications which are creating a large number of TCP
connections.

Signed-off-by: Chris Perl <chris.perl@gmail.com>
---
 support/nfs/rpc_socket.c | 68 ++++++++++++++----------------------------------
 1 file changed, 20 insertions(+), 48 deletions(-)

diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 7896cd2..2900d18 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -106,36 +106,6 @@ static CLIENT *nfs_get_localclient(const struct sockaddr *sap,
 	return client;
 }
 
-/*
- * Bind a socket using an unused ephemeral source port.
- *
- * Returns zero on success, or returns -1 on error.  errno is
- * set to reflect the nature of the error.
- */
-static int nfs_bind(const int sock, const sa_family_t family)
-{
-	struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-		.sin_addr.s_addr	= htonl(INADDR_ANY),
-	};
-	struct sockaddr_in6 sin6 = {
-		.sin6_family		= AF_INET6,
-		.sin6_addr		= IN6ADDR_ANY_INIT,
-	};
-
-	switch (family) {
-	case AF_INET:
-		return bind(sock, (struct sockaddr *)(char *)&sin,
-					(socklen_t)sizeof(sin));
-	case AF_INET6:
-		return bind(sock, (struct sockaddr *)(char *)&sin6,
-					(socklen_t)sizeof(sin6));
-	}
-
-	errno = EAFNOSUPPORT;
-	return -1;
-}
-
 #ifdef HAVE_LIBTIRPC
 
 /*
@@ -276,7 +246,8 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 				 const int resvport)
 {
 	CLIENT *client;
-	int ret, sock;
+	int ret = 0;
+	int sock = 0;
 #ifdef HAVE_LIBTIRPC
 	struct sockaddr_storage address;
 	const struct netbuf nbuf = {
@@ -300,15 +271,15 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 		return NULL;
 	}
 
-	if (resvport)
+	if (resvport) {
 		ret = nfs_bindresvport(sock, sap->sa_family);
-	else
-		ret = nfs_bind(sock, sap->sa_family);
-	if (ret < 0) {
-		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-		rpc_createerr.cf_error.re_errno = errno;
-		(void)close(sock);
-		return NULL;
+
+		if (ret < 0) {
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno = errno;
+			(void)close(sock);
+			return NULL;
+		}
 	}
 
 	if (timeout->tv_sec == -1)
@@ -358,7 +329,8 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 				 const int resvport)
 {
 	CLIENT *client;
-	int ret, sock;
+	int ret = 0;
+	int sock = 0;
 #ifdef HAVE_LIBTIRPC
 	struct sockaddr_storage address;
 	const struct netbuf nbuf = {
@@ -382,15 +354,15 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 		return NULL;
 	}
 
-	if (resvport)
+	if (resvport) {
 		ret = nfs_bindresvport(sock, sap->sa_family);
-	else
-		ret = nfs_bind(sock, sap->sa_family);
-	if (ret < 0) {
-		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-		rpc_createerr.cf_error.re_errno = errno;
-		(void)close(sock);
-		return NULL;
+
+		if (ret < 0) {
+			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
+			rpc_createerr.cf_error.re_errno = errno;
+			(void)close(sock);
+			return NULL;
+		}
 	}
 
 	if (timeout->tv_sec == -1)
-- 
1.8.3.1

