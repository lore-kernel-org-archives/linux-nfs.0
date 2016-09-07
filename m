Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:63178 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752040AbcIGUKg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Sep 2016 16:10:36 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <viro@zeniv.linux.org.uk>
Subject: [PATCH] vfs: Don't copy beyond the end of the file
Date: Wed, 7 Sep 2016 16:10:31 -0400
Message-ID: <20160907201031.27512-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to `man 2 copy_file_range`, EINVAL should be returned if the
"requested range extends beyond the end of the source file".  Falling
back on do_splice_direct() will return 0 in this case, so let's add an
explicit check to match the behavior documented in the man page.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/read_write.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index 66215a7..1cbab4e 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1497,6 +1497,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (unlikely(ret))
 		return ret;
 
+	if (pos_in >= i_size_read(inode_in))
+		return -EINVAL;
+
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
 	    (file_out->f_flags & O_APPEND))
-- 
2.9.3

