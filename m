Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48248 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752980Ab0I2LMT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:12:19 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 15/15] SQUASHME: pnfsblock: use new struct pnfs_layout_hdr
Date: Wed, 29 Sep 2010 13:12:17 +0200
Message-Id: <1285758737-27268-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index ac53a3f..23dbe91 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -546,7 +546,7 @@ release_inval_marks(struct pnfs_inval_markings *marks)
 
 /* Note we are relying on caller locking to prevent nasty races. */
 static void
-bl_free_layout(struct pnfs_layout_hdr *lo)
+bl_free_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
 
@@ -557,7 +557,7 @@ bl_free_layout(struct pnfs_layout_hdr *lo)
 }
 
 static struct pnfs_layout_hdr *
-bl_alloc_layout(struct inode *inode)
+bl_alloc_layout_hdr(struct inode *inode)
 {
 	struct pnfs_block_layout	*bl;
 
@@ -1105,15 +1105,17 @@ bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		return 1;
 }
 
-static struct layoutdriver_io_operations blocklayout_io_operations = {
+static struct pnfs_layoutdriver_type blocklayout_type = {
+	.id = LAYOUT_BLOCK_VOLUME,
+	.name = "LAYOUT_BLOCK_VOLUME",
 	.commit				= bl_commit,
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
 	.write_begin			= bl_write_begin,
 	.write_end			= bl_write_end,
 	.write_end_cleanup		= bl_write_end_cleanup,
-	.alloc_layout			= bl_alloc_layout,
-	.free_layout			= bl_free_layout,
+	.alloc_layout_hdr		= bl_alloc_layout_hdr,
+	.free_layout_hdr		= bl_free_layout_hdr,
 	.alloc_lseg			= bl_alloc_lseg,
 	.free_lseg			= bl_free_lseg,
 	.setup_layoutcommit		= bl_setup_layoutcommit,
@@ -1121,20 +1123,10 @@ static struct layoutdriver_io_operations blocklayout_io_operations = {
 	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
 	.initialize_mountpoint		= bl_initialize_mountpoint,
 	.uninitialize_mountpoint	= bl_uninitialize_mountpoint,
-};
-
-static struct layoutdriver_policy_operations blocklayout_policy_operations = {
 	.get_stripesize			= bl_get_stripesize,
 	.pg_test			= bl_pg_test,
 };
 
-static struct pnfs_layoutdriver_type blocklayout_type = {
-	.id = LAYOUT_BLOCK_VOLUME,
-	.name = "LAYOUT_BLOCK_VOLUME",
-	.ld_io_ops = &blocklayout_io_operations,
-	.ld_policy_ops = &blocklayout_policy_operations,
-};
-
 static int __init nfs4blocklayout_init(void)
 {
 	int ret;
-- 
1.7.2.3

