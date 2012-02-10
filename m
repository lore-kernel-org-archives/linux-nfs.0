Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab2BJWCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:15 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 05/21] NFS: Break up the nfs_fs_mount function
Date: Fri, 10 Feb 2012 17:01:49 -0500
Message-Id: <1328911325-1566-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I keep the first few generic steps before calling into a specific NFS
version to allocate a server and complete the mount.  This will
eventually allow each NFS version to do custom server initialization
before attempting a mount, such as setting up the v3 aclclient or
initializing v4.1 pnfs.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c    |    1 +
 fs/nfs/nfs.h       |   13 ++++++++
 fs/nfs/nfs2super.c |   12 +++++++
 fs/nfs/nfs3super.c |   12 +++++++
 fs/nfs/nfs4_fs.h   |    5 +++
 fs/nfs/nfs4super.c |   10 ++++++
 fs/nfs/super.c     |   84 ++++++++++++++++++++++++++-------------------------
 7 files changed, 96 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4312a51..67a6187 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1263,6 +1263,7 @@ error:
 	nfs_free_server(server);
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(nfs_create_server);
 
 #ifdef CONFIG_NFS_V4
 /*
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 4e4802e..dc7d047 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -13,6 +13,8 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_xdr.h>
 
+struct nfs_parsed_mount_data;
+
 struct nfs_subversion {
 	unsigned int version;		/* Protocol number */
 	struct rpc_version *rpc_vers;	/* NFS version information */
@@ -21,6 +23,8 @@ struct nfs_subversion {
 
 	void (*reference)(void);	/* For reference counting */
 	void (*unreference)(void);	/* Also for reference counting */
+	struct dentry *(*fs_mount)(struct file_system_type *, int, const char *,
+				   struct nfs_fh *, struct nfs_parsed_mount_data *);
 };
 
 void nfs_register_versions(void);
@@ -33,4 +37,13 @@ struct nfs_subversion *get_nfs_server_version(struct nfs_server *);
 void register_nfs_version(struct nfs_subversion *);
 void unregister_nfs_version(struct nfs_subversion *);
 
+/* Exported in client.c */
+struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *, struct nfs_fh *);
+
+/* Exported in super.c */
+struct dentry *_nfs_fs_mount(struct file_system_type *, struct nfs_server *,
+			     int, const char *, struct nfs_fh *,
+			     struct nfs_parsed_mount_data *);
+
+
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index 773342d..8f92f5d 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -17,6 +17,17 @@ static void nfs2_unreference(void)
 	module_put(THIS_MODULE);
 }
 
+static struct dentry *nfs2_fs_mount(struct file_system_type *fs_type,
+				    int flags, const char *dev_name,
+				    struct nfs_fh *mntfh,
+				    struct nfs_parsed_mount_data *data)
+{
+	struct nfs_server *server = nfs_create_server(data, mntfh);
+	if (IS_ERR(server))
+		return ERR_CAST(server);
+	return _nfs_fs_mount(fs_type, server, flags, dev_name, mntfh, data);
+}
+
 static struct nfs_subversion nfs_v2 = {
 	.version  = 2,
 	.rpc_vers = &nfs_version2,
@@ -24,6 +35,7 @@ static struct nfs_subversion nfs_v2 = {
 
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
+	.fs_mount = nfs2_fs_mount,
 };
 
 static int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index a02c815..2048460 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -15,6 +15,17 @@ static void nfs3_unreference(void)
 	module_put(THIS_MODULE);
 }
 
