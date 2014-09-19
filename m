Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:61215 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757349AbaISRas (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Sep 2014 13:30:48 -0400
Date: Fri, 19 Sep 2014 13:30:46 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH][linux-next] pnfs/blocklayout: Use do_div for 64 bit divide
 operations
Message-ID: <20140919133046.7d5ad943@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Commit 5c83746a0cf2 "pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing"
added some open coded 64 bit divisions which caused the following
error on 32 bit builds:

fs/built-in.o: In function `bl_map_stripe':
fs/nfs/blocklayout/dev.c:153: undefined reference to `__udivdi3'
fs/nfs/blocklayout/dev.c:154: undefined reference to `__umoddi3'
fs/nfs/blocklayout/dev.c:168: undefined reference to `__udivdi3'

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 fs/nfs/blocklayout/dev.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 00f159da06ee..05d32e2175db 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -150,10 +150,18 @@ static bool bl_map_stripe(struct pnfs_block_dev *dev, u64 offset,
 		struct pnfs_block_dev_map *map)
 {
 	struct pnfs_block_dev *child;
-	u64 chunk = (offset / dev->chunk_size);
-	int chunk_idx = chunk % dev->nr_children;
+	u64 chunk;
+	u64 chunk_tmp;
+	int chunk_idx;
 	u64 disk_offset;
 
+	chunk = offset;
+	/* chunk = offset / dev->chunk_size */
+	do_div(chunk, dev->chunk_size);
+	chunk_tmp = chunk;
+	/* chunk_idx = chunk % dev->nr_children) */
+	chunk_idx = do_div(chunk_tmp, dev->nr_children);
+
 	if (chunk_idx > dev->nr_children) {
 		dprintk("%s: invalid chunk idx %d (%lld/%lld)\n",
 			__func__, chunk_idx, offset, dev->chunk_size);
@@ -165,7 +173,9 @@ static bool bl_map_stripe(struct pnfs_block_dev *dev, u64 offset,
 	offset = chunk * dev->chunk_size;
 
 	/* disk offset of the stripe */
-	disk_offset = offset / dev->nr_children;
+	disk_offset = offset;
+	/* disk_offset = offset / dev->nr_children */
+	do_div(disk_offset, dev->nr_children);
 
 	child = &dev->children[chunk_idx];
 	child->map(child, disk_offset, map);
-- 
1.8.1.4

