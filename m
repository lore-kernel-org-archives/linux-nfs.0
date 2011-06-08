Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33691 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141Ab1FHRjT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 13:39:19 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH] nfs-utils:  Support binding to source address.
Date: Wed,  8 Jun 2011 10:39:08 -0700
Message-Id: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This lets one specify the source IP address for
sockets, allowing users to leverage routing rules
on multi-homed systems.

Kernel patches to RPC and NFS are needed to complete
full functionality.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 d50fe94... d8ef257... M	support/include/nfsrpc.h
:100644 100644 9af2543... 3822b4b... M	support/include/sockaddr.h
:100644 100644 d74400b... e8256ff... M	support/nfs/getport.c
:100644 100644 c14efe8... 9cd8538... M	support/nfs/rpc_socket.c
:100644 100644 b1b5793... ccd44a2... M	utils/gssd/gssd.h
:100644 100644 41328c9... e584d20... M	utils/gssd/gssd_proc.c
:100644 100644 f3f0a83... 0c57ea4... M	utils/mount/mount.c
:100644 100644 d1f91dc... 1081144... M	utils/mount/network.c
:100644 100644 81c6f22... 4af8fd1... M	utils/mount/network.h
:100644 100644 b03792e... 8bf379c... M	utils/mount/nfs4_mount.h
:100644 100644 028e7cd... 432947d... M	utils/mount/nfs4mount.c
:100644 100644 2becfb1... 07b9cc3... M	utils/mount/nfs_mount.h
:100644 100644 1298fe4... 7d9a925... M	utils/mount/nfsmount.c
:100644 100644 8cd2852... 053a91f... M	utils/mount/nfsumount.c
:100644 100644 f1aa503... 31c41d6... M	utils/mount/stropts.c
:100644 100644 b4fd888... 68cebaa... M	utils/mount/stropts.h
:100644 100644 298db39... dfad580... M	utils/mount/utils.c
:100644 100644 3fcd504... 8471458... M	utils/mount/utils.h
 support/include/nfsrpc.h   |   23 ++++--
 support/include/sockaddr.h |    6 ++
 support/nfs/getport.c      |   37 ++++++---
 support/nfs/rpc_socket.c   |   98 ++++++++++++++++++-------
 utils/gssd/gssd.h          |    2 +
 utils/gssd/gssd_proc.c     |   33 +++++----
 utils/mount/mount.c        |   34 ++++++--
 utils/mount/network.c      |  174 +++++++++++++++++++++++++++++++++++---------
 utils/mount/network.h      |   20 +++--
 utils/mount/nfs4_mount.h   |    5 +-
 utils/mount/nfs4mount.c    |    6 +-
 utils/mount/nfs_mount.h    |    5 +-
 utils/mount/nfsmount.c     |   14 ++--
 utils/mount/nfsumount.c    |   20 ++++-
 utils/mount/stropts.c      |   15 +++-
 utils/mount/stropts.h      |    2 +-
 utils/mount/utils.c        |    8 ++-
 utils/mount/utils.h        |    3 +-
 18 files changed, 368 insertions(+), 137 deletions(-)

diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
index d50fe94..d8ef257 100644
--- a/support/include/nfsrpc.h
+++ b/support/include/nfsrpc.h
@@ -55,6 +55,8 @@
 #define NSMPROG		((rpcprog_t)100024)
 #endif
 
+struct local_bind_info;
+
 /**
  * nfs_clear_rpc_createerr - zap all error reporting fields
  *
@@ -75,7 +77,8 @@ extern rpcprog_t	nfs_getrpcbyname(const rpcprog_t, const char *table[]);
 extern CLIENT		*nfs_get_rpcclient(const struct sockaddr *,
 				const socklen_t, const unsigned short,
 				const rpcprog_t, const rpcvers_t,
-				struct timeval *);
+				struct timeval *,
+				struct local_bind_info *);
 
 /*
  * Acquire an RPC CLIENT * with a privileged source port
@@ -83,7 +86,8 @@ extern CLIENT		*nfs_get_rpcclient(const struct sockaddr *,
 extern CLIENT		*nfs_get_priv_rpcclient( const struct sockaddr *,
 				const socklen_t, const unsigned short,
 				const rpcprog_t, const rpcvers_t,
-				struct timeval *);
+				struct timeval *,
+				struct local_bind_info *);
 
 /*
  * Convert a netid to a protocol number and protocol family
@@ -116,7 +120,8 @@ extern int		nfs_getport_ping(struct sockaddr *sap,
 				const socklen_t salen,
 				const rpcprog_t program,
 				const rpcvers_t version,
-				const unsigned short protocol);
+				const unsigned short protocol,
+				struct local_bind_info *local_ip);
 
 /*
  * Generic function that maps an RPC service tuple to an IP port
@@ -124,14 +129,16 @@ extern int		nfs_getport_ping(struct sockaddr *sap,
  */
 extern unsigned short	nfs_getport(const struct sockaddr *,
 				const socklen_t, const rpcprog_t,
-				const rpcvers_t, const unsigned short);
+				const rpcvers_t, const unsigned short,
+				struct local_bind_info *local_ip);
 
 /*
  * Generic function that maps an RPC service tuple to an IP port
  * number of the service on the local host
  */
 extern unsigned short	nfs_getlocalport(const rpcprot_t,
-				const rpcvers_t, const unsigned short);
+				const rpcvers_t, const unsigned short,
+				struct local_bind_info *local_ip);
 
 /*
  * Function to invoke an rpcbind v3/v4 GETADDR request
@@ -153,7 +160,8 @@ extern unsigned long	nfs_pmap_getport(const struct sockaddr_in *,
 				const unsigned long,
 				const unsigned long,
 				const unsigned long,
-				const struct timeval *);
+				const struct timeval *,
+				struct local_bind_info *local_ip);
 
 /*
  * Contact a remote RPC service to discover whether it is responding
@@ -164,7 +172,8 @@ extern int		nfs_rpc_ping(const struct sockaddr *sap,
 				const rpcprog_t program,
 				const rpcvers_t version,
 				const unsigned short protocol,
-				const struct timeval *timeout);
+				const struct timeval *timeout,
+				struct local_bind_info *local_ip);
 
 /* create AUTH_SYS handle with no supplemental groups */
 extern AUTH *			 nfs_authsys_create(void);
diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
index 9af2543..3822b4b 100644
--- a/support/include/sockaddr.h
+++ b/support/include/sockaddr.h
@@ -46,6 +46,12 @@ union nfs_sockaddr {
 	struct sockaddr_in6	s6;
 };
 
