Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53961 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755935Ab1FGRaI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:30:08 -0400
Date: Tue, 7 Jun 2011 13:30:06 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 35/88] pnfsblock: bl_setup_layoutcommit
Message-ID: <4a06ec26e425a51d092f53fe6358d08bef9e594f.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

In blocklayout driver. There are two things happening
while layoutcommit/cleanup.
1. the modified extents are encoded.
2. On cleanup the extents are put back on the layout rw
   extents list, for reads.

In the new system where actual xdr encoding is done in
encode_layoutcommit() directly into xdr buffer, these are
the new commit stages:

1. On setup_layoutcommit, the range is adjusted as before
   and a structure is allocated for communication with
   bl_encode_layoutcommit && bl_cleanup_layoutcommit
   (Generic layer provides a void-star to hang it on)

2. bl_encode_layoutcommit is called to do the actual
   encoding directly into xdr. The commit-extent-list is not
   freed and is stored on above structure.
   FIXME: The code is not yet converted to the new XDR cleanup

3. On cleanup the commit-extent-list is put back by a call
   to set_to_rw() as before, but with no need for XDR decoding
   of the list as before. And the commit-extent-list is freed.
   Finally allocated structure is freed.

[pnfsblock: fix 64-bit compiler warnings for setup_layoutcommit]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[blocklayout: encode_layoutcommit implementation]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   10 +++++++++-
 fs/nfs/blocklayout/blocklayout.h |   19 +++++++++++++++++++
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d4396d6..0277974 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -625,7 +625,7 @@ bl_setup_layoutcommit(struct pnfs_layout_type *lo,
 		      struct pnfs_layoutcommit_arg *arg)
 {
 	struct nfs_server *nfss = PNFS_NFS_SERVER(lo);
-	struct pnfs_layoutcommit_arg *arg = &data->args;
+	struct bl_layoutupdate_data *layoutupdate_data;
 
 	dprintk("%s enter\n", __func__);
 	/* Need to ensure commit is block-size aligned */
@@ -637,6 +637,14 @@ bl_setup_layoutcommit(struct pnfs_layout_type *lo,
 		arg->lseg.length += offset + mask;
 		arg->lseg.length &= ~mask;
 	}
+
+	layoutupdate_data = kmalloc(sizeof(struct bl_layoutupdate_data),
+					 GFP_KERNEL);
+	if (unlikely(!layoutupdate_data))
+		return -ENOMEM;
+	INIT_LIST_HEAD(&layoutupdate_data->ranges);
+	arg->layoutdriver_data = layoutupdate_data;
+
 	return 0;
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 1ec9bff..780d757 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -181,6 +181,13 @@ struct pnfs_block_layout {
 	sector_t		bl_blocksize;  /* Server blocksize in sectors */
 };
 
+/* this struct is comunicated between:
+ * bl_setup_layoutcommit && bl_encode_layoutcommit && bl_cleanup_layoutcommit
+ */
+struct bl_layoutupdate_data {
+	struct list_head ranges;
+};
+
 #define BLK_ID(lo)     ((struct block_mount_id *)(PNFS_MOUNTID(lo)->mountid))
 #define BLK_LSEG2EXT(lseg) ((struct pnfs_block_layout *)lseg->layout->ld_data)
 #define BLK_LO2EXT(lo) ((struct pnfs_block_layout *)lo->ld_data)
@@ -218,6 +225,18 @@ uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
 	(x) = tmp >> 9; \
 } while (0)
 
+#define WRITE32(n)               do { \
+	*p++ = htonl(n); \
+	} while (0)
+#define WRITE64(n)               do {                           \
+	*p++ = htonl((uint32_t)((n) >> 32));			\
+	*p++ = htonl((uint32_t)(n));				\
+} while (0)
+#define WRITEMEM(ptr, nbytes)     do {                          \
+	p = xdr_encode_opaque_fixed(p, ptr, nbytes);	\
+} while (0)
+#define WRITE_DEVID(x)  WRITEMEM((x)->data, NFS4_PNFS_DEVICEID4_SIZE)
+
 /* blocklayoutdev.c */
 struct block_device *nfs4_blkdev_get(dev_t dev);
 int nfs4_blkdev_put(struct block_device *bdev);
-- 
1.7.4.1

