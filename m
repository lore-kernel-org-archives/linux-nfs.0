Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34991 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965375AbbBBWll (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:41:41 -0500
Received: by mail-pa0-f43.google.com with SMTP id eu11so87915128pac.2
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:41:41 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 52/53] nfs41: .init_read and .init_write can be called with valid pg_lseg
Date: Mon,  2 Feb 2015 14:39:06 -0800
Message-Id: <1422916747-86649-53-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

With pgio refactoring in v3.15, .init_read and .init_write can be
called with valid pgio->pg_lseg. file layout was fixed at that time
by commit c6194271f (pnfs: filelayout: support non page aligned
layouts). But the generic helper still needs to be fixed.

Cc: stable@vger.kernel.org # 3.15+
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c | 41 ++++++++++++++++++++---------------------
 1 file changed, 20 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0fb0f19..c7be9b9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1711,19 +1711,19 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 {
 	u64 rd_size = req->wb_bytes;
 
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
+	if (pgio->pg_lseg == NULL) {
+		if (pgio->pg_dreq == NULL)
+			rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
+		else
+			rd_size = nfs_dreq_bytes_left(pgio->pg_dreq);
+
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+						   req->wb_context,
+						   req_offset(req),
+						   rd_size,
+						   IOMODE_READ,
+						   GFP_KERNEL);
+	}
 	/* If no lseg, fall back to read through mds */
 	if (pgio->pg_lseg == NULL)
 		nfs_pageio_reset_read_mds(pgio);
@@ -1735,14 +1735,13 @@ void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
 {
-	WARN_ON_ONCE(pgio->pg_lseg != NULL);
-
-	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-					   req->wb_context,
-					   req_offset(req),
-					   wb_size,
-					   IOMODE_RW,
-					   GFP_NOFS);
+	if (pgio->pg_lseg == NULL)
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+						   req->wb_context,
+						   req_offset(req),
+						   wb_size,
+						   IOMODE_RW,
+						   GFP_NOFS);
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
 		nfs_pageio_reset_write_mds(pgio);
-- 
1.9.3

