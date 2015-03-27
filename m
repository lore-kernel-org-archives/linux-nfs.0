Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37467 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbbC0RFP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:05:15 -0400
Received: by igcxg11 with SMTP id xg11so25575682igc.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:05:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Add a helper to sync both O_DIRECT and buffered writes
Date: Fri, 27 Mar 2015 13:05:11 -0400
Message-Id: <1427475913-14626-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Then apply it to nfs_setattr() and nfs_getattr().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d42dff6d5e98..60f907666697 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -133,6 +133,12 @@ void nfs_evict_inode(struct inode *inode)
 	nfs_clear_inode(inode);
 }
 
+static int nfs_sync_inode(struct inode *inode)
+{
+	nfs_inode_dio_wait(inode);
+	return nfs_wb_all(inode);
+}
+
 /**
  * nfs_sync_mapping - helper to flush all mmapped dirty data to disk
  */
@@ -525,10 +531,8 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	trace_nfs_setattr_enter(inode);
 
 	/* Write all dirty data */
-	if (S_ISREG(inode->i_mode)) {
-		nfs_inode_dio_wait(inode);
-		nfs_wb_all(inode);
-	}
+	if (S_ISREG(inode->i_mode))
+		nfs_sync_inode(inode);
 
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)
@@ -644,8 +648,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	trace_nfs_getattr_enter(inode);
 	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
-		nfs_inode_dio_wait(inode);
-		err = filemap_write_and_wait(inode->i_mapping);
+		err = nfs_sync_inode(inode);
 		if (err)
 			goto out;
 	}
-- 
2.1.0

