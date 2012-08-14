Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38437 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab2HNNyS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 09:54:18 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so439745yhm.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Aug 2012 06:54:18 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: bharrosh@panasas.com, linux-nfs@vger.kernel.org,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v3 3/3] NFS41: send real read size in layoutget
Date: Tue, 14 Aug 2012 21:52:24 +0800
Message-Id: <1344952344-1435-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344952344-1435-1-git-send-email-bergwolf@gmail.com>
References: <1344952344-1435-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For buffer read, use offst-to-isize.

For direct read, use dreq->bytes_left.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/pnfs.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9ff45d1..4a250a4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1153,16 +1153,24 @@ out_forget_reply:
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

