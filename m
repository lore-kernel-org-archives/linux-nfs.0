Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42264 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056Ab2DTXzt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 19:55:49 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v4 18/25] NFS: prepare coalesce testing for directio
Date: Fri, 20 Apr 2012 19:55:31 -0400
Message-Id: <1334966131-7232-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The coalesce code made assumptions that will no longer be true once
non-page aligned io occurs.  This introduces no change in
current behavior, but allows for more general situations to come.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   12 ++++++++++++
 fs/nfs/pagelist.c       |    4 ++--
 fs/nfs/pnfs.c           |    8 ++++++++
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 02d8170..e40523f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -796,6 +796,16 @@ filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
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
@@ -815,6 +825,8 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 
 	BUG_ON(pgio->pg_lseg != NULL);
 
+	if (req->wb_offset != req->wb_pgbase)
+		goto out_mds;
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   0,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 5d01a16..638ca7f 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -280,12 +280,12 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 		return false;
 	if (req->wb_context->state != prev->wb_context->state)
 		return false;
-	if (req->wb_index != (prev->wb_index + 1))
-		return false;
 	if (req->wb_pgbase != 0)
 		return false;
 	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
 		return false;
+	if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
+		return false;
 	return pgio->pg_ops->pg_test(pgio, prev, req);
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4fa43e0..5e11557 100644
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

