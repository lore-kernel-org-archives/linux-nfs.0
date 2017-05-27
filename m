Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:41620 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753845AbdE0IRJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 04:17:09 -0400
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 02/10] fs: remove do_readv_writev
Date: Sat, 27 May 2017 11:16:46 +0300
Message-Id: <20170527081654.15957-3-hch@lst.de>
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
References: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

opencode it in both callers to simplify the call stack a bit.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c | 43 +++++++++++++++++++++----------------------
 1 file changed, 21 insertions(+), 22 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 19d4d88fa285..94cb71058098 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -951,51 +951,50 @@ static ssize_t __do_readv_writev(int type, struct file *file,
 	return ret;
 }
 
-static ssize_t do_readv_writev(int type, struct file *file,
-			       const struct iovec __user *uvector,
-			       unsigned long nr_segs, loff_t *pos,
-			       int flags)
+ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
+		  unsigned long vlen, loff_t *pos, int flags)
 {
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov = iovstack;
 	struct iov_iter iter;
 	ssize_t ret;
 
-	ret = import_iovec(type, uvector, nr_segs,
-			   ARRAY_SIZE(iovstack), &iov, &iter);
-	if (ret < 0)
-		return ret;
-
-	ret = __do_readv_writev(type, file, &iter, pos, flags);
-	kfree(iov);
-
-	return ret;
-}
-
-ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
-		  unsigned long vlen, loff_t *pos, int flags)
-{
 	if (!(file->f_mode & FMODE_READ))
 		return -EBADF;
 	if (!(file->f_mode & FMODE_CAN_READ))
 		return -EINVAL;
 
-	return do_readv_writev(READ, file, vec, vlen, pos, flags);
-}
+	ret = import_iovec(READ, vec, vlen, ARRAY_SIZE(iovstack), &iov, &iter);
+	if (ret < 0)
+		return ret;
 
+	ret = __do_readv_writev(READ, file, &iter, pos, flags);
+	kfree(iov);
+	return ret;
+}
 EXPORT_SYMBOL(vfs_readv);
 
 ssize_t vfs_writev(struct file *file, const struct iovec __user *vec,
 		   unsigned long vlen, loff_t *pos, int flags)
 {
+	struct iovec iovstack[UIO_FASTIOV];
+	struct iovec *iov = iovstack;
+	struct iov_iter iter;
+	ssize_t ret;
+
 	if (!(file->f_mode & FMODE_WRITE))
 		return -EBADF;
 	if (!(file->f_mode & FMODE_CAN_WRITE))
 		return -EINVAL;
 
-	return do_readv_writev(WRITE, file, vec, vlen, pos, flags);
-}
+	ret = import_iovec(WRITE, vec, vlen, ARRAY_SIZE(iovstack), &iov, &iter);
+	if (ret < 0)
+		return ret;
 
+	ret = __do_readv_writev(WRITE, file, &iter, pos, flags);
+	kfree(iov);
+	return ret;
+}
 EXPORT_SYMBOL(vfs_writev);
 
 static ssize_t do_readv(unsigned long fd, const struct iovec __user *vec,
-- 
2.11.0

