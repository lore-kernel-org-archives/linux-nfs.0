Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:12561 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755423AbcHSRZq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:25:46 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@rhel7-2-ga-3.androsad.fake>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version-2 03/12] VFS permit cross device vfs_copy_file_range
Date: Fri, 19 Aug 2016 13:25:03 -0400
Message-ID: <1471627512-4102-4-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@rhel7-2-ga-3.androsad.fake>

NFSv4.2 inter server to server copy always copies across devices.

Note: both btrfs and nfs have EXDEV checks in their
copy_file_range functions.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/read_write.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 1cbab4e..a6d3350 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1483,7 +1483,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 			    size_t len, unsigned int flags)
 {
 	struct inode *inode_in = file_inode(file_in);
-	struct inode *inode_out = file_inode(file_out);
 	ssize_t ret;
 
 	if (flags != 0)
@@ -1505,10 +1504,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	    (file_out->f_flags & O_APPEND))
 		return -EBADF;
 
-	/* this could be relaxed once a method supports cross-fs copies */
-	if (inode_in->i_sb != inode_out->i_sb)
-		return -EXDEV;
-
 	if (len == 0)
 		return 0;
 
-- 
1.8.3.1

