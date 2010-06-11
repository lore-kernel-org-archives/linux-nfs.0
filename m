From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 04/26] pnfs-submit: Revert "pnfs: Add function to set up O_DIRECT I/O"
Date: Fri, 11 Jun 2010 03:31:31 -0400
Message-ID: <1276241513-17942-5-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869Ab0FKHcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:20 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3tv024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:07 -0700 (PDT)
In-Reply-To: <1276241513-17942-4-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 4bc73cd4118b5d5b710c28c83a750bf4e02e8269.

Conflicts:

	fs/nfs/pnfs.c
	fs/nfs/pnfs.h

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   31 -------------------------------
 fs/nfs/pnfs.h |   25 -------------------------
 2 files changed, 0 insertions(+), 56 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 27b7b48..6717a9d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1374,37 +1374,6 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	pnfs_set_pg_test(inode, pgio);
 }
 
-/* Retrieve I/O parameters for O_DIRECT.
- * Out Args:
- * iosize    - min of boundary and (rsize or wsize)
- * remaining - # bytes remaining in the current stripe unit
- */
-void
-_pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
-		     size_t count, loff_t loff, int iswrite, size_t *iosize,
-		     size_t *remaining)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	u32 boundary;
-	unsigned int rwsize;
-
-	if (count <= 0 ||
-	    pnfs_update_layout(inode, ctx, count, loff, IOMODE_READ, NULL))
-		return;
-
-	if (iswrite)
-		rwsize = nfss->wsize;
-	else
-		rwsize = nfss->rsize;
-
-	boundary = pnfs_getboundary(inode);
-
-	*iosize = min(rwsize, boundary);
-	*remaining = boundary - (do_div(loff, boundary));
-
-	dprintk("%s Rem %Zu iosize %Zu\n", __func__, *remaining, *iosize);
-}
-
 /*
  * Get a layoutout for COMMIT
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 47de1ba..4581a3e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -65,9 +65,6 @@ void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segm
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
-void _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
-			  size_t count, loff_t loff, int iswrite,
-			  size_t *rwsize, size_t *remaining);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
 				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
@@ -183,20 +180,6 @@ static inline int pnfs_get_read_status(struct nfs_read_data *data)
 	return data->pdata.pnfs_error;
 }
 
-static inline void pnfs_direct_init_io(struct inode *inode,
-				       struct nfs_open_context *ctx,
-				       size_t count, loff_t loff, int iswrite,
-				       size_t *iosize, size_t *remaining)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-
-	if (pnfs_enabled_sb(nfss))
-		return _pnfs_direct_init_io(inode, ctx, count, loff, iswrite,
-					    iosize, remaining);
-
-	return;
-}
-
 static inline int pnfs_use_rpc(struct nfs_server *nfss)
 {
 	if (pnfs_enabled_sb(nfss))
@@ -242,14 +225,6 @@ static inline int pnfs_get_read_status(struct nfs_read_data *data)
 	return 0;
 }
 
-/* Set num of remaining bytes, which is everything */
-static inline void pnfs_direct_init_io(struct inode *inode,
-				       struct nfs_open_context *ctx,
-				       size_t count, loff_t loff, int iswrite,
-				       size_t *iosize, size_t *remaining)
-{
-}
-
 static inline int pnfs_use_rpc(struct nfs_server *nfss)
 {
 	return 1;
-- 
1.6.6.1

