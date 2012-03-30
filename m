Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752923Ab2C3TCy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 15:02:54 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 09/10] NFS: Use nfs_fs_mount_common() for xdev mounts
Date: Fri, 30 Mar 2012 15:02:36 -0400
Message-Id: <1333134157-17141-10-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
References: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

At this point, there are only a few small differences between these two
functions.  I can set a few function pointers in the nfs_mount_info
struct to get around these differences.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |  111 +++++++++++++++++++-------------------------------------
 1 file changed, 38 insertions(+), 73 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1247e7e..73e0e4b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2124,6 +2124,8 @@ static inline void nfs_initialise_sb(struct super_block *sb)
 }
 
 struct nfs_mount_info {
+	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
+	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
 	struct nfs_parsed_mount_data *parsed;
 	struct nfs_clone_mount *cloned;
 	unsigned int unshared;
@@ -2133,10 +2135,14 @@ struct nfs_mount_info {
  * Finish setting up an NFS2/3 superblock
  */
 static void nfs_fill_super(struct super_block *sb,
-			   struct nfs_parsed_mount_data *data)
+			   struct nfs_mount_info *mount_info)
 {
+	struct nfs_parsed_mount_data *data = NULL;
 	struct nfs_server *server = NFS_SB(sb);
 
+	if (mount_info)
+		data = mount_info->parsed;
+
 	sb->s_blocksize_bits = 0;
 	sb->s_blocksize = 0;
 	if (data && data->bsize)
@@ -2160,8 +2166,9 @@ static void nfs_fill_super(struct super_block *sb,
  * Finish setting up a cloned NFS2/3/4 superblock
  */
 static void nfs_clone_super(struct super_block *sb,
-			    const struct super_block *old_sb)
+			    struct nfs_mount_info *mount_info)
 {
+	const struct super_block *old_sb = mount_info->cloned->sb;
 	struct nfs_server *server = NFS_SB(sb);
 
 	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
@@ -2290,6 +2297,22 @@ static int nfs_bdi_register(struct nfs_server *server)
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
+static int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
+			       struct nfs_mount_info *mount_info)
+{
+	return security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts);
+}
+
+static int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
+				 struct nfs_mount_info *mount_info)
+{
+	/* clone any lsm security options from the parent to the new sb */
+	security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
+	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
+		return -ESTALE;
+	return 0;
+}
+
 struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
 				   struct nfs_server *server,
 				   int flags, const char *dev_name,
@@ -2333,15 +2356,15 @@ struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs_fill_super(s, mount_info->parsed);
-		nfs_fscache_get_super_cookie(s, mount_info->parsed, NULL);
+		mount_info->fill_super(s, mount_info);
+		nfs_fscache_get_super_cookie(s, mount_info->parsed, mount_info->cloned);
 	}
 
 	mntroot = nfs_get_root(s, mntfh, dev_name);
 	if (IS_ERR(mntroot))
 		goto error_splat_super;
 
-	error = security_sb_set_mnt_opts(s, &mount_info->parsed->lsm_opts);
+	error = mount_info->set_security(s, mntroot, mount_info);
 	if (error)
 		goto error_splat_root;
 
@@ -2371,6 +2394,8 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	struct nfs_server *server;
 	struct nfs_parsed_mount_data *data;
 	struct nfs_mount_info mount_info = {
+		.fill_super = nfs_fill_super,
+		.set_security = nfs_set_sb_security,
 		.unshared = NFS_MOUNT_UNSHARED,
 	};
 	struct nfs_fh *mntfh;
@@ -2445,13 +2470,8 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 		const char *dev_name, struct nfs_mount_info *mount_info)
 {
 	struct nfs_clone_mount *data = mount_info->cloned;
-	struct super_block *s;
 	struct nfs_server *server;
-	struct dentry *mntroot;
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-	};
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int error;
 
 	dprintk("--> nfs_xdev_mount_common()\n");
@@ -2460,71 +2480,14 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
-		goto out_err_noserver;
-	}
-	sb_mntdata.server = server;
-
-	if (server->flags & mount_info->unshared)
-		compare_super = NULL;
-
-	/* -o noac implies -o sync */
-	if (server->flags & NFS_MOUNT_NOAC)
-		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
-
-	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, compare_super, nfs_set_super, &sb_mntdata);
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
+		goto out;
 	}
 
-	s->s_flags |= MS_ACTIVE;
-
-	/* clone any lsm security options from the parent to the new sb */
-	security_sb_clone_mnt_opts(data->sb, s);
-
-	dprintk("<-- nfs_xdev_mount_common() = 0\n");
+	mount_info->fill_super = nfs_clone_super;
+	mount_info->set_security = nfs_clone_sb_security;
+	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, data->fh, mount_info);
+out:
 	return mntroot;
-
-out_err_nosb:
-	nfs_free_server(server);
-out_err_noserver:
-	dprintk("<-- nfs_xdev_mount_common() = %d [error]\n", error);
-	return ERR_PTR(error);
-
-error_splat_super:
-	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
-error_splat_bdi:
-	deactivate_locked_super(s);
-	dprintk("<-- nfs_xdev_mount_common() = %d [splat]\n", error);
-	return ERR_PTR(error);
 }
 
 /*
@@ -2588,6 +2551,8 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 		  const char *dev_name, void *raw_data)
 {
 	struct nfs_mount_info mount_info = {
+		.fill_super = nfs_fill_super,
+		.set_security = nfs_set_sb_security,
 		.parsed = raw_data,
 		.unshared = NFS4_MOUNT_UNSHARED,
 	};
-- 
1.7.9.5

