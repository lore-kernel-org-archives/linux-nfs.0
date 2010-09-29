Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16995 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752536Ab0I2LJv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:09:51 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] SQUASHME: pnfs-submit: handle non-pnfs case in set_pnfs_layoutdriver
Date: Wed, 29 Sep 2010 13:09:48 +0200
Message-Id: <1285758588-26823-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1ccf8d8..9d53c3c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -139,10 +139,14 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 {
 	struct pnfs_layoutdriver_type *ld_type = NULL;
 
-	BUG_ON(!(server->nfs_client->cl_exchange_flags &
-		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS)));
 	if (id == 0)
 		goto out_no_driver;
+	if (!(server->nfs_client->cl_exchange_flags &
+		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
+		printk(KERN_ERR "%s: id %u cl_exchange_flags 0x%x\n", __func__,
+		       id, server->nfs_client->cl_exchange_flags);
+		goto out_no_driver;
+	}
 	ld_type = find_pnfs_driver(id);
 	if (!ld_type) {
 		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
-- 
1.7.2.3

