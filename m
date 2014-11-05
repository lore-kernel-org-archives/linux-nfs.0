Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:47520 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbaKEVO7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 16:14:59 -0500
Received: by mail-qg0-f43.google.com with SMTP id f51so13094386qge.30
        for <linux-nfs@vger.kernel.org>; Wed, 05 Nov 2014 13:14:59 -0800 (PST)
From: Milosz Tanski <milosz@adfin.com>
To: linux-kernel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-aio@kvack.org, Mel Gorman <mgorman@suse.de>,
        Volker Lendecke <Volker.Lendecke@sernet.de>, Tejun Heo <tj@kernel.org>,
        Jeff Moyer <jmoyer@redhat.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-api@vger.kernel.org,
        Michael Kerrisk <mtk.manpages@gmail.com>, linux-arch@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v5 1/7] vfs: Prepare for adding a new preadv/pwritev with user flags.
Date: Wed,  5 Nov 2014 16:14:47 -0500
Message-Id: <e9ce907fbe6ef2d4c6bd48a8fbf5b1c73280bd5b.1415220890.git.milosz@adfin.com>
In-Reply-To: <cover.1415220890.git.milosz@adfin.com>
References: <cover.1415220890.git.milosz@adfin.com>
In-Reply-To: <cover.1415220890.git.milosz@adfin.com>
References: <cover.1415220890.git.milosz@adfin.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Plumbing the flags argument through the vfs code so they can be passed down to
__generic_file_(read/write)_iter function that do the acctual work.

Signed-off-by: Milosz Tanski <milosz@adfin.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Moyer <jmoyer@redhat.com>
---
 drivers/target/target_core_file.c |  6 +++---
 fs/nfsd/vfs.c                     |  4 ++--
 fs/read_write.c                   | 27 +++++++++++++++------------
 fs/splice.c                       |  2 +-
 include/linux/aio.h               |  2 ++
 include/linux/fs.h                |  4 ++--
 6 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index 7d6cdda..58d9a6d 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -350,9 +350,9 @@ static int fd_do_rw(struct se_cmd *cmd, struct scatterlist *sgl,
 	set_fs(get_ds());
 
 	if (is_write)
-		ret = vfs_writev(fd, &iov[0], sgl_nents, &pos);
+		ret = vfs_writev(fd, &iov[0], sgl_nents, &pos, 0);
 	else
-		ret = vfs_readv(fd, &iov[0], sgl_nents, &pos);
+		ret = vfs_readv(fd, &iov[0], sgl_nents, &pos, 0);
 
 	set_fs(old_fs);
 
@@ -528,7 +528,7 @@ fd_execute_write_same(struct se_cmd *cmd)
 
 	old_fs = get_fs();
 	set_fs(get_ds());
-	rc = vfs_writev(f, &iov[0], iov_num, &pos);
+	rc = vfs_writev(f, &iov[0], iov_num, &pos, 0);
 	set_fs(old_fs);
 
 	vfree(iov);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 989129e..ef01c78 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -872,7 +872,7 @@ __be32 nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
 
 	oldfs = get_fs();
 	set_fs(KERNEL_DS);
-	host_err = vfs_readv(file, (struct iovec __user *)vec, vlen, &offset);
+	host_err = vfs_readv(file, (struct iovec __user *)vec, vlen, &offset, 0);
 	set_fs(oldfs);
 	return nfsd_finish_read(file, count, host_err);
 }
@@ -960,7 +960,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
-	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &pos);
+	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &pos, 0);
 	set_fs(oldfs);
 	if (host_err < 0)
 		goto out_nfserr;
diff --git a/fs/read_write.c b/fs/read_write.c
index 7d9318c..94b2d34 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -653,7 +653,8 @@ unsigned long iov_shorten(struct iovec *iov, unsigned long nr_segs, size_t to)
 EXPORT_SYMBOL(iov_shorten);
 
 static ssize_t do_iter_readv_writev(struct file *filp, int rw, const struct iovec *iov,
-		unsigned long nr_segs, size_t len, loff_t *ppos, iter_fn_t fn)
+		unsigned long nr_segs, size_t len, loff_t *ppos, iter_fn_t fn,
+		int flags)
 {
 	struct kiocb kiocb;
 	struct iov_iter iter;
@@ -662,6 +663,7 @@ static ssize_t do_iter_readv_writev(struct file *filp, int rw, const struct iove
 	init_sync_kiocb(&kiocb, filp);
 	kiocb.ki_pos = *ppos;
 	kiocb.ki_nbytes = len;
+	kiocb.ki_rwflags = flags;
 
 	iov_iter_init(&iter, rw, iov, nr_segs, len);
 	ret = fn(&kiocb, &iter);
@@ -800,7 +802,8 @@ out:
 
 static ssize_t do_readv_writev(int type, struct file *file,
 			       const struct iovec __user * uvector,
-			       unsigned long nr_segs, loff_t *pos)
+			       unsigned long nr_segs, loff_t *pos,
+			       int flags)
 {
 	size_t tot_len;
 	struct iovec iovstack[UIO_FASTIOV];
@@ -834,7 +837,7 @@ static ssize_t do_readv_writev(int type, struct file *file,
 
 	if (iter_fn)
 		ret = do_iter_readv_writev(file, type, iov, nr_segs, tot_len,
-						pos, iter_fn);
+						pos, iter_fn, flags);
 	else if (fnv)
 		ret = do_sync_readv_writev(file, iov, nr_segs, tot_len,
 						pos, fnv);
@@ -857,27 +860,27 @@ out:
 }
 
 ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
-		  unsigned long vlen, loff_t *pos)
+		  unsigned long vlen, loff_t *pos, int flags)
 {
 	if (!(file->f_mode & FMODE_READ))
 		return -EBADF;
 	if (!(file->f_mode & FMODE_CAN_READ))
 		return -EINVAL;
 
-	return do_readv_writev(READ, file, vec, vlen, pos);
+	return do_readv_writev(READ, file, vec, vlen, pos, flags);
 }
 
 EXPORT_SYMBOL(vfs_readv);
 
 ssize_t vfs_writev(struct file *file, const struct iovec __user *vec,
-		   unsigned long vlen, loff_t *pos)
+		   unsigned long vlen, loff_t *pos, int flags)
 {
 	if (!(file->f_mode & FMODE_WRITE))
 		return -EBADF;
 	if (!(file->f_mode & FMODE_CAN_WRITE))
 		return -EINVAL;
 
-	return do_readv_writev(WRITE, file, vec, vlen, pos);
+	return do_readv_writev(WRITE, file, vec, vlen, pos, flags);
 }
 
 EXPORT_SYMBOL(vfs_writev);
