Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53133 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbaIKAeR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 20:34:17 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRsL1-00082t-PG
	for linux-nfs@vger.kernel.org; Thu, 11 Sep 2014 00:34:16 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] pnfs/blocklayout: remove some debugging
Date: Wed, 10 Sep 2014 17:36:28 -0700
Message-Id: <1410395791-2385-2-git-send-email-hch@lst.de>
In-Reply-To: <1410395791-2385-1-git-send-email-hch@lst.de>
References: <1410395791-2385-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kbuild test robot complained that we got the printk format wrong.
Let's just kill these printks instead of fixing them as there is not
point after the initial tree algorithm debugging.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/extent_tree.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index f34f61d..43e891b 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -370,9 +370,6 @@ ext_tree_split(struct rb_root *root, struct pnfs_block_extent *be,
 	struct pnfs_block_extent *new;
 	sector_t orig_len = be->be_length;
 
-	dprintk("%s: need split for 0x%lx:0x%lx at 0x%lx\n",
-		__func__, be->be_f_offset, ext_f_end(be), split);
-
 	new = kzalloc(sizeof(*new), GFP_ATOMIC);
 	if (!new)
 		return -ENOMEM;
@@ -387,11 +384,6 @@ ext_tree_split(struct rb_root *root, struct pnfs_block_extent *be,
 	new->be_tag = be->be_tag;
 	new->be_device = nfs4_get_deviceid(be->be_device);
 
-	dprintk("%s: got 0x%lx:0x%lx!\n",
-		__func__, be->be_f_offset, ext_f_end(be));
-	dprintk("%s: got 0x%lx:0x%lx!\n",
-		__func__, new->be_f_offset, ext_f_end(new));
-
 	__ext_tree_insert(root, new, false);
 	return 0;
 }
-- 
1.9.1

