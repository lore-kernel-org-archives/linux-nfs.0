Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49386 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753845AbdE0IRR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 04:17:17 -0400
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 04/10] fs: remove __do_readv_writev
Date: Sat, 27 May 2017 11:16:48 +0300
Message-Id: <20170527081654.15957-5-hch@lst.de>
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
References: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split it into one helper each for reads vs writes.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c | 60 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 36 insertions(+), 24 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 5cbdf23d924f..f453c9a485b9 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -916,8 +916,8 @@ ssize_t compat_rw_copy_check_uvector(int type,
 }
 #endif
 
-static ssize_t __do_readv_writev(int type, struct file *file,
-				 struct iov_iter *iter, loff_t *pos, int flags)
+static ssize_t do_iter_read(struct file *file, struct iov_iter *iter,
+		loff_t *pos, int flags)
 {
 	size_t tot_len;
 	ssize_t ret = 0;
@@ -925,29 +925,41 @@ static ssize_t __do_readv_writev(int type, struct file *file,
 	tot_len = iov_iter_count(iter);
 	if (!tot_len)
 		goto out;
-	ret = rw_verify_area(type, file, pos, tot_len);
+	ret = rw_verify_area(READ, file, pos, tot_len);
 	if (ret < 0)
-		goto out;
-
-	if (type != READ)
-		file_start_write(file);
+		return ret;
 
-	if ((type == READ && file->f_op->read_iter) ||
-	    (type == WRITE && file->f_op->write_iter))
-		ret = do_iter_readv_writev(file, iter, pos, type, flags);
+	if (file->f_op->read_iter)
+		ret = do_iter_readv_writev(file, iter, pos, READ, flags);
 	else
-		ret = do_loop_readv_writev(file, iter, pos, type, flags);
+		ret = do_loop_readv_writev(file, iter, pos, READ, flags);
+out:
+	if (ret >= 0)
+		fsnotify_access(file);
+	return ret;
+}
 
-	if (type != READ)
-		file_end_write(file);
+static ssize_t do_iter_write(struct file *file, struct iov_iter *iter,
+		loff_t *pos, int flags)
+{
+	size_t tot_len;
+	ssize_t ret = 0;
 
-out:
-	if ((ret + (type == READ)) > 0) {
-		if (type == READ)
-			fsnotify_access(file);
-		else
-			fsnotify_modify(file);
-	}
+	tot_len = iov_iter_count(iter);
+	if (!tot_len)
+		return 0;
+	ret = rw_verify_area(WRITE, file, pos, tot_len);
+	if (ret < 0)
+		return ret;
+
+	file_start_write(file);
+	if (file->f_op->write_iter)
+		ret = do_iter_readv_writev(file, iter, pos, WRITE, flags);
+	else
+		ret = do_loop_readv_writev(file, iter, pos, WRITE, flags);
+	file_end_write(file);
+	if (ret > 0)
+		fsnotify_modify(file);
 	return ret;
 }
 
@@ -968,7 +980,7 @@ ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
 	if (ret < 0)
 		return ret;
 
-	ret = __do_readv_writev(READ, file, &iter, pos, flags);
+	ret = do_iter_read(file, &iter, pos, flags);
 	kfree(iov);
 	return ret;
 }
@@ -991,7 +1003,7 @@ ssize_t vfs_writev(struct file *file, const struct iovec __user *vec,
 	if (ret < 0)
 		return ret;
 
-	ret = __do_readv_writev(WRITE, file, &iter, pos, flags);
+	ret = do_iter_write(file, &iter, pos, flags);
 	kfree(iov);
 	return ret;
 }
@@ -1161,7 +1173,7 @@ static size_t compat_readv(struct file *file,
 	ret = compat_import_iovec(READ, vec, vlen, UIO_FASTIOV, &iov, &iter);
 	if (ret < 0)
 		goto out;
-	ret = __do_readv_writev(READ, file, &iter, pos, flags);
+	ret = do_iter_read(file, &iter, pos, flags);
 	kfree(iov);
 out:
 	if (ret > 0)
@@ -1274,7 +1286,7 @@ static size_t compat_writev(struct file *file,
 	ret = compat_import_iovec(WRITE, vec, vlen, UIO_FASTIOV, &iov, &iter);
 	if (ret < 0)
 		goto out;
-	ret = __do_readv_writev(WRITE, file, &iter, pos, flags);
+	ret = do_iter_write(file, &iter, pos, flags);
 	kfree(iov);
 out:
 	if (ret > 0)
-- 
2.11.0

