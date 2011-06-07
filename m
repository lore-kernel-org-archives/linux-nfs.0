Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:44042 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044Ab1FGRfi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:38 -0400
Date: Tue, 7 Jun 2011 13:35:36 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 83/88] SQUASHME: pnfs-block: fixup layoutcommit methods args
Message-ID: <3d0a1f2e487c14932f25ccc4144e6e89a0e06bc7.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   11 +++++------
 fs/nfs/blocklayout/blocklayout.h |    4 ++--
 fs/nfs/blocklayout/extents.c     |    4 ++--
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 39f3896..161c113 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -617,7 +617,7 @@ bl_alloc_lseg(struct pnfs_layout_hdr *lo,
 
 static int
 bl_setup_layoutcommit(struct pnfs_layout_hdr *lo,
-		      struct nfs4_layoutcommit_op_args *arg)
+		      struct nfs4_layoutcommit_args *arg)
 {
 	struct nfs_server *nfss = NFS_SERVER(lo->inode);
 	struct bl_layoutupdate_data *layoutupdate_data;
@@ -645,7 +645,7 @@ bl_setup_layoutcommit(struct pnfs_layout_hdr *lo,
 
 static void
 bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
-		       const struct nfs4_layoutcommit_op_args *arg)
+		       const struct nfs4_layoutcommit_args *arg)
 {
 	dprintk("%s enter\n", __func__);
 	encode_pnfs_block_layoutupdate(BLK_LO2EXT(lo), xdr, arg);
@@ -653,12 +653,11 @@ bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
 
 static void
 bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
-			struct nfs4_layoutcommit_op_args *arg,
-			struct nfs4_layoutcommit_op_res *res)
+			struct nfs4_layoutcommit_data *lcdata)
 {
 	dprintk("%s enter\n", __func__);
-	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), arg, res->status);
-	kfree(arg->layoutdriver_data);
+	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), &lcdata->args, lcdata->res.status);
+	kfree(lcdata->args.layoutdriver_data);
 }
 
 static void free_blk_mountid(struct block_mount_id *mid)
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 058c198..9e7bd62 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -276,9 +276,9 @@ struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
 int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
 int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   struct xdr_stream *xdr,
-				   const struct nfs4_layoutcommit_op_args *arg);
+				   const struct nfs4_layoutcommit_args *arg);
 void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
-				   const struct nfs4_layoutcommit_op_args *arg,
+				   const struct nfs4_layoutcommit_args *arg,
 				   int status);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index cd32935..40dff82 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -738,7 +738,7 @@ find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
 int
 encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 			       struct xdr_stream *xdr,
-			       const struct nfs4_layoutcommit_op_args *arg)
+			       const struct nfs4_layoutcommit_args *arg)
 {
 	sector_t start, end;
 	struct pnfs_block_short_extent *lce, *save;
@@ -922,7 +922,7 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 
 void
 clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
-			      const struct nfs4_layoutcommit_op_args *arg,
+			      const struct nfs4_layoutcommit_args *arg,
 			      int status)
 {
 	struct bl_layoutupdate_data *bld = arg->layoutdriver_data;
-- 
1.7.4.1

