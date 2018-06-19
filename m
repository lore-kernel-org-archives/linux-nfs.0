Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755865AbeFSI50 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Jun 2018 04:57:26 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: bfields@fieldses.org, Jeff Layton <jlayton@kernel.org>,
        Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: don't advertise a SCSI layout for an unsupported request_queue
Date: Tue, 19 Jun 2018 04:57:24 -0400
Message-Id: <be316794f70ba6e4b2e0314cd6fca9ad2447cdc2.1529398437.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 30181faae37f ("nfsd: Check queue type before submitting a SCSI
request") did the work of ensuring that we don't send SCSI requests to a
request queue that won't support them, but that check is in the
GETDEVICEINFO path.  Let's not set the SCSI layout in fs_layout_type in the
first place, and then we'll have less clients sending GETDEVICEINFO for
non-SCSI request queues and less unnecessary WARN_ONs.

While we're in here, remove some outdated comments that refer to
"overwriting" layout seletion because commit 8a4c3926889e ("nfsd: allow
nfsd to advertise multiple layout types") changed things to no longer
overwrite the layout type.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfsd/nfs4layouts.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 7d888369f85a..0ba7d3150213 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -133,27 +133,20 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 	if (!(exp->ex_flags & NFSEXP_PNFS))
 		return;
 
-	/*
-	 * If flex file is configured, use it by default. Otherwise
-	 * check if the file system supports exporting a block-like layout.
-	 * If the block device supports reservations prefer the SCSI layout,
-	 * otherwise advertise the block layout.
-	 */
 #ifdef CONFIG_NFSD_FLEXFILELAYOUT
 	exp->ex_layout_types |= 1 << LAYOUT_FLEX_FILES;
 #endif
 #ifdef CONFIG_NFSD_BLOCKLAYOUT
-	/* overwrite flex file layout selection if needed */
 	if (sb->s_export_op->get_uuid &&
 	    sb->s_export_op->map_blocks &&
 	    sb->s_export_op->commit_blocks)
 		exp->ex_layout_types |= 1 << LAYOUT_BLOCK_VOLUME;
 #endif
 #ifdef CONFIG_NFSD_SCSILAYOUT
-	/* overwrite block layout selection if needed */
 	if (sb->s_export_op->map_blocks &&
 	    sb->s_export_op->commit_blocks &&
-	    sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
+	    sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops &&
+		blk_queue_scsi_passthrough(sb->s_bdev->bd_disk->queue))
 		exp->ex_layout_types |= 1 << LAYOUT_SCSI;
 #endif
 }
-- 
2.14.3

