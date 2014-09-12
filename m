Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35855 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495AbaILDEW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 23:04:22 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so235453pab.4
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 20:04:21 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>, Christoph Hellwig <hch@lst.de>,
        Boaz Harrosh <boaz@plexistor.com>
Subject: [PATCH v2] nfs41: change PNFS_LAYOUTRET_ON_SETATTR to only return on truncation to smaller size
Date: Fri, 12 Sep 2014 11:04:10 +0800
Message-Id: <1410491050-12858-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both blocks layout and objects layout want to use it to avoid CB_LAYOUTRECALL
but that should only happen if client is doing truncation to a smaller size.
For other cases, we let server decide if it wants to recall client's layouts.
Change PNFS_LAYOUTRET_ON_SETATTR to follow the logic and not to send
layoutreturn unnecessarily.

Cc: Christoph Hellwig <hch@lst.de>
Cc: Boaz Harrosh <boaz@plexistor.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4proc.c | 4 +++-
 fs/nfs/pnfs.h     | 3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7dd8aca..63a5b80 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3213,7 +3213,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs4_label *label = NULL;
 	int status;
 
-	if (pnfs_ld_layoutret_on_setattr(inode))
+	if (pnfs_ld_layoutret_on_setattr(inode) &&
+	    sattr->ia_valid & ATTR_SIZE &&
+	    sattr->ia_size < i_size_read(inode))
 		pnfs_commit_and_return_layout(inode);
 
 	nfs_fattr_init(fattr);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index aca3dff..04a3646 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -68,7 +68,8 @@ enum {
 };
 
 enum layoutdriver_policy_flags {
-	/* Should the pNFS client commit and return the layout upon a setattr */
+	/* Should the pNFS client commit and return the layout upon truncate to
+	 * a smaller size */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
 	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
 };
-- 
1.9.1

