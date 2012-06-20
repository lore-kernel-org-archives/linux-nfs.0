Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:65521 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757976Ab2FTTyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:09 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/10] NFS: Create custom NFS v4 write_inode() function
Date: Wed, 20 Jun 2012 15:53:49 -0400
Message-Id: <1340222029-18027-11-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives pnfs a chance to do a layout commit inside the v4 code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4_fs.h |  3 +++
 fs/nfs/super.c   |  2 +-
 fs/nfs/write.c   | 10 ++++++++--
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a0be2d1a..3696ca7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -202,6 +202,9 @@ struct nfs4_state_maintenance_ops {
 extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
+/* write.c */
+int nfs4_write_inode(struct inode *, struct writeback_control *);
+
 /* nfs4namespace.c */
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5a1c860..9d33fb2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -391,7 +391,7 @@ struct file_system_type nfs4_referral_fs_type = {
 static const struct super_operations nfs4_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
+	.write_inode	= nfs4_write_inode,
 	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.evict_inode	= nfs4_evict_inode,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c11fb00..f312860 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1671,9 +1671,14 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 
 int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
-	int ret;
+	return nfs_commit_unstable_pages(inode, wbc);
+}
+
+#ifdef CONFIG_NFS_V4
+int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc)
+{
+	int ret = nfs_write_inode(inode, wbc);
 
-	ret = nfs_commit_unstable_pages(inode, wbc);
 	if (ret >= 0 && test_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags)) {
 		int status;
 		bool sync = true;
@@ -1687,6 +1692,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 	}
 	return ret;
 }
+#endif
 
 /*
  * flush the inode to disk.
-- 
1.7.11

