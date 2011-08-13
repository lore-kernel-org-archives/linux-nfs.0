Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:35848 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155Ab1HPNsM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 09:48:12 -0400
Received: by pzk37 with SMTP id 37so4663577pzk.1
        for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 06:48:11 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: benny@tonian.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: [PATCH] pnfsblock: init pg_bsize properly
Date: Fri, 12 Aug 2011 18:04:10 -0700
Message-Id: <1313197450-4595-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

pg_bsize is server->wsize/rsize by default. We would want to use the lseg length.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 36648e1..9143e61 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -919,14 +919,30 @@ bl_clear_layoutdriver(struct nfs_server *server)
 	return 0;
 }
 
+static void bl_pg_init_read(struct nfs_pageio_descriptor *pgio,
+			    struct nfs_page *req)
+{
+	pnfs_generic_pg_init_read(pgio, req);
+	if (pgio->pg_lseg)
+		pgio->pg_bsize = pgio->pg_lseg->pls_range.length;
+}
+
+static void bl_pg_init_write(struct nfs_pageio_descriptor *pgio,
+			     struct nfs_page *req)
+{
+	pnfs_generic_pg_init_write(pgio, req);
+	if (pgio->pg_lseg)
+		pgio->pg_bsize = pgio->pg_lseg->pls_range.length;
+}
+
 static const struct nfs_pageio_ops bl_pg_read_ops = {
-	.pg_init = pnfs_generic_pg_init_read,
+	.pg_init = bl_pg_init_read,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = pnfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops bl_pg_write_ops = {
-	.pg_init = pnfs_generic_pg_init_write,
+	.pg_init = bl_pg_init_write,
 	.pg_test = pnfs_generic_pg_test,
 	.pg_doio = pnfs_generic_pg_writepages,
 };
-- 
1.7.1.262.g5ef3d

