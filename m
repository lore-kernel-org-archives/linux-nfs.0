Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36795 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbcFZA0n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jun 2016 20:26:43 -0400
Received: by mail-it0-f65.google.com with SMTP id h190so6639345ith.3
        for <linux-nfs@vger.kernel.org>; Sat, 25 Jun 2016 17:26:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFS: Getattr doesn't require data sync semantics
Date: Sat, 25 Jun 2016 20:25:53 -0400
Message-Id: <1466900754-29584-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466900754-29584-3-git-send-email-trond.myklebust@primarydata.com>
References: <1466900754-29584-1-git-send-email-trond.myklebust@primarydata.com>
 <1466900754-29584-2-git-send-email-trond.myklebust@primarydata.com>
 <1466900754-29584-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When retrieving stat() information, NFS unfortunately does require us to
sync writes to disk in order to ensure that mtime and ctime are up to
date. However we shouldn't have to ensure that those writes are persisted.

Relaxing that requirement does mean that we may see an mtime/ctime change
if the server reboots and forces us to replay all writes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b729f7b972d3..8eb2d96fd45b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -661,9 +661,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	trace_nfs_getattr_enter(inode);
 	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
-		inode_lock(inode);
-		err = nfs_sync_inode(inode);
-		inode_unlock(inode);
+		err = filemap_write_and_wait(inode->i_mapping);
 		if (err)
 			goto out;
 	}
-- 
2.7.4

