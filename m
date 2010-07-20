From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/3] SQAUSHME: pnfs-obj: use new read_pagelist api
Date: Tue, 20 Jul 2010 08:58:50 +0300
Message-ID: <1279605530-7585-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
Cc: andros@netapp.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22890 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754693Ab0GTF6x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 01:58:53 -0400
In-Reply-To: <4C453A50.7070009@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objlayout.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 6595bfc..c7daa16 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -352,23 +352,18 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
  * Perform sync or async reads.
  */
 enum pnfs_try_status
-objlayout_read_pagelist(struct pnfs_layout_type *pnfs_layout_type,
-			struct page **pages,
-			unsigned pgbase,
-			unsigned nr_pages,
-			loff_t offset,
-			size_t count,
-			struct nfs_read_data *rdata)
+objlayout_read_pagelist(struct nfs_read_data *rdata, unsigned nr_pages)
 {
-	struct inode *inode = PNFS_INODE(pnfs_layout_type);
+	loff_t offset = rdata->args.offset;
+	size_t count = rdata->args.count;
 	struct objlayout_io_state *state;
 	ssize_t status = 0;
 	loff_t eof;
 
 	dprintk("%s: Begin inode %p offset %llu count %d\n",
-		__func__, inode, offset, (int)count);
+		__func__, rdata->inode, offset, (int)count);
 
-	eof = i_size_read(inode);
+	eof = i_size_read(rdata->inode);
 	if (unlikely(offset + count > eof)) {
 		if (offset >= eof) {
 			status = 0;
@@ -379,7 +374,8 @@ objlayout_read_pagelist(struct pnfs_layout_type *pnfs_layout_type,
 		count = eof - offset;
 	}
 
-	state = objlayout_alloc_io_state(pnfs_layout_type, pages, pgbase,
+	state = objlayout_alloc_io_state(NFS_I(rdata->inode)->layout,
+					 rdata->args.pages, rdata->args.pgbase,
 					 nr_pages, offset, count,
 					 rdata->pdata.lseg, rdata);
 	if (unlikely(!state)) {
-- 
1.7.1.1