+struct local_bind_info {
+	struct sockaddr_storage addr;
+	int addrlen;
+	int is_set;
+};
+
 #if SIZEOF_SOCKLEN_T - 0 == 0
 #define socklen_t unsigned int
 #endif
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index d74400b..e8256ff 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -181,7 +181,8 @@ static CLIENT *nfs_gp_get_rpcbclient(struct sockaddr *sap,
 				     const socklen_t salen,
 				     const unsigned short transport,
 				     const rpcvers_t version,
-				     struct timeval *timeout)
+				     struct timeval *timeout,
+				     struct local_bind_info *local_ip)
 {
 	static const char *rpcb_pgmtbl[] = {
 		"rpcbind",
@@ -195,7 +196,7 @@ static CLIENT *nfs_gp_get_rpcbclient(struct sockaddr *sap,
 
 	nfs_set_port(sap, ntohs(nfs_gp_get_rpcb_port(transport)));
 	clnt = nfs_get_rpcclient(sap, salen, transport, rpcb_prog,
-							version, timeout);
+				 version, timeout, local_ip);
 	nfs_gp_map_tcp_errorcodes(transport);
 	return clnt;
 }
@@ -729,7 +730,8 @@ static unsigned short nfs_gp_getport(CLIENT *client,
  */
 int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
 		 const rpcprog_t program, const rpcvers_t version,
-		 const unsigned short protocol, const struct timeval *timeout)
+		 const unsigned short protocol, const struct timeval *timeout,
+		 struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *saddr = &address.sa;
@@ -744,7 +746,7 @@ int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
 
 	memcpy(saddr, sap, (size_t)salen);
 	client = nfs_get_rpcclient(saddr, salen, protocol,
-						program, version, &tout);
+				   program, version, &tout, local_ip);
 	if (client != NULL) {
 		result = nfs_gp_ping(client, tout);
 		nfs_gp_map_tcp_errorcodes(protocol);
@@ -798,7 +800,8 @@ unsigned short nfs_getport(const struct sockaddr *sap,
 			   const socklen_t salen,
 			   const rpcprog_t program,
 			   const rpcvers_t version,
-			   const unsigned short protocol)
+			   const unsigned short protocol,
+			   struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *saddr = &address.sa;
@@ -810,7 +813,8 @@ unsigned short nfs_getport(const struct sockaddr *sap,
 
 	memcpy(saddr, sap, (size_t)salen);
 	client = nfs_gp_get_rpcbclient(saddr, salen, protocol,
-						default_rpcb_version, &timeout);
+				       default_rpcb_version, &timeout,
+				       local_ip);
 	if (client != NULL) {
 		port = nfs_gp_getport(client, saddr, program,
 					version, protocol, timeout);
@@ -840,7 +844,8 @@ unsigned short nfs_getport(const struct sockaddr *sap,
  */
 int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 		     const rpcprog_t program, const rpcvers_t version,
-		     const unsigned short protocol)
+		     const unsigned short protocol,
+		     struct local_bind_info *local_ip)
 {
 	struct timeval timeout = { -1, 0 };
 	unsigned short port = 0;
@@ -850,7 +855,8 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 	nfs_clear_rpc_createerr();
 
 	client = nfs_gp_get_rpcbclient(sap, salen, protocol,
-						default_rpcb_version, &timeout);
+				       default_rpcb_version, &timeout,
+				       local_ip);
 	if (client != NULL) {
 		port = nfs_gp_getport(client, sap, program,
 					version, protocol, timeout);
@@ -868,7 +874,8 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 		nfs_clear_rpc_createerr();
 
 		client = nfs_get_rpcclient(saddr, salen, protocol,
-						program, version, &timeout);
+					   program, version, &timeout,
+					   local_ip);
 		if (client != NULL) {
 			result = nfs_gp_ping(client, timeout);
 			nfs_gp_map_tcp_errorcodes(protocol);
@@ -909,7 +916,8 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
  */
 unsigned short nfs_getlocalport(const rpcprot_t program,
 				const rpcvers_t version,
-				const unsigned short protocol)
+				const unsigned short protocol,
+				struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *lb_addr = &address.sa;
@@ -946,7 +954,8 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 
 		if (nfs_gp_loopback_address(lb_addr, &lb_len)) {
 			port = nfs_getport(lb_addr, lb_len,
-						program, version, protocol);
+					   program, version, protocol,
+					   local_ip);
 		} else
 			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
 	}
@@ -1074,7 +1083,8 @@ unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
 			       const unsigned long program,
 			       const unsigned long version,
 			       const unsigned long protocol,
-			       const struct timeval *timeout)
+			       const struct timeval *timeout,
+			       struct local_bind_info *local_ip)
 {
 	struct sockaddr_in address;
 	struct sockaddr *saddr = (struct sockaddr *)&address;
@@ -1094,7 +1104,8 @@ unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
 
 	memcpy(saddr, sin, sizeof(address));
 	client = nfs_gp_get_rpcbclient(saddr, (socklen_t)sizeof(*sin),
-					transport, PMAPVERS, &tout);
+				       transport, PMAPVERS, &tout,
+				       local_ip);
 	if (client != NULL) {
 		port = nfs_gp_pmap_getport(client, &parms, tout);
 		CLNT_DESTROY(client);
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index c14efe8..9cd8538 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -112,8 +112,12 @@ static CLIENT *nfs_get_localclient(const struct sockaddr *sap,
  * Returns zero on success, or returns -1 on error.  errno is
  * set to reflect the nature of the error.
  */
-static int nfs_bind(const int sock, const sa_family_t family)
+static int nfs_bind(const int sock, const sa_family_t family,
+		    struct local_bind_info *local_ip)
 {
+	struct sockaddr *sa = NULL;
+	socklen_t salen = 0;
+
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
@@ -123,15 +127,26 @@ static int nfs_bind(const int sock, const sa_family_t family)
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 	};
 
-	switch (family) {
-	case AF_INET:
-		return bind(sock, (struct sockaddr *)(char *)&sin,
-					(socklen_t)sizeof(sin));
-	case AF_INET6:
-		return bind(sock, (struct sockaddr *)(char *)&sin6,
-					(socklen_t)sizeof(sin6));
+	if (local_ip && local_ip->is_set) {
+		sa = (struct sockaddr *)(char *)(&local_ip->addr);
+		salen = local_ip->addrlen;
+	} else {
+		switch (family) {
+		case AF_INET:
+			sa = (struct sockaddr *)(char *)&sin;
+			salen = sizeof(sin);
+			break;
+		case AF_INET6:
+			sa = (struct sockaddr *)(char *)&sin6;
+			salen = sizeof(sin6);
+		default:
+			break;
+		}
 	}
 
+	if (sa)
+		return bind(sock, sa, salen);
+
 	errno = EAFNOSUPPORT;
 	return -1;
 }
@@ -144,8 +159,10 @@ static int nfs_bind(const int sock, const sa_family_t family)
  * Returns zero on success, or returns -1 on error.  errno is
  * set to reflect the nature of the error.
  */
-static int nfs_bindresvport(const int sock, const sa_family_t family)
+static int nfs_bindresvport(const int sock, const sa_family_t family,
+			    struct local_bind_info *local_ip)
 {
+	struct sockaddr *sa = NULL;
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
@@ -155,13 +172,23 @@ static int nfs_bindresvport(const int sock, const sa_family_t family)
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 	};
 
-	switch (family) {
-	case AF_INET:
-		return bindresvport_sa(sock, (struct sockaddr *)(char *)&sin);
-	case AF_INET6:
-		return bindresvport_sa(sock, (struct sockaddr *)(char *)&sin6);
+	if (local_ip && local_ip->is_set) {
+		sa = (struct sockaddr *)(char *)(&local_ip->addr);
+	} else {
+		switch (family) {
+		case AF_INET:
+			sa = (struct sockaddr *)(char *)&sin;
+			break;
+		case AF_INET6:
+			sa = (struct sockaddr *)(char *)&sin6;
+		default:
+			break;
+		}
 	}
 
+	if (sa)
+		return bindresvport_sa(sock, sa);
+
 	errno = EAFNOSUPPORT;
 	return -1;
 }
@@ -174,14 +201,25 @@ static int nfs_bindresvport(const int sock, const sa_family_t family)
  * Returns zero on success, or returns -1 on error.  errno is
  * set to reflect the nature of the error.
  */
-static int nfs_bindresvport(const int sock, const sa_family_t family)
+static int nfs_bindresvport(const int sock, const sa_family_t family,
+			    struct local_bind_info *local_ip)
 {
+	struct sockaddr_in laddr;
 	if (family != AF_INET) {
 		errno = EAFNOSUPPORT;
 		return -1;
 	}
 
-	return bindresvport(sock, NULL);
+	laddr.sin_family = family;
+	laddr.sin_port = 0;
+	if (local_ip && local_ip->is_set) {
+		struct sockaddr_in *si;
+		si = (struct sockaddr_in *)(&local_ip->addr);
+		laddr.sin_addr.s_addr = si->sin_addr.s_addr;
+	} else {
+		laddr.sin_addr.s_addr = htonl(INADDR_ANY);
+	}
+	return bindresvport(sock, &laddr);
 }
 
 #endif	/* !HAVE_LIBTIRPC */
@@ -273,7 +311,8 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 				 const rpcprog_t program,
 				 const rpcvers_t version,
 				 struct timeval *timeout,
-				 const int resvport)
+				 const int resvport,
+				 struct local_bind_info *local_ip)
 {
 	CLIENT *client;
 	int ret, sock;
@@ -301,9 +340,9 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 	}
 
 	if (resvport)
