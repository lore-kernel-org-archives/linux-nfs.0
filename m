Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab0HMVcZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:25 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 24/50] pnfs_submit: filelayout layout segment alloc and free
Date: Fri, 13 Aug 2010 17:31:36 -0400
Message-Id: <1281735122-1496-25-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-24-git-send-email-andros@netapp.com>
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
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c   |  201 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4filelayout.h   |   16 ++++
 fs/nfs/pnfs.c             |   22 +++++
 include/linux/nfs4.h      |    5 +
 include/linux/nfs4_pnfs.h |   12 +++
 5 files changed, 256 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e1a09a8..50620f4 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -46,6 +46,7 @@
 #include "nfs4filelayout.h"
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
@@ -104,9 +105,209 @@ filelayout_free_layout(struct pnfs_layout_type *lo)
 	dprintk("NFS_FILELAYOUT: freeing layout\n");
 	kfree(FILE_LO(lo));
 }
+
+/*
+ * filelayout_check_layout()
+ *
+ * Make sure layout segment parameters are sane WRT the device.
+ *
+ * Notes:
+ * 1) current code insists that # stripe index = # data servers in ds_list
+ *    which is wrong.
+ * 2) pattern_offset is ignored and must == 0 which is wrong;
+ * 3) the pattern_offset needs to be a mutliple of the stripe unit.
+ * 4) stripe unit is multiple of page size
+ */
+
+static int
+filelayout_check_layout(struct pnfs_layout_type *lo,
+			struct pnfs_layout_segment *lseg)
+{
+	struct nfs4_filelayout_segment *fl = LSEG_LD_DATA(lseg);
+	struct nfs4_file_layout_dsaddr *dsaddr;
+	int status = -EINVAL;
+	struct nfs_server *nfss = NFS_SERVER(PNFS_INODE(lo));
+
+	dprintk("--> %s\n", __func__);
+	dsaddr = nfs4_pnfs_device_item_find(nfss->nfs_client, &fl->dev_id);
+	if (dsaddr == NULL) {
+		dsaddr = get_device_info(PNFS_INODE(lo), &fl->dev_id);
+		if (dsaddr == NULL) {
+			dprintk("%s NO device for dev_id %s\n",
+				__func__, deviceid_fmt(&fl->dev_id));
+			goto out;
+		}
+	}
+	if (fl->first_stripe_index < 0 ||
+	    fl->first_stripe_index > dsaddr->stripe_count) {
+		dprintk("%s Bad first_stripe_index %d\n",
+				__func__, fl->first_stripe_index);
+		goto out;
+	}
+
+	if (fl->pattern_offset != 0) {
+		dprintk("%s Unsupported no-zero pattern_offset %Ld\n",
+				__func__, fl->pattern_offset);
+		goto out;
+	}
+
+	if (fl->stripe_unit % PAGE_SIZE) {
+		dprintk("%s Stripe unit (%u) not page aligned\n",
+			__func__, fl->stripe_unit);
+		goto out;
+	}
+
+	/* XXX only support SPARSE packing. Don't support use MDS open fh */
+	if (!(fl->num_fh == 1 || fl->num_fh == dsaddr->ds_num)) {
+		dprintk("%s num_fh %u not equal to 1 or ds_num %u\n",
+			__func__, fl->num_fh, dsaddr->ds_num);
+		goto out;
+	}
+
+	if (fl->stripe_unit % nfss->rsize || fl->stripe_unit % nfss->wsize) {
+		dprintk("%s Stripe unit (%u) not aligned with rsize %u "
+			"wsize %u\n", __func__, fl->stripe_unit, nfss->rsize,
+			nfss->wsize);
+	}
+
+	/* reference the device */
+	nfs4_set_layout_deviceid(lseg, &dsaddr->deviceid);
+
+	status = 0;
+out:
+	dprintk("--> %s returns %d\n", __func__, status);
+	return status;
+}
+
+static void _filelayout_free_lseg(struct pnfs_layout_segment *lseg);
+static void filelayout_free_fh_array(struct nfs4_filelayout_segment *fl);
+
+/* Decode layout and store in layoutid.  Overwrite any existing layout
+ * information for this file.
+ */
+static int
+filelayout_set_layout(struct nfs4_filelayout *flo,
+		      struct nfs4_filelayout_segment *fl,
+		      struct nfs4_pnfs_layoutget_res *lgr)
+{
+	uint32_t *p = (uint32_t *)lgr->layout.buf;
+	uint32_t nfl_util;
+	int i;
+
+	dprintk("%s: set_layout_map Begin\n", __func__);
+
+	memcpy(&fl->dev_id, p, NFS4_PNFS_DEVICEID4_SIZE);
+	p += XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE);
+	nfl_util = be32_to_cpup(p++);
+	if (nfl_util & NFL4_UFLG_COMMIT_THRU_MDS)
+		fl->commit_through_mds = 1;
+	if (nfl_util & NFL4_UFLG_DENSE)
+		fl->stripe_type = STRIPE_DENSE;
+	else
+		fl->stripe_type = STRIPE_SPARSE;
+	fl->stripe_unit = nfl_util & ~NFL4_UFLG_MASK;
+
+	if (!flo->stripe_unit)
+		flo->stripe_unit = fl->stripe_unit;
+	else if (flo->stripe_unit != fl->stripe_unit) {
+		printk(KERN_NOTICE "%s: updating strip_unit from %u to %u\n",
+			__func__, flo->stripe_unit, fl->stripe_unit);
+		flo->stripe_unit = fl->stripe_unit;
+	}
+
+	fl->first_stripe_index = be32_to_cpup(p++);
+	p = xdr_decode_hyper(p, &fl->pattern_offset);
+	fl->num_fh = be32_to_cpup(p++);
+
+	dprintk("%s: nfl_util 0x%X num_fh %u fsi %u po %llu dev_id %s\n",
+		__func__, nfl_util, fl->num_fh, fl->first_stripe_index,
+		fl->pattern_offset, deviceid_fmt(&fl->dev_id));
+
+	if (fl->num_fh * sizeof(struct nfs_fh) > 2*PAGE_SIZE) {
+		fl->fh_array = vmalloc(fl->num_fh * sizeof(struct nfs_fh));
+		if (fl->fh_array)
+			memset(fl->fh_array, 0,
+				fl->num_fh * sizeof(struct nfs_fh));
+	} else {
+		fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh),
+					GFP_KERNEL);
+       }
+	if (!fl->fh_array)
+		return -ENOMEM;
+
+	for (i = 0; i < fl->num_fh; i++) {
+		/* fh */
+		fl->fh_array[i].size = be32_to_cpup(p++);
+		if (sizeof(struct nfs_fh) < fl->fh_array[i].size) {
+			printk(KERN_ERR "Too big fh %d received %d\n",
+				i, fl->fh_array[i].size);
+			/* Layout is now invalid, pretend it doesn't exist */
+			filelayout_free_fh_array(fl);
+			fl->num_fh = 0;
+			break;
+		}
+		memcpy(fl->fh_array[i].data, p, fl->fh_array[i].size);
+		p += XDR_QUADLEN(fl->fh_array[i].size);
+		dprintk("DEBUG: %s: fh len %d\n", __func__,
+					fl->fh_array[i].size);
+	}
+
+	return 0;
+}
+
+static struct pnfs_layout_segment *
+filelayout_alloc_lseg(struct pnfs_layout_type *layoutid,
+		      struct nfs4_pnfs_layoutget_res *lgr)
+{
+	struct nfs4_filelayout *flo = FILE_LO(layoutid);
+	struct pnfs_layout_segment *lseg;
+	int rc;
+
+	dprintk("--> %s\n", __func__);
+	lseg = kzalloc(sizeof(struct pnfs_layout_segment) +
+		       sizeof(struct nfs4_filelayout_segment), GFP_KERNEL);
+	if (!lseg)
+		return NULL;
+
+	rc = filelayout_set_layout(flo, LSEG_LD_DATA(lseg), lgr);
+
+	if (rc != 0 || filelayout_check_layout(layoutid, lseg)) {
+		_filelayout_free_lseg(lseg);
+		lseg = NULL;
+	}
+	return lseg;
+}
+
+static void filelayout_free_fh_array(struct nfs4_filelayout_segment *fl)
+{
+	if (fl->num_fh * sizeof(struct nfs_fh) > 2*PAGE_SIZE)
+		vfree(fl->fh_array);
+	else
+		kfree(fl->fh_array);
+
+	fl->fh_array = NULL;
+}
+
+static void
+_filelayout_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	filelayout_free_fh_array(LSEG_LD_DATA(lseg));
+	kfree(lseg);
+}
+
+static void
+filelayout_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	dprintk("--> %s\n", __func__);
+	nfs4_unset_layout_deviceid(lseg, lseg->deviceid,
+				   nfs4_fl_free_deviceid_callback);
+	_filelayout_free_lseg(lseg);
+}
 struct layoutdriver_io_operations filelayout_io_operations = {
 	.alloc_layout            = filelayout_alloc_layout,
 	.free_layout             = filelayout_free_layout,
+	.alloc_lseg              = filelayout_alloc_lseg,
+	.free_lseg               = filelayout_free_lseg,
 	.initialize_mountpoint   = filelayout_initialize_mountpoint,
 	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
 };
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index ad975fd..aeb2147 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -23,6 +23,11 @@
 #define NFS4_PNFS_MAX_STRIPE_CNT 4096
 #define NFS4_PNFS_MAX_MULTI_CNT  64 /* 256 fit into a u8 stripe_index */
 
