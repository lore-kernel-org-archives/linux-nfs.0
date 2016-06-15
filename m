Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34451 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933028AbcFOUGE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 16:06:04 -0400
Received: by mail-it0-f65.google.com with SMTP id d71so4758765ith.1
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2016 13:06:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix potential race in nfs_fhget()
Date: Wed, 15 Jun 2016 16:05:28 -0400
Message-Id: <1466021128-62407-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we don't set the mode correctly in nfs_init_locked(), then there is
potential for a race with a second call to nfs_fhget that will cause
inode aliasing.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 52e7d6869e3b..dda689d7a8a7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -282,6 +282,7 @@ nfs_init_locked(struct inode *inode, void *opaque)
 	struct nfs_fattr	*fattr = desc->fattr;
 
 	set_nfs_fileid(inode, fattr->fileid);
+	inode->i_mode = fattr->mode;
 	nfs_copy_fh(NFS_FH(inode), desc->fh);
 	return 0;
 }
-- 
2.5.5

