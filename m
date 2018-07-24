Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44745 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388402AbeGXUCn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:02:43 -0400
Received: by mail-io0-f193.google.com with SMTP id q19-v6so4284727ioh.11
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 11:54:53 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Lance Shelton <lance.shelton@hammerspace.com>
Subject: [PATCH] Fix error code in nfs_lookup_verify_inode()
Date: Tue, 24 Jul 2018 14:54:30 -0400
Message-Id: <20180724185430.15335-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Lance Shelton <lance.shelton@hammerspace.com>

Return -ESTALE to force a lookup when the file has no more links

Signed-off-by: Lance Shelton <lance.shelton@hammerspace.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f0e39583af7e..a004b8fc02da 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1038,7 +1038,7 @@ int nfs_lookup_verify_inode(struct inode *inode, unsigned int flags)
 	if (flags & LOOKUP_REVAL)
 		goto out_force;
 out:
-	return (inode->i_nlink == 0) ? -ENOENT : 0;
+	return (inode->i_nlink == 0) ? -ESTALE : 0;
 out_force:
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
-- 
2.17.1

