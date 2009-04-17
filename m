From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] support: Provide an API for creating a privileged RPC
	client
Date: Fri, 17 Apr 2009 16:17:42 -0400
Message-ID: <20090417201742.14555.74643.stgit@ingres.1015granger.net>
References: <20090417201021.14555.93852.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet02.oracle.com ([141.146.126.229]:16655 "EHLO
	agminet02.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756472AbZDQVHu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2009 17:07:50 -0400
In-Reply-To: <20090417201021.14555.93852.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We needed to guarantee that some RPC programs, such as PMAP, got an
unprivileged port, to prevent exhausting the local privileged port
space sending RPC requests that don't need such privileges.
nfs_get_rpcclient() provides that feature.

However, some RPC programs, such as MNT and UMNT, require a privileged
port.  So, let's provide an additional API for this that also supports
IPv6 and setting a destination port.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfsrpc.h |   11 +++-
 support/nfs/rpc_socket.c |  140 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 143 insertions(+), 8 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index 097debb..543c35b 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -24,6 +24,7 @@
 #define __NFS_UTILS_NFSRPC_H
 
 #include <rpc/types.h>
+#include <rpc/clnt.h>
 
 /*
  * Conventional RPC program numbers
@@ -54,7 +55,7 @@
 extern rpcprog_t	nfs_getrpcbyname(const rpcprog_t, const char *table[]);
 
 /*
- * Acquire an RPC CLIENT *
+ * Acquire an RPC CLIENT * with an ephemeral source port
  */
 extern CLIENT		*nfs_get_rpcclient(const struct sockaddr *,
 				const socklen_t, const unsigned short,
@@ -62,6 +63,14 @@ extern CLIENT		*nfs_get_rpcclient(const struct sockaddr *,
 				struct timeval *);
 
 /*
+ * Acquire an RPC CLIENT * with a privileged source port
+ */
+extern CLIENT		*nfs_get_priv_rpcclient( const struct sockaddr *,
+				const socklen_t, const unsigned short,
+				const rpcprog_t, const rpcvers_t,
+				struct timeval *);
+
+/*
  * Convert a socket address to a universal address
  */
 extern char		*nfs_sockaddr2universal(const struct sockaddr *,
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 2b11e35..85e6064 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -132,6 +132,58 @@ static int nfs_bind(const int sock, const sa_family_t family)
 	return -1;
 }
 
+#ifdef IPV6_SUPPORT
+
+/*
+ * Bind a socket using an unused privileged source port.
+ *
+ * Returns zero on success, or returns -1 on error.  errno is
+ * set to reflect the nature of the error.
+ */
+static int nfs_bindresvport(const int sock, const sa_family_t family)
+{
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+	};
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+	};
+
+	switch (family) {
+	case AF_INET:
+		return bindresvport_sa(sock, (struct sockaddr *)&sin,
+					(socklen_t)sizeof(sin));
+	case AF_INET6:
+		return bindresvport_sa(sock, (struct sockaddr *)&sin6,
+					(socklen_t)sizeof(sin6));
+	}
+
+	errno = EAFNOSUPPORT;
+	return -1;
+}
+
+#else	/* !IPV6_SUPPORT */
+
+/*
+ * Bind a socket using an unused privileged source port.
+ *
+ * Returns zero on success, or returns -1 on error.  errno is
+ * set to reflect the nature of the error.
+ */
+static int nfs_bindresvport(const int sock, const sa_family_t family)
+{
+	if (family != AF_INET) {
+		errno = EAFNOSUPPORT;
+		return -1;
+	}
+
+	return bindresvport(sock, NULL);
+}
+
+#endif	/* !IPV6_SUPPORT */
+
 /*
  * Perform a non-blocking connect on the socket fd.
  *
@@ -218,7 +270,8 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 				 const socklen_t salen,
 				 const rpcprog_t program,
 				 const rpcvers_t version,
-				 struct timeval *timeout)
+				 struct timeval *timeout,
+				 const int resvport)
 {
 	CLIENT *client;
 	int ret, sock;
@@ -245,7 +298,10 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 		return NULL;
 	}
 
-	ret = nfs_bind(sock, sap->sa_family);
+	if (resvport)
+		ret = nfs_bindresvport(sock, sap->sa_family);
+	else
+		ret = nfs_bind(sock, sap->sa_family);
 	if (ret < 0) {
 		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 		rpc_createerr.cf_error.re_errno = errno;
@@ -294,7 +350,8 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 				 const socklen_t salen,
 				 const rpcprog_t program,
 				 const rpcvers_t version,
-				 struct timeval *timeout)
+				 struct timeval *timeout,
+				 const int resvport)
 {
 	CLIENT *client;
 	int ret, sock;
@@ -321,7 +378,10 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 		return NULL;
 	}
 
-	ret = nfs_bind(sock, sap->sa_family);
+	if (resvport)
+		ret = nfs_bindresvport(sock, sap->sa_family);
+	else
+		ret = nfs_bind(sock, sap->sa_family);
 	if (ret < 0) {
 		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 		rpc_createerr.cf_error.re_errno = errno;
@@ -365,7 +425,8 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
  * @timeout: pointer to request timeout (must not be NULL)
  *
  * Set up an RPC client for communicating with an RPC program @program
- * and @version on the server @sap over @transport.
+ * and @version on the server @sap over @transport.  An unprivileged
+ * source port is used.
  *
  * Returns a pointer to a prepared RPC client if successful, and
  * @timeout is initialized; caller must destroy a non-NULL returned RPC
@@ -405,10 +466,75 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 
 	switch (transport) {
 	case IPPROTO_TCP:
-		return nfs_get_tcpclient(sap, salen, program, version, timeout);
+		return nfs_get_tcpclient(sap, salen, program, version,
+						timeout, 0);
+	case 0:
+	case IPPROTO_UDP:
+		return nfs_get_udpclient(sap, salen, program, version,
+						timeout, 0);
+	}
+
+	rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
+	return NULL;
+}
+
+/**
+ * nfs_get_priv_rpcclient - acquire an RPC client
+ * @sap: pointer to socket address of RPC server
+ * @salen: length of socket address
+ * @transport: IPPROTO_ value of transport protocol to use
+ * @program: RPC program number
+ * @version: RPC version number
+ * @timeout: pointer to request timeout (must not be NULL)
+ *
+ * Set up an RPC client for communicating with an RPC program @program
+ * and @version on the server @sap over @transport.  A privileged
+ * source port is used.
+ *
+ * Returns a pointer to a prepared RPC client if successful, and
+ * @timeout is initialized; caller must destroy a non-NULL returned RPC
+ * client.  Otherwise returns NULL, and rpc_createerr.cf_stat is set to
+ * reflect the error.
+ */
+CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
+			       const socklen_t salen,
+			       const unsigned short transport,
+			       const rpcprog_t program,
+			       const rpcvers_t version,
+			       struct timeval *timeout)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+
+	switch (sap->sa_family) {
+	case AF_LOCAL:
+		return nfs_get_localclient(sap, salen, program,
+						version, timeout);
+	case AF_INET:
+		if (sin->sin_port == 0) {
+			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
+			return NULL;
+		}
+		break;
+	case AF_INET6:
+		if (sin6->sin6_port == 0) {
+			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
+			return NULL;
+		}
+		break;
+	default:
+		rpc_createerr.cf_stat = RPC_UNKNOWNHOST;
+		return NULL;
+	}
+
+	switch (transport) {
+	case IPPROTO_TCP:
+		return nfs_get_tcpclient(sap, salen, program, version,
+						timeout, 1);
 	case 0:
 	case IPPROTO_UDP:
-		return nfs_get_udpclient(sap, salen, program, version, timeout);
+		return nfs_get_udpclient(sap, salen, program, version,
+						timeout, 1);
 	}
 
 	rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;

