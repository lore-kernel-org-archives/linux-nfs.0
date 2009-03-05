From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/9] nfs-utils: replace function-specific switches with
	HAVE_LIBTIRPC
Date: Thu, 05 Mar 2009 12:42:02 -0500
Message-ID: <20090305174202.30471.27257.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64530 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474AbZCERmk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:42:40 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of switching in TI-RPC-specific logic with a function-specific
switch like HAVE_CLNT_VG_CREATE, let's use the more generic
HAVE_LIBTIRPC macro everywhere.

This simplifies ./configure (always a good thing), and makes it more
clear in the source code exactly what the extra conditionally compiled
code is for.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 aclocal/libtirpc.m4      |    5 -----
 support/nfs/getport.c    |   36 +++++++++++++++++----------------
 support/nfs/rpc_socket.c |   50 +++++++++++++++++++++++-----------------------
 3 files changed, 43 insertions(+), 48 deletions(-)

diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index 67c4012..b1f3669 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -15,11 +15,6 @@ AC_DEFUN([AC_LIBTIRPC], [
     AC_CHECK_HEADERS([tirpc/netconfig.h], ,
                      [AC_MSG_ERROR([libtirpc headers not found.])])
 
-    dnl set up HAVE_FOO for various functions
-    AC_CHECK_FUNCS([getnetconfig \
-                    clnt_create clnt_create_timed \
-                    clnt_vc_create clnt_dg_create xdr_rpcb])
-
   fi
 
 ])dnl
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 5da1749..2255b7d 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -40,7 +40,7 @@
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
 
-#ifdef HAVE_TIRPC_NETCONFIG_H
+#ifdef HAVE_LIBTIRPC
 #include <tirpc/netconfig.h>
 #include <tirpc/rpc/rpcb_prot.h>
 #endif
@@ -53,17 +53,17 @@
  * Rpcbind's local socket service does not seem to be working.
  * Disable this logic for now.
  */
-#ifdef HAVE_XDR_RPCB
+#ifdef HAVE_LIBTIRPC
 #undef NFS_GP_LOCAL
-#else	/* HAVE_XDR_RPCB */
+#else	/* !HAVE_LIBTIRPC */
 #undef NFS_GP_LOCAL
-#endif	/* HAVE_XDR_RPCB */
+#endif	/* !HAVE_LIBTIRPC */
 
-#ifdef HAVE_XDR_RPCB
+#ifdef HAVE_LIBTIRPC
 const static rpcvers_t default_rpcb_version = RPCBVERS_4;
-#else
+#else	/* !HAVE_LIBTIRPC */
 const static rpcvers_t default_rpcb_version = PMAPVERS;
-#endif
+#endif	/* !HAVE_LIBTIRPC */
 
 #ifdef HAVE_DECL_AI_ADDRCONFIG
 /*
@@ -242,7 +242,7 @@ static CLIENT *nfs_gp_get_rpcbclient(const struct sockaddr *sap,
  * Returns a '\0'-terminated string if successful; otherwise NULL.
  * rpc_createerr.cf_stat is set to reflect the error.
  */
-#ifdef HAVE_XDR_RPCB
+#ifdef HAVE_LIBTIRPC
 
 static char *nfs_gp_get_netid(const sa_family_t family,
 			      const unsigned short protocol)
@@ -290,7 +290,7 @@ out:
 	return NULL;
 }
 
