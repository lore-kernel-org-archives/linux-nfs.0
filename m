Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758315Ab2CUPVQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:16 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 07/23] NFS: Version specific xdev mounting
Date: Wed, 21 Mar 2012 11:20:37 -0400
Message-Id: <1332343253-24970-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I set up a common _nfs_xdev_mount() function that can be called by v2,
v3 and v4 with different parameters.  This also gives each version a
chance to do their own thing both before and after the call.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs.h       |    4 ++
 fs/nfs/nfs2super.c |   10 ++++-
 fs/nfs/nfs3super.c |    8 ++++
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4super.c |   11 +++++
 fs/nfs/super.c     |  126 ++++++++++------------------------------------------
 6 files changed, 56 insertions(+), 104 deletions(-)

diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index a7a08b3..a5e6a63 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -12,6 +12,7 @@
 #include <linux/nfs_xdr.h>
 
 struct nfs_parsed_mount_data;
+struct nfs_clone_mount;
 
 struct nfs_subversion {
 	unsigned int version;		/* Protocol number */
@@ -23,6 +24,7 @@ struct nfs_subversion {
 	void (*unreference)(void);	/* Also for reference counting */
 	struct dentry *(*fs_mount)(struct file_system_type *, int, const char *,
 				   struct nfs_fh *, struct nfs_parsed_mount_data *);
+	struct dentry *(*xdev_mount)(int, const char *, struct nfs_clone_mount *);
 };
 
 void nfs_register_versions(void);
@@ -39,9 +41,11 @@ void unregister_nfs_version(struct nfs_subversion *);
 struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *, struct nfs_fh *);
 
 /* Exported in super.c */
+extern struct file_system_type nfs_fs_type;
 struct dentry *_nfs_fs_mount(struct file_system_type *, struct nfs_server *,
 			     int, const char *, struct nfs_fh *,
 			     struct nfs_parsed_mount_data *);
+struct dentry *_nfs_xdev_mount(struct file_system_type *, int, const char *, void *, int);
 
 
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index 8f92f5d..d1074a9 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -1,10 +1,11 @@
 /*
  * Copyright (c) 2012 Netapp, Inc. All rights reserved.
  *
- * Initialize the NFS v2 module
+ Initialize[* Initialize the NFS v2 module
  */
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
 #include "nfs.h"
 
 static void nfs2_reference(void)
@@ -28,6 +29,12 @@ static struct dentry *nfs2_fs_mount(struct file_system_type *fs_type,
 	return _nfs_fs_mount(fs_type, server, flags, dev_name, mntfh, data);
 }
 
