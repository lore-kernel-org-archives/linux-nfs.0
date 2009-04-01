From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/6] nfs-utils: split out gssd rpc client creation into separate function
Date: Wed,  1 Apr 2009 10:24:03 -0400
Message-ID: <1238595845-2186-5-git-send-email-jlayton@redhat.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, kwc@citi.umich.edu
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:39516 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765827AbZDAOYM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 10:24:12 -0400
In-Reply-To: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Abstract out the actual RPC client creation functions. This will allow
us to create a new TI-RPC enabled client creation function in a later
patch.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   80 +++++++++++++++++++++++++++++------------------
 1 files changed, 49 insertions(+), 31 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 4d54c40..b88b0c6 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -537,6 +537,52 @@ out_err:
 	return -1;
 }
 
+static CLIENT *
+create_rpc_client(struct clnt_info *clp, int protocol, uid_t uid)
+{
+	CLIENT			*rpc_clnt = NULL;
+	char			rpc_errmsg[1024];
+	int			sockp = RPC_ANYSOCK;
+	int			sendsz = 32768, recvsz = 32768;
+	const struct timeval 	timeout = {5, 0};
+
+	switch(protocol) {
+	case IPPROTO_TCP:
+		if ((rpc_clnt = clnttcp_create(
+					(struct sockaddr_in *) &clp->addr,
+					clp->prog, clp->vers, &sockp,
+					sendsz, recvsz)) == NULL) {
+			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
+				 "WARNING: can't create tcp rpc_clnt "
+				 "for server %s for user with uid %d",
+				 clp->servername, uid);
+			printerr(0, "%s\n",
+				 clnt_spcreateerror(rpc_errmsg));
+		}
+		break;
+	case IPPROTO_UDP:
+		if ((rpc_clnt = clntudp_bufcreate(
+					(struct sockaddr_in *) &clp->addr,
+					clp->prog, clp->vers, timeout,
+					&sockp, sendsz, recvsz)) == NULL) {
+			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
+				 "WARNING: can't create udp rpc_clnt "
+				 "for server %s for user with uid %d",
+				 clp->servername, uid);
+			printerr(0, "%s\n",
+				 clnt_spcreateerror(rpc_errmsg));
+		}
+		break;
+	default:
+		/* Shouldn't happen! */
+		printerr(0, "ERROR: requested protocol '%s', but "
+			 "got addrinfo with protocol %d\n",
+			 clp->protocol, protocol);
+	}
+
+	return rpc_clnt;
+}
+
 /*
  * Determine the port from the servicename and set the right field in the
  * sockaddr. This is mostly a no-op with newer kernels that send the port
@@ -623,9 +669,6 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	uid_t			save_uid = -1;
 	int			retval = -1;
 	OM_uint32		min_stat;
-	char			rpc_errmsg[1024];
-	int			sockp = RPC_ANYSOCK;
-	int			sendsz = 32768, recvsz = 32768;
 	int			socktype, protocol;
 
 	/* Create the context as the user (not as root) */
@@ -697,34 +740,9 @@ int create_auth_rpc_client(struct clnt_info *clp,
 			   socktype, protocol))
 		goto out_fail;
 
-	if (protocol == IPPROTO_TCP) {
-		if ((rpc_clnt = clnttcp_create(
-					(struct sockaddr_in *) &clp->addr,
-					clp->prog, clp->vers, &sockp,
-					sendsz, recvsz)) == NULL) {
-			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
-				 "WARNING: can't create tcp rpc_clnt "
-				 "for server %s for user with uid %d",
-				 clp->servername, uid);
-			printerr(0, "%s\n",
-				 clnt_spcreateerror(rpc_errmsg));
-			goto out_fail;
-		}
-	} else if (protocol == IPPROTO_UDP) {
-		const struct timeval timeout = {5, 0};
-		if ((rpc_clnt = clntudp_bufcreate(
-					(struct sockaddr_in *) &clp->addr,
-					clp->prog, clp->vers, timeout,
-					&sockp, sendsz, recvsz)) == NULL) {
-			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
-				 "WARNING: can't create udp rpc_clnt "
-				 "for server %s for user with uid %d",
-				 clp->servername, uid);
-			printerr(0, "%s\n",
-				 clnt_spcreateerror(rpc_errmsg));
-			goto out_fail;
-		}
-	}
+	rpc_clnt = create_rpc_client(clp, protocol, uid);
+	if (!rpc_clnt)
+		goto out_fail;
 
 	printerr(2, "creating context with server %s\n", clp->servicename);
 	auth = authgss_create_default(rpc_clnt, clp->servicename, &sec);
-- 
1.6.0.6

