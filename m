Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35719 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbbJXP2x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 11:28:53 -0400
Received: by pasz6 with SMTP id z6so144427212pas.2
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2015 08:28:52 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org,
        Steve French <steve.french@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 1/9] vfs: add COPY_FILE_CLONE_ONLY flag
Date: Sun, 25 Oct 2015 07:17:08 +0800
Message-Id: <1445728636-10109-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
References: <1445728636-10109-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To tell file system not to return partial success in the
.copy_file_range method. This is useful to implement the
clone (or reflink) functionality.

COPY_FILE_CLONE_ONLY is added only to include/linux/fs.h
and thus is not exposed to users. We can replace it with
something like Anna's COPY_FR_REFLINK in uapi/fs.h when
implementing new user visiable APIs like sys_clone.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/read_write.c    | 9 +++++----
 include/linux/fs.h | 3 +++
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index d2da7e4..da11a7f 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1349,8 +1349,9 @@ static ssize_t vfs_copy_fr_copy(struct file *file_in, loff_t pos_in,
 
 /*
  * copy_file_range() differs from regular file read and write in that it
- * specifically allows return partial success.  When it does so is up to
- * the copy_file_range method.
+ * specifically allows returning partial success when COPY_FILE_CLONE_ONLY
+ * is not set in the flags argument, in which case it is up to the file system
+ * to decide whether it wants to do so in the copy_file_range method.
  */
 ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 			    struct file *file_out, loff_t pos_out,
@@ -1360,7 +1361,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	struct inode *inode_out = file_inode(file_out);
 	ssize_t ret;
 
-	if (flags != 0)
+	if (flags && flags != COPY_FILE_CLONE_ONLY)
 		return -EINVAL;
 
 	if (!(file_in->f_mode & FMODE_READ) ||
@@ -1385,7 +1386,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (file_out->f_op->copy_file_range)
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
-	if (ret == -EOPNOTSUPP)
+	if (ret == -EOPNOTSUPP && !(flags & COPY_FILE_CLONE_ONLY))
 		ret = vfs_copy_fr_copy(file_in, pos_in, file_out, pos_out, len);
 
 	if (ret > 0) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6220307..1c430fd 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1610,6 +1610,9 @@ struct block_device_operations;
 
 struct iov_iter;
 
+/* Tell file system not to return partial success in copy_file_range method */
+#define COPY_FILE_CLONE_ONLY		(1 << 0)
+
 struct file_operations {
 	struct module *owner;
 	loff_t (*llseek) (struct file *, loff_t, int);
-- 
1.8.3.1

