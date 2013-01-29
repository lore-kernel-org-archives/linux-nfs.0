Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:20025 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab3A2QZM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2013 11:25:12 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Zach Brown <zab@zabbo.net>,
        "Maxim V. Patlasov" <mpatlasov@parallels.com>,
        Dave Kleikamp <dave.kleikamp@oracle.com>, Mel Gorman <mgorman@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH V6 22/30] nfs: simplify swap
Date: Tue, 29 Jan 2013 10:23:35 -0600
Message-Id: <1359476623-10544-23-git-send-email-dave.kleikamp@oracle.com>
In-Reply-To: <1359476623-10544-1-git-send-email-dave.kleikamp@oracle.com>
References: <1359476623-10544-1-git-send-email-dave.kleikamp@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

swap_writepage can now call nfs's write_iter f_op, eliminating the need to
implement for the special-case direct_IO a_op. There is no longer a need to
pass the uio flag through the direct write path.

Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
Acked-by: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/direct.c           | 94 ++++++++++++++++-------------------------------
 fs/nfs/file.c             |  4 +-
 include/linux/blk_types.h |  2 -
 include/linux/fs.h        |  2 -
 include/linux/nfs_fs.h    |  4 +-
 mm/page_io.c              | 13 +++----
 6 files changed, 42 insertions(+), 77 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 2b0ebcb..239c2fe 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -118,29 +118,18 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
  * @nr_segs: size of iovec array
  *
  * The presence of this routine in the address space ops vector means
- * the NFS client supports direct I/O. However, for most direct IO, we
- * shunt off direct read and write requests before the VFS gets them,
- * so this method is only ever called for swap.
+ * the NFS client supports direct I/O. However, we shunt off direct
+ * read and write requests before the VFS gets them, so this method
+ * should never be called.
  */
 ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, struct iov_iter *iter,
 		      loff_t pos)
 {
-#ifndef CONFIG_NFS_SWAP
 	dprintk("NFS: nfs_direct_IO (%s) off/no(%Ld/%lu) EINVAL\n",
 			iocb->ki_filp->f_path.dentry->d_name.name,
 			(long long) pos, iter->nr_segs);
 
 	return -EINVAL;
-#else
-	VM_BUG_ON(iocb->ki_left != PAGE_SIZE);
-	VM_BUG_ON(iocb->ki_nbytes != PAGE_SIZE);
-
-	if (rw == READ || rw == KERNEL_READ)
-		return nfs_file_direct_read(iocb, iter, pos,
-				rw == READ ? true : false);
-	return nfs_file_direct_write(iocb, iter, pos,
-				rw == WRITE ? true : false);
-#endif /* CONFIG_NFS_SWAP */
 }
 
 static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
@@ -312,7 +301,7 @@ static const struct nfs_pgio_completion_ops nfs_direct_read_completion_ops = {
  */
 static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *desc,
 						const struct iovec *iov,
-						loff_t pos, bool uio)
+						loff_t pos)
 {
 	struct nfs_direct_req *dreq = desc->pg_dreq;
 	struct nfs_open_context *ctx = dreq->ctx;
@@ -340,20 +329,12 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 					  GFP_KERNEL);
 		if (!pagevec)
 			break;
