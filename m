Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:65416 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab2HHCDg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Aug 2012 22:03:36 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr13so617318pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Aug 2012 19:03:36 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: bharrosh@panasas.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH RFC 3/3] NFS41: send real read size in layoutget for DIO
Date: Wed,  8 Aug 2012 10:03:12 +0800
Message-Id: <1344391392-1948-4-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@emc.com>

We don't have the real IO size information in buffer read, but for direct
read, we can get it from dreq->bytes_left. Let's make use of it.

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/pnfs.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e61a373..e4cfd1e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1154,16 +1154,22 @@ out_forget_reply:
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
+	if (pgio->pg_dreq != NULL)
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

