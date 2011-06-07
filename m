Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:43972 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756691Ab1FGRf0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:26 -0400
Date: Tue, 7 Jun 2011 13:35:24 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 81/88] SQUASHME: pnfs-block: fixup cleanup_layoutcommit
 arguments
Message-ID: <9384871254203cc17eaf6b256dc47049cf57b1f4.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    5 +++--
 fs/nfs/blocklayout/blocklayout.h |    2 +-
 fs/nfs/blocklayout/extents.c     |    2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index ff94ee2..1865392 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -653,10 +653,11 @@ bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
 
 static void
 bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
-			struct nfs4_layoutcommit_args *arg, int status)
+			struct nfs4_layoutcommit_op_args *arg,
+			struct nfs4_layoutcommit_op_res *res)
 {
 	dprintk("%s enter\n", __func__);
-	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), arg, status);
+	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), arg, res->status);
 	kfree(arg->layoutdriver_data);
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 9e7bd62..4266ae7 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -278,7 +278,7 @@ int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   struct xdr_stream *xdr,
 				   const struct nfs4_layoutcommit_args *arg);
 void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
-				   const struct nfs4_layoutcommit_args *arg,
+				   const struct nfs4_layoutcommit_op_args *arg,
 				   int status);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 40dff82..0ff65f3 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -922,7 +922,7 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 
 void
 clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
-			      const struct nfs4_layoutcommit_args *arg,
+			      const struct nfs4_layoutcommit_op_args *arg,
 			      int status)
 {
 	struct bl_layoutupdate_data *bld = arg->layoutdriver_data;
-- 
1.7.4.1

