Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36783 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbcFZA0i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jun 2016 20:26:38 -0400
Received: by mail-it0-f66.google.com with SMTP id h190so6639284ith.3
        for <linux-nfs@vger.kernel.org>; Sat, 25 Jun 2016 17:26:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFS: Fix a race in nfs42_proc_deallocate()
Date: Sat, 25 Jun 2016 20:25:51 -0400
Message-Id: <1466900754-29584-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466900754-29584-1-git-send-email-trond.myklebust@primarydata.com>
References: <1466900754-29584-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When punching holes in a file, we want to ensure the operation is
serialised w.r.t. other writes, meaning that we want to call
nfs_sync_inode() while holding the inode lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index aa03ed09ba06..0f9f536e647b 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -113,15 +113,17 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	if (!nfs_server_capable(inode, NFS_CAP_DEALLOCATE))
 		return -EOPNOTSUPP;
 
-	nfs_wb_all(inode);
 	inode_lock(inode);
+	err = nfs_sync_inode(inode);
+	if (err)
+		goto out_unlock;
 
 	err = nfs42_proc_fallocate(&msg, filep, offset, len);
 	if (err == 0)
 		truncate_pagecache_range(inode, offset, (offset + len) -1);
 	if (err == -EOPNOTSUPP)
 		NFS_SERVER(inode)->caps &= ~NFS_CAP_DEALLOCATE;
-
+out_unlock:
 	inode_unlock(inode);
 	return err;
 }
-- 
2.7.4

