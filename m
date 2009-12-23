From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Wed, 23 Dec 2009 15:21:47 +0100
Message-ID: <1261578107.2606.11.camel@localhost>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost>
	 <1261232747.1947.194.camel@serenity>  <20091222015907.GA6223@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>, Jan Kara <jack@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47632 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803AbZLWOVx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Dec 2009 09:21:53 -0500
In-Reply-To: <20091222015907.GA6223@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-12-22 at 09:59 +0800, Wu Fengguang wrote: 
> 1) normal fs sets I_DIRTY_DATASYNC when extending i_size, however NFS
>    will set the flag for any pages written -- why this trick? To
>    guarantee the call of nfs_commit_inode()? Which unfortunately turns
>    almost every server side NFS write into sync writes..
> 
>  writeback_single_inode:
>     do_writepages
>       nfs_writepages
>         nfs_writepage ----[short time later]---> nfs_writeback_release*
>                                                    nfs_mark_request_commit
>                                                      __mark_inode_dirty(I_DIRTY_DATASYNC);
>                                     
>     if (I_DIRTY_SYNC || I_DIRTY_DATASYNC)  <---- so this will be true for most time
>       write_inode
>         nfs_write_inode
>           nfs_commit_inode


I have been working on a fix for this. We basically do want to ensure
that NFS calls commit (otherwise we're not finished cleaning the dirty
pages), but we want to do it _after_ we've waited for all the writes to
complete. See below...

Trond

------------------------------------------------------------------------------------------------------ 
VFS: Add a new inode state: I_UNSTABLE_PAGES

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Add a new inode state to enable the vfs to commit the nfs unstable pages to
stable storage once the write back of dirty pages is done.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/fs-writeback.c  |   24 ++++++++++++++++++++++--
 fs/nfs/inode.c     |   13 +++++--------
 fs/nfs/write.c     |    2 +-
 include/linux/fs.h |    7 +++++++
 4 files changed, 35 insertions(+), 11 deletions(-)


diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 49bc1b8..c035efe 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -388,6 +388,14 @@ static int write_inode(struct inode *inode, int sync)
 }
 
 /*
+ * Commit the NFS unstable pages.
+ */
+static void commit_unstable_pages(struct inode *inode, int wait)
+{
+	return write_inode(inode, sync);
+}
+
+/*
  * Wait for writeback on an inode to complete.
  */
 static void inode_wait_for_writeback(struct inode *inode)
@@ -474,6 +482,18 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 	}
 
 	spin_lock(&inode_lock);
+	/*
+	 * Special state for cleaning NFS unstable pages
+	 */
+	if (inode->i_state & I_UNSTABLE_PAGES) {
+		int err;
+		inode->i_state &= ~I_UNSTABLE_PAGES;
+		spin_unlock(&inode_lock);
+		err = commit_unstable_pages(inode, wait);
+		if (ret == 0)
+			ret = err;
+		spin_lock(&inode_lock);
+	}
 	inode->i_state &= ~I_SYNC;
 	if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
 		if ((inode->i_state & I_DIRTY_PAGES) && wbc->for_kupdate) {
@@ -481,7 +501,7 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 			 * More pages get dirtied by a fast dirtier.
 			 */
 			goto select_queue;
-		} else if (inode->i_state & I_DIRTY) {
+		} else if (inode->i_state & (I_DIRTY|I_UNSTABLE_PAGES)) {
 			/*
 			 * At least XFS will redirty the inode during the
 			 * writeback (delalloc) and on io completion (isize).
@@ -1050,7 +1070,7 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 
 	spin_lock(&inode_lock);
 	if ((inode->i_state & flags) != flags) {
-		const int was_dirty = inode->i_state & I_DIRTY;
+		const int was_dirty = inode->i_state & (I_DIRTY|I_UNSTABLE_PAGES);
 
 		inode->i_state |= flags;
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index faa0918..4f129b3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -99,17 +99,14 @@ u64 nfs_compat_user_ino64(u64 fileid)
 
 int nfs_write_inode(struct inode *inode, int sync)
 {
+	int flags = 0;
 	int ret;
 
-	if (sync) {
-		ret = filemap_fdatawait(inode->i_mapping);
-		if (ret == 0)
-			ret = nfs_commit_inode(inode, FLUSH_SYNC);
-	} else
-		ret = nfs_commit_inode(inode, 0);
-	if (ret >= 0)
+	if (sync)
+		flags = FLUSH_SYNC;
+	ret = nfs_commit_inode(inode, flags);
+	if (ret > 0)
 		return 0;
-	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return ret;
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d171696..2f74e44 100644
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
diff --git a/include/linux/fs.h b/include/linux/fs.h
index cca1919..ab01af0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1637,6 +1637,8 @@ struct super_operations {
 #define I_CLEAR			64
 #define __I_SYNC		7
 #define I_SYNC			(1 << __I_SYNC)
+#define __I_UNSTABLE_PAGES	9
+#define I_UNSTABLE_PAGES	(1 << __I_UNSTABLE_PAGES)
 
 #define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC | I_DIRTY_PAGES)
 
@@ -1651,6 +1653,11 @@ static inline void mark_inode_dirty_sync(struct inode *inode)
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

