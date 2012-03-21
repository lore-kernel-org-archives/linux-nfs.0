Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758975Ab2CUPVT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:19 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 13/23] NFS: Custom alloc and free client functions for modules
Date: Wed, 21 Mar 2012 11:20:43 -0400
Message-Id: <1332343253-24970-14-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives v4 a chance to do any setup and teardown that it needs (such
as pnfs or v4.1 sessions).

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile     |    2 +-
 fs/nfs/client.c     |   96 +++++++++++----------------------------------------
 fs/nfs/nfs.h        |   15 ++++++++
 fs/nfs/nfs2super.c  |    2 ++
 fs/nfs/nfs3super.c  |    2 ++
 fs/nfs/nfs4_fs.h    |    4 +++
 fs/nfs/nfs4client.c |   80 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4super.c  |    2 ++
 8 files changed, 127 insertions(+), 76 deletions(-)
 create mode 100644 fs/nfs/nfs4client.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 7c8a7a0..cf8b669 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,7 +12,7 @@ nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o nfs4sysctl.o
+			   nfs4namespace.o nfs4sysctl.o nfs4client.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index adc548c..41c687e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -27,7 +27,6 @@
 #include <linux/sunrpc/xprtrdma.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
-#include <linux/nfs4_mount.h>
 #include <linux/lockd/bind.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
@@ -44,9 +43,7 @@
 
 #include <asm/system.h>
 
-#include "nfs4_fs.h"
 #include "callback.h"
-#include "delegation.h"
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
@@ -65,7 +62,7 @@ static LIST_HEAD(nfs_versions);
  * Get a unique NFSv4.0 callback identifier which will be used
  * by the V4.0 callback service to lookup the nfs_client struct
  */
