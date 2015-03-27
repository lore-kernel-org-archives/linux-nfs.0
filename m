Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:35914 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbbC0RIo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:08:44 -0400
Received: by igbud6 with SMTP id ud6so26044936igb.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:08:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Block new writes while syncing data in nfs_getattr()
Date: Fri, 27 Mar 2015 13:08:42 -0400
Message-Id: <1427476122-14789-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f1fc0e4c1c02..0c3be2658546 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -649,7 +649,9 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	trace_nfs_getattr_enter(inode);
 	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
+		mutex_lock(&inode->i_mutex);
 		err = nfs_sync_inode(inode);
+		mutex_unlock(&inode->i_mutex);
 		if (err)
 			goto out;
 	}
-- 
2.1.0

