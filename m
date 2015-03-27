Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37403 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577AbbC0RBK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:01:10 -0400
Received: by igcxg11 with SMTP id xg11so25470060igc.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:01:10 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Return the delegation before returning the layout in evict_inode()
Date: Fri, 27 Mar 2015 13:01:08 -0400
Message-Id: <1427475668-14437-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Minor optimisation for the case where the layout has return-on-close
enabled.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4super.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 75090feeafad..d91898193b2f 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -91,10 +91,11 @@ static void nfs4_evict_inode(struct inode *inode)
 {
 	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
-	pnfs_return_layout(inode);
-	pnfs_destroy_layout(NFS_I(inode));
 	/* If we are holding a delegation, return it! */
 	nfs_inode_return_delegation_noreclaim(inode);
+	/* Note that above delegreturn would trigger pnfs return-on-close */
+	pnfs_return_layout(inode);
+	pnfs_destroy_layout(NFS_I(inode));
 	/* First call standard NFS clear_inode() code */
 	nfs_clear_inode(inode);
 }
-- 
2.1.0

