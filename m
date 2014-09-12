Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:53091 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbaILDBt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 23:01:49 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so221946pdj.6
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 20:01:48 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>, Christoph Hellwig <hch@lst.de>,
        Boaz Harrosh <boaz@plexistor.com>
Subject: [PATCH] nfs41: change PNFS_LAYOUTRET_ON_SETATTR to only return on chown/truncate
Date: Fri, 12 Sep 2014 11:01:35 +0800
Message-Id: <1410490895-12684-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both blocks layout and objects layout want to use it to avoid CB_LAYOUTRECALL
but that should only happen if client is doing chown or truncate. So change
PNFS_LAYOUTRET_ON_SETATTR to follow the logic and not to send layoutreturn
unnecessarily.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Boaz Harrosh <boaz@plexistor.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 fs/nfs/pnfs.h     | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7dd8aca..e55bd0f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3213,7 +3213,8 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs4_label *label = NULL;
 	int status;
 
-	if (pnfs_ld_layoutret_on_setattr(inode))
+	if (pnfs_ld_layoutret_on_setattr(inode) &&
+	    sattr->ia_valid & (ATTR_UID|ATTR_GID|ATTR_SIZE))
 		pnfs_commit_and_return_layout(inode);
 
 	nfs_fattr_init(fattr);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index aca3dff..1765ea8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -68,7 +68,8 @@ enum {
 };
 
 enum layoutdriver_policy_flags {
-	/* Should the pNFS client commit and return the layout upon a setattr */
+	/* Should the pNFS client commit and return the layout upon a setattr
+	 * that changes uid/gid/size. */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
 	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
 };
-- 
1.9.1

