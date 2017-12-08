Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60532 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753115AbdLHRxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Dec 2017 12:53:00 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 3/3] pnfs/blocklayout: handle transient devices
Date: Fri,  8 Dec 2017 12:52:59 -0500
Message-Id: <a07f47bf74db804b355381bd0f6415fe70d6a956.1512748321.git.bcodding@redhat.com>
In-Reply-To: <cover.1512748321.git.bcodding@redhat.com>
References: <cover.1512748321.git.bcodding@redhat.com>
In-Reply-To: <cover.1512748321.git.bcodding@redhat.com>
References: <cover.1512748321.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PNFS block/SCSI layouts should gracefully handle cases where block devices
are not available when a layout is retrieved, or the block devices are
removed while the client holds a layout.

While setting up a layout segment, keep a record of an unavailable or
un-parsable block device in cache with a flag so that subsequent layouts do
not spam the server with GETDEVINFO.  We can reuse the current
NFS_DEVICEID_UNAVAILABLE handling with one variation: instead of reusing
the device, we will discard it and send a fresh GETDEVINFO after the
timeout, since the lookup and validation of the device occurs within the
GETDEVINFO response handling.

A lookup of a layout segment that references an unavailable device will
return a segment with the NFS_LSEG_UNAVAILABLE flag set.  This will allow
the pgio layer to mark the layout with the appropriate fail bit, which
forces subsequent IO to the MDS, and prevents spamming the server with
LAYOUTGET, LAYOUTRETURN.

Finally, when IO to a block device fails, look up the block device(s)
referenced by the pgio header, and mark them as unavailable.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c | 82 +++++++++++++++++++++++++++++++++++++---
 fs/nfs/blocklayout/dev.c         |  7 +---
 fs/nfs/pnfs.c                    |  2 +-
 fs/nfs/pnfs.h                    |  2 +
 fs/nfs/pnfs_dev.c                |  1 -
 5 files changed, 82 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index f66c9f2816a5..f2e9cbfa3432 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -184,6 +184,29 @@ do_add_page_to_bio(struct bio *bio, int npg, int rw, sector_t isect,
 	return bio;
 }
 
+static void bl_mark_devices_unavailable(struct nfs_pgio_header *header, bool rw)
+{
+	struct pnfs_block_layout *bl = BLK_LSEG2EXT(header->lseg);
+	size_t bytes_left = header->args.count;
+	sector_t isect, extent_length = 0;
+	struct pnfs_block_extent be;
+
+	isect = header->args.offset >> SECTOR_SHIFT;
+	bytes_left += header->args.offset - (isect << SECTOR_SHIFT);
+
+	while (bytes_left > 0) {
+		if (!ext_tree_lookup(bl, isect, &be, rw))
+				return;
+		extent_length = be.be_length - (isect - be.be_f_offset);
+		nfs4_mark_deviceid_unavailable(be.be_device);
+		isect += extent_length;
+		if (bytes_left > extent_length << SECTOR_SHIFT)
+			bytes_left -= extent_length << SECTOR_SHIFT;
+		else
+			bytes_left = 0;
+	}
+}
+
 static void bl_end_io_read(struct bio *bio)
 {
 	struct parallel_io *par = bio->bi_private;
@@ -194,6 +217,7 @@ static void bl_end_io_read(struct bio *bio)
 		if (!header->pnfs_error)
 			header->pnfs_error = -EIO;
 		pnfs_set_lo_fail(header->lseg);
+		bl_mark_devices_unavailable(header, false);
 	}
 
 	bio_put(bio);
@@ -323,6 +347,7 @@ static void bl_end_io_write(struct bio *bio)
 		if (!header->pnfs_error)
 			header->pnfs_error = -EIO;
 		pnfs_set_lo_fail(header->lseg);
+		bl_mark_devices_unavailable(header, true);
 	}
 	bio_put(bio);
 	put_parallel(par);
@@ -552,6 +577,31 @@ static int decode_sector_number(__be32 **rp, sector_t *sp)
 	return 0;
 }
 
