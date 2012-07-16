Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4387 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461Ab2GPUja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:30 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/12] NFS: Initialize the NFS v4 client from init_nfs_v4()
Date: Mon, 16 Jul 2012 16:39:17 -0400
Message-Id: <1342471161-22452-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

And split these functions out of the generic client into a v4 specific
file.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile     |   2 +-
 fs/nfs/client.c     | 137 ++-----------------------------------------------
 fs/nfs/internal.h   |   1 +
 fs/nfs/nfs4client.c | 144 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 149 insertions(+), 135 deletions(-)
 create mode 100644 fs/nfs/nfs4client.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index ec13afe..0b96c20 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -15,7 +15,7 @@ nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o nfs4file.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o nfs4getroot.o
+			   nfs4namespace.o nfs4getroot.o nfs4client.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 
 ifeq ($(CONFIG_SYSCTL), y)
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 254719c..5664c7b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -662,9 +662,9 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 /*
  * Create an RPC client handle
  */
-static int nfs_create_rpc_client(struct nfs_client *clp,
-				 const struct rpc_timeout *timeparms,
-				 rpc_authflavor_t flavor)
+int nfs_create_rpc_client(struct nfs_client *clp,
+			  const struct rpc_timeout *timeparms,
+			  rpc_authflavor_t flavor)
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
@@ -1305,137 +1305,6 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
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
-		nfs_mark_client_ready(clp, NFS_CS_SESSION_INITING);
-	}
-#endif /* CONFIG_NFS_V4_1 */
-
-	return nfs4_init_callback(clp);
-}
-
-/**
- * nfs4_init_client - Initialise an NFS4 client record
- *
- * @clp: nfs_client to initialise
- * @timeparms: timeout parameters for underlying RPC transport
- * @ip_addr: callback IP address in presentation format
- * @authflavor: authentication flavor for underlying RPC transport
- *
- * Returns pointer to an NFS client, or an ERR_PTR value.
- */
-struct nfs_client *nfs4_init_client(struct nfs_client *clp,
-				    const struct rpc_timeout *timeparms,
-				    const char *ip_addr,
-				    rpc_authflavor_t authflavour)
-{
-	char buf[INET6_ADDRSTRLEN + 1];
-	int error;
-
-	if (clp->cl_cons_state == NFS_CS_READY) {
-		/* the client is initialised already */
-		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
-		return clp;
-	}
-
-	/* Check NFS protocol revision and initialize RPC op vector */
-	clp->rpc_ops = &nfs_v4_clientops;
-
-	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
-	error = nfs_create_rpc_client(clp, timeparms, authflavour);
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
-	return clp;
-
-error:
-	nfs_mark_client_ready(clp, error);
-	nfs_put_client(clp);
-	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
-	return ERR_PTR(error);
-}
-
-/*
  * Set up an NFS4 client
  */
 static int nfs4_set_client(struct nfs_server *server,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ca7200a..10df28d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -149,6 +149,7 @@ extern void nfs_umount(const struct nfs_mount_request *info);
 extern const struct rpc_program nfs_program;
 extern void nfs_clients_init(struct net *net);
 extern struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *);
+int nfs_create_rpc_client(struct nfs_client *, const struct rpc_timeout *, rpc_authflavor_t);
 
 extern void nfs_cleanup_cb_ident_idr(struct net *);
 extern void nfs_put_client(struct nfs_client *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
new file mode 100644
index 0000000..c5234b5
--- /dev/null
+++ b/fs/nfs/nfs4client.c
@@ -0,0 +1,144 @@
+/*
+ * Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+#include <linux/nfs_fs.h>
+#include <linux/nfs_idmap.h>
+#include <linux/sunrpc/auth.h>
+#include <linux/sunrpc/xprt.h>
+#include <linux/sunrpc/bc_xprt.h>
+#include "internal.h"
+#include "callback.h"
+
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
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
+		nfs_mark_client_ready(clp, NFS_CS_SESSION_INITING);
+	}
+#endif /* CONFIG_NFS_V4_1 */
+
+	return nfs4_init_callback(clp);
+}
+
+/**
+ * nfs4_init_client - Initialise an NFS4 client record
+ *
+ * @clp: nfs_client to initialise
+ * @timeparms: timeout parameters for underlying RPC transport
+ * @ip_addr: callback IP address in presentation format
+ * @authflavor: authentication flavor for underlying RPC transport
+ *
+ * Returns pointer to an NFS client, or an ERR_PTR value.
+ */
+struct nfs_client *nfs4_init_client(struct nfs_client *clp,
+				    const struct rpc_timeout *timeparms,
+				    const char *ip_addr,
+				    rpc_authflavor_t authflavour)
+{
+	char buf[INET6_ADDRSTRLEN + 1];
+	int error;
+
+	if (clp->cl_cons_state == NFS_CS_READY) {
+		/* the client is initialised already */
+		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
+		return clp;
+	}
+
+	/* Check NFS protocol revision and initialize RPC op vector */
+	clp->rpc_ops = &nfs_v4_clientops;
+
+	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
+	error = nfs_create_rpc_client(clp, timeparms, authflavour);
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
+	return clp;
+
+error:
+	nfs_mark_client_ready(clp, error);
+	nfs_put_client(clp);
+	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
+	return ERR_PTR(error);
+}
-- 
1.7.11.2

