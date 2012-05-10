Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5910 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760037Ab2EJPUj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 11:20:39 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 06/14] NFS: Create a common xdev_mount() function
Date: Thu, 10 May 2012 11:19:57 -0400
Message-Id: <1336663205-23886-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
References: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The only difference between nfs_xdev_mount() and nfs4_xdev_mount() is the
unshared flag, so I pass this as an nfs_mount_info parameter so we can
share more code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |  122 +++++++++++++++-----------------------------------------
 1 file changed, 32 insertions(+), 90 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 64a62da..707d1f6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -280,6 +280,7 @@ static match_table_t nfs_vers_tokens = {
 struct nfs_mount_info {
 	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
 	struct nfs_parsed_mount_data *parsed;
+	struct nfs_clone_mount *cloned;
 };
 
 static void nfs_umount_begin(struct super_block *);
@@ -2160,8 +2161,9 @@ static void nfs_fill_super(struct super_block *sb,
  * Finish setting up a cloned NFS2/3 superblock
  */
 static void nfs_clone_super(struct super_block *sb,
-			    const struct super_block *old_sb)
+			    struct nfs_mount_info *mount_info)
 {
+	const struct super_block *old_sb = mount_info->cloned->sb;
 	struct nfs_server *server = NFS_SB(sb);
 
 	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
@@ -2454,13 +2456,13 @@ static void nfs_kill_super(struct super_block *s)
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
@@ -2470,7 +2472,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	};
 	int error;
 
-	dprintk("--> nfs_xdev_mount()\n");
+	dprintk("--> nfs_xdev_mount_common()\n");
 
 	/* create a new volume representation */
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
@@ -2505,7 +2507,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs_clone_super(s, data->sb);
+		mount_info->fill_super(s, mount_info);
 		nfs_get_cache_cookie(s, NULL, data);
 	}
 
@@ -2525,13 +2527,13 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
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
@@ -2539,18 +2541,33 @@ error_splat_super:
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
+		.fill_super = nfs_clone_super,
+		.cloned   = raw_data,
+	};
+	return nfs_xdev_mount_common(&nfs_fs_type, flags, dev_name, &mount_info);
+}
+
 #ifdef CONFIG_NFS_V4
 
 /*
  * Finish setting up a cloned NFS4 superblock
  */
 static void nfs4_clone_super(struct super_block *sb,
-			    const struct super_block *old_sb)
+			     struct nfs_mount_info *mount_info)
 {
+	const struct super_block *old_sb = mount_info->cloned->sb;
 	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
 	sb->s_blocksize = old_sb->s_blocksize;
 	sb->s_maxbytes = old_sb->s_maxbytes;
@@ -2930,86 +2947,11 @@ static struct dentry *
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
+		.fill_super = nfs4_clone_super,
+		.cloned = raw_data,
 	};
-	int error;
-
-	dprintk("--> nfs4_xdev_mount()\n");
-
-	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
-	if (IS_ERR(server)) {
-		error = PTR_ERR(server);
-		goto out_err_noserver;
-	}
-	sb_mntdata.server = server;
-
-	if (server->flags & NFS_MOUNT_UNSHARED)
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
-		nfs4_clone_super(s, data->sb);
-		nfs_get_cache_cookie(s, NULL, data);
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
1.7.10.1

