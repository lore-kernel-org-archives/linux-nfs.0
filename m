Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:44626 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755864AbaIRVJ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2014 17:09:56 -0400
Received: by mail-qg0-f45.google.com with SMTP id j107so1825391qga.32
        for <linux-nfs@vger.kernel.org>; Thu, 18 Sep 2014 14:09:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>, Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] pnfs/blocklayout: Fix a 64-bit division/remainder issue in bl_map_stripe
Date: Thu, 18 Sep 2014 17:09:51 -0400
Message-Id: <1411074591-73466-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kbuild test robot reports:

   fs/built-in.o: In function `bl_map_stripe':
   >> :(.text+0x965b4): undefined reference to `__aeabi_uldivmod'
   >> :(.text+0x965cc): undefined reference to `__aeabi_uldivmod'
   >> :(.text+0x96604): undefined reference to `__aeabi_uldivmod'

Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/blocklayout/dev.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 00f159da06ee..ffe23b0d8a31 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -150,10 +150,13 @@ static bool bl_map_stripe(struct pnfs_block_dev *dev, u64 offset,
 		struct pnfs_block_dev_map *map)
 {
 	struct pnfs_block_dev *child;
-	u64 chunk = (offset / dev->chunk_size);
-	int chunk_idx = chunk % dev->nr_children;
+	u64 chunk;
+	u32 chunk_idx;
 	u64 disk_offset;
 
+	chunk = div_u64(offset, dev->chunk_size);
+	div_u64_rem(chunk, dev->nr_children, &chunk_idx);
+
 	if (chunk_idx > dev->nr_children) {
 		dprintk("%s: invalid chunk idx %d (%lld/%lld)\n",
 			__func__, chunk_idx, offset, dev->chunk_size);
-- 
1.9.3

