Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760509Ab2C3TCv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 15:02:51 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 08/10] NFS: Create a common xdev_mount() function
Date: Fri, 30 Mar 2012 15:02:35 -0400
Message-Id: <1333134157-17141-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
References: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The only difference between nfs_xdev_mount() and nfs4_xdev_mount() is the
unshared flag, so I pass this as an nfs_mount_info parameter so we can
share more code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |  116 ++++++++++++++------------------------------------------
 1 file changed, 28 insertions(+), 88 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index cf8a6b2..1247e7e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2125,6 +2125,7 @@ static inline void nfs_initialise_sb(struct super_block *sb)
 
 struct nfs_mount_info {
 	struct nfs_parsed_mount_data *parsed;
+	struct nfs_clone_mount *cloned;
 	unsigned int unshared;
 };
 
@@ -2437,13 +2438,13 @@ static void nfs_kill_super(struct super_block *s)
 }
 
 /*
- * Clone an NFS2/3 server record on xdev traversal (FSID-change)
+ * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
  */
 static struct dentry *
-nfs_xdev_mount(struct file_system_type *fs_type, int flags,
-		const char *dev_name, void *raw_data)
+nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
+		const char *dev_name, struct nfs_mount_info *mount_info)
 {
-	struct nfs_clone_mount *data = raw_data;
+	struct nfs_clone_mount *data = mount_info->cloned;
 	struct super_block *s;
 	struct nfs_server *server;
 	struct dentry *mntroot;
@@ -2453,7 +2454,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	};
 	int error;
 
-	dprintk("--> nfs_xdev_mount()\n");
+	dprintk("--> nfs_xdev_mount_common()\n");
 
 	/* create a new volume representation */
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
@@ -2463,7 +2464,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	}
 	sb_mntdata.server = server;
 
-	if (server->flags & NFS_MOUNT_UNSHARED)
+	if (server->flags & mount_info->unshared)
 		compare_super = NULL;
 
 	/* -o noac implies -o sync */
@@ -2508,13 +2509,13 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	/* clone any lsm security options from the parent to the new sb */
 	security_sb_clone_mnt_opts(data->sb, s);
 
-	dprintk("<-- nfs_xdev_mount() = 0\n");
+	dprintk("<-- nfs_xdev_mount_common() = 0\n");
 	return mntroot;
 
 out_err_nosb:
 	nfs_free_server(server);
 out_err_noserver:
-	dprintk("<-- nfs_xdev_mount() = %d [error]\n", error);
+	dprintk("<-- nfs_xdev_mount_common() = %d [error]\n", error);
 	return ERR_PTR(error);
 
 error_splat_super:
@@ -2522,10 +2523,24 @@ error_splat_super:
 		bdi_unregister(&server->backing_dev_info);
 error_splat_bdi:
 	deactivate_locked_super(s);
-	dprintk("<-- nfs_xdev_mount() = %d [splat]\n", error);
+	dprintk("<-- nfs_xdev_mount_common() = %d [splat]\n", error);
 	return ERR_PTR(error);
 }
 
+/*
+ * Clone an NFS2/3 server record on xdev traversal (FSID-change)
+ */
+static struct dentry *
+nfs_xdev_mount(struct file_system_type *fs_type, int flags,
+		const char *dev_name, void *raw_data)
+{
+	struct nfs_mount_info mount_info = {
+		.cloned   = raw_data,
+		.unshared = NFS_MOUNT_UNSHARED,
+	};
+	return nfs_xdev_mount_common(&nfs_fs_type, flags, dev_name, &mount_info);
+}
+
 #ifdef CONFIG_NFS_V4
 
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
@@ -2743,86 +2758,11 @@ static struct dentry *
 nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 		 const char *dev_name, void *raw_data)
 {
-	struct nfs_clone_mount *data = raw_data;
-	struct super_block *s;
-	struct nfs_server *server;
-	struct dentry *mntroot;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
+	struct nfs_mount_info mount_info = {
+		.cloned = raw_data,
+		.unshared = NFS4_MOUNT_UNSHARED,
 	};
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
-		error = nfs_bdi_register(server);
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
-	mntroot = nfs_get_root(s, data->fh, dev_name);
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
-		bdi_unregister(&server->backing_dev_info);
-error_splat_bdi:
-	deactivate_locked_super(s);
-	dprintk("<-- nfs4_xdev_mount() = %d [splat]\n", error);
-	return ERR_PTR(error);
+	return nfs_xdev_mount_common(&nfs4_fs_type, flags, dev_name, &mount_info);
 }
 
 static struct dentry *
-- 
1.7.9.5

