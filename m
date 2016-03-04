Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46867 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759341AbcCDTqW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 14:46:22 -0500
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] nfs4.h: add SCSI layout defintions
Date: Fri,  4 Mar 2016 20:46:14 +0100
Message-Id: <1457120777-30687-2-git-send-email-hch@lst.de>
In-Reply-To: <1457120777-30687-1-git-send-email-hch@lst.de>
References: <1457120777-30687-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Based on draft-ietf-nfsv4-scsi-layout-05 after the WG last call.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/nfs4.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index d6f9b4e..0114334 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -529,6 +529,7 @@ enum pnfs_layouttype {
 	LAYOUT_OSD2_OBJECTS = 2,
 	LAYOUT_BLOCK_VOLUME = 3,
 	LAYOUT_FLEX_FILES = 4,
+	LAYOUT_SCSI = 5,
 	LAYOUT_TYPE_MAX
 };
 
@@ -555,6 +556,7 @@ enum pnfs_block_volume_type {
 	PNFS_BLOCK_VOLUME_SLICE		= 1,
 	PNFS_BLOCK_VOLUME_CONCAT	= 2,
 	PNFS_BLOCK_VOLUME_STRIPE	= 3,
+	PNFS_BLOCK_VOLUME_SCSI		= 4,
 };
 
 enum pnfs_block_extent_state {
@@ -568,6 +570,23 @@ enum pnfs_block_extent_state {
 #define PNFS_BLOCK_EXTENT_SIZE \
 	(7 * sizeof(__be32) + NFS4_DEVICEID4_SIZE)
 
+/* on the wire size of a scsi commit range */
+#define PNFS_SCSI_RANGE_SIZE \
+	(4 * sizeof(__be32))
+
+enum scsi_code_set {
+	PS_CODE_SET_BINARY	= 1,
+	PS_CODE_SET_ASCII	= 2,
+	PS_CODE_SET_UTF8	= 3
+};
+
+enum scsi_designator_type {
+	PS_DESIGNATOR_T10	= 1,
+	PS_DESIGNATOR_EUI64	= 2,
+	PS_DESIGNATOR_NAA	= 3,
+	PS_DESIGNATOR_NAME	= 8
+};
+
 #define NFL4_UFLG_MASK			0x0000003F
 #define NFL4_UFLG_DENSE			0x00000001
 #define NFL4_UFLG_COMMIT_THRU_MDS	0x00000002
-- 
2.1.4

