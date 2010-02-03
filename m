From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/3] NFS: Fix a umount race
Date: Wed,  3 Feb 2010 15:14:38 -0500
Message-ID: <1265228079-9713-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1265228079-9713-1-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63416 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757839Ab0BCUPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 15:15:08 -0500
In-Reply-To: <1265228079-9713-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we unregister the bdi before kill_anon_super() calls
ida_remove() on our device name.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org
---
 fs/nfs/super.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ce907ef..f1afee4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -243,6 +243,7 @@ static int  nfs_show_stats(struct seq_file *, struct vfsmount *);
 static int nfs_get_sb(struct file_system_type *, int, const char *, void *, struct vfsmount *);
 static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
+static void nfs_put_super(struct super_block *);
 static void nfs_kill_super(struct super_block *);
 static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
@@ -266,6 +267,7 @@ static const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
+	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -335,6 +337,7 @@ static const struct super_operations nfs4_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
+	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs4_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -2258,6 +2261,17 @@ error_splat_super:
 }
 
 /*
+ * Ensure that we unregister the bdi before kill_anon_super
+ * releases the device name
+ */
+static void nfs_put_super(struct super_block *s)
+{
+	struct nfs_server *server = NFS_SB(s);
+
+	bdi_unregister(&server->backing_dev_info);
+}
+
+/*
  * Destroy an NFS2/3 superblock
  */
 static void nfs_kill_super(struct super_block *s)
@@ -2265,7 +2279,6 @@ static void nfs_kill_super(struct super_block *s)
 	struct nfs_server *server = NFS_SB(s);
 
 	kill_anon_super(s);
-	bdi_unregister(&server->backing_dev_info);
 	nfs_fscache_release_super_cookie(s);
 	nfs_free_server(server);
 }
-- 
1.6.6

