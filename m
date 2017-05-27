Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49256 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753920AbdE0IRa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 04:17:30 -0400
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 05/10] fs: move more code into do_iter_read/do_iter_write
Date: Sat, 27 May 2017 11:16:49 +0300
Message-Id: <20170527081654.15957-6-hch@lst.de>
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
References: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The checks for the permissions and can read / write flags are common
for the callers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c | 73 ++++++++++++++++++++++-----------------------------------
 1 file changed, 28 insertions(+), 45 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index f453c9a485b9..64b61a032a56 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -922,6 +922,11 @@ static ssize_t do_iter_read(struct file *file, struct iov_iter *iter,
 	size_t tot_len;
 	ssize_t ret = 0;
 
+	if (!(file->f_mode & FMODE_READ))
+		return -EBADF;
+	if (!(file->f_mode & FMODE_CAN_READ))
+		return -EINVAL;
+
 	tot_len = iov_iter_count(iter);
 	if (!tot_len)
 		goto out;
@@ -945,6 +950,11 @@ static ssize_t do_iter_write(struct file *file, struct iov_iter *iter,
 	size_t tot_len;
 	ssize_t ret = 0;
 
+	if (!(file->f_mode & FMODE_WRITE))
+		return -EBADF;
+	if (!(file->f_mode & FMODE_CAN_WRITE))
+		return -EINVAL;
+
 	tot_len = iov_iter_count(iter);
 	if (!tot_len)
 		return 0;
@@ -971,17 +981,12 @@ ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
 	struct iov_iter iter;
 	ssize_t ret;
 
-	if (!(file->f_mode & FMODE_READ))
-		return -EBADF;
-	if (!(file->f_mode & FMODE_CAN_READ))
-		return -EINVAL;
-
 	ret = import_iovec(READ, vec, vlen, ARRAY_SIZE(iovstack), &iov, &iter);
-	if (ret < 0)
-		return ret;
+	if (ret >= 0) {
+		ret = do_iter_read(file, &iter, pos, flags);
+		kfree(iov);
+	}
 
-	ret = do_iter_read(file, &iter, pos, flags);
-	kfree(iov);
 	return ret;
 }
 EXPORT_SYMBOL(vfs_readv);
@@ -994,17 +999,11 @@ ssize_t vfs_writev(struct file *file, const struct iovec __user *vec,
 	struct iov_iter iter;
 	ssize_t ret;
 
-	if (!(file->f_mode & FMODE_WRITE))
-		return -EBADF;
-	if (!(file->f_mode & FMODE_CAN_WRITE))
-		return -EINVAL;
-
 	ret = import_iovec(WRITE, vec, vlen, ARRAY_SIZE(iovstack), &iov, &iter);
-	if (ret < 0)
-		return ret;
-
-	ret = do_iter_write(file, &iter, pos, flags);
-	kfree(iov);
+	if (ret >= 0) {
+		ret = do_iter_write(file, &iter, pos, flags);
+		kfree(iov);
+	}
 	return ret;
 }
 EXPORT_SYMBOL(vfs_writev);
@@ -1161,21 +1160,13 @@ static size_t compat_readv(struct file *file,
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov = iovstack;
 	struct iov_iter iter;
-	ssize_t ret = -EBADF;
-
-	if (!(file->f_mode & FMODE_READ))
-		goto out;
-
-	ret = -EINVAL;
-	if (!(file->f_mode & FMODE_CAN_READ))
-		goto out;
+	ssize_t ret;
 
 	ret = compat_import_iovec(READ, vec, vlen, UIO_FASTIOV, &iov, &iter);
-	if (ret < 0)
-		goto out;
-	ret = do_iter_read(file, &iter, pos, flags);
-	kfree(iov);
-out:
+	if (ret >= 0) {
+		ret = do_iter_read(file, &iter, pos, flags);
+		kfree(iov);
+	}
 	if (ret > 0)
 		add_rchar(current, ret);
 	inc_syscr(current);
@@ -1274,21 +1265,13 @@ static size_t compat_writev(struct file *file,
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov = iovstack;
 	struct iov_iter iter;
-	ssize_t ret = -EBADF;
-
-	if (!(file->f_mode & FMODE_WRITE))
-		goto out;
-
-	ret = -EINVAL;
-	if (!(file->f_mode & FMODE_CAN_WRITE))
-		goto out;
+	ssize_t ret;
 
 	ret = compat_import_iovec(WRITE, vec, vlen, UIO_FASTIOV, &iov, &iter);
-	if (ret < 0)
-		goto out;
-	ret = do_iter_write(file, &iter, pos, flags);
-	kfree(iov);
-out:
+	if (ret >= 0) {
+		ret = do_iter_write(file, &iter, pos, flags);
+		kfree(iov);
+	}
 	if (ret > 0)
 		add_wchar(current, ret);
 	inc_syscw(current);
-- 
2.11.0

