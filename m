Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53766 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab1FGR3k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:29:40 -0400
Date: Tue, 7 Jun 2011 13:29:38 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 32/88] pnfsblock: bl_write_pagelist support functions
Message-ID: <acad7c05f4df4df52f50c2b7ffd1c86fdc4cf2f4.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

[pnfsblock: SQUASHME: adjust to API change]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fixup blksize alignment in bl_setup_layoutcommit]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   32 +++++++++++++++++++++++++++++++-
 1 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index af26bcc..9c46f5a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -73,6 +73,19 @@ static int is_hole(struct pnfs_block_extent *be, sector_t isect)
 		return !is_sector_initialized(be->be_inval, isect);
 }
 
+/* Given the be associated with isect, determine if page data can be
+ * written to disk.
+ */
+static int is_writable(struct pnfs_block_extent *be, sector_t isect)
+{
+	if (be->be_state == PNFS_BLOCK_READWRITE_DATA)
+		return 1;
+	else if (be->be_state != PNFS_BLOCK_INVALID_DATA)
+		return 0;
+	else
+		return is_sector_initialized(be->be_inval, isect);
+}
+
 static int
 dont_like_caller(struct nfs_page *req)
 {
@@ -441,7 +454,19 @@ static int
 bl_setup_layoutcommit(struct pnfs_layout_type *lo,
 		      struct pnfs_layoutcommit_arg *arg)
 {
+	struct nfs_server *nfss = PNFS_NFS_SERVER(lo);
+	struct pnfs_layoutcommit_arg *arg = &data->args;
+
 	dprintk("%s enter\n", __func__);
+	/* Need to ensure commit is block-size aligned */
+	if (nfss->pnfs_blksize) {
+		u64 mask = nfss->pnfs_blksize - 1;
+		u64 offset = arg->lseg.offset & mask;
+
+		arg->lseg.offset -= offset;
+		arg->lseg.length += offset + mask;
+		arg->lseg.length &= ~mask;
+	}
 	return 0;
 }
 
@@ -916,7 +941,12 @@ bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	   struct nfs_page *req)
 {
 	dprintk("%s enter\n", __func__);
-	return 1;
+	if (pgio->pg_iswrite) {
+		return test_bit(PG_USE_PNFS, &prev->wb_flags) ==
+			test_bit(PG_USE_PNFS, &req->wb_flags);
+	} else {
+		return 1;
+	}
 }
 
 /* This checks if old req will likely use same io method as soon
-- 
1.7.4.1

