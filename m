Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33349 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbcERVIJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2016 17:08:09 -0400
Received: by mail-pf0-f182.google.com with SMTP id 206so22368610pfu.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 May 2016 14:08:09 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH 2/3] nfs/flexfiles: Use the layout segment for reading unless it a IOMODE_RW and reading is disabled
Date: Wed, 18 May 2016 14:07:55 -0700
Message-Id: <1463605676-82483-3-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
References: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 981b39a..ea24b0a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -852,7 +852,8 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	int ds_idx;
 
 	/* Use full layout for now */
-	if (!pgio->pg_lseg) {
+	if (!pgio->pg_lseg || ff_layout_avoid_read_on_rw(pgio->pg_lseg)) {
+		pnfs_put_lseg(pgio->pg_lseg);
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   req->wb_context,
 						   0,
@@ -862,9 +863,9 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
 			pgio->pg_lseg = NULL;
-			return;
 		}
 	}
+
 	/* If no lseg, fall back to read through mds */
 	if (pgio->pg_lseg == NULL)
 		goto out_mds;
-- 
1.8.3.1

