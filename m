Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760264Ab2BJWC0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:26 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 15/21] NFS: Move the nfs4_init_client() to nfs4client.c
Date: Fri, 10 Feb 2012 17:01:59 -0500
Message-Id: <1328911325-1566-15-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c     |  117 ++------------------------------------------------
 fs/nfs/nfs.h        |    2 +
 fs/nfs/nfs4client.c |  108 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+), 112 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 69b563d..b709c38 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -38,7 +38,6 @@
 #include <linux/slab.h>
 #include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
-#include <linux/sunrpc/bc_xprt.h>
 
 #include <asm/system.h>
 
@@ -621,10 +620,10 @@ EXPORT_SYMBOL_GPL(nfs_init_timeout_values);
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
@@ -657,6 +656,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 	clp->cl_rpcclient = clnt;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_create_rpc_client);
 
 /*
  * Version 2 or 3 client destruction
@@ -1217,113 +1217,6 @@ nfs4_find_client_sessionid(const struct sockaddr *addr,
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
-		if (nfs4_has_session(clp)) {
-			error = xprt_setup_backchannel(
-						clp->cl_rpcclient->cl_xprt,
-						NFS41_BC_MIN_CALLBACKS);
-			if (error < 0)
-				return error;
-		}
-
-		error = nfs_callback_up(clp->cl_mvops->minor_version,
-					clp->cl_rpcclient->cl_xprt);
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
index 1934399..38113b5 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -64,6 +64,8 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *,
 				  const struct rpc_timeout *, const char *,
 				  rpc_authflavor_t, int);
 void nfs_init_timeout_values(struct rpc_timeout *, int, unsigned int, unsigned int);
+int nfs_create_rpc_client(struct nfs_client *, const struct rpc_timeout *,
+			  rpc_authflavor_t, int, int);
 int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *,
 			      rpc_authflavor_t);
 int nfs_probe_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 7a30d0a..f3a86fc 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -6,6 +6,7 @@
 #include <linux/module.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs_idmap.h>
+#include <linux/sunrpc/bc_xprt.h>
 #include "internal.h"
 #include "nfs4_fs.h"
 #include "callback.h"
@@ -410,6 +411,113 @@ error:
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
+		if (nfs4_has_session(clp)) {
+			error = xprt_setup_backchannel(
+						clp->cl_rpcclient->cl_xprt,
+						NFS41_BC_MIN_CALLBACKS);
+			if (error < 0)
+				return error;
+		}
+
+		error = nfs_callback_up(clp->cl_mvops->minor_version,
+					clp->cl_rpcclient->cl_xprt);
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
1.7.9