-		if (uio) {
-			down_read(&current->mm->mmap_sem);
-			result = get_user_pages(current, current->mm, user_addr,
+		down_read(&current->mm->mmap_sem);
+		result = get_user_pages(current, current->mm, user_addr,
 					npages, 1, 0, pagevec, NULL);
-			up_read(&current->mm->mmap_sem);
-			if (result < 0)
-				break;
-		} else {
-			WARN_ON(npages != 1);
-			result = get_kernel_page(user_addr, 1, pagevec);
-			if (WARN_ON(result != 1))
-				break;
-		}
-
+		up_read(&current->mm->mmap_sem);
+		if (result < 0)
+			break;
 		if ((unsigned)result < npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
@@ -403,7 +384,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
 
 static ssize_t nfs_direct_do_schedule_read_iovec(
 		struct nfs_pageio_descriptor *desc, const struct iovec *iov,
-		unsigned long nr_segs, loff_t pos, bool uio)
+		unsigned long nr_segs, loff_t pos)
 {
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
@@ -411,7 +392,7 @@ static ssize_t nfs_direct_do_schedule_read_iovec(
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_read_schedule_segment(desc, vec, pos, uio);
+		result = nfs_direct_read_schedule_segment(desc, vec, pos);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -468,8 +449,7 @@ static ssize_t nfs_direct_do_schedule_read_bvec(
 #endif /* CONFIG_BLOCK */
 
 static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq,
-					struct iov_iter *iter, loff_t pos,
-					bool uio)
+					struct iov_iter *iter, loff_t pos)
 {
 	struct nfs_pageio_descriptor desc;
 	ssize_t result;
@@ -480,10 +460,8 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq,
 	desc.pg_dreq = dreq;
 
 	if (iov_iter_has_iovec(iter)) {
-		if (uio)
-			dreq->flags = NFS_ODIRECT_MARK_DIRTY;
 		result = nfs_direct_do_schedule_read_iovec(&desc,
-				iov_iter_iovec(iter), iter->nr_segs, pos, uio);
+				iov_iter_iovec(iter), iter->nr_segs, pos);
 #ifdef CONFIG_BLOCK
 	} else if (iov_iter_has_bvec(iter)) {
 		result = nfs_direct_do_schedule_read_bvec(&desc,
@@ -509,7 +487,7 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq,
 }
 
 static ssize_t nfs_direct_read(struct kiocb *iocb, struct iov_iter *iter,
-			       loff_t pos, bool uio)
+			       loff_t pos)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -533,7 +511,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 		dreq->iocb = iocb;
 
 	NFS_I(inode)->read_io += iov_iter_count(iter);
-	result = nfs_direct_read_schedule(dreq, iter, pos, uio);
+	result = nfs_direct_read_schedule(dreq, iter, pos);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -698,7 +676,7 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode
  */
 static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *desc,
 						 const struct iovec *iov,
-						 loff_t pos, bool uio)
+						 loff_t pos)
 {
 	struct nfs_direct_req *dreq = desc->pg_dreq;
 	struct nfs_open_context *ctx = dreq->ctx;
@@ -726,19 +704,12 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *d
 		if (!pagevec)
 			break;
 
-		if (uio) {
-			down_read(&current->mm->mmap_sem);
-			result = get_user_pages(current, current->mm, user_addr,
-						npages, 0, 0, pagevec, NULL);
-			up_read(&current->mm->mmap_sem);
-			if (result < 0)
-				break;
-		} else {
-			WARN_ON(npages != 1);
-			result = get_kernel_page(user_addr, 0, pagevec);
-			if (WARN_ON(result != 1))
-				break;
-		}
+		down_read(&current->mm->mmap_sem);
+		result = get_user_pages(current, current->mm, user_addr,
+					npages, 0, 0, pagevec, NULL);
+		up_read(&current->mm->mmap_sem);
+		if (result < 0)
+			break;
 
 		if ((unsigned)result < npages) {
 			bytes = result * PAGE_SIZE;
@@ -869,7 +840,7 @@ static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops = {
 
 static ssize_t nfs_direct_do_schedule_write_iovec(
 		struct nfs_pageio_descriptor *desc, const struct iovec *iov,
-		unsigned long nr_segs, loff_t pos, bool uio)
+		unsigned long nr_segs, loff_t pos)
 {
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
@@ -878,7 +849,7 @@ static ssize_t nfs_direct_do_schedule_write_iovec(
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
 		result = nfs_direct_write_schedule_segment(desc, vec,
-							   pos, uio);
+							   pos);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -936,8 +907,7 @@ static ssize_t nfs_direct_do_schedule_write_bvec(
 #endif /* CONFIG_BLOCK */
 
 static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq,
-					 struct iov_iter *iter, loff_t pos,
-					 bool uio)
+					 struct iov_iter *iter, loff_t pos)
 {
 	struct nfs_pageio_descriptor desc;
 	struct inode *inode = dreq->inode;
@@ -953,7 +923,7 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq,
 
 	if (iov_iter_has_iovec(iter)) {
 		result = nfs_direct_do_schedule_write_iovec(&desc,
-				iov_iter_iovec(iter), iter->nr_segs, pos, uio);
+				iov_iter_iovec(iter), iter->nr_segs, pos);
 #ifdef CONFIG_BLOCK
 	} else if (iov_iter_has_bvec(iter)) {
 		result = nfs_direct_do_schedule_write_bvec(&desc,
@@ -980,7 +950,7 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq,
 }
 
 static ssize_t nfs_direct_write(struct kiocb *iocb, struct iov_iter *iter,
-				loff_t pos, bool uio)
+				loff_t pos)
 {
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
@@ -1003,7 +973,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_write_schedule(dreq, iter, pos, uio);
+	result = nfs_direct_write_schedule(dreq, iter, pos);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
@@ -1033,7 +1003,7 @@ out:
  * cache.
  */
 ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
-			     loff_t pos, bool uio)
+			     loff_t pos)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
@@ -1058,7 +1028,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 
 	task_io_account_read(count);
 
-	retval = nfs_direct_read(iocb, iter, pos, uio);
+	retval = nfs_direct_read(iocb, iter, pos);
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
 
@@ -1088,7 +1058,7 @@ out:
  * is no atomic O_APPEND write facility in the NFS protocol.
  */
 ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
-			      loff_t pos, bool uio)
+			      loff_t pos)
 {
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
@@ -1120,7 +1090,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
 
 	task_io_account_write(count);
 
-	retval = nfs_direct_write(iocb, iter, pos, uio);
+	retval = nfs_direct_write(iocb, iter, pos);
 	if (retval > 0) {
 		struct inode *inode = mapping->host;
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 28119c5..83cbc6c 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -179,7 +179,7 @@ nfs_file_read_iter(struct kiocb *iocb, struct iov_iter *iter, loff_t pos)
 	ssize_t result;
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_read(iocb, iter, pos, true);
+		return nfs_file_direct_read(iocb, iter, pos);
 
 	dprintk("NFS: read_iter(%s/%s, %lu@%lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -619,7 +619,7 @@ ssize_t nfs_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
 	size_t count = iov_iter_count(iter);
 
 	if (iocb->ki_filp->f_flags & O_DIRECT)
-		return nfs_file_direct_write(iocb, iter, pos, true);
+		return nfs_file_direct_write(iocb, iter, pos);
 
 	dprintk("NFS: write_iter(%s/%s, %lu@%lld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index cdf1119..3134079 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -174,7 +174,6 @@ enum rq_flag_bits {
 	__REQ_FLUSH_SEQ,	/* request for flush sequence */
 	__REQ_IO_STAT,		/* account I/O stat */
 	__REQ_MIXED_MERGE,	/* merge of different types, fail separately */
-	__REQ_KERNEL, 		/* direct IO to kernel pages */
 	__REQ_NR_BITS,		/* stops here */
 };
 
@@ -222,6 +221,5 @@ enum rq_flag_bits {
 #define REQ_IO_STAT		(1 << __REQ_IO_STAT)
 #define REQ_MIXED_MERGE		(1 << __REQ_MIXED_MERGE)
 #define REQ_SECURE		(1 << __REQ_SECURE)
-#define REQ_KERNEL		(1 << __REQ_KERNEL)
 
 #endif /* __LINUX_BLK_TYPES_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 31d2e17..679c7cc 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -180,8 +180,6 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define READ			0
 #define WRITE			RW_MASK
 #define READA			RWA_MASK
-#define KERNEL_READ		(READ|REQ_KERNEL)
-#define KERNEL_WRITE		(WRITE|REQ_KERNEL)
 
 #define READ_SYNC		(READ | REQ_SYNC)
 #define WRITE_SYNC		(WRITE | REQ_SYNC | REQ_NOIDLE)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9f8e8a9..6033367 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -446,9 +446,9 @@ extern int nfs3_removexattr (struct dentry *, const char *name);
  */
 extern ssize_t nfs_direct_IO(int, struct kiocb *, struct iov_iter *, loff_t);
 extern ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
-			loff_t pos, bool uio);
+			loff_t pos);
 extern ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
-			loff_t pos, bool uio);
+			loff_t pos);
 
 /*
  * linux/fs/nfs/dir.c
diff --git a/mm/page_io.c b/mm/page_io.c
index 33da274..60a5503 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -203,14 +203,14 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
-		struct address_space *mapping = swap_file->f_mapping;
-		struct iovec iov = {
-			.iov_base = kmap(page),
-			.iov_len  = PAGE_SIZE,
+		struct bio_vec bvec = {
+			.bv_page = kmap(page),
+			.bv_len = PAGE_SIZE,
+			.bv_offset = 0,
 		};
 		struct iov_iter iter;
 
-		iov_iter_init(&iter, &iov, 1, PAGE_SIZE, 0);
+		iov_iter_init_bvec(&iter, &bvec, 1, PAGE_SIZE, 0);
 
 		init_sync_kiocb(&kiocb, swap_file);
 		kiocb.ki_pos = page_file_offset(page);
@@ -218,8 +218,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		kiocb.ki_nbytes = PAGE_SIZE;
 
 		unlock_page(page);
-		ret = mapping->a_ops->direct_IO(KERNEL_WRITE, &kiocb, &iter,
-						kiocb.ki_pos);
+		ret = swap_file->f_op->write_iter(&kiocb, &iter, kiocb.ki_pos);
 		kunmap(page);
 		if (ret == PAGE_SIZE) {
 			count_vm_event(PSWPOUT);
-- 
1.8.1.1

