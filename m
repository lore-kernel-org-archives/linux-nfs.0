From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] SUNRPC: Register both netids for AF_INET6 servers
Date: Mon, 15 Sep 2008 16:27:23 -0500
Message-ID: <20080915212723.3939.23359.stgit@ellison.1015granger.net>
References: <20080915212437.3939.82594.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: okir@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:40094 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132AbYIOV1z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2008 17:27:55 -0400
In-Reply-To: <20080915212437.3939.82594.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TI-RPC is a user-space library of RPC functions that replaces ONC RPC
and allows RPC to operate in the new world of IPv6.

TI-RPC combines the concept of a transport protocol (UDP and TCP)
and a protocol family (PF_INET and PF_INET6) into a single identifier
called a "netid."  For example, "udp" means UDP over IPv4, and "udp6"
means UDP over IPv6.

For rpcbind, then, the RPC service tuple that is registered and
advertised is:

  [RPC program, RPC version, service address and port, netid]

instead of

  [RPC program, RPC version, port, protocol]

Service address is typically ANYADDR, but can be a specific address
of one of the interfaces on a multi-homed host.  The third item in
the new tuple is expressed as a universal address.

The current Linux rpcbind implementation registers a netid for both
protocol families when RPCB_SET is done for just the PF_INET6 version
of the netid (ie udp6 or tcp6).  So registering "udp6" causes a
registration for "udp" to appear automatically as well.

We've recently determined that this is incorrect behavior.  In the
TI-RPC world, "udp6" is not meant to imply that the registered RPC
service handles requests from AF_INET as well, even if the listener
socket does address mapping.  "udp" and "udp6" are entirely separate
capabilities, and must be registered separately.

The Linux kernel, unlike TI-RPC, leverages address mapping to allow a
single listener socket to handle requests for both AF_INET and AF_INET6.
This is still OK, but the kernel currently assumes registering "udp6"
will cover "udp" as well.  It registers only "udp6" for it's AF_INET6
services, even though they handle both AF_INET and AF_INET6 on the same
port.

So svc_register() actually needs to register both "udp" and "udp6"
explicitly (and likewise for TCP).  Until rpcbind is fixed, the
kernel can ignore the return code for the second RPCB_SET call.

Please merge this with commit 15231312:

    SUNRPC: Support IPv6 when registering kernel RPC services

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Olaf Kirch <okir@suse.de>
---

 net/sunrpc/svc.c |  143 ++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 100 insertions(+), 43 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index c023cb3..5089014 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -721,69 +721,125 @@ svc_exit_thread(struct svc_rqst *rqstp)
 EXPORT_SYMBOL(svc_exit_thread);
 
 #ifdef CONFIG_SUNRPC_REGISTER_V4
+
 /*
- * Registering kernel RPC services with rpcbind version 2 will work
- * over either IPv4 or IPv6, since the Linux kernel always registers
- * services for the "any" address.
- *
- * However, the local rpcbind daemon listens on either only AF_INET
- * or AF_INET6 (never both).  When it listens on AF_INET6, an rpcbind
- * version 2 registration will result in registering the service at
- * IN6ADDR_ANY, even if the RPC service being registered is not
- * IPv6-enabled.
+ * Register an "inet" protocol family netid with the local
+ * rpcbind daemon via an rpcbind v4 SET request.
  *
- * Rpcbind version 4 allows us to be a little more specific.  Kernel
- * RPC services that don't yet support AF_INET6 can register
- * themselves as IPv4-only with the local rpcbind daemon, even if the
- * daemon is listening only on AF_INET6.
+ * No netconfig infrastructure is available in the kernel, so
+ * we map IP_ protocol numbers to netids by hand.
  *
- * And, registering IPv6-enabled kernel RPC services via AF_INET6
- * verifies that the local user space rpcbind daemon is properly
- * configured to support remote AF_INET6 rpcbind requests.
- *
- * An AF_INET6 registration request will fail if the local rpcbind
- * daemon is not set up to listen on AF_INET6.  Likewise, we fail
- * AF_INET6 registration requests if svc_register() is configured to
- * support only rpcbind version 2.
+ * Returns zero on success; a negative errno value is returned
+ * if any error occurs.
  */
-static int __svc_register(const u32 program, const u32 version,
-			  const sa_family_t family,
-			  const unsigned short protocol,
-			  const unsigned short port)
+static int __svc_rpcb_register4(const u32 program, const u32 version,
+				const unsigned short protocol,
+				const unsigned short port)
 {
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
 		.sin_port		= htons(port),
 	};
