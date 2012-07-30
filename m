Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50661 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754886Ab2G3UFd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:33 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/10] NFS: Split out remaining NFS v4 inode functions
Date: Mon, 30 Jul 2012 16:05:21 -0400
Message-Id: <1343678725-8659-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Somehow I missed this in my previous patch series, but these functions
are only needed by the v4 code and should be moved to a v4-only file.  I
wasn't exactly sure where I should put these functions, so I moved them
into nfs4super.c where I could make them static.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/inode.c     | 23 +----------------------
 fs/nfs/internal.h  |  4 +---
 fs/nfs/nfs4_fs.h   |  3 ---
 fs/nfs/nfs4super.c | 39 +++++++++++++++++++++++++++++++++++++++
 fs/nfs/write.c     | 20 --------------------
 5 files changed, 41 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e8877c8..a6ffa4b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -106,7 +106,7 @@ u64 nfs_compat_user_ino64(u64 fileid)
 	return ino;
 }
 
-static void nfs_clear_inode(struct inode *inode)
+void nfs_clear_inode(struct inode *inode)
 {
 	/*
 	 * The following should never happen...
@@ -1472,27 +1472,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	return -ESTALE;
 }
 
-
-#ifdef CONFIG_NFS_V4
-
-/*
- * Clean out any remaining NFSv4 state that might be left over due
- * to open() calls that passed nfs_atomic_lookup, but failed to call
- * nfs_open().
- */
-void nfs4_evict_inode(struct inode *inode)
-{
-	truncate_inode_pages(&inode->i_data, 0);
-	clear_inode(inode);
-	pnfs_return_layout(inode);
-	pnfs_destroy_layout(NFS_I(inode));
-	/* If we are holding a delegation, return it! */
-	nfs_inode_return_delegation_noreclaim(inode);
-	/* First call standard NFS clear_inode() code */
-	nfs_clear_inode(inode);
-}
-#endif
-
 struct inode *nfs_alloc_inode(struct super_block *sb)
 {
 	struct nfs_inode *nfsi;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 17d1470..4174faf 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -319,10 +319,8 @@ extern struct workqueue_struct *nfsiod_workqueue;
 extern struct inode *nfs_alloc_inode(struct super_block *sb);
 extern void nfs_destroy_inode(struct inode *);
 extern int nfs_write_inode(struct inode *, struct writeback_control *);
+extern void nfs_clear_inode(struct inode *);
 extern void nfs_evict_inode(struct inode *);
-#ifdef CONFIG_NFS_V4
-extern void nfs4_evict_inode(struct inode *);
-#endif
 void nfs_zap_acl_cache(struct inode *inode);
 extern int nfs_wait_bit_killable(void *word);
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 290762f..af8712d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -205,9 +205,6 @@ extern const struct dentry_operations nfs4_dentry_operations;
 int nfs_atomic_open(struct inode *, struct dentry *, struct file *,
 		    unsigned, umode_t, int *);
 
-/* write.c */
-int nfs4_write_inode(struct inode *, struct writeback_control *);
-
 /* nfs4namespace.c */
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index c70e173..1c825f3 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -6,12 +6,16 @@
 #include <linux/nfs_idmap.h>
 #include <linux/nfs4_mount.h>
 #include <linux/nfs_fs.h>
+#include "delegation.h"
 #include "internal.h"
 #include "nfs4_fs.h"
+#include "pnfs.h"
 #include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+static int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc);
+static void nfs4_evict_inode(struct inode *inode);
 static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
@@ -75,6 +79,41 @@ struct nfs_subversion nfs_v4 = {
 	.xattr    = nfs4_xattr_handlers,
 };
 
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
+/*
+ * Clean out any remaining NFSv4 state that might be left over due
+ * to open() calls that passed nfs_atomic_lookup, but failed to call
+ * nfs_open().
+ */
+static void nfs4_evict_inode(struct inode *inode)
+{
+	truncate_inode_pages(&inode->i_data, 0);
+	clear_inode(inode);
+	pnfs_return_layout(inode);
+	pnfs_destroy_layout(NFS_I(inode));
+	/* If we are holding a delegation, return it! */
+	nfs_inode_return_delegation_noreclaim(inode);
+	/* First call standard NFS clear_inode() code */
+	nfs_clear_inode(inode);
+}
+
 /*
  * Get the superblock for the NFS4 root partition
  */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f312860..6ddac54 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1674,26 +1674,6 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 	return nfs_commit_unstable_pages(inode, wbc);
 }
 
-#ifdef CONFIG_NFS_V4
-int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc)
-{
-	int ret = nfs_write_inode(inode, wbc);
-
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
-}
-#endif
-
 /*
  * flush the inode to disk.
  */
-- 
1.7.11.3

