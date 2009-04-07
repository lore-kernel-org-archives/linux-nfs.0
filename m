From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/5] nfs-utils: query for remote port using rpcbind instead of
	getaddrinfo
Date: Tue,  7 Apr 2009 11:25:44 -0400
Message-ID: <1239117946-7535-4-git-send-email-jlayton@redhat.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

We already have the server's address from the upcall, so we don't really
need to look it up again, and querying the local services DB for the
port that the remote server is listening on is just plain wrong.

Use rpcbind to set the port for the program and version that we were
given in the upcall. The exception here is NFSv4. Since NFSv4 mounts
are supposed to use a well-defined port then skip the rpcbind query
for that and just set the port to the standard one (2049).

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |  126 +++++++++++++++++++++++++++++-------------------
 1 files changed, 76 insertions(+), 50 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 9d3712b..1571329 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -72,6 +72,7 @@
 #include "gss_util.h"
 #include "krb5_util.h"
 #include "context.h"
+#include "nfsrpc.h"
 
 /*
  * pollarray:
@@ -541,6 +542,64 @@ out_err:
 }
 
 /*
+ * If the port isn't already set, do an rpcbind query to the remote server
+ * using the program and version and get the port. Newer kernels send the
+ * port in the upcall, so this is really only for compatibility with older
+ * ones.
+ */
+static int
+populate_port(struct sockaddr *sa, const socklen_t salen,
+	      const rpcprog_t program, const rpcvers_t version,
+	      const unsigned short protocol)
+{
+	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
+	unsigned short		port;
+
+	/*
+	 * Newer kernels send the port in the upcall. If we already have
+	 * the port, there's no need to look it up.
+	 */
+	switch (sa->sa_family) {
+	case AF_INET:
+		if (s4->sin_port != 0) {
+			printerr(2, "DEBUG: port already set to %d\n",
+				 ntohs(s4->sin_port));
+			return 1;
+		}
+		break;
+	default:
+		printerr(0, "ERROR: unsupported address family %d\n",
+			    sa->sa_family);
+		return 0;
+	}
+
+	/* Use standard NFS port for NFSv4 */
+	if (program == 100003 && version == 4) {
+		port = 2049;
+		goto set_port;
+	}
+
+	port = nfs_getport(sa, salen, program, version, protocol);
+	if (!port) {
+		printerr(0, "ERROR: unable to obtain port for prog %ld "
+			    "vers %ld\n", program, version);
+		return 0;
+	}
+
+set_port:
+	printerr(2, "DEBUG: setting port to %hu for prog %lu vers %lu\n", port,
+		 program, version);
+
+	switch (sa->sa_family) {
+	case AF_INET:
+		s4->sin_port = htons(port);
+		break;
+	}
+
+	return 1;
+}
+
+/*
  * Create an RPC connection and establish an authenticated
  * gss context with a server.
  */
@@ -555,14 +614,13 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	AUTH			*auth = NULL;
 	uid_t			save_uid = -1;
 	int			retval = -1;
-	int			errcode;
 	OM_uint32		min_stat;
 	char			rpc_errmsg[1024];
 	int			sockp = RPC_ANYSOCK;
 	int			sendsz = 32768, recvsz = 32768;
-	struct addrinfo		ai_hints, *a = NULL;
-	char			service[64];
-	char			*at_sign;
+	int			protocol;
+	struct sockaddr		*addr = (struct sockaddr *) &clp->addr;
+	socklen_t		salen;
 
 	/* Create the context as the user (not as root) */
 	save_uid = geteuid();
@@ -616,15 +674,10 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	printerr(2, "creating %s client for server %s\n", clp->protocol,
 			clp->servername);
 
