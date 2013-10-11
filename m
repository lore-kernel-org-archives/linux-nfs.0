Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f50.google.com ([209.85.213.50]:33587 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190Ab3JKUWH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Oct 2013 16:22:07 -0400
From: "Geyslan G. Bem" <geyslan@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, joe@perches.com,
        kernel-br@googlegroups.com, "Geyslan G. Bem" <geyslan@gmail.com>
Subject: [PATCH] nfs: Remove useless 'error' assignment
Date: Fri, 11 Oct 2013 17:15:54 -0300
Message-Id: <1381522554-22243-1-git-send-email-geyslan@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the 'error' variable was been assigned twice in vain.

Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>
---
 fs/nfs/unlink.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index bb939ed..0c29b1b 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -493,7 +493,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	unsigned long long fileid;
 	struct dentry *sdentry;
 	struct rpc_task *task;
-	int            error = -EIO;
+	int            error = -EBUSY;
 
 	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -503,7 +503,6 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	/*
 	 * We don't allow a dentry to be silly-renamed twice.
 	 */
-	error = -EBUSY;
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
 		goto out;
 
-- 
1.8.4

