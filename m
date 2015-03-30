Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49522 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbbC3QrC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 12:47:02 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: require an explicit option to enable pNFS
Date: Mon, 30 Mar 2015 18:46:29 +0200
Message-Id: <1427733989-30051-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Turns out sending out layouts to any client is a bad idea if they
can't get at the storage device, so require explicit admin action
to enable pNFS.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4layouts.c            | 2 +-
 include/uapi/linux/nfsd/export.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index f4e8da2..9a8254b 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -118,7 +118,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 {
 	struct super_block *sb = exp->ex_path.mnt->mnt_sb;
 
-	if (exp->ex_flags & NFSEXP_NOPNFS)
+	if (!(exp->ex_flags & NFSEXP_PNFS))
 		return;
 
 	if (sb->s_export_op->get_uuid &&
diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
index 4742f2c..d3bd6ffe 100644
--- a/include/uapi/linux/nfsd/export.h
+++ b/include/uapi/linux/nfsd/export.h
@@ -47,7 +47,7 @@
  * exported filesystem.
  */
 #define	NFSEXP_V4ROOT		0x10000
-#define NFSEXP_NOPNFS		0x20000
+#define NFSEXP_PNFS		0x20000
 
 /* All flags that we claim to support.  (Note we don't support NOACL.) */
 #define NFSEXP_ALLFLAGS		0x3FE7F
-- 
1.9.1

