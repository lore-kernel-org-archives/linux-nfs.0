Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759154Ab2C3TCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 15:02:47 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 01/10] NFS: Create a single nfs_fill_super() function
Date: Fri, 30 Mar 2012 15:02:28 -0400
Message-Id: <1333134157-17141-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
References: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This can be shared by v2, v3 and v4 in their other common code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   26 ++++++--------------------
 1 file changed, 6 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 37412f7..c9bc86e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2135,16 +2135,18 @@ static void nfs_fill_super(struct super_block *sb,
 
 	sb->s_blocksize_bits = 0;
 	sb->s_blocksize = 0;
-	if (data->bsize)
+	if (data && data->bsize)
 		sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
 
-	if (server->nfs_client->rpc_ops->version == 3) {
+	if (server->nfs_client->rpc_ops->version != 2) {
 		/* The VFS shouldn't apply the umask to mode bits. We will do
 		 * so ourselves when necessary.
 		 */
 		sb->s_flags |= MS_POSIXACL;
 		sb->s_time_gran = 1;
 	}
+	if (server->nfs_client->rpc_ops->version == 4)
+		sb->s_xattr = nfs4_xattr_handlers;
 
 	sb->s_op = &nfs_sops;
  	nfs_initialise_sb(sb);
@@ -2520,22 +2522,6 @@ static void nfs4_clone_super(struct super_block *sb,
 	nfs_initialise_sb(sb);
 }
 
-/*
- * Set up an NFS4 superblock
- */
-static void nfs4_fill_super(struct super_block *sb)
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
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 {
 	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
@@ -2723,7 +2709,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs4_fill_super(s);
+		nfs_fill_super(s, data);
 		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
 	}
 
@@ -3074,7 +3060,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs4_fill_super(s);
+		nfs_fill_super(s, NULL);
 		nfs_fscache_get_super_cookie(s, NULL, data);
 	}
 
-- 
1.7.9.5

