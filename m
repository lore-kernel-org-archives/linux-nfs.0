Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:54188 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932648AbbI3R1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Sep 2015 13:27:14 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v5 6/9] vfs: Copy should use file_out rather than file_in
Date: Wed, 30 Sep 2015 13:26:50 -0400
Message-ID: <1443634014-3026-7-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The way to think about this is that the destination filesystem reads the
data from the source file and processes it accordingly.  This is
especially important to avoid an infinate loop when doing a "server to
server" copy on NFS.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/read_write.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 8e7cb33..6f74f1f 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1355,7 +1355,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
 	    (file_out->f_flags & O_APPEND) ||
-	    !file_in->f_op || !file_in->f_op->copy_file_range)
+	    !file_out->f_op || !file_out->f_op->copy_file_range)
 		return -EBADF;
 
 	inode_in = file_inode(file_in);
@@ -1378,8 +1378,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (ret)
 		return ret;
 
-	ret = file_in->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
-					     len, flags);
+	ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
+					      len, flags);
 	if (ret > 0) {
 		fsnotify_access(file_in);
 		add_rchar(current, ret);
-- 
2.6.0