-static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
+int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 {
 	int ret = 0;
 	struct nfs_net *nn = net_generic(clp->net, nfs_net_id);
@@ -111,16 +108,6 @@ struct rpc_stat nfs_rpcstat = {
 	.program		= &nfs_program
 };
 
-struct nfs_client_initdata {
-	const char *hostname;
-	const struct sockaddr *addr;
-	size_t addrlen;
-	const struct nfs_rpc_ops *rpc_ops;
-	int proto;
-	u32 minorversion;
-	struct net *net;
-};
-
 static int find_nfs_version(struct nfs_subversion **nfs, unsigned int version)
 {
 	struct nfs_subversion *tmp;
@@ -184,7 +171,7 @@ EXPORT_SYMBOL_GPL(unregister_nfs_version);
  * Since these are allocated/deallocated very rarely, we don't
  * bother putting them in a slab cache...
  */
-static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
+struct nfs_client *_nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 {
 	struct nfs_client *clp;
 	struct rpc_cred *cred;
@@ -214,19 +201,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_proto = cl_init->proto;
 	clp->net = get_net(cl_init->net);
 
-#ifdef CONFIG_NFS_V4
-	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
-	if (err)
-		goto error_cleanup;
-
-	spin_lock_init(&clp->cl_lock);
-	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
-	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
-	clp->cl_boot_time = CURRENT_TIME;
-	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
-	clp->cl_minorversion = cl_init->minorversion;
-	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
-#endif
 	cred = rpc_lookup_machine_cred("*");
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;
@@ -239,42 +213,23 @@ error_cleanup:
 error_0:
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL_GPL(_nfs_alloc_client);
 
-#ifdef CONFIG_NFS_V4
-#ifdef CONFIG_NFS_V4_1
-static void nfs4_shutdown_session(struct nfs_client *clp)
-{
-	if (nfs4_has_session(clp)) {
-		nfs4_deviceid_purge_client(clp);
-		nfs4_destroy_session(clp->cl_session);
-	}
-
-}
-#else /* CONFIG_NFS_V4_1 */
-static void nfs4_shutdown_session(struct nfs_client *clp)
+static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 {
+	struct nfs_subversion *nfs_mod = get_nfs_version(cl_init->rpc_ops->version);
+	return nfs_mod->alloc_client(cl_init);
 }
-#endif /* CONFIG_NFS_V4_1 */
 
-/*
- * Destroy the NFS4 callback service
- */
-static void nfs4_destroy_callback(struct nfs_client *clp)
+#ifdef CONFIG_NFS_V4
+static void pnfs_init_server(struct nfs_server *server)
 {
-	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down(clp->cl_mvops->minor_version);
+	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
 }
 
-static void nfs4_shutdown_client(struct nfs_client *clp)
+static void nfs4_destroy_server(struct nfs_server *server)
 {
-	if (__test_and_clear_bit(NFS_CS_RENEWD, &clp->cl_res_state))
-		nfs4_kill_renewd(clp);
-	nfs4_shutdown_session(clp);
-	nfs4_destroy_callback(clp);
-	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
-		nfs_idmap_delete(clp);
-
-	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+	nfs4_purge_state_owners(server);
 }
 
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
@@ -294,21 +249,7 @@ static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
 		idr_remove(&nn->cb_ident_idr, clp->cl_cb_ident);
 }
 
-static void pnfs_init_server(struct nfs_server *server)
-{
-	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
-}
-
-static void nfs4_destroy_server(struct nfs_server *server)
-{
-	nfs4_purge_state_owners(server);
-}
-
 #else
-static void nfs4_shutdown_client(struct nfs_client *clp)
-{
-}
-
 void nfs_cleanup_cb_ident_idr(struct net *net)
 {
 }
@@ -326,11 +267,9 @@ static void pnfs_init_server(struct nfs_server *server)
 /*
  * Destroy a shared client record
  */
-static void nfs_free_client(struct nfs_client *clp)
+void _nfs_free_client(struct nfs_client *clp)
 {
-	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
-
-	nfs4_shutdown_client(clp);
+	dprintk("--> _nfs_free_client(%u)\n", clp->rpc_ops->version);
 
 	nfs_fscache_release_client_cookie(clp);
 
@@ -347,7 +286,14 @@ static void nfs_free_client(struct nfs_client *clp)
 	kfree(clp->impl_id);
 	kfree(clp);
 
-	dprintk("<-- nfs_free_client()\n");
+	dprintk("<-- _nfs_free_client()\n");
+}
+EXPORT_SYMBOL_GPL(_nfs_free_client);
+
+static void nfs_free_client(struct nfs_client *clp)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_client_version(clp);
+	nfs_mod->free_client(clp);
 }
 
 /*
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 9e632c2..6036141 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -14,6 +14,16 @@
 struct nfs_parsed_mount_data;
 struct nfs_clone_mount;
 
+struct nfs_client_initdata {
+	const char *hostname;
+	const struct sockaddr *addr;
+	size_t addrlen;
+	const struct nfs_rpc_ops *rpc_ops;
+	int proto;
+	u32 minorversion;
+	struct net *net;
+};
+
 struct nfs_subversion {
 	unsigned int version;		/* Protocol number */
 	struct rpc_version *rpc_vers;	/* NFS version information */
@@ -22,6 +32,8 @@ struct nfs_subversion {
 
 	void (*reference)(void);	/* For reference counting */
 	void (*unreference)(void);	/* Also for reference counting */
+	struct nfs_client *(*alloc_client)(const struct nfs_client_initdata *);
+	void (*free_client)(struct nfs_client *);
 	struct dentry *(*fs_mount)(struct file_system_type *, int, const char *,
 				   struct nfs_fh *, struct nfs_parsed_mount_data *);
 	struct dentry *(*xdev_mount)(int, const char *, struct nfs_clone_mount *);
@@ -43,7 +55,10 @@ void register_nfs_version(struct nfs_subversion *);
 void unregister_nfs_version(struct nfs_subversion *);
 
 /* Exported in client.c */
+int nfs_get_cb_ident_idr(struct nfs_client *, int);
 struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *, struct nfs_fh *);
+struct nfs_client *_nfs_alloc_client(const struct nfs_client_initdata *);
+void _nfs_free_client(struct nfs_client *);
 
 /* Exported in dir.c */
 struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index 6d2a1fd..697356f 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -54,6 +54,8 @@ static struct nfs_subversion nfs_v2 = {
 
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
+	.alloc_client = _nfs_alloc_client,
+	.free_client = _nfs_free_client,
 	.fs_mount = nfs2_fs_mount,
 	.xdev_mount = nfs2_xdev_mount,
 	.submount = nfs2_do_submount,
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index 7142c03..17dad41 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -85,6 +85,8 @@ static struct nfs_subversion nfs_v3 = {
 
 	.reference = nfs3_reference,
 	.unreference = nfs3_unreference,
+	.alloc_client = _nfs_alloc_client,
+	.free_client = _nfs_free_client,
 	.fs_mount = nfs3_fs_mount,
 	.xdev_mount = nfs3_xdev_mount,
 	.submount = nfs3_do_submount,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b6bc89c..636786e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -210,6 +210,10 @@ extern const struct inode_operations nfs4_dir_inode_operations;
 extern struct file_system_type nfs4_fs_type;
 struct dentry *nfs4_try_mount(int flags, const char *dev_name, struct nfs_parsed_mount_data *);
 
+/* nfs4client.c */
+struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *);
+void nfs4_free_client(struct nfs_client *);
+
 /* nfs4namespace.c */
 struct vfsmount *nfs4_do_submount(struct dentry *, struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
new file mode 100644
index 0000000..c555748
--- /dev/null
+++ b/fs/nfs/nfs4client.c
@@ -0,0 +1,80 @@
+/*
+ *Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#include <linux/nfs4.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_fs_sb.h>
+#include <linux/nfs_idmap.h>
+#include "internal.h"
+#include "callback.h"
+#include "pnfs.h"
+
+#ifdef CONFIG_NFS_V4_1
+static void nfs4_shutdown_session(struct nfs_client *clp)
+{
+	if (nfs4_has_session(clp)) {
+		nfs4_deviceid_purge_client(clp);
+		nfs4_destroy_session(clp->cl_session);
+	}
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
+static void nfs4_shutdown_client(struct nfs_client *clp)
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
+
+void nfs4_free_client(struct nfs_client *clp)
+{
+	nfs4_shutdown_client(clp);
+	_nfs_free_client(clp);
+}
+
+struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
+{
+	struct nfs_client *clp = _nfs_alloc_client(cl_init);
+	int err = -ENOMEM;
+
+	if (IS_ERR(clp))
+		return clp;
+
+	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
+	if (err)
+		goto error_cleanup;
+
+	spin_lock_init(&clp->cl_lock);
+	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
+	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
+	clp->cl_boot_time = CURRENT_TIME;
+	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
+	clp->cl_minorversion = cl_init->minorversion;
+	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+
+	return clp;
+
+error_cleanup:
+	kfree(clp);
+	return ERR_PTR(err);
+}
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index b384a81..b0beba9 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -615,6 +615,8 @@ static struct nfs_subversion nfs_v4 = {
 
 	.reference = nfs4_reference,
 	.unreference = nfs4_unreference,
+	.alloc_client = nfs4_alloc_client,
+	.free_client = nfs4_free_client,
 	.fs_mount = nfs4_fs_mount,
 	.xdev_mount = nfs4_xdev_mount,
 	.submount = nfs4_do_submount,
-- 
1.7.9.4

