From: andros@netapp.com
Subject: [PATCH 03/13] SQUASHME pnfs_submit: remove pnfs_mount_type from alloc_layout
Date: Thu, 29 Apr 2010 16:34:41 -0400
Message-ID: <1272573291-8986-4-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
 <1272573291-8986-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757115Ab0D3Qst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:49 -0400
In-Reply-To: <1272573291-8986-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The pnfs_mount_type parameter is not used by any layout driver alloc_layout
function.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c   |    2 +-
 fs/nfs/pnfs.c             |    2 +-
 include/linux/nfs4_pnfs.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 79b9df2..4a3f58a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -334,7 +334,7 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
  * inode from now on.
  */
 static void *
-filelayout_alloc_layout(struct pnfs_mount_type *mountid, struct inode *inode)
+filelayout_alloc_layout(struct inode *inode)
 {
 	dprintk("NFS_FILELAYOUT: allocating layout\n");
 	return kzalloc(sizeof(struct nfs4_filelayout), GFP_KERNEL);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 50858c8..f6181bd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -864,7 +864,7 @@ alloc_init_layout(struct inode *ino)
 
 	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
 	lo = &NFS_I(ino)->layout;
-	ld_data = io_ops->alloc_layout(NFS_SERVER(ino)->pnfs_mountid, ino);
+	ld_data = io_ops->alloc_layout(ino);
 	if (!ld_data) {
 		printk(KERN_ERR
 			"%s: out of memory: io_ops->alloc_layout failed\n",
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index b2bec02..be42370 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -162,7 +162,7 @@ struct layoutdriver_io_operations {
 	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
 	 * inode specific layout structure.  Each subsequent layoutget operation results in
 	 * a set_layout call to set the opaque layout in the layout driver.*/
-	void * (*alloc_layout) (struct pnfs_mount_type *mountid, struct inode *inode);
+	void * (*alloc_layout) (struct inode *inode);
 	void (*free_layout) (void *layoutid);
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
-- 
1.6.6

