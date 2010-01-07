From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/5] VFS: Ensure that writeback_single_inode() commits
 unstable writes
Date: Wed, 06 Jan 2010 23:53:31 -0500
Message-ID: <20100107045331.5986.87344.stgit@localhost.localdomain>
References: <20100107045330.5986.55090.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1365 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776Ab0AGFAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 00:00:44 -0500
In-Reply-To: <20100107045330.5986.55090.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the call to do_writepages() succeeded in starting writeback, we do not
know whether or not we will need to COMMIT any unstable writes until after
the write RPC calls are finished. Currently, we assume that at least one
write RPC call will have finished, and set I_DIRTY_DATASYNC by the time
do_writepages is done, so that write_inode() is triggered.

In order to ensure reliable operation (i.e. ensure that a single call to
writeback_single_inode() with WB_SYNC_ALL set suffices to ensure that pages
are on disk) we need to first wait for filemap_fdatawait() to complete,
then test for unstable pages.

Since NFS is currently the only filesystem that has unstable pages, we can
add a new inode state I_UNSTABLE_PAGES that NFS alone will set. When set,
this will trigger a callback to a new address_space_operation to call the
COMMIT.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Acked-by: Jan Kara <jack@suse.cz>
---

 fs/fs-writeback.c  |   31 ++++++++++++++++++++++++++++++-
 fs/nfs/file.c      |    1 +
 fs/nfs/inode.c     |   16 ----------------
 fs/nfs/internal.h  |    3 ++-
 fs/nfs/super.c     |    2 --
 fs/nfs/write.c     |   33 ++++++++++++++++++++++++++++++++-
 include/linux/fs.h |    9 +++++++++
 7 files changed, 74 insertions(+), 21 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1a7c42c..3640769 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -389,6 +389,17 @@ static int write_inode(struct inode *inode, int sync)
 }
 
 /*
+ * Commit the NFS unstable pages.
+ */
+static int commit_unstable_pages(struct address_space *mapping,
+		struct writeback_control *wbc)
+{
+	if (mapping->a_ops && mapping->a_ops->commit_unstable_pages)
+		return mapping->a_ops->commit_unstable_pages(mapping, wbc);
+	return 0;
+}
+
+/*
  * Wait for writeback on an inode to complete.
  */
 static void inode_wait_for_writeback(struct inode *inode)
@@ -475,6 +486,18 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 	}
 
 	spin_lock(&inode_lock);
+	/*
+	 * Special state for cleaning NFS unstable pages
+	 */
+	if (inode->i_state & I_UNSTABLE_PAGES) {
+		int err;
+		inode->i_state &= ~I_UNSTABLE_PAGES;
+		spin_unlock(&inode_lock);
+		err = commit_unstable_pages(mapping, wbc);
+		if (ret == 0)
+			ret = err;
+		spin_lock(&inode_lock);
+	}
 	inode->i_state &= ~I_SYNC;
 	if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
 		if ((inode->i_state & I_DIRTY_PAGES) && wbc->for_kupdate) {
@@ -533,6 +556,12 @@ select_queue:
 				inode->i_state |= I_DIRTY_PAGES;
 				redirty_tail(inode);
 			}
