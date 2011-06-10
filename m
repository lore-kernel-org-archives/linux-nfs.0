From: greearb@candelatech.com
Subject: [PATCH v2 1/6] nfs-utils:  Add structure for passing local binding info.
Date: Fri, 10 Jun 2011 12:41:33 -0700
Message-ID: <1307734898-12860-2-git-send-email-greearb@candelatech.com>
References: <1307734898-12860-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43004 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757300Ab1FJTmU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 15:42:20 -0400
In-Reply-To: <1307734898-12860-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Create a struct local_bind_info that will hold an IP
address to be used for binding to a local IP address.
Pass this down to the code that needs it.

There are no functional changes in this patch, just passing
around un-used variables which are always NULL.  Future
patches will use this.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 d50fe94... d8ef257... M	support/include/nfsrpc.h
:100644 100644 9af2543... b1089ce... M	support/include/sockaddr.h
:100644 100644 d74400b... e8256ff... M	support/nfs/getport.c
:100644 100644 c14efe8... 5652f6c... M	support/nfs/rpc_socket.c
:100644 100644 b1b5793... ccd44a2... M	utils/gssd/gssd.h
:100644 100644 41328c9... e584d20... M	utils/gssd/gssd_proc.c
:100644 100644 d1f91dc... 5ba6967... M	utils/mount/network.c
:100644 100644 81c6f22... a832e76... M	utils/mount/network.h
:100644 100644 1298fe4... 960cbaa... M	utils/mount/nfsmount.c
:100644 100644 f1aa503... 71417df... M	utils/mount/stropts.c
:100644 100644 298db39... eb50074... M	utils/mount/utils.c
 support/include/nfsrpc.h   |   23 ++++++++++----
 support/include/sockaddr.h |    6 ++++
 support/nfs/getport.c      |   37 ++++++++++++++++--------
 support/nfs/rpc_socket.c   |   37 ++++++++++++++----------
 utils/gssd/gssd.h          |    2 +
 utils/gssd/gssd_proc.c     |   33 ++++++++++++---------
 utils/mount/network.c      |   66 +++++++++++++++++++++++++++----------------
 utils/mount/network.h      |   14 ++++++---
 utils/mount/nfsmount.c     |    2 +-
 utils/mount/stropts.c      |    2 +-
 utils/mount/utils.c        |    2 +-
 11 files changed, 142 insertions(+), 82 deletions(-)

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
index 9af2543..b1089ce 100644
--- a/support/include/sockaddr.h
+++ b/support/include/sockaddr.h
@@ -46,6 +46,12 @@ union nfs_sockaddr {
 	struct sockaddr_in6	s6;
 };
 
