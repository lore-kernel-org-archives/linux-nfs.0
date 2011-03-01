Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757120Ab1CAR3y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 12:29:54 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Marc Eshel <eshel@almaden.ibm.com>, Mike Sager <sager@netapp.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>,
        Tigran Mkrtchyan <tigran@anahit.desy.de>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Andy Adamson <andros@netapp.com>, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH pNFS wave 3 Version 3 13/18] NFSv4.1: filelayout i/o helpers
Date: Mon, 28 Feb 2011 20:34:18 -0500
Message-Id: <1298943263-2886-14-git-send-email-andros@netapp.com>
In-Reply-To: <1298943263-2886-13-git-send-email-andros@netapp.com>
References: <1298943263-2886-1-git-send-email-andros@netapp.com>
 <1298943263-2886-2-git-send-email-andros@netapp.com>
 <1298943263-2886-3-git-send-email-andros@netapp.com>
 <1298943263-2886-4-git-send-email-andros@netapp.com>
 <1298943263-2886-5-git-send-email-andros@netapp.com>
 <1298943263-2886-6-git-send-email-andros@netapp.com>
 <1298943263-2886-7-git-send-email-andros@netapp.com>
 <1298943263-2886-8-git-send-email-andros@netapp.com>
 <1298943263-2886-9-git-send-email-andros@netapp.com>
 <1298943263-2886-10-git-send-email-andros@netapp.com>
 <1298943263-2886-11-git-send-email-andros@netapp.com>
 <1298943263-2886-12-git-send-email-andros@netapp.com>
 <1298943263-2886-13-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Prepare for filelayout_read_pagelist with helper functions that find the correct
data server, filehandle, and offset.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Tigran Mkrtchyan <tigran@anahit.desy.de>
Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c    |   34 ++++++++++++++++++++++
 fs/nfs/nfs4filelayout.h    |    7 ++++
 fs/nfs/nfs4filelayoutdev.c |   67 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 108 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 0efe8cb..ed83370 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -66,6 +66,40 @@ filelayout_clear_layoutdriver(struct nfs_server *nfss)
 	return 0;
 }
 
+static loff_t
+filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
+			    loff_t offset)
+{
+	u32 stripe_width = flseg->stripe_unit * flseg->dsaddr->stripe_count;
+	u64 tmp;
+
+	offset -= flseg->pattern_offset;
+	tmp = offset;
+	do_div(tmp, stripe_width);
+
+	return tmp * flseg->stripe_unit + do_div(offset, flseg->stripe_unit);
+}
+
+/* This function is used by the layout driver to calculate the
+ * offset of the file on the dserver based on whether the
+ * layout type is STRIPE_DENSE or STRIPE_SPARSE
+ */
+static loff_t
+filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
+{
+	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
+
+	switch (flseg->stripe_type) {
+	case STRIPE_SPARSE:
+		return offset;
+
+	case STRIPE_DENSE:
+		return filelayout_get_dense_offset(flseg, offset);
+	}
+
+	BUG();
+}
+
 /*
  * filelayout_check_layout()
  *
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index bbf60dd..9fef76e 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -83,9 +83,16 @@ FILELAYOUT_LSEG(struct pnfs_layout_segment *lseg)
 			    generic_hdr);
 }
 
+extern struct nfs_fh *
+nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
+
 extern void nfs4_fl_free_deviceid_callback(struct pnfs_deviceid_node *);
 extern void print_ds(struct nfs4_pnfs_ds *ds);
 extern void print_deviceid(struct nfs4_deviceid *dev_id);
+u32 nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset);
+u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
+struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
+					u32 ds_idx);
 extern struct nfs4_file_layout_dsaddr *
 nfs4_fl_find_get_deviceid(struct nfs_client *, struct nfs4_deviceid *dev_id);
 struct nfs4_file_layout_dsaddr *
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 8e21e65..e8496f3 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -512,3 +512,70 @@ nfs4_fl_find_get_deviceid(struct nfs_client *clp, struct nfs4_deviceid *id)
 	return (d == NULL) ? NULL :
 		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
 }
+
+/*
+ * Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
+ * Then: ((res + fsi) % dsaddr->stripe_count)
+ */
+u32
+nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset)
+{
+	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
+	u64 tmp;
+
+	tmp = offset - flseg->pattern_offset;
+	do_div(tmp, flseg->stripe_unit);
+	tmp += flseg->first_stripe_index;
+	return do_div(tmp, flseg->dsaddr->stripe_count);
+}
+
+u32
+nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j)
+{
+	return FILELAYOUT_LSEG(lseg)->dsaddr->stripe_indices[j];
+}
+
+struct nfs_fh *
+nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
+{
+	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
+	u32 i;
+
+	if (flseg->stripe_type == STRIPE_SPARSE) {
+		if (flseg->num_fh == 1)
+			i = 0;
+		else if (flseg->num_fh == 0)
+			/* Use the MDS OPEN fh set in nfs_read_rpcsetup */
+			return NULL;
+		else
+			i = nfs4_fl_calc_ds_index(lseg, j);
+	} else
+		i = j;
+	return flseg->fh_array[i];
+}
+
+struct nfs4_pnfs_ds *
+nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
+{
+	struct nfs4_file_layout_dsaddr *dsaddr = FILELAYOUT_LSEG(lseg)->dsaddr;
+	struct nfs4_pnfs_ds *ds = dsaddr->ds_list[ds_idx];
+
+	if (ds == NULL) {
+		printk(KERN_ERR "%s: No data server for offset index %d\n",
+			__func__, ds_idx);
+		return NULL;
+	}
+
+	if (!ds->ds_clp) {
+		int err;
+
+		err = nfs4_ds_connect(NFS_SERVER(lseg->pls_layout->plh_inode),
+					  dsaddr->ds_list[ds_idx]);
+		if (err) {
+			printk(KERN_ERR "%s nfs4_ds_connect error %d\n",
+			       __func__, err);
+			return NULL;
+		}
+	}
+	return ds;
+}
-- 
1.6.6

