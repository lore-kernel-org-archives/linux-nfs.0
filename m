From: andros@netapp.com
Subject: [PATCH 04/14] SQUASHME pnfs_submit: wait for I/O for data server connect
Date: Thu,  8 Apr 2010 15:54:00 -0400
Message-ID: <1270756450-5570-5-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
 <1270756450-5570-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933116Ab0DHTy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:56 -0400
In-Reply-To: <1270756450-5570-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Don't create (and maintain) a session to a data server until needed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index ea25bd2..cda0bce 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -458,10 +458,9 @@ nfs4_pnfs_ds_add(struct filelayout_mount_type *mt, struct nfs4_pnfs_ds **dsp,
 static struct nfs4_pnfs_ds *
 decode_and_add_ds(uint32_t **pp, struct filelayout_mount_type *mt)
 {
-	struct nfs_server *mds_srv = NFS_SB(mt->fl_sb);
 	struct nfs4_pnfs_ds *ds = NULL;
 	char r_addr[29]; /* max size of ip/port string */
-	int len, err;
+	int len;
 	u32 ip_addr, port;
 	int tmp[6];
 	uint32_t *p = *pp;
@@ -495,19 +494,6 @@ decode_and_add_ds(uint32_t **pp, struct filelayout_mount_type *mt)
 
 	nfs4_pnfs_ds_add(mt, &ds, ip_addr, port, r_addr, len);
 
-	/* XXX: Don't connect to data servers here, because we
-	 * don't want any un-used (never used!) connections.
-	 * We should wait until I/O demands use of the data server.
-	 */
-	if (!ds->ds_clp) {
-		err = nfs4_pnfs_ds_create(mds_srv, ds);
-		if (err) {
-			printk(KERN_ERR "%s nfs4_pnfs_ds_create error %d\n",
-			       __func__, err);
-			goto out_err;
-		}
-	}
-
 	dprintk("%s: addr:port string = %s\n", __func__, r_addr);
 	return ds;
 out_err:
@@ -746,6 +732,7 @@ nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 {
 	struct nfs4_filelayout_segment *layout = LSEG_LD_DATA(lseg);
 	struct inode *inode = PNFS_INODE(lseg->layout);
+	struct nfs_server *mds_srv = NFS_SERVER(inode);
 	struct nfs4_file_layout_dsaddr *dsaddr;
 	u64 tmp, tmp2;
 	u32 stripe_idx, end_idx, ds_idx;
@@ -776,13 +763,24 @@ nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 	BUG_ON(stripe_idx >= dsaddr->stripe_count);
 
 	ds_idx = dsaddr->stripe_indices[stripe_idx];
-	dserver->ds = dsaddr->ds_list[ds_idx];
-
-	if (dserver->ds == NULL) {
+	if (dsaddr->ds_list[ds_idx] == NULL) {
 		printk(KERN_ERR "%s: No data server for device id (%s)!! \n",
 			__func__, deviceid_fmt(&layout->dev_id));
 		return 1;
 	}
+
+	if (!dsaddr->ds_list[ds_idx]->ds_clp) {
+		int err;
+
+		err = nfs4_pnfs_ds_create(mds_srv, dsaddr->ds_list[ds_idx]);
+		if (err) {
+			printk(KERN_ERR "%s nfs4_pnfs_ds_create error %d\n",
+			       __func__, err);
+			return 1;
+		}
+	}
+	dserver->ds = dsaddr->ds_list[ds_idx];
+
 	if (layout->num_fh == 1)
 		dserver->fh = &layout->fh_array[0];
 	else
-- 
1.6.6

