Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34146 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811AbcEYObq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 10:31:46 -0400
Received: by mail-pa0-f49.google.com with SMTP id qo8so18357815pab.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2016 07:31:46 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [V2 2/3] nfs/flexfiles: Use the layout segment for reading unless it a IOMODE_RW and reading is disabled
Date: Wed, 25 May 2016 07:31:13 -0700
Message-Id: <1464186674-104401-3-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1464186674-104401-1-git-send-email-loghyr@primarydata.com>
References: <1464186674-104401-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 40bccb2..a7aeb74 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -830,7 +830,8 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	int ds_idx;
 
 	/* Use full layout for now */
-	if (!pgio->pg_lseg) {
+	if (!pgio->pg_lseg || ff_layout_avoid_read_on_rw(pgio->pg_lseg)) {
+		pnfs_put_lseg(pgio->pg_lseg);
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   req->wb_context,
 						   0,
@@ -840,9 +841,9 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
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