@@ -890,7 +893,7 @@ SYSCALL_DEFINE3(readv, unsigned long, fd, const struct iovec __user *, vec,
 
 	if (f.file) {
 		loff_t pos = file_pos_read(f.file);
-		ret = vfs_readv(f.file, vec, vlen, &pos);
+		ret = vfs_readv(f.file, vec, vlen, &pos, 0);
 		if (ret >= 0)
 			file_pos_write(f.file, pos);
 		fdput_pos(f);
@@ -910,7 +913,7 @@ SYSCALL_DEFINE3(writev, unsigned long, fd, const struct iovec __user *, vec,
 
 	if (f.file) {
 		loff_t pos = file_pos_read(f.file);
-		ret = vfs_writev(f.file, vec, vlen, &pos);
+		ret = vfs_writev(f.file, vec, vlen, &pos, 0);
 		if (ret >= 0)
 			file_pos_write(f.file, pos);
 		fdput_pos(f);
@@ -942,7 +945,7 @@ SYSCALL_DEFINE5(preadv, unsigned long, fd, const struct iovec __user *, vec,
 	if (f.file) {
 		ret = -ESPIPE;
 		if (f.file->f_mode & FMODE_PREAD)
-			ret = vfs_readv(f.file, vec, vlen, &pos);
+			ret = vfs_readv(f.file, vec, vlen, &pos, 0);
 		fdput(f);
 	}
 
@@ -966,7 +969,7 @@ SYSCALL_DEFINE5(pwritev, unsigned long, fd, const struct iovec __user *, vec,
 	if (f.file) {
 		ret = -ESPIPE;
 		if (f.file->f_mode & FMODE_PWRITE)
-			ret = vfs_writev(f.file, vec, vlen, &pos);
+			ret = vfs_writev(f.file, vec, vlen, &pos, 0);
 		fdput(f);
 	}
 
@@ -1014,7 +1017,7 @@ static ssize_t compat_do_readv_writev(int type, struct file *file,
 
 	if (iter_fn)
 		ret = do_iter_readv_writev(file, type, iov, nr_segs, tot_len,
-						pos, iter_fn);
+						pos, iter_fn, 0);
 	else if (fnv)
 		ret = do_sync_readv_writev(file, iov, nr_segs, tot_len,
 						pos, fnv);
diff --git a/fs/splice.c b/fs/splice.c
index f5cb9ba..9591b9f 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -576,7 +576,7 @@ static ssize_t kernel_readv(struct file *file, const struct iovec *vec,
 	old_fs = get_fs();
 	set_fs(get_ds());
 	/* The cast to a user pointer is valid due to the set_fs() */
-	res = vfs_readv(file, (const struct iovec __user *)vec, vlen, &pos);
+	res = vfs_readv(file, (const struct iovec __user *)vec, vlen, &pos, 0);
 	set_fs(old_fs);
 
 	return res;
diff --git a/include/linux/aio.h b/include/linux/aio.h
index d9c92da..9c1d499 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -52,6 +52,8 @@ struct kiocb {
 	 * this is the underlying eventfd context to deliver events to.
 	 */
 	struct eventfd_ctx	*ki_eventfd;
+
+	int			ki_rwflags;
 };
 
 static inline bool is_sync_kiocb(struct kiocb *kiocb)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a957d43..9ed5711 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1538,9 +1538,9 @@ ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 extern ssize_t vfs_read(struct file *, char __user *, size_t, loff_t *);
 extern ssize_t vfs_write(struct file *, const char __user *, size_t, loff_t *);
 extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
-		unsigned long, loff_t *);
+		unsigned long, loff_t *, int);
 extern ssize_t vfs_writev(struct file *, const struct iovec __user *,
-		unsigned long, loff_t *);
+		unsigned long, loff_t *, int);
 
 struct super_operations {
    	struct inode *(*alloc_inode)(struct super_block *sb);
-- 
1.9.1

