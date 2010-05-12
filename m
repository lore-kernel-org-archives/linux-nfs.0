Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:34859 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750796Ab0ELFbg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 01:31:36 -0400
Date: Wed, 12 May 2010 13:30:21 +0800
From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
To: linux-nfs@vger.kernel.org
Cc: bhalevy@panasas.com, iisaman@citi.umich.edu
Subject: [PATCH] pnfs: set pnfs_blksize before calling set_pnfs_layoutdriver
Message-ID: <20100512053021.GA7476@MDS-78.localdomain>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For block/volume layout driver, set_pnfs_layoutdriver will call
initialize_mountpoint() which will check the value of pnfs_blksize.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
---
 fs/nfs/client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dddc75c..94a9be9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -880,9 +880,9 @@ static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fh *mntfh, stru
 
 	if (nfs4_has_session(clp) &&
 	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
+		server->pnfs_blksize = fsinfo->blksize;
 		set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 		pnfs_set_ds_iosize(server);
-		server->pnfs_blksize = fsinfo->blksize;
 	}
 #endif /* CONFIG_NFS_V4_1 */
 }
-- 
1.6.2.5

