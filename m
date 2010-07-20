From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] SQUASHME: pnfs-obj: use new write_pagelist api
Date: Tue, 20 Jul 2010 08:58:58 +0300
Message-ID: <1279605538-7619-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61854 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754693Ab0GTF7A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:59:00 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index c7daa16..e8ea910 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -442,23 +442,22 @@ objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
  * Perform sync or async writes.
  */
 enum pnfs_try_status
-objlayout_write_pagelist(struct pnfs_layout_type *pnfs_layout_type,
-			 struct page **pages,
-			 unsigned pgbase,
+objlayout_write_pagelist(struct nfs_write_data *wdata,
 			 unsigned nr_pages,
-			 loff_t offset,
-			 size_t count,
-			 int how,
-			 struct nfs_write_data *wdata)
+			 int how)
 {
 	struct objlayout_io_state *state;
 	ssize_t status;
 
-	dprintk("%s: Begin inode %p offset %llu count %d\n",
-		__func__, PNFS_INODE(pnfs_layout_type), offset, (int)count);
+	dprintk("%s: Begin inode %p offset %llu count %u\n",
+		__func__, wdata->inode, wdata->args.offset, wdata->args.count);
 
-	state = objlayout_alloc_io_state(pnfs_layout_type, pages, pgbase,
-					 nr_pages, offset, count,
+	state = objlayout_alloc_io_state(NFS_I(wdata->inode)->layout,
+					 wdata->args.pages,
+					 wdata->args.pgbase,
+					 nr_pages,
+					 wdata->args.offset,
+					 wdata->args.count,
 					 wdata->pdata.lseg, wdata);
 	if (unlikely(!state)) {
 		status = -ENOMEM;
-- 
1.7.1.1

