Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:61872 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933346AbbCPSGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2015 14:06:32 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v4 2/2] NFS: Reduce time spent holding the i_mutex during fallocate()
Date: Mon, 16 Mar 2015 14:06:24 -0400
Message-ID: <1426529184-8794-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1426529184-8794-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1426529184-8794-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At the very least, we should not be taking the i_mutex until after
checking if the server even supports ALLOCATE or DEALLOCATE, allowing
v4.0 or v4.1 to exit without potentially waiting on a lock.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c | 8 ++++++++
 fs/nfs/nfs4file.c  | 9 ++-------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index b9aa6bb..3a9e752 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -96,9 +96,13 @@ int nfs42_proc_allocate(struct file *filep, loff_t offset, loff_t len)
 	if (!nfs_server_capable(inode, NFS_CAP_ALLOCATE))
 		return -EOPNOTSUPP;
 
+	mutex_lock(&inode->i_mutex);
+
 	err = nfs42_proc_fallocate(&msg, filep, offset, len);
 	if (err == -EOPNOTSUPP)
 		NFS_SERVER(inode)->caps &= ~NFS_CAP_ALLOCATE;
+
+	mutex_unlock(&inode->i_mutex);
 	return err;
 }
 
@@ -114,11 +118,15 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 		return -EOPNOTSUPP;
 
 	nfs_wb_all(inode);
+	mutex_lock(&inode->i_mutex);
+
 	err = nfs42_proc_fallocate(&msg, filep, offset, len);
 	if (err == 0)
 		truncate_pagecache_range(inode, offset, (offset + len) -1);
 	if (err == -EOPNOTSUPP)
 		NFS_SERVER(inode)->caps &= ~NFS_CAP_DEALLOCATE;
+
+	mutex_unlock(&inode->i_mutex);
 	return err;
 }
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index d09c689..1d1848e 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -152,14 +152,9 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
 	if (ret < 0)
 		return ret;
 
-	mutex_lock(&inode->i_mutex);
 	if (mode & FALLOC_FL_PUNCH_HOLE)
-		ret = nfs42_proc_deallocate(filep, offset, len);
-	else
-		ret = nfs42_proc_allocate(filep, offset, len);
-	mutex_unlock(&inode->i_mutex);
-
-	return ret;
+		return nfs42_proc_deallocate(filep, offset, len);
+	return nfs42_proc_allocate(filep, offset, len);
 }
 #endif /* CONFIG_NFS_V4_2 */
 
-- 
2.3.3

