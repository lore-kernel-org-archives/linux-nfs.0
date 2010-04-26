From: andros@netapp.com
Subject: [PATCH 2/3] SQUASHME pnfs_submit: fix multiple mount set_pnfs_layoutdriver
Date: Mon, 26 Apr 2010 12:18:18 -0400
Message-ID: <1272298699-11411-3-git-send-email-andros@netapp.com>
References: <1272298699-11411-1-git-send-email-andros@netapp.com>
 <1272298699-11411-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14530 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790Ab0DZQSR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Apr 2010 12:18:17 -0400
In-Reply-To: <1272298699-11411-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The same struct nfs_server can enter set_pnfs_layoutdriver for mounts that
share a super block.  Don't initialize a pnfs mountpoint more than once.

Don't set the pnfs_curr_ld until the pnfs mountpoint initialization succeeds

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bf906cc..a3e8231 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -215,20 +215,25 @@ set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id)
 	struct pnfs_mount_type *mt;
 	struct nfs_server *server = NFS_SB(sb);
 
+	if (server->pnfs_curr_ld)
+		return;
+
 	if (id > 0 && find_pnfs(id, &mod)) {
-		dprintk("%s: Setting pNFS module\n", __func__);
-		server->pnfs_curr_ld = mod->pnfs_ld_type;
-		mt = server->pnfs_curr_ld->ld_io_ops->initialize_mountpoint(
+		mt = mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
 			sb, fh);
 		if (!mt) {
 			printk(KERN_ERR "%s: Error initializing mount point "
 			       "for layout driver %u. ", __func__, id);
 			goto out_err;
 		}
-		/* Layout driver succeeded in initializing mountpoint */
+		/*
+		 * Layout driver succeeded in initializing mountpoint
+		 * and has taken a reference on the nfs_client cl_devid_cache
+		 */
+		server->pnfs_curr_ld = mod->pnfs_ld_type;
 		server->pnfs_mountid = mt;
-		/* Set the rpc_ops */
 		server->nfs_client->rpc_ops = &pnfs_v4_clientops;
+		dprintk("%s: pNFS module for %u set\n", __func__, id);
 		return;
 	}
 
-- 
1.6.6

