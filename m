Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:13094 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309AbbHaTuW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2015 15:50:22 -0400
From: <andros@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <Anna.Schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 01/16] VFS: Separate cross fs check from vfs_copy_file_range
Date: Mon, 31 Aug 2015 15:49:51 -0400
Message-ID: <1441050606-40897-2-git-send-email-andros@netapp.com>
In-Reply-To: <1441050606-40897-1-git-send-email-andros@netapp.com>
References: <1441050606-40897-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Move the high level vfs_copy_file_range entrypoint restriction that limits
copy offloading to files on the same mount and super to
a helper function to be called by copy_file_range methods.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/read_write.c    | 34 +++++++++++++++++++++++-----------
 include/linux/fs.h |  1 +
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index e564a6b..da28205 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1330,6 +1330,29 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
 #endif
 
 /*
+ * copy_offload_same_fs(). Test for file system copy_file_range methods
+ * that support only copy offloading to files on the same mount point
+ * and super (and not to the same file).
+ */
+ssize_t copy_offload_same_fs(struct file *file_in, struct file *file_out)
+{
+	struct inode *inode_in = file_inode(file_in);
+	struct inode *inode_out = file_inode(file_out);
+
+	/* forbid copy not on the same mount point and super */
+	if (inode_in->i_sb != inode_out->i_sb ||
+	    file_in->f_path.mnt != file_out->f_path.mnt)
+		return -EXDEV;
+
+	/* forbid ranges in the same file */
+	if (inode_in == inode_out)
+		return -EINVAL;
+
+	return 0;
+}
+EXPORT_SYMBOL(copy_offload_same_fs);
+
+/*
  * copy_file_range() differs from regular file read and write in that it
  * specifically allows return partial success.  When it does so is up to
  * the copy_file_range method.
@@ -1339,7 +1362,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 			    size_t len, int flags)
 {
 	struct inode *inode_in;
-	struct inode *inode_out;
 	ssize_t ret;
 
 	if (flags)
@@ -1362,22 +1384,12 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 		return -EINVAL;
 
 	inode_in = file_inode(file_in);
-	inode_out = file_inode(file_out);
 
 	/* make sure offsets don't wrap and the input is inside i_size */
 	if (pos_in + len < pos_in || pos_out + len < pos_out ||
 	    pos_in + len > i_size_read(inode_in))
 		return -EINVAL;
 
-	/* this could be relaxed once a method supports cross-fs copies */
-	if (inode_in->i_sb != inode_out->i_sb ||
-	    file_in->f_path.mnt != file_out->f_path.mnt)
-		return -EXDEV;
-
-	/* forbid ranges in the same file */
-	if (inode_in == inode_out)
-		return -EINVAL;
-
 	ret = mnt_want_write_file(file_out);
 	if (ret)
 		return ret;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c97aed8..1c29f2f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1685,6 +1685,7 @@ extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *);
 extern ssize_t vfs_writev(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *);
+extern ssize_t copy_offload_same_fs(struct file *, struct file *);
 extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
 				   loff_t, size_t, int);
 
-- 
1.8.3.1

