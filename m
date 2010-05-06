Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:39279 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751171Ab0EFIEP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 May 2010 04:04:15 -0400
Date: Thu, 6 May 2010 15:18:21 +0800
From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
To: linux-nfs@vger.kernel.org
Cc: bhalevy@panasas.com
Subject: [PATCH] nfs41: Free layoutcommit_data when error occurs in setup
Message-ID: <20100506071656.GA2746@MDS-78.localdomain>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When layout driver cannot setup layoutcommit_data, we should free
layoutcommit_data data structure before we return.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
---
 fs/nfs/pnfs.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e17efcc..1018bc6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2226,10 +2226,8 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 		return -ENOMEM;
 
 	spin_lock(&nfsi->lo_lock);
-	if (!nfsi->layoutcommit_ctx) {
-		pnfs_layoutcommit_free(data);
+	if (!nfsi->layoutcommit_ctx)
 		goto out_unlock;
-	}
 
 	data->args.inode = inode;
 	data->cred  = nfsi->layoutcommit_ctx->cred;
@@ -2256,6 +2254,7 @@ out:
 	dprintk("%s end (err:%d)\n", __func__, status);
 	return status;
 out_unlock:
+	pnfs_layoutcommit_free(data);
 	spin_unlock(&nfsi->lo_lock);
 	goto out;
 }
-- 
1.6.2.5

