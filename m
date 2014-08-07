Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45775 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbaHGHVh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:37 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger than page size
Date: Thu,  7 Aug 2014 09:23:40 +0200
Message-Id: <1407396229-4785-9-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
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