+static struct dentry *nfs2_xdev_mount(int flags, const char *dev_name,
+				      struct nfs_clone_mount *data)
+{
+	return _nfs_xdev_mount(&nfs_fs_type, flags, dev_name, data, NFS_MOUNT_UNSHARED);
+}
+
 static struct nfs_subversion nfs_v2 = {
 	.version  = 2,
 	.rpc_vers = &nfs_version2,
@@ -36,6 +43,7 @@ static struct nfs_subversion nfs_v2 = {
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
 	.fs_mount = nfs2_fs_mount,
+	.xdev_mount = nfs2_xdev_mount,
 };
 
 static int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index 2048460..7bdd388 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -3,6 +3,7 @@
  */
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
 #include "nfs.h"
 
 static void nfs3_reference(void)
@@ -26,6 +27,12 @@ struct dentry *nfs3_fs_mount(struct file_system_type *fs_type,
 	return _nfs_fs_mount(fs_type, server, flags, dev_name, mntfh, data);
 }
 
+static struct dentry *nfs3_xdev_mount(int flags, const char *dev_name,
+				      struct nfs_clone_mount *data)
+{
+	return _nfs_xdev_mount(&nfs_fs_type, flags, dev_name, data, NFS_MOUNT_UNSHARED);
+}
+
 static struct nfs_subversion nfs_v3 = {
 	.version  = 3,
 	.rpc_vers = &nfs_version3,
@@ -34,6 +41,7 @@ static struct nfs_subversion nfs_v3 = {
 	.reference = nfs3_reference,
 	.unreference = nfs3_unreference,
 	.fs_mount = nfs3_fs_mount,
+	.xdev_mount = nfs3_xdev_mount,
 };
 
 int __init init_nfs_v3(void)
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index cb2f14c..6786c4f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -207,6 +207,7 @@ extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
 /* super.c */
+extern struct file_system_type nfs4_fs_type;
 struct dentry *nfs4_try_mount(int flags, const char *dev_name, struct nfs_parsed_mount_data *);
 
 /* nfs4proc.c */
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 0cc67b6..8a297c5 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -3,6 +3,7 @@
  */
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
+#include <linux/nfs4_mount.h>
 #include "nfs4_fs.h"
 #include "nfs.h"
 
@@ -24,6 +25,15 @@ struct dentry *nfs4_fs_mount(struct file_system_type *fs_type,
 	return nfs4_try_mount(flags, dev_name, data);
 }
 
+/*
+ * Clone an NFS4 server record on xdev traversal (FSID-change)
+ */
+struct dentry *nfs4_xdev_mount(int flags, const char *dev_name,
+			       struct nfs_clone_mount *data)
+{
+	return _nfs_xdev_mount(&nfs4_fs_type, flags, dev_name, data, NFS4_MOUNT_UNSHARED);
+}
+
 static struct nfs_subversion nfs_v4 = {
 	.version  = 4,
 	.rpc_vers = &nfs_version4,
@@ -32,6 +42,7 @@ static struct nfs_subversion nfs_v4 = {
 	.reference = nfs4_reference,
 	.unreference = nfs4_unreference,
 	.fs_mount = nfs4_fs_mount,
+	.xdev_mount = nfs4_xdev_mount,
 };
 
 int __init init_nfs_v4(void)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 16ceae3..994a0cc 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -293,13 +293,14 @@ static void nfs_put_super(struct super_block *);
 static void nfs_kill_super(struct super_block *);
 static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
-static struct file_system_type nfs_fs_type = {
+struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs",
 	.mount		= nfs_fs_mount,
 	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
+EXPORT_SYMBOL_GPL(nfs_fs_type);
 
 struct file_system_type nfs_xdev_fs_type = {
 	.owner		= THIS_MODULE,
@@ -333,15 +334,13 @@ static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_xdev_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static void nfs4_kill_super(struct super_block *sb);
 
-static struct file_system_type nfs4_fs_type = {
+struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
 	.mount		= nfs4_mount,
@@ -360,7 +359,7 @@ static struct file_system_type nfs4_remote_fs_type = {
 struct file_system_type nfs4_xdev_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
-	.mount		= nfs4_xdev_mount,
+	.mount		= nfs_xdev_mount,
 	.kill_sb	= nfs4_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
@@ -2437,9 +2436,9 @@ static void nfs_kill_super(struct super_block *s)
 /*
  * Clone an NFS2/3 server record on xdev traversal (FSID-change)
  */
-static struct dentry *
-nfs_xdev_mount(struct file_system_type *fs_type, int flags,
-		const char *dev_name, void *raw_data)
+struct dentry *
+_nfs_xdev_mount(struct file_system_type *fs_type, int flags,
+		const char *dev_name, void *raw_data, int unshared_flag)
 {
 	struct nfs_clone_mount *data = raw_data;
 	struct super_block *s;
@@ -2451,7 +2450,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	};
 	int error;
 
-	dprintk("--> nfs_xdev_mount()\n");
+	dprintk("--> _nfs_xdev_mount()\n");
 
 	/* create a new volume representation */
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
@@ -2461,7 +2460,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	}
 	sb_mntdata.server = server;
 
-	if (server->flags & NFS_MOUNT_UNSHARED)
+	if (server->flags & unshared_flag)
 		compare_super = NULL;
 
 	/* -o noac implies -o sync */
@@ -2469,7 +2468,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
+	s = sget(fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
@@ -2506,13 +2505,13 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	/* clone any lsm security options from the parent to the new sb */
 	security_sb_clone_mnt_opts(data->sb, s);
 
-	dprintk("<-- nfs_xdev_mount() = 0\n");
+	dprintk("<-- _nfs_xdev_mount() = 0\n");
 	return mntroot;
 
 out_err_nosb:
 	nfs_free_server(server);
 out_err_noserver:
-	dprintk("<-- nfs_xdev_mount() = %d [error]\n", error);
+	dprintk("<-- _nfs_xdev_mount() = %d [error]\n", error);
 	return ERR_PTR(error);
 
 error_splat_super:
@@ -2520,9 +2519,19 @@ error_splat_super:
 		nfs_unregister(server);
 error_splat_bdi:
 	deactivate_locked_super(s);
-	dprintk("<-- nfs_xdev_mount() = %d [splat]\n", error);
+	dprintk("<-- _nfs_xdev_mount() = %d [splat]\n", error);
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(_nfs_xdev_mount);
+
+static struct dentry *
+nfs_xdev_mount(struct file_system_type *fs_type, int flags,
+	       const char *dev_name, void *raw_data)
+{
+	struct nfs_clone_mount *data = raw_data;
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SB(data->sb));
+	return nfs_mod->xdev_mount(flags, dev_name, data);
+}
 
 #ifdef CONFIG_NFS_V4
 
@@ -2937,95 +2946,6 @@ static void nfs4_kill_super(struct super_block *sb)
 	dprintk("<-- %s\n", __func__);
 }
 
-/*
- * Clone an NFS4 server record on xdev traversal (FSID-change)
- */
-static struct dentry *
-nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
-		 const char *dev_name, void *raw_data)
-{
-	struct nfs_clone_mount *data = raw_data;
-	struct super_block *s;
-	struct nfs_server *server;
-	struct dentry *mntroot;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-	};
-	int error;
-
-	dprintk("--> nfs4_xdev_mount()\n");
-
-	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
-	if (IS_ERR(server)) {
-		error = PTR_ERR(server);
-		goto out_err_noserver;
-	}
-	sb_mntdata.server = server;
-
-	if (server->flags & NFS4_MOUNT_UNSHARED)
-		compare_super = NULL;
-
-	/* -o noac implies -o sync */
-	if (server->flags & NFS_MOUNT_NOAC)
-		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
-
-	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs4_fs_type, compare_super, nfs_set_super, &sb_mntdata);
-	if (IS_ERR(s)) {
-		error = PTR_ERR(s);
-		goto out_err_nosb;
-	}
-
-	if (s->s_fs_info != server) {
-		nfs_free_server(server);
-		server = NULL;
-	} else {
-		error = nfs_register(server);
-		if (error)
-			goto error_splat_bdi;
-	}
-
-	if (!s->s_root) {
-		/* initial superblock/root creation */
-		nfs_clone_super(s, data->sb);
-		nfs_fscache_get_super_cookie(s, NULL, data);
-	}
-
-	mntroot = nfs4_get_root(s, data->fh, dev_name);
-	if (IS_ERR(mntroot)) {
-		error = PTR_ERR(mntroot);
-		goto error_splat_super;
-	}
-	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
-		dput(mntroot);
-		error = -ESTALE;
-		goto error_splat_super;
-	}
-
-	s->s_flags |= MS_ACTIVE;
-
-	security_sb_clone_mnt_opts(data->sb, s);
-
-	dprintk("<-- nfs4_xdev_mount() = 0\n");
-	return mntroot;
-
-out_err_nosb:
-	nfs_free_server(server);
-out_err_noserver:
-	dprintk("<-- nfs4_xdev_mount() = %d [error]\n", error);
-	return ERR_PTR(error);
-
-error_splat_super:
-	if (server && !s->s_root)
-		nfs_unregister(server);
-error_splat_bdi:
-	deactivate_locked_super(s);
-	dprintk("<-- nfs4_xdev_mount() = %d [splat]\n", error);
-	return ERR_PTR(error);
-}
-
 static struct dentry *
 nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 			   const char *dev_name, void *raw_data)
-- 
1.7.9.4

