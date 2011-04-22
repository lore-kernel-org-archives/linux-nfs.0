Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6500 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab1DVIF7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:05:59 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] SQUASHME: no need to send layoutcommit from _pnfs_return_layout
Date: Fri, 22 Apr 2011 11:05:44 +0300
Message-Id: <1303459544-16518-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DB125BD.3040703@panasas.com>
References: <4DB125BD.3040703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

squash into "pnfs: layoutreturn"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ec2418b..27b0593 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -714,11 +714,8 @@ _pnfs_return_layout(struct inode *ino)
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
-	/* Return layout even if layoutcommit fails */
-	status = pnfs_layoutcommit_inode(ino, true);
-	if (status)
-		dprintk("%s: layoutcommit failed, status=%d. Returning layout anyway\n",
-			__func__, status);
+	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
+
 	status = return_layout(ino);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
-- 
1.7.3.4

