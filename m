Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:49777 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754080AbbIKUak (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 16:30:40 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v2 7/9] vfs: Remove copy_file_range mountpoint checks
Date: Fri, 11 Sep 2015 16:30:20 -0400
Message-ID: <1442003423-6884-8-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I still want to do an in-kernel copy even if the files are on different
mountpoints, and NFS has a "server to server" copy that expects two
files on different mountpoints.  Let's have individual filesystems
implement this check instead.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/read_write.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index ac32388..363bd3e 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1366,11 +1366,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	    pos_in + len > i_size_read(inode_in))
 		return -EINVAL;
 
-	/* this could be relaxed once a method supports cross-fs copies */
-	if (inode_in->i_sb != inode_out->i_sb ||
-	    file_in->f_path.mnt != file_out->f_path.mnt)
-		return -EXDEV;
-
 	if (len == 0)
 		return 0;
 
-- 
2.5.1

