Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8043 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879Ab2EaQWm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 12:22:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH] NFS: Ensure that setattr and getattr wait for O_DIRECT write completion
Date: Thu, 31 May 2012 12:22:33 -0400
Message-Id: <1338481353-23083-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the same mechanism as the block devices are using, but move the
helper functions from fs/direct-io.c into fs/inode.c to remove the
dependency on CONFIG_BLOCK.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Fred Isaman <iisaman@netapp.com>
---
 fs/direct-io.c     |   44 --------------------------------------------
 fs/inode.c         |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/direct.c    |   15 ++++++++++++---
 fs/nfs/inode.c     |    5 ++++-
 fs/nfs/internal.h  |    4 ++++
 include/linux/fs.h |    9 +++------
 6 files changed, 71 insertions(+), 54 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index f4aadd1..0c85fae 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -145,50 +145,6 @@ struct dio {
 
 static struct kmem_cache *dio_cache __read_mostly;
 
-static void __inode_dio_wait(struct inode *inode)
-{
-	wait_queue_head_t *wq = bit_waitqueue(&inode->i_state, __I_DIO_WAKEUP);
-	DEFINE_WAIT_BIT(q, &inode->i_state, __I_DIO_WAKEUP);
-
-	do {
-		prepare_to_wait(wq, &q.wait, TASK_UNINTERRUPTIBLE);
-		if (atomic_read(&inode->i_dio_count))
-			schedule();
-	} while (atomic_read(&inode->i_dio_count));
-	finish_wait(wq, &q.wait);
-}
-
-/**
- * inode_dio_wait - wait for outstanding DIO requests to finish
- * @inode: inode to wait for
- *
- * Waits for all pending direct I/O requests to finish so that we can
- * proceed with a truncate or equivalent operation.
- *
- * Must be called under a lock that serializes taking new references
- * to i_dio_count, usually by inode->i_mutex.
- */
-void inode_dio_wait(struct inode *inode)
-{
-	if (atomic_read(&inode->i_dio_count))
-		__inode_dio_wait(inode);
-}
-EXPORT_SYMBOL(inode_dio_wait);
-
-/*
- * inode_dio_done - signal finish of a direct I/O requests
- * @inode: inode the direct I/O happens on
- *
- * This is called once we've finished processing a direct I/O request,
- * and is used to wake up callers waiting for direct I/O to be quiesced.
- */
-void inode_dio_done(struct inode *inode)
-{
-	if (atomic_dec_and_test(&inode->i_dio_count))
-		wake_up_bit(&inode->i_state, __I_DIO_WAKEUP);
-}
-EXPORT_SYMBOL(inode_dio_done);
-
 /*
  * How many pages are in the queue?
  */
diff --git a/fs/inode.c b/fs/inode.c
index 9f4f5fe..a8138d8 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1741,3 +1741,51 @@ bool inode_owner_or_capable(const struct inode *inode)
 	return false;
 }
 EXPORT_SYMBOL(inode_owner_or_capable);
+
+/*
+ * Direct i/o helper functions
+ */
+static void __inode_dio_wait(struct inode *inode)
+{
+	wait_queue_head_t *wq = bit_waitqueue(&inode->i_state, __I_DIO_WAKEUP);
+	DEFINE_WAIT_BIT(q, &inode->i_state, __I_DIO_WAKEUP);
+
+	do {
+		prepare_to_wait(wq, &q.wait, TASK_UNINTERRUPTIBLE);
+		if (atomic_read(&inode->i_dio_count))
+			schedule();
+	} while (atomic_read(&inode->i_dio_count));
+	finish_wait(wq, &q.wait);
+}
+
+/**
+ * inode_dio_wait - wait for outstanding DIO requests to finish
+ * @inode: inode to wait for
+ *
+ * Waits for all pending direct I/O requests to finish so that we can
+ * proceed with a truncate or equivalent operation.
+ *
+ * Must be called under a lock that serializes taking new references
+ * to i_dio_count, usually by inode->i_mutex.
+ */
+void inode_dio_wait(struct inode *inode)
+{
+	if (atomic_read(&inode->i_dio_count))
+		__inode_dio_wait(inode);
+}
+EXPORT_SYMBOL(inode_dio_wait);
+
+/*
+ * inode_dio_done - signal finish of a direct I/O requests
+ * @inode: inode the direct I/O happens on
+ *
+ * This is called once we've finished processing a direct I/O request,
+ * and is used to wake up callers waiting for direct I/O to be quiesced.
+ */
+void inode_dio_done(struct inode *inode)
+{
+	if (atomic_dec_and_test(&inode->i_dio_count))
+		wake_up_bit(&inode->i_state, __I_DIO_WAKEUP);
+}
+EXPORT_SYMBOL(inode_dio_done);
+
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 23d170b..ad2775d 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -454,6 +454,12 @@ out:
 	return result;
 }
 
