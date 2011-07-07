Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:53361 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab1GGQ0R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 12:26:17 -0400
Message-Id: <4b112fbbc10c8efbc48d7cc6fb8b30f0643fe899.1310055433.git.rees@umich.edu>
In-Reply-To: <cover.1310055433.git.rees@umich.edu>
References: <cover.1310055433.git.rees@umich.edu>
Subject: [PATCH 4/6] get rid of deprecated xdr macros
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu,  7 Jul 2011 12:26:15 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/blocklayout/blocklayout.h    |   46 +----------------------------------
 fs/nfs/blocklayout/blocklayoutdev.c |   30 +++++++++++++++++-----
 fs/nfs/blocklayout/extents.c        |   10 ++++----
 3 files changed, 29 insertions(+), 57 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 6b7718b..d923acc 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -193,52 +193,8 @@ BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
 	return BLK_LO2EXT(lseg->pls_layout);
 }
 
-uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
-
-#define BLK_READBUF(p, e, nbytes)  do { \
-	p = blk_overflow(p, e, nbytes); \
-	if (!p) { \
-		printk(KERN_WARNING \
-			"%s: reply buffer overflowed in line %d.\n", \
-			__func__, __LINE__); \
-		goto out_err; \
-	} \
-} while (0)
-
-#define READ32(x)         (x) = ntohl(*p++)
-#define READ64(x)         do {                  \
-	(x) = (uint64_t)ntohl(*p++) << 32;           \
-	(x) |= ntohl(*p++);                     \
-} while (0)
-#define COPYMEM(x, nbytes) do {                 \
-	memcpy((x), p, nbytes);                 \
-	p += XDR_QUADLEN(nbytes);               \
-} while (0)
-#define READ_DEVID(x)	COPYMEM((x)->data, NFS4_DEVICEID4_SIZE)
-#define READ_SECTOR(x)     do { \
-	READ64(tmp); \
-	if (tmp & 0x1ff) { \
-		printk(KERN_WARNING \
-		       "%s Value not 512-byte aligned at line %d\n", \
-		       __func__, __LINE__);			     \
-		goto out_err; \
-	} \
-	(x) = tmp >> 9; \
-} while (0)
-
-#define WRITE32(n)               do { \
-	*p++ = htonl(n); \
-	} while (0)
-#define WRITE64(n)               do {                           \
-	*p++ = htonl((uint32_t)((n) >> 32));			\
-	*p++ = htonl((uint32_t)(n));				\
-} while (0)
-#define WRITEMEM(ptr, nbytes)     do {                          \
-	p = xdr_encode_opaque_fixed(p, ptr, nbytes);	\
-} while (0)
-#define WRITE_DEVID(x)  WRITEMEM((x)->data, NFS4_DEVICEID4_SIZE)
-
 /* blocklayoutdev.c */
+uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
 struct block_device *nfs4_blkdev_get(dev_t dev);
 int nfs4_blkdev_put(struct block_device *bdev);
 struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index a90eb6b..4c80a8f 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -49,6 +49,19 @@ uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes)
 }
 EXPORT_SYMBOL(blk_overflow);
 
+static int decode_sector_number(__be32 **rp, sector_t *sp)
+{
+	uint64_t s;
+
+	*rp = xdr_decode_hyper(*rp, &s);
+	if (s & 0x1ff) {
+		printk(KERN_WARNING "%s: sector not aligned\n", __func__);
+		return -1;
+	}
+	*sp = s >> 9;
+	return 0;
+}
+
 /* Open a block_device by device number. */
 struct block_device *nfs4_blkdev_get(dev_t dev)
 {
@@ -241,7 +254,6 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	struct xdr_buf buf;
 	struct page *scratch;
 	__be32 *p;
-	uint64_t tmp; /* Used by READSECTOR */
 	struct layout_verification lv = {
 		.mode = lgr->range.iomode,
 		.start = lgr->range.offset >> 9,
@@ -263,7 +275,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	if (unlikely(!p))
 		goto out_err;
 
-	READ32(count);
+	count = be32_to_cpup(p++);
 
 	dprintk("%s enter, number of extents %i\n", __func__, count);
 	p = xdr_inline_decode(&stream, (28 + NFS4_DEVICEID4_SIZE) * count);
@@ -280,7 +292,8 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 			status = -ENOMEM;
 			goto out_err;
 		}
-		READ_DEVID(&be->be_devid);
+		memcpy(&be->be_devid, p, NFS4_DEVICEID4_SIZE);
+		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 		be->be_mdev = translate_devid(lo, &be->be_devid);
 		if (!be->be_mdev)
 			goto out_err;
@@ -288,10 +301,13 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 		/* The next three values are read in as bytes,
 		 * but stored as 512-byte sector lengths
 		 */
-		READ_SECTOR(be->be_f_offset);
-		READ_SECTOR(be->be_length);
-		READ_SECTOR(be->be_v_offset);
-		READ32(be->be_state);
+		if (decode_sector_number(&p, &be->be_f_offset) < 0)
+			goto out_err;
+		if (decode_sector_number(&p, &be->be_length) < 0)
+			goto out_err;
+		if (decode_sector_number(&p, &be->be_v_offset) < 0)
+			goto out_err;
+		be->be_state = be32_to_cpup(p++);
 		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
 			be->be_inval = &bl->bl_inval;
 		if (verify_extent(be, &lv)) {
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index a62d29f..56cbe9a 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -761,11 +761,11 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
 		if (!p)
 			break;
-		WRITE_DEVID(&lce->bse_devid);
-		WRITE64(lce->bse_f_offset << 9);
-		WRITE64(lce->bse_length << 9);
-		WRITE64(0LL);
-		WRITE32(PNFS_BLOCK_READWRITE_DATA);
+		p = xdr_encode_opaque_fixed(p, lce->bse_devid.data, NFS4_DEVICEID4_SIZE);
+		p = xdr_encode_hyper(p, lce->bse_f_offset << 9);
+		p = xdr_encode_hyper(p, lce->bse_length << 9);
+		p = xdr_encode_hyper(p, 0LL);
+		*p++ = cpu_to_be32(PNFS_BLOCK_READWRITE_DATA);
 		list_del(&lce->bse_node);
 		list_add_tail(&lce->bse_node, ranges);
 		bl->bl_count--;
-- 
1.7.4.1

