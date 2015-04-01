Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35570 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbDAIeH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 04:34:07 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: add NFSEXP_PNFS to the exflags array
Date: Wed,  1 Apr 2015 10:33:32 +0200
Message-Id: <1427877212-498-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And add a comment to export.h to remind people they have to do this.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/export.c                 | 1 +
 fs/nfsd/nfs4layouts.c            | 5 ++++-
 include/uapi/linux/nfsd/export.h | 3 +++
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c3e3b6e..639d8c2 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1159,6 +1159,7 @@ static struct flags {
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 	{ NFSEXP_V4ROOT, {"v4root", ""}},
+	{ NFSEXP_PNFS, {"pnfs", ""}},
 	{ 0, {"", ""}}
 };
 
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 6904213..442e055 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -118,8 +118,11 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 {
 	struct super_block *sb = exp->ex_path.mnt->mnt_sb;
 
-	if (!(exp->ex_flags & NFSEXP_PNFS))
+	if (!(exp->ex_flags & NFSEXP_PNFS)) {
+		printk("NOPNFS!\n");
 		return;
+	}
+	printk("PNFS!\n");
 
 	if (sb->s_export_op->get_uuid &&
 	    sb->s_export_op->map_blocks &&
diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
index d3bd6ffe..0df7bd5 100644
--- a/include/uapi/linux/nfsd/export.h
+++ b/include/uapi/linux/nfsd/export.h
@@ -21,6 +21,9 @@
 
 /*
  * Export flags.
+ *
+ * Please update the expflags[] array in fs/nfsd/export.c when adding
+ * a new flag.
  */
 #define NFSEXP_READONLY		0x0001
 #define NFSEXP_INSECURE_PORT	0x0002
-- 
1.9.1

