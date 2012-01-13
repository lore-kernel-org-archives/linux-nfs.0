Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932742Ab2AMULV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:21 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 21/44] NFS: Add a function to run when shutting down a client
Date: Fri, 13 Jan 2012 15:10:30 -0500
Message-Id: <1326485453-1350-22-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v4 has a callback socket that needs to be closed, and v4.1 has sessions
that should be cleaned up before exiting.  This function provides a
chance to do that.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c      |   40 +++-------------------------------------
 fs/nfs/nfs.h         |    1 +
 fs/nfs/nfs2/module.c |    5 +++++
 fs/nfs/nfs3/module.c |    5 +++++
 fs/nfs/nfs4/client.c |   39 +++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4/nfs4.h   |    1 +
 6 files changed, 54 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ca6ebe5..d7470fa 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -137,6 +137,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.reference = nfs_module_null_function,
 	.unreference = nfs_module_null_function,
 	.init_aclclient = nfs4_init_aclclient,
+	.shutdown_client = nfs4_shutdown_client,
 	.have_delegation = nfs4_have_delegation,
 	.have_delegated_attributes = nfs4_have_delegated_attributes,
 	.return_delegation = nfs4_inode_return_delegation,
@@ -282,39 +283,6 @@ error_0:
 }
 
 #ifdef CONFIG_NFS_V4
-#ifdef CONFIG_NFS_V4_1
-static void nfs4_shutdown_session(struct nfs_client *clp)
-{
-	if (nfs4_has_session(clp))
-		nfs4_destroy_session(clp->cl_session);
-}
-#else /* CONFIG_NFS_V4_1 */
-static void nfs4_shutdown_session(struct nfs_client *clp)
-{
-}
-#endif /* CONFIG_NFS_V4_1 */
-
-/*
- * Destroy the NFS4 callback service
- */
-static void nfs4_destroy_callback(struct nfs_client *clp)
-{
-	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down(clp->cl_mvops->minor_version);
-}
-
-static void nfs4_shutdown_client(struct nfs_client *clp)
-{
-	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
-		nfs4_kill_renewd(clp);
-	nfs4_shutdown_session(clp);
-	nfs4_destroy_callback(clp);
-	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
-		nfs_idmap_delete(clp);
-
-	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
-}
-
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
 void nfs_cleanup_cb_ident_idr(void)
 {
@@ -339,9 +307,6 @@ static void nfs4_destroy_server(struct nfs_server *server)
 }
 
 #else
-static void nfs4_shutdown_client(struct nfs_client *clp)
-{
-}
 
 void nfs_cleanup_cb_ident_idr(void)
 {
@@ -362,9 +327,10 @@ static void pnfs_init_server(struct nfs_server *server)
  */
 static void nfs_free_client(struct nfs_client *clp)
 {
+	struct nfs_subversion *nfs_mod = get_nfs_client_version(clp);
 	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
 
-	nfs4_shutdown_client(clp);
+	nfs_mod->shutdown_client(clp);
 
 	nfs_fscache_release_client_cookie(clp);
 
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index c3dfb7d..987656f 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -22,6 +22,7 @@ struct nfs_subversion {
 	void (*reference)(void);	/* For reference counting */
 	void (*unreference)(void);	/* Also for reference counting */
 	void (*init_aclclient)(struct nfs_server *);
+	void (*shutdown_client)(struct nfs_client *);
 	int (*have_delegation)(struct inode *, fmode_t);
 	int (*have_delegated_attributes)(struct inode *);
 	int (*return_delegation)(struct inode *);
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index 618ce83..7c29b04 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -19,6 +19,10 @@ static void nfs2_unreference(void)
 	module_put(THIS_MODULE);
 }
 
+static void nfs2_shutdown_client(struct nfs_client *clp)
+{
+}
+
 static int nfs2_no_delegation(struct inode *inode, fmode_t flags)
 {
 	return 0;
@@ -37,6 +41,7 @@ struct nfs_subversion nfs_v2 = {
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
 	.init_aclclient = nfs2_init_aclclient,
+	.shutdown_client = nfs2_shutdown_client,
 	.have_delegation = nfs2_no_delegation,
 	.have_delegated_attributes = nfs2_no_delegation2,
 	.return_delegation = nfs2_no_delegation2,
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index a999b2f..6293bf7 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -19,6 +19,10 @@ static void nfs3_unreference(void)
 	module_put(THIS_MODULE);
 }
 
+static void nfs3_shutdown_client(struct nfs_client *clp)
+{
+}
+
 static int nfs3_no_delegation(struct inode *inode, fmode_t flags)
 {
 	return 0;
@@ -37,6 +41,7 @@ struct nfs_subversion nfs_v3 = {
 	.reference = nfs3_reference,
 	.unreference = nfs3_unreference,
 	.init_aclclient = nfs3_init_aclclient,
+	.shutdown_client = nfs3_shutdown_client,
 	.have_delegation = nfs3_no_delegation,
 	.have_delegated_attributes = nfs3_no_delegation2,
 	.return_delegation = nfs3_no_delegation2,
diff --git a/fs/nfs/nfs4/client.c b/fs/nfs/nfs4/client.c
index bbc415d..9f53f3f 100644
--- a/fs/nfs/nfs4/client.c
+++ b/fs/nfs/nfs4/client.c
@@ -2,11 +2,50 @@
  * Copyright (c) 2012 Netapp, Inc. All rights reserved.
  */
 #include <linux/sunrpc/sched.h>
+#include <linux/nfs_fs.h>
 #include <linux/nfs_fs_sb.h>
+#include <linux/nfs_idmap.h>
 #include <linux/nfs_mount.h>
 
+#include "nfs4_fs.h"
+#include "delegation.h"
+#include "callback.h"
+
 void nfs4_init_aclclient(struct nfs_server *server)
 {
 	server->flags &= ~NFS_MOUNT_NOACL;
 	server->flags &= ~NFS_CAP_ACLS;
 }
+
+#ifdef CONFIG_NFS_V4_1
+static void nfs4_shutdown_session(struct nfs_client *clp)
+{
+	if (nfs4_has_session(clp))
+		nfs4_destroy_session(clp->cl_session);
+}
+#else /* CONFIG_NFS_V4_1 */
+static void nfs4_shutdown_session(struct nfs_client *clp)
+{
+}
+#endif /* CONFIG_NFS_V4_1 */
+
+/*
+ * Destroy the NFS4 callback service
+ */
+static void nfs4_destroy_callback(struct nfs_client *clp)
+{
+	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
+		nfs_callback_down(clp->cl_mvops->minor_version);
+}
+
+void nfs4_shutdown_client(struct nfs_client *clp)
+{
+	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
+		nfs4_kill_renewd(clp);
+	nfs4_shutdown_session(clp);
+	nfs4_destroy_callback(clp);
+	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
+		nfs_idmap_delete(clp);
+
+	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+}
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 6d5cf57..97ff8d8 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -4,6 +4,7 @@
 #include "../nfs.h"
 
 void nfs4_init_aclclient(struct nfs_server *);
+void nfs4_shutdown_client(struct nfs_client *);
 struct vfsmount *nfs4_do_submount(struct dentry *, struct nfs_fh *,
 				  struct nfs_fattr *, rpc_authflavor_t);
 struct vfsmount *nfs4_do_clone_mount(struct nfs_server *, const char *,
-- 
1.7.8.3

