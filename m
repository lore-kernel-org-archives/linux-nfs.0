Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:44514 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753845AbdE0IRN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 May 2017 04:17:13 -0400
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 03/10] fs: remove do_compat_readv_writev
Date: Sat, 27 May 2017 11:16:47 +0300
Message-Id: <20170527081654.15957-4-hch@lst.de>
In-Reply-To: <20170527081654.15957-1-hch@lst.de>
References: <20170527081654.15957-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

opencode it in both callers to simplify the call stack a bit.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c | 42 ++++++++++++++++--------------------------
 1 file changed, 16 insertions(+), 26 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 94cb71058098..5cbdf23d924f 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1142,32 +1142,13 @@ SYSCALL_DEFINE6(pwritev2, unsigned long, fd, const struct iovec __user *, vec,
 }
 
 #ifdef CONFIG_COMPAT
-
-static ssize_t compat_do_readv_writev(int type, struct file *file,
-			       const struct compat_iovec __user *uvector,
-			       unsigned long nr_segs, loff_t *pos,
-			       int flags)
-{
-	struct iovec iovstack[UIO_FASTIOV];
-	struct iovec *iov = iovstack;
-	struct iov_iter iter;
-	ssize_t ret;
-
-	ret = compat_import_iovec(type, uvector, nr_segs,
-				  UIO_FASTIOV, &iov, &iter);
-	if (ret < 0)
-		return ret;
-
-	ret = __do_readv_writev(type, file, &iter, pos, flags);
-	kfree(iov);
-
-	return ret;
-}
-
 static size_t compat_readv(struct file *file,
 			   const struct compat_iovec __user *vec,
 			   unsigned long vlen, loff_t *pos, int flags)
 {
+	struct iovec iovstack[UIO_FASTIOV];
+	struct iovec *iov = iovstack;
+	struct iov_iter iter;
 	ssize_t ret = -EBADF;
 
 	if (!(file->f_mode & FMODE_READ))
@@ -1177,8 +1158,11 @@ static size_t compat_readv(struct file *file,
 	if (!(file->f_mode & FMODE_CAN_READ))
 		goto out;
 
-	ret = compat_do_readv_writev(READ, file, vec, vlen, pos, flags);
-
+	ret = compat_import_iovec(READ, vec, vlen, UIO_FASTIOV, &iov, &iter);
+	if (ret < 0)
+		goto out;
+	ret = __do_readv_writev(READ, file, &iter, pos, flags);
+	kfree(iov);
 out:
 	if (ret > 0)
 		add_rchar(current, ret);
@@ -1275,6 +1259,9 @@ static size_t compat_writev(struct file *file,
 			    const struct compat_iovec __user *vec,
 			    unsigned long vlen, loff_t *pos, int flags)
 {
+	struct iovec iovstack[UIO_FASTIOV];
+	struct iovec *iov = iovstack;
+	struct iov_iter iter;
 	ssize_t ret = -EBADF;
 
 	if (!(file->f_mode & FMODE_WRITE))
@@ -1284,8 +1271,11 @@ static size_t compat_writev(struct file *file,
 	if (!(file->f_mode & FMODE_CAN_WRITE))
 		goto out;
 
-	ret = compat_do_readv_writev(WRITE, file, vec, vlen, pos, flags);
-
+	ret = compat_import_iovec(WRITE, vec, vlen, UIO_FASTIOV, &iov, &iter);
+	if (ret < 0)
+		goto out;
+	ret = __do_readv_writev(WRITE, file, &iter, pos, flags);
+	kfree(iov);
 out:
 	if (ret > 0)
 		add_wchar(current, ret);
-- 
2.11.0

