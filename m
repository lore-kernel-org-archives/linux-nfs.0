Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754656Ab2G3UFc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:32 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/10] NFS: Pass super operations and xattr handlers in the nfs_subversion
Date: Mon, 30 Jul 2012 16:05:20 -0400
Message-Id: <1343678725-8659-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I can set all variables in the nfs_fill_super() function, allowing me to
remove the nfs4_fill_super() function.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h  |  1 +
 fs/nfs/nfs.h       |  2 ++
 fs/nfs/nfs2super.c |  1 +
 fs/nfs/nfs3super.c |  1 +
 fs/nfs/nfs4super.c | 24 +++---------------------
 fs/nfs/super.c     |  9 +++++----
 6 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2151baf..17d1470 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -327,6 +327,7 @@ void nfs_zap_acl_cache(struct inode *inode);
 extern int nfs_wait_bit_killable(void *word);
 
 /* super.c */
+extern const struct super_operations nfs_sops;
 extern struct file_system_type nfs_fs_type;
 extern struct file_system_type nfs_xdev_fs_type;
 #ifdef CONFIG_NFS_V4
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index ac10b9e..9f502a0 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -16,6 +16,8 @@ struct nfs_subversion {
 	struct file_system_type *nfs_fs;	/* NFS filesystem type */
 	const struct rpc_version *rpc_vers;	/* NFS version information */
 	const struct nfs_rpc_ops *rpc_ops;	/* NFS operations */
+	const struct super_operations *sops;	/* NFS Super operations */
+	const struct xattr_handler **xattr;	/* NFS xattr handlers */
 	struct list_head list;		/* List of NFS versions */
 };
 
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index cef06d4..a9fb69d 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -11,6 +11,7 @@ static struct nfs_subversion nfs_v2 = {
 	.nfs_fs   = &nfs_fs_type,
 	.rpc_vers = &nfs_version2,
 	.rpc_ops  = &nfs_v2_clientops,
+	.sops     = &nfs_sops,
 };
 
 int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index f815cf3..8378090 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -11,6 +11,7 @@ static struct nfs_subversion nfs_v3 = {
 	.nfs_fs   = &nfs_fs_type,
 	.rpc_vers = &nfs_version3,
 	.rpc_ops  = &nfs_v3_clientops,
+	.sops     = &nfs_sops,
 };
 
 int __init init_nfs_v3(void)
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index a628362..c70e173 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -71,26 +71,11 @@ struct nfs_subversion nfs_v4 = {
 	.nfs_fs   = &nfs4_fs_type,
 	.rpc_vers = &nfs_version4,
 	.rpc_ops  = &nfs_v4_clientops,
+	.sops     = &nfs4_sops,
+	.xattr    = nfs4_xattr_handlers,
 };
 
 /*
- * Set up an NFS4 superblock
- */
-static void nfs4_fill_super(struct super_block *sb,
-			    struct nfs_mount_info *mount_info)
-{
-	sb->s_time_gran = 1;
-	sb->s_op = &nfs4_sops;
-	/*
-	 * The VFS shouldn't apply the umask to mode bits. We will do
-	 * so ourselves when necessary.
-	 */
-	sb->s_flags  |= MS_POSIXACL;
-	sb->s_xattr = nfs4_xattr_handlers;
-	nfs_initialise_sb(sb);
-}
-
-/*
  * Get the superblock for the NFS4 root partition
  */
 static struct dentry *
@@ -101,7 +86,6 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 	struct nfs_server *server;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 
-	mount_info->fill_super = nfs4_fill_super;
 	mount_info->set_security = nfs_set_sb_security;
 
 	/* Get a volume representation */
@@ -236,8 +220,6 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 
 	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
 
-	mount_info->fill_super = nfs4_fill_super;
-
 	export_path = data->nfs_server.export_path;
 	data->nfs_server.export_path = "/";
 	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
@@ -257,7 +239,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 			   const char *dev_name, void *raw_data)
 {
 	struct nfs_mount_info mount_info = {
-		.fill_super = nfs4_fill_super,
+		.fill_super = nfs_fill_super,
 		.set_security = nfs_clone_sb_security,
 		.cloned = raw_data,
 	};
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a5f9fb3..a275d19 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -298,7 +298,7 @@ struct file_system_type nfs_xdev_fs_type = {
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
-static const struct super_operations nfs_sops = {
+const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
@@ -2105,10 +2105,12 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 
 	sb->s_blocksize_bits = 0;
 	sb->s_blocksize = 0;
-	if (data->bsize)
+	sb->s_xattr = server->nfs_client->cl_nfs_mod->xattr;
+	sb->s_op = server->nfs_client->cl_nfs_mod->sops;
+	if (data && data->bsize)
 		sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
 
-	if (server->nfs_client->rpc_ops->version == 3) {
+	if (server->nfs_client->rpc_ops->version != 2) {
 		/* The VFS shouldn't apply the umask to mode bits. We will do
 		 * so ourselves when necessary.
 		 */
@@ -2116,7 +2118,6 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 		sb->s_time_gran = 1;
 	}
 
-	sb->s_op = &nfs_sops;
  	nfs_initialise_sb(sb);
 }
 
-- 
1.7.11.3