-		ret = nfs_bindresvport(sock, sap->sa_family);
+		ret = nfs_bindresvport(sock, sap->sa_family, local_ip);
 	else
-		ret = nfs_bind(sock, sap->sa_family);
+		ret = nfs_bind(sock, sap->sa_family, local_ip);
 	if (ret < 0) {
 		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 		rpc_createerr.cf_error.re_errno = errno;
@@ -355,7 +394,8 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 				 const rpcprog_t program,
 				 const rpcvers_t version,
 				 struct timeval *timeout,
-				 const int resvport)
+				 const int resvport,
+				 struct local_bind_info *local_ip)
 {
 	CLIENT *client;
 	int ret, sock;
@@ -383,9 +423,9 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 	}
 
 	if (resvport)
-		ret = nfs_bindresvport(sock, sap->sa_family);
+		ret = nfs_bindresvport(sock, sap->sa_family, local_ip);
 	else
-		ret = nfs_bind(sock, sap->sa_family);
+		ret = nfs_bind(sock, sap->sa_family, local_ip);
 	if (ret < 0) {
 		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 		rpc_createerr.cf_error.re_errno = errno;
@@ -442,7 +482,8 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 			  const unsigned short transport,
 			  const rpcprog_t program,
 			  const rpcvers_t version,
-			  struct timeval *timeout)
+			  struct timeval *timeout,
+			  struct local_bind_info *local_ip)
 {
 	nfs_clear_rpc_createerr();
 
@@ -465,11 +506,11 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 	switch (transport) {
 	case IPPROTO_TCP:
 		return nfs_get_tcpclient(sap, salen, program, version,
-						timeout, 0);
+					 timeout, 0, local_ip);
 	case 0:
 	case IPPROTO_UDP:
 		return nfs_get_udpclient(sap, salen, program, version,
-						timeout, 0);
+					 timeout, 0, local_ip);
 	}
 
 	rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
@@ -499,7 +540,8 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
 			       const unsigned short transport,
 			       const rpcprog_t program,
 			       const rpcvers_t version,
-			       struct timeval *timeout)
+			       struct timeval *timeout,
+			       struct local_bind_info *local_ip)
 {
 	nfs_clear_rpc_createerr();
 
@@ -522,11 +564,11 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
 	switch (transport) {
 	case IPPROTO_TCP:
 		return nfs_get_tcpclient(sap, salen, program, version,
-						timeout, 1);
+					 timeout, 1, local_ip);
 	case 0:
 	case IPPROTO_UDP:
 		return nfs_get_udpclient(sap, salen, program, version,
-						timeout, 1);
+					 timeout, 1, local_ip);
 	}
 
 	rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index b1b5793..ccd44a2 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -34,6 +34,7 @@
 #include <sys/types.h>
 #include <sys/queue.h>
 #include <gssapi/gssapi.h>
+#include "sockaddr.h"
 
 #define MAX_FILE_NAMELEN	32
 #define FD_ALLOC_BLOCK		256
@@ -85,6 +86,7 @@ struct clnt_info {
 	int                     gssd_fd;
 	int                     gssd_poll_index;
 	struct sockaddr_storage addr;
+	struct local_bind_info  local_ip;
 };
 
 TAILQ_HEAD(topdirs_list_head, topdirs_info) topdirs_list;
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 41328c9..e584d20 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -726,7 +726,8 @@ out_err:
 static int
 populate_port(struct sockaddr *sa, const socklen_t salen,
 	      const rpcprog_t program, const rpcvers_t version,
-	      const unsigned short protocol)
+	      const unsigned short protocol,
+	      struct local_bind_info *local_ip)
 {
 	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
 #ifdef IPV6_SUPPORTED
@@ -774,7 +775,7 @@ populate_port(struct sockaddr *sa, const socklen_t salen,
 		goto set_port;
 	}
 
-	port = nfs_getport(sa, salen, program, version, protocol);
+	port = nfs_getport(sa, salen, program, version, protocol, local_ip);
 	if (!port) {
 		printerr(0, "ERROR: unable to obtain port for prog %ld "
 			    "vers %ld\n", program, version);
@@ -807,7 +808,8 @@ int create_auth_rpc_client(struct clnt_info *clp,
 			   CLIENT **clnt_return,
 			   AUTH **auth_return,
 			   uid_t uid,
-			   int authtype)
+			   int authtype,
+			   struct local_bind_info *local_ip)
 {
 	CLIENT			*rpc_clnt = NULL;
 	struct rpc_gss_sec	sec;
@@ -899,11 +901,12 @@ int create_auth_rpc_client(struct clnt_info *clp,
 		goto out_fail;
 	}
 
-	if (!populate_port(addr, salen, clp->prog, clp->vers, protocol))
+	if (!populate_port(addr, salen, clp->prog, clp->vers,
+			   protocol, local_ip))
 		goto out_fail;
 
 	rpc_clnt = nfs_get_rpcclient(addr, salen, protocol, clp->prog,
-				     clp->vers, &timeout);
+				     clp->vers, &timeout, local_ip);
 	if (!rpc_clnt) {
 		snprintf(rpc_errmsg, sizeof(rpc_errmsg),
 			 "WARNING: can't create %s rpc_clnt to server %s for "
@@ -955,7 +958,7 @@ int create_auth_rpc_client(struct clnt_info *clp,
  */
 static void
 process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
-		    char *service)
+		    char *service, struct local_bind_info *local_ip)
 {
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
@@ -1011,7 +1014,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 				downcall_err = -EKEYEXPIRED;
 			else if (!err)
 				create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
-							     AUTHTYPE_KRB5);
+								     AUTHTYPE_KRB5, local_ip);
 			if (create_resp == 0)
 				break;
 		}
