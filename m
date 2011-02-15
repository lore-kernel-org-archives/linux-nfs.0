Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55805 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228Ab1BPSjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 13:39:19 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pNFS wave 3 Version 2 17/18] NFSv4.1: turn off pNFS on ds connection failure
Date: Tue, 15 Feb 2011 03:39:02 -0500
Message-Id: <1297759143-2045-18-git-send-email-andros@netapp.com>
In-Reply-To: <1297759143-2045-1-git-send-email-andros@netapp.com>
References: <1297759143-2045-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

If a data server is unavailable, go through MDS.

Mark the deviceid containing the data server as a negative cache entry.
Do not try to connect to any data server on a deviceid marked as a negative
cache entry. Mark any layout that tries to use the marked deviceid as failed.

Inodes with a layout marked as fails will not use the layout for I/O, and will
not perform any more layoutgets.
Inodes without a layout will still do layoutget, but the layout will get
marked immediately.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |    4 +++-
 fs/nfs/nfs4filelayout.h    |    4 ++++
 fs/nfs/nfs4filelayoutdev.c |   28 ++++++++++++++++++++++++----
 fs/nfs/pnfs.c              |    9 +++++----
 4 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 84c7577..eba9873 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -211,7 +211,9 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	idx = nfs4_fl_calc_ds_index(lseg, j);
 	ds = nfs4_fl_prepare_ds(lseg, idx);
 	if (!ds) {
-		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
+		/* Either layout fh index faulty, or ds connect failed */
+		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
+		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
 		return PNFS_NOT_ATTEMPTED;
 	}
 	dprintk("%s USE DS:ip %x %hu\n", __func__,
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 23f1e1e..ee0c907 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -55,10 +55,14 @@ struct nfs4_pnfs_ds {
 	atomic_t		ds_count;
 };
 
+/* nfs4_file_layout_dsaddr flags */
+#define NFS4_DEVICE_ID_NEG_ENTRY	0x00000001
+
 struct nfs4_file_layout_dsaddr {
 	struct hlist_node		node;
 	struct nfs4_deviceid		deviceid;
 	atomic_t			ref;
+	unsigned long			flags;
 	u32				stripe_count;
 	u8				*stripe_indices;
 	u32				ds_num;
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index ac38c75..433204f 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -602,6 +602,21 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
 	return flseg->fh_array[i];
 }
 
+static void
+filelayout_mark_devid_negative(struct nfs4_file_layout_dsaddr *dsaddr,
+			       int err, u32 ds_addr)
+{
+	u32 *p = (u32 *)&dsaddr->deviceid;
+
+	printk(KERN_ERR "NFS: data server %x connection error %d."
+		" Deviceid [%x%x%x%x] marked out of use.\n",
+		ds_addr, err, p[0], p[1], p[2], p[3]);
+
+	spin_lock(&filelayout_deviceid_lock);
+	dsaddr->flags |= NFS4_DEVICE_ID_NEG_ENTRY;
+	spin_unlock(&filelayout_deviceid_lock);
+}
+
 struct nfs4_pnfs_ds *
 nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 {
@@ -615,13 +630,18 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	}
 
 	if (!ds->ds_clp) {
+		struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
 		int err;
 
-		err = nfs4_ds_connect(NFS_SERVER(lseg->pls_layout->plh_inode),
-					  dsaddr->ds_list[ds_idx]);
+		if (dsaddr->flags & NFS4_DEVICE_ID_NEG_ENTRY) {
+			/* Already tried to connect, don't try again */
+			dprintk("%s Deviceid marked out of use\n", __func__);
+			return NULL;
+		}
+		err = nfs4_ds_connect(s, ds);
 		if (err) {
-			printk(KERN_ERR "%s nfs4_ds_connect error %d\n",
-			       __func__, err);
+			filelayout_mark_devid_negative(dsaddr, err,
+						       ntohl(ds->ds_ip_addr));
 			return NULL;
 		}
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 349a378..a7ea646 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -739,15 +739,16 @@ pnfs_update_layout(struct inode *ino,
 		dprintk("%s matches recall, use MDS\n", __func__);
 		goto out_unlock;
 	}
-	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_find_lseg(lo, iomode);
-	if (lseg)
-		goto out_unlock;
 
 	/* if LAYOUTGET already failed once we don't try again */
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
+	/* Check to see if the layout for the given range already exists */
+	lseg = pnfs_find_lseg(lo, iomode);
+	if (lseg)
+		goto out_unlock;
+
 	if (pnfs_layoutgets_blocked(lo, NULL, 0))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
-- 
1.7.2.3

