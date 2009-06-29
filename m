From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/31] getport: Remove unneeded @salen arguments
Date: Mon, 29 Jun 2009 13:35:35 -0400
Message-ID: <20090629173535.2076.40148.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:52523 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758313AbZF2Rfz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:35:55 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Now that getnameinfo(3) is no longer used, the @salen
argument to nfs_sockaddr2universal() is no longer needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfsrpc.h |    4 +---
 support/nfs/getport.c    |   42 +++++++++++++++++-------------------------
 2 files changed, 18 insertions(+), 28 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index 543c35b..da3b4df 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -73,8 +73,7 @@ extern CLIENT		*nfs_get_priv_rpcclient( const struct sockaddr *,
 /*
  * Convert a socket address to a universal address
  */
-extern char		*nfs_sockaddr2universal(const struct sockaddr *,
-				const socklen_t);
+extern char		*nfs_sockaddr2universal(const struct sockaddr *);
 
 /*
  * Extract port number from a universal address
@@ -114,7 +113,6 @@ extern unsigned short	nfs_rpcb_getaddr(const struct sockaddr *,
 				const socklen_t,
 				const unsigned short,
 				const struct sockaddr *,
-				const socklen_t,
 				const rpcprog_t,
 				const rpcvers_t,
 				const unsigned short,
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 056d3c7..bc0f121 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -321,7 +321,6 @@ int nfs_universal2port(const char *uaddr)
 /**
  * nfs_sockaddr2universal - convert a sockaddr to a "universal address"
  * @sap: pointer to a socket address
- * @salen: length of socket address
  *
  * Universal addresses (defined in RFC 1833) are used when calling an
  * rpcbind daemon via protocol versions 3 or 4..
@@ -334,8 +333,7 @@ int nfs_universal2port(const char *uaddr)
  * in some earlier glibc releases, and we don't require support for
  * scope IDs for universal addresses.
  */
-char *nfs_sockaddr2universal(const struct sockaddr *sap,
-			     const socklen_t salen)
+char *nfs_sockaddr2universal(const struct sockaddr *sap)
 {
 	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
 	const struct sockaddr_un *sun = (const struct sockaddr_un *)sap;
@@ -407,7 +405,6 @@ static int nfs_gp_ping(CLIENT *client, struct timeval timeout)
  * to by r_netid and r_addr; otherwise 0.
  */
 static int nfs_gp_init_rpcb_parms(const struct sockaddr *sap,
-				  const socklen_t salen,
 				  const rpcprog_t program,
 				  const rpcvers_t version,
 				  const unsigned short protocol,
@@ -419,7 +416,7 @@ static int nfs_gp_init_rpcb_parms(const struct sockaddr *sap,
 	if (netid == NULL)
 		return 0;
 
-	addr = nfs_sockaddr2universal(sap, salen);
+	addr = nfs_sockaddr2universal(sap);
 	if (addr == NULL) {
 		free(netid);
 		return 0;
@@ -540,7 +537,6 @@ static unsigned long nfs_gp_pmap_getport(CLIENT *client,
 
 static unsigned short nfs_gp_getport_rpcb(CLIENT *client,
 					  const struct sockaddr *sap,
-					  const socklen_t salen,
 					  const rpcprog_t program,
 					  const rpcvers_t version,
 					  const unsigned short protocol,
@@ -549,8 +545,8 @@ static unsigned short nfs_gp_getport_rpcb(CLIENT *client,
 	unsigned short port = 0;
 	struct rpcb parms;
 
-	if (nfs_gp_init_rpcb_parms(sap, salen, program,
-					version, protocol, &parms) != 0) {
+	if (nfs_gp_init_rpcb_parms(sap, program, version,
+					protocol, &parms) != 0) {
 		port = nfs_gp_rpcb_getaddr(client, &parms, timeout);
 		nfs_gp_free_rpcb_parms(&parms);
 	}
@@ -586,7 +582,6 @@ static unsigned long nfs_gp_getport_pmap(CLIENT *client,
  */
 static unsigned short nfs_gp_getport(CLIENT *client,
 				     const struct sockaddr *sap,
-				     const socklen_t salen,
 				     const rpcprog_t program,
 				     const rpcvers_t version,
 				     const unsigned short protocol,
@@ -595,7 +590,7 @@ static unsigned short nfs_gp_getport(CLIENT *client,
 	switch (sap->sa_family) {
 #ifdef HAVE_LIBTIRPC
 	case AF_INET6:
-		return nfs_gp_getport_rpcb(client, sap, salen, program,
+		return nfs_gp_getport_rpcb(client, sap, program,
 						version, protocol, timeout);
 #endif	/* HAVE_LIBTIRPC */
 	case AF_INET:
@@ -699,7 +694,7 @@ unsigned short nfs_getport(const struct sockaddr *sap,
 	client = nfs_gp_get_rpcbclient(saddr, salen, protocol,
 						default_rpcb_version, &timeout);
 	if (client != NULL) {
-		port = nfs_gp_getport(client, saddr, salen, program,
+		port = nfs_gp_getport(client, saddr, program,
 					version, protocol, timeout);
 		CLNT_DESTROY(client);
 	}
@@ -737,7 +732,7 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 	client = nfs_gp_get_rpcbclient(sap, salen, protocol,
 						default_rpcb_version, &timeout);
 	if (client != NULL) {
-		port = nfs_gp_getport(client, sap, salen, program,
+		port = nfs_gp_getport(client, sap, program,
 					version, protocol, timeout);
 		CLNT_DESTROY(client);
 		client = NULL;
@@ -812,7 +807,7 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 	if (client != NULL) {
 		struct rpcb parms;
 
-		if (nfs_gp_init_rpcb_parms(sap, salen, program, version,
+		if (nfs_gp_init_rpcb_parms(sap, program, version,
 						protocol, &parms) != 0) {
 			port = nfs_gp_rpcb_getaddr(client, &parms, timeout);
 			nfs_gp_free_rpcb_parms(&parms);
@@ -838,7 +833,6 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
  * @salen: length of server address
  * @transport: transport protocol to use for the query
  * @addr: pointer to r_addr address
- * @addrlen: length of address
  * @program: requested RPC program number
  * @version: requested RPC version number
  * @protocol: requested IPPROTO_ value of transport protocol
@@ -869,7 +863,6 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 				const socklen_t salen,
 				const unsigned short transport,
 				const struct sockaddr *addr,
-				const socklen_t addrlen,
 				const rpcprog_t program,
 				const rpcvers_t version,
 				const unsigned short protocol,
@@ -889,7 +882,7 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 	client = nfs_gp_get_rpcbclient(saddr, salen, transport,
 							RPCBVERS_4, &tout);
 	if (client != NULL) {
-		if (nfs_gp_init_rpcb_parms(addr, addrlen, program, version,
+		if (nfs_gp_init_rpcb_parms(addr, program, version,
 						protocol, &parms) != 0) {
 			port = nfs_gp_rpcb_getaddr(client, &parms, tout);
 			nfs_gp_free_rpcb_parms(&parms);
@@ -902,15 +895,14 @@ unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
 
 #else	/* !HAVE_LIBTIRPC */
 
-unsigned short nfs_rpcb_getaddr(const struct sockaddr *sap,
-				const socklen_t salen,
-				const unsigned short transport,
-				const struct sockaddr *addr,
-				const socklen_t addrlen,
-				const rpcprog_t program,
-				const rpcvers_t version,
-				const unsigned short protocol,
-				const struct timeval *timeout)
+unsigned short nfs_rpcb_getaddr(__attribute__((unused)) const struct sockaddr *sap,
+				__attribute__((unused)) const socklen_t salen,
+				__attribute__((unused)) const unsigned short transport,
+				__attribute__((unused)) const struct sockaddr *addr,
+				__attribute__((unused)) const rpcprog_t program,
+				__attribute__((unused)) const rpcvers_t version,
+				__attribute__((unused)) const unsigned short protocol,
+				__attribute__((unused)) const struct timeval *timeout)
 {
 	rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
 	return 0;

