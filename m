Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5981 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751363Ab0JEOtT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Oct 2010 10:49:19 -0400
Message-ID: <4CAB3AED.8020907@panasas.com>
Date: Tue, 05 Oct 2010 10:49:17 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] bdi: Initialize inode->i_mapping.backing_dev_info to sb->s_bdi
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Jan Kara <jack@suse.cz>

This patch is needed in pnfs tree for exofs.

Currently, we initialize inode->i_mapping.backing_dev_info to the bdi of device
sb->s_bdev points to. However there is quite a big number of filesystems that
do not set sb->s_bdev (because they do not have one) but do set sb->s_bdi.
These filesystems would generally benefit from setting
inode->i_mapping.backing_dev_info to their s_bdi because otherwise their inodes
would point to default_backing_dev_info and thus dirty inode tracking would
happen there. So change inode initialization code to use sb->s_bdi if it
is available.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/inode.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 8646433..e415be4 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -172,15 +172,21 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	mapping->writeback_index = 0;
 
 	/*
-	 * If the block_device provides a backing_dev_info for client
-	 * inodes then use that.  Otherwise the inode share the bdev's
-	 * backing_dev_info.
+	 * If the filesystem provides a backing_dev_info for client inodes
+	 * then use that. Otherwise inodes share default_backing_dev_info.
 	 */
-	if (sb->s_bdev) {
-		struct backing_dev_info *bdi;
-
-		bdi = sb->s_bdev->bd_inode->i_mapping->backing_dev_info;
-		mapping->backing_dev_info = bdi;
+	if (sb->s_bdi && sb->s_bdi != &noop_backing_dev_info) {
+		/*
+		 * Catch cases where filesystem might be bitten by using s_bdi
+		 * instead of sb->s_bdev. Can be removed in 2.6.38.
+		 */
+		if (sb->s_bdev) {
+			struct backing_dev_info *bdi =
+			  sb->s_bdev->bd_inode->i_mapping->backing_dev_info;
+			WARN(bdi != sb->s_bdi, "s_bdev bdi %s != s_bdi %s\n",
+			     bdi->name, sb->s_bdi->name);
+		}
+		mapping->backing_dev_info = sb->s_bdi;
 	}
 	inode->i_private = NULL;
 	inode->i_mapping = mapping;
-- 
1.7.2

