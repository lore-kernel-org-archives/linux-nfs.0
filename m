Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx61.netapp.com ([216.240.31.181]:10044 "EHLO mx61.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032990AbbKFV2K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Nov 2015 16:28:10 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v8 4/4] vfs: Add vfs_copy_file_range() support for pagecache copies
Date: Fri, 6 Nov 2015 16:18:20 -0500
Message-ID: <1446844701-848-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1446844701-848-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1446844701-848-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This allows us to have an in-kernel copy mechanism that avoids frequent
switches between kernel and user space.  This is especially useful so
NFSD can support server-side copies.

The default (flags=0) means to first attempt copy acceleration, but use
the pagecache if that fails.

I moved the rw_verify_area() calls into the fallback code since some
filesystems can handle reflinking a large range.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Padraig Brady <P@draigBrady.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c | 37 ++++++++++++++++++++++++++-----------
 1 file changed, 26 insertions(+), 11 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 97c15ca..a093830 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1329,6 +1329,24 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
 }
 #endif
 
+static ssize_t vfs_copy_fr_copy(struct file *file_in, loff_t pos_in,
+				struct file *file_out, loff_t pos_out,
+				size_t len)
+{
+	ssize_t ret = rw_verify_area(READ, file_in, &pos_in, len);
+
+	if (ret >= 0) {
+		len = ret;
+		ret = rw_verify_area(WRITE, file_out, &pos_out, len);
+		if (ret >= 0)
+			len = ret;
+	}
+	if (ret < 0)
+		return ret;
+
+	return do_splice_direct(file_in, &pos_in, file_out, &pos_out, len, 0);
+}
+
 /*
  * copy_file_range() differs from regular file read and write in that it
  * specifically allows return partial success.  When it does so is up to
@@ -1345,17 +1363,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (flags != 0)
 		return -EINVAL;
 
-	/* copy_file_range allows full ssize_t len, ignoring MAX_RW_COUNT  */
-	ret = rw_verify_area(READ, file_in, &pos_in, len);
-	if (ret >= 0)
-		ret = rw_verify_area(WRITE, file_out, &pos_out, len);
-	if (ret < 0)
-		return ret;
-
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
-	    (file_out->f_flags & O_APPEND) ||
-	    !file_out->f_op->copy_file_range)
+	    (file_out->f_flags & O_APPEND))
 		return -EBADF;
 
 	/* this could be relaxed once a method supports cross-fs copies */
@@ -1369,8 +1379,13 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
-	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
-					      len, flags);
+	ret = -EOPNOTSUPP;
+	if (file_out->f_op->copy_file_range)
+		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
+						      pos_out, len, flags);
+	if (ret == -EOPNOTSUPP)
+		ret = vfs_copy_fr_copy(file_in, pos_in, file_out, pos_out, len);
+
 	if (ret > 0) {
 		fsnotify_access(file_in);
 		add_rchar(current, ret);
-- 
2.6.2