+		} else if (inode->i_state & I_UNSTABLE_PAGES) {
+			/*
+			 * The inode has got yet more unstable pages to
+			 * commit. Requeue...
+			 */
+			redirty_tail(inode);
 		} else if (atomic_read(&inode->i_count)) {
 			/*
 			 * The inode is clean, inuse
@@ -1051,7 +1080,7 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 
 	spin_lock(&inode_lock);
 	if ((inode->i_state & flags) != flags) {
-		const int was_dirty = inode->i_state & I_DIRTY;
+		const int was_dirty = inode->i_state & (I_DIRTY|I_UNSTABLE_PAGES);
 
 		inode->i_state |= flags;
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6b89132..67e50ac 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -526,6 +526,7 @@ const struct address_space_operations nfs_file_aops = {
 	.migratepage = nfs_migrate_page,
 	.launder_page = nfs_launder_page,
 	.error_remove_page = generic_error_remove_page,
+	.commit_unstable_pages = nfs_commit_unstable_pages,
 };
 
 /*
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index faa0918..8341709 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -97,22 +97,6 @@ u64 nfs_compat_user_ino64(u64 fileid)
 	return ino;
 }
 
-int nfs_write_inode(struct inode *inode, int sync)
-{
-	int ret;
-
-	if (sync) {
-		ret = filemap_fdatawait(inode->i_mapping);
-		if (ret == 0)
-			ret = nfs_commit_inode(inode, FLUSH_SYNC);
-	} else
-		ret = nfs_commit_inode(inode, 0);
-	if (ret >= 0)
-		return 0;
-	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
-	return ret;
-}
-
 void nfs_clear_inode(struct inode *inode)
 {
 	/*
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 29e464d..7bb326f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -211,7 +211,6 @@ extern int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask);
 extern struct workqueue_struct *nfsiod_workqueue;
 extern struct inode *nfs_alloc_inode(struct super_block *sb);
 extern void nfs_destroy_inode(struct inode *);
-extern int nfs_write_inode(struct inode *,int);
 extern void nfs_clear_inode(struct inode *);
 #ifdef CONFIG_NFS_V4
 extern void nfs4_clear_inode(struct inode *);
@@ -253,6 +252,8 @@ extern int nfs4_path_walk(struct nfs_server *server,
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
+extern int nfs_commit_unstable_pages(struct address_space *mapping,
+		struct writeback_control *wbc);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ce907ef..805c1a0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -265,7 +265,6 @@ struct file_system_type nfs_xdev_fs_type = {
 static const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -334,7 +333,6 @@ struct file_system_type nfs4_referral_fs_type = {
 static const struct super_operations nfs4_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs4_clear_inode,
 	.umount_begin	= nfs_umount_begin,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d171696..910be28 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -441,7 +441,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 	spin_unlock(&inode->i_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
-	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+	mark_inode_unstable_pages(inode);
 }
 
 static int
@@ -1406,11 +1406,42 @@ int nfs_commit_inode(struct inode *inode, int how)
 	}
 	return res;
 }
+
+int nfs_commit_unstable_pages(struct address_space *mapping,
+		struct writeback_control *wbc)
+{
+	struct inode *inode = mapping->host;
+	int flags = FLUSH_SYNC;
+	int ret;
+
+	/* Don't commit yet if this is a non-blocking flush and there are
+	 * outstanding writes for this mapping.
+	 */
+	if (wbc->sync_mode != WB_SYNC_ALL &&
+	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
+		    NFS_PAGE_TAG_LOCKED)) {
+		mark_inode_unstable_pages(inode);
+		return 0;
+	}
+	if (wbc->nonblocking)
+		flags = 0;
+	ret = nfs_commit_inode(inode, flags);
+	if (ret > 0)
+		ret = 0;
+	return ret;
+}
+
 #else
 static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 {
 	return 0;
 }
+
+int nfs_commit_unstable_pages(struct address_space *mapping,
+		struct writeback_control *wbc)
+{
+	return 0;
+}
 #endif
 
 long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_control *wbc, int how)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9147ca8..de594b3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -602,6 +602,8 @@ struct address_space_operations {
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
+	int (*commit_unstable_pages)(struct address_space *,
+			struct writeback_control *);
 };
 
 /*
@@ -1635,6 +1637,8 @@ struct super_operations {
 #define I_CLEAR			64
 #define __I_SYNC		7
 #define I_SYNC			(1 << __I_SYNC)
+#define __I_UNSTABLE_PAGES	8
+#define I_UNSTABLE_PAGES	(1 << __I_UNSTABLE_PAGES)
 
 #define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC | I_DIRTY_PAGES)
 
@@ -1649,6 +1653,11 @@ static inline void mark_inode_dirty_sync(struct inode *inode)
 	__mark_inode_dirty(inode, I_DIRTY_SYNC);
 }
 
+static inline void mark_inode_unstable_pages(struct inode *inode)
+{
+	__mark_inode_dirty(inode, I_UNSTABLE_PAGES);
+}
+
 /**
  * inc_nlink - directly increment an inode's link count
  * @inode: inode

