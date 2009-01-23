From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] SUNRPC: Simplify kernel RPC service registration
Date: Fri, 23 Jan 2009 11:46:23 -0500
Message-ID: <20090123164623.27126.4787.stgit@ingres.1015granger.net>
References: <20090123164302.27126.56411.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:35275 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756840AbZAWQtG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2009 11:49:06 -0500
In-Reply-To: <20090123164302.27126.56411.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel registers RPC services with the local portmapper with an
rpcbind SET upcall to the local portmapper.  Traditionally, this used
rpcbind v2, but registering RPC services that support IPv6 requires
rpcbind v3 or v4.

Previously the kernel used the registration upcall to detect whether
user space supported IPv6 for RPC at all, and fail the service
creation if it didn't.  This is probably unnecessary paranoia.

Since the kernel uses a single listener (either AF_INET or AF_INET6)
to handle all requests for a particular RPC service, AF_INET6
listeners handle IPv4 RPC requests too.  If user space doesn't allow
an AF_INET6 kernel service to be registered, that should be no
trouble at all for the kernel's AF_INET6 RPC listener -- it just won't
get any RPC requests via IPv6.  So we don't need to register the
service for IPv6 if user space doesn't allow it.

So, we try registration via rpcbind v4 first; if that fails, we retry
with rpcbind v2, and support only IPv4 requests.

This provides complete backwards compatibilty with legacy user space
that only supports rpcbind v2.  The only down-side is that registering
a new kernel RPC service may take an extra exchange with the local
portmapper, but this is an infrequent operation, so it shouldn't
matter.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   50 ++++++++++++++++++++++++--------------------------
 1 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 8dc4a1e..3cf1b3c 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -719,8 +719,6 @@ svc_exit_thread(struct svc_rqst *rqstp)
 }
 EXPORT_SYMBOL_GPL(svc_exit_thread);
 
-#ifdef CONFIG_SUNRPC_REGISTER_V4
-
 /*
  * Register an "inet" protocol family netid with the local
  * rpcbind daemon via an rpcbind v4 SET request.
@@ -741,6 +739,7 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 		.sin_port		= htons(port),
 	};
 	char *netid;
+	int error;
 
 	switch (protocol) {
 	case IPPROTO_UDP:
@@ -753,8 +752,17 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 		return -ENOPROTOOPT;
 	}
 
-	return rpcb_v4_register(program, version,
-				(struct sockaddr *)&sin, netid);
+	error = rpcb_v4_register(program, version,
+					(struct sockaddr *)&sin, netid);
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
 
 /*
@@ -777,6 +785,7 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 		.sin6_port		= htons(port),
 	};
 	char *netid;
+	int error;
 
 	switch (protocol) {
 	case IPPROTO_UDP:
@@ -789,8 +798,18 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 		return -ENOPROTOOPT;
 	}
 
-	return rpcb_v4_register(program, version,
+	error = rpcb_v4_register(program, version,
 				(struct sockaddr *)&sin6, netid);
+
+	/*
+	 * User space didn't support registering an IPv6 service,
+	 * so register this service for IPv4 only, using the legacy
+	 * rpcbind v2 protocol.
+	 */
+	if (error == -EPROTONOSUPPORT)
+		error = rpcb_register(program, version, protocol, port);
+
+	return error;
 }
 
 /*
@@ -831,27 +850,6 @@ static int __svc_register(const u32 program, const u32 version,
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
-			  sa_family_t family,
-			  const unsigned short protocol,
-			  const unsigned short port)
-{
-	if (family != AF_INET)
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

