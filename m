From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/31] support: Introduce sockaddr helpers to get and set IP
	port numbers
Date: Mon, 29 Jun 2009 13:38:16 -0400
Message-ID: <20090629173815.2076.40031.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:39589 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242AbZF2RkF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:05 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce address family-agnostic functions that get and set IP port
numbers in socket addresses.  We can already replace a few similar
functions in the mount command, and a few more will come up with
statd and sm-notify.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nfsrpc.h |   10 +++++++
 support/nfs/getport.c    |   24 ++----------------
 support/nfs/rpc_socket.c |   63 +++++++++++++++++++++++++++++++++-------------
 utils/mount/network.c    |   15 -----------
 4 files changed, 58 insertions(+), 54 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index b3cdb8c..dff6af7 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -59,6 +59,16 @@ static inline void nfs_clear_rpc_createerr(void)
 }
 
 /*
+ * Extract port value from a socket address
+ */
+extern uint16_t		nfs_get_port(const struct sockaddr *);
+
+/*
+ * Set port value in a socket address
+ */
+extern void		nfs_set_port(struct sockaddr *, const uint16_t);
+
+/*
  * Look up an RPC program name in /etc/rpc
  */
 extern rpcprog_t	nfs_getrpcbyname(const rpcprog_t, const char *table[]);
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index f5ba4ef..4d4b1c4 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -113,24 +113,6 @@ static int nfs_gp_loopback_address(struct sockaddr *sap, socklen_t *salen)
 }
 
 /*
- * Plant port number in @sap.  @port is already in network byte order.
- */
-static void nfs_gp_set_port(struct sockaddr *sap, const in_port_t port)
-{
-	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-
-	switch (sap->sa_family) {
-	case AF_INET:
-		sin->sin_port = port;
-		break;
-	case AF_INET6:
-		sin6->sin6_port = port;
-		break;
-	}
-}
-
-/*
  * Look up a network service in /etc/services and return the
  * network-order port number of that service.
  */
@@ -210,7 +192,7 @@ static CLIENT *nfs_gp_get_rpcbclient(struct sockaddr *sap,
 	rpcprog_t rpcb_prog = nfs_getrpcbyname(RPCBPROG, rpcb_pgmtbl);
 	CLIENT *clnt;
 
-	nfs_gp_set_port(sap, nfs_gp_get_rpcb_port(transport));
+	nfs_set_port(sap, ntohs(nfs_gp_get_rpcb_port(transport)));
 	clnt = nfs_get_rpcclient(sap, salen, transport, rpcb_prog,
 							version, timeout);
 	nfs_gp_map_tcp_errorcodes(transport);
@@ -773,7 +755,7 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 		struct sockaddr *saddr = (struct sockaddr *)&address;
 
 		memcpy(saddr, sap, (size_t)salen);
-		nfs_gp_set_port(saddr, htons(port));
+		nfs_set_port(saddr, port);
 
 		nfs_clear_rpc_createerr();
 
@@ -787,7 +769,7 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 	}
 
 	if (result)
-		nfs_gp_set_port(sap, htons(port));
+		nfs_set_port(sap, port);
 
 	return result;
 }
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index a080487..9c20f61 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -416,6 +416,49 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 }
 
 /**
+ * nfs_get_port - extract port value from a socket address
+ * @sap: pointer to socket address
+ *
+ * Returns port value in host byte order.
+ */
+uint16_t
+nfs_get_port(const struct sockaddr *sap)
+{
+       const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+       const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
+
+       switch (sap->sa_family) {
+       case AF_INET:
+               return ntohs(sin->sin_port);
+       case AF_INET6:
+               return ntohs(sin6->sin6_port);
+       }
+       return 0;
+}
+
+/**
+ * nfs_set_port - set port value in a socket address
+ * @sap: pointer to socket address
+ * @port: port value to set
+ *
+ */
+void
+nfs_set_port(struct sockaddr *sap, const uint16_t port)
+{
+       struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+       struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+
+       switch (sap->sa_family) {
+       case AF_INET:
+               sin->sin_port = htons(port);
+               break;
+       case AF_INET6:
+               sin6->sin6_port = htons(port);
+               break;
+       }
+}
+
+/**
  * nfs_get_rpcclient - acquire an RPC client
  * @sap: pointer to socket address of RPC server
  * @salen: length of socket address
@@ -440,9 +483,6 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 			  const rpcvers_t version,
 			  struct timeval *timeout)
 {
-	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-
 	nfs_clear_rpc_createerr();
 
 	switch (sap->sa_family) {
@@ -450,13 +490,8 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 		return nfs_get_localclient(sap, salen, program,
 						version, timeout);
 	case AF_INET:
-		if (sin->sin_port == 0) {
-			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
-			return NULL;
-		}
-		break;
 	case AF_INET6:
-		if (sin6->sin6_port == 0) {
+		if (nfs_get_port(sap) == 0) {
 			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
 			return NULL;
 		}
@@ -505,9 +540,6 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
 			       const rpcvers_t version,
 			       struct timeval *timeout)
 {
-	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-
 	nfs_clear_rpc_createerr();
 
 	switch (sap->sa_family) {
@@ -515,13 +547,8 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
 		return nfs_get_localclient(sap, salen, program,
 						version, timeout);
 	case AF_INET:
-		if (sin->sin_port == 0) {
-			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
-			return NULL;
-		}
-		break;
 	case AF_INET6:
-		if (sin6->sin6_port == 0) {
+		if (nfs_get_port(sap) == 0) {
 			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
 			return NULL;
 		}
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 5b6f4c2..ad6c146 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -170,21 +170,6 @@ static const unsigned long probe_mnt3_first[] = {
 	0,
 };
 
-static void nfs_set_port(struct sockaddr *sap, const unsigned short port)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)sap)->sin_port = htons(port);
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
-		break;
-	default:
-		nfs_error(_("%s: unrecognized address family in %s"),
-			progname, __func__);
-	}
-}
-
 static int nfs_lookup(const char *hostname, const sa_family_t family,
 		      struct sockaddr *sap, socklen_t *salen)
 {

