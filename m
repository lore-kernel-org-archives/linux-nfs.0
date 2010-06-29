From: andros@netapp.com
Subject: [PATCH 1/5] SQUASHME pnfs-submit: add state flag for layoutcommit_needed
Date: Tue, 29 Jun 2010 12:42:13 -0400
Message-ID: <1277829737-5465-2-git-send-email-andros@netapp.com>
References: <1277829737-5465-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
To: benny@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15343 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932137Ab0F2Qly (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jun 2010 12:41:54 -0400
In-Reply-To: <1277829737-5465-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@netapp.com>

This avoids locking and existance of layout issues

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c             |    2 ++
 include/linux/nfs4_pnfs.h |    2 +-
 include/linux/nfs_fs.h    |    1 +
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9a295cf..bf15b5c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -154,6 +154,7 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
 		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
+		__set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->vfs_inode.i_lock);
 		dprintk("%s: Set layoutcommit\n", __func__);
@@ -1635,6 +1636,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	nfsi->layout.pnfs_write_begin_pos = 0;
 	nfsi->layout.pnfs_write_end_pos = 0;
 	nfsi->layout.lo_cred = NULL;
+	__clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
 	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
 
 	spin_unlock(&inode->i_lock);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index d20b5de..4d9b15c 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -83,7 +83,7 @@ has_layout(struct nfs_inode *nfsi)
 static inline bool
 layoutcommit_needed(struct nfs_inode *nfsi)
 {
-	return nfsi->layout.lo_cred != NULL;
+	return test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
 }
 
 #else /* CONFIG_NFS_V4_1 */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index a60d880..a33e86e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -109,6 +109,7 @@ struct pnfs_layout_type {
 	#define NFS_INO_RO_LAYOUT_FAILED 0      /* get ro layout failed stop trying */
 	#define NFS_INO_RW_LAYOUT_FAILED 1      /* get rw layout failed stop trying */
 	#define NFS_INO_LAYOUT_ALLOC     2      /* bit lock for layout allocation */
+	#define NFS_INO_LAYOUTCOMMIT     3	/* LAYOUTCOMMIT needed */
 	time_t pnfs_layout_suspend;
 	struct rpc_cred         *lo_cred; /* layoutcommit credential */
 	/* DH: These vars keep track of the maximum write range
-- 
1.6.6

