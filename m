Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42628 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036AbbHQQoR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 12:44:17 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] pnfs: move common blocklayout XDR defintions to nfs4.h
Date: Mon, 17 Aug 2015 18:41:01 +0200
Message-Id: <1439829661-1505-6-git-send-email-hch@lst.de>
In-Reply-To: <1439829661-1505-1-git-send-email-hch@lst.de>
References: <1439829661-1505-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.h | 19 +------------------
 fs/nfs/blocklayout/extent_tree.c |  2 +-
 fs/nfsd/blocklayoutxdr.c         |  2 +-
 fs/nfsd/blocklayoutxdr.h         | 15 ---------------
 include/linux/nfs4.h             | 18 ++++++++++++++++++
 5 files changed, 21 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 92dca9e..c556640 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -46,13 +46,6 @@
 
 struct pnfs_block_dev;
 
-enum pnfs_block_volume_type {
-	PNFS_BLOCK_VOLUME_SIMPLE	= 0,
-	PNFS_BLOCK_VOLUME_SLICE		= 1,
-	PNFS_BLOCK_VOLUME_CONCAT	= 2,
-	PNFS_BLOCK_VOLUME_STRIPE	= 3,
-};
-
 #define PNFS_BLOCK_MAX_UUIDS	4
 #define PNFS_BLOCK_MAX_DEVICES	64
 
@@ -117,13 +110,6 @@ struct pnfs_block_dev {
 			struct pnfs_block_dev_map *map);
 };
 
-enum exstate4 {
-	PNFS_BLOCK_READWRITE_DATA	= 0,
-	PNFS_BLOCK_READ_DATA		= 1,
-	PNFS_BLOCK_INVALID_DATA		= 2, /* mapped, but data is invalid */
-	PNFS_BLOCK_NONE_DATA		= 3  /* unmapped, it's a hole */
-};
-
 /* sector_t fields are all in 512-byte sectors */
 struct pnfs_block_extent {
 	union {
@@ -134,15 +120,12 @@ struct pnfs_block_extent {
 	sector_t	be_f_offset;	/* the starting offset in the file */
 	sector_t	be_length;	/* the size of the extent */
 	sector_t	be_v_offset;	/* the starting offset in the volume */
-	enum exstate4	be_state;	/* the state of this extent */
+	enum pnfs_block_extent_state be_state;	/* the state of this extent */
 #define EXTENT_WRITTEN		1
 #define EXTENT_COMMITTING	2
 	unsigned int	be_tag;
 };
 
-/* on the wire size of the extent */
-#define BL_EXTENT_SIZE	(7 * sizeof(__be32) + NFS4_DEVICEID4_SIZE)
-
 struct pnfs_block_layout {
 	struct pnfs_layout_hdr	bl_layout;
 	struct rb_root		bl_ext_rw;
diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index a11b759..c59a59c 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -465,7 +465,7 @@ out:
 static size_t ext_tree_layoutupdate_size(size_t count)
 {
 	return sizeof(__be32) /* number of entries */ +
-		BL_EXTENT_SIZE * count;
+		PNFS_BLOCK_EXTENT_SIZE * count;
 }
 
 static void ext_tree_free_commitdata(struct nfs4_layoutcommit_args *arg,
diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
index 9aa2796..6d834dc 100644
--- a/fs/nfsd/blocklayoutxdr.c
+++ b/fs/nfsd/blocklayoutxdr.c
@@ -101,7 +101,7 @@ nfsd4_block_decode_layoutupdate(__be32 *p, u32 len, struct iomap **iomapp,
 	}
 
 	nr_iomaps = be32_to_cpup(p++);
-	expected = sizeof(__be32) + nr_iomaps * NFS4_BLOCK_EXTENT_SIZE;
+	expected = sizeof(__be32) + nr_iomaps * PNFS_BLOCK_EXTENT_SIZE;
 	if (len != expected) {
 		dprintk("%s: extent array size mismatch: %u/%u\n",
 			__func__, len, expected);
diff --git a/fs/nfsd/blocklayoutxdr.h b/fs/nfsd/blocklayoutxdr.h
index fdc7903..6de925f 100644
--- a/fs/nfsd/blocklayoutxdr.h
+++ b/fs/nfsd/blocklayoutxdr.h
@@ -7,13 +7,6 @@
 struct iomap;
 struct xdr_stream;
 
-enum pnfs_block_extent_state {
-	PNFS_BLOCK_READWRITE_DATA	= 0,
-	PNFS_BLOCK_READ_DATA		= 1,
-	PNFS_BLOCK_INVALID_DATA		= 2,
-	PNFS_BLOCK_NONE_DATA		= 3,
-};
-
 struct pnfs_block_extent {
 	struct nfsd4_deviceid		vol_id;
 	u64				foff;
@@ -21,14 +14,6 @@ struct pnfs_block_extent {
 	u64				soff;
 	enum pnfs_block_extent_state	es;
 };
-#define NFS4_BLOCK_EXTENT_SIZE		44
-
-enum pnfs_block_volume_type {
-	PNFS_BLOCK_VOLUME_SIMPLE	= 0,
-	PNFS_BLOCK_VOLUME_SLICE		= 1,
-	PNFS_BLOCK_VOLUME_CONCAT	= 2,
-	PNFS_BLOCK_VOLUME_STRIPE	= 3,
-};
 
 /*
  * Random upper cap for the uuid length to avoid unbounded allocation.
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index b8e72aa..00121f2 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -547,6 +547,24 @@ enum pnfs_notify_deviceid_type4 {
 	NOTIFY_DEVICEID4_DELETE = 1 << 2,
 };
 
+enum pnfs_block_volume_type {
+	PNFS_BLOCK_VOLUME_SIMPLE	= 0,
+	PNFS_BLOCK_VOLUME_SLICE		= 1,
+	PNFS_BLOCK_VOLUME_CONCAT	= 2,
+	PNFS_BLOCK_VOLUME_STRIPE	= 3,
+};
+
+enum pnfs_block_extent_state {
+	PNFS_BLOCK_READWRITE_DATA	= 0,
+	PNFS_BLOCK_READ_DATA		= 1,
+	PNFS_BLOCK_INVALID_DATA		= 2,
+	PNFS_BLOCK_NONE_DATA		= 3,
+};
+
+/* on the wire size of a block layout extent */
+#define PNFS_BLOCK_EXTENT_SIZE \
+	(7 * sizeof(__be32) + NFS4_DEVICEID4_SIZE)
+
 #define NFL4_UFLG_MASK			0x0000003F
 #define NFL4_UFLG_DENSE			0x00000001
 #define NFL4_UFLG_COMMIT_THRU_MDS	0x00000002
-- 
1.9.1

