Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:59532 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751810Ab0ELHnX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 03:43:23 -0400
Date: Wed, 12 May 2010 15:42:04 +0800
From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
To: linux-nfs@vger.kernel.org
Cc: bhalevy@panasas.com
Subject: [PATCH] pnfs: set pnfs_curr_ld before calling initialize_mountpoint
Message-ID: <20100512074204.GA7643@MDS-78.localdomain>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

initialize_mountpoint will call _nfs4_pnfs_getdevicelist and then
pnfs_curr_ld->id is accessed. This introduce a NULL pointer reference.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3739c38..5ad7fc6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -212,6 +212,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 		return;
 
 	if (id > 0 && find_pnfs(id, &mod)) {
+		server->pnfs_curr_ld = mod->pnfs_ld_type;
 		if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
 							server, mntfh)) {
 			printk(KERN_ERR "%s: Error initializing mount point "
@@ -222,7 +223,6 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 		 * Layout driver succeeded in initializing mountpoint
 		 * and has taken a reference on the nfs_client cl_devid_cache
 		 */
-		server->pnfs_curr_ld = mod->pnfs_ld_type;
 		server->nfs_client->rpc_ops = &pnfs_v4_clientops;
 		dprintk("%s: pNFS module for %u set\n", __func__, id);
 		return;
-- 
1.6.2.5

