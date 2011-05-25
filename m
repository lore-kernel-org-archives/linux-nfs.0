Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57250 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046Ab1EYVaQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2011 17:30:16 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v8 30/32] NFSv4.1: use pnfs_generic_pg_test directly by layout driver
Date: Thu, 26 May 2011 00:30:13 +0300
Message-Id: <1306359013-17950-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDD7392.6040505@panasas.com>
References: <4DDD7392.6040505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c      |    3 +++
 fs/nfs/objlayout/objio_osd.c |   14 +-------------
 fs/nfs/pnfs.c                |   13 +++++++++----
 fs/nfs/pnfs.h                |    6 ++++--
 4 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 24f0572..4269088 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -661,6 +661,9 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	u64 p_stripe, r_stripe;
 	u32 stripe_unit;
 
+	if (!pnfs_generic_pg_test(pgio, prev, req))
+		return 0;
+
 	if (!pgio->pg_lseg)
 		return 1;
 	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index bb68dc0..829a416 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -974,18 +974,6 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
 	return _write_exec(ios);
 }
 
-/*
- * objlayout_pg_test(). Called by nfs_can_coalesce_requests()
- *
- * return true iff coalesce page
- */
-bool
-objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
-		   struct nfs_page *req)
-{
-	return true;
-}
-
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
@@ -999,7 +987,7 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 
 	.read_pagelist           = objlayout_read_pagelist,
 	.write_pagelist          = objlayout_write_pagelist,
-	.pg_test                 = objlayout_pg_test,
+	.pg_test                 = pnfs_generic_pg_test,
 
 	.free_deviceid_node	 = objio_free_deviceid_node,
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7d96e6b..8171212 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1067,12 +1067,17 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 						   pgio->pg_count,
 						   access_type,
 						   gfp_flags);
-	} else if (pgio->pg_lseg &&
-		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
-						pgio->pg_lseg->pls_range.length))
+		return true;
+	}
+
+	if (pgio->pg_lseg &&
+	    req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
+					 pgio->pg_lseg->pls_range.length))
 		return false;
-	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
+
+	return true;
 }
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
 /*
  * Called by non rpc-based layout drivers
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d998d0d..a279969 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -294,8 +294,10 @@ static inline int pnfs_return_layout(struct inode *ino)
 
 static inline void pnfs_pageio_init(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 {
-	if (NFS_SERVER(inode)->pnfs_curr_ld)
-		pgio->pg_test = pnfs_generic_pg_test;
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
+
+	if (ld)
+		pgio->pg_test = ld->pg_test;
 }
 
 #else  /* CONFIG_NFS_V4_1 */
-- 
1.7.3.4