+	char *netid;
+
+	switch (protocol) {
+	case IPPROTO_UDP:
+		netid = RPCBIND_NETID_UDP;
+		break;
+	case IPPROTO_TCP:
+		netid = RPCBIND_NETID_TCP;
+		break;
+	default:
+		return -EPROTONOSUPPORT;
+	}
+
+	return rpcb_v4_register(program, version,
+				(struct sockaddr *)&sin, netid);
+}
+
+/*
+ * Register an "inet6" protocol family netid with the local
+ * rpcbind daemon via an rpcbind v4 SET request.
+ *
+ * No netconfig infrastructure is available in the kernel, so
+ * we map IP_ protocol numbers to netids by hand.
+ *
+ * Returns zero on success; a negative errno value is returned
+ * if any error occurs.
+ */
+static int __svc_rpcb_register6(const u32 program, const u32 version,
+				const unsigned short protocol,
+				const unsigned short port)
+{
 	struct sockaddr_in6 sin6 = {
 		.sin6_family		= AF_INET6,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 		.sin6_port		= htons(port),
 	};
-	struct sockaddr *sap;
 	char *netid;
 
-	switch (family) {
-	case AF_INET:
-		sap = (struct sockaddr *)&sin;
-		netid = RPCBIND_NETID_TCP;
-		if (protocol == IPPROTO_UDP)
-			netid = RPCBIND_NETID_UDP;
+	switch (protocol) {
+	case IPPROTO_UDP:
+		netid = RPCBIND_NETID_UDP6;
 		break;
-	case AF_INET6:
-		sap = (struct sockaddr *)&sin6;
+	case IPPROTO_TCP:
 		netid = RPCBIND_NETID_TCP6;
-		if (protocol == IPPROTO_UDP)
-			netid = RPCBIND_NETID_UDP6;
 		break;
 	default:
-		return -EAFNOSUPPORT;
+		return -EPROTONOSUPPORT;
+	}
+
+	return rpcb_v4_register(program, version,
+				(struct sockaddr *)&sin6, netid);
+}
+
+/*
+ * Register a kernel RPC service via rpcbind version 4.
+ *
+ * Returns zero on success; a negative errno value is returned
+ * if any error occurs.
+ */
+static int __svc_register(const u32 program, const u32 version,
+			  const sa_family_t family,
+			  const unsigned short protocol,
+			  const unsigned short port)
+{
+	int error;
+
+	switch (family) {
+	case AF_INET:
+		return __svc_rpcb_register4(program, version,
+						protocol, port);
+	case AF_INET6:
+		error = __svc_rpcb_register6(program, version,
+						protocol, port);
+		if (error < 0)
+			return error;
+
+		/*
+		 * Work around bug in some versions of Linux rpcbind
+		 * which don't allow registration of both inet and
+		 * inet6 netids.
+		 *
+		 * Error return ignored for now.
+		 */
+		__svc_rpcb_register4(program, version,
+						protocol, port);
+		return 0;
 	}
 
-	return rpcb_v4_register(program, version, sap, netid);
+	return -EAFNOSUPPORT;
 }
-#else
+
+#else	/* CONFIG_SUNRPC_REGISTER_V4 */
+
+/*
+ * Register a kernel RPC service via rpcbind version 2.
+ *
+ * Returns zero on success; a negative errno value is returned
+ * if any error occurs.
+ */
 static int __svc_register(const u32 program, const u32 version,
 			  sa_family_t family,
 			  const unsigned short protocol,
@@ -794,7 +850,8 @@ static int __svc_register(const u32 program, const u32 version,
 
 	return rpcb_register(program, version, protocol, port);
 }
-#endif
+
+#endif /* CONFIG_SUNRPC_REGISTER_V4 */
 
 /**
  * svc_register - register an RPC service with the local portmapper
@@ -818,12 +875,12 @@ int svc_register(const struct svc_serv *serv, const unsigned short proto,
 			if (progp->pg_vers[i] == NULL)
 				continue;
 
-			dprintk("svc: svc_register(%s, %u, %s, %u, %d)%s\n",
+			dprintk("svc: svc_register(%sv%d, %s, %u, %u)%s\n",
 					progp->pg_name,
-					serv->sv_family,
+					i,
 					proto == IPPROTO_UDP?  "udp" : "tcp",
 					port,
-					i,
+					serv->sv_family,
 					progp->pg_vers[i]->vs_hidden?
 						" (but not telling portmap)" : "");
 

