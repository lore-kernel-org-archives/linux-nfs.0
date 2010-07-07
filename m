From: andros@netapp.com
Subject: [PATCH 04/16] SQUASHME pnfs-submit: filelayout: use new alloc/free_layout API
Date: Wed,  7 Jul 2010 18:34:11 -0400
Message-ID: <1278542063-4009-5-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
 <1278542063-4009-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755675Ab0GGWeZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:25 -0400
In-Reply-To: <1278542063-4009-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   15 +++++++++------
 fs/nfs/nfs4filelayout.h |    7 +++++++
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 57a0010..b49ccf4 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -301,20 +301,23 @@ filelayout_write_pagelist(struct pnfs_layout_type *layoutid,
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
+	return flp ? &flp->fl_layout : NULL;
 }
 
 /* Free a filelayout layout structure
  */
 static void
-filelayout_free_layout(void *layoutid)
+filelayout_free_layout(struct pnfs_layout_type *lo)
 {
 	dprintk("NFS_FILELAYOUT: freeing layout\n");
-	kfree(layoutid);
+	kfree(lo);
 }
 
 /*
@@ -471,7 +474,7 @@ static struct pnfs_layout_segment *
 filelayout_alloc_lseg(struct pnfs_layout_type *layoutid,
 		      struct nfs4_pnfs_layoutget_res *lgr)
 {
-	struct nfs4_filelayout *flo = PNFS_LD_DATA(layoutid);
+	struct nfs4_filelayout *flo = FILE_LO(layoutid);
 	struct pnfs_layout_segment *lseg;
 	int rc;
 
@@ -693,7 +696,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 ssize_t
 filelayout_get_stripesize(struct pnfs_layout_type *layoutid)
 {
-	struct nfs4_filelayout *flo = PNFS_LD_DATA(layoutid);
+	struct nfs4_filelayout *flo = FILE_LO(layoutid);
 
 	return flo->stripe_unit;
 }
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index de8391f..fd25e76 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -68,6 +68,7 @@ struct nfs4_filelayout_segment {
 };
 
 struct nfs4_filelayout {
+	struct pnfs_layout_type fl_layout;
 	int uncommitted_write;
 	loff_t last_commit_size;
 	u64 layout_id;
@@ -77,6 +78,12 @@ struct nfs4_filelayout {
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset);
 
+static inline struct nfs4_filelayout *
+FILE_LO(struct pnfs_layout_type *lo)
+{
+	return container_of(lo, struct nfs4_filelayout, fl_layout);
+}
+
 extern struct pnfs_client_operations *pnfs_callback_ops;
 
 extern void nfs4_fl_free_deviceid_callback(struct kref *);
-- 
1.6.6

