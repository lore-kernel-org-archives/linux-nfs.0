Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5591 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809Ab1FJBbH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 21:31:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4.1: Fix some issues with pnfs_generic_pg_test
Date: Thu,  9 Jun 2011 21:30:58 -0400
Message-Id: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

1. If the intention is to coalesce requests 'prev' and 'req' then we
   have to ensure at least that we have a layout starting at
   req_offset(prev).

2. If we're only requesting a minimal layout of length desc->pg_count,
   we need to test the length actually returned by the server before
   we allow the coalescing to occur.

3. We need to deal correctly with (pgio->lseg == NULL)

4. Fixup the test guarding the pnfs_update_layout.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/objlayout/objio_osd.c |    3 +++
 fs/nfs/pnfs.c                |   12 +++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9cf208d..4c41a60 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1001,6 +1001,9 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
 	if (!pnfs_generic_pg_test(pgio, prev, req))
 		return false;
 
+	if (pgio->pg_lseg == NULL)
+		return true;
+
 	return pgio->pg_count + req->wb_bytes <=
 			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8c1309d..12b53ef 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1059,19 +1059,21 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		gfp_flags = GFP_NOFS;
 	}
 
-	if (pgio->pg_count == prev->wb_bytes) {
+	if (pgio->pg_lseg == NULL) {
+		if (pgio->pg_count != prev->wb_bytes)
+			return true;
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   prev->wb_context,
-						   req_offset(req),
+						   req_offset(prev),
 						   pgio->pg_count,
 						   access_type,
 						   gfp_flags);
-		return true;
+		if (pgio->pg_lseg == NULL)
+			return true;
 	}
 
-	if (pgio->pg_lseg &&
-	    req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
+	if (req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
 					 pgio->pg_lseg->pls_range.length))
 		return false;
 
-- 
1.7.5.2

