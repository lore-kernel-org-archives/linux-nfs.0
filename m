From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/6] nfs-utils: skip getaddrinfo in create_auth_rpc_client unless we need port
Date: Wed,  1 Apr 2009 10:24:02 -0400
Message-ID: <1238595845-2186-4-git-send-email-jlayton@redhat.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, kwc@citi.umich.edu
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:47661 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757883AbZDAOdh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 10:33:37 -0400
In-Reply-To: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already have the server's address from the upcall, so we don't really
need to look it up again. Move the getaddrinfo call in
create_auth_rpc_client to a new function. Skip it if we already have the
port in the sockaddr that we saved from the info in the upcall. If
we need to get the port, don't bother looking up the hostname, just do
the getaddrinfo with AI_NUMERICHOST set.

This should reduce the amount of lookups that are needed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |  134 +++++++++++++++++++++++++++++-------------------
 1 files changed, 81 insertions(+), 53 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index f5f3a0f..4d54c40 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -538,6 +538,76 @@ out_err:
 }
 
 /*
+ * Determine the port from the servicename and set the right field in the
+ * sockaddr. This is mostly a no-op with newer kernels that send the port
+ * in the upcall. Returns true on success and false on failure.
+ */
+static int
+populate_port(struct sockaddr *sa, char *servicename, int socktype,
+	      int protocol)
+{
+	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
+	char			node[INET_ADDRSTRLEN];
+	char			service[64];
+	char			*at_sign;
+	int			errcode;
+	struct addrinfo		*a = NULL;
+	struct addrinfo		ai_hints = { .ai_family	  = sa->sa_family,
+					     .ai_socktype = socktype,
+					     .ai_protocol = protocol,
+					     .ai_flags    = AI_NUMERICHOST };
+
+	switch (sa->sa_family) {
+	case AF_INET:
+		if (s4->sin_port != 0) {
+			printerr(2, "DEBUG: port already set to %d\n",
+				 ntohs(s4->sin_port));
+			return 1;
+		}
+		if (!inet_ntop(AF_INET, &s4->sin_addr, node,
+				sizeof(struct sockaddr_in)))
+			return 0;
+		break;
+	default:
+		printerr(0, "ERROR: unsupported address family %d\n",
+			    sa->sa_family);
+		return 0;
+	}
+
+	/* extract the service name from clp->servicename */
+	if ((at_sign = strchr(servicename, '@')) == NULL) {
+		printerr(0, "WARNING: servicename (%s) not formatted as "
+			"expected with service@host\n", servicename);
+		return 0;
+	}
+	if ((at_sign - servicename) >= sizeof(service)) {
+		printerr(0, "WARNING: service portion of servicename (%s) "
+			"is too long!\n", servicename);
+		return 0;
+	}
+	strncpy(service, servicename, at_sign - servicename);
+	service[at_sign - servicename] = '\0';
+
+	errcode = getaddrinfo(node, service, &ai_hints, &a);
+	if (errcode) {
+		printerr(0, "WARNING: Error from getaddrinfo for service "
+			 "'%s': %s\n", service,
+			 errcode == EAI_SYSTEM ? strerror(errno) :
+						 gai_strerror(errcode));
+		return 0;
+	}
+
+	if (a->ai_family == AF_INET)
+		s4->sin_port = ((struct sockaddr_in *) a->ai_addr)->sin_port;
+	else
+		printerr(0, "ERROR: unrecognized address family %d returned "
+			    "by getaddrinfo.\n", a->ai_family);
+
+	freeaddrinfo(a);
+	return 1;
+}
+
+/*
  * Create an RPC connection and establish an authenticated
  * gss context with a server.
  */
@@ -552,14 +622,11 @@ int create_auth_rpc_client(struct clnt_info *clp,
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
+	int			socktype, protocol;
 
 	/* Create the context as the user (not as root) */
 	save_uid = geteuid();
@@ -613,15 +680,12 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	printerr(2, "creating %s client for server %s\n", clp->protocol,
 			clp->servername);
 
-	memset(&ai_hints, '\0', sizeof(ai_hints));
-	ai_hints.ai_family = PF_INET;
-	ai_hints.ai_flags |= AI_CANONNAME;
 	if ((strcmp(clp->protocol, "tcp")) == 0) {
-		ai_hints.ai_socktype = SOCK_STREAM;
-		ai_hints.ai_protocol = IPPROTO_TCP;
+		socktype = SOCK_STREAM;
+		protocol = IPPROTO_TCP;
 	} else if ((strcmp(clp->protocol, "udp")) == 0) {
-		ai_hints.ai_socktype = SOCK_DGRAM;
-		ai_hints.ai_protocol = IPPROTO_UDP;
+		socktype = SOCK_DGRAM;
+		protocol = IPPROTO_UDP;
 	} else {
 		printerr(0, "WARNING: unrecognized protocol, '%s', requested "
 			 "for connection to server %s for user with uid %d\n",
@@ -629,39 +693,13 @@ int create_auth_rpc_client(struct clnt_info *clp,
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
-		goto out_fail;
-	}
-	strncpy(service, clp->servicename, at_sign - clp->servicename);
-	service[at_sign - clp->servicename] = '\0';
-
-	errcode = getaddrinfo(clp->servername, service, &ai_hints, &a);
-	if (errcode) {
-		printerr(0, "WARNING: Error from getaddrinfo for server "
-			 "'%s': %s\n", clp->servername, gai_strerror(errcode));
+	if (!populate_port((struct sockaddr *) &clp->addr, clp->servicename,
+			   socktype, protocol))
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
+					(struct sockaddr_in *) &clp->addr,
 					clp->prog, clp->vers, &sockp,
 					sendsz, recvsz)) == NULL) {
 			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
@@ -672,10 +710,10 @@ int create_auth_rpc_client(struct clnt_info *clp,
 				 clnt_spcreateerror(rpc_errmsg));
 			goto out_fail;
 		}
-	} else if (a->ai_protocol == IPPROTO_UDP) {
+	} else if (protocol == IPPROTO_UDP) {
 		const struct timeval timeout = {5, 0};
 		if ((rpc_clnt = clntudp_bufcreate(
-					(struct sockaddr_in *) a->ai_addr,
+					(struct sockaddr_in *) &clp->addr,
 					clp->prog, clp->vers, timeout,
 					&sockp, sendsz, recvsz)) == NULL) {
 			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
@@ -686,16 +724,7 @@ int create_auth_rpc_client(struct clnt_info *clp,
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
@@ -717,7 +746,6 @@ int create_auth_rpc_client(struct clnt_info *clp,
   out:
 	if (sec.cred != GSS_C_NO_CREDENTIAL)
 		gss_release_cred(&min_stat, &sec.cred);
-  	if (a != NULL) freeaddrinfo(a);
 	/* Restore euid to original value */
 	if ((save_uid != -1) && (setfsuid(save_uid) != uid)) {
 		printerr(0, "WARNING: Failed to restore fsuid"
-- 
1.6.0.6

