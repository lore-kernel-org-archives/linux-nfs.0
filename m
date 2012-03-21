Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5056 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759040Ab2CUPVW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:22 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 19/23] NFS: Create custom NFS v4 write_inode() function
Date: Wed, 21 Mar 2012 11:20:49 -0400
Message-Id: <1332343253-24970-20-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives pnfs a chance to do a layout commit inside the v4 code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4super.c |   20 +++++++++++++++++++-
 fs/nfs/write.c     |   16 +---------------
 2 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index f463a2c..2a3974d 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -27,6 +27,24 @@ static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_typ
 	int flags, const char *dev_name, void *raw_data);
 static void nfs4_kill_super(struct super_block *sb);
 
+static int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc)
+{
+	int ret = nfs_write_inode(inode, wbc);
+
+	if (ret >= 0 && test_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags)) {
+		int status;
+		bool sync = true;
+
+		if (wbc->sync_mode == WB_SYNC_NONE)
+			sync = false;
+
+		status = pnfs_layoutcommit_inode(inode, sync);
+		if (status < 0)
+			return status;
+	}
+	return ret;
+}
+
 /*
  * Clean out any remaining NFSv4 state that might be left over due
  * to open() calls that passed nfs_atomic_lookup, but failed to call
@@ -87,7 +105,7 @@ struct file_system_type nfs4_referral_fs_type = {
 static const struct super_operations nfs4_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
+	.write_inode	= nfs4_write_inode,
 	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.evict_inode	= nfs4_evict_inode,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e4a72d6..5b28bbe 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1620,21 +1620,7 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 
 int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
-	int ret;
-
-	ret = nfs_commit_unstable_pages(inode, wbc);
-	if (ret >= 0 && test_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags)) {
-		int status;
-		bool sync = true;
-
-		if (wbc->sync_mode == WB_SYNC_NONE)
-			sync = false;
-
-		status = pnfs_layoutcommit_inode(inode, sync);
-		if (status < 0)
-			return status;
-	}
-	return ret;
+	return nfs_commit_unstable_pages(inode, wbc);
 }
 
 /*
-- 
1.7.9.4

