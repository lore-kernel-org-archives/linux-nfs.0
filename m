Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:59583 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932385AbaDXSQC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:16:02 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so1224672igb.5
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:16:01 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 16/18 v2] pnfs: allow non page aligned pnfs layout segments
Date: Thu, 24 Apr 2014 14:15:26 -0400
Message-Id: <1398363328-7100-17-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove alignment checks that would revert to MDS and change pg_test
to return the max ammount left in the segment (or other pg_test call)
up to size of passed request, or 0 if no space is left.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pnfs.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6ef108b..ce46a41 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1388,11 +1388,6 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 
 	WARN_ON_ONCE(pgio->pg_lseg != NULL);
 
-	if (req->wb_offset != req->wb_pgbase) {
-		nfs_pageio_reset_read_mds(pgio);
-		return;
-	}
-
 	if (pgio->pg_dreq == NULL)
 		rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
 	else
@@ -1417,11 +1412,6 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	WARN_ON_ONCE(pgio->pg_lseg != NULL);
 
-	if (req->wb_offset != req->wb_pgbase) {
-		nfs_pageio_reset_write_mds(pgio);
-		return;
-	}
-
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   req_offset(req),
@@ -1443,9 +1433,9 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		     struct nfs_page *req)
 {
 	unsigned int size;
+	u64 end;
 
 	size = nfs_generic_pg_test(pgio, prev, req);
-
 	if (!size)
 		return 0;
 
@@ -1463,11 +1453,16 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	 * first byte that lies outside the pnfs_layout_range. FIXME?
 	 *
 	 */
-	if (req_offset(req) >= end_offset(pgio->pg_lseg->pls_range.offset,
-					 pgio->pg_lseg->pls_range.length))
-		return 0;
+	if (pgio->pg_lseg) {
+		end = end_offset(pgio->pg_lseg->pls_range.offset,
+				 pgio->pg_lseg->pls_range.length);
+		WARN_ON_ONCE(req_offset(req) > end);
+		if (req_offset(req) >= end)
+			return 0;
+		size = min((unsigned int)(end - req_offset(req)), size);
+	}
 
-	return min(size, req->wb_bytes);
+	return size;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
-- 
1.8.5.2 (Apple Git-48)

