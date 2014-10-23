Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58237 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255AbaJWMCx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2014 08:02:53 -0400
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>
Subject: [PATCH] nfs: Fix use of uninitialized variable in nfs_getattr()
Date: Thu, 23 Oct 2014 14:02:47 +0200
Message-Id: <1414065767-20005-1-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable 'err' needn't be initialized when nfs_getattr() uses it to
check whether it should call generic_fillattr() or not. That can result
in spurious error returns. Initialize 'err' properly.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6388a59f2add..00689a8a85e4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -626,7 +626,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
-	int err;
+	int err = 0;
 
 	trace_nfs_getattr_enter(inode);
 	/* Flush out writes to the server in order to update c/mtime.  */
-- 
1.8.1.4

