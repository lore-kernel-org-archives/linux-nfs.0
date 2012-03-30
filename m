Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756709Ab2C3TCs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 15:02:48 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 02/10] NFS: Create a single nfs_clone_super() function
Date: Fri, 30 Mar 2012 15:02:29 -0400
Message-Id: <1333134157-17141-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
References: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 and v3 shared a function for this, but v4 implemented something very
slightly different.  Might as well share code whenever possible...

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
Please ignore the earlier version of this patch from last week.  This one
should work better...

 fs/nfs/super.c |   31 ++++++-------------------------
 1 file changed, 6 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c9bc86e..1358dc1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2153,7 +2153,7 @@ static void nfs_fill_super(struct super_block *sb,
 }
 
 /*
- * Finish setting up a cloned NFS2/3 superblock
+ * Finish setting up a cloned NFS2/3/4 superblock
  */
 static void nfs_clone_super(struct super_block *sb,
 			    const struct super_block *old_sb)
@@ -2163,16 +2163,17 @@ static void nfs_clone_super(struct super_block *sb,
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
 
@@ -2502,26 +2503,6 @@ error_splat_bdi:
 
 #ifdef CONFIG_NFS_V4
 
-/*
- * Finish setting up a cloned NFS4 superblock
- */
-static void nfs4_clone_super(struct super_block *sb,
-			    const struct super_block *old_sb)
-{
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
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 {
 	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
@@ -2969,7 +2950,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs4_clone_super(s, data->sb);
+		nfs_clone_super(s, data->sb);
 		nfs_fscache_get_super_cookie(s, NULL, data);
 	}
 
-- 
1.7.9.5

