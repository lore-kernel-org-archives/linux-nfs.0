Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51983 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752926Ab1BNTTB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:19:01 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 16/16] pnfs: wave 3: turn off pNFS on ds connection failure
Date: Mon, 14 Feb 2011 14:18:36 -0500
Message-Id: <1297711116-3139-17-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-1-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
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
 fs/nfs/nfs4filelayout.h    |    3 +++
 fs/nfs/nfs4filelayoutdev.c |   27 +++++++++++++++++++++++----
 fs/nfs/pnfs.c              |   18 ++++++++++++++----
 fs/nfs/pnfs.h              |    4 ++++
 5 files changed, 47 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c818042..3768377 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -232,7 +232,9 @@ filelayout_read_pagelist(struct nfs_read_data *data)
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
index 9fef76e..1809aa6 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -97,5 +97,8 @@ extern struct nfs4_file_layout_dsaddr *
 nfs4_fl_find_get_deviceid(struct nfs_client *, struct nfs4_deviceid *dev_id);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id);
+void filelayout_mark_devid_negative(struct nfs_client *clp,
+				    struct pnfs_deviceid_node *devid,
+				    int err, u32 ds_ipaddr);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index e8496f3..b8b3dbb 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -553,6 +553,19 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
 		i = j;
 	return flseg->fh_array[i];
 }
+void
+filelayout_mark_devid_negative(struct nfs_client *mds_clp,
+			       struct pnfs_deviceid_node *devid,
+			       int err, u32 ds_addr)
+{
+	u32 *p = (u32 *)&devid->de_id;
+
+	printk(KERN_ERR "NFS: data server %x connection error %d."
+			" Deviceid [%x%x%x%x] marked out of use.\n",
+			ds_addr, err, p[0], p[1], p[2], p[3]);
+
+	pnfs_mark_devid_negative(mds_clp, devid);
+}
 
 struct nfs4_pnfs_ds *
 nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
@@ -567,13 +580,19 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	}
 
 	if (!ds->ds_clp) {
+		struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
 		int err;
 
-		err = nfs4_ds_connect(NFS_SERVER(lseg->pls_layout->plh_inode),
-					  dsaddr->ds_list[ds_idx]);
+		if (dsaddr->deviceid.de_flags & NFS4_DEVICE_ID_NEG_ENTRY) {
+			/* Already tried to connect, don't try again */
+			dprintk("%s Deviceid marked out of use\n", __func__);
+			return NULL;
+		}
+		err = nfs4_ds_connect(s, ds);
 		if (err) {
-			printk(KERN_ERR "%s nfs4_ds_connect error %d\n",
-			       __func__, err);
+			filelayout_mark_devid_negative(s->nfs_client,
+						       &dsaddr->deviceid, err,
+						       ntohl(ds->ds_ip_addr));
 			return NULL;
 		}
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6f4a5ab..912b1ff 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -761,15 +761,16 @@ pnfs_update_layout(struct inode *ino,
 		dprintk("%s matches recall, use MDS\n", __func__);
 		goto out_unlock;
 	}
+
+	/* If LAYOUTGET or pNFS I/O already failed once we don't try again */
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
+		goto out_unlock;
+
 	/* Check to see if the layout for the given range already exists */
 	lseg = pnfs_find_lseg(lo, iomode);
 	if (lseg)
 		goto out_unlock;
 
-	/* if LAYOUTGET already failed once we don't try again */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
-		goto out_unlock;
-
 	if (pnfs_layoutgets_blocked(lo, NULL, 0))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
@@ -1052,3 +1053,12 @@ pnfs_put_deviceid_cache(struct nfs_client *clp)
 	}
 }
 EXPORT_SYMBOL_GPL(pnfs_put_deviceid_cache);
+
+void
+pnfs_mark_devid_negative(struct nfs_client *clp, struct pnfs_deviceid_node *d)
+{
+	spin_lock(&clp->cl_devid_cache->dc_lock);
+	d->de_flags |= NFS4_DEVICE_ID_NEG_ENTRY;
+	spin_unlock(&clp->cl_devid_cache->dc_lock);
+}
+EXPORT_SYMBOL_GPL(pnfs_mark_devid_negative);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 585023f..a760363 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -131,6 +131,8 @@ struct pnfs_deviceid_node {
 	struct hlist_node	de_node;
 	struct nfs4_deviceid	de_id;
 	atomic_t		de_ref;
+	unsigned long		de_flags;
+#define NFS4_DEVICE_ID_NEG_ENTRY		1
 };
 
 struct pnfs_deviceid_cache {
@@ -151,6 +153,8 @@ extern struct pnfs_deviceid_node *pnfs_add_deviceid(
 				struct pnfs_deviceid_node *);
 extern void pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
 			      struct pnfs_deviceid_node *devid);
+extern void pnfs_mark_devid_negative(struct nfs_client *clp,
+				     struct pnfs_deviceid_node *d);
 
 extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
 extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
-- 
1.7.2.3

