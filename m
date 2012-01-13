Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59841 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932762Ab2AMULi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:38 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 38/44] NFS: Only initialize pnfs in the v4.x case
Date: Fri, 13 Jan 2012 15:10:47 -0500
Message-Id: <1326485453-1350-39-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 and v3 don't have pnfs, so I can move the pnfs_init_server() function
to the nfs4 client code to keep it separate from the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c      |   61 ++++++++++++++++++++++++-------------------------
 fs/nfs/nfs.h         |    5 ++++
 fs/nfs/nfs4/client.c |   32 ++++++++++++++++++++++++++
 fs/nfs/nfs4/nfs4.h   |    2 +
 fs/nfs/nfs4/super.c  |    3 +-
 5 files changed, 71 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dd6453b..778ef62 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -42,6 +42,7 @@
 
 #include <asm/system.h>
 
+#include "nfs4/nfs4.h"
 #include "nfs4/nfs4_fs.h"
 #include "nfs4/callback.h"
 #include "nfs4/delegation.h"
@@ -254,11 +255,6 @@ static void nfs_cb_idr_remove(struct nfs_client *clp)
 	spin_unlock(&nfs_idr_lock);
 }
 
-static void pnfs_init_server(struct nfs_server *server)
-{
-	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
-}
-
 static void nfs4_destroy_server(struct nfs_server *server)
 {
 	nfs4_purge_state_owners(server);
@@ -279,10 +275,6 @@ static void nfs_cb_idr_remove(struct nfs_client *clp)
 {
 }
 
-static void pnfs_init_server(struct nfs_server *server)
-{
-}
-
 #endif /* CONFIG_NFS_V4 */
 
 /*
@@ -1041,7 +1033,7 @@ static void nfs_server_remove_lists(struct nfs_server *server)
 /*
  * Allocate and initialise a server record
  */
-static struct nfs_server *nfs_alloc_server(void)
+struct nfs_server *nfs_alloc_server(void)
 {
 	struct nfs_server *server;
 
@@ -1072,10 +1064,9 @@ static struct nfs_server *nfs_alloc_server(void)
 		return NULL;
 	}
 
-	pnfs_init_server(server);
-
 	return server;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_server);
 
 /*
  * Free up a server record
@@ -1611,7 +1602,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 
 	dprintk("--> nfs4_create_server()\n");
 
-	server = nfs_alloc_server();
+	server = nfs4_alloc_server();
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
@@ -1645,7 +1636,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	dprintk("--> nfs4_create_referral_server()\n");
 
-	server = nfs_alloc_server();
+	server = nfs4_alloc_server();
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
@@ -1688,27 +1679,15 @@ error:
 
 #endif /* CONFIG_NFS_V4 */
 
