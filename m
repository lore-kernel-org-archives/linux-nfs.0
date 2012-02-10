Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753647Ab2BJWCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:15 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 06/21] NFS: Create a single nfs_clone_super() function
Date: Fri, 10 Feb 2012 17:01:50 -0500
Message-Id: <1328911325-1566-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 and v3 shared a function for this, but v4 implemented something
different.  When I looked closer at the v4 implementation, I found it
was basically doing the same thing as v3.  Might as well share the code
whenever possible...

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   33 +++++++--------------------------
 1 files changed, 7 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c1e8994..ea1d932 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2089,7 +2089,7 @@ static void nfs_fill_super(struct super_block *sb,
 }
 
 /*
- * Finish setting up a cloned NFS2/3 superblock
+ * Finish setting up a cloned NFS2/3/4 superblock
  */
 static void nfs_clone_super(struct super_block *sb,
 			    const struct super_block *old_sb)
@@ -2099,17 +2099,18 @@ static void nfs_clone_super(struct super_block *sb,
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
- 	nfs_initialise_sb(sb);
+	nfs_initialise_sb(sb);
 }
 
 static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
@@ -2462,26 +2463,6 @@ error_splat_bdi:
 #ifdef CONFIG_NFS_V4
 
 /*
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
-/*
  * Set up an NFS4 superblock
  */
 static void nfs4_fill_super(struct super_block *sb)
@@ -2950,7 +2931,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs4_clone_super(s, data->sb);
+		nfs_clone_super(s, data->sb);
 		nfs_fscache_get_super_cookie(s, NULL, data);
 	}
 
-- 
1.7.9