+struct dentry *nfs3_fs_mount(struct file_system_type *fs_type,
+			     int flags, const char *dev_name,
+			     struct nfs_fh *mntfh,
+			     struct nfs_parsed_mount_data *data)
+{
+	struct nfs_server *server = nfs_create_server(data, mntfh);
+	if (IS_ERR(server))
+		return ERR_CAST(server);
+	return _nfs_fs_mount(fs_type, server, flags, dev_name, mntfh, data);
+}
+
 static struct nfs_subversion nfs_v3 = {
 	.version  = 3,
 	.rpc_vers = &nfs_version3,
@@ -22,6 +33,7 @@ static struct nfs_subversion nfs_v3 = {
 
 	.reference = nfs3_reference,
 	.unreference = nfs3_unreference,
+	.fs_mount = nfs3_fs_mount,
 };
 
 int __init init_nfs_v3(void)
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b133b50..b888151 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -11,6 +11,8 @@
 
 #ifdef CONFIG_NFS_V4
 
+#include "nfs.h"
+
 struct idmap;
 
 enum nfs4_client_state {
@@ -204,6 +206,9 @@ struct nfs4_state_maintenance_ops {
 extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
+/* super.c */
+struct dentry *nfs4_try_mount(int flags, const char *dev_name, struct nfs_parsed_mount_data *);
+
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 9b2a679..0cc67b6 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -3,6 +3,7 @@
  */
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
+#include "nfs4_fs.h"
 #include "nfs.h"
 
 static void nfs4_reference(void)
@@ -15,6 +16,14 @@ static void nfs4_unreference(void)
 	module_put(THIS_MODULE);
 }
 
+struct dentry *nfs4_fs_mount(struct file_system_type *fs_type,
+			     int flags, const char *dev_name,
+			     struct nfs_fh *mntfh,
+			     struct nfs_parsed_mount_data *data)
+{
+	return nfs4_try_mount(flags, dev_name, data);
+}
+
 static struct nfs_subversion nfs_v4 = {
 	.version  = 4,
 	.rpc_vers = &nfs_version4,
@@ -22,6 +31,7 @@ static struct nfs_subversion nfs_v4 = {
 
 	.reference = nfs4_reference,
 	.unreference = nfs4_unreference,
+	.fs_mount = nfs4_fs_mount,
 };
 
 int __init init_nfs_v4(void)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c5a2085..c1e8994 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -310,7 +310,7 @@ static const struct super_operations nfs_sops = {
 #ifdef CONFIG_NFS_V4
 static int nfs4_validate_text_mount_data(void *options,
 	struct nfs_parsed_mount_data *args, const char *dev_name);
-static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
+struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	struct nfs_parsed_mount_data *data);
 static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
@@ -2237,52 +2237,20 @@ static void nfs_unregister(struct nfs_server *server)
 	nfs_mod->unreference();
 }
 
-static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data)
+struct dentry *_nfs_fs_mount(struct file_system_type *fs_type,
+			     struct nfs_server *server,
+			     int flags, const char *dev_name,
+			     struct nfs_fh *mntfh,
+			     struct nfs_parsed_mount_data *data)
 {
-	struct nfs_server *server = NULL;
 	struct super_block *s;
-	struct nfs_parsed_mount_data *data;
-	struct nfs_fh *mntfh;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
 	};
-	struct nfs_subversion *nfs_mod;
 	int error;
 
-	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
-	mntfh = nfs_alloc_fhandle();
-	if (data == NULL || mntfh == NULL)
-		goto out;
-
-	/* Validate the mount data */
-	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
-	if (error < 0) {
-		mntroot = ERR_PTR(error);
-		goto out;
-	}
-
-	nfs_mod = get_nfs_version(data->version);
-	if (IS_ERR(nfs_mod)) {
-		mntroot = (struct dentry *)nfs_mod;
-		goto out;
-	}
-
-#ifdef CONFIG_NFS_V4
-	if (data->version == 4) {
-		mntroot = nfs4_try_mount(flags, dev_name, data);
-		goto out;
-	}
-#endif	/* CONFIG_NFS_V4 */
-
-	/* Get a volume representation */
-	server = nfs_create_server(data, mntfh);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
 	sb_mntdata.server = server;
 
 	if (server->flags & NFS_MOUNT_UNSHARED)
@@ -2327,8 +2295,6 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	s->s_flags |= MS_ACTIVE;
 
 out:
-	nfs_free_parsed_mount_data(data);
-	nfs_free_fhandle(mntfh);
 	return mntroot;
 
 out_err_nosb:
@@ -2345,6 +2311,42 @@ error_splat_bdi:
 	deactivate_locked_super(s);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(_nfs_fs_mount);
+
+static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data)
+{
+	struct nfs_parsed_mount_data *data;
+	struct nfs_fh *mntfh;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+	struct nfs_subversion *nfs_mod;
+	int error;
+
+	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
+	mntfh = nfs_alloc_fhandle();
+	if (data == NULL || mntfh == NULL)
+		goto out;
+
+	/* Validate the mount data */
+	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
+	if (error < 0) {
+		mntroot = ERR_PTR(error);
+		goto out;
+	}
+
+	nfs_mod = get_nfs_version(data->version);
+	if (IS_ERR(nfs_mod)) {
+		mntroot = (struct dentry *)nfs_mod;
+		goto out;
+	}
+
+	mntroot = nfs_mod->fs_mount(fs_type, flags, dev_name, mntfh, data);
+
+out:
+	nfs_free_parsed_mount_data(data);
+	nfs_free_fhandle(mntfh);
+	return mntroot;
+}
 
 /*
  * Ensure that we unregister the bdi before kill_anon_super
@@ -2829,7 +2831,7 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 	return dentry;
 }
 
-static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
+struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 			 struct nfs_parsed_mount_data *data)
 {
 	char *export_path;
-- 
1.7.9

