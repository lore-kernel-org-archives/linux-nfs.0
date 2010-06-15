From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 06/10] pnfs-submit: Add state flag for layoutcommit_needed
Date: Mon, 14 Jun 2010 21:46:11 -0400
Message-ID: <1276566375-24566-7-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
 <1276566375-24566-3-git-send-email-iisaman@netapp.com>
 <1276566375-24566-4-git-send-email-iisaman@netapp.com>
 <1276566375-24566-5-git-send-email-iisaman@netapp.com>
 <1276566375-24566-6-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52272 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932219Ab0FOO3G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:06 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 50E1C18167
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-6-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This avoids locking and existance of layout issues in upcoming patches

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c             |    2 ++
 include/linux/nfs4_pnfs.h |    2 +-
 include/linux/nfs_fs.h    |    1 +
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e667208..6def09c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -155,6 +155,7 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 	spin_lock(&nfsi->lo_lock);
 	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
 		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
+		__set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->lo_lock);
 		dprintk("%s: Set layoutcommit\n", __func__);
@@ -1686,6 +1687,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	nfsi->layout.pnfs_write_begin_pos = 0;
 	nfsi->layout.pnfs_write_end_pos = 0;
 	nfsi->layout.lo_cred = NULL;
+	__clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->pnfs_layout_state);
 	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
 
 	spin_unlock(&nfsi->lo_lock);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 9dac941..0eb9b16 100644
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
index 0b3419d..71bbc4c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -208,6 +208,7 @@ struct nfs_inode {
 	#define NFS_INO_RO_LAYOUT_FAILED 0	/* get ro layout failed stop trying */
 	#define NFS_INO_RW_LAYOUT_FAILED 1	/* get rw layout failed stop trying */
 	#define NFS_INO_LAYOUT_ALLOC     2	/* bit lock for layout allocation */
+	#define NFS_INO_LAYOUTCOMMIT     3	/* LAYOUTCOMMIT needed */
 	time_t pnfs_layout_suspend;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
-- 
1.6.6.1