+static struct nfs4_deviceid_node *
+bl_find_get_deviceid(struct nfs_server *server,
+		const struct nfs4_deviceid *id, struct rpc_cred *cred,
+		gfp_t gfp_mask)
+{
+	struct nfs4_deviceid_node *node;
+	unsigned long start, end;
+
+retry:
+	node = nfs4_find_get_deviceid(server, id, cred, gfp_mask);
+	if (!node)
+		return ERR_PTR(-ENODEV);
+
+	if (test_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags) == 0)
+		return node;
+
+	end = jiffies;
+	start = end - PNFS_DEVICE_RETRY_TIMEOUT;
+	if (!time_in_range(node->timestamp_unavailable, start, end)) {
+		nfs4_delete_deviceid(node->ld, node->nfs_client, id);
+		goto retry;
+	}
+	return ERR_PTR(-ENODEV);
+}
+
 static int
 bl_alloc_extent(struct xdr_stream *xdr, struct pnfs_layout_hdr *lo,
 		struct layout_verification *lv, struct list_head *extents,
@@ -573,16 +623,18 @@ bl_alloc_extent(struct xdr_stream *xdr, struct pnfs_layout_hdr *lo,
 	memcpy(&id, p, NFS4_DEVICEID4_SIZE);
 	p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 
-	error = -EIO;
-	be->be_device = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &id,
+	be->be_device = bl_find_get_deviceid(NFS_SERVER(lo->plh_inode), &id,
 						lo->plh_lc_cred, gfp_mask);
-	if (!be->be_device)
+	if (IS_ERR(be->be_device)) {
+		error = PTR_ERR(be->be_device);
 		goto out_free_be;
+	}
 
 	/*
 	 * The next three values are read in as bytes, but stored in the
 	 * extent structure in 512-byte granularity.
 	 */
+	error = -EIO;
 	if (decode_sector_number(&p, &be->be_f_offset) < 0)
 		goto out_put_deviceid;
 	if (decode_sector_number(&p, &be->be_length) < 0)
@@ -692,11 +744,16 @@ bl_alloc_lseg(struct pnfs_layout_hdr *lo, struct nfs4_layoutget_res *lgr,
 	__free_page(scratch);
 out:
 	dprintk("%s returns %d\n", __func__, status);
-	if (status) {
+	switch (status) {
+	case -ENODEV:
+		/* Our extent block devices are unavailable */
+		set_bit(NFS_LSEG_UNAVAILABLE, &lseg->pls_flags);
+	case 0:
+		return lseg;
+	default:
 		kfree(lseg);
 		return ERR_PTR(status);
 	}
-	return lseg;
 }
 
 static void
@@ -798,6 +855,13 @@ bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 	}
 
 	pnfs_generic_pg_init_read(pgio, req);
+
+	if (pgio->pg_lseg &&
+		test_bit(NFS_LSEG_UNAVAILABLE, &pgio->pg_lseg->pls_flags)) {
+		pnfs_error_mark_layout_for_return(pgio->pg_inode, pgio->pg_lseg);
+		pnfs_set_lo_fail(pgio->pg_lseg);
+		nfs_pageio_reset_read_mds(pgio);
+	}
 }
 
 /*
@@ -853,6 +917,14 @@ bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 		wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
 
 	pnfs_generic_pg_init_write(pgio, req, wb_size);
+
+	if (pgio->pg_lseg &&
+		test_bit(NFS_LSEG_UNAVAILABLE, &pgio->pg_lseg->pls_flags)) {
+
+		pnfs_error_mark_layout_for_return(pgio->pg_inode, pgio->pg_lseg);
+		pnfs_set_lo_fail(pgio->pg_lseg);
+		nfs_pageio_reset_write_mds(pgio);
+	}
 }
 
 /*
diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index 4d319098f83b..3c0b3daa49f2 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -538,14 +538,11 @@ bl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 		goto out_free_volumes;
 
 	ret = bl_parse_deviceid(server, top, volumes, nr_volumes - 1, gfp_mask);
-	if (ret) {
-		bl_free_device(top);
-		kfree(top);
-		goto out_free_volumes;
-	}
 
 	node = &top->node;
 	nfs4_init_deviceid_node(node, server, &pdev->dev_id);
+	if (ret)
+		nfs4_mark_deviceid_unavailable(node);
 
 out_free_volumes:
 	kfree(volumes);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c383d0913b54..b9bce42ccba2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -678,7 +678,7 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 		return 0;
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		if (pnfs_match_lseg_recall(lseg, recall_range, seq)) {
-			dprintk("%s: freeing lseg %p iomode %d seq %u"
+			dprintk("%s: freeing lseg %p iomode %d seq %u "
 				"offset %llu length %llu\n", __func__,
 				lseg, lseg->pls_range.iomode, lseg->pls_seq,
 				lseg->pls_range.offset, lseg->pls_range.length);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 4b4120b6824a..74a1032e50d6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -39,6 +39,7 @@ enum {
 	NFS_LSEG_ROC,		/* roc bit received from server */
 	NFS_LSEG_LAYOUTCOMMIT,	/* layoutcommit bit set for layoutcommit */
 	NFS_LSEG_LAYOUTRETURN,	/* layoutreturn bit set for layoutreturn */
+	NFS_LSEG_UNAVAILABLE,	/* unavailable bit set for temporary problem */
 };
 
 /* Individual ip address */
@@ -86,6 +87,7 @@ enum pnfs_try_status {
  */
 #define NFS4_DEF_DS_TIMEO   600 /* in tenths of a second */
 #define NFS4_DEF_DS_RETRANS 5
+#define PNFS_DEVICE_RETRY_TIMEOUT (120*HZ)
 
 /* error codes for internal use */
 #define NFS4ERR_RESET_TO_MDS   12001
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 2961fcd7a2df..e8a07b3f9aaa 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -43,7 +43,6 @@
 #define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
 #define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
 
-#define PNFS_DEVICE_RETRY_TIMEOUT (120*HZ)
 
 static struct hlist_head nfs4_deviceid_cache[NFS4_DEVICE_ID_HASH_SIZE];
 static DEFINE_SPINLOCK(nfs4_deviceid_lock);
-- 
2.9.3

