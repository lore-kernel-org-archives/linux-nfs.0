Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4387 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126Ab2GPUjc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 16:39:32 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/12] NFS: Create a single nfs_clone_super() function
Date: Mon, 16 Jul 2012 16:39:19 -0400
Message-Id: <1342471161-22452-11-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 and v3 shared a function for this, but v4 implemented something only
slightly different.  Might as well share code whenever possible...

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c | 32 ++++++--------------------------
 1 file changed, 6 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 9bad4e7..ca3c0e8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2218,7 +2218,7 @@ static void nfs_fill_super(struct super_block *sb,
 }
 
 /*
- * Finish setting up a cloned NFS2/3 superblock
+ * Finish setting up a cloned NFS2/3/4 superblock
  */
 static void nfs_clone_super(struct super_block *sb,
 			    struct nfs_mount_info *mount_info)
@@ -2229,16 +2229,17 @@ static void nfs_clone_super(struct super_block *sb,
 	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
 	sb->s_blocksize = old_sb->s_blocksize;
 	sb->s_maxbytes = old_sb->s_maxbytes;
+	sb->s_xattr = old_sb->s_xattr;
+	sb->s_op = old_sb->s_op;
+	sb->s_time_gran = 1;
 
-	if (server->nfs_client->rpc_ops->version == 3) {
+	if (server->nfs_client->rpc_ops->version != 2) {
 		/* The VFS shouldn't apply the umask to mode bits. We will do
 		 * so ourselves when necessary.
 		 */
 		sb->s_flags |= MS_POSIXACL;
-		sb->s_time_gran = 1;
 	}
 
-	sb->s_op = old_sb->s_op;
  	nfs_initialise_sb(sb);
 }
 
@@ -2580,27 +2581,6 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 #ifdef CONFIG_NFS_V4
 
 /*
- * Finish setting up a cloned NFS4 superblock
- */
-static void nfs4_clone_super(struct super_block *sb,
-			     struct nfs_mount_info *mount_info)
-{
-	const struct super_block *old_sb = mount_info->cloned->sb;
-	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
-	sb->s_blocksize = old_sb->s_blocksize;
-	sb->s_maxbytes = old_sb->s_maxbytes;
-	sb->s_time_gran = 1;
-	sb->s_op = old_sb->s_op;
-	/*
-	 * The VFS shouldn't apply the umask to mode bits. We will do
-	 * so ourselves when necessary.
-	 */
-	sb->s_flags  |= MS_POSIXACL;
-	sb->s_xattr  = old_sb->s_xattr;
-	nfs_initialise_sb(sb);
-}
-
-/*
  * Set up an NFS4 superblock
  */
 static void nfs4_fill_super(struct super_block *sb,
@@ -2883,7 +2863,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 		 const char *dev_name, void *raw_data)
 {
 	struct nfs_mount_info mount_info = {
-		.fill_super = nfs4_clone_super,
+		.fill_super = nfs_clone_super,
 		.set_security = nfs_clone_sb_security,
 		.cloned = raw_data,
 	};
-- 
1.7.11.2

