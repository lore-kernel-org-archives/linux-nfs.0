Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45763 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbaHGHVc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:32 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/17] pnfs: do not pass uninitialized lsegs to ->free_lseg
Date: Thu,  7 Aug 2014 09:23:34 +0200
Message-Id: <1407396229-4785-3-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure the lsegs are initialized early so that we don't pass an unitialized
one back to ->free_lseg during error processing.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pnfs.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4e85315..6d01740 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1358,6 +1358,9 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out;
 	}
 
+	init_lseg(lo, lseg);
+	lseg->pls_range = res->range;
+
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
 		dprintk("%s forget reply due to recall\n", __func__);
@@ -1375,8 +1378,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	/* Done processing layoutget. Set the layout stateid */
 	pnfs_set_layout_stateid(lo, &res->stateid, false);
 
-	init_lseg(lo, lseg);
-	lseg->pls_range = res->range;
 	pnfs_get_lseg(lseg);
 	pnfs_layout_insert_lseg(lo, lseg);
 
-- 
1.9.1