+static void nfs_inode_dio_write_done(struct inode *inode)
+{
+	nfs_zap_mapping(inode, inode->i_mapping);
+	inode_dio_done(inode);
+}
+
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
@@ -564,7 +570,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
-			nfs_zap_mapping(dreq->inode, dreq->inode->i_mapping);
+			nfs_inode_dio_write_done(dreq->inode);
 			nfs_direct_complete(dreq);
 	}
 }
@@ -581,7 +587,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
 {
-	nfs_zap_mapping(inode, inode->i_mapping);
+	nfs_inode_dio_write_done(inode);
 	nfs_direct_complete(dreq);
 }
 #endif
@@ -766,14 +772,16 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 					       loff_t pos)
 {
 	struct nfs_pageio_descriptor desc;
+	struct inode *inode = dreq->inode;
 	ssize_t result = 0;
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
-	nfs_pageio_init_write(&desc, dreq->inode, FLUSH_COND_STABLE,
+	nfs_pageio_init_write(&desc, inode, FLUSH_COND_STABLE,
 			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 	get_dreq(dreq);
+	atomic_inc(&inode->i_dio_count);
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
@@ -793,6 +801,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	 * generic layer handle the completion.
 	 */
 	if (requested_bytes == 0) {
+		inode_dio_done(inode);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a6f5fbb..258d38c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -418,8 +418,10 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		return 0;
 
 	/* Write all dirty data */
-	if (S_ISREG(inode->i_mode))
+	if (S_ISREG(inode->i_mode)) {
+		nfs_inode_dio_wait(inode);
 		nfs_wb_all(inode);
+	}
 
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)
@@ -503,6 +505,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 
 	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
+		nfs_inode_dio_wait(inode);
 		err = filemap_write_and_wait(inode->i_mapping);
 		if (err)
 			goto out;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1848a72..18f99ef 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -369,6 +369,10 @@ extern int nfs_migrate_page(struct address_space *,
 /* direct.c */
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq);
+static inline void nfs_inode_dio_wait(struct inode *inode)
+{
+	inode_dio_wait(inode);
+}
 
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8de6755..eef4cd6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2432,8 +2432,6 @@ enum {
 };
 
 void dio_end_io(struct bio *bio, int error);
-void inode_dio_wait(struct inode *inode);
-void inode_dio_done(struct inode *inode);
 
 ssize_t __blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
 	struct block_device *bdev, const struct iovec *iov, loff_t offset,
@@ -2448,12 +2446,11 @@ static inline ssize_t blockdev_direct_IO(int rw, struct kiocb *iocb,
 				    offset, nr_segs, get_block, NULL, NULL,
 				    DIO_LOCKING | DIO_SKIP_HOLES);
 }
-#else
-static inline void inode_dio_wait(struct inode *inode)
-{
-}
 #endif
 
+void inode_dio_wait(struct inode *inode);
+void inode_dio_done(struct inode *inode);
+
 extern const struct file_operations generic_ro_fops;
 
 #define special_file(m) (S_ISCHR(m)||S_ISBLK(m)||S_ISFIFO(m)||S_ISSOCK(m))
-- 
1.7.10.2