@@ -1038,7 +1041,8 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 					gssd_setup_krb5_machine_gss_ccache(*ccname);
 					if ((create_auth_rpc_client(clp, &rpc_clnt,
 								    &auth, uid,
-								    AUTHTYPE_KRB5)) == 0) {
+								    AUTHTYPE_KRB5,
+								    local_ip)) == 0) {
 						/* Success! */
 						success++;
 						break;
@@ -1108,7 +1112,8 @@ out_return_error:
  * context on behalf of the kernel
  */
 static void
-process_spkm3_upcall(struct clnt_info *clp, uid_t uid, int fd)
+process_spkm3_upcall(struct clnt_info *clp, uid_t uid, int fd,
+		     struct local_bind_info *local_ip)
 {
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
@@ -1120,7 +1125,7 @@ process_spkm3_upcall(struct clnt_info *clp, uid_t uid, int fd)
 	token.length = 0;
 	token.value = NULL;
 
-	if (create_auth_rpc_client(clp, &rpc_clnt, &auth, uid, AUTHTYPE_SPKM3)) {
+	if (create_auth_rpc_client(clp, &rpc_clnt, &auth, uid, AUTHTYPE_SPKM3, local_ip)) {
 		printerr(0, "WARNING: Failed to create spkm3 context for "
 			    "user with uid %d\n", uid);
 		goto out_return_error;
@@ -1167,7 +1172,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 		return;
 	}
 
-	return process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL);
+	process_krb5_upcall(clp, uid, clp->krb5_fd, NULL, NULL, &clp->local_ip);
 }
 
 void
@@ -1181,7 +1186,7 @@ handle_spkm3_upcall(struct clnt_info *clp)
 		return;
 	}
 
-	return process_spkm3_upcall(clp, uid, clp->spkm3_fd);
+	process_spkm3_upcall(clp, uid, clp->spkm3_fd, &clp->local_ip);
 }
 
 void
@@ -1291,9 +1296,9 @@ handle_gssd_upcall(struct clnt_info *clp)
 	}
 
 	if (strcmp(mech, "krb5") == 0)
-		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service);
+		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service, &clp->local_ip);
 	else if (strcmp(mech, "spkm3") == 0)
-		process_spkm3_upcall(clp, uid, clp->gssd_fd);
+		process_spkm3_upcall(clp, uid, clp->gssd_fd, &clp->local_ip);
 	else
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "received unknown gss mech '%s'\n", mech);
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index f3f0a83..0c57ea4 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -48,6 +48,7 @@
 #include "error.h"
 #include "stropts.h"
 #include "utils.h"
+#include "network.h"
 
 char *progname;
 int nfs_mount_data_version;
@@ -55,6 +56,7 @@ int nomtab;
 int verbose;
 int sloppy;
 int string;
+struct local_bind_info glb_local_ip;
 
 #define FOREGROUND	(0)
 #define BACKGROUND	(1)
@@ -305,6 +307,9 @@ static void parse_opt(const char *opt, int *mask, char *extra_opts, size_t len)
 
 	if ((len -= strlen(opt)) > 0)
 		strcat(extra_opts, opt);
+
+	if (strncmp(opt, "srcaddr=", strlen("srcaddr=")) == 0)
+		parse_local_bind(&glb_local_ip, opt + strlen("srcaddr="));
 }
 
 /*
@@ -345,21 +350,21 @@ static void parse_opts(const char *options, int *flags, char **extra_opts)
 }
 
 static int try_mount(char *spec, char *mount_point, int flags,
-			char *fs_type, char **extra_opts, char *mount_opts,
-			int fake, int bg)
+		     char *fs_type, char **extra_opts, char *mount_opts,
+		     int fake, int bg, struct local_bind_info *local_ip)
 {
 	int ret;
 
 	if (string)
 		ret = nfsmount_string(spec, mount_point, fs_type, flags,
-					extra_opts, fake, bg);
+				      extra_opts, fake, bg, local_ip);
 	else {
 		if (strcmp(fs_type, "nfs4") == 0)
 			ret = nfs4mount(spec, mount_point, flags,
-					extra_opts, fake, bg);
+					extra_opts, fake, bg, local_ip);
 		else
 			ret = nfsmount(spec, mount_point, flags,
-					extra_opts, fake, bg);
+				       extra_opts, fake, bg, local_ip);
 	}
 
 	if (ret)
@@ -377,6 +382,7 @@ int main(int argc, char *argv[])
 	char *spec, *mount_point, *fs_type = "nfs";
 	char *extra_opts = NULL, *mount_opts = NULL;
 	uid_t uid = getuid();
+	char *env;
 
 	progname = basename(argv[0]);
 
@@ -404,7 +410,7 @@ int main(int argc, char *argv[])
 	mount_config_init(progname);
 
 	argv[2] = argv[0]; /* so that getopt error messages are correct */
-	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
+	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hsI:",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
@@ -434,6 +440,9 @@ int main(int argc, char *argv[])
 		case 's':
 			++sloppy;
 			break;
+		case 'I':
+			parse_local_bind(&glb_local_ip, optarg);
+			break;
 		case 'h':
 		default:
 			mount_usage();
@@ -495,6 +504,13 @@ int main(int argc, char *argv[])
 
 	parse_opts(mount_opts, &flags, &extra_opts);
 
+	/* It is hard to pass new cmd line args to this, so allow env to
+	 * set local binding as well.
+	 */
+	env = getenv("MNT_SRCADDR");
+	if (env)
+		parse_local_bind(&glb_local_ip, env);
+
 	if (uid != 0) {
 		if (!(flags & (MS_USERS|MS_USER))) {
 			nfs_error(_("%s: permission denied"), progname);
@@ -515,7 +531,7 @@ int main(int argc, char *argv[])
 	}
 
 	mnt_err = try_mount(spec, mount_point, flags, fs_type, &extra_opts,
-				mount_opts, fake, FOREGROUND);
+			    mount_opts, fake, FOREGROUND, &glb_local_ip);
 	if (mnt_err == EX_BG) {
 		printf(_("%s: backgrounding \"%s\"\n"),
 			progname, spec);
@@ -535,8 +551,8 @@ int main(int argc, char *argv[])
 		}
 
 		mnt_err = try_mount(spec, mount_point, flags, fs_type,
-					&extra_opts, mount_opts, fake,
-					BACKGROUND);
+				    &extra_opts, mount_opts, fake,
+				    BACKGROUND, &glb_local_ip);
 		if (verbose && mnt_err)
 			printf(_("%s: giving up \"%s\"\n"),
 				progname, spec);
