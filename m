From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] nfs-utils: Replace getservbyname(3)
Date: Wed, 04 Mar 2009 19:02:39 -0500
Message-ID: <20090305000238.28749.26250.stgit@ingres.1015granger.net>
References: <20090304234711.28749.7018.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:26170 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbZCEADh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 19:03:37 -0500
In-Reply-To: <20090304234711.28749.7018.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The getservbyname(3) function is not re-entrant, and anyway, the man page
says it is obsolete.  Replace it with a call to getaddrinfo(3).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfsrpc.h |    6 ---
 support/nfs/getport.c    |  105 ++++++++++++++++++++++++++++------------------
 support/nfs/rpc_socket.c |   46 --------------------
 3 files changed, 63 insertions(+), 94 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index 1529d44..097debb 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -54,12 +54,6 @@
 extern rpcprog_t	nfs_getrpcbyname(const rpcprog_t, const char *table[]);
 
 /*
- * Look up a port number in /etc/services for an RPC program
- */
-extern unsigned short	nfs_getportbynumber(const rpcprog_t program,
-				const unsigned short transport);
-
-/*
  * Acquire an RPC CLIENT *
  */
 extern CLIENT		*nfs_get_rpcclient(const struct sockaddr *,
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 023c79a..5da1749 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -65,14 +65,6 @@ const static rpcvers_t default_rpcb_version = RPCBVERS_4;
 const static rpcvers_t default_rpcb_version = PMAPVERS;
 #endif
 
-static const char *nfs_gp_rpcb_pgmtbl[] = {
-	"rpcbind",
-	"portmap",
-	"portmapper",
-	"sunrpc",
-	NULL,
-};
-
 #ifdef HAVE_DECL_AI_ADDRCONFIG
 /*
  * getaddrinfo(3) generates a usable loopback address based on how the
@@ -128,39 +120,6 @@ static int nfs_gp_loopback_address(struct sockaddr *sap, socklen_t *salen)
 #endif
 
 /*
- * Discover the port number that should be used to contact an
- * rpcbind service.  This will detect if the port has a local
- * value that may have been set in /etc/services.
- *
- * NB: s_port is already in network byte order.
- *
- * Returns network byte-order port number of rpcbind service
- * on this system.
- */
-static in_port_t nfs_gp_get_rpcb_port(const unsigned short protocol)
-{
-	struct protoent *proto;
-
-	proto = getprotobynumber((int)protocol);
-	if (proto != NULL) {
-		struct servent *entry;
-
-		entry = getservbyname("rpcbind", proto->p_name);
-		if (entry != NULL)
-			return (in_port_t)entry->s_port;
-
-		entry = getservbyname("portmapper", proto->p_name);
-		if (entry != NULL)
-			return (in_port_t)entry->s_port;
-
-		entry = getservbyname("sunrpc", proto->p_name);
-		if (entry != NULL)
-			return (in_port_t)entry->s_port;
-	}
-	return htons((uint16_t)PMAPPORT);
-}
-
-/*
  * Plant port number in @sap.  @port is already in network byte order.
  */
 static void nfs_gp_set_port(struct sockaddr *sap, const in_port_t port)
@@ -179,6 +138,61 @@ static void nfs_gp_set_port(struct sockaddr *sap, const in_port_t port)
 }
 
 /*
+ * Look up a network service in /etc/services and return the
+ * network-order port number of that service.
+ */
+static in_port_t nfs_gp_getservbyname(const char *service,
+				      const unsigned short protocol)
+{
+	const struct addrinfo gai_hint = {
+		.ai_family	= AF_INET,
+		.ai_protocol	= protocol,
+		.ai_flags	= AI_PASSIVE,
+	};
+	struct addrinfo *gai_results;
+	const struct sockaddr_in *sin;
+	in_port_t port;
+
+	if (getaddrinfo(NULL, service, &gai_hint, &gai_results) != 0)
+		return 0;
+
+	sin = (const struct sockaddr_in *)gai_results->ai_addr;
+	port = sin->sin_port;
+	
+	freeaddrinfo(gai_results);
+	return port;
+}
+
+/*
+ * Discover the port number that should be used to contact an
+ * rpcbind service.  This will detect if the port has a local
+ * value that may have been set in /etc/services.
+ *
+ * Returns network byte-order port number of rpcbind service
+ * on this system.
+ */
+static in_port_t nfs_gp_get_rpcb_port(const unsigned short protocol)
+{
+	static const char *rpcb_netnametbl[] = {
+		"rpcbind",
+		"portmapper",
+		"sunrpc",
+		NULL,
+	};
+	unsigned int i;
+
+	for (i = 0; rpcb_netnametbl[i] != NULL; i++) {
+		in_port_t port;
+
+		port = nfs_gp_getservbyname(rpcb_netnametbl[i], protocol);
+		if (port != 0)
+			return port;
+	}
+
+	return (in_port_t)htons((uint16_t)PMAPPORT);
+}
+
+/*
  * Set up an RPC client for communicating with an rpcbind daemon at
  * @sap over @transport with protocol version @version.
  *
@@ -193,9 +207,16 @@ static CLIENT *nfs_gp_get_rpcbclient(const struct sockaddr *sap,
 				     const rpcvers_t version,
 				     struct timeval *timeout)
 {
+	static const char *rpcb_pgmtbl[] = {
+		"rpcbind",
+		"portmap",
+		"portmapper",
+		"sunrpc",
+		NULL,
+	};
 	struct sockaddr_storage address;
 	struct sockaddr *saddr = (struct sockaddr *)&address;
-	rpcprog_t rpcb_prog = nfs_getrpcbyname(RPCBPROG, nfs_gp_rpcb_pgmtbl);
+	rpcprog_t rpcb_prog = nfs_getrpcbyname(RPCBPROG, rpcb_pgmtbl);
 
 	memcpy(saddr, sap, (size_t)salen);
 	nfs_gp_set_port(saddr, nfs_gp_get_rpcb_port(transport));
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 82ba818..b7420d1 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -480,49 +480,3 @@ rpcprog_t nfs_getrpcbyname(const rpcprog_t program, const char *table[])
 
 	return program;
 }
-
-static unsigned short nfs_tryportbyname(const char *name,
-					const char *protocol)
-{
-	struct servent *servp = NULL;
-
-	servp = getservbyname(name, protocol);
-	if (servp != NULL)
-		return (unsigned short)ntohl((uint32_t)servp->s_port);
-	return 0;
-}
-
-/**
- * nfs_getportbynumber - convert an RPC program number to a port
- * @program: RPC program number to look up
- * @transport: IPPROTO_ value of transport protocol to use
- *
- * Returns a non-zero port number, in host byte order, on success;
- * otherwise zero if some problem occurred.
- */
-unsigned short nfs_getportbynumber(const rpcprog_t program,
-				   const unsigned short transport)
-{
-	char *protocol = (transport == IPPROTO_TCP) ? "tcp" : "udp";
-	struct rpcent *rpcp;
-	unsigned short port = 0;
-
-	rpcp = getrpcbynumber((int)program);
-	if (rpcp == NULL)
-		return port;
-
-	port = nfs_tryportbyname(rpcp->r_name, protocol);
-	if (port != 0)
-		return port;
-
-	if (rpcp->r_aliases) {
-		int i;
-		for (i = 0; rpcp->r_aliases[i] != NULL; i++) {
-			port = nfs_tryportbyname(rpcp->r_aliases[i], protocol);
-			if (port != 0)
-				break;
-		}
-	}
-
-	return port;
-}

