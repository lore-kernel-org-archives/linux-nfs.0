From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 10/10] pnfs-submit: filelayout: adjust to new alloc_layout API
Date: Mon, 14 Jun 2010 21:46:15 -0400
Message-ID: <1276566375-24566-11-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
 <1276566375-24566-3-git-send-email-iisaman@netapp.com>
 <1276566375-24566-4-git-send-email-iisaman@netapp.com>
 <1276566375-24566-5-git-send-email-iisaman@netapp.com>
 <1276566375-24566-6-git-send-email-iisaman@netapp.com>
 <1276566375-24566-7-git-send-email-iisaman@netapp.com>
 <1276566375-24566-8-git-send-email-iisaman@netapp.com>
 <1276566375-24566-9-git-send-email-iisaman@netapp.com>
 <1276566375-24566-10-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52273 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932222Ab0FOO3G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:06 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 73E2F1816B
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-10-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   11 +++++++----
 fs/nfs/nfs4filelayout.h |    7 +++++++
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 8a83c0d..f863549 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -308,11 +308,14 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
  * will use the pnfs_layout_type type to refer to the layout for this
  * inode from now on.
  */
-static void *
+static struct pnfs_layout_type *
 filelayout_alloc_layout(struct inode *inode)
 {
+	struct nfs4_filelayout *flp;
+
 	dprintk("NFS_FILELAYOUT: allocating layout\n");
-	return kzalloc(sizeof(struct nfs4_filelayout), GFP_KERNEL);
+	flp =  kzalloc(sizeof(struct nfs4_filelayout), GFP_KERNEL);
+	return flp ? &flp->fl_cache : NULL;
 }
 
 /* Free a filelayout layout structure
@@ -478,7 +481,7 @@ static struct pnfs_layout_segment *
 filelayout_alloc_lseg(struct pnfs_layout_type *layoutid,
 		      struct nfs4_pnfs_layoutget_res *lgr)
 {
-	struct nfs4_filelayout *flo = PNFS_LD_DATA(layoutid);
+	struct nfs4_filelayout *flo = FILE_LO_CACHE(layoutid);
 	struct pnfs_layout_segment *lseg;
 	int rc;
 
@@ -697,7 +700,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 ssize_t
 filelayout_get_stripesize(struct pnfs_layout_type *layoutid)
 {
-	struct nfs4_filelayout *flo = PNFS_LD_DATA(layoutid);
+	struct nfs4_filelayout *flo = FILE_LO_CACHE(layoutid);
 
 	return flo->stripe_unit;
 }
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 3697926..060bf9a 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -70,6 +70,7 @@ struct nfs4_filelayout_segment {
 };
 
 struct nfs4_filelayout {
+	struct pnfs_layout_type fl_cache;
 	int uncommitted_write;
 	loff_t last_commit_size;
 	u64 layout_id;
@@ -90,6 +91,12 @@ nfs4_fl_select_ds_fh(struct nfs4_filelayout_segment *flseg, u32 idx)
 		return &flseg->fh_array[idx];
 }
 
+static inline struct nfs4_filelayout *
+FILE_LO_CACHE(struct pnfs_layout_type *lo_cache)
+{
+	return container_of(lo_cache, struct nfs4_filelayout, fl_cache);
+}
+
 extern struct pnfs_client_operations *pnfs_callback_ops;
 
 extern void nfs4_fl_free_deviceid_callback(struct kref *);
-- 
1.6.6.1

