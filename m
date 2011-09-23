Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:32833 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744Ab1IWBu2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 21:50:28 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 06/10] pnfsblock: init pg_bsize properly
Date: Thu, 22 Sep 2011 21:50:13 -0400
Message-Id: <1316742617-14766-7-git-send-email-rees@umich.edu>
In-Reply-To: <1316742617-14766-1-git-send-email-rees@umich.edu>
References: <1316742617-14766-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

pg_bsize is server->wsize/rsize by default. We would want to use the lseg
length.

Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/blocklayout/blocklayout.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 2167ba2..f5a7fa6 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -923,14 +923,30 @@ bl_clear_layoutdriver(struct nfs_server *server)
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
1.7.4.1