+enum stripetype4 {
+	STRIPE_SPARSE = 1,
+	STRIPE_DENSE = 2
+};
+
 /* Individual ip address */
 struct nfs4_pnfs_ds {
 	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
@@ -41,6 +46,17 @@ struct nfs4_file_layout_dsaddr {
 	struct nfs4_pnfs_ds	*ds_list[1];
 };
 
+struct nfs4_filelayout_segment {
+	u32 stripe_type;
+	u32 commit_through_mds;
+	u32 stripe_unit;
+	u32 first_stripe_index;
+	u64 pattern_offset;
+	struct pnfs_deviceid dev_id;
+	unsigned int num_fh;
+	struct nfs_fh *fh_array;
+};
+
 struct nfs4_filelayout {
 	struct pnfs_layout_type fl_layout;
 	u32 stripe_unit;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0f98261..33be484 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -972,6 +972,28 @@ nfs4_init_deviceid_node(struct nfs4_deviceid *d)
 }
 EXPORT_SYMBOL(nfs4_init_deviceid_node);
 
+/* Called from layoutdriver_io_operations->alloc_lseg */
+void
+nfs4_set_layout_deviceid(struct pnfs_layout_segment *l, struct nfs4_deviceid *d)
+{
+	dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.refcount));
+	l->deviceid = d;
+	kref_get(&d->de_kref);
+}
+EXPORT_SYMBOL(nfs4_set_layout_deviceid);
+
+/* Called from layoutdriver_io_operations->free_lseg */
+void
+nfs4_unset_layout_deviceid(struct pnfs_layout_segment *l,
+			   struct nfs4_deviceid *d,
+			   void (*free_callback)(struct kref *))
+{
+	dprintk("%s [%d]\n", __func__, atomic_read(&d->de_kref.refcount));
+	l->deviceid = NULL;
+	kref_put(&d->de_kref, free_callback);
+}
+EXPORT_SYMBOL(nfs4_unset_layout_deviceid);
+
 struct nfs4_deviceid *
 nfs4_find_deviceid(struct nfs4_deviceid_cache *c, struct pnfs_deviceid *id)
 {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index a5f5c94..2e11a3d 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -576,6 +576,11 @@ enum pnfs_iomode {
 	IOMODE_ANY = 3,
 };
 
+#define NFL4_UFLG_MASK			0x0000003F
+#define NFL4_UFLG_DENSE			0x00000001
+#define NFL4_UFLG_COMMIT_THRU_MDS	0x00000002
+#define NFL4_UFLG_STRIPE_UNIT_SIZE_MASK	0xFFFFFFC0
+
 #endif
 #endif
 
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 287a7dc..1ed509c 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -67,6 +67,12 @@ struct pnfs_layout_segment {
 	u8 ld_data[];			/* layout driver private data */
 };
 
+static inline void *
+LSEG_LD_DATA(struct pnfs_layout_segment *lseg)
+{
+	return lseg->ld_data;
+}
+
 /* Layout driver I/O operations.
  * Either the pagecache or non-pagecache read/write operations must be implemented
  */
@@ -142,6 +148,12 @@ extern struct nfs4_deviceid *nfs4_find_deviceid(struct nfs4_deviceid_cache *,
 				struct pnfs_deviceid *);
 extern struct nfs4_deviceid *nfs4_add_deviceid(struct nfs4_deviceid_cache *,
 				struct nfs4_deviceid *);
+extern void nfs4_set_layout_deviceid(struct pnfs_layout_segment *,
+				struct nfs4_deviceid *);
+extern void nfs4_unset_layout_deviceid(struct pnfs_layout_segment *,
+				struct nfs4_deviceid *,
+				void (*free_callback)(struct kref *));
+
 /* pNFS client callback functions.
  * These operations allow the layout driver to access pNFS client
  * specific information or call pNFS client->server operations.
-- 
1.6.2.5

