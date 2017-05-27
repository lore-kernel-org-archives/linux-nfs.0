Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:46224 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753845AbdE0IR3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 04:17:29 -0400
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 07/10] fs: implement vfs_iter_read using do_iter_read
Date: Sat, 27 May 2017 11:16:51 +0300
Message-Id: <20170527081654.15957-8-hch@lst.de>
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
References: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

De-dupliate some code and allow for passing the flags argument to
vfs_iter_read.  Additional it properly updates atime now.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/block/loop.c              |  4 ++--
 drivers/target/target_core_file.c |  2 +-
 fs/coda/file.c                    |  2 +-
 fs/read_write.c                   | 29 +++++++++--------------------
 include/linux/fs.h                |  3 ++-
 5 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 28d932906f24..1070e851ad9a 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -342,7 +342,7 @@ static int lo_read_simple(struct loop_device *lo, struct request *rq,
 
 	rq_for_each_segment(bvec, rq, iter) {
 		iov_iter_bvec(&i, ITER_BVEC, &bvec, 1, bvec.bv_len);
-		len = vfs_iter_read(lo->lo_backing_file, &i, &pos);
+		len = vfs_iter_read(lo->lo_backing_file, &i, &pos, 0);
 		if (len < 0)
 			return len;
 
@@ -383,7 +383,7 @@ static int lo_read_transfer(struct loop_device *lo, struct request *rq,
 		b.bv_len = bvec.bv_len;
 
 		iov_iter_bvec(&i, ITER_BVEC, &b, 1, b.bv_len);
-		len = vfs_iter_read(lo->lo_backing_file, &i, &pos);
+		len = vfs_iter_read(lo->lo_backing_file, &i, &pos, 0);
 		if (len < 0) {
 			ret = len;
 			goto out_free_page;
diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index 73b8f93a5fef..2befc0d7fdb1 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -275,7 +275,7 @@ static int fd_do_rw(struct se_cmd *cmd, struct file *fd,
 	if (is_write)
 		ret = vfs_iter_write(fd, &iter, &pos);
 	else
-		ret = vfs_iter_read(fd, &iter, &pos);
+		ret = vfs_iter_read(fd, &iter, &pos, 0);
 
 	if (is_write) {
 		if (ret < 0 || ret != data_length) {
diff --git a/fs/coda/file.c b/fs/coda/file.c
index 9d956cd6d46f..f1102822bcfd 100644
--- a/fs/coda/file.c
+++ b/fs/coda/file.c
@@ -34,7 +34,7 @@ coda_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 
 	BUG_ON(!cfi || cfi->cfi_magic != CODA_MAGIC);
 
-	return vfs_iter_read(cfi->cfi_container, to, &iocb->ki_pos);
+	return vfs_iter_read(cfi->cfi_container, to, &iocb->ki_pos, 0);
 }
 
 static ssize_t
diff --git a/fs/read_write.c b/fs/read_write.c
index 60c64a996ab2..620ac6f9dacb 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -356,26 +356,6 @@ SYSCALL_DEFINE5(llseek, unsigned int, fd, unsigned long, offset_high,
 }
 #endif
 
-ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos)
-{
-	struct kiocb kiocb;
-	ssize_t ret;
-
-	if (!file->f_op->read_iter)
-		return -EINVAL;
-
-	init_sync_kiocb(&kiocb, file);
-	kiocb.ki_pos = *ppos;
-
-	iter->type |= READ;
-	ret = call_read_iter(file, &kiocb, iter);
-	BUG_ON(ret == -EIOCBQUEUED);
-	if (ret > 0)
-		*ppos = kiocb.ki_pos;
-	return ret;
-}
-EXPORT_SYMBOL(vfs_iter_read);
-
 ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos)
 {
 	struct kiocb kiocb;
@@ -955,6 +935,15 @@ static ssize_t do_iter_read(struct file *file, struct iov_iter *iter,
 	return ret;
 }
 
+ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos,
+		int flags)
+{
+	if (!file->f_op->read_iter)
+		return -EINVAL;
+	return do_iter_read(file, iter, ppos, flags);
+}
+EXPORT_SYMBOL(vfs_iter_read);
+
 static ssize_t do_iter_write(struct file *file, struct iov_iter *iter,
 		loff_t *pos, int flags)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 803e5a9b2654..3f6a4f4efb32 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2789,7 +2789,8 @@ extern ssize_t generic_file_write_iter(struct kiocb *, struct iov_iter *);
 extern ssize_t generic_file_direct_write(struct kiocb *, struct iov_iter *);
 extern ssize_t generic_perform_write(struct file *, struct iov_iter *, loff_t);
 
-ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos);
+ssize_t vfs_iter_read(struct file *file, struct iov_iter *iter, loff_t *ppos,
+		int flags);
 ssize_t vfs_iter_write(struct file *file, struct iov_iter *iter, loff_t *ppos);
 
 /* fs/block_dev.c */
-- 
2.11.0

