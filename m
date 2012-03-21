Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58708 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758462Ab2CUPVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:20 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 15/23] NFS: Move the nfs4_init_client() to nfs4client.c
Date: Wed, 21 Mar 2012 11:20:45 -0400
Message-Id: <1332343253-24970-16-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c     |  135 ++-------------------------------------------------
 fs/nfs/nfs.h        |    2 +
 fs/nfs/nfs4client.c |  126 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 132 insertions(+), 131 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 38efcf4..32a9a54 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -30,20 +30,17 @@
 #include <linux/lockd/bind.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
-#include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
 #include <linux/slab.h>
 #include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
-#include <linux/sunrpc/bc_xprt.h>
 #include <linux/nsproxy.h>
 #include <linux/pid_namespace.h>
 
 #include <asm/system.h>
 
-#include "callback.h"
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
@@ -628,10 +625,10 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 /*
  * Create an RPC client handle
  */
-static int nfs_create_rpc_client(struct nfs_client *clp,
-				 const struct rpc_timeout *timeparms,
-				 rpc_authflavor_t flavor,
-				 int discrtry, int noresvport)
+int nfs_create_rpc_client(struct nfs_client *clp,
+			  const struct rpc_timeout *timeparms,
+			  rpc_authflavor_t flavor,
+			  int discrtry, int noresvport)
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
@@ -1226,130 +1223,6 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-/*
- * Initialize the NFS4 callback service
- */
-static int nfs4_init_callback(struct nfs_client *clp)
-{
-	int error;
-
-	if (clp->rpc_ops->version == 4) {
-		struct rpc_xprt *xprt;
-
-		xprt = rcu_dereference_raw(clp->cl_rpcclient->cl_xprt);
-
-		if (nfs4_has_session(clp)) {
-			error = xprt_setup_backchannel(xprt,
-						NFS41_BC_MIN_CALLBACKS);
-			if (error < 0)
-				return error;
-		}
-
-		error = nfs_callback_up(clp->cl_mvops->minor_version, xprt);
-		if (error < 0) {
-			dprintk("%s: failed to start callback. Error = %d\n",
-				__func__, error);
-			return error;
-		}
-		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
-	}
-	return 0;
-}
-
-/*
- * Initialize the minor version specific parts of an NFS4 client record
- */
-static int nfs4_init_client_minor_version(struct nfs_client *clp)
-{
-#if defined(CONFIG_NFS_V4_1)
-	if (clp->cl_mvops->minor_version) {
-		struct nfs4_session *session = NULL;
-		/*
-		 * Create the session and mark it expired.
-		 * When a SEQUENCE operation encounters the expired session
-		 * it will do session recovery to initialize it.
-		 */
-		session = nfs4_alloc_session(clp);
-		if (!session)
-			return -ENOMEM;
-
-		clp->cl_session = session;
-		/*
-		 * The create session reply races with the server back
-		 * channel probe. Mark the client NFS_CS_SESSION_INITING
-		 * so that the client back channel can find the
-		 * nfs_client struct
-		 */
-		clp->cl_cons_state = NFS_CS_SESSION_INITING;
-	}
-#endif /* CONFIG_NFS_V4_1 */
-
-	return nfs4_init_callback(clp);
-}
-
-/*
- * Initialise an NFS4 client record
- */
-int nfs4_init_client(struct nfs_client *clp,
-		     const struct rpc_timeout *timeparms,
-		     const char *ip_addr,
-		     rpc_authflavor_t authflavour,
-		     int noresvport)
-{
-	char buf[INET6_ADDRSTRLEN + 1];
-	int error;
-
-	if (clp->cl_cons_state == NFS_CS_READY) {
-		/* the client is initialised already */
-		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
-		return 0;
-	}
-
-	/* Check NFS protocol revision and initialize RPC op vector */
-	clp->rpc_ops = &nfs_v4_clientops;
-
-	error = nfs_create_rpc_client(clp, timeparms, authflavour,
-				      1, noresvport);
-	if (error < 0)
-		goto error;
-
-	/* If no clientaddr= option was specified, find a usable cb address */
-	if (ip_addr == NULL) {
-		struct sockaddr_storage cb_addr;
-		struct sockaddr *sap = (struct sockaddr *)&cb_addr;
-
-		error = rpc_localaddr(clp->cl_rpcclient, sap, sizeof(cb_addr));
-		if (error < 0)
-			goto error;
-		error = rpc_ntop(sap, buf, sizeof(buf));
-		if (error < 0)
-			goto error;
-		ip_addr = (const char *)buf;
-	}
-	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
-
-	error = nfs_idmap_new(clp);
-	if (error < 0) {
-		dprintk("%s: failed to create idmapper. Error = %d\n",
-			__func__, error);
-		goto error;
-	}
-	__set_bit(NFS_CS_IDMAP, &clp->cl_res_state);
-
-	error = nfs4_init_client_minor_version(clp);
-	if (error < 0)
-		goto error;
-
-	if (!nfs4_has_session(clp))
-		nfs_mark_client_ready(clp, NFS_CS_READY);
-	return 0;
-
-error:
-	nfs_mark_client_ready(clp, error);
-	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
-	return error;
-}
-
 #endif /* CONFIG_NFS_V4 */
 
 /*
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 3ed4b32..d53f350 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -62,6 +62,8 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
 				  const struct rpc_timeout *, const char *,
 				  rpc_authflavor_t, int);
 void nfs_init_timeout_values(struct rpc_timeout *, int, unsigned int, unsigned int);
+int nfs_create_rpc_client(struct nfs_client *, const struct rpc_timeout *,
+			  rpc_authflavor_t, int, int);
 int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *,
 			      rpc_authflavor_t);
 int nfs_probe_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 230d25e..fcdec76 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -9,6 +9,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_fs_sb.h>
 #include <linux/nfs_idmap.h>
+#include <linux/sunrpc/bc_xprt.h>
 #include "internal.h"
 #include "callback.h"
 #include "pnfs.h"
@@ -412,6 +413,131 @@ error:
 	return ERR_PTR(error);
 }
 
+/*
+ * Initialize the NFS4 callback service
+ */
+static int nfs4_init_callback(struct nfs_client *clp)
+{
+	int error;
+
+	if (clp->rpc_ops->version == 4) {
+		struct rpc_xprt *xprt;
+
+		xprt = rcu_dereference_raw(clp->cl_rpcclient->cl_xprt);
+
+		if (nfs4_has_session(clp)) {
+			error = xprt_setup_backchannel(xprt,
+						NFS41_BC_MIN_CALLBACKS);
+			if (error < 0)
+				return error;
+		}
+
+		error = nfs_callback_up(clp->cl_mvops->minor_version, xprt);
+		if (error < 0) {
+			dprintk("%s: failed to start callback. Error = %d\n",
+				__func__, error);
+			return error;
+		}
+		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
+	}
+	return 0;
+}
+
+/*
+ * Initialize the minor version specific parts of an NFS4 client record
+ */
+static int nfs4_init_client_minor_version(struct nfs_client *clp)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (clp->cl_mvops->minor_version) {
+		struct nfs4_session *session = NULL;
+		/*
+		 * Create the session and mark it expired.
+		 * When a SEQUENCE operation encounters the expired session
+		 * it will do session recovery to initialize it.
+		 */
+		session = nfs4_alloc_session(clp);
+		if (!session)
+			return -ENOMEM;
+
+		clp->cl_session = session;
+		/*
+		 * The create session reply races with the server back
+		 * channel probe. Mark the client NFS_CS_SESSION_INITING
+		 * so that the client back channel can find the
+		 * nfs_client struct
+		 */
+		clp->cl_cons_state = NFS_CS_SESSION_INITING;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+
+	return nfs4_init_callback(clp);
+}
+
+/*
+ * Initialise an NFS4 client record
+ */
+int nfs4_init_client(struct nfs_client *clp,
+		     const struct rpc_timeout *timeparms,
+		     const char *ip_addr,
+		     rpc_authflavor_t authflavour,
+		     int noresvport)
+{
+	char buf[INET6_ADDRSTRLEN + 1];
+	int error;
+
+	if (clp->cl_cons_state == NFS_CS_READY) {
+		/* the client is initialised already */
+		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
+		return 0;
+	}
+
+	/* Check NFS protocol revision and initialize RPC op vector */
+	clp->rpc_ops = &nfs_v4_clientops;
+
+	error = nfs_create_rpc_client(clp, timeparms, authflavour,
+				      1, noresvport);
+	if (error < 0)
+		goto error;
+
+	/* If no clientaddr= option was specified, find a usable cb address */
+	if (ip_addr == NULL) {
+		struct sockaddr_storage cb_addr;
+		struct sockaddr *sap = (struct sockaddr *)&cb_addr;
+
+		error = rpc_localaddr(clp->cl_rpcclient, sap, sizeof(cb_addr));
+		if (error < 0)
+			goto error;
+		error = rpc_ntop(sap, buf, sizeof(buf));
+		if (error < 0)
+			goto error;
+		ip_addr = (const char *)buf;
+	}
+
+	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
+
+	error = nfs_idmap_new(clp);
+	if (error < 0) {
+		dprintk("%s: failed to create idmapper. Error = %d\n",
+			__func__, error);
+		goto error;
+	}
+	__set_bit(NFS_CS_IDMAP, &clp->cl_res_state);
+
+	error = nfs4_init_client_minor_version(clp);
+	if (error < 0)
+		goto error;
+
+	if (!nfs4_has_session(clp))
+		nfs_mark_client_ready(clp, NFS_CS_READY);
+	return 0;
+
+error:
+	nfs_mark_client_ready(clp, error);
+	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
+	return error;
+}
+
 module_param(nfs4_disable_idmapping, bool, 0644);
 MODULE_PARM_DESC(nfs4_disable_idmapping,
 		"Turn off NFSv4 idmapping when using 'sec=sys'");
-- 
1.7.9.4

