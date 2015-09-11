Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:45875 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754103AbbIKUau (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 16:30:50 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v2 5/9] vfs: Copy shouldn't forbid ranges inside the same file
Date: Fri, 11 Sep 2015 16:30:18 -0400
Message-ID: <1442003423-6884-6-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is perfectly valid for BTRFS and XFS, so let's leave this up to
filesystems to check.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/read_write.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 38cc251..d32549b 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1371,10 +1371,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	    file_in->f_path.mnt != file_out->f_path.mnt)
 		return -EXDEV;
 
-	/* forbid ranges in the same file */
-	if (inode_in == inode_out)
-		return -EINVAL;
-
 	if (len == 0)
 		return 0;
 
-- 
2.5.1

