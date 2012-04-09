Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:54329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758027Ab2DIUw7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:52:59 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/26] NFS: prepare coalesce testing for directio
Date: Mon,  9 Apr 2012 16:52:16 -0400
Message-Id: <1334004744-31842-19-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The coalesce code made assumptions that will no longer be true once
non-page aligned io occurs.  This introduces no change in
current behavior, but allows for more general situations to come.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   17 ++++++++++++++++-
 fs/nfs/pagelist.c       |    4 +---
 fs/nfs/pnfs.c           |    8 ++++++++
 3 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 2c78a46..0afa735 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -779,6 +779,16 @@ filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 {
 	BUG_ON(pgio->pg_lseg != NULL);
 
+	if (req->wb_offset != req->wb_pgbase) {
+		/*
+		 * Handling unaligned pages is difficult, because have to
+		 * somehow split a req in two in certain cases in the
+		 * pg.test code.  Avoid this by just not using pnfs
+		 * in this case.
+		 */
+		nfs_pageio_reset_read_mds(pgio);
+		return;
+	}
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   0,
@@ -796,6 +806,8 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	BUG_ON(pgio->pg_lseg != NULL);
 
+	if (req->wb_offset != req->wb_pgbase)
+		goto out_mds;
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   0,
@@ -804,7 +816,10 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 					   GFP_NOFS);
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_reset_write_mds(pgio);
+		goto out_mds;
+	return;
+out_mds:
+	nfs_pageio_reset_write_mds(pgio);
 }
 
 static const struct nfs_pageio_ops filelayout_pg_read_ops = {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b360d08..bd201d1 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -278,12 +278,10 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 		return false;
 	if (req->wb_context->state != prev->wb_context->state)
 		return false;
-	if (req->wb_index != (prev->wb_index + 1))
+	if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
 		return false;
 	if (req->wb_pgbase != 0)
 		return false;
-	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
-		return false;
 	return pgio->pg_ops->pg_test(pgio, prev, req);
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 02dd84b..da3c183 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1082,6 +1082,10 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 {
 	BUG_ON(pgio->pg_lseg != NULL);
 
+	if (req->wb_offset != req->wb_pgbase) {
+		nfs_pageio_reset_read_mds(pgio);
+		return;
+	}
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   req_offset(req),
@@ -1100,6 +1104,10 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *
 {
 	BUG_ON(pgio->pg_lseg != NULL);
 
+	if (req->wb_offset != req->wb_pgbase) {
+		nfs_pageio_reset_write_mds(pgio);
+		return;
+	}
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   req_offset(req),
-- 
1.7.2.1

