From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 5/6] SQUASHME: pnfs-commit: Fix scariness in nfs4_clear_inode
Date: Tue,  6 Jul 2010 17:07:53 +0300
Message-ID: <1278425273-22466-1-git-send-email-bharrosh@panasas.com>
References: <4C3334E3.7070600@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>,
	Fred Isaman <iisaman@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61097 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753127Ab0GFOH5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 10:07:57 -0400
In-Reply-To: <4C3334E3.7070600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It does not look right to clear out basic nfs RPC resources
before calling layout_return.

Also, for me a layout is an inner resource to delegation, the
delegation is acquired during open, a layout later. So it's
proper to return the layout before the delegation

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/inode.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7989dea..916d6d0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1351,13 +1351,12 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_clear_inode(struct inode *inode)
 {
-	/* If we are holding a delegation, return it! */
-	nfs_inode_return_delegation_noreclaim(inode);
-	/* First call standard NFS clear_inode() code */
-	nfs_clear_inode(inode);
 #ifdef CONFIG_NFS_V4_1
 	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
 #endif /* CONFIG_NFS_V4_1 */
+	/* If we are holding a delegation, return it! */
+	nfs_inode_return_delegation_noreclaim(inode);
+	nfs_clear_inode(inode);
 }
 #endif
 
-- 
1.6.6.1