diff --git a/utils/mount/network.c b/utils/mount/network.c
index d1f91dc..1081144 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -404,30 +404,116 @@ out:
 	return 0;
 }
 
+
+void
+parse_local_bind(struct local_bind_info *laddr, const char* str) {
+	/* str is an IP address. */
+	int aiErr;
+	unsigned int i;
+	struct addrinfo *aiHead;
+	struct addrinfo hints;
+	char *node = NULL; /* ip addr */
+	char *service = NULL; /* port */
+	char *tmp = xstrdup(str);
+
+	laddr->is_set = 0;
+
+	memset(&hints, 0, sizeof(hints));
+
+	hints.ai_flags  = AI_NUMERICSERV;
+	hints.ai_socktype = SOCK_STREAM;
+	hints.ai_protocol = IPPROTO_TCP;
+
+	if (str[0] == '[') {
+		/* IPv6 addr */
+		hints.ai_family = PF_INET6;
+		node = tmp + 1;
+		for (i = 0; i < strlen(node); i++) {
+			if (node[i] == ']') {
+				node[i] = 0;
+				service = &(node[i+1]);
+				break;
+			}
+		}
+	} else {
+		hints.ai_family = PF_INET;
+		node = tmp;
+		service = node;
+	}
+
+	if (service) {
+		int found_port = 0;
+		for (i = 0; i < strlen(service); i++) {
+			if (service[i] == ':') {
+				service += i+1;
+				found_port = 1;
+				break;
+			}
+		}
+		if (!found_port)
+			service = NULL;
+	}
+
+	aiErr = getaddrinfo(node, service, &hints, &aiHead);
+	if (aiErr != 0) {
+		printf("node: %s service: %s  ai_family: %s  aiErr: %i %s\n",
+		       node, service,
+		       hints.ai_family == PF_INET6 ? "INET6" : "INET",
+		       aiErr, gai_strerror(aiErr));
+		perror("getaddrinfo");
+	} else {
+		if (aiHead) {
+			memcpy(&laddr->addr, aiHead->ai_addr, aiHead->ai_addrlen);
+			laddr->addrlen = aiHead->ai_addrlen;
+			laddr->is_set = 1;
+			freeaddrinfo(aiHead);
+		}
+	}
+	free(tmp);
+}
+
 /*
  * Create a socket that is locally bound to a reserved or non-reserved port.
  *
  * The caller should check rpc_createerr to determine the cause of any error.
  */
 static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
-			unsigned int timeout, int resvp, int conn)
+		      unsigned int timeout, int resvp, int conn,
+		      struct local_bind_info *local_ip)
 {
 	int so, cc, type;
 	struct sockaddr_in laddr;
 	socklen_t namelen = sizeof(laddr);
+	int f = AF_INET;
+
+	if (local_ip && local_ip->is_set)
+		f = local_ip->addr.ss_family;
 
 	type = (p_prot == IPPROTO_UDP ? SOCK_DGRAM : SOCK_STREAM);
-	if ((so = socket (AF_INET, type, p_prot)) < 0)
+
+	so = socket(f, type, p_prot);
+	if (so < 0)
 		goto err_socket;
 
-	laddr.sin_family = AF_INET;
+	laddr.sin_family = f;
 	laddr.sin_port = 0;
 	laddr.sin_addr.s_addr = htonl(INADDR_ANY);
 	if (resvp) {
+		/* TODO:  Support IPv6 */
+		if (local_ip && local_ip->is_set
+		    && local_ip->addr.ss_family == AF_INET) {
+			struct sockaddr_in *si;
+			si = (struct sockaddr_in *)(&local_ip->addr);
+			laddr.sin_addr.s_addr = si->sin_addr.s_addr;
+		}
 		if (bindresvport(so, &laddr) < 0)
 			goto err_bindresvport;
 	} else {
-		cc = bind(so, SAFE_SOCKADDR(&laddr), namelen);
+		if (local_ip && local_ip->is_set)
+			cc = bind(so, (struct sockaddr *)&(local_ip->addr),
+				  local_ip->addrlen);
+		else
+			cc = bind(so, SAFE_SOCKADDR(&laddr), namelen);
 		if (cc < 0)
 			goto err_bind;
 	}
@@ -537,7 +623,8 @@ static void nfs_pp_debug2(const char *str)
  */
 static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 			  struct pmap *pmap, const unsigned long *versions,
-			  const unsigned int *protos)
+			  const unsigned int *protos,
+			  struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *saddr = &address.sa;
@@ -555,14 +642,16 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 		if (verbose)
 			printf(_("%s: prog %lu, trying vers=%lu, prot=%u\n"),
 				progname, prog, *p_vers, *p_prot);
-		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
+		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot,
+				     local_ip);
 		if (p_port) {
 			if (!port || port == p_port) {
 				nfs_set_port(saddr, p_port);
 				nfs_pp_debug(saddr, salen, prog, *p_vers,
 						*p_prot, p_port);
 				if (nfs_rpc_ping(saddr, salen, prog,
-							*p_vers, *p_prot, NULL))
+						 *p_vers, *p_prot, NULL,
+						 local_ip))
 					goto out_ok;
 			} else
 				rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
@@ -615,7 +704,8 @@ out_ok:
  * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
  */
 static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
-				struct pmap *pmap)
+			     struct pmap *pmap,
+			     struct local_bind_info *local_ip)
 {
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
@@ -626,10 +716,12 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
 		probe_proto = nfs_default_proto();
 
 		return nfs_probe_port(sap, salen, pmap,
-					probe_nfs3_first, probe_proto);
+				      probe_nfs3_first, probe_proto,
+				      local_ip);
 	} else
 		return nfs_probe_port(sap, salen, pmap,
-					probe_nfs2_only, probe_udp_only);
+				      probe_nfs2_only, probe_udp_only,
+				      local_ip);
 }
 
 /*
@@ -646,17 +738,20 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
  * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
  */
 static int nfs_probe_mntport(const struct sockaddr *sap, const socklen_t salen,
-				struct pmap *pmap)
+			     struct pmap *pmap,
+			     struct local_bind_info *local_ip)
 {
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
 
 	if (nfs_mount_data_version >= 4)
 		return nfs_probe_port(sap, salen, pmap,
-					probe_mnt3_first, probe_udp_first);
+				      probe_mnt3_first, probe_udp_first,
+				      local_ip);
 	else
 		return nfs_probe_port(sap, salen, pmap,
-					probe_mnt1_first, probe_udp_only);
+				      probe_mnt1_first, probe_udp_only,
+				      local_ip);
 }
 
 /*
@@ -673,11 +768,12 @@ static int nfs_probe_version_fixed(const struct sockaddr *mnt_saddr,
 			struct pmap *mnt_pmap,
 			const struct sockaddr *nfs_saddr,
 			const socklen_t nfs_salen,
-			struct pmap *nfs_pmap)
+			struct pmap *nfs_pmap,
+			struct local_bind_info *local_ip)
 {
-	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap))
+	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap, local_ip))
 		return 0;
-	return nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap);
+	return nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap, local_ip);
 }
 
 /**
@@ -700,7 +796,8 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 			struct pmap *mnt_pmap,
 			const struct sockaddr *nfs_saddr,
 			const socklen_t nfs_salen,
-			struct pmap *nfs_pmap)
+			struct pmap *nfs_pmap,
+			struct local_bind_info *local_ip)
 {
 	struct pmap save_nfs, save_mnt;
 	const unsigned long *probe_vers;
@@ -712,7 +809,8 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 
 	if (nfs_pmap->pm_vers)
 		return nfs_probe_version_fixed(mnt_saddr, mnt_salen, mnt_pmap,
-					       nfs_saddr, nfs_salen, nfs_pmap);
+					       nfs_saddr, nfs_salen, nfs_pmap,
+					       local_ip);
 
 	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
 	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
@@ -721,9 +819,9 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 
 	for (; *probe_vers; probe_vers++) {
 		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
-		if (nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap) != 0) {
+		if (nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap, local_ip) != 0) {
 			mnt_pmap->pm_vers = *probe_vers;
-			if (nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap) != 0)
+			if (nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap, local_ip) != 0)
 				return 1;
 			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
 		}
@@ -753,7 +851,8 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
  * Otherwise zero is returned; rpccreateerr.cf_stat is set to reflect
  * the nature of the error.
  */