-/*
- * Clone an NFS2, NFS3 or NFS4 server record
- */
-struct nfs_server *nfs_clone_server(struct nfs_server *source,
-				    struct nfs_fh *fh,
-				    struct nfs_fattr *fattr)
+struct nfs_server *do_nfs_clone_server(struct nfs_server *source,
+				       struct nfs_server *server,
+				       struct nfs_fh *fh,
+				       struct nfs_fattr *fattr)
 {
-	struct nfs_server *server;
 	struct nfs_fattr *fattr_fsinfo;
 	struct nfs_subversion *nfs_mod;
-	int error;
-
-	dprintk("--> nfs_clone_server(,%llx:%llx,)\n",
-		(unsigned long long) fattr->fsid.major,
-		(unsigned long long) fattr->fsid.minor);
-
-	server = nfs_alloc_server();
-	if (!server)
-		return ERR_PTR(-ENOMEM);
+	int error = -ENOMEM;
 
-	error = -ENOMEM;
 	fattr_fsinfo = nfs_alloc_fattr();
 	if (fattr_fsinfo == NULL)
 		goto out_free_server;
@@ -1760,6 +1739,26 @@ out_free_server:
 	dprintk("<-- nfs_clone_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(do_nfs_clone_server);
+
+/*
+ * Clone an NFS2 or NFS3 server record
+ */
+struct nfs_server *nfs_clone_server(struct nfs_server *source,
+				    struct nfs_fh *fh,
+				    struct nfs_fattr *fattr)
+{
+	struct nfs_server *server;
+	dprintk("--> nfs_clone_server(,%llx:%llx,)\n",
+		(unsigned long long) fattr->fsid.major,
+		(unsigned long long) fattr->fsid.minor);
+
+	server = nfs_alloc_server();
+	if (!server)
+		return ERR_PTR(-ENOMEM);
+	return do_nfs_clone_server(source, server, fh, fattr);
+}
+
 
 #ifdef CONFIG_PROC_FS
 static struct proc_dir_entry *proc_fs_nfs;
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 55ea4d7..13321fd 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -62,6 +62,11 @@ struct nfs_subversion *get_nfs_server_version(struct nfs_server *);
 void register_nfs_version(struct nfs_subversion *);
 void unregister_nfs_version(struct nfs_subversion *);
 
+/* Exported in client.c */
+struct nfs_server *nfs_alloc_server(void);
+struct nfs_server *do_nfs_clone_server(struct nfs_server *, struct nfs_server *,
+				       struct nfs_fh *, struct nfs_fattr *);
+
 /* Exported in dir.c */
 int nfs_lookup_revalidate(struct dentry *, struct nameidata *);
 int nfs_dentry_delete(const struct dentry *);
diff --git a/fs/nfs/nfs4/client.c b/fs/nfs/nfs4/client.c
index 9f53f3f..130c6a6 100644
--- a/fs/nfs/nfs4/client.c
+++ b/fs/nfs/nfs4/client.c
@@ -10,6 +10,9 @@
 #include "nfs4_fs.h"
 #include "delegation.h"
 #include "callback.h"
+#include "../nfs.h"
+
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 void nfs4_init_aclclient(struct nfs_server *server)
 {
@@ -49,3 +52,32 @@ void nfs4_shutdown_client(struct nfs_client *clp)
 
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
 }
+
+static void pnfs_init_server(struct nfs_server *server)
+{
+	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
+}
+
+struct nfs_server *nfs4_alloc_server(void)
+{
+	struct nfs_server *server = nfs_alloc_server();
+	if (server)
+		pnfs_init_server(server);
+	return server;
+}
+
+struct nfs_server *nfs4_clone_server(struct nfs_server *source,
+				     struct nfs_fh *fh,
+				     struct nfs_fattr *fattr)
+{
+	struct nfs_server *server;
+
+	dprintk("--> nfs_clone_server(,%llx:%llx,)\n",
+		(unsigned long long) fattr->fsid.major,
+		(unsigned long long) fattr->fsid.minor);
+
+	server = nfs4_alloc_server();
+	if (!server)
+		return ERR_PTR(-ENOMEM);
+	return do_nfs_clone_server(source, server, fh, fattr);
+}
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index c24fb13..111ba82 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -7,6 +7,8 @@ extern struct file_system_type nfs4_fs_type;
 
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
+struct nfs_server *nfs4_alloc_server(void);
+struct nfs_server *nfs4_clone_server(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
 
 void nfs4_init_aclclient(struct nfs_server *);
 void nfs4_shutdown_client(struct nfs_client *);
diff --git a/fs/nfs/nfs4/super.c b/fs/nfs/nfs4/super.c
index 12efb65..a8aa3f3 100644
--- a/fs/nfs/nfs4/super.c
+++ b/fs/nfs/nfs4/super.c
@@ -5,6 +5,7 @@
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs_fs_sb.h>
 
+#include "nfs4.h"
 #include "delegation.h"
 #include "../internal.h"
 #include "../fscache.h"
@@ -537,7 +538,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 	dprintk("--> nfs4_xdev_mount()\n");
 
 	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	server = nfs4_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out_err_noserver;
-- 
1.7.8.3

