From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/17] SUNRPC: Simplify kernel RPC service registration
Date: Tue, 03 Mar 2009 17:33:48 -0500
Message-ID: <20090303223347.2933.32251.stgit@ingres.1015granger.net>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org, steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:23505 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979AbZCCWfP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 17:35:15 -0500
In-Reply-To: <20090303220539.2933.15015.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel registers RPC services with the local portmapper with an
rpcbind SET upcall to the local portmapper.  Traditionally, this used
rpcbind v2, but registering RPC services that support IPv6 requires
rpcbind v3 or v4.

Since we now want separate PF_INET and PF_INET6 listeners for each
kernel RPC service, svc_register() will do only one of those
registrations at a time.

For PF_INET, it tries an rpcb v4 SET upcall first; if that fails, it
does a legacy portmap SET.  This makes it entirely backwards
compatible with legacy user space, but allows a proper v4 SET to be
used if rpcbind is available.

For PF_INET6, it does an rpcb v4 SET upcall.  If that fails, it fails
the registration, and thus the transport creation.  This let's the
kernel detect if user space is able to support IPv6 RPC services.

This provides complete backwards compatibilty with legacy user space
that only supports rpcbind v2.  The only down-side is that registering
a new kernel RPC service may take an extra exchange with the local
portmapper on legacy systems, but this is an infrequent operation, so
it shouldn't be consequential.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   79 +++++++++++++++++++++++-------------------------------
 1 files changed, 34 insertions(+), 45 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f1e0ad8..949164d 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -718,8 +718,6 @@ svc_exit_thread(struct svc_rqst *rqstp)
 }
 EXPORT_SYMBOL_GPL(svc_exit_thread);
 
-#ifdef CONFIG_SUNRPC_REGISTER_V4
-
 /*
  * Register an "inet" protocol family netid with the local
  * rpcbind daemon via an rpcbind v4 SET request.
@@ -734,12 +732,13 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 				const unsigned short protocol,
 				const unsigned short port)
 {
-	struct sockaddr_in sin = {
+	const struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
 		.sin_port		= htons(port),
 	};
-	char *netid;
+	const char *netid;
+	int error;
 
 	switch (protocol) {
 	case IPPROTO_UDP:
@@ -752,10 +751,20 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 		return -ENOPROTOOPT;
 	}
 
-	return rpcb_v4_register(program, version,
-				(struct sockaddr *)&sin, netid);
+	error = rpcb_v4_register(program, version,
+					(const struct sockaddr *)&sin, netid);
+
+	/*
+	 * User space didn't support rpcbind v4, so retry this
+	 * registration request with the legacy rpcbind v2 protocol.
+	 */
+	if (error == -EPROTONOSUPPORT)
+		error = rpcb_register(program, version, protocol, port);
+
+	return error;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 /*
  * Register an "inet6" protocol family netid with the local
  * rpcbind daemon via an rpcbind v4 SET request.
@@ -770,12 +779,13 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 				const unsigned short protocol,
 				const unsigned short port)
 {
-	struct sockaddr_in6 sin6 = {
+	const struct sockaddr_in6 sin6 = {
 		.sin6_family		= AF_INET6,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 		.sin6_port		= htons(port),
 	};
-	char *netid;
+	const char *netid;
+	int error;
 
 	switch (protocol) {
 	case IPPROTO_UDP:
@@ -788,9 +798,19 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 		return -ENOPROTOOPT;
 	}
 
-	return rpcb_v4_register(program, version,
-				(struct sockaddr *)&sin6, netid);
+	error = rpcb_v4_register(program, version,
+					(const struct sockaddr *)&sin6, netid);
+
+	/*
+	 * User space didn't support rpcbind version 4, so we won't
+	 * use a PF_INET6 listener.
+	 */
+	if (error == -EPROTONOSUPPORT)
+		error = -EAFNOSUPPORT;
+
+	return error;
 }
+#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 
 /*
  * Register a kernel RPC service via rpcbind version 4.
@@ -809,48 +829,17 @@ static int __svc_register(const u32 program, const u32 version,
 	case PF_INET:
 		return __svc_rpcb_register4(program, version,
 						protocol, port);
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case PF_INET6:
-		error = __svc_rpcb_register6(program, version,
+		return__svc_rpcb_register6(program, version,
 						protocol, port);
-		if (error < 0)
-			return error;
-
-		/*
-		 * Work around bug in some versions of Linux rpcbind
-		 * which don't allow registration of both inet and
-		 * inet6 netids.
-		 *
-		 * Error return ignored for now.
-		 */
-		__svc_rpcb_register4(program, version,
-						protocol, port);
-		return 0;
+#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 	}
 
 	return -EAFNOSUPPORT;
 }
 
-#else	/* CONFIG_SUNRPC_REGISTER_V4 */
-
-/*
- * Register a kernel RPC service via rpcbind version 2.
- *
- * Returns zero on success; a negative errno value is returned
- * if any error occurs.
- */
-static int __svc_register(const u32 program, const u32 version,
-			  const int family,
-			  const unsigned short protocol,
-			  const unsigned short port)
-{
-	if (family != PF_INET)
-		return -EAFNOSUPPORT;
-
-	return rpcb_register(program, version, protocol, port);
-}
-
-#endif /* CONFIG_SUNRPC_REGISTER_V4 */
-
 /**
  * svc_register - register an RPC service with the local portmapper
  * @serv: svc_serv struct for the service to register