-int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
+int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server,
+		    struct local_bind_info *local_ip)
 {
 	struct sockaddr *mnt_addr = SAFE_SOCKADDR(&mnt_server->saddr);
 	struct sockaddr *nfs_addr = SAFE_SOCKADDR(&nfs_server->saddr);
@@ -761,7 +860,7 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 	return nfs_probe_bothports(mnt_addr, sizeof(mnt_server->saddr),
 					&mnt_server->pmap,
 					nfs_addr, sizeof(nfs_server->saddr),
-					&nfs_server->pmap);
+				   &nfs_server->pmap, local_ip);
 }
 
 static int nfs_probe_statd(void)
@@ -773,7 +872,8 @@ static int nfs_probe_statd(void)
 	rpcprog_t program = nfs_getrpcbyname(NSMPROG, nfs_ns_pgmtbl);
 
 	return nfs_getport_ping(SAFE_SOCKADDR(&addr), sizeof(addr),
-				program, (rpcvers_t)1, IPPROTO_UDP);
+				program, (rpcvers_t)1, IPPROTO_UDP,
+				NULL);
 }
 
 /**
@@ -829,7 +929,8 @@ int start_statd(void)
  * We use a fast timeout since this call is advisory only.
  */
 int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
-		      const struct pmap *pmap, const dirpath *argp)
+		      const struct pmap *pmap, const dirpath *argp,
+		      struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *saddr = &address.sa;
@@ -841,7 +942,7 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 	enum clnt_stat res = 0;
 
 	memcpy(saddr, sap, salen);
-	if (nfs_probe_mntport(saddr, salen, &mnt_pmap) == 0) {
+	if (nfs_probe_mntport(saddr, salen, &mnt_pmap, local_ip) == 0) {
 		if (verbose)
 			nfs_error(_("%s: Failed to discover mountd port%s"),
 				progname, clnt_spcreateerror(""));
@@ -851,7 +952,7 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 
 	client = nfs_get_priv_rpcclient(saddr, salen, mnt_pmap.pm_prot,
 					mnt_pmap.pm_prog, mnt_pmap.pm_vers,
-					&timeout);
+					&timeout, local_ip);
 	if (client == NULL) {
 		if (verbose)
 			nfs_error(_("%s: Failed to create RPC client%s"),
@@ -899,7 +1000,8 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
  * Note that a side effect of calling this function is that rpccreateerr
  * is set.
  */
-int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
+int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp,
+		    struct local_bind_info *local_ip)
 {
 	struct sockaddr *sap = SAFE_SOCKADDR(&mnt_server->saddr);
 	socklen_t salen = sizeof(mnt_server->saddr);
@@ -908,9 +1010,9 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 	enum clnt_stat res = 0;
 	int msock;
 
-	if (!nfs_probe_mntport(sap, salen, pmap))
+	if (!nfs_probe_mntport(sap, salen, pmap, local_ip))
 		return 0;
-	clnt = mnt_openclnt(mnt_server, &msock);
+	clnt = mnt_openclnt(mnt_server, &msock, local_ip);
 	if (!clnt)
 		return 0;
 	res = clnt_call(clnt, MOUNTPROC_UMNT,
@@ -931,7 +1033,8 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
  *
  * Returns an active handle for the remote's mountd service
  */
-CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
+CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock,
+		     struct local_bind_info *local_ip)
 {
 	struct sockaddr_in *mnt_saddr = &mnt_server->saddr;
 	struct pmap *mnt_pmap = &mnt_server->pmap;
@@ -939,7 +1042,7 @@ CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
 
 	mnt_saddr->sin_port = htons((u_short)mnt_pmap->pm_port);
 	*msock = get_socket(mnt_saddr, mnt_pmap->pm_prot, MOUNT_TIMEOUT,
-				TRUE, FALSE);
+			    TRUE, FALSE, local_ip);
 	if (*msock == RPC_ANYSOCK) {
 		if (rpc_createerr.cf_error.re_errno == EADDRINUSE)
 			/*
@@ -1008,7 +1111,7 @@ void mnt_closeclnt(CLIENT *clnt, int msock)
  */
 int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 		const unsigned long vers, const unsigned int prot,
-		struct sockaddr_in *caddr)
+	      struct sockaddr_in *caddr, struct local_bind_info *local_ip)
 {
 	CLIENT *clnt = NULL;
 	int sock, status;
@@ -1016,7 +1119,7 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 	struct sockaddr dissolve;
 
 	rpc_createerr.cf_stat = status = 0;
-	sock = get_socket(saddr, prot, CONNECT_TIMEOUT, FALSE, TRUE);
+	sock = get_socket(saddr, prot, CONNECT_TIMEOUT, FALSE, TRUE, local_ip);
 	if (sock == RPC_ANYSOCK) {
 		if (rpc_createerr.cf_error.re_errno == ETIMEDOUT) {
 			/*
@@ -1659,7 +1762,8 @@ out:
  * parsed successfully; otherwise EX_FAIL.
  */
 int nfs_umount_do_umnt(struct mount_options *options,
-		       char **hostname, char **dirname)
+		       char **hostname, char **dirname,
+		       struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *sap = &address.sa;
@@ -1686,7 +1790,7 @@ int nfs_umount_do_umnt(struct mount_options *options,
 		/* nfs_lookup reports any errors */
 		return EX_FAIL;
 
-	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) == 0)
+	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname, local_ip) == 0)
 		/* nfs_advise_umount reports any errors */
 		return EX_FAIL;
 
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 81c6f22..4af8fd1 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -25,6 +25,7 @@
 #define _NFS_UTILS_MOUNT_NETWORK_H
 
 #include <rpc/pmap_prot.h>
+#include "sockaddr.h"
 
 #define MNT_SENDBUFSIZE (2048U)
 #define MNT_RECVBUFSIZE (1024U)
@@ -35,14 +36,17 @@ typedef struct {
 	struct pmap pmap;
 } clnt_addr_t;
 
+void parse_local_bind(struct local_bind_info *laddr, const char* str);
+
 /* RPC call timeout values */
 static const struct timeval TIMEOUT = { 20, 0 };
 static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
-int probe_bothports(clnt_addr_t *, clnt_addr_t *);
+int probe_bothports(clnt_addr_t *, clnt_addr_t *, struct local_bind_info *);
 int nfs_probe_bothports(const struct sockaddr *, const socklen_t,
 			struct pmap *, const struct sockaddr *,
-			const socklen_t, struct pmap *);
+			const socklen_t, struct pmap *,
+			struct local_bind_info *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_lookup(const char *hostname, const sa_family_t family,
 		struct sockaddr *sap, socklen_t *salen);
@@ -53,7 +57,7 @@ int nfs_callback_address(const struct sockaddr *, const socklen_t,
 		struct sockaddr *, socklen_t *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,
 		const unsigned long, const unsigned int,
-		struct sockaddr_in *);
+	      struct sockaddr_in *, struct local_bind_info *);
 
 struct mount_options;
 
@@ -69,13 +73,15 @@ int start_statd(void);
 
 unsigned long nfsvers_to_mnt(const unsigned long);
 
-int nfs_call_umount(clnt_addr_t *, dirpath *);
+int nfs_call_umount(clnt_addr_t *, dirpath *, struct local_bind_info *);
 int nfs_advise_umount(const struct sockaddr *, const socklen_t,
-		      const struct pmap *, const dirpath *);
-CLIENT *mnt_openclnt(clnt_addr_t *, int *);
+		      const struct pmap *, const dirpath *,
+		      struct local_bind_info *);
+CLIENT *mnt_openclnt(clnt_addr_t *, int *, struct local_bind_info *);
 void mnt_closeclnt(CLIENT *, int);
 
 int nfs_umount_do_umnt(struct mount_options *options,
-		       char **hostname, char **dirname);
+		       char **hostname, char **dirname,
+		       struct local_bind_info *local_ip);
 
 #endif	/* _NFS_UTILS_MOUNT_NETWORK_H */
