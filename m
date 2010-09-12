Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:27951 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753100Ab0ILRFG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Sep 2010 13:05:06 -0400
Message-ID: <4C8D083F.8080102@panasas.com>
Date: Sun, 12 Sep 2010 19:05:03 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@panasas.com>,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Subject: [RFC 2/3] SQUASHME: fileslayout: Adjust to device_cache API changes.
References: <4C8D0759.6090201@panasas.com>
In-Reply-To: <4C8D0759.6090201@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Move the struct nfs4_deviceid *deviceid pointer from the
Generic part to the fileslayout specific part. The rest
is left the same as Before.

This prompts for a cleanup at the nfs4_filelayout_segment
level as now it stands out more bluntly the (possible)
duplication of members. It looks like by accessing
nfs4_file_layout_dsaddr directly from nfs4_filelayout_segment
we can drop lots of the segments members.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/nfs4filelayout.c    |   14 ++++++++------
 fs/nfs/nfs4filelayout.h    |    5 +----
 fs/nfs/nfs4filelayoutdev.c |    7 ++++---
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 46a8a03..1434163 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -113,7 +113,7 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 		u64 tmp, off;
 		u32 unit = flseg->stripe_unit;
 
-		stripe_width = unit * FILE_DSADDR(lseg)->stripe_count;
+		stripe_width = unit * flseg->dsaddr->stripe_count;
 		tmp = off = offset - flseg->pattern_offset;
 		do_div(tmp, stripe_width);
 		return tmp * unit + do_div(off, unit);
@@ -376,15 +376,14 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 			nfss->wsize);
 	}
 
-	nfs4_set_layout_deviceid(lseg, &dsaddr->deviceid);
+	fl->dsaddr = dsaddr;
 
 	status = 0;
 out:
 	dprintk("--> %s returns %d\n", __func__, status);
 	return status;
 out_put:
-	nfs4_put_unset_layout_deviceid(lseg, &dsaddr->deviceid,
-				       nfs4_fl_free_deviceid_callback);
+	nfs4_put_deviceid(nfss->nfs_client->cl_devid_cache, &dsaddr->deviceid);
 	goto out;
 }
 
@@ -507,9 +506,12 @@ _filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 static void
 filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 {
+	struct nfs4_filelayout_segment *fl = LSEG_LD_DATA(lseg);
+	struct nfs_server *nfss = NFS_SERVER(PNFS_INODE(lseg->layout));
+
 	dprintk("--> %s\n", __func__);
-	nfs4_put_unset_layout_deviceid(lseg, lseg->deviceid,
-				   nfs4_fl_free_deviceid_callback);
+	nfs4_put_deviceid(nfss->nfs_client->cl_devid_cache,
+			  &fl->dsaddr->deviceid);
 	_filelayout_free_lseg(lseg);
 }
 
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index be6dc33..a2beac8 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -23,10 +23,6 @@
 #define NFS4_PNFS_MAX_MULTI_CNT  64 /* 256 fit into a u8 stripe_index */
 #define NFS4_PNFS_MAX_MULTI_DS   2
 
-#define FILE_DSADDR(lseg) (container_of(lseg->deviceid, \
-					struct nfs4_file_layout_dsaddr, \
-					deviceid))
-
 enum stripetype4 {
 	STRIPE_SPARSE = 1,
 	STRIPE_DENSE = 2
@@ -62,6 +58,7 @@ struct nfs4_filelayout_segment {
 	u32 first_stripe_index;
 	u64 pattern_offset;
 	struct pnfs_deviceid dev_id;
+	struct nfs4_file_layout_dsaddr *dsaddr;
 	unsigned int num_fh;
 	struct nfs_fh *fh_array;
 };
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 0354c61..7bdb1f8 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -573,16 +573,17 @@ _nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset)
 	tmp = offset - flseg->pattern_offset;
 	do_div(tmp, flseg->stripe_unit);
 	tmp += flseg->first_stripe_index;
-	return do_div(tmp, FILE_DSADDR(lseg)->stripe_count);
+	return do_div(tmp, flseg->dsaddr->stripe_count);
 }
 
 u32
 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, loff_t offset)
 {
+	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
 	u32 j;
 
 	j = _nfs4_fl_calc_j_index(lseg, offset);
-	return FILE_DSADDR(lseg)->stripe_indices[j];
+	return flseg->dsaddr->stripe_indices[j];
 }
 
 struct nfs_fh *
@@ -609,7 +610,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
 	struct nfs4_file_layout_dsaddr *dsaddr;
 
-	dsaddr = FILE_DSADDR(lseg);
+	dsaddr = flseg->dsaddr;
 	if (dsaddr->ds_list[ds_idx] == NULL) {
 		printk(KERN_ERR "%s: No data server for device id (%s)!!\n",
 			__func__, deviceid_fmt(&flseg->dev_id));
-- 
1.7.2.2