+struct local_bind_info {
+	union nfs_sockaddr addr;
+	socklen_t addrlen;
+	bool is_set;
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
index c14efe8..5652f6c 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -112,7 +112,8 @@ static CLIENT *nfs_get_localclient(const struct sockaddr *sap,
  * Returns zero on success, or returns -1 on error.  errno is
  * set to reflect the nature of the error.
  */
-static int nfs_bind(const int sock, const sa_family_t family)
+static int nfs_bind(const int sock, const sa_family_t family,
+		    struct local_bind_info *local_ip)
 {
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
@@ -144,7 +145,8 @@ static int nfs_bind(const int sock, const sa_family_t family)
  * Returns zero on success, or returns -1 on error.  errno is
  * set to reflect the nature of the error.
  */
-static int nfs_bindresvport(const int sock, const sa_family_t family)
+static int nfs_bindresvport(const int sock, const sa_family_t family,
+			    struct local_bind_info *local_ip)
 {
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
@@ -174,7 +176,8 @@ static int nfs_bindresvport(const int sock, const sa_family_t family)
  * Returns zero on success, or returns -1 on error.  errno is
  * set to reflect the nature of the error.
  */
-static int nfs_bindresvport(const int sock, const sa_family_t family)
+static int nfs_bindresvport(const int sock, const sa_family_t family,
+			    struct local_bind_info *local_ip)
 {
 	if (family != AF_INET) {
 		errno = EAFNOSUPPORT;
@@ -273,7 +276,8 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
 				 const rpcprog_t program,
 				 const rpcvers_t version,
 				 struct timeval *timeout,
-				 const int resvport)
+				 const int resvport,
+				 struct local_bind_info *local_ip)
 {
 	CLIENT *client;
 	int ret, sock;
@@ -301,9 +305,9 @@ static CLIENT *nfs_get_udpclient(const struct sockaddr *sap,
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
@@ -355,7 +359,8 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
 				 const rpcprog_t program,
 				 const rpcvers_t version,
 				 struct timeval *timeout,
-				 const int resvport)
+				 const int resvport,
+				 struct local_bind_info *local_ip)
 {
 	CLIENT *client;
 	int ret, sock;
@@ -383,9 +388,9 @@ static CLIENT *nfs_get_tcpclient(const struct sockaddr *sap,
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
@@ -442,7 +447,8 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 			  const unsigned short transport,
 			  const rpcprog_t program,
 			  const rpcvers_t version,
-			  struct timeval *timeout)
+			  struct timeval *timeout,
+			  struct local_bind_info *local_ip)
 {
 	nfs_clear_rpc_createerr();
 
@@ -465,11 +471,11 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
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
@@ -499,7 +505,8 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
 			       const unsigned short transport,
 			       const rpcprog_t program,
 			       const rpcvers_t version,
-			       struct timeval *timeout)
+			       struct timeval *timeout,
+			       struct local_bind_info *local_ip)
 {
 	nfs_clear_rpc_createerr();
 
@@ -522,11 +529,11 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
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
diff --git a/utils/mount/network.c b/utils/mount/network.c
index d1f91dc..5ba6967 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -537,7 +537,8 @@ static void nfs_pp_debug2(const char *str)
  */
 static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 			  struct pmap *pmap, const unsigned long *versions,
-			  const unsigned int *protos)
+			  const unsigned int *protos,
+			  struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *saddr = &address.sa;
@@ -555,14 +556,16 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
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
@@ -615,7 +618,8 @@ out_ok:
  * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
  */
 static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
-				struct pmap *pmap)
+			     struct pmap *pmap,
+			     struct local_bind_info *local_ip)
 {
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
@@ -626,10 +630,12 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
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
@@ -646,17 +652,20 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
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
@@ -673,11 +682,12 @@ static int nfs_probe_version_fixed(const struct sockaddr *mnt_saddr,
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
@@ -700,7 +710,8 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 			struct pmap *mnt_pmap,
 			const struct sockaddr *nfs_saddr,
 			const socklen_t nfs_salen,
-			struct pmap *nfs_pmap)
+			struct pmap *nfs_pmap,
+			struct local_bind_info *local_ip)
 {
 	struct pmap save_nfs, save_mnt;
 	const unsigned long *probe_vers;
@@ -712,7 +723,8 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 
 	if (nfs_pmap->pm_vers)
 		return nfs_probe_version_fixed(mnt_saddr, mnt_salen, mnt_pmap,
-					       nfs_saddr, nfs_salen, nfs_pmap);
+					       nfs_saddr, nfs_salen, nfs_pmap,
+					       local_ip);
 
 	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
 	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
@@ -721,9 +733,9 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
 
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
@@ -753,7 +765,8 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
  * Otherwise zero is returned; rpccreateerr.cf_stat is set to reflect
  * the nature of the error.
  */
-int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
+int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server,
+		    struct local_bind_info *local_ip)
 {
 	struct sockaddr *mnt_addr = SAFE_SOCKADDR(&mnt_server->saddr);
 	struct sockaddr *nfs_addr = SAFE_SOCKADDR(&nfs_server->saddr);
@@ -761,7 +774,7 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 	return nfs_probe_bothports(mnt_addr, sizeof(mnt_server->saddr),
 					&mnt_server->pmap,
 					nfs_addr, sizeof(nfs_server->saddr),
-					&nfs_server->pmap);
+				   &nfs_server->pmap, local_ip);
 }
 
 static int nfs_probe_statd(void)
@@ -773,7 +786,8 @@ static int nfs_probe_statd(void)
 	rpcprog_t program = nfs_getrpcbyname(NSMPROG, nfs_ns_pgmtbl);
 
 	return nfs_getport_ping(SAFE_SOCKADDR(&addr), sizeof(addr),
-				program, (rpcvers_t)1, IPPROTO_UDP);
+				program, (rpcvers_t)1, IPPROTO_UDP,
+				NULL);
 }
 
 /**
@@ -829,7 +843,8 @@ int start_statd(void)
  * We use a fast timeout since this call is advisory only.
  */
 int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
-		      const struct pmap *pmap, const dirpath *argp)
+		      const struct pmap *pmap, const dirpath *argp,
+		      struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *saddr = &address.sa;
@@ -841,7 +856,7 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 	enum clnt_stat res = 0;
 
 	memcpy(saddr, sap, salen);