-#endif	/* HAVE_XDR_RPCB */
+#endif	/* HAVE_LIBTIRPC */
 
 /*
  * Extract a port number from a universal address, and terminate the
@@ -453,7 +453,7 @@ static int nfs_gp_ping(CLIENT *client, struct timeval timeout)
 	return (int)(status == RPC_SUCCESS);
 }
 
-#ifdef HAVE_XDR_RPCB
+#ifdef HAVE_LIBTIRPC
 
 /*
  * Initialize the rpcb argument for a GETADDR request.
@@ -565,7 +565,7 @@ static unsigned short nfs_gp_rpcb_getaddr(CLIENT *client,
 	return port;
 }
 
-#endif	/* HAVE_XDR_RPCB */
+#endif	/* HAVE_LIBTIRPC */
 
 /*
  * Try GETPORT request via rpcbind version 2.
@@ -595,7 +595,7 @@ static unsigned long nfs_gp_pmap_getport(CLIENT *client,
 	return port;
 }
 
-#ifdef HAVE_XDR_RPCB
+#ifdef HAVE_LIBTIRPC
 
 static unsigned short nfs_gp_getport_rpcb(CLIENT *client,
 					  const struct sockaddr *sap,
@@ -617,7 +617,7 @@ static unsigned short nfs_gp_getport_rpcb(CLIENT *client,
 	return port;
 }
 
-#endif	/* HAVE_XDR_RPCB */
+#endif	/* HAVE_LIBTIRPC */
 
 static unsigned long nfs_gp_getport_pmap(CLIENT *client,
 					 const rpcprog_t program,
@@ -652,11 +652,11 @@ static unsigned short nfs_gp_getport(CLIENT *client,
 				     struct timeval timeout)
 {
 	switch (sap->sa_family) {
-#ifdef HAVE_XDR_RPCB
+#ifdef HAVE_LIBTIRPC
 	case AF_INET6:
 		return nfs_gp_getport_rpcb(client, sap, salen, program,
 						version, protocol, timeout);
-#endif	/* HAVE_XDR_RPCB */
+#endif	/* HAVE_LIBTIRPC */
 	case AF_INET:
 		return nfs_gp_getport_pmap(client, program, version,
 							protocol, timeout);
@@ -922,7 +922,7 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
  * address of the same address family.  In this way an RPC server can
  * advertise via rpcbind that it does not support AF_INET6.
  */
-#ifdef HAVE_XDR_RPCB
+#ifdef HAVE_LIBTIRPC
 
 unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 				const socklen_t salen,
@@ -955,7 +955,7 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 	return port;
 }
 
-#else	/* HAVE_XDR_RPCB */
+#else	/* !HAVE_LIBTIRPC */
 
 unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 				const socklen_t salen,
@@ -971,7 +971,7 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 	return 0;
 }
 
-#endif	/* HAVE_XDR_RPCB */
+#endif	/* !HAVE_LIBTIRPC */
 
 /**
  * nfs_pmap_getport - query rpcbind via the portmap protocol (rpcbindv2)
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index b7420d1..4b4b0be 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -40,7 +40,7 @@
 
 #include "nfsrpc.h"
 
-#ifdef HAVE_TIRPC_NETCONFIG_H
+#ifdef HAVE_LIBTIRPC
 
 /*
  * Most of the headers under /usr/include/tirpc are currently
@@ -84,7 +84,7 @@ extern CLIENT *clnt_vc_create(const int, const struct netbuf *,
 			      const rpcprog_t, const rpcvers_t,
 			      u_int, u_int);
 
-#endif	/* HAVE_TIRPC_NETCONFIG_H */
+#endif	/* HAVE_LIBTIRPC */
 
 /*
  * If "-1" is specified in the tv_sec field, use these defaults instead.
@@ -107,14 +107,14 @@ static CLIENT *nfs_get_localclient(const struct sockaddr *sap,
 				   const rpcvers_t version,
 				   struct timeval *timeout)
 {
-#ifdef HAVE_CLNT_VC_CREATE
+#ifdef HAVE_LIBTIRPC
 	struct sockaddr_storage address;
 	const struct netbuf nbuf = {
 		.maxlen		= sizeof(struct sockaddr_un),
 		.len		= (size_t)salen,
 		.buf		= &address,
 	};
-#endif	/* HAVE_CLNT_VC_CREATE */
+#endif	/* HAVE_LIBTIRPC */
 	CLIENT *client;
 	int sock;
 
@@ -128,13 +128,13 @@ static CLIENT *nfs_get_localclient(const struct sockaddr *sap,
 	if (timeout->tv_sec == -1)
 		timeout->tv_sec = NFSRPC_TIMEOUT_TCP;
 
-#ifdef HAVE_CLNT_VC_CREATE
+#ifdef HAVE_LIBTIRPC
 	memcpy(nbuf.buf, sap, (size_t)salen);
 	client = clnt_vc_create(sock, &nbuf, program, version, 0, 0);
-#else	/* HAVE_CLNT_VC_CREATE */
+#else	/* !HAVE_LIBTIRPC */
 	client = clntunix_create((struct sockaddr_un *)sap,
 					program, version, &sock, 0, 0);
-#endif	/* HAVE_CLNT_VC_CREATE */
+#endif	/* !HAVE_LIBTIRPC */
 	if (client != NULL)
 		CLNT_CONTROL(client, CLSET_FD_CLOSE, NULL);
 	else
@@ -261,23 +261,23 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 				 const rpcvers_t version,
 				 struct timeval *timeout)
 {
-#ifdef HAVE_CLNT_DG_CREATE
+	CLIENT *client;
+	int ret, sock;
+#ifdef HAVE_LIBTIRPC
 	struct sockaddr_storage address;
 	const struct netbuf nbuf = {
 		.maxlen		= salen,
 		.len		= salen,
 		.buf		= &address,
 	};
-#endif	/* HAVE_CLNT_DG_CREATE */
-	CLIENT *client;
-	int ret, sock;
 
-#ifndef HAVE_CLNT_DG_CREATE
+#else	/* !HAVE_LIBTIRPC */
+
 	if (sap->sa_family != AF_INET) {
 		rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
 		return NULL;
 	}
-#endif	/* !HAVE_CLNT_DG_CREATE */
+#endif	/* !HAVE_LIBTIRPC */
 
 	sock = socket((int)sap->sa_family, SOCK_DGRAM, IPPROTO_UDP);
 	if (sock == -1) {
@@ -305,13 +305,13 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 		return NULL;
 	}
 
-#ifdef HAVE_CLNT_DG_CREATE
+#ifdef HAVE_LIBTIRPC
 	memcpy(nbuf.buf, sap, (size_t)salen);
 	client = clnt_dg_create(sock, &nbuf, program, version, 0, 0);
-#else	/* HAVE_CLNT_DG_CREATE */
+#else	/* !HAVE_LIBTIRPC */
 	client = clntudp_create((struct sockaddr_in *)sap, program,
 					version, *timeout, &sock);
-#endif	/* HAVE_CLNT_DG_CREATE */
+#endif	/* !HAVE_LIBTIRPC */
 	if (client != NULL) {
 		CLNT_CONTROL(client, CLSET_RETRY_TIMEOUT, (char *)timeout);
 		CLNT_CONTROL(client, CLSET_FD_CLOSE, NULL);
@@ -337,23 +337,23 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 				 const rpcvers_t version,
 				 struct timeval *timeout)
 {
-#ifdef HAVE_CLNT_VC_CREATE
+	CLIENT *client;
+	int ret, sock;
+#ifdef HAVE_LIBTIRPC
 	struct sockaddr_storage address;
 	const struct netbuf nbuf = {
 		.maxlen		= salen,
 		.len		= salen,
 		.buf		= &address,
 	};
-#endif	/* HAVE_CLNT_VC_CREATE */
-	CLIENT *client;
-	int ret, sock;
 
-#ifndef HAVE_CLNT_VC_CREATE
+#else	/* !HAVE_LIBTIRPC */
+
 	if (sap->sa_family != AF_INET) {
 		rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
 		return NULL;
 	}
-#endif	/* !HAVE_CLNT_VC_CREATE */
+#endif	/* !HAVE_LIBTIRPC */
 
 	sock = socket((int)sap->sa_family, SOCK_STREAM, IPPROTO_TCP);
 	if (sock == -1) {
@@ -381,13 +381,13 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 		return NULL;
 	}
 
-#ifdef HAVE_CLNT_VC_CREATE
+#ifdef HAVE_LIBTIRPC
 	memcpy(nbuf.buf, sap, (size_t)salen);
 	client = clnt_vc_create(sock, &nbuf, program, version, 0, 0);
-#else	/* HAVE_CLNT_VC_CREATE */
+#else	/* !HAVE_LIBTIRPC */
 	client = clnttcp_create((struct sockaddr_in *)sap,
 					program, version, &sock, 0, 0);
-#endif	/* HAVE_CLNT_VC_CREATE */
+#endif	/* !HAVE_LIBTIRPC */
 	if (client != NULL)
 		CLNT_CONTROL(client, CLSET_FD_CLOSE, NULL);
 	else

