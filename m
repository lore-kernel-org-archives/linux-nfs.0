Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35495 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab2HMOkc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 10:40:32 -0400
Received: by mail-yx0-f174.google.com with SMTP id l14so1982967yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 07:40:32 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v2 3/3] NFS41: send real read size in layoutget
Date: Mon, 13 Aug 2012 22:39:36 +0800
Message-Id: <1344868776-1739-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344868776-1739-1-git-send-email-bergwolf@gmail.com>
References: <1344868776-1739-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For buffer read, use offst-to-isize.

For direct read, use dreq->bytes_left.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/pnfs.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d1da23a..49d2f2d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1154,16 +1154,24 @@ out_forget_reply:
 void
 pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
+	u64 rd_size = req->wb_bytes;
+
 	BUG_ON(pgio->pg_lseg != NULL);
 
 	if (req->wb_offset != req->wb_pgbase) {
 		nfs_pageio_reset_read_mds(pgio);
 		return;
 	}
+
+	if (pgio->pg_dreq == NULL)
+		rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
+	else
+		rd_size = nfs_dreq_bytes_left(pgio->pg_dreq);
+
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   req_offset(req),
-					   req->wb_bytes,
+					   rd_size,
 					   IOMODE_READ,
 					   GFP_KERNEL);
 	/* If no lseg, fall back to read through mds */
-- 
1.7.1.262.g5ef3d

