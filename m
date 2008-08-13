From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] SUNRPC: Use new rpcb_v4_register() interface in
	svc_register()
Date: Wed, 13 Aug 2008 18:40:25 -0400
Message-ID: <20080813224024.13068.36753.stgit@manray.1015granger.net>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30851 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496AbYHMWlz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 18:41:55 -0400
In-Reply-To: <20080813223653.13068.9467.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to advertise NFS-related services on IPv6 interfaces via
rpcbind, the kernel RPC server implementation must use
rpcb_v4_register() instead of rpcb_register().

Legacy support (register using portmapper/rpcbindv2) is still available.
The new rpcbind version is not used unless enabled via a CONFIG option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |   73 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index aa334c2..e22ef0d 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -720,6 +720,74 @@ svc_exit_thread(struct svc_rqst *rqstp)
 }
 EXPORT_SYMBOL(svc_exit_thread);
 
+#ifdef CONFIG_SUNRPC_REGISTER_V4
+/*
+ * Registering kernel RPC services with rpcbind version 2 will work
+ * over either IPv4 or IPv6, since the Linux kernel always registers
+ * services for the "any" address.
+ *
+ * However, the local rpcbind daemon listens on either only AF_INET
+ * or AF_INET6 (never both).  When it listens on AF_INET6, an rpcbind
+ * version 2 registration will result in registering the service at
+ * IN6ADDR_ANY, even if the RPC service being registered is not
+ * IPv6-enabled.
+ *
+ * Rpcbind version 4 allows us to be a little more specific.  Kernel
+ * RPC services that don't yet support AF_INET6 can register
+ * themselves as IPv4-only with the local rpcbind daemon, even if the
+ * daemon is listening only on AF_INET6.
+ *
+ * And, registering IPv6-enabled kernel RPC services via AF_INET6
+ * verifies that the local user space rpcbind daemon is properly
+ * configured to support remote AF_INET6 rpcbind requests.
+ *
+ * An AF_INET6 registration request will fail if the local rpcbind
+ * daemon is not set up to listen on AF_INET6.  Likewise, we fail
+ * AF_INET6 registration requests if svc_register() is configured to
+ * support only rpcbind version 2.
+ */
+static int __svc_register(const u32 program, const u32 version,
+			  const sa_family_t family,
+			  const unsigned short protocol,
+			  const unsigned short port)
+{
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_ANY),
+		.sin_port		= htons(port),
+	};
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+		.sin6_addr		= IN6ADDR_ANY_INIT,
+		.sin6_port		= htons(port),
+	};
+	struct sockaddr *sap;
+	char *netid;
+	int error, result;
+
+	switch (family) {
+	case AF_INET:
+		sap = (struct sockaddr *)&sin;
+		netid = RPCBIND_NETID_TCP;
+		if (protocol == IPPROTO_UDP)
+			netid = RPCBIND_NETID_UDP;
+		break;
+	case AF_INET6:
+		sap = (struct sockaddr *)&sin6;
+		netid = RPCBIND_NETID_TCP6;
+		if (protocol == IPPROTO_UDP)
+			netid = RPCBIND_NETID_UDP6;
+		break;
+	default:
+		return -EAFNOSUPPORT;
+	}
+
+	error = rpcb_v4_register(program, version, sap, netid, &result);
+	if (!result)
+		error = -EACCES;
+	return error;
+}
+#else
 static int __svc_register(const u32 program, const u32 version,
 			  sa_family_t family,
 			  const unsigned short protocol,
@@ -727,11 +795,15 @@ static int __svc_register(const u32 program, const u32 version,
 {
 	int error, result;
 
+	if (family != AF_INET)
+		return -EAFNOSUPPORT;
+
 	error = rpcb_register(program, version, protocol, port, &result);
 	if (!result)
 		error = -EACCES;
 	return error;
 }
+#endif
 
 /**
  * svc_register - register an RPC service with the local portmapper
@@ -739,6 +811,7 @@ static int __svc_register(const u32 program, const u32 version,
  * @proto: transport protocol number to advertise
  * @port: port to advertise
  *
+ * Service is registered for any address in serv's address family
  */
 int svc_register(const struct svc_serv *serv, const unsigned short proto,
 		 const unsigned short port)

