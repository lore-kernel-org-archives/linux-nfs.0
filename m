Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6480 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab1DVIEZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:04:25 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] SQUASHME: call pnfs_return_layout right before pnfs_destroy_layout
Date: Fri, 22 Apr 2011 11:04:14 +0300
Message-Id: <1303459454-16283-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DB125BD.3040703@panasas.com>
References: <4DB125BD.3040703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

squash into "pnfs: layoutreturn"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 73a2529..9a48d1c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1424,9 +1424,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_evict_inode(struct inode *inode)
 {
-	pnfs_return_layout(inode, NULL, true);
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
+	pnfs_return_layout(inode, NULL);
 	pnfs_destroy_layout(NFS_I(inode));
 	/* If we are holding a delegation, return it! */
 	nfs_inode_return_delegation_noreclaim(inode);
-- 
1.7.3.4

