Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:23369 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752664AbdCBQIh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:08:37 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <linux-fsdevel@vger.kernel.org>
CC: <hch@lst.de>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
Date: Thu, 2 Mar 2017 11:02:10 -0500
Message-ID: <20170302160211.30451-3-kolga@netapp.com>
In-Reply-To: <20170302160211.30451-1-kolga@netapp.com>
References: <20170302160211.30451-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow nfs_copy_file_range to copy across devices.
NFSv4.2 inter server to server copy always copies across devices, and
NFSv4.2 intra server to server copy can copy across devices on the same
server.

If a file system's fileoperations copy_file_range operation prohibits
cross-device copies, fall back to do_splice_direct. This is needed for
nfsd_copy_file_range() which is called by the inter server to server
destination server acting as an NFS client, and reading the file from
the source server.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/read_write.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 1d9e305..75084cd 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1534,10 +1534,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	    (file_out->f_flags & O_APPEND))
 		return -EBADF;
 
-	/* this could be relaxed once a method supports cross-fs copies */
-	if (inode_in->i_sb != inode_out->i_sb)
-		return -EXDEV;
-
 	if (len == 0)
 		return 0;
 
@@ -1559,7 +1555,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (file_out->f_op->copy_file_range) {
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
-		if (ret != -EOPNOTSUPP)
+		if (ret != -EOPNOTSUPP && ret != -EXDEV)
 			goto done;
 	}
 
-- 
1.8.3.1

