Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:22492 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbcALViW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2016 16:38:22 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH] NFS: Close a race in nfs42_proc_deallocate()
Date: Tue, 12 Jan 2016 16:38:18 -0500
Message-ID: <1452634698-16619-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to take the i_mutex before writing back the inode to ensure that
the file doesn't change before calling DEALLOCATE.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 6e81749..10d8eb4 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -122,8 +122,8 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	if (!nfs_server_capable(inode, NFS_CAP_DEALLOCATE))
 		return -EOPNOTSUPP;
 
-	nfs_wb_all(inode);
 	mutex_lock(&inode->i_mutex);
+	nfs_wb_all(inode);
 
 	err = nfs42_proc_fallocate(&msg, filep, offset, len);
 	if (err == 0)
-- 
2.7.0

