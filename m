Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:62691 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbbKJVxq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Nov 2015 16:53:46 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v9 4/4] vfs: Add vfs_copy_file_range() support for pagecache copies
Date: Tue, 10 Nov 2015 16:53:33 -0500
Message-ID: <1447192413-15376-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1447192413-15376-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1447192413-15376-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This allows us to have an in-kernel copy mechanism that avoids frequent
switches between kernel and user space.  This is especially useful so
NFSD can support server-side copies.

The default (flags=0) means to first attempt copy acceleration, but use
the pagecache if that fails.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Padraig Brady <P@draigBrady.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
v9:
- Don't remove call to rw_verify_area()
---
 fs/read_write.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 97c15ca..6f73af1 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1354,8 +1354,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
-	    (file_out->f_flags & O_APPEND) ||
-	    !file_out->f_op->copy_file_range)
+	    (file_out->f_flags & O_APPEND))
 		return -EBADF;
 
 	/* this could be relaxed once a method supports cross-fs copies */
@@ -1369,8 +1368,14 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
-	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
-					      len, flags);
+	ret = -EOPNOTSUPP;
+	if (file_out->f_op->copy_file_range)
+		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
+						      pos_out, len, flags);
+	if (ret == -EOPNOTSUPP)
+		ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
+				len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
+
 	if (ret > 0) {
 		fsnotify_access(file_in);
 		add_rchar(current, ret);
-- 
2.6.2

