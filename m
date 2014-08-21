Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51175 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaHUQHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:22 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtV-00008t-2I
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:21 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/19] pnfs: do not pass uninitialized lsegs to ->free_lseg
Date: Thu, 21 Aug 2014 11:09:18 -0500
Message-Id: <1408637375-11343-3-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure the lsegs are initialized early so that we don't pass an unitialized
one back to ->free_lseg during error processing.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pnfs.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a3851de..6e0fa71 100644
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

