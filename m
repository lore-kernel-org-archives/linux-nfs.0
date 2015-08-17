Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42552 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbbHQQoD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 12:44:03 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] pnfs/blocklayout: calculate layoutupdate size correctly
Date: Mon, 17 Aug 2015 18:40:57 +0200
Message-Id: <1439829661-1505-2-git-send-email-hch@lst.de>
In-Reply-To: <1439829661-1505-1-git-send-email-hch@lst.de>
References: <1439829661-1505-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to include the first u32 for the number of entries.  Add a helper
for the calculation instead of opencoding it so that it's in one place.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/extent_tree.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 31d0b5e..7536036 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -462,6 +462,12 @@ out:
 	return err;
 }
 
+static size_t ext_tree_layoutupdate_size(size_t count)
+{
+	return sizeof(__be32) /* number of entries */ +
+		BL_EXTENT_SIZE * count;
+}
+
 static void ext_tree_free_commitdata(struct nfs4_layoutcommit_args *arg,
 		size_t buffer_size)
 {
@@ -489,7 +495,7 @@ static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
 			continue;
 
 		(*count)++;
-		if (*count * BL_EXTENT_SIZE > buffer_size) {
+		if (ext_tree_layoutupdate_size(*count) > buffer_size) {
 			/* keep counting.. */
 			ret = -ENOSPC;
 			continue;
@@ -530,7 +536,7 @@ retry:
 	if (unlikely(ret)) {
 		ext_tree_free_commitdata(arg, buffer_size);
 
-		buffer_size = sizeof(__be32) + BL_EXTENT_SIZE * count;
+		buffer_size = ext_tree_layoutupdate_size(count);
 		count = 0;
 
 		arg->layoutupdate_pages =
@@ -549,7 +555,7 @@ retry:
 	}
 
 	*start_p = cpu_to_be32(count);
-	arg->layoutupdate_len = sizeof(__be32) + BL_EXTENT_SIZE * count;
+	arg->layoutupdate_len = ext_tree_layoutupdate_size(count);
 
 	if (unlikely(arg->layoutupdate_pages != &arg->layoutupdate_page)) {
 		__be32 *p = start_p;
-- 
1.9.1

