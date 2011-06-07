Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53994 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755935Ab1FGRaQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:30:16 -0400
Date: Tue, 7 Jun 2011 13:30:14 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 36/88] pnfsblock: encode_layoutcommit
Message-ID: <b3723a8f69690ecbf022cebcb5bb7f4f1f2ddfad.1307464382.git.rees@umich.edu>
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

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[blocklayout: encode_layoutcommit implementation]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[pnfsblock: fix bug setting up layoutcommit.]
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
[pnfsblock: prevent commit list corruption]
[pnfsblock: fix layoutcommit with an empty opaque]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    1 +
 fs/nfs/blocklayout/blocklayout.h |    3 ++
 fs/nfs/blocklayout/extents.c     |   48 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 0277974..6132e8e 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -653,6 +653,7 @@ bl_encode_layoutcommit(struct pnfs_layout_type *lo, struct xdr_stream *xdr,
 		       const struct pnfs_layoutcommit_arg *arg)
 {
 	dprintk("%s enter\n", __func__);
+	encode_pnfs_block_layoutupdate(BLK_LO2EXT(lo), xdr, arg);
 }
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 780d757..1c110e1 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -263,6 +263,9 @@ void put_extent(struct pnfs_block_extent *be);
 struct pnfs_block_extent *alloc_extent(void);
 struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
 int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
+int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
+				   struct xdr_stream *xdr,
+				   const struct pnfs_layoutcommit_arg *arg);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
 int mark_for_commit(struct pnfs_block_extent *be,
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index d4e4a92..b2f8643 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -680,3 +680,51 @@ find_get_extent(struct pnfs_block_layout *bl, sector_t isect,
 	print_bl_extent(ret);
 	return ret;
 }
+
+int
+encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
+			       struct xdr_stream *xdr,
+			       const struct pnfs_layoutcommit_arg *arg)
+{
+	sector_t start, end;
+	struct pnfs_block_short_extent *lce, *save;
+	unsigned int count;
+	struct bl_layoutupdate_data *bld = arg->layoutdriver_data;
+	struct list_head *ranges = &bld->ranges;
+	__be32 *p, *xdr_start;
+
+	dprintk("%s enter\n", __func__);
+	start = arg->lseg.offset >> 9;
+	end = start + (arg->lseg.length >> 9);
+	dprintk("%s set start=%llu, end=%llu\n",
+		__func__, (u64)start, (u64)end);
+
+	/* BUG - creation of bl_commit is buggy - need to wait for
+	 * entire block to be marked WRITTEN before it can be added.
+	 */
+	spin_lock(&bl->bl_ext_lock);
+	list_splice_init(&bl->bl_commit, ranges);
+	count = bl->bl_count;
+	bl->bl_count = 0;
+	/* Want to adjust for possible truncate */
+	/* We now want to adjust argument range */
+	spin_unlock(&bl->bl_ext_lock);
+
+	dprintk("%s found %i ranges\n", __func__, count);
+	/* XDR encode the ranges found */
+	xdr_start = p = xdr_reserve_space(xdr, 8);
+	p++;
+	WRITE32(count);
+	list_for_each_entry_safe(lce, save, ranges, bse_node) {
+		p = xdr_reserve_space(xdr, 7 * 4 + sizeof(lce->bse_devid.data));
+
+		WRITE_DEVID(&lce->bse_devid);
+		WRITE64(lce->bse_f_offset << 9);
+		WRITE64(lce->bse_length << 9);
+		WRITE64(0LL);
+		WRITE32(PNFS_BLOCK_READWRITE_DATA);
+	}
+
+	*xdr_start = cpu_to_be32((xdr->p - xdr_start - 1) * 4);
+	return 0;
+}
-- 
1.7.4.1