-	memset(&ai_hints, '\0', sizeof(ai_hints));
-	ai_hints.ai_family = PF_INET;
-	ai_hints.ai_flags |= AI_CANONNAME;
 	if ((strcmp(clp->protocol, "tcp")) == 0) {
-		ai_hints.ai_socktype = SOCK_STREAM;
-		ai_hints.ai_protocol = IPPROTO_TCP;
+		protocol = IPPROTO_TCP;
 	} else if ((strcmp(clp->protocol, "udp")) == 0) {
-		ai_hints.ai_socktype = SOCK_DGRAM;
-		ai_hints.ai_protocol = IPPROTO_UDP;
+		protocol = IPPROTO_UDP;
 	} else {
 		printerr(0, "WARNING: unrecognized protocol, '%s', requested "
 			 "for connection to server %s for user with uid %d\n",
@@ -632,39 +685,22 @@ int create_auth_rpc_client(struct clnt_info *clp,
 		goto out_fail;
 	}
 
-	/* extract the service name from clp->servicename */
-	if ((at_sign = strchr(clp->servicename, '@')) == NULL) {
-		printerr(0, "WARNING: servicename (%s) not formatted as "
-			"expected with service@host\n", clp->servicename);
-		goto out_fail;
-	}
-	if ((at_sign - clp->servicename) >= sizeof(service)) {
-		printerr(0, "WARNING: service portion of servicename (%s) "
-			"is too long!\n", clp->servicename);
+	switch (addr->sa_family) {
+	case AF_INET:
+		salen = sizeof(struct sockaddr_in);
+		break;
+	default:
+		printerr(1, "ERROR: Unknown address family %d\n",
+			 addr->sa_family);
 		goto out_fail;
 	}
-	strncpy(service, clp->servicename, at_sign - clp->servicename);
-	service[at_sign - clp->servicename] = '\0';
 
-	errcode = getaddrinfo(clp->servername, service, &ai_hints, &a);
-	if (errcode) {
-		printerr(0, "WARNING: Error from getaddrinfo for server "
-			 "'%s': %s\n", clp->servername, gai_strerror(errcode));
+	if (!populate_port(addr, salen, clp->prog, clp->vers, protocol))
 		goto out_fail;
-	}
 
-	if (a == NULL) {
-		printerr(0, "WARNING: No address information found for "
-			 "connection to server %s for user with uid %d\n",
-			 clp->servername, uid);
-		goto out_fail;
-	}
-	if (((struct sockaddr_in) clp->addr).sin_port != 0)
-		((struct sockaddr_in *) a->ai_addr)->sin_port =
-				((struct sockaddr_in) clp->addr).sin_port;
-	if (a->ai_protocol == IPPROTO_TCP) {
+	if (protocol == IPPROTO_TCP) {
 		if ((rpc_clnt = clnttcp_create(
-					(struct sockaddr_in *) a->ai_addr,
+					(struct sockaddr_in *) addr,
 					clp->prog, clp->vers, &sockp,
 					sendsz, recvsz)) == NULL) {
 			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
@@ -675,10 +711,10 @@ int create_auth_rpc_client(struct clnt_info *clp,
 				 clnt_spcreateerror(rpc_errmsg));
 			goto out_fail;
 		}
-	} else if (a->ai_protocol == IPPROTO_UDP) {
+	} else if (protocol == IPPROTO_UDP) {
 		const struct timeval timeout = {5, 0};
 		if ((rpc_clnt = clntudp_bufcreate(
-					(struct sockaddr_in *) a->ai_addr,
+					(struct sockaddr_in *) addr,
 					clp->prog, clp->vers, timeout,
 					&sockp, sendsz, recvsz)) == NULL) {
 			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
@@ -689,16 +725,7 @@ int create_auth_rpc_client(struct clnt_info *clp,
 				 clnt_spcreateerror(rpc_errmsg));
 			goto out_fail;
 		}
-	} else {
-		/* Shouldn't happen! */
-		printerr(0, "ERROR: requested protocol '%s', but "
-			 "got addrinfo with protocol %d\n",
-			 clp->protocol, a->ai_protocol);
-		goto out_fail;
 	}
-	/* We're done with this */
-	freeaddrinfo(a);
-	a = NULL;
 
 	printerr(2, "creating context with server %s\n", clp->servicename);
 	auth = authgss_create_default(rpc_clnt, clp->servicename, &sec);
@@ -720,7 +747,6 @@ int create_auth_rpc_client(struct clnt_info *clp,
   out:
 	if (sec.cred != GSS_C_NO_CREDENTIAL)
 		gss_release_cred(&min_stat, &sec.cred);
-  	if (a != NULL) freeaddrinfo(a);
 	/* Restore euid to original value */
 	if ((save_uid != -1) && (setfsuid(save_uid) != uid)) {
 		printerr(0, "WARNING: Failed to restore fsuid"
-- 
1.6.0.6
