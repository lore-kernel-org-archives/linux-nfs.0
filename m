Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12468 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757280Ab0EXRhF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 13:37:05 -0400
From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 2/2] pnfs-submit: Dynamically load the nfslayoutdriver
Date: Mon, 24 May 2010 10:37:03 -0700
Message-Id: <1274722623-11078-2-git-send-email-Ricardo.Labiaga@netapp.com>
In-Reply-To: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Load the files layout driver if the server indicates that it supports
LAYOUT4_NFSV4_1_FILES.  Other layouts can be loaded in a similar fashion.
The module can be blacklisted to disable pNFS support for the corresponding
layout type.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/pnfs.c |   17 +++++++++++++++--
 fs/nfs/pnfs.h |    2 ++
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 57d3ff0..6a89279 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -205,12 +205,24 @@ unmount_pnfs_layoutdriver(struct nfs_server *nfss)
 void
 set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 {
-	struct pnfs_module *mod;
+	struct pnfs_module *mod = NULL;
 
 	if (server->pnfs_curr_ld)
 		return;
 
-	if (id > 0 && find_pnfs(id, &mod)) {
+	if (!find_pnfs(id, &mod)) {
+		switch (id) {
+		case LAYOUT_NFSV4_1_FILES:
+			request_module(LAYOUT_NFSV4_1_FILES_MODULE);
+			break;
+		default:
+			goto out_not_found;
+		};
+
+		find_pnfs(id, &mod);
+	}
+
+	if (mod) {
 		if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
 			server->nfs_client)) {
 			printk(KERN_ERR "%s: Error initializing mount point "
@@ -227,6 +239,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		return;
 	}
 
+out_not_found:
 	dprintk("%s: No pNFS module found for %u. ", __func__, id);
 out_err:
 	dprintk("Using NFSv4 I/O\n");
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b80157b..dac955e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -80,6 +80,8 @@ void _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
 				     (srv)->pnfs_curr_ld->ld_policy_ops && \
 				     (srv)->pnfs_curr_ld->ld_policy_ops->opname)
 
+#define LAYOUT_NFSV4_1_FILES_MODULE "nfslayoutdriver"
+
 static inline int lo_fail_bit(u32 iomode)
 {
 	return iomode == IOMODE_RW ?
-- 
1.5.4.3

