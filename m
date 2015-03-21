Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:36616 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbCUEV3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Mar 2015 00:21:29 -0400
From: Taesoo Kim <tsgatesv@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: taesoo@gatech.edu, changwoo@gatech.edu, sanidhya@gatech.edu,
        blee@gatech.edu, csong84@gatech.edu,
        Byoungyoung Lee <lifeasageek@gmail.com>,
        Taesoo Kim <tsgatesv@gmail.com>
Subject: [PATCH] NFS: fix potential NULL deref in nfs_closedir()
Date: Sat, 21 Mar 2015 00:21:18 -0400
Message-Id: <1426911678-25306-1-git-send-email-tsgatesv@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Byoungyoung Lee <lifeasageek@gmail.com>

When filp->private_data is NULL, put_nfs_open_dir_context()
deferences its pointer (fi->list, fi->cred), similar to what
other file systems handle '.release' api (9p, cifs, btrfs, 
ext4, ocfs2).

Signed-off-by: Byoungyoung Lee <lifeasageek@gmail.com>
Signed-off-by: Taesoo Kim <tsgatesv@gmail.com>
---
 fs/nfs/dir.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c19e16f..434ecf1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -133,7 +133,8 @@ out:
 static int
 nfs_closedir(struct inode *inode, struct file *filp)
 {
-	put_nfs_open_dir_context(file_inode(filp), filp->private_data);
+	if (filp->private_data)
+		put_nfs_open_dir_context(file_inode(filp), filp->private_data);
 	return 0;
 }
 
-- 
1.9.1

