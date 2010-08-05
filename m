Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25364 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752491Ab0HEPxu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Aug 2010 11:53:50 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs-submit: reduce nesting level in set_pnfs_layoutdriver
Date: Thu,  5 Aug 2010 18:53:44 +0300
Message-Id: <1281023624-27452-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1280193018-1628-1-git-send-email-Ricardo.Labiaga@netapp.com>
References: <1280193018-1628-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Simplify the code a bit.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5f91763..393855e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -214,23 +214,25 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		find_pnfs(id, &mod);
 	}
 
-	if (mod) {
-		server->pnfs_curr_ld = mod->pnfs_ld_type;
-		if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
-			server->nfs_client)) {
-			printk(KERN_ERR "%s: Error initializing mount point "
-			       "for layout driver %u. ", __func__, id);
-			goto out_err;
-		}
-		dprintk("%s: pNFS module for %u set\n", __func__, id);
-		return;
+	if (!mod) {
+		dprintk("%s: No pNFS module found for %u. ", __func__, id);
+		goto out_err;
+	}
+
+	server->pnfs_curr_ld = mod->pnfs_ld_type;
+	if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
+							server->nfs_client)) {
+		printk(KERN_ERR "%s: Error initializing mount point "
+		       "for layout driver %u. ", __func__, id);
+		goto out_err;
 	}
 
-	dprintk("%s: No pNFS module found for %u. ", __func__, id);
+	dprintk("%s: pNFS module for %u set\n", __func__, id);
+	return;
+
 out_err:
 	dprintk("Using NFSv4 I/O\n");
 	server->pnfs_curr_ld = NULL;
-	return;
 }
 
 /* Allow I/O module to set its functions structure */
-- 
1.7.2