-	if (nfs_probe_mntport(saddr, salen, &mnt_pmap) == 0) {
+	if (nfs_probe_mntport(saddr, salen, &mnt_pmap, local_ip) == 0) {
 		if (verbose)
 			nfs_error(_("%s: Failed to discover mountd port%s"),
 				progname, clnt_spcreateerror(""));
@@ -851,7 +866,7 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
 
 	client = nfs_get_priv_rpcclient(saddr, salen, mnt_pmap.pm_prot,
 					mnt_pmap.pm_prog, mnt_pmap.pm_vers,
-					&timeout);
+					&timeout, local_ip);
 	if (client == NULL) {
 		if (verbose)
 			nfs_error(_("%s: Failed to create RPC client%s"),
@@ -908,7 +923,7 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 	enum clnt_stat res = 0;
 	int msock;
 
-	if (!nfs_probe_mntport(sap, salen, pmap))
+	if (!nfs_probe_mntport(sap, salen, pmap, NULL))
 		return 0;
 	clnt = mnt_openclnt(mnt_server, &msock);
 	if (!clnt)
@@ -1659,7 +1674,8 @@ out:
  * parsed successfully; otherwise EX_FAIL.
  */
 int nfs_umount_do_umnt(struct mount_options *options,
-		       char **hostname, char **dirname)
+		       char **hostname, char **dirname,
+		       struct local_bind_info *local_ip)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *sap = &address.sa;
@@ -1686,7 +1702,7 @@ int nfs_umount_do_umnt(struct mount_options *options,
 		/* nfs_lookup reports any errors */
 		return EX_FAIL;
 
-	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) == 0)
+	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname, local_ip) == 0)
 		/* nfs_advise_umount reports any errors */
 		return EX_FAIL;
 
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 81c6f22..a832e76 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -25,6 +25,7 @@
 #define _NFS_UTILS_MOUNT_NETWORK_H
 
 #include <rpc/pmap_prot.h>
+#include "sockaddr.h"
 
 #define MNT_SENDBUFSIZE (2048U)
 #define MNT_RECVBUFSIZE (1024U)
@@ -39,10 +40,11 @@ typedef struct {
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
@@ -53,7 +55,7 @@ int nfs_callback_address(const struct sockaddr *, const socklen_t,
 		struct sockaddr *, socklen_t *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,
 		const unsigned long, const unsigned int,
-		struct sockaddr_in *);
+	      struct sockaddr_in *);
 
 struct mount_options;
 
@@ -71,11 +73,13 @@ unsigned long nfsvers_to_mnt(const unsigned long);
 
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 int nfs_advise_umount(const struct sockaddr *, const socklen_t,
-		      const struct pmap *, const dirpath *);
+		      const struct pmap *, const dirpath *,
+		      struct local_bind_info *);
 CLIENT *mnt_openclnt(clnt_addr_t *, int *);
 void mnt_closeclnt(CLIENT *, int);
 
 int nfs_umount_do_umnt(struct mount_options *options,
-		       char **hostname, char **dirname);
+		       char **hostname, char **dirname,
+		       struct local_bind_info *local_ip);
 
 #endif	/* _NFS_UTILS_MOUNT_NETWORK_H */
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 1298fe4..960cbaa 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -129,7 +129,7 @@ nfs_call_mount(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server,
 	enum clnt_stat stat;
 	int msock;
 
-	if (!probe_bothports(mnt_server, nfs_server))
+	if (!probe_bothports(mnt_server, nfs_server, NULL))
 		goto out_bad;
 
 	clnt = mnt_openclnt(mnt_server, &msock);
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index f1aa503..71417df 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -534,7 +534,7 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
 	 * negotiate.  Bail now if we can't contact it.
 	 */
 	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
-				 nfs_saddr, nfs_salen, &nfs_pmap)) {
+				 nfs_saddr, nfs_salen, &nfs_pmap, NULL)) {
 		errno = ESPIPE;
 		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
 			errno = EOPNOTSUPP;
diff --git a/utils/mount/utils.c b/utils/mount/utils.c
index 298db39..eb50074 100644
--- a/utils/mount/utils.c
+++ b/utils/mount/utils.c
@@ -164,7 +164,7 @@ int nfs_umount23(const char *devname, char *string)
 
 	options = po_split(string);
 	if (options) {
-		result = nfs_umount_do_umnt(options, &hostname, &dirname);
+		result = nfs_umount_do_umnt(options, &hostname, &dirname, NULL);
 		po_destroy(options);
 	} else
 		nfs_error(_("%s: option parsing error"), progname);
-- 
1.7.3.4

