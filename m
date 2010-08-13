Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015Ab0HMVcR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:17 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 15/50] pnfs_submit: filelayout deviceid cache
Date: Fri, 13 Aug 2010 17:31:27 -0400
Message-Id: <1281735122-1496-16-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-15-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.h    |    3 ++
 fs/nfs/nfs4filelayoutdev.c |   57 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index f272d0f..39dcdba 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -43,4 +43,7 @@ extern struct pnfs_client_operations *pnfs_callback_ops;
 
 extern void nfs4_fl_free_deviceid_callback(struct kref *);
 extern void print_ds(struct nfs4_pnfs_ds *ds);
+char *deviceid_fmt(const struct pnfs_deviceid *dev_id);
+extern struct nfs4_file_layout_dsaddr *
+nfs4_pnfs_device_item_find(struct nfs_client *, struct pnfs_deviceid *dev_id);
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index c8b8ca7..0da1510 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -84,6 +84,21 @@ print_ds_list(struct nfs4_file_layout_dsaddr *dsaddr)
 		print_ds(dsaddr->ds_list[i]);
 }
 
+/* Debugging function assuming a 64bit major/minor split of the deviceid */
+char *
+deviceid_fmt(const struct pnfs_deviceid *dev_id)
+{
+	static char buf[17];
+	uint32_t *p = (uint32_t *)dev_id->data;
+	uint64_t major, minor;
+
+	p = xdr_decode_hyper(p, &major);
+	p = xdr_decode_hyper(p, &minor);
+
+	sprintf(buf, "%08llu %08llu", major, minor);
+	return buf;
+}
+
 /* nfs4_ds_cache_lock is held */
 static inline struct nfs4_pnfs_ds *
 _data_server_lookup(u32 ip_addr, u32 port)
@@ -113,9 +128,39 @@ destroy_ds(struct nfs4_pnfs_ds *ds)
 	kfree(ds);
 }
 
+static void
+nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
+{
+	struct nfs4_pnfs_ds *ds;
+	int i;
+
+	dprintk("%s: device id=%s\n", __func__,
+		deviceid_fmt(&dsaddr->deviceid.de_id));
+
+	for (i = 0; i < dsaddr->ds_num; i++) {
+		ds = dsaddr->ds_list[i];
+		if (ds != NULL) {
+			if (atomic_dec_and_lock(&ds->ds_count,
+						&nfs4_ds_cache_lock)) {
+				list_del_init(&ds->ds_node);
+				spin_unlock(&nfs4_ds_cache_lock);
+				destroy_ds(ds);
+			}
+		}
+	}
+	kfree(dsaddr->stripe_indices);
+	kfree(dsaddr);
+}
+
 void
 nfs4_fl_free_deviceid_callback(struct kref *kref)
 {
+	struct nfs4_deviceid *device =
+		container_of(kref, struct nfs4_deviceid, de_kref);
+	struct nfs4_file_layout_dsaddr *dsaddr =
+		container_of(device, struct nfs4_file_layout_dsaddr, deviceid);
+
+	nfs4_fl_free_deviceid(dsaddr);
 }
 
 static void
@@ -154,3 +199,15 @@ nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 		kfree(ds);
 	}
 }
+
+struct nfs4_file_layout_dsaddr *
+nfs4_pnfs_device_item_find(struct nfs_client *clp, struct pnfs_deviceid *id)
+{
+	struct nfs4_deviceid *d;
+
+	d = nfs4_find_deviceid(clp->cl_devid_cache, id);
+	dprintk("%s device id (%s) nfs4_deviceid %p\n", __func__,
+		deviceid_fmt(id), d);
+	return (d == NULL) ? NULL :
+		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
+}
-- 
1.6.2.5

