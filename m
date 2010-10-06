Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5768 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757417Ab0JFOHJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Oct 2010 10:07:09 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: pnfs-submit: init pg_lseg to NULL when !CONFIG_NFS_V4_1
Date: Wed,  6 Oct 2010 10:06:46 -0400
Message-Id: <1286374006-7193-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.h  |   17 +++++++++++++++--
 fs/nfs/read.c  |    2 --
 fs/nfs/write.c |    2 --
 3 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 4ea3ae0..a94241a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -30,6 +30,8 @@
 #ifndef FS_NFS_PNFS_H
 #define FS_NFS_PNFS_H
 
+#include <linux/nfs_page.h>
+
 struct pnfs_layout_segment {
 	struct list_head fi_list;
 	struct pnfs_layout_range range;
@@ -45,8 +47,6 @@ enum pnfs_try_status {
 
 #ifdef CONFIG_NFS_V4_1
 
-#include <linux/nfs_page.h> /* For struct nfs_pageio_descriptor */
-
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
 
 enum {
@@ -368,6 +368,19 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
+static inline void
+pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *ino,
+		      struct nfs_open_context *ctx, struct list_head *pages)
+{
+	pgio->pg_lseg = NULL;
+}
+
+static inline void
+pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *ino)
+{
+	pgio->pg_lseg = NULL;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c34f97d..4d0e26a 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -665,9 +665,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-#ifdef CONFIG_NFS_V4_1
 	pnfs_pageio_init_read(&pgio, inode, desc.ctx, pages);
-#endif /* CONFIG_NFS_V4_1 */
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2251551..652c130 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1029,9 +1029,7 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
-#ifdef CONFIG_NFS_V4_1
 	pnfs_pageio_init_write(pgio, inode);
-#endif /* CONFIG_NFS_V4_1 */
 
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
-- 
1.7.2.3