diff --git a/utils/mount/nfs4_mount.h b/utils/mount/nfs4_mount.h
index b03792e..8bf379c 100644
--- a/utils/mount/nfs4_mount.h
+++ b/utils/mount/nfs4_mount.h
@@ -68,6 +68,9 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS4_MOUNT_FLAGMASK	0xFFFF
 
-int nfs4mount(const char *, const char *, int, char **, int, int);
+struct local_bind_info;
+
+int nfs4mount(const char *, const char *, int, char **, int, int,
+	      struct local_bind_info *);
 
 #endif
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 028e7cd..432947d 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -172,7 +172,8 @@ static int get_my_ipv4addr(char *ip_addr, int len)
 }
 
 int nfs4mount(const char *spec, const char *node, int flags,
-	      char **extra_opts, int fake, int running_bg)
+	      char **extra_opts, int fake, int running_bg,
+	      struct local_bind_info *local_ip)
 {
 	static struct nfs4_mount_data data;
 	static char hostdir[1024];
@@ -425,7 +426,8 @@ int nfs4mount(const char *spec, const char *node, int flags,
 		}
 		client_addr.sin_family = 0;
 		client_addr.sin_addr.s_addr = 0;
-		clnt_ping(&server_addr, NFS_PROGRAM, 4, data.proto, &client_addr);
+		clnt_ping(&server_addr, NFS_PROGRAM, 4, data.proto,
+			  &client_addr, local_ip);
 		if (rpc_createerr.cf_stat == RPC_SUCCESS) {
 			if (!ip_addr_in_opts &&
 			    client_addr.sin_family != 0 &&
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 2becfb1..07b9cc3 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -80,7 +80,10 @@ struct nfs_mount_data {
 #define AUTH_GSS_SPKMP		390011
 #endif
 
-int	nfsmount(const char *, const char *, int , char **, int, int);
+struct local_bind_info;
+
+int	nfsmount(const char *, const char *, int , char **, int, int,
+		 struct local_bind_info *);
 int	nfsumount(int, char **);
 
 #endif	/* _NFS_UTILS_MOUNT_NFS_MOUNT_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 1298fe4..7d9a925 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -123,16 +123,17 @@ nfs2_mount(CLIENT *clnt, mnt2arg_t *mnt2arg, mnt2res_t *mnt2res)
 
 static int
 nfs_call_mount(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server,
-	       mntarg_t *mntarg, mntres_t *mntres)
+	       mntarg_t *mntarg, mntres_t *mntres,
+	       struct local_bind_info *local_ip)
 {
 	CLIENT *clnt;
 	enum clnt_stat stat;
 	int msock;
 
-	if (!probe_bothports(mnt_server, nfs_server))
+	if (!probe_bothports(mnt_server, nfs_server, local_ip))
 		goto out_bad;
 
-	clnt = mnt_openclnt(mnt_server, &msock);
+	clnt = mnt_openclnt(mnt_server, &msock, local_ip);
 	if (!clnt)
 		goto out_bad;
 	/* make pointers in xdr_mountres3 NULL so
@@ -501,7 +502,8 @@ out_bad:
 
 int
 nfsmount(const char *spec, const char *node, int flags,
-	 char **extra_opts, int fake, int running_bg)
+	 char **extra_opts, int fake, int running_bg,
+	 struct local_bind_info *local_ip)
 {
 	char hostdir[1024];
 	char *hostname, *dirname, *old_opts, *mounthost = NULL;
@@ -681,7 +683,7 @@ nfsmount(const char *spec, const char *node, int flags,
 				sleep(30);
 
 			stat = nfs_call_mount(&mnt_server, &nfs_server,
-					      &dirname, &mntres);
+					      &dirname, &mntres, local_ip);
 			if (stat)
 				break;
 			memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
@@ -779,7 +781,7 @@ nfsmount(const char *spec, const char *node, int flags,
 					"not supported"),
 					progname, hostname, dirname);
 			/* server has registered us in rmtab, send umount */
-			nfs_call_umount(&mnt_server, &dirname);
+			nfs_call_umount(&mnt_server, &dirname, local_ip);
 			goto fail;
 		}
 noauth_flavors:
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 8cd2852..053a91f 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -57,7 +57,7 @@ extern int verbose;
 int force;
 int lazy;
 int remount;
-
+struct local_bind_info glb_local_ip;
 
 static int try_remount(const char *spec, const char *node)
 {
@@ -231,6 +231,7 @@ static struct option umount_longopts[] =
   { "no-mtab", 0, 0, 'n' },
   { "verbose", 0, 0, 'v' },
   { "read-only", 0, 0, 'r' },
+  { "local-ip", 0, 0, 'I' },
   { NULL, 0, 0, 0 }
 };
 
@@ -239,6 +240,7 @@ int nfsumount(int argc, char *argv[])
 	int c, ret;
 	char *spec;
 	struct mntentchn *mc;
+	char *env;
 
 	if (argc < 2) {
 		umount_usage();
@@ -251,13 +253,16 @@ int nfsumount(int argc, char *argv[])
 	argc -= 1;
 
 	argv[0] = argv[-1]; /* So that getopt error messages are correct */
-	while ((c = getopt_long (argc, argv, "fvnrlh",
+	while ((c = getopt_long (argc, argv, "fvnrlhI:",
 				umount_longopts, NULL)) != -1) {
 
 		switch (c) {
 		case 'f':
 			++force;
 			break;
+		case 'I':              /* bind to local IP */
+			parse_local_bind(&glb_local_ip, optarg);
+			break;
 		case 'v':
 			++verbose;
 			break;
@@ -280,7 +285,11 @@ int nfsumount(int argc, char *argv[])
 		umount_usage();
 		return EX_USAGE;
 	}
-	
+
+	env = getenv("MNT_BIND_ADDR");
+	if (env)
+		parse_local_bind(&glb_local_ip, env);
+
 	if (spec == NULL || (*spec != '/' && strchr(spec,':') == NULL)) {
 		nfs_error(_("%s: %s: not found\n"), progname, spec);
 		return EX_USAGE;
@@ -344,7 +353,8 @@ int nfsumount(int argc, char *argv[])
 				 * we don't want to signal an error, as that
 				 * could cause /sbin/mount to retry!
 				 */
-				nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
+				nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts,
+					     &glb_local_ip);
 				break;
 			case 1:
 				break;
@@ -355,7 +365,7 @@ int nfsumount(int argc, char *argv[])
 		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
 	} else if (*spec != '/') {
 		if (!lazy)
-			ret = nfs_umount23(spec, "tcp,v3");
+			ret = nfs_umount23(spec, "tcp,v3", &glb_local_ip);
 	} else
 		ret = del_mtab(NULL, spec);
 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index f1aa503..31c41d6 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -92,6 +92,7 @@ struct nfsmount_info {
 	int			flags,		/* MS_ flags */
 				fake,		/* actually do the mount? */
 				child;		/* forked bg child? */
+	struct local_bind_info  *local_ip;      /* Local IP binding info */
 };
 
 #ifdef MOUNT_CONFIG
@@ -484,7 +485,8 @@ static int nfs_construct_new_options(struct mount_options *options,
  * FALSE is returned if some failure occurred.
  */
 static int
-nfs_rewrite_pmap_mount_options(struct mount_options *options)
+nfs_rewrite_pmap_mount_options(struct mount_options *options,
+			       struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr nfs_address;
 	struct sockaddr *nfs_saddr = &nfs_address.sa;
@@ -534,7 +536,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 	 * negotiate.  Bail now if we can't contact it.
 	 */
 	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
-				 nfs_saddr, nfs_salen, &nfs_pmap)) {
+				 nfs_saddr, nfs_salen, &nfs_pmap,
+				 local_ip)) {
 		errno = ESPIPE;
 		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
 			errno = EOPNOTSUPP;
@@ -589,7 +592,7 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
 }
 
 static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
-		struct sockaddr *sap, socklen_t salen)
+			     struct sockaddr *sap, socklen_t salen)
 {
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
@@ -631,7 +634,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
 		printf(_("%s: trying text-based options '%s'\n"),
 			progname, *mi->extra_opts);
 
-	if (!nfs_rewrite_pmap_mount_options(options))
+	if (!nfs_rewrite_pmap_mount_options(options, mi->local_ip))
 		goto out_fail;
 
 	result = nfs_sys_mount(mi, options);
@@ -1028,7 +1031,8 @@ static int nfsmount_start(struct nfsmount_info *mi)
  * Returns a valid mount command exit code.
  */
 int nfsmount_string(const char *spec, const char *node, const char *type,
-		    int flags, char **extra_opts, int fake, int child)
+		    int flags, char **extra_opts, int fake, int child,
+		    struct local_bind_info *local_ip)
 {
 	struct nfsmount_info mi = {
 		.spec		= spec,
@@ -1039,6 +1043,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		.flags		= flags,
 		.fake		= fake,
 		.child		= child,
+		.local_ip	= local_ip,
 	};
 	int retval = EX_FAIL;
 
diff --git a/utils/mount/stropts.h b/utils/mount/stropts.h
index b4fd888..68cebaa 100644
--- a/utils/mount/stropts.h
+++ b/utils/mount/stropts.h
@@ -25,6 +25,6 @@
 #define _NFS_UTILS_MOUNT_STROPTS_H
 
 int nfsmount_string(const char *, const char *, const char *, int,
-			char **, int, int);
+		    char **, int, int, struct local_bind_info *);
 
 #endif	/* _NFS_UTILS_MOUNT_STROPTS_H */
diff --git a/utils/mount/utils.c b/utils/mount/utils.c
index 298db39..dfad580 100644
--- a/utils/mount/utils.c
+++ b/utils/mount/utils.c
@@ -104,6 +104,7 @@ void mount_usage(void)
 	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
 	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
 	printf(_("\t-h\t\tPrint this help\n"));
+	printf(_("\t-I\t\tBind to local IP address\n"));
 	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
 }
 
@@ -115,6 +116,7 @@ void umount_usage(void)
 	printf(_("\t-n\tDo not update /etc/mtab\n"));
 	printf(_("\t-r\tremount\n"));
 	printf(_("\t-l\tlazy unmount\n"));
+	printf(_("\t-I\t\tBind to local IP address\n"));
 	printf(_("\t-h\tprint this help\n\n"));
 }
 
@@ -153,7 +155,8 @@ int chk_mountpoint(const char *mount_point)
  * pmap tuple.  If the GETPORT call later fails to disambiguate them,
  * then we fail.
  */
-int nfs_umount23(const char *devname, char *string)
+int nfs_umount23(const char *devname, char *string,
+		 struct local_bind_info *local_ip)
 {
 	char *hostname = NULL, *dirname = NULL;
 	struct mount_options *options;
@@ -164,7 +167,8 @@ int nfs_umount23(const char *devname, char *string)
 
 	options = po_split(string);
 	if (options) {
-		result = nfs_umount_do_umnt(options, &hostname, &dirname);
+		result = nfs_umount_do_umnt(options, &hostname, &dirname,
+					    local_ip);
 		po_destroy(options);
 	} else
 		nfs_error(_("%s: option parsing error"), progname);
diff --git a/utils/mount/utils.h b/utils/mount/utils.h
index 3fcd504..8471458 100644
--- a/utils/mount/utils.h
+++ b/utils/mount/utils.h
@@ -31,6 +31,7 @@ void mount_usage(void);
 void umount_usage(void);
 int chk_mountpoint(const char *mount_point);
 
-int nfs_umount23(const char *devname, char *string);
+int nfs_umount23(const char *devname, char *string,
+		 struct local_bind_info *local_ip);
 
 #endif	/* !_NFS_UTILS_MOUNT_UTILS_H */
-- 
1.7.3.4

