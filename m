Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:41361 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753582AbdCTWHJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Mar 2017 18:07:09 -0400
From: <andros@netapp.com>
To: <trondmy@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 3/3] NFS filelayout:call GETDEVICEINFO after pnfs_layout_process completes
Date: Mon, 20 Mar 2017 18:07:02 -0400
Message-ID: <1490047622-35305-4-git-send-email-andros@netapp.com>
In-Reply-To: <1490047622-35305-1-git-send-email-andros@netapp.com>
References: <1490047622-35305-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Fix a filelayout GETDEVICEINFO call hang triggered from the LAYOUTGET
pnfs_layout_process where the GETDEVICEINFO call is waiting for a
session slot, and the LAYOUGET call is waiting for pnfs_layout_process
to complete before freeing the slot GETDEVICEINFO is waiting for..

This occurs in testing against the pynfs pNFS server where the
the on-wire reply highest_slotid and slot id are zero, and the
target high slot id is 8 (negotiated in CREATE_SESSION).

The internal fore channel slot table max_slotid, the maximum allowed
table slotid value, has been reduced via nfs41_set_max_slotid_locked
 from 8 to 1.  Thus there is one slot (slotid 0) available for use but
it has not been freed by LAYOUTGET  proir to the GETDEVICEINFO request.

In order to ensure that layoutrecall callbacks are processed in the
correct order, nfs4_proc_layoutget processing needs to be finished
e.g. pnfs_layout_process) before giving up the slot that identifies
the layoutget (see referring_call_exists).

Move the filelayout_check_layout nfs4_find_get_device call outside of
the pnfs_layout_process call tree.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/filelayout/filelayout.c | 138 +++++++++++++++++++++++++++--------------
 1 file changed, 91 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 4812bf0..2fe05e6 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -560,6 +560,50 @@ static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 	return PNFS_ATTEMPTED;
 }
 
+static int
+filelayout_check_deviceid(struct pnfs_layout_hdr *lo,
+			  struct nfs4_filelayout_segment *fl,
+			  gfp_t gfp_flags)
+{
+	struct nfs4_deviceid_node *d;
+	struct nfs4_file_layout_dsaddr *dsaddr;
+	int status = -EINVAL;
+
+	/* find and reference the deviceid */
+	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &fl->deviceid,
+			lo->plh_lc_cred, gfp_flags);
+	if (d == NULL)
+		goto out;
+
+	dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
+	/* Found deviceid is unavailable */
+	if (filelayout_test_devid_unavailable(&dsaddr->id_node))
+		goto out_put;
+
+	fl->dsaddr = dsaddr;
+
+	if (fl->first_stripe_index >= dsaddr->stripe_count) {
+		dprintk("%s Bad first_stripe_index %u\n",
+				__func__, fl->first_stripe_index);
+		goto out_put;
+	}
+
+	if ((fl->stripe_type == STRIPE_SPARSE &&
+	    fl->num_fh > 1 && fl->num_fh != dsaddr->ds_num) ||
+	    (fl->stripe_type == STRIPE_DENSE &&
+	    fl->num_fh != dsaddr->stripe_count)) {
+		dprintk("%s num_fh %u not valid for given packing\n",
+			__func__, fl->num_fh);
+		goto out_put;
+	}
+	status = 0;
+out:
+	return status;
+out_put:
+	nfs4_fl_put_deviceid(dsaddr);
+	goto out;
+}
+
 /*
  * filelayout_check_layout()
  *
@@ -574,8 +618,6 @@ static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 			struct nfs4_layoutget_res *lgr,
 			gfp_t gfp_flags)
 {
-	struct nfs4_deviceid_node *d;
-	struct nfs4_file_layout_dsaddr *dsaddr;
 	int status = -EINVAL;
 
 	dprintk("--> %s\n", __func__);
@@ -600,41 +642,10 @@ static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 		goto out;
 	}
 
-	/* find and reference the deviceid */
-	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &fl->deviceid,
-			lo->plh_lc_cred, gfp_flags);
-	if (d == NULL)
-		goto out;
-
-	dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
-	/* Found deviceid is unavailable */
-	if (filelayout_test_devid_unavailable(&dsaddr->id_node))
-		goto out_put;
-
-	fl->dsaddr = dsaddr;
-
-	if (fl->first_stripe_index >= dsaddr->stripe_count) {
-		dprintk("%s Bad first_stripe_index %u\n",
-				__func__, fl->first_stripe_index);
-		goto out_put;
-	}
-
-	if ((fl->stripe_type == STRIPE_SPARSE &&
-	    fl->num_fh > 1 && fl->num_fh != dsaddr->ds_num) ||
-	    (fl->stripe_type == STRIPE_DENSE &&
-	    fl->num_fh != dsaddr->stripe_count)) {
-		dprintk("%s num_fh %u not valid for given packing\n",
-			__func__, fl->num_fh);
-		goto out_put;
-	}
-
 	status = 0;
 out:
 	dprintk("--> %s returns %d\n", __func__, status);
 	return status;
-out_put:
-	nfs4_fl_put_deviceid(dsaddr);
-	goto out;
 }
 
 static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
@@ -885,18 +896,51 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
 	return min(stripe_unit - (unsigned int)stripe_offset, size);
 }
 
+static struct pnfs_layout_segment *
+fl_pnfs_update_layout(struct inode *ino,
+		      struct nfs_open_context *ctx,
+		      loff_t pos,
+		      u64 count,
+		      enum pnfs_iomode iomode,
+		      bool strict_iomode,
+		      gfp_t gfp_flags)
+{
+	struct pnfs_layout_segment *lseg = NULL;
+	struct pnfs_layout_hdr *lo;
+	struct nfs4_filelayout_segment *fl;
+	int status;
+
+	lseg = pnfs_update_layout(ino, ctx, pos, count, iomode, strict_iomode,
+				  gfp_flags);
+	if (!lseg)
+		lseg = ERR_PTR(-ENOMEM);
+	if (IS_ERR(lseg))
+		goto out;
+
+	lo = NFS_I(ino)->layout;
+	fl = FILELAYOUT_LSEG(lseg);
+
+	status = filelayout_check_deviceid(lo, fl, gfp_flags);
+	if (status)
+		lseg = ERR_PTR(status);
+out:
+	if (IS_ERR(lseg))
+		pnfs_put_lseg(lseg);
+	return lseg;
+}
+
 static void
 filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
 {
 	if (!pgio->pg_lseg) {
-		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-					   req->wb_context,
-					   0,
-					   NFS4_MAX_UINT64,
-					   IOMODE_READ,
-					   false,
-					   GFP_KERNEL);
+		pgio->pg_lseg = fl_pnfs_update_layout(pgio->pg_inode,
+						      req->wb_context,
+						      0,
+						      NFS4_MAX_UINT64,
+						      IOMODE_READ,
+						      false,
+						      GFP_KERNEL);
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
 			pgio->pg_lseg = NULL;
@@ -916,13 +960,13 @@ static void _filelayout_free_lseg(struct nfs4_filelayout_segment *fl)
 	int status;
 
 	if (!pgio->pg_lseg) {
-		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-					   req->wb_context,
-					   0,
-					   NFS4_MAX_UINT64,
-					   IOMODE_RW,
-					   false,
-					   GFP_NOFS);
+		pgio->pg_lseg = fl_pnfs_update_layout(pgio->pg_inode,
+						      req->wb_context,
+						      0,
+						      NFS4_MAX_UINT64,
+						      IOMODE_RW,
+						      false,
+						      GFP_NOFS);
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
 			pgio->pg_lseg = NULL;
-- 
1.8.3.1

