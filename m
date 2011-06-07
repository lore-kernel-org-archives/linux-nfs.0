Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:44014 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757431Ab1FGRfb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:31 -0400
Date: Tue, 7 Jun 2011 13:35:30 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 82/88] SQUASHME: pnfs-block: fixup encode_layoutcommit
 arguments
Message-ID: <0069c4560794907aa1db9c01546ca80702b0a9cb.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    2 +-
 fs/nfs/blocklayout/blocklayout.h |    2 +-
 fs/nfs/blocklayout/extents.c     |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 1865392..39f3896 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -645,7 +645,7 @@ bl_setup_layoutcommit(struct pnfs_layout_hdr *lo,
 
 static void
 bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
-		       const struct nfs4_layoutcommit_args *arg)
+		       const struct nfs4_layoutcommit_op_args *arg)
 {
 	dprintk("%s enter\n", __func__);
 	encode_pnfs_block_layoutupdate(BLK_LO2EXT(lo), xdr, arg);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 4266ae7..058c198 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -276,7 +276,7 @@ struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
 int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
 int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   struct xdr_stream *xdr,
-				   const struct nfs4_layoutcommit_args *arg);
+				   const struct nfs4_layoutcommit_op_args *arg);
 void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   const struct nfs4_layoutcommit_op_args *arg,
 				   int status);
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 0ff65f3..cd32935 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -738,7 +738,7 @@ find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
 int
 encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 			       struct xdr_stream *xdr,
-			       const struct nfs4_layoutcommit_args *arg)
+			       const struct nfs4_layoutcommit_op_args *arg)
 {
 	sector_t start, end;
 	struct pnfs_block_short_extent *lce, *save;
-- 
1.7.4.1

