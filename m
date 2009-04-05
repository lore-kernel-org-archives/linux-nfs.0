From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/5] nfs-utils: switch gssd to use standard function for getting an RPC client
Date: Sun,  5 Apr 2009 09:43:02 -0400
Message-ID: <1238938983-7347-5-git-send-email-jlayton@redhat.com>
References: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, kwc@citi.umich.edu
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54325 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655AbZDENnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Apr 2009 09:43:14 -0400
In-Reply-To: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already have a common function for setting up an RPC client. Switch
gssd to use it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |   53 +++++++++++++++++++++--------------------------
 1 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index bebefe7..1f7dadd 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -72,6 +72,7 @@
 #include "gss_util.h"
 #include "krb5_util.h"
 #include "context.h"
+#include "nfsrpc.h"
 
 /*
  * pollarray:
@@ -624,10 +625,10 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	int			retval = -1;
 	OM_uint32		min_stat;
 	char			rpc_errmsg[1024];
-	int			sockp = RPC_ANYSOCK;
-	int			sendsz = 32768, recvsz = 32768;
 	int			protocol;
+	struct timeval		timeout = {5, 0};
 	struct sockaddr		*addr = (struct sockaddr *) &clp->addr;
+	socklen_t		salen;
 
 	/* Create the context as the user (not as root) */
 	save_uid = geteuid();
@@ -695,33 +696,27 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	if (!populate_port(addr, clp->servicename, protocol))
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
+	switch (addr->sa_family) {
+	case AF_INET:
+		salen = sizeof(struct sockaddr_in);
+		break;
+	default:
+		printerr(1, "ERROR: Unknown address family %d\n",
+			 addr->sa_family);
+		goto out_fail;
+	}
+
+	rpc_clnt = nfs_get_rpcclient(addr, salen, protocol, clp->prog,
+				     clp->vers, &timeout);
+	if (!rpc_clnt) {
+		snprintf(rpc_errmsg, sizeof(rpc_errmsg),
+			 "WARNING: can't create %s rpc_clnt to server %s for "
+			 "user with uid %d",
+			 protocol == IPPROTO_TCP ? "tcp" : "udp",
+			 clp->servername, uid);
+		printerr(0, "%s\n",
+			 clnt_spcreateerror(rpc_errmsg));
+		goto out_fail;
 	}
 
 	printerr(2, "creating context with server %s\n", clp->servicename);
-- 
1.6.0.6

