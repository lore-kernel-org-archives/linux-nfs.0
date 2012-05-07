Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62209 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756467Ab2EGOsu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 May 2012 10:48:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Ensure that setattr and getattr wait for O_DIRECT write completion
Date: Mon,  7 May 2012 10:48:32 -0400
Message-Id: <1336402112-9227-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the same mechanism as the block devices are using, but define
our own copy of those functions if !CONFIG_BLOCK.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/direct.c   |   47 ++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/inode.c    |    5 ++++-
 fs/nfs/internal.h |    1 +
 3 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index aab3016..023c469 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -106,6 +106,44 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
 	return atomic_dec_and_test(&dreq->io_count);
 }
 
+#ifndef CONFIG_BLOCK
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
+static void inode_dio_wait(struct inode *inode)
+{
+	if (atomic_read(&inode->i_dio_count))
+		__inode_dio_wait(inode);
+}
+
+static void inode_dio_done(struct inode *inode)
+{
+	if (atomic_dec_and_test(&inode->i_dio_count))
+		wake_up_bit(&inode->i_state, __I_DIO_WAKEUP);
+}
+#endif
+
+void nfs_inode_dio_wait(struct inode *inode)
+{
+	inode_dio_wait(inode);
+}
+
+static void nfs_inode_dio_write_done(struct inode *inode)
+{
+	nfs_zap_mapping(inode, inode->i_mapping);
+	inode_dio_done(inode);
+}
+
 /**
  * nfs_direct_IO - NFS address space operation for direct I/O
  * @rw: direction (read or write)
@@ -565,7 +603,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
-			nfs_zap_mapping(dreq->inode, dreq->inode->i_mapping);
+			nfs_inode_dio_write_done(dreq->inode);
 			nfs_direct_complete(dreq);
 	}
 }
@@ -582,7 +620,7 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
 {
-	nfs_zap_mapping(inode, inode->i_mapping);
+	nfs_inode_dio_write_done(inode);
 	nfs_direct_complete(dreq);
 }
 #endif
@@ -771,14 +809,16 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
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
@@ -797,6 +837,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	 * generic layer handle the completion.
 	 */
 	if (requested_bytes == 0) {
+		inode_dio_done(inode);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9f17cd1..6663bc2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -416,8 +416,10 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		return 0;
 
 	/* Write all dirty data */
-	if (S_ISREG(inode->i_mode))
+	if (S_ISREG(inode->i_mode)) {
+		nfs_inode_dio_wait(inode);
 		nfs_wb_all(inode);
+	}
 
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)
@@ -501,6 +503,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 
 	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
+		nfs_inode_dio_wait(inode);
 		err = filemap_write_and_wait(inode->i_mapping);
 		if (err)
 			goto out;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1855e8f..5d4bde8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -368,6 +368,7 @@ extern int nfs_migrate_page(struct address_space *,
 /* direct.c */
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq);
+void nfs_inode_dio_wait(struct inode *inode);
 
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
-- 
1.7.7.6

