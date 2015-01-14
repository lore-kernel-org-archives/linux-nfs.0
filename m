Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:57880 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbbANJnu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 04:43:50 -0500
From: Christoph Hellwig <hch@lst.de>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH 05/12] block_dev: get bdev inode bdi directly from the block device
Date: Wed, 14 Jan 2015 10:42:34 +0100
Message-Id: <1421228561-16857-6-git-send-email-hch@lst.de>
In-Reply-To: <1421228561-16857-1-git-send-email-hch@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Directly grab the backing_dev_info from the request_queue instead of
detouring through the address_space.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Tejun Heo <tj@kernel.org>
---
 fs/fs-writeback.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 2d609a5..e8116a4 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -69,10 +69,10 @@ EXPORT_SYMBOL(writeback_in_progress);
 static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
 {
 	struct super_block *sb = inode->i_sb;
-
+#ifdef CONFIG_BLOCK
 	if (sb_is_blkdev_sb(sb))
-		return inode->i_mapping->backing_dev_info;
-
+		return blk_get_backing_dev_info(I_BDEV(inode));
+#endif
 	return sb->s_bdi;
 }
 
-- 
1.9.1

