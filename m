Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16546 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758AbaETSI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 02/12] nfs: Create a common pnfs_generic_pg_init() function
Date: Tue, 20 May 2014 14:08:09 -0400
Message-ID: <1400609299-32558-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most of this code can be shared.  There are some differences with
calculating bsize, but that needs to be changed in the layout drivers
that call the read and write versions of this function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 61 +++++++++++++++++++++++++++--------------------------------
 1 file changed, 28 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8da7ff6..4d57003 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1387,48 +1387,22 @@ void pnfs_pageio_reset_mds(struct nfs_pageio_descriptor *pgio)
 }
 EXPORT_SYMBOL_GPL(pnfs_pageio_reset_mds);
 
-void
-pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
-{
-	u64 rd_size = req->wb_bytes;
-
-	WARN_ON_ONCE(pgio->pg_lseg != NULL);
-
-	if (pgio->pg_dreq == NULL)
-		rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
-	else
-		rd_size = nfs_dreq_bytes_left(pgio->pg_dreq);
-
-	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-					   req->wb_context,
-					   req_offset(req),
-					   rd_size,
-					   IOMODE_READ,
-					   GFP_KERNEL);
-	/* If no lseg, fall back to read through mds */
-	if (pgio->pg_lseg == NULL)
-		pnfs_pageio_reset_mds(pgio);
-
-}
-EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
-
-void
-pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
-			   struct nfs_page *req, u64 wb_size)
+static void pnfs_generic_pg_init(struct nfs_pageio_descriptor *pgio,
+				 struct nfs_page *req, u64 bsize,
+				 enum pnfs_iomode iomode, gfp_t gfp_flags)
 {
 	WARN_ON_ONCE(pgio->pg_lseg != NULL);
 
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   req_offset(req),
-					   wb_size,
-					   IOMODE_RW,
-					   GFP_NOFS);
-	/* If no lseg, fall back to write through mds */
+					   bsize,
+					   iomode,
+					   gfp_flags);
+	/* If no lseg, fall back to IO through mds */
 	if (pgio->pg_lseg == NULL)
 		pnfs_pageio_reset_mds(pgio);
 }
-EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
 /*
  * Return 0 if @req cannot be coalesced into @pgio, otherwise return the number
@@ -1472,6 +1446,14 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
+void
+pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
+			   struct nfs_page *req, u64 wb_size)
+{
+	pnfs_generic_pg_init(pgio, req, wb_size, IOMODE_RW, GFP_NOFS);
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
+
 int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *hdr)
 {
 	struct nfs_pageio_descriptor pgio;
@@ -1590,6 +1572,19 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 
+void
+pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	u64 rd_size;
+	if (pgio->pg_dreq == NULL)
+		rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
+	else
+		rd_size = nfs_dreq_bytes_left(pgio->pg_dreq);
+
+	pnfs_generic_pg_init(pgio, req, rd_size, IOMODE_READ, GFP_KERNEL);
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
+
 int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *hdr)
 {
 	struct nfs_pageio_descriptor pgio;
-- 
1.9.2

