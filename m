From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] SUNRPC: Support IPv6 when registering kernel RPC services
Date: Mon, 18 Aug 2008 19:34:16 -0400
Message-ID: <20080818233415.1214.31668.stgit@manray.1015granger.net>
References: <20080818233128.1214.48603.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21596 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbYHSMHE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 08:07:04 -0400
In-Reply-To: <20080818233128.1214.48603.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to advertise NFS-related services on IPv6 interfaces via
rpcbind, the kernel RPC server implementation must use
rpcb_v4_register() instead of rpcb_register().

A new kernel build option allows distributions to use the legacy
v2 call until they integrate an appropriate user-space rpcbind
daemon that can support IPv6 RPC services.

I tried adding some automatic logic to fall back if registering
with a v4 protocol request failed, but there are too many corner
cases.  So I just made it a compile-time switch that distributions
can throw when they've replaced portmapper with rpcbind.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig                 |   22 ++++++++++
 include/linux/sunrpc/svc.h |    4 +-
 net/sunrpc/svc.c           |   95 +++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 113 insertions(+), 8 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index d387358..949e6d1 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1765,6 +1765,28 @@ config SUNRPC_XPRT_RDMA
 
 	  If unsure, say N.
 
+config SUNRPC_REGISTER_V4
+	bool "Register local RPC services via rpcbind v4 (EXPERIMENTAL)"
+	depends on SUNRPC && EXPERIMENTAL
+	default n
+	help 
+	  Sun added support for registering RPC services at an IPv6
+	  address by creating two new versions of the rpcbind protocol
+	  (RFC 1833).
+
+	  This option enables support in the kernel RPC server for
+	  registering kernel RPC services via version 4 of the rpcbind
+	  protocol.  If you enable this option, you must run a portmapper
+	  daemon that supports rpcbind protocol version 4.
+
+	  Serving NFS over IPv6 from knfsd (the kernel's NFS server)
+	  requires that you enable this option and use a portmapper that
+	  supports rpcbind version 4.
+
+	  If unsure, say N to get traditional behavior (register kernel
+	  RPC services using only rpcbind version 2).  Distributions
+	  using the legacy Linux portmapper daemon must say N here.
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index a794d4a..2a41d29 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -395,7 +395,9 @@ struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
-int		   svc_register(struct svc_serv *, int, unsigned short);
+int		   svc_register(const struct svc_serv *, const unsigned short,
+				const unsigned short);
+
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
 struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3d4c0b0..c023cb3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -720,13 +720,92 @@ svc_exit_thread(struct svc_rqst *rqstp)
 }
 EXPORT_SYMBOL(svc_exit_thread);
 
+#ifdef CONFIG_SUNRPC_REGISTER_V4
 /*
- * Register an RPC service with the local portmapper.
- * To unregister a service, call this routine with
- * proto and port == 0.
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
  */
-int
-svc_register(struct svc_serv *serv, int proto, unsigned short port)
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
+	return rpcb_v4_register(program, version, sap, netid);
+}
+#else
+static int __svc_register(const u32 program, const u32 version,
+			  sa_family_t family,
+			  const unsigned short protocol,
+			  const unsigned short port)
+{
+	if (family != AF_INET)
+		return -EAFNOSUPPORT;
+
+	return rpcb_register(program, version, protocol, port);
+}
+#endif
+
+/**
+ * svc_register - register an RPC service with the local portmapper
+ * @serv: svc_serv struct for the service to register
+ * @proto: transport protocol number to advertise
+ * @port: port to advertise
+ *
+ * Service is registered for any address in serv's address family
+ */
+int svc_register(const struct svc_serv *serv, const unsigned short proto,
+		 const unsigned short port)
 {
 	struct svc_program	*progp;
 	unsigned int		i;
@@ -739,8 +818,9 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 			if (progp->pg_vers[i] == NULL)
 				continue;
 
-			dprintk("svc: svc_register(%s, %s, %d, %d)%s\n",
+			dprintk("svc: svc_register(%s, %u, %s, %u, %d)%s\n",
 					progp->pg_name,
+					serv->sv_family,
 					proto == IPPROTO_UDP?  "udp" : "tcp",
 					port,
 					i,
@@ -750,7 +830,8 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
-			error = rpcb_register(progp->pg_prog, i, proto, port);
+			error = __svc_register(progp->pg_prog, i,
+						serv->sv_family, proto, port);
 			if (error < 0)
 				break;
 		}

