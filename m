Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:57888 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399AbbANJnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 04:43:51 -0500
From: Christoph Hellwig <hch@lst.de>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH 06/12] nilfs2: set up s_bdi like the generic mount_bdev code
Date: Wed, 14 Jan 2015 10:42:35 +0100
Message-Id: <1421228561-16857-7-git-send-email-hch@lst.de>
In-Reply-To: <1421228561-16857-1-git-send-email-hch@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mapping->backing_dev_info will go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Reviewed-by: Tejun Heo <tj@kernel.org>
---
 fs/nilfs2/super.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nilfs2/super.c b/fs/nilfs2/super.c
index 2e5b3ec..3d4bbac 100644
--- a/fs/nilfs2/super.c
+++ b/fs/nilfs2/super.c
@@ -1057,7 +1057,6 @@ nilfs_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct the_nilfs *nilfs;
 	struct nilfs_root *fsroot;
-	struct backing_dev_info *bdi;
 	__u64 cno;
 	int err;
 
@@ -1077,8 +1076,7 @@ nilfs_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_time_gran = 1;
 	sb->s_max_links = NILFS_LINK_MAX;
 
-	bdi = sb->s_bdev->bd_inode->i_mapping->backing_dev_info;
-	sb->s_bdi = bdi ? : &default_backing_dev_info;
+	sb->s_bdi = &bdev_get_queue(sb->s_bdev)->backing_dev_info;
 
 	err = load_nilfs(nilfs, sb);
 	if (err)
-- 
1.9.1

