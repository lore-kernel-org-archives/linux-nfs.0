Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36584 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759219Ab2CMTTV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Mar 2012 15:19:21 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] NFS4: remove erroneous BUG_ONs in file layout pg_init functions
Date: Tue, 13 Mar 2012 15:19:19 -0400
Message-Id: <1331666359-11534-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These BUG_ONs assume that pg_init is called once per nfs_pageio_descriptor,
yet it is actually called once per attempted RPC call.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c7496b6..3c2ee2f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -757,7 +757,7 @@ void
 filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
 {
-	BUG_ON(pgio->pg_lseg != NULL);
+	struct pnfs_layout_segment *old = pgio->pg_lseg;
 
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
@@ -765,6 +765,7 @@ filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 					   NFS4_MAX_UINT64,
 					   IOMODE_READ,
 					   GFP_KERNEL);
+	put_lseg(old);
 	/* If no lseg, fall back to read through mds */
 	if (pgio->pg_lseg == NULL)
 		nfs_pageio_reset_read_mds(pgio);
@@ -774,7 +775,7 @@ void
 filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			 struct nfs_page *req)
 {
-	BUG_ON(pgio->pg_lseg != NULL);
+	struct pnfs_layout_segment *old = pgio->pg_lseg;
 
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
@@ -782,6 +783,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 					   NFS4_MAX_UINT64,
 					   IOMODE_RW,
 					   GFP_NOFS);
+	put_lseg(old);
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
 		nfs_pageio_reset_write_mds(pgio);
-- 
1.7.2.1

