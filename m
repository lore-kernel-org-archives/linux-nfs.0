From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] SQUASHME: pnfs-submit: have initialize_mountpoint return status
Date: Thu,  6 May 2010 22:22:52 +0300
Message-ID: <1273173772-27641-1-git-send-email-bhalevy@panasas.com>
References: <4BE3166F.7060800@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61079 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754739Ab0EFTW4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:22:56 -0400
In-Reply-To: <4BE3166F.7060800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

use status convention rather than boolean true for success.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c |   10 +++++-----
 fs/nfs/pnfs.c           |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 021c853..9d1274d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -71,16 +71,16 @@ struct layoutdriver_io_operations filelayout_io_operations;
 int
 filelayout_initialize_mountpoint(struct nfs_client *clp)
 {
-
-	if (nfs4_alloc_init_deviceid_cache(clp,
-					   nfs4_fl_free_deviceid_callback)) {
+	int status = nfs4_alloc_init_deviceid_cache(clp,
+						nfs4_fl_free_deviceid_callback);
+	if (status) {
 		printk(KERN_WARNING "%s: deviceid cache could not be "
 			"initialized\n", __func__);
-		return 0;
+		return status;
 	}
 	dprintk("%s: deviceid cache has been initialized successfully\n",
 		__func__);
-	return 1;
+	return 0;
 }
 
 /* Uninitialize a mountpoint by destroying its device list.
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ec543d2..3a09b91 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -211,7 +211,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		return;
 
 	if (id > 0 && find_pnfs(id, &mod)) {
-		if (!mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
+		if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
 			server->nfs_client)) {
 			printk(KERN_ERR "%s: Error initializing mount point "
 			       "for layout driver %u. ", __func__, id);
-- 
1.6.5.1

