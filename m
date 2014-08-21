Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51195 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbaHUQHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:38 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtl-0000AY-0B
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:37 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/19] pnfs/blocklayout: reject pnfs blocksize larger than page size
Date: Thu, 21 Aug 2014 11:09:26 -0500
Message-Id: <1408637375-11343-11-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Linux VM subsystem can't support block sizes larger than page size
for block based filesystems very well.  While this can be hacked around
to some extent for simple filesystems the read-modify-write cycles
required for pnfs block invalid extents are extremly deadlock prone
when operating on multiple pages.  Reject this case early on instead
of pretending to support it (badly).

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index cbb1797..6c1a421 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1115,6 +1115,12 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 		dprintk("%s Server did not return blksize\n", __func__);
 		return -EINVAL;
 	}
+	if (server->pnfs_blksize > PAGE_SIZE) {
+		printk(KERN_ERR "%s: pNFS blksize %d not supported.\n",
+			__func__, server->pnfs_blksize);
+		return -EINVAL;
+	}
+
 	b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_NOFS);
 	if (!b_mt_id) {
 		status = -ENOMEM;
-- 
1.9.1

