Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52265 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab1FGRem (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:42 -0400
Date: Tue, 7 Jun 2011 13:34:41 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 74/88] SQUASHME: pnfsblock: use new struct pnfs_layout_hdr
Message-ID: <7f13f28a5666d43be559fdbaf3681a2d61f8101b.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

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
1.7.4.1

