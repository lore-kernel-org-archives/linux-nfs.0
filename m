Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab0HROoX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:23 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 02/11] SQUASHME pnfs-submit rename pnfs_layout_type 2
Date: Wed, 18 Aug 2010 10:44:09 -0400
Message-Id: <1282142658-21579-3-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-2-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: filelayout alloc_layout and free_layout

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    6 +++---
 fs/nfs/nfs4filelayout.h |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index fea1772..fa08540 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -282,10 +282,10 @@ filelayout_write_pagelist(struct nfs_write_data *data, unsigned nr_pages, int sy
 
 /*
  * Create a filelayout layout structure and return it.  The pNFS client
- * will use the pnfs_layout_type type to refer to the layout for this
+ * will use the pnfs_layout_hdr type to refer to the layout for this
  * inode from now on.
  */
-static struct pnfs_layout_type *
+static struct pnfs_layout_hdr *
 filelayout_alloc_layout(struct inode *inode)
 {
 	struct nfs4_filelayout *flp;
@@ -297,7 +297,7 @@ filelayout_alloc_layout(struct inode *inode)
 
 /* Free a filelayout layout structure */
 static void
-filelayout_free_layout(struct pnfs_layout_type *lo)
+filelayout_free_layout(struct pnfs_layout_hdr *lo)
 {
 	dprintk("NFS_FILELAYOUT: freeing layout\n");
 	kfree(FILE_LO(lo));
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index f8f7c05..c851919 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -62,7 +62,7 @@ struct nfs4_filelayout_segment {
 };
 
 struct nfs4_filelayout {
-	struct pnfs_layout_type fl_layout;
+	struct pnfs_layout_hdr fl_layout;
 	u32 stripe_unit;
 };
 
@@ -70,7 +70,7 @@ extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset);
 
 static inline struct nfs4_filelayout *
-FILE_LO(struct pnfs_layout_type *lo)
+FILE_LO(struct pnfs_layout_hdr *lo)
 {
 	return container_of(lo, struct nfs4_filelayout, fl_layout);
 }
-- 
1.6.2.5

