Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:47933 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753944AbdE0IRe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 04:17:34 -0400
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 08/10]  fs: implement vfs_iter_write using do_iter_write
Date: Sat, 27 May 2017 11:16:52 +0300
Message-Id: <20170527081654.15957-9-hch@lst.de>
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
References: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

De-dupliate some code and allow for passing the flags argument to
vfs_iter_write.  Additionally it now properly updates timestamps.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/block/loop.c              |  2 +-
 drivers/target/target_core_file.c |  4 ++--
 fs/coda/file.c                    |  2 +-
 fs/read_write.c                   | 29 +++++++++--------------------
 fs/splice.c                       |  2 +-
 include/linux/fs.h                |  3 ++-
 6 files changed, 16 insertions(+), 26 deletions(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 1070e851ad9a..1802142cca4b 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -266,7 +266,7 @@ static int lo_write_bvec(struct file *file, struct bio_vec *bvec, loff_t *ppos)
 	iov_iter_bvec(&i, ITER_BVEC, bvec, 1, bvec->bv_len);
 
 	file_start_write(file);
-	bw = vfs_iter_write(file, &i, ppos);
+	bw = vfs_iter_write(file, &i, ppos, 0);
 	file_end_write(file);
 
 	if (likely(bw ==  bvec->bv_len))
diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index 2befc0d7fdb1..e921948415c7 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -273,7 +273,7 @@ static int fd_do_rw(struct se_cmd *cmd, struct file *fd,
 
 	iov_iter_bvec(&iter, ITER_BVEC, bvec, sgl_nents, len);
 	if (is_write)
-		ret = vfs_iter_write(fd, &iter, &pos);
+		ret = vfs_iter_write(fd, &iter, &pos, 0);
 	else
 		ret = vfs_iter_read(fd, &iter, &pos, 0);
 
@@ -409,7 +409,7 @@ fd_execute_write_same(struct se_cmd *cmd)
 	}
 
 	iov_iter_bvec(&iter, ITER_BVEC, bvec, nolb, len);
-	ret = vfs_iter_write(fd_dev->fd_file, &iter, &pos);
+	ret = vfs_iter_write(fd_dev->fd_file, &iter, &pos, 0);
 
 	kfree(bvec);
 	if (ret < 0 || ret != len) {
diff --git a/fs/coda/file.c b/fs/coda/file.c
index f1102822bcfd..363402fcb3ed 100644
--- a/fs/coda/file.c
+++ b/fs/coda/file.c
@@ -51,7 +51,7 @@ coda_file_write_iter(struct kiocb *iocb, struct iov_iter *to)
 	host_file = cfi->cfi_container;
 	file_start_write(host_file);
 	inode_lock(coda_inode);
-	ret = vfs_iter_write(cfi->cfi_container, to, &iocb->ki_pos);
+	ret = vfs_iter_write(cfi->cfi_container, to, &iocb->ki_pos, 0);
 	coda_inode->i_size = file_inode(host_file)->i_size;
 	coda_inode->i_blocks = (coda_inode->i_size + 511) >> 9;
 	coda_inode->i_mtime = coda_inode->i_ctime = current_time(coda_inode);
diff --git a/fs/read_write.c b/fs/read_write.c
index 620ac6f9dacb..f48caaf93216 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -356,26 +356,6 @@ SYSCALL_DEFINE5(llseek, unsigned int, fd, unsigned long, offset_high,
 }
 #endif
 
-ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos)
-{
-	struct kiocb kiocb;
-	ssize_t ret;
-
-	if (!file->f_op->write_iter)
-		return -EINVAL;
-
-	init_sync_kiocb(&kiocb, file);
-	kiocb.ki_pos = *ppos;
-
-	iter->type |= WRITE;
-	ret = call_write_iter(file, &kiocb, iter);
-	BUG_ON(ret == -EIOCBQUEUED);
-	if (ret > 0)
-		*ppos = kiocb.ki_pos;
-	return ret;
-}
-EXPORT_SYMBOL(vfs_iter_write);
-
 int rw_verify_area(int read_write, struct file *file, const loff_t *ppos, size_t count)
 {
 	struct inode *inode;
@@ -973,6 +953,15 @@ static ssize_t do_iter_write(struct file *file, struct iov_iter *iter,
 	return ret;
 }
 
+ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos,
+		int flags)
+{
+	if (!file->f_op->write_iter)
+		return -EINVAL;
+	return do_iter_write(file, iter, ppos, flags);
+}
+EXPORT_SYMBOL(vfs_iter_write);
+
 ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
 		  unsigned long vlen, loff_t *pos, int flags)
 {
diff --git a/fs/splice.c b/fs/splice.c
index 540c4a44756c..ae41201d0325 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -762,7 +762,7 @@ iter_file_splice_write(struct pipe_inode_info *pipe, struct file *out,
 
 		iov_iter_bvec(&from, ITER_BVEC | WRITE, array, n,
 			      sd.total_len - left);
-		ret = vfs_iter_write(out, &from, &sd.pos);
+		ret = vfs_iter_write(out, &from, &sd.pos, 0);
 		if (ret <= 0)
 			break;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f6a4f4efb32..c67f1f8ee789 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2791,7 +2791,8 @@ extern ssize_t generic_perform_write(struct file *, struct iov_iter *, loff_t);
 
 ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos,
 		int flags);
-ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos);
+ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos,
+		int flags);
 
 /* fs/block_dev.c */
 extern ssize_t blkdev_read_iter(struct kiocb *iocb, struct iov_iter *to);
-- 
2.11.0

