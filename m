Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:10583 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760607AbbIDURZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 16:17:25 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v1 8/8] vfs: Fall back on splice if no copy function defined
Date: Fri, 4 Sep 2015 16:17:02 -0400
Message-ID: <1441397823-1203-9-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS server will need a fallback for filesystems that don't have any
kind of copy acceleration yet, and it should be generally useful to have
an in-kernel copy to avoid lots of switches between kernel and
user space.  Users who only want a reflink can pass the COPY_REFLINK
flag to disable the fallback.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/read_write.c           | 16 ++++++++++++----
 include/linux/copy.h      |  6 ++++++
 include/uapi/linux/Kbuild |  1 +
 include/uapi/linux/copy.h |  6 ++++++
 4 files changed, 25 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/copy.h
 create mode 100644 include/uapi/linux/copy.h

diff --git a/fs/read_write.c b/fs/read_write.c
index 9dafb7f..bd7e7e2 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -7,6 +7,7 @@
 #include <linux/slab.h> 
 #include <linux/stat.h>
 #include <linux/fcntl.h>
+#include <linux/copy.h>
 #include <linux/file.h>
 #include <linux/uio.h>
 #include <linux/fsnotify.h>
@@ -1342,7 +1343,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	struct inode *inode_out;
 	ssize_t ret;
 
-	if (flags)
+	if (!((flags == 0) || (flags == COPY_REFLINK)))
 		return -EINVAL;
 
 	/* copy_file_range allows full ssize_t len, ignoring MAX_RW_COUNT  */
@@ -1355,7 +1356,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
 	    (file_out->f_flags & O_APPEND) ||
-	    !file_out->f_op || !file_out->f_op->copy_file_range)
+	    !file_in->f_op)
 		return -EBADF;
 
 	inode_in = file_inode(file_in);
@@ -1377,8 +1378,15 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
-	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
-					      len, flags);
+	ret = -EOPNOTSUPP;
+	if (file_out->f_op->copy_file_range)
+		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
+						      pos_out, len, flags);
+	if ((ret < 0) && !(flags & COPY_REFLINK)) {
+		file_start_write(file_out);
+		ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out, len, 0);
+		file_end_write(file_out);
+	}
 	if (ret > 0) {
 		fsnotify_access(file_in);
 		add_rchar(current, ret);
diff --git a/include/linux/copy.h b/include/linux/copy.h
new file mode 100644
index 0000000..fd54543
--- /dev/null
+++ b/include/linux/copy.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_COPY_H
+#define _LINUX_COPY_H
+
+#include <uapi/linux/copy.h>
+
+#endif /* _LINUX_COPY_H */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 1ff9942..b6109f3 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -90,6 +90,7 @@ header-y += coda_psdev.h
 header-y += coff.h
 header-y += connector.h
 header-y += const.h
+header-y += copy.h
 header-y += cramfs_fs.h
 header-y += cuda.h
 header-y += cyclades.h
diff --git a/include/uapi/linux/copy.h b/include/uapi/linux/copy.h
new file mode 100644
index 0000000..68f3d65
--- /dev/null
+++ b/include/uapi/linux/copy.h
@@ -0,0 +1,6 @@
+#ifndef _UAPI_LINUX_COPY_H
+#define _UAPI_LINUX_COPY_H
+
+#define COPY_REFLINK	1	/* only perform a reflink */
+
+#endif /* _UAPI_LINUX_COPY_H */
-- 
2.5.1

