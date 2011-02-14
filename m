Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2269 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753154Ab1BNTbw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:31:52 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/2] SQUASHME pnfs-submit wave3 avoid calculating j index twice per call
Date: Mon, 14 Feb 2011 14:31:49 -0500
Message-Id: <1297711909-27015-3-git-send-email-andros@netapp.com>
In-Reply-To: <1297711909-27015-2-git-send-email-andros@netapp.com>
References: <1297711909-27015-1-git-send-email-andros@netapp.com>
 <1297711909-27015-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Calculating the j index is expensive, so save and reuse it instead of recalculating.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |    7 ++++---
 fs/nfs/nfs4filelayout.h    |    5 +++--
 fs/nfs/nfs4filelayoutdev.c |   16 +++++++---------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 80e7a66..3768377 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -220,7 +220,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	struct pnfs_layout_segment *lseg = data->lseg;
 	struct nfs4_pnfs_ds *ds;
 	loff_t offset = data->args.offset;
-	u32 idx;
+	u32 j, idx;
 	struct nfs_fh *fh;
 
 	dprintk("--> %s ino %lu pgbase %u req %Zu@%llu\n",
@@ -228,7 +228,8 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 		data->args.pgbase, (size_t)data->args.count, offset);
 
 	/* Retrieve the correct rpc_client for the byte range */
-	idx = nfs4_fl_calc_ds_index(lseg, offset);
+	j = nfs4_fl_calc_j_index(lseg, offset);
+	idx = nfs4_fl_calc_ds_index(lseg, j);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds) {
 		/* Either layout fh index faulty, or ds connect failed */
@@ -241,7 +242,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 
 	/* No multipath support. Use first DS */
 	data->ds_clp = ds->ds_clp;
-	fh = nfs4_fl_select_ds_fh(lseg, offset);
+	fh = nfs4_fl_select_ds_fh(lseg, j);
 	if (fh)
 		data->args.fh = fh;
 
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 7e33bd8..1809aa6 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -84,12 +84,13 @@ FILELAYOUT_LSEG(struct pnfs_layout_segment *lseg)
 }
 
 extern struct nfs_fh *
-nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset);
+nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
 
 extern void nfs4_fl_free_deviceid_callback(struct pnfs_deviceid_node *);
 extern void print_ds(struct nfs4_pnfs_ds *ds);
 extern void print_deviceid(struct nfs4_deviceid *dev_id);
-u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, loff_t offset);
+u32 nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset);
+u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
 struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
 					u32 ds_idx);
 extern struct nfs4_file_layout_dsaddr *
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 1e1c536..2780d97 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -517,8 +517,8 @@ nfs4_fl_find_get_deviceid(struct nfs_client *clp, struct nfs4_deviceid *id)
  * Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
  * Then: ((res + fsi) % dsaddr->stripe_count)
  */
-static u32
-_nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset)
+u32
+nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset)
 {
 	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
 	u64 tmp;
@@ -530,16 +530,13 @@ _nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset)
 }
 
 u32
-nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, loff_t offset)
+nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j)
 {
-	u32 j;
-
-	j = _nfs4_fl_calc_j_index(lseg, offset);
 	return FILELAYOUT_LSEG(lseg)->dsaddr->stripe_indices[j];
 }
 
 struct nfs_fh *
-nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset)
+nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
 {
 	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
 	u32 i;
@@ -551,11 +548,12 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset)
 			/* Use the MDS OPEN fh set in nfs_read_rpcsetup */
 			return NULL;
 		else
-			i = nfs4_fl_calc_ds_index(lseg, offset);
+			i = nfs4_fl_calc_ds_index(lseg, j);
 	} else
-		i = _nfs4_fl_calc_j_index(lseg, offset);
+		i = j;
 	return flseg->fh_array[i];
 }
+
 void
 filelayout_mark_devid_negative(struct nfs_client *mds_clp,
 			       struct pnfs_deviceid_node *devid,
-- 
1.6.6

