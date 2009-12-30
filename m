From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Wed, 30 Dec 2009 17:22:48 +0100
Message-ID: <1262190168.7332.6.camel@localhost>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost>
	 <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost>
	 <1261578107.2606.11.camel@localhost> <20091223180551.GD3159@quack.suse.cz>
	 <1261595574.6775.2.camel@localhost> <20091224025228.GA12477@localhost>
	 <1261656281.3596.1.camel@localhost>  <20091225055617.GA8595@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jan Kara <jack@suse.cz>, Steve Rago <sar@nec-labs.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752450AbZL3QW6@vger.kernel.org>
In-Reply-To: <20091225055617.GA8595@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-25 at 13:56 +0800, Wu Fengguang wrote: 
> On Thu, Dec 24, 2009 at 08:04:41PM +0800, Trond Myklebust wrote:
> > That would indicate that we're cycling through writeback_single_inode()
> > more than once. Why?
> 
> Yes. The above sequence can happen for a 4MB sized dirty file.
> The first COMMIT is done by L547, while the second COMMIT will be
> scheduled either by __mark_inode_dirty(), or scheduled by L583
> (depending on the time ACKs for L543 but missed L547 arrives:
> if an ACK missed L578, the inode will be queued into b_dirty list,
> but if any ACK arrives between L547 and L578, the inode will enter
> b_more_io_wait, which is a to-be-introduced new dirty list). 
> 
>          537         dirty = inode->i_state & I_DIRTY;
>          538         inode->i_state |= I_SYNC;
>          539         inode->i_state &= ~I_DIRTY;
>          540 
>          541         spin_unlock(&inode_lock);
>          542 
> ==>      543         ret = do_writepages(mapping, wbc);
>          544 
>          545         /* Don't write the inode if only I_DIRTY_PAGES was set */
>          546         if (dirty & (I_DIRTY_SYNC | I_DIRTY_DATASYNC)) {
> ==>      547                 int err = write_inode(inode, wait);
>          548                 if (ret == 0)
>          549                         ret = err;
>          550         }
>          551 
>          552         if (wait) {
>          553                 int err = filemap_fdatawait(mapping);
>          554                 if (ret == 0)
>          555                         ret = err;
>          556         }
>          557 
>          558         spin_lock(&inode_lock);
>          559         inode->i_state &= ~I_SYNC;
>          560         if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
>          561                 if (mapping_tagged(mapping, PAGECACHE_TAG_DIRTY)) {
>          562                         /*
>          563                          * We didn't write back all the pages.  nfs_writepages()
>          564                          * sometimes bales out without doing anything.
>          565                          */
>          566                         inode->i_state |= I_DIRTY_PAGES;
>          567                         if (wbc->nr_to_write <= 0) {
>          568                                 /*
>          569                                  * slice used up: queue for next turn
>          570                                  */
>          571                                 requeue_io(inode);
>          572                         } else {
>          573                                 /*
>          574                                  * somehow blocked: retry later
>          575                                  */
>          576                                 requeue_io_wait(inode);
>          577                         }
> ==>      578                 } else if (inode->i_state & I_DIRTY) {
>          579                         /*
>          580                          * At least XFS will redirty the inode during the
>          581                          * writeback (delalloc) and on io completion (isize).
>          582                          */
> ==>      583                         requeue_io_wait(inode);

Hi Fengguang,

Apologies for having taken time over this. Do you see any improvement
with the appended variant instead? It adds a new address_space_operation
in order to do the commit. Furthermore, it ignores the commit request if
the caller is just doing a WB_SYNC_NONE background flush, waiting
instead for the ensuing WB_SYNC_ALL request...

Cheers
  Trond
-------------------------------------------------------------------------------------------------------- 
VFS: Add a new inode state: I_UNSTABLE_PAGES

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Add a new inode state to enable the vfs to commit the nfs unstable pages to
stable storage once the write back of dirty pages is done.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/fs-writeback.c  |   27 +++++++++++++++++++++++++--
 fs/nfs/file.c      |    1 +
 fs/nfs/inode.c     |   16 ----------------
 fs/nfs/internal.h  |    3 ++-
 fs/nfs/super.c     |    2 --
 fs/nfs/write.c     |   29 ++++++++++++++++++++++++++++-
 include/linux/fs.h |    9 +++++++++
 7 files changed, 65 insertions(+), 22 deletions(-)


diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 49bc1b8..24bc817 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -388,6 +388,17 @@ static int write_inode(struct inode *inode, int sync)
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
@@ -474,6 +485,18 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
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
@@ -481,7 +504,7 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 			 * More pages get dirtied by a fast dirtier.
 			 */
 			goto select_queue;
-		} else if (inode->i_state & I_DIRTY) {
+		} else if (inode->i_state & (I_DIRTY|I_UNSTABLE_PAGES)) {
 			/*
 			 * At least XFS will redirty the inode during the
 			 * writeback (delalloc) and on io completion (isize).
@@ -1050,7 +1073,7 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 
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
index d171696..187f3a9 100644
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
@@ -1406,11 +1406,38 @@ int nfs_commit_inode(struct inode *inode, int how)
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
+	/* Don't commit if this is just a non-blocking flush */
+	if (wbc->sync_mode != WB_SYNC_ALL) {
+		mark_inode_unstable_pages(inode);
+		return 0;
+	}
+	if (wbc->nonblocking)
+		flags = 0;
+	ret = nfs_commit_inode(inode, flags);
+	if (ret > 0)
+		return 0;
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
index 9147ca8..ea0b7a3 100644
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
+#define __I_UNSTABLE_PAGES	9
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
