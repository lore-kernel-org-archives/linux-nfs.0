Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42761 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754015AbbANQqW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:46:22 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so11560168pab.0
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:46:22 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 49/50] pnfs/flexfiles: Add the FlexFile Layout Driver
Date: Wed, 14 Jan 2015 08:44:55 -0800
Message-Id: <1421253896-73106-50-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
References: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The flexfile layout is a new layout that extends the
file layout. It is currently being drafted as a specification at
https://datatracker.ietf.org/doc/draft-ietf-nfsv4-layout-types/

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
Signed-off-by: Tao Peng <bergwolf@primarydata.com>
---
 fs/nfs/Kconfig                            |    5 +
 fs/nfs/Makefile                           |    1 +
 fs/nfs/flexfilelayout/Makefile            |    5 +
 fs/nfs/flexfilelayout/flexfilelayout.c    | 1603 +++++++++++++++++++++++++++++
 fs/nfs/flexfilelayout/flexfilelayout.h    |  158 +++
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  552 ++++++++++
 fs/nfs/nfs4proc.c                         |    4 +-
 fs/nfs/pnfs.c                             |   32 +-
 fs/nfs/pnfs.h                             |    1 +
 include/linux/nfs4.h                      |    1 +
 10 files changed, 2351 insertions(+), 11 deletions(-)
 create mode 100644 fs/nfs/flexfilelayout/Makefile
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.c
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayout.h
 create mode 100644 fs/nfs/flexfilelayout/flexfilelayoutdev.c

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 3dece03..c7abc10 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -128,6 +128,11 @@ config PNFS_OBJLAYOUT
 	depends on NFS_V4_1 && SCSI_OSD_ULD
 	default NFS_V4
 
+config PNFS_FLEXFILE_LAYOUT
+	tristate
+	depends on NFS_V4_1 && NFS_V3
+	default m
+
 config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
 	string "NFSv4.1 Implementation ID Domain"
 	depends on NFS_V4_1
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 23abffa..1e987ac 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -33,3 +33,4 @@ nfsv4-$(CONFIG_NFS_V4_2)	+= nfs42proc.o
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += filelayout/
 obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
 obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
+obj-$(CONFIG_PNFS_FLEXFILE_LAYOUT) += flexfilelayout/
diff --git a/fs/nfs/flexfilelayout/Makefile b/fs/nfs/flexfilelayout/Makefile
new file mode 100644
index 0000000..1d2c9f6
--- /dev/null
+++ b/fs/nfs/flexfilelayout/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the pNFS Flexfile Layout Driver kernel module
+#
+obj-$(CONFIG_PNFS_FLEXFILE_LAYOUT) += nfs_layout_flexfiles.o
+nfs_layout_flexfiles-y := flexfilelayout.o flexfilelayoutdev.o
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
new file mode 100644
index 0000000..ad1e029
--- /dev/null
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -0,0 +1,1603 @@
+/*
+ * Module for pnfs flexfile layout driver.
+ *
+ * Copyright (c) 2014, Primary Data, Inc. All rights reserved.
+ *
+ * Tao Peng <bergwolf@primarydata.com>
+ */
+
+#include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
+#include <linux/module.h>
+
+#include <linux/sunrpc/metrics.h>
+
+#include "flexfilelayout.h"
+#include "../nfs4session.h"
+#include "../internal.h"
+#include "../delegation.h"
+#include "../nfs4trace.h"
+#include "../iostat.h"
+#include "../nfs.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+#define FF_LAYOUT_POLL_RETRY_MAX     (15*HZ)
+
+static struct pnfs_layout_hdr *
+ff_layout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
+{
+	struct nfs4_flexfile_layout *ffl;
+
+	ffl = kzalloc(sizeof(*ffl), gfp_flags);
+	INIT_LIST_HEAD(&ffl->error_list);
+	return ffl != NULL ? &ffl->generic_hdr : NULL;
+}
+
+static void
+ff_layout_free_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	struct nfs4_ff_layout_ds_err *err, *n;
+
+	list_for_each_entry_safe(err, n, &FF_LAYOUT_FROM_HDR(lo)->error_list,
+				 list) {
+		list_del(&err->list);
+		kfree(err);
+	}
+	kfree(FF_LAYOUT_FROM_HDR(lo));
+}
+
+static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS4_STATEID_SIZE);
+	if (unlikely(p == NULL))
+		return -ENOBUFS;
+	memcpy(stateid, p, NFS4_STATEID_SIZE);
+	dprintk("%s: stateid id= [%x%x%x%x]\n", __func__,
+		p[0], p[1], p[2], p[3]);
+	return 0;
+}
+
+static int decode_deviceid(struct xdr_stream *xdr, struct nfs4_deviceid *devid)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, NFS4_DEVICEID4_SIZE);
+	if (unlikely(!p))
+		return -ENOBUFS;
+	memcpy(devid, p, NFS4_DEVICEID4_SIZE);
+	nfs4_print_deviceid(devid);
+	return 0;
+}
+
+static int decode_nfs_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		return -ENOBUFS;
+	fh->size = be32_to_cpup(p++);
+	if (fh->size > sizeof(struct nfs_fh)) {
+		printk(KERN_ERR "NFS flexfiles: Too big fh received %d\n",
+		       fh->size);
+		return -EOVERFLOW;
+	}
+	/* fh.data */
+	p = xdr_inline_decode(xdr, fh->size);
+	if (unlikely(!p))
+		return -ENOBUFS;
+	memcpy(&fh->data, p, fh->size);
+	dprintk("%s: fh len %d\n", __func__, fh->size);
+
+	return 0;
+}
+
+/*
+ * we only handle AUTH_NONE and AUTH_UNIX for now.
+ *
+ * For AUTH_UNIX, we want to parse
+ * struct authsys_parms {
+ *          unsigned int stamp;
+ *          string machinename<255>;
+ *          unsigned int uid;
+ *          unsigned int gid;
+ *          unsigned int gids<16>;
+ * };
+ */
+static int
+ff_layout_parse_auth(struct xdr_stream *xdr,
+		     struct nfs4_ff_layout_mirror *mirror)
+{
+	__be32 *p;
+	int flavor, len, gid_it = 0;
+
+	/* authflavor(4) + opaque_length(4)*/
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		return -ENOBUFS;
+	flavor = be32_to_cpup(p++);
+	len = be32_to_cpup(p++);
+	if (flavor < RPC_AUTH_NULL || flavor >=  RPC_AUTH_MAXFLAVOR ||
+	    len < 0)
+		return -EINVAL;
+
+	dprintk("%s: flavor %u len %u\n", __func__, flavor, len);
+
+	if (flavor == RPC_AUTH_NULL && len == 0)
+		goto out_fill;
+
+	/* opaque body */
+	p = xdr_inline_decode(xdr, len);
+	if (unlikely(!p))
+		return -ENOBUFS;
+
+	if (flavor == RPC_AUTH_NULL) {
+		mirror->uid = -1;
+		mirror->gid = -1;
+	} else if (flavor == RPC_AUTH_UNIX) {
+		int len2;
+
+		p++; /* stamp */
+		len2 = be32_to_cpup(p++); /* machinename length */
+		dprintk("%s: machinename length %u\n", __func__, len2);
+		if (len2 < 0 || len2 >= len || len2 > 255)
+			return -EINVAL;
+		p += XDR_QUADLEN(len2); /* machinename */
+
+		mirror->uid = be32_to_cpup(p++);
+		mirror->gid = be32_to_cpup(p++);
+
+		len2 = be32_to_cpup(p++); /* gid array length */
+		dprintk("%s: gid array length %u\n", __func__, len2);
+		if (len2 > 16)
+			return -EINVAL;
+		for (; gid_it < len2; gid_it++)
+			mirror->gids[gid_it] = be32_to_cpup(p++);
+	} else {
+		return -EPROTONOSUPPORT;
+	}
+
+out_fill:
+	/* filling the rest of gids */
+	for (; gid_it < 16; gid_it++)
+		mirror->gids[gid_it] = -1;
+
+	return 0;
+}
+
+static void ff_layout_free_mirror_array(struct nfs4_ff_layout_segment *fls)
+{
+	int i;
+
+	if (fls->mirror_array) {
+		for (i = 0; i < fls->mirror_array_cnt; i++) {
+			/* normally mirror_ds is freed in
+			 * .free_deviceid_node but we still do it here
+			 * for .alloc_lseg error path */
+			if (fls->mirror_array[i]) {
+				kfree(fls->mirror_array[i]->fh_versions);
+				nfs4_ff_layout_put_deviceid(fls->mirror_array[i]->mirror_ds);
+				kfree(fls->mirror_array[i]);
+			}
+		}
+		kfree(fls->mirror_array);
+		fls->mirror_array = NULL;
+	}
+}
+
+static int ff_layout_check_layout(struct nfs4_layoutget_res *lgr)
+{
+	int ret = 0;
+
+	dprintk("--> %s\n", __func__);
+
+	/* FIXME: remove this check when layout segment support is added */
+	if (lgr->range.offset != 0 ||
+	    lgr->range.length != NFS4_MAX_UINT64) {
+		dprintk("%s Only whole file layouts supported. Use MDS i/o\n",
+			__func__);
+		ret = -EINVAL;
+	}
+
+	dprintk("--> %s returns %d\n", __func__, ret);
+	return ret;
+}
+
+static void _ff_layout_free_lseg(struct nfs4_ff_layout_segment *fls)
+{
+	if (fls) {
+		ff_layout_free_mirror_array(fls);
+		kfree(fls);
+	}
+}
+
+static void ff_layout_sort_mirrors(struct nfs4_ff_layout_segment *fls)
+{
+	struct nfs4_ff_layout_mirror *tmp;
+	int i, j;
+
+	for (i = 0; i < fls->mirror_array_cnt - 1; i++) {
+		for (j = i + 1; j < fls->mirror_array_cnt; j++)
+			if (fls->mirror_array[i]->efficiency <
+			    fls->mirror_array[j]->efficiency) {
+				tmp = fls->mirror_array[i];
+				fls->mirror_array[i] = fls->mirror_array[j];
+				fls->mirror_array[j] = tmp;
+			}
+	}
+}
+
+static struct pnfs_layout_segment *
+ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
+		     struct nfs4_layoutget_res *lgr,
+		     gfp_t gfp_flags)
+{
+	struct pnfs_layout_segment *ret;
+	struct nfs4_ff_layout_segment *fls = NULL;
+	struct xdr_stream stream;
+	struct xdr_buf buf;
+	struct page *scratch;
+	u64 stripe_unit;
+	u32 mirror_array_cnt;
+	__be32 *p;
+	int i, rc;
+
+	dprintk("--> %s\n", __func__);
+	scratch = alloc_page(gfp_flags);
+	if (!scratch)
+		return ERR_PTR(-ENOMEM);
+
+	xdr_init_decode_pages(&stream, &buf, lgr->layoutp->pages,
+			      lgr->layoutp->len);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
+
+	/* stripe unit and mirror_array_cnt */
+	rc = -EIO;
+	p = xdr_inline_decode(&stream, 8 + 4);
+	if (!p)
+		goto out_err_free;
+
+	p = xdr_decode_hyper(p, &stripe_unit);
+	mirror_array_cnt = be32_to_cpup(p++);
+	dprintk("%s: stripe_unit=%llu mirror_array_cnt=%u\n", __func__,
+		stripe_unit, mirror_array_cnt);
+
+	if (mirror_array_cnt > NFS4_FLEXFILE_LAYOUT_MAX_MIRROR_CNT ||
+	    mirror_array_cnt == 0)
+		goto out_err_free;
+
+	rc = -ENOMEM;
+	fls = kzalloc(sizeof(*fls), gfp_flags);
+	if (!fls)
+		goto out_err_free;
+
+	fls->mirror_array_cnt = mirror_array_cnt;
+	fls->stripe_unit = stripe_unit;
+	fls->mirror_array = kcalloc(fls->mirror_array_cnt,
+				    sizeof(fls->mirror_array[0]), gfp_flags);
+	if (fls->mirror_array == NULL)
+		goto out_err_free;
+
+	for (i = 0; i < fls->mirror_array_cnt; i++) {
+		struct nfs4_deviceid devid;
+		struct nfs4_deviceid_node *idnode;
+		u32 ds_count;
+		u32 fh_count;
+		int j;
+
+		rc = -EIO;
+		p = xdr_inline_decode(&stream, 4);
+		if (!p)
+			goto out_err_free;
+		ds_count = be32_to_cpup(p);
+
+		/* FIXME: allow for striping? */
+		if (ds_count != 1)
+			goto out_err_free;
+
+		fls->mirror_array[i] =
+			kzalloc(sizeof(struct nfs4_ff_layout_mirror),
+				gfp_flags);
+		if (fls->mirror_array[i] == NULL) {
+			rc = -ENOMEM;
+			goto out_err_free;
+		}
+
+		spin_lock_init(&fls->mirror_array[i]->lock);
+		fls->mirror_array[i]->ds_count = ds_count;
+
+		/* deviceid */
+		rc = decode_deviceid(&stream, &devid);
+		if (rc)
+			goto out_err_free;
+
+		idnode = nfs4_find_get_deviceid(NFS_SERVER(lh->plh_inode),
+						&devid, lh->plh_lc_cred,
+						gfp_flags);
+		/*
+		 * upon success, mirror_ds is allocated by previous
+		 * getdeviceinfo, or newly by .alloc_deviceid_node
+		 * nfs4_find_get_deviceid failure is indeed getdeviceinfo falure
+		 */
+		if (idnode)
+			fls->mirror_array[i]->mirror_ds =
+				FF_LAYOUT_MIRROR_DS(idnode);
+		else
+			goto out_err_free;
+
+		/* efficiency */
+		rc = -EIO;
+		p = xdr_inline_decode(&stream, 4);
+		if (!p)
+			goto out_err_free;
+		fls->mirror_array[i]->efficiency = be32_to_cpup(p);
+
+		/* stateid */
+		rc = decode_stateid(&stream, &fls->mirror_array[i]->stateid);
+		if (rc)
+			goto out_err_free;
+
+		/* fh */
+		p = xdr_inline_decode(&stream, 4);
+		if (!p)
+			goto out_err_free;
+		fh_count = be32_to_cpup(p);
+
+		fls->mirror_array[i]->fh_versions =
+			kzalloc(fh_count * sizeof(struct nfs_fh),
+				gfp_flags);
+		if (fls->mirror_array[i]->fh_versions == NULL) {
+			rc = -ENOMEM;
+			goto out_err_free;
+		}
+
+		for (j = 0; j < fh_count; j++) {
+			rc = decode_nfs_fh(&stream,
+					   &fls->mirror_array[i]->fh_versions[j]);
+			if (rc)
+				goto out_err_free;
+		}
+
+		fls->mirror_array[i]->fh_versions_cnt = fh_count;
+
+		/* opaque_auth */
+		rc = ff_layout_parse_auth(&stream, fls->mirror_array[i]);
+		if (rc)
+			goto out_err_free;
+
+		dprintk("%s: uid %d gid %d\n", __func__,
+			fls->mirror_array[i]->uid,
+			fls->mirror_array[i]->gid);
+	}
+
+	ff_layout_sort_mirrors(fls);
+	rc = ff_layout_check_layout(lgr);
+	if (rc)
+		goto out_err_free;
+
+	ret = &fls->generic_hdr;
+	dprintk("<-- %s (success)\n", __func__);
+out_free_page:
+	__free_page(scratch);
+	return ret;
+out_err_free:
+	_ff_layout_free_lseg(fls);
+	ret = ERR_PTR(rc);
+	dprintk("<-- %s (%d)\n", __func__, rc);
+	goto out_free_page;
+}
+
+static bool ff_layout_has_rw_segments(struct pnfs_layout_hdr *layout)
+{
+	struct pnfs_layout_segment *lseg;
+
+	list_for_each_entry(lseg, &layout->plh_segs, pls_list)
+		if (lseg->pls_range.iomode == IOMODE_RW)
+			return true;
+
+	return false;
+}
+
+static void
+ff_layout_free_lseg(struct pnfs_layout_segment *lseg)
+{
+	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
+	int i;
+
+	dprintk("--> %s\n", __func__);
+
+	for (i = 0; i < fls->mirror_array_cnt; i++) {
+		if (fls->mirror_array[i]) {
+			nfs4_ff_layout_put_deviceid(fls->mirror_array[i]->mirror_ds);
+			fls->mirror_array[i]->mirror_ds = NULL;
+			if (fls->mirror_array[i]->cred) {
+				put_rpccred(fls->mirror_array[i]->cred);
+				fls->mirror_array[i]->cred = NULL;
+			}
+		}
+	}
+
+	if (lseg->pls_range.iomode == IOMODE_RW) {
+		struct nfs4_flexfile_layout *ffl;
+		struct inode *inode;
+
+		ffl = FF_LAYOUT_FROM_HDR(lseg->pls_layout);
+		inode = ffl->generic_hdr.plh_inode;
+		spin_lock(&inode->i_lock);
+		if (!ff_layout_has_rw_segments(lseg->pls_layout)) {
+			ffl->commit_info.nbuckets = 0;
+			kfree(ffl->commit_info.buckets);
+			ffl->commit_info.buckets = NULL;
+		}
+		spin_unlock(&inode->i_lock);
+	}
+	_ff_layout_free_lseg(fls);
+}
+
+/* Return 1 until we have multiple lsegs support */
+static int
+ff_layout_get_lseg_count(struct nfs4_ff_layout_segment *fls)
+{
+	return 1;
+}
+
+static int
+ff_layout_alloc_commit_info(struct pnfs_layout_segment *lseg,
+			    struct nfs_commit_info *cinfo,
+			    gfp_t gfp_flags)
+{
+	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
+	struct pnfs_commit_bucket *buckets;
+	int size;
+
+	if (cinfo->ds->nbuckets != 0) {
+		/* This assumes there is only one RW lseg per file.
+		 * To support multiple lseg per file, we need to
+		 * change struct pnfs_commit_bucket to allow dynamic
+		 * increasing nbuckets.
+		 */
+		return 0;
+	}
+
+	size = ff_layout_get_lseg_count(fls) * FF_LAYOUT_MIRROR_COUNT(lseg);
+
+	buckets = kcalloc(size, sizeof(struct pnfs_commit_bucket),
+			  gfp_flags);
+	if (!buckets)
+		return -ENOMEM;
+	else {
+		int i;
+
+		spin_lock(cinfo->lock);
+		if (cinfo->ds->nbuckets != 0)
+			kfree(buckets);
+		else {
+			cinfo->ds->buckets = buckets;
+			cinfo->ds->nbuckets = size;
+			for (i = 0; i < size; i++) {
+				INIT_LIST_HEAD(&buckets[i].written);
+				INIT_LIST_HEAD(&buckets[i].committing);
+				/* mark direct verifier as unset */
+				buckets[i].direct_verf.committed =
+					NFS_INVALID_STABLE_HOW;
+			}
+		}
+		spin_unlock(cinfo->lock);
+		return 0;
+	}
+}
+
+static struct nfs4_pnfs_ds *
+ff_layout_choose_best_ds_for_read(struct nfs_pageio_descriptor *pgio,
+				  int *best_idx)
+{
+	struct nfs4_ff_layout_segment *fls;
+	struct nfs4_pnfs_ds *ds;
+	int idx;
+
+	fls = FF_LAYOUT_LSEG(pgio->pg_lseg);
+	/* mirrors are sorted by efficiency */
+	for (idx = 0; idx < fls->mirror_array_cnt; idx++) {
+		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, idx, false);
+		if (ds) {
+			*best_idx = idx;
+			return ds;
+		}
+	}
+
+	return NULL;
+}
+
+static void
+ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
+			struct nfs_page *req)
+{
+	struct nfs_pgio_mirror *pgm;
+	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_pnfs_ds *ds;
+	int ds_idx;
+
+	/* Use full layout for now */
+	if (!pgio->pg_lseg)
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+						   req->wb_context,
+						   0,
+						   NFS4_MAX_UINT64,
+						   IOMODE_READ,
+						   GFP_KERNEL);
+	/* If no lseg, fall back to read through mds */
+	if (pgio->pg_lseg == NULL)
+		goto out_mds;
+
+	ds = ff_layout_choose_best_ds_for_read(pgio, &ds_idx);
+	if (!ds)
+		goto out_mds;
+	mirror = FF_LAYOUT_COMP(pgio->pg_lseg, ds_idx);
+
+	pgio->pg_mirror_idx = ds_idx;
+
+	/* read always uses only one mirror - idx 0 for pgio layer */
+	pgm = &pgio->pg_mirrors[0];
+	pgm->pg_bsize = mirror->mirror_ds->ds_versions[0].rsize;
+
+	return;
+out_mds:
+	pnfs_put_lseg(pgio->pg_lseg);
+	pgio->pg_lseg = NULL;
+	nfs_pageio_reset_read_mds(pgio);
+}
+
+static void
+ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
+			struct nfs_page *req)
+{
+	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs_pgio_mirror *pgm;
+	struct nfs_commit_info cinfo;
+	struct nfs4_pnfs_ds *ds;
+	int i;
+	int status;
+
+	if (!pgio->pg_lseg)
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+						   req->wb_context,
+						   0,
+						   NFS4_MAX_UINT64,
+						   IOMODE_RW,
+						   GFP_NOFS);
+	/* If no lseg, fall back to write through mds */
+	if (pgio->pg_lseg == NULL)
+		goto out_mds;
+
+	nfs_init_cinfo(&cinfo, pgio->pg_inode, pgio->pg_dreq);
+	status = ff_layout_alloc_commit_info(pgio->pg_lseg, &cinfo, GFP_NOFS);
+	if (status < 0)
+		goto out_mds;
+
+	/* Use a direct mapping of ds_idx to pgio mirror_idx */
+	if (WARN_ON_ONCE(pgio->pg_mirror_count !=
+	    FF_LAYOUT_MIRROR_COUNT(pgio->pg_lseg)))
+		goto out_mds;
+
+	for (i = 0; i < pgio->pg_mirror_count; i++) {
+		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, i, true);
+		if (!ds)
+			goto out_mds;
+		pgm = &pgio->pg_mirrors[i];
+		mirror = FF_LAYOUT_COMP(pgio->pg_lseg, i);
+		pgm->pg_bsize = mirror->mirror_ds->ds_versions[0].wsize;
+	}
+
+	return;
+
+out_mds:
+	pnfs_put_lseg(pgio->pg_lseg);
+	pgio->pg_lseg = NULL;
+	nfs_pageio_reset_write_mds(pgio);
+}
+
+static unsigned int
+ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
+				    struct nfs_page *req)
+{
+	if (!pgio->pg_lseg)
+		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+						   req->wb_context,
+						   0,
+						   NFS4_MAX_UINT64,
+						   IOMODE_RW,
+						   GFP_NOFS);
+	if (pgio->pg_lseg)
+		return FF_LAYOUT_MIRROR_COUNT(pgio->pg_lseg);
+
+	/* no lseg means that pnfs is not in use, so no mirroring here */
+	pnfs_put_lseg(pgio->pg_lseg);
+	pgio->pg_lseg = NULL;
+	nfs_pageio_reset_write_mds(pgio);
+	return 1;
+}
+
+static const struct nfs_pageio_ops ff_layout_pg_read_ops = {
+	.pg_init = ff_layout_pg_init_read,
+	.pg_test = pnfs_generic_pg_test,
+	.pg_doio = pnfs_generic_pg_readpages,
+	.pg_cleanup = pnfs_generic_pg_cleanup,
+};
+
+static const struct nfs_pageio_ops ff_layout_pg_write_ops = {
+	.pg_init = ff_layout_pg_init_write,
+	.pg_test = pnfs_generic_pg_test,
+	.pg_doio = pnfs_generic_pg_writepages,
+	.pg_get_mirror_count = ff_layout_pg_get_mirror_count_write,
+	.pg_cleanup = pnfs_generic_pg_cleanup,
+};
+
+static void ff_layout_reset_write(struct nfs_pgio_header *hdr, bool retry_pnfs)
+{
+	struct rpc_task *task = &hdr->task;
+
+	pnfs_layoutcommit_inode(hdr->inode, false);
+
+	if (retry_pnfs) {
+		dprintk("%s Reset task %5u for i/o through pNFS "
+			"(req %s/%llu, %u bytes @ offset %llu)\n", __func__,
+			hdr->task.tk_pid,
+			hdr->inode->i_sb->s_id,
+			(unsigned long long)NFS_FILEID(hdr->inode),
+			hdr->args.count,
+			(unsigned long long)hdr->args.offset);
+
+		if (!hdr->dreq) {
+			struct nfs_open_context *ctx;
+
+			ctx = nfs_list_entry(hdr->pages.next)->wb_context;
+			set_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
+			hdr->completion_ops->error_cleanup(&hdr->pages);
+		} else {
+			nfs_direct_set_resched_writes(hdr->dreq);
+			/* fake unstable write to let common nfs resend pages */
+			hdr->verf.committed = NFS_UNSTABLE;
+			hdr->good_bytes = 0;
+		}
+		return;
+	}
+
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		dprintk("%s Reset task %5u for i/o through MDS "
+			"(req %s/%llu, %u bytes @ offset %llu)\n", __func__,
+			hdr->task.tk_pid,
+			hdr->inode->i_sb->s_id,
+			(unsigned long long)NFS_FILEID(hdr->inode),
+			hdr->args.count,
+			(unsigned long long)hdr->args.offset);
+
+		task->tk_status = pnfs_write_done_resend_to_mds(hdr);
+	}
+}
+
+static void ff_layout_reset_read(struct nfs_pgio_header *hdr)
+{
+	struct rpc_task *task = &hdr->task;
+
+	pnfs_layoutcommit_inode(hdr->inode, false);
+
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		dprintk("%s Reset task %5u for i/o through MDS "
+			"(req %s/%llu, %u bytes @ offset %llu)\n", __func__,
+			hdr->task.tk_pid,
+			hdr->inode->i_sb->s_id,
+			(unsigned long long)NFS_FILEID(hdr->inode),
+			hdr->args.count,
+			(unsigned long long)hdr->args.offset);
+
+		task->tk_status = pnfs_read_done_resend_to_mds(hdr);
+	}
+}
+
+static int ff_layout_async_handle_error_v4(struct rpc_task *task,
+					   struct nfs4_state *state,
+					   struct nfs_client *clp,
+					   struct pnfs_layout_segment *lseg,
+					   int idx)
+{
+	struct pnfs_layout_hdr *lo = lseg->pls_layout;
+	struct inode *inode = lo->plh_inode;
+	struct nfs_server *mds_server = NFS_SERVER(inode);
+
+	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx);
+	struct nfs_client *mds_client = mds_server->nfs_client;
+	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
+
+	if (task->tk_status >= 0)
+		return 0;
+
+	switch (task->tk_status) {
+	/* MDS state errors */
+	case -NFS4ERR_DELEG_REVOKED:
+	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_BAD_STATEID:
+		if (state == NULL)
+			break;
+		nfs_remove_bad_delegation(state->inode);
+	case -NFS4ERR_OPENMODE:
+		if (state == NULL)
+			break;
+		if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
+			goto out_bad_stateid;
+		goto wait_on_recovery;
+	case -NFS4ERR_EXPIRED:
+		if (state != NULL) {
+			if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
+				goto out_bad_stateid;
+		}
+		nfs4_schedule_lease_recovery(mds_client);
+		goto wait_on_recovery;
+	/* DS session errors */
+	case -NFS4ERR_BADSESSION:
+	case -NFS4ERR_BADSLOT:
+	case -NFS4ERR_BAD_HIGH_SLOT:
+	case -NFS4ERR_DEADSESSION:
+	case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+	case -NFS4ERR_SEQ_FALSE_RETRY:
+	case -NFS4ERR_SEQ_MISORDERED:
+		dprintk("%s ERROR %d, Reset session. Exchangeid "
+			"flags 0x%x\n", __func__, task->tk_status,
+			clp->cl_exchange_flags);
+		nfs4_schedule_session_recovery(clp->cl_session, task->tk_status);
+		break;
+	case -NFS4ERR_DELAY:
+	case -NFS4ERR_GRACE:
+		rpc_delay(task, FF_LAYOUT_POLL_RETRY_MAX);
+		break;
+	case -NFS4ERR_RETRY_UNCACHED_REP:
+		break;
+	/* Invalidate Layout errors */
+	case -NFS4ERR_PNFS_NO_LAYOUT:
+	case -ESTALE:           /* mapped NFS4ERR_STALE */
+	case -EBADHANDLE:       /* mapped NFS4ERR_BADHANDLE */
+	case -EISDIR:           /* mapped NFS4ERR_ISDIR */
+	case -NFS4ERR_FHEXPIRED:
+	case -NFS4ERR_WRONG_TYPE:
+		dprintk("%s Invalid layout error %d\n", __func__,
+			task->tk_status);
+		/*
+		 * Destroy layout so new i/o will get a new layout.
+		 * Layout will not be destroyed until all current lseg
+		 * references are put. Mark layout as invalid to resend failed
+		 * i/o and all i/o waiting on the slot table to the MDS until
+		 * layout is destroyed and a new valid layout is obtained.
+		 */
+		pnfs_destroy_layout(NFS_I(inode));
+		rpc_wake_up(&tbl->slot_tbl_waitq);
+		goto reset;
+	/* RPC connection errors */
+	case -ECONNREFUSED:
+	case -EHOSTDOWN:
+	case -EHOSTUNREACH:
+	case -ENETUNREACH:
+	case -EIO:
+	case -ETIMEDOUT:
+	case -EPIPE:
+		dprintk("%s DS connection error %d\n", __func__,
+			task->tk_status);
+		nfs4_mark_deviceid_unavailable(devid);
+		rpc_wake_up(&tbl->slot_tbl_waitq);
+		/* fall through */
+	default:
+		if (ff_layout_has_available_ds(lseg))
+			return -NFS4ERR_RESET_TO_PNFS;
+reset:
+		dprintk("%s Retry through MDS. Error %d\n", __func__,
+			task->tk_status);
+		return -NFS4ERR_RESET_TO_MDS;
+	}
+out:
+	task->tk_status = 0;
+	return -EAGAIN;
+out_bad_stateid:
+	task->tk_status = -EIO;
+	return 0;
+wait_on_recovery:
+	rpc_sleep_on(&mds_client->cl_rpcwaitq, task, NULL);
+	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
+		rpc_wake_up_queued_task(&mds_client->cl_rpcwaitq, task);
+	goto out;
+}
+
+/* Retry all errors through either pNFS or MDS except for -EJUKEBOX */
+static int ff_layout_async_handle_error_v3(struct rpc_task *task,
+					   struct pnfs_layout_segment *lseg,
+					   int idx)
+{
+	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx);
+
+	if (task->tk_status >= 0)
+		return 0;
+
+	if (task->tk_status != -EJUKEBOX) {
+		dprintk("%s DS connection error %d\n", __func__,
+			task->tk_status);
+		nfs4_mark_deviceid_unavailable(devid);
+		if (ff_layout_has_available_ds(lseg))
+			return -NFS4ERR_RESET_TO_PNFS;
+		else
+			return -NFS4ERR_RESET_TO_MDS;
+	}
+
+	if (task->tk_status == -EJUKEBOX)
+		nfs_inc_stats(lseg->pls_layout->plh_inode, NFSIOS_DELAY);
+	task->tk_status = 0;
+	rpc_restart_call(task);
+	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
+	return -EAGAIN;
+}
+
+static int ff_layout_async_handle_error(struct rpc_task *task,
+					struct nfs4_state *state,
+					struct nfs_client *clp,
+					struct pnfs_layout_segment *lseg,
+					int idx)
+{
+	int vers = clp->cl_nfs_mod->rpc_vers->number;
+
+	switch (vers) {
+	case 3:
+		return ff_layout_async_handle_error_v3(task, lseg, idx);
+	case 4:
+		return ff_layout_async_handle_error_v4(task, state, clp,
+						       lseg, idx);
+	default:
+		/* should never happen */
+		WARN_ON_ONCE(1);
+		return 0;
+	}
+}
+
+static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
+					int idx, u64 offset, u64 length,
+					u32 status, int opnum)
+{
+	struct nfs4_ff_layout_mirror *mirror;
+	int err;
+
+	mirror = FF_LAYOUT_COMP(lseg, idx);
+	err = ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
+				       mirror, offset, length, status, opnum,
+				       GFP_NOIO);
+	dprintk("%s: err %d op %d status %u\n", __func__, err, opnum, status);
+}
+
+/* NFS_PROTO call done callback routines */
+
+static int ff_layout_read_done_cb(struct rpc_task *task,
+				struct nfs_pgio_header *hdr)
+{
+	struct inode *inode;
+	int err;
+
+	trace_nfs4_pnfs_read(hdr, task->tk_status);
+	if (task->tk_status == -ETIMEDOUT && !hdr->res.op_status)
+		hdr->res.op_status = NFS4ERR_NXIO;
+	if (task->tk_status < 0 && hdr->res.op_status)
+		ff_layout_io_track_ds_error(hdr->lseg, hdr->pgio_mirror_idx,
+					    hdr->args.offset, hdr->args.count,
+					    hdr->res.op_status, OP_READ);
+	err = ff_layout_async_handle_error(task, hdr->args.context->state,
+					   hdr->ds_clp, hdr->lseg,
+					   hdr->pgio_mirror_idx);
+
+	switch (err) {
+	case -NFS4ERR_RESET_TO_PNFS:
+		set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+			&hdr->lseg->pls_layout->plh_flags);
+		pnfs_read_resend_pnfs(hdr);
+		return task->tk_status;
+	case -NFS4ERR_RESET_TO_MDS:
+		inode = hdr->lseg->pls_layout->plh_inode;
+		pnfs_error_mark_layout_for_return(inode, hdr->lseg);
+		ff_layout_reset_read(hdr);
+		return task->tk_status;
+	case -EAGAIN:
+		rpc_restart_call_prepare(task);
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
+/*
+ * We reference the rpc_cred of the first WRITE that triggers the need for
+ * a LAYOUTCOMMIT, and use it to send the layoutcommit compound.
+ * rfc5661 is not clear about which credential should be used.
+ *
+ * Flexlayout client should treat DS replied FILE_SYNC as DATA_SYNC, so
+ * to follow http://www.rfc-editor.org/errata_search.php?rfc=5661&eid=2751
+ * we always send layoutcommit after DS writes.
+ */
+static void
+ff_layout_set_layoutcommit(struct nfs_pgio_header *hdr)
+{
+	pnfs_set_layoutcommit(hdr);
+	dprintk("%s inode %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
+		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
+}
+
+static bool
+ff_layout_reset_to_mds(struct pnfs_layout_segment *lseg, int idx)
+{
+	/* No mirroring for now */
+	struct nfs4_deviceid_node *node = FF_LAYOUT_DEVID_NODE(lseg, idx);
+
+	return ff_layout_test_devid_unavailable(node);
+}
+
+static int ff_layout_read_prepare_common(struct rpc_task *task,
+					 struct nfs_pgio_header *hdr)
+{
+	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
+		rpc_exit(task, -EIO);
+		return -EIO;
+	}
+	if (ff_layout_reset_to_mds(hdr->lseg, hdr->pgio_mirror_idx)) {
+		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		if (ff_layout_has_available_ds(hdr->lseg))
+			pnfs_read_resend_pnfs(hdr);
+		else
+			ff_layout_reset_read(hdr);
+		rpc_exit(task, 0);
+		return -EAGAIN;
+	}
+	hdr->pgio_done_cb = ff_layout_read_done_cb;
+
+	return 0;
+}
+
+/*
+ * Call ops for the async read/write cases
+ * In the case of dense layouts, the offset needs to be reset to its
+ * original value.
+ */
+static void ff_layout_read_prepare_v3(struct rpc_task *task, void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	if (ff_layout_read_prepare_common(task, hdr))
+		return;
+
+	rpc_call_start(task);
+}
+
+static int ff_layout_setup_sequence(struct nfs_client *ds_clp,
+				    struct nfs4_sequence_args *args,
+				    struct nfs4_sequence_res *res,
+				    struct rpc_task *task)
+{
+	if (ds_clp->cl_session)
+		return nfs41_setup_sequence(ds_clp->cl_session,
+					   args,
+					   res,
+					   task);
+	return nfs40_setup_sequence(ds_clp->cl_slot_tbl,
+				   args,
+				   res,
+				   task);
+}
+
+static void ff_layout_read_prepare_v4(struct rpc_task *task, void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	if (ff_layout_read_prepare_common(task, hdr))
+		return;
+
+	if (ff_layout_setup_sequence(hdr->ds_clp,
+				     &hdr->args.seq_args,
+				     &hdr->res.seq_res,
+				     task))
+		return;
+
+	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
+			hdr->args.lock_context, FMODE_READ) == -EIO)
+		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
+}
+
+static void ff_layout_read_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
+
+	if (test_bit(NFS_IOHDR_REDO, &hdr->flags) &&
+	    task->tk_status == 0) {
+		nfs4_sequence_done(task, &hdr->res.seq_res);
+		return;
+	}
+
+	/* Note this may cause RPC to be resent */
+	hdr->mds_ops->rpc_call_done(task, hdr);
+}
+
+static void ff_layout_read_count_stats(struct rpc_task *task, void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	rpc_count_iostats_metrics(task,
+	    &NFS_CLIENT(hdr->inode)->cl_metrics[NFSPROC4_CLNT_READ]);
+}
+
+static int ff_layout_write_done_cb(struct rpc_task *task,
+				struct nfs_pgio_header *hdr)
+{
+	struct inode *inode;
+	int err;
+
+	trace_nfs4_pnfs_write(hdr, task->tk_status);
+	if (task->tk_status == -ETIMEDOUT && !hdr->res.op_status)
+		hdr->res.op_status = NFS4ERR_NXIO;
+	if (task->tk_status < 0 && hdr->res.op_status)
+		ff_layout_io_track_ds_error(hdr->lseg, hdr->pgio_mirror_idx,
+					    hdr->args.offset, hdr->args.count,
+					    hdr->res.op_status, OP_WRITE);
+	err = ff_layout_async_handle_error(task, hdr->args.context->state,
+					   hdr->ds_clp, hdr->lseg,
+					   hdr->pgio_mirror_idx);
+
+	switch (err) {
+	case -NFS4ERR_RESET_TO_PNFS:
+	case -NFS4ERR_RESET_TO_MDS:
+		inode = hdr->lseg->pls_layout->plh_inode;
+		pnfs_error_mark_layout_for_return(inode, hdr->lseg);
+		if (err == -NFS4ERR_RESET_TO_PNFS) {
+			pnfs_set_retry_layoutget(hdr->lseg->pls_layout);
+			ff_layout_reset_write(hdr, true);
+		} else {
+			pnfs_clear_retry_layoutget(hdr->lseg->pls_layout);
+			ff_layout_reset_write(hdr, false);
+		}
+		return task->tk_status;
+	case -EAGAIN:
+		rpc_restart_call_prepare(task);
+		return -EAGAIN;
+	}
+
+	if (hdr->res.verf->committed == NFS_FILE_SYNC ||
+	    hdr->res.verf->committed == NFS_DATA_SYNC)
+		ff_layout_set_layoutcommit(hdr);
+
+	return 0;
+}
+
+static int ff_layout_commit_done_cb(struct rpc_task *task,
+				     struct nfs_commit_data *data)
+{
+	struct inode *inode;
+	int err;
+
+	trace_nfs4_pnfs_commit_ds(data, task->tk_status);
+	if (task->tk_status == -ETIMEDOUT && !data->res.op_status)
+		data->res.op_status = NFS4ERR_NXIO;
+	if (task->tk_status < 0 && data->res.op_status)
+		ff_layout_io_track_ds_error(data->lseg, data->ds_commit_index,
+					    data->args.offset, data->args.count,
+					    data->res.op_status, OP_COMMIT);
+	err = ff_layout_async_handle_error(task, NULL, data->ds_clp,
+					   data->lseg, data->ds_commit_index);
+
+	switch (err) {
+	case -NFS4ERR_RESET_TO_PNFS:
+	case -NFS4ERR_RESET_TO_MDS:
+		inode = data->lseg->pls_layout->plh_inode;
+		pnfs_error_mark_layout_for_return(inode, data->lseg);
+		if (err == -NFS4ERR_RESET_TO_PNFS)
+			pnfs_set_retry_layoutget(data->lseg->pls_layout);
+		else
+			pnfs_clear_retry_layoutget(data->lseg->pls_layout);
+		pnfs_generic_prepare_to_resend_writes(data);
+		return -EAGAIN;
+	case -EAGAIN:
+		rpc_restart_call_prepare(task);
+		return -EAGAIN;
+	}
+
+	if (data->verf.committed == NFS_UNSTABLE)
+		pnfs_commit_set_layoutcommit(data);
+
+	return 0;
+}
+
+static int ff_layout_write_prepare_common(struct rpc_task *task,
+					  struct nfs_pgio_header *hdr)
+{
+	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
+		rpc_exit(task, -EIO);
+		return -EIO;
+	}
+
+	if (ff_layout_reset_to_mds(hdr->lseg, hdr->pgio_mirror_idx)) {
+		bool retry_pnfs;
+
+		retry_pnfs = ff_layout_has_available_ds(hdr->lseg);
+		dprintk("%s task %u reset io to %s\n", __func__,
+			task->tk_pid, retry_pnfs ? "pNFS" : "MDS");
+		ff_layout_reset_write(hdr, retry_pnfs);
+		rpc_exit(task, 0);
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
+static void ff_layout_write_prepare_v3(struct rpc_task *task, void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	if (ff_layout_write_prepare_common(task, hdr))
+		return;
+
+	rpc_call_start(task);
+}
+
+static void ff_layout_write_prepare_v4(struct rpc_task *task, void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	if (ff_layout_write_prepare_common(task, hdr))
+		return;
+
+	if (ff_layout_setup_sequence(hdr->ds_clp,
+				     &hdr->args.seq_args,
+				     &hdr->res.seq_res,
+				     task))
+		return;
+
+	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
+			hdr->args.lock_context, FMODE_WRITE) == -EIO)
+		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
+}
+
+static void ff_layout_write_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	if (test_bit(NFS_IOHDR_REDO, &hdr->flags) &&
+	    task->tk_status == 0) {
+		nfs4_sequence_done(task, &hdr->res.seq_res);
+		return;
+	}
+
+	/* Note this may cause RPC to be resent */
+	hdr->mds_ops->rpc_call_done(task, hdr);
+}
+
+static void ff_layout_write_count_stats(struct rpc_task *task, void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	rpc_count_iostats_metrics(task,
+	    &NFS_CLIENT(hdr->inode)->cl_metrics[NFSPROC4_CLNT_WRITE]);
+}
+
+static void ff_layout_commit_prepare_v3(struct rpc_task *task, void *data)
+{
+	rpc_call_start(task);
+}
+
+static void ff_layout_commit_prepare_v4(struct rpc_task *task, void *data)
+{
+	struct nfs_commit_data *wdata = data;
+
+	ff_layout_setup_sequence(wdata->ds_clp,
+				 &wdata->args.seq_args,
+				 &wdata->res.seq_res,
+				 task);
+}
+
+static void ff_layout_commit_count_stats(struct rpc_task *task, void *data)
+{
+	struct nfs_commit_data *cdata = data;
+
+	rpc_count_iostats_metrics(task,
+	    &NFS_CLIENT(cdata->inode)->cl_metrics[NFSPROC4_CLNT_COMMIT]);
+}
+
+static const struct rpc_call_ops ff_layout_read_call_ops_v3 = {
+	.rpc_call_prepare = ff_layout_read_prepare_v3,
+	.rpc_call_done = ff_layout_read_call_done,
+	.rpc_count_stats = ff_layout_read_count_stats,
+	.rpc_release = pnfs_generic_rw_release,
+};
+
+static const struct rpc_call_ops ff_layout_read_call_ops_v4 = {
+	.rpc_call_prepare = ff_layout_read_prepare_v4,
+	.rpc_call_done = ff_layout_read_call_done,
+	.rpc_count_stats = ff_layout_read_count_stats,
+	.rpc_release = pnfs_generic_rw_release,
+};
+
+static const struct rpc_call_ops ff_layout_write_call_ops_v3 = {
+	.rpc_call_prepare = ff_layout_write_prepare_v3,
+	.rpc_call_done = ff_layout_write_call_done,
+	.rpc_count_stats = ff_layout_write_count_stats,
+	.rpc_release = pnfs_generic_rw_release,
+};
+
+static const struct rpc_call_ops ff_layout_write_call_ops_v4 = {
+	.rpc_call_prepare = ff_layout_write_prepare_v4,
+	.rpc_call_done = ff_layout_write_call_done,
+	.rpc_count_stats = ff_layout_write_count_stats,
+	.rpc_release = pnfs_generic_rw_release,
+};
+
+static const struct rpc_call_ops ff_layout_commit_call_ops_v3 = {
+	.rpc_call_prepare = ff_layout_commit_prepare_v3,
+	.rpc_call_done = pnfs_generic_write_commit_done,
+	.rpc_count_stats = ff_layout_commit_count_stats,
+	.rpc_release = pnfs_generic_commit_release,
+};
+
+static const struct rpc_call_ops ff_layout_commit_call_ops_v4 = {
+	.rpc_call_prepare = ff_layout_commit_prepare_v4,
+	.rpc_call_done = pnfs_generic_write_commit_done,
+	.rpc_count_stats = ff_layout_commit_count_stats,
+	.rpc_release = pnfs_generic_commit_release,
+};
+
+static enum pnfs_try_status
+ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
+{
+	struct pnfs_layout_segment *lseg = hdr->lseg;
+	struct nfs4_pnfs_ds *ds;
+	struct rpc_clnt *ds_clnt;
+	struct rpc_cred *ds_cred;
+	loff_t offset = hdr->args.offset;
+	u32 idx = hdr->pgio_mirror_idx;
+	int vers;
+	struct nfs_fh *fh;
+
+	dprintk("--> %s ino %lu pgbase %u req %Zu@%llu\n",
+		__func__, hdr->inode->i_ino,
+		hdr->args.pgbase, (size_t)hdr->args.count, offset);
+
+	ds = nfs4_ff_layout_prepare_ds(lseg, idx, false);
+	if (!ds)
+		goto out_failed;
+
+	ds_clnt = nfs4_ff_find_or_create_ds_client(lseg, idx, ds->ds_clp,
+						   hdr->inode);
+	if (IS_ERR(ds_clnt))
+		goto out_failed;
+
+	ds_cred = ff_layout_get_ds_cred(lseg, idx, hdr->cred);
+	if (IS_ERR(ds_cred))
+		goto out_failed;
+
+	vers = nfs4_ff_layout_ds_version(lseg, idx);
+
+	dprintk("%s USE DS: %s cl_count %d vers %d\n", __func__,
+		ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count), vers);
+
+	atomic_inc(&ds->ds_clp->cl_count);
+	hdr->ds_clp = ds->ds_clp;
+	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
+	if (fh)
+		hdr->args.fh = fh;
+
+	/*
+	 * Note that if we ever decide to split across DSes,
+	 * then we may need to handle dense-like offsets.
+	 */
+	hdr->args.offset = offset;
+	hdr->mds_offset = offset;
+
+	/* Perform an asynchronous read to ds */
+	nfs_initiate_pgio(ds_clnt, hdr, ds_cred, ds->ds_clp->rpc_ops,
+			  vers == 3 ? &ff_layout_read_call_ops_v3 :
+				      &ff_layout_read_call_ops_v4,
+			  0, RPC_TASK_SOFTCONN);
+
+	return PNFS_ATTEMPTED;
+
+out_failed:
+	if (ff_layout_has_available_ds(lseg))
+		return PNFS_TRY_AGAIN;
+	return PNFS_NOT_ATTEMPTED;
+}
+
+/* Perform async writes. */
+static enum pnfs_try_status
+ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
+{
+	struct pnfs_layout_segment *lseg = hdr->lseg;
+	struct nfs4_pnfs_ds *ds;
+	struct rpc_clnt *ds_clnt;
+	struct rpc_cred *ds_cred;
+	loff_t offset = hdr->args.offset;
+	int vers;
+	struct nfs_fh *fh;
+	int idx = hdr->pgio_mirror_idx;
+
+	ds = nfs4_ff_layout_prepare_ds(lseg, idx, true);
+	if (!ds)
+		return PNFS_NOT_ATTEMPTED;
+
+	ds_clnt = nfs4_ff_find_or_create_ds_client(lseg, idx, ds->ds_clp,
+						   hdr->inode);
+	if (IS_ERR(ds_clnt))
+		return PNFS_NOT_ATTEMPTED;
+
+	ds_cred = ff_layout_get_ds_cred(lseg, idx, hdr->cred);
+	if (IS_ERR(ds_cred))
+		return PNFS_NOT_ATTEMPTED;
+
+	vers = nfs4_ff_layout_ds_version(lseg, idx);
+
+	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s cl_count %d vers %d\n",
+		__func__, hdr->inode->i_ino, sync, (size_t) hdr->args.count,
+		offset, ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count),
+		vers);
+
+	hdr->pgio_done_cb = ff_layout_write_done_cb;
+	atomic_inc(&ds->ds_clp->cl_count);
+	hdr->ds_clp = ds->ds_clp;
+	hdr->ds_commit_idx = idx;
+	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
+	if (fh)
+		hdr->args.fh = fh;
+
+	/*
+	 * Note that if we ever decide to split across DSes,
+	 * then we may need to handle dense-like offsets.
+	 */
+	hdr->args.offset = offset;
+
+	/* Perform an asynchronous write */
+	nfs_initiate_pgio(ds_clnt, hdr, ds_cred, ds->ds_clp->rpc_ops,
+			  vers == 3 ? &ff_layout_write_call_ops_v3 :
+				      &ff_layout_write_call_ops_v4,
+			  sync, RPC_TASK_SOFTCONN);
+	return PNFS_ATTEMPTED;
+}
+
+static void
+ff_layout_mark_request_commit(struct nfs_page *req,
+			      struct pnfs_layout_segment *lseg,
+			      struct nfs_commit_info *cinfo,
+			      u32 ds_commit_idx)
+{
+	struct list_head *list;
+	struct pnfs_commit_bucket *buckets;
+
+	spin_lock(cinfo->lock);
+	buckets = cinfo->ds->buckets;
+	list = &buckets[ds_commit_idx].written;
+	if (list_empty(list)) {
+		/* Non-empty buckets hold a reference on the lseg.  That ref
+		 * is normally transferred to the COMMIT call and released
+		 * there.  It could also be released if the last req is pulled
+		 * off due to a rewrite, in which case it will be done in
+		 * pnfs_common_clear_request_commit
+		 */
+		WARN_ON_ONCE(buckets[ds_commit_idx].wlseg != NULL);
+		buckets[ds_commit_idx].wlseg = pnfs_get_lseg(lseg);
+	}
+	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
+	cinfo->ds->nwritten++;
+
+	/* nfs_request_add_commit_list(). We need to add req to list without
+	 * dropping cinfo lock.
+	 */
+	set_bit(PG_CLEAN, &(req)->wb_flags);
+	nfs_list_add_request(req, list);
+	cinfo->mds->ncommit++;
+	spin_unlock(cinfo->lock);
+	if (!cinfo->dreq) {
+		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+			     BDI_RECLAIMABLE);
+		__mark_inode_dirty(req->wb_context->dentry->d_inode,
+				   I_DIRTY_DATASYNC);
+	}
+}
+
+static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
+{
+	return i;
+}
+
+static struct nfs_fh *
+select_ds_fh_from_commit(struct pnfs_layout_segment *lseg, u32 i)
+{
+	struct nfs4_ff_layout_segment *flseg = FF_LAYOUT_LSEG(lseg);
+
+	/* FIXME: Assume that there is only one NFS version available
+	 * for the DS.
+	 */
+	return &flseg->mirror_array[i]->fh_versions[0];
+}
+
+static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
+{
+	struct pnfs_layout_segment *lseg = data->lseg;
+	struct nfs4_pnfs_ds *ds;
+	struct rpc_clnt *ds_clnt;
+	struct rpc_cred *ds_cred;
+	u32 idx;
+	int vers;
+	struct nfs_fh *fh;
+
+	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
+	ds = nfs4_ff_layout_prepare_ds(lseg, idx, true);
+	if (!ds)
+		goto out_err;
+
+	ds_clnt = nfs4_ff_find_or_create_ds_client(lseg, idx, ds->ds_clp,
+						   data->inode);
+	if (IS_ERR(ds_clnt))
+		goto out_err;
+
+	ds_cred = ff_layout_get_ds_cred(lseg, idx, data->cred);
+	if (IS_ERR(ds_cred))
+		goto out_err;
+
+	vers = nfs4_ff_layout_ds_version(lseg, idx);
+
+	dprintk("%s ino %lu, how %d cl_count %d vers %d\n", __func__,
+		data->inode->i_ino, how, atomic_read(&ds->ds_clp->cl_count),
+		vers);
+	data->commit_done_cb = ff_layout_commit_done_cb;
+	data->cred = ds_cred;
+	atomic_inc(&ds->ds_clp->cl_count);
+	data->ds_clp = ds->ds_clp;
+	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
+	if (fh)
+		data->args.fh = fh;
+	return nfs_initiate_commit(ds_clnt, data, ds->ds_clp->rpc_ops,
+				   vers == 3 ? &ff_layout_commit_call_ops_v3 :
+					       &ff_layout_commit_call_ops_v4,
+				   how, RPC_TASK_SOFTCONN);
+out_err:
+	pnfs_generic_prepare_to_resend_writes(data);
+	pnfs_generic_commit_release(data);
+	return -EAGAIN;
+}
+
+static int
+ff_layout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
+			   int how, struct nfs_commit_info *cinfo)
+{
+	return pnfs_generic_commit_pagelist(inode, mds_pages, how, cinfo,
+					    ff_layout_initiate_commit);
+}
+
+static struct pnfs_ds_commit_info *
+ff_layout_get_ds_info(struct inode *inode)
+{
+	struct pnfs_layout_hdr *layout = NFS_I(inode)->layout;
+
+	if (layout == NULL)
+		return NULL;
+
+	return &FF_LAYOUT_FROM_HDR(layout)->commit_info;
+}
+
+static void
+ff_layout_free_deveiceid_node(struct nfs4_deviceid_node *d)
+{
+	nfs4_ff_layout_free_deviceid(container_of(d, struct nfs4_ff_layout_ds,
+						  id_node));
+}
+
+static int ff_layout_encode_ioerr(struct nfs4_flexfile_layout *flo,
+				  struct xdr_stream *xdr,
+				  const struct nfs4_layoutreturn_args *args)
+{
+	struct pnfs_layout_hdr *hdr = &flo->generic_hdr;
+	__be32 *start;
+	int count = 0, ret = 0;
+
+	start = xdr_reserve_space(xdr, 4);
+	if (unlikely(!start))
+		return -E2BIG;
+
+	/* This assume we always return _ALL_ layouts */
+	spin_lock(&hdr->plh_inode->i_lock);
+	ret = ff_layout_encode_ds_ioerr(flo, xdr, &count, &args->range);
+	spin_unlock(&hdr->plh_inode->i_lock);
+
+	*start = cpu_to_be32(count);
+
+	return ret;
+}
+
+/* report nothing for now */
+static void ff_layout_encode_iostats(struct nfs4_flexfile_layout *flo,
+				     struct xdr_stream *xdr,
+				     const struct nfs4_layoutreturn_args *args)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (likely(p))
+		*p = cpu_to_be32(0);
+}
+
+static struct nfs4_deviceid_node *
+ff_layout_alloc_deviceid_node(struct nfs_server *server,
+			      struct pnfs_device *pdev, gfp_t gfp_flags)
+{
+	struct nfs4_ff_layout_ds *dsaddr;
+
+	dsaddr = nfs4_ff_alloc_deviceid_node(server, pdev, gfp_flags);
+	if (!dsaddr)
+		return NULL;
+	return &dsaddr->id_node;
+}
+
+static void
+ff_layout_encode_layoutreturn(struct pnfs_layout_hdr *lo,
+			      struct xdr_stream *xdr,
+			      const struct nfs4_layoutreturn_args *args)
+{
+	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
+	__be32 *start;
+
+	dprintk("%s: Begin\n", __func__);
+	start = xdr_reserve_space(xdr, 4);
+	BUG_ON(!start);
+
+	if (ff_layout_encode_ioerr(flo, xdr, args))
+		goto out;
+
+	ff_layout_encode_iostats(flo, xdr, args);
+out:
+	*start = cpu_to_be32((xdr->p - start - 1) * 4);
+	dprintk("%s: Return\n", __func__);
+}
+
+static struct pnfs_layoutdriver_type flexfilelayout_type = {
+	.id			= LAYOUT_FLEX_FILES,
+	.name			= "LAYOUT_FLEX_FILES",
+	.owner			= THIS_MODULE,
+	.alloc_layout_hdr	= ff_layout_alloc_layout_hdr,
+	.free_layout_hdr	= ff_layout_free_layout_hdr,
+	.alloc_lseg		= ff_layout_alloc_lseg,
+	.free_lseg		= ff_layout_free_lseg,
+	.pg_read_ops		= &ff_layout_pg_read_ops,
+	.pg_write_ops		= &ff_layout_pg_write_ops,
+	.get_ds_info		= ff_layout_get_ds_info,
+	.free_deviceid_node	= ff_layout_free_deveiceid_node,
+	.mark_request_commit	= ff_layout_mark_request_commit,
+	.clear_request_commit	= pnfs_generic_clear_request_commit,
+	.scan_commit_lists	= pnfs_generic_scan_commit_lists,
+	.recover_commit_reqs	= pnfs_generic_recover_commit_reqs,
+	.commit_pagelist	= ff_layout_commit_pagelist,
+	.read_pagelist		= ff_layout_read_pagelist,
+	.write_pagelist		= ff_layout_write_pagelist,
+	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
+	.encode_layoutreturn    = ff_layout_encode_layoutreturn,
+};
+
+static int __init nfs4flexfilelayout_init(void)
+{
+	printk(KERN_INFO "%s: NFSv4 Flexfile Layout Driver Registering...\n",
+	       __func__);
+	return pnfs_register_layoutdriver(&flexfilelayout_type);
+}
+
+static void __exit nfs4flexfilelayout_exit(void)
+{
+	printk(KERN_INFO "%s: NFSv4 Flexfile Layout Driver Unregistering...\n",
+	       __func__);
+	pnfs_unregister_layoutdriver(&flexfilelayout_type);
+}
+
+MODULE_ALIAS("nfs-layouttype4-4");
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("The NFSv4 flexfile layout driver");
+
+module_init(nfs4flexfilelayout_init);
+module_exit(nfs4flexfilelayout_exit);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
new file mode 100644
index 0000000..712fc55
--- /dev/null
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -0,0 +1,158 @@
+/*
+ * NFSv4 flexfile layout driver data structures.
+ *
+ * Copyright (c) 2014, Primary Data, Inc. All rights reserved.
+ *
+ * Tao Peng <bergwolf@primarydata.com>
+ */
+
+#ifndef FS_NFS_NFS4FLEXFILELAYOUT_H
+#define FS_NFS_NFS4FLEXFILELAYOUT_H
+
+#include "../pnfs.h"
+
+/* XXX: Let's filter out insanely large mirror count for now to avoid oom
+ * due to network error etc. */
+#define NFS4_FLEXFILE_LAYOUT_MAX_MIRROR_CNT 4096
+
+struct nfs4_ff_ds_version {
+	u32				version;
+	u32				minor_version;
+	u32				rsize;
+	u32				wsize;
+	bool				tightly_coupled;
+};
+
+/* chained in global deviceid hlist */
+struct nfs4_ff_layout_ds {
+	struct nfs4_deviceid_node	id_node;
+	u32				ds_versions_cnt;
+	struct nfs4_ff_ds_version	*ds_versions;
+	struct nfs4_pnfs_ds		*ds;
+};
+
+struct nfs4_ff_layout_ds_err {
+	struct list_head		list; /* linked in mirror error_list */
+	u64				offset;
+	u64				length;
+	int				status;
+	enum nfs_opnum4			opnum;
+	nfs4_stateid			stateid;
+	struct nfs4_deviceid		deviceid;
+};
+
+struct nfs4_ff_layout_mirror {
+	u32				ds_count;
+	u32				efficiency;
+	struct nfs4_ff_layout_ds	*mirror_ds;
+	u32				fh_versions_cnt;
+	struct nfs_fh			*fh_versions;
+	nfs4_stateid			stateid;
+	union {
+		struct { /* same as struct unx_cred */
+			u32		uid; /* -1 iff AUTH_NONE */
+			u32		gid; /* -1 iff AUTH_NONE */
+			u32		gids[16];
+		};
+	};
+	struct rpc_cred			*cred;
+	spinlock_t			lock;
+};
+
+struct nfs4_ff_layout_segment {
+	struct pnfs_layout_segment	generic_hdr;
+	u64				stripe_unit;
+	u32				mirror_array_cnt;
+	struct nfs4_ff_layout_mirror	**mirror_array;
+};
+
+struct nfs4_flexfile_layout {
+	struct pnfs_layout_hdr generic_hdr;
+	struct pnfs_ds_commit_info commit_info;
+	struct list_head	error_list; /* nfs4_ff_layout_ds_err */
+};
+
+static inline struct nfs4_flexfile_layout *
+FF_LAYOUT_FROM_HDR(struct pnfs_layout_hdr *lo)
+{
+	return container_of(lo, struct nfs4_flexfile_layout, generic_hdr);
+}
+
+static inline struct nfs4_ff_layout_segment *
+FF_LAYOUT_LSEG(struct pnfs_layout_segment *lseg)
+{
+	return container_of(lseg,
+			    struct nfs4_ff_layout_segment,
+			    generic_hdr);
+}
+
+static inline struct nfs4_deviceid_node *
+FF_LAYOUT_DEVID_NODE(struct pnfs_layout_segment *lseg, u32 idx)
+{
+	if (idx >= FF_LAYOUT_LSEG(lseg)->mirror_array_cnt ||
+	    FF_LAYOUT_LSEG(lseg)->mirror_array[idx] == NULL ||
+	    FF_LAYOUT_LSEG(lseg)->mirror_array[idx]->mirror_ds == NULL)
+		return NULL;
+	return &FF_LAYOUT_LSEG(lseg)->mirror_array[idx]->mirror_ds->id_node;
+}
+
+static inline struct nfs4_ff_layout_ds *
+FF_LAYOUT_MIRROR_DS(struct nfs4_deviceid_node *node)
+{
+	return container_of(node, struct nfs4_ff_layout_ds, id_node);
+}
+
+static inline struct nfs4_ff_layout_mirror *
+FF_LAYOUT_COMP(struct pnfs_layout_segment *lseg, u32 idx)
+{
+	if (idx >= FF_LAYOUT_LSEG(lseg)->mirror_array_cnt)
+		return NULL;
+	return FF_LAYOUT_LSEG(lseg)->mirror_array[idx];
+}
+
+static inline u32
+FF_LAYOUT_MIRROR_COUNT(struct pnfs_layout_segment *lseg)
+{
+	return FF_LAYOUT_LSEG(lseg)->mirror_array_cnt;
+}
+
+static inline bool
+ff_layout_test_devid_unavailable(struct nfs4_deviceid_node *node)
+{
+	return nfs4_test_deviceid_unavailable(node);
+}
+
+static inline int
+nfs4_ff_layout_ds_version(struct pnfs_layout_segment *lseg, u32 ds_idx)
+{
+	return FF_LAYOUT_COMP(lseg, ds_idx)->mirror_ds->ds_versions[0].version;
+}
+
+struct nfs4_ff_layout_ds *
+nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
+			    gfp_t gfp_flags);
+void nfs4_ff_layout_put_deviceid(struct nfs4_ff_layout_ds *mirror_ds);
+void nfs4_ff_layout_free_deviceid(struct nfs4_ff_layout_ds *mirror_ds);
+int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
+			     struct nfs4_ff_layout_mirror *mirror, u64 offset,
+			     u64 length, int status, enum nfs_opnum4 opnum,
+			     gfp_t gfp_flags);
+int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
+			      struct xdr_stream *xdr, int *count,
+			      const struct pnfs_layout_range *range);
+struct nfs_fh *
+nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx);
+
+struct nfs4_pnfs_ds *
+nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
+			  bool fail_return);
+
+struct rpc_clnt *
+nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg,
+				 u32 ds_idx,
+				 struct nfs_client *ds_clp,
+				 struct inode *inode);
+struct rpc_cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
+				       u32 ds_idx, struct rpc_cred *mdscred);
+bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
+#endif /* FS_NFS_NFS4FLEXFILELAYOUT_H */
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
new file mode 100644
index 0000000..5dae5c2
--- /dev/null
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -0,0 +1,552 @@
+/*
+ * Device operations for the pnfs nfs4 file layout driver.
+ *
+ * Copyright (c) 2014, Primary Data, Inc. All rights reserved.
+ *
+ * Tao Peng <bergwolf@primarydata.com>
+ */
+
+#include <linux/nfs_fs.h>
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+#include <linux/sunrpc/addr.h>
+
+#include "../internal.h"
+#include "../nfs4session.h"
+#include "flexfilelayout.h"
+
+#define NFSDBG_FACILITY		NFSDBG_PNFS_LD
+
+static unsigned int dataserver_timeo = NFS4_DEF_DS_TIMEO;
+static unsigned int dataserver_retrans = NFS4_DEF_DS_RETRANS;
+
+void nfs4_ff_layout_put_deviceid(struct nfs4_ff_layout_ds *mirror_ds)
+{
+	if (mirror_ds)
+		nfs4_put_deviceid_node(&mirror_ds->id_node);
+}
+
+void nfs4_ff_layout_free_deviceid(struct nfs4_ff_layout_ds *mirror_ds)
+{
+	nfs4_print_deviceid(&mirror_ds->id_node.deviceid);
+	nfs4_pnfs_ds_put(mirror_ds->ds);
+	kfree(mirror_ds);
+}
+
+/* Decode opaque device data and construct new_ds using it */
+struct nfs4_ff_layout_ds *
+nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
+			    gfp_t gfp_flags)
+{
+	struct xdr_stream stream;
+	struct xdr_buf buf;
+	struct page *scratch;
+	struct list_head dsaddrs;
+	struct nfs4_pnfs_ds_addr *da;
+	struct nfs4_ff_layout_ds *new_ds = NULL;
+	struct nfs4_ff_ds_version *ds_versions = NULL;
+	u32 mp_count;
+	u32 version_count;
+	__be32 *p;
+	int i, ret = -ENOMEM;
+
+	/* set up xdr stream */
+	scratch = alloc_page(gfp_flags);
+	if (!scratch)
+		goto out_err;
+
+	new_ds = kzalloc(sizeof(struct nfs4_ff_layout_ds), gfp_flags);
+	if (!new_ds)
+		goto out_scratch;
+
+	nfs4_init_deviceid_node(&new_ds->id_node,
+				server,
+				&pdev->dev_id);
+	INIT_LIST_HEAD(&dsaddrs);
+
+	xdr_init_decode_pages(&stream, &buf, pdev->pages, pdev->pglen);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
+
+	/* multipath count */
+	p = xdr_inline_decode(&stream, 4);
+	if (unlikely(!p))
+		goto out_err_drain_dsaddrs;
+	mp_count = be32_to_cpup(p);
+	dprintk("%s: multipath ds count %d\n", __func__, mp_count);
+
+	for (i = 0; i < mp_count; i++) {
+		/* multipath ds */
+		da = nfs4_decode_mp_ds_addr(server->nfs_client->cl_net,
+					    &stream, gfp_flags);
+		if (da)
+			list_add_tail(&da->da_node, &dsaddrs);
+	}
+	if (list_empty(&dsaddrs)) {
+		dprintk("%s: no suitable DS addresses found\n",
+			__func__);
+		ret = -ENOMEDIUM;
+		goto out_err_drain_dsaddrs;
+	}
+
+	/* version count */
+	p = xdr_inline_decode(&stream, 4);
+	if (unlikely(!p))
+		goto out_err_drain_dsaddrs;
+	version_count = be32_to_cpup(p);
+	dprintk("%s: version count %d\n", __func__, version_count);
+
+	ds_versions = kzalloc(version_count * sizeof(struct nfs4_ff_ds_version),
+			      gfp_flags);
+	if (!ds_versions)
+		goto out_scratch;
+
+	for (i = 0; i < version_count; i++) {
+		/* 20 = version(4) + minor_version(4) + rsize(4) + wsize(4) +
+		 * tightly_coupled(4) */
+		p = xdr_inline_decode(&stream, 20);
+		if (unlikely(!p))
+			goto out_err_drain_dsaddrs;
+		ds_versions[i].version = be32_to_cpup(p++);
+		ds_versions[i].minor_version = be32_to_cpup(p++);
+		ds_versions[i].rsize = nfs_block_size(be32_to_cpup(p++), NULL);
+		ds_versions[i].wsize = nfs_block_size(be32_to_cpup(p++), NULL);
+		ds_versions[i].tightly_coupled = be32_to_cpup(p);
+
+		if (ds_versions[i].rsize > NFS_MAX_FILE_IO_SIZE)
+			ds_versions[i].rsize = NFS_MAX_FILE_IO_SIZE;
+		if (ds_versions[i].wsize > NFS_MAX_FILE_IO_SIZE)
+			ds_versions[i].wsize = NFS_MAX_FILE_IO_SIZE;
+
+		if (ds_versions[i].version != 3 || ds_versions[i].minor_version != 0) {
+			dprintk("%s: [%d] unsupported ds version %d-%d\n", __func__,
+				i, ds_versions[i].version,
+				ds_versions[i].minor_version);
+			ret = -EPROTONOSUPPORT;
+			goto out_err_drain_dsaddrs;
+		}
+
+		dprintk("%s: [%d] vers %u minor_ver %u rsize %u wsize %u coupled %d\n",
+			__func__, i, ds_versions[i].version,
+			ds_versions[i].minor_version,
+			ds_versions[i].rsize,
+			ds_versions[i].wsize,
+			ds_versions[i].tightly_coupled);
+	}
+
+	new_ds->ds_versions = ds_versions;
+	new_ds->ds_versions_cnt = version_count;
+
+	new_ds->ds = nfs4_pnfs_ds_add(&dsaddrs, gfp_flags);
+	if (!new_ds->ds)
+		goto out_err_drain_dsaddrs;
+
+	/* If DS was already in cache, free ds addrs */
+	while (!list_empty(&dsaddrs)) {
+		da = list_first_entry(&dsaddrs,
+				      struct nfs4_pnfs_ds_addr,
+				      da_node);
+		list_del_init(&da->da_node);
+		kfree(da->da_remotestr);
+		kfree(da);
+	}
+
+	__free_page(scratch);
+	return new_ds;
+
+out_err_drain_dsaddrs:
+	while (!list_empty(&dsaddrs)) {
+		da = list_first_entry(&dsaddrs, struct nfs4_pnfs_ds_addr,
+				      da_node);
+		list_del_init(&da->da_node);
+		kfree(da->da_remotestr);
+		kfree(da);
+	}
+
+	kfree(ds_versions);
+out_scratch:
+	__free_page(scratch);
+out_err:
+	kfree(new_ds);
+
+	dprintk("%s ERROR: returning %d\n", __func__, ret);
+	return NULL;
+}
+
+static u64
+end_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	end = start + len;
+	return end >= start ? end : NFS4_MAX_UINT64;
+}
+
+static void extend_ds_error(struct nfs4_ff_layout_ds_err *err,
+			    u64 offset, u64 length)
+{
+	u64 end;
+
+	end = max_t(u64, end_offset(err->offset, err->length),
+		    end_offset(offset, length));
+	err->offset = min_t(u64, err->offset, offset);
+	err->length = end - err->offset;
+}
+
+static bool ds_error_can_merge(struct nfs4_ff_layout_ds_err *err,  u64 offset,
+			       u64 length, int status, enum nfs_opnum4 opnum,
+			       nfs4_stateid *stateid,
+			       struct nfs4_deviceid *deviceid)
+{
+	return err->status == status && err->opnum == opnum &&
+	       nfs4_stateid_match(&err->stateid, stateid) &&
+	       !memcmp(&err->deviceid, deviceid, sizeof(*deviceid)) &&
+	       end_offset(err->offset, err->length) >= offset &&
+	       err->offset <= end_offset(offset, length);
+}
+
+static bool merge_ds_error(struct nfs4_ff_layout_ds_err *old,
+			   struct nfs4_ff_layout_ds_err *new)
+{
+	if (!ds_error_can_merge(old, new->offset, new->length, new->status,
+				new->opnum, &new->stateid, &new->deviceid))
+		return false;
+
+	extend_ds_error(old, new->offset, new->length);
+	return true;
+}
+
+static bool
+ff_layout_add_ds_error_locked(struct nfs4_flexfile_layout *flo,
+			      struct nfs4_ff_layout_ds_err *dserr)
+{
+	struct nfs4_ff_layout_ds_err *err;
+
+	list_for_each_entry(err, &flo->error_list, list) {
+		if (merge_ds_error(err, dserr)) {
+			return true;
+		}
+	}
+
+	list_add(&dserr->list, &flo->error_list);
+	return false;
+}
+
+static bool
+ff_layout_update_ds_error(struct nfs4_flexfile_layout *flo, u64 offset,
+			  u64 length, int status, enum nfs_opnum4 opnum,
+			  nfs4_stateid *stateid, struct nfs4_deviceid *deviceid)
+{
+	bool found = false;
+	struct nfs4_ff_layout_ds_err *err;
+
+	list_for_each_entry(err, &flo->error_list, list) {
+		if (ds_error_can_merge(err, offset, length, status, opnum,
+				       stateid, deviceid)) {
+			found = true;
+			extend_ds_error(err, offset, length);
+			break;
+		}
+	}
+
+	return found;
+}
+
+int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
+			     struct nfs4_ff_layout_mirror *mirror, u64 offset,
+			     u64 length, int status, enum nfs_opnum4 opnum,
+			     gfp_t gfp_flags)
+{
+	struct nfs4_ff_layout_ds_err *dserr;
+	bool needfree;
+
+	if (status == 0)
+		return 0;
+
+	if (mirror->mirror_ds == NULL)
+		return -EINVAL;
+
+	spin_lock(&flo->generic_hdr.plh_inode->i_lock);
+	if (ff_layout_update_ds_error(flo, offset, length, status, opnum,
+				      &mirror->stateid,
+				      &mirror->mirror_ds->id_node.deviceid)) {
+		spin_unlock(&flo->generic_hdr.plh_inode->i_lock);
+		return 0;
+	}
+	spin_unlock(&flo->generic_hdr.plh_inode->i_lock);
+	dserr = kmalloc(sizeof(*dserr), gfp_flags);
+	if (!dserr)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&dserr->list);
+	dserr->offset = offset;
+	dserr->length = length;
+	dserr->status = status;
+	dserr->opnum = opnum;
+	nfs4_stateid_copy(&dserr->stateid, &mirror->stateid);
+	memcpy(&dserr->deviceid, &mirror->mirror_ds->id_node.deviceid,
+	       NFS4_DEVICEID4_SIZE);
+
+	spin_lock(&flo->generic_hdr.plh_inode->i_lock);
+	needfree = ff_layout_add_ds_error_locked(flo, dserr);
+	spin_unlock(&flo->generic_hdr.plh_inode->i_lock);
+	if (needfree)
+		kfree(dserr);
+
+	return 0;
+}
+
+/* currently we only support AUTH_NONE and AUTH_SYS */
+static rpc_authflavor_t
+nfs4_ff_layout_choose_authflavor(struct nfs4_ff_layout_mirror *mirror)
+{
+	if (mirror->uid == (u32)-1)
+		return RPC_AUTH_NULL;
+	return RPC_AUTH_UNIX;
+}
+
+/* fetch cred for NFSv3 DS */
+static int ff_layout_update_mirror_cred(struct nfs4_ff_layout_mirror *mirror,
+				      struct nfs4_pnfs_ds *ds)
+{
+	if (ds && !mirror->cred && mirror->mirror_ds->ds_versions[0].version == 3) {
+		struct rpc_auth *auth = ds->ds_clp->cl_rpcclient->cl_auth;
+		struct rpc_cred *cred;
+		struct auth_cred acred = {
+			.uid = make_kuid(&init_user_ns, mirror->uid),
+			.gid = make_kgid(&init_user_ns, mirror->gid),
+		};
+
+		/* AUTH_NULL ignores acred */
+		cred = auth->au_ops->lookup_cred(auth, &acred, 0);
+		if (IS_ERR(cred)) {
+			dprintk("%s: lookup_cred failed with %ld\n",
+				__func__, PTR_ERR(cred));
+			return PTR_ERR(cred);
+		} else {
+			mirror->cred = cred;
+		}
+	}
+	return 0;
+}
+
+struct nfs_fh *
+nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx)
+{
+	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, mirror_idx);
+	struct nfs_fh *fh = NULL;
+	struct nfs4_deviceid_node *devid;
+
+	if (mirror == NULL || mirror->mirror_ds == NULL ||
+	    mirror->mirror_ds->ds == NULL) {
+		printk(KERN_ERR "NFS: %s: No data server for mirror offset index %d\n",
+			__func__, mirror_idx);
+		if (mirror && mirror->mirror_ds) {
+			devid = &mirror->mirror_ds->id_node;
+			pnfs_generic_mark_devid_invalid(devid);
+		}
+		goto out;
+	}
+
+	/* FIXME: For now assume there is only 1 version available for the DS */
+	fh = &mirror->fh_versions[0];
+out:
+	return fh;
+}
+
+/* Upon return, either ds is connected, or ds is NULL */
+struct nfs4_pnfs_ds *
+nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
+			  bool fail_return)
+{
+	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
+	struct nfs4_pnfs_ds *ds = NULL;
+	struct nfs4_deviceid_node *devid;
+	struct inode *ino = lseg->pls_layout->plh_inode;
+	struct nfs_server *s = NFS_SERVER(ino);
+	unsigned int max_payload;
+	rpc_authflavor_t flavor;
+
+	if (mirror == NULL || mirror->mirror_ds == NULL ||
+	    mirror->mirror_ds->ds == NULL) {
+		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
+			__func__, ds_idx);
+		if (mirror && mirror->mirror_ds) {
+			devid = &mirror->mirror_ds->id_node;
+			pnfs_generic_mark_devid_invalid(devid);
+		}
+		goto out;
+	}
+
+	ds = mirror->mirror_ds->ds;
+	devid = &mirror->mirror_ds->id_node;
+
+	/* matching smp_wmb() in _nfs4_pnfs_v3/4_ds_connect */
+	smp_rmb();
+	if (ds->ds_clp)
+		goto out_test_devid;
+
+	flavor = nfs4_ff_layout_choose_authflavor(mirror);
+
+	/* FIXME: For now we assume the server sent only one version of NFS
+	 * to use for the DS.
+	 */
+	nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
+			     dataserver_retrans,
+			     mirror->mirror_ds->ds_versions[0].version,
+			     mirror->mirror_ds->ds_versions[0].minor_version,
+			     flavor);
+
+	/* connect success, check rsize/wsize limit */
+	if (ds->ds_clp) {
+		max_payload =
+			nfs_block_size(rpc_max_payload(ds->ds_clp->cl_rpcclient),
+				       NULL);
+		if (mirror->mirror_ds->ds_versions[0].rsize > max_payload)
+			mirror->mirror_ds->ds_versions[0].rsize = max_payload;
+		if (mirror->mirror_ds->ds_versions[0].wsize > max_payload)
+			mirror->mirror_ds->ds_versions[0].wsize = max_payload;
+	} else {
+		ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
+					 mirror, lseg->pls_range.offset,
+					 lseg->pls_range.length, NFS4ERR_NXIO,
+					 OP_ILLEGAL, GFP_NOIO);
+		if (fail_return) {
+			pnfs_error_mark_layout_for_return(ino, lseg);
+			if (ff_layout_has_available_ds(lseg))
+				pnfs_set_retry_layoutget(lseg->pls_layout);
+			else
+				pnfs_clear_retry_layoutget(lseg->pls_layout);
+
+		} else {
+			if (ff_layout_has_available_ds(lseg))
+				set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
+					&lseg->pls_layout->plh_flags);
+			else {
+				pnfs_error_mark_layout_for_return(ino, lseg);
+				pnfs_clear_retry_layoutget(lseg->pls_layout);
+			}
+		}
+	}
+
+out_test_devid:
+	if (ff_layout_test_devid_unavailable(devid))
+		ds = NULL;
+out:
+	if (ff_layout_update_mirror_cred(mirror, ds))
+		ds = NULL;
+	return ds;
+}
+
+struct rpc_cred *
+ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
+		      struct rpc_cred *mdscred)
+{
+	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
+	struct rpc_cred *cred = ERR_PTR(-EINVAL);
+
+	if (!nfs4_ff_layout_prepare_ds(lseg, ds_idx, true))
+		goto out;
+
+	if (mirror && mirror->cred)
+		cred = mirror->cred;
+	else
+		cred = mdscred;
+out:
+	return cred;
+}
+
+/**
+* Find or create a DS rpc client with th MDS server rpc client auth flavor
+* in the nfs_client cl_ds_clients list.
+*/
+struct rpc_clnt *
+nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg, u32 ds_idx,
+				 struct nfs_client *ds_clp, struct inode *inode)
+{
+	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
+
+	switch (mirror->mirror_ds->ds_versions[0].version) {
+	case 3:
+		/* For NFSv3 DS, flavor is set when creating DS connections */
+		return ds_clp->cl_rpcclient;
+	case 4:
+		return nfs4_find_or_create_ds_client(ds_clp, inode);
+	default:
+		BUG();
+	}
+}
+
+static bool is_range_intersecting(u64 offset1, u64 length1,
+				  u64 offset2, u64 length2)
+{
+	u64 end1 = end_offset(offset1, length1);
+	u64 end2 = end_offset(offset2, length2);
+
+	return (end1 == NFS4_MAX_UINT64 || end1 > offset2) &&
+	       (end2 == NFS4_MAX_UINT64 || end2 > offset1);
+}
+
+/* called with inode i_lock held */
+int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
+			      struct xdr_stream *xdr, int *count,
+			      const struct pnfs_layout_range *range)
+{
+	struct nfs4_ff_layout_ds_err *err, *n;
+	__be32 *p;
+
+	list_for_each_entry_safe(err, n, &flo->error_list, list) {
+		if (!is_range_intersecting(err->offset, err->length,
+					   range->offset, range->length))
+			continue;
+		/* offset(8) + length(8) + stateid(NFS4_STATEID_SIZE)
+		 * + deviceid(NFS4_DEVICEID4_SIZE) + status(4) + opnum(4)
+		 */
+		p = xdr_reserve_space(xdr,
+				24 + NFS4_STATEID_SIZE + NFS4_DEVICEID4_SIZE);
+		if (unlikely(!p))
+			return -ENOBUFS;
+		p = xdr_encode_hyper(p, err->offset);
+		p = xdr_encode_hyper(p, err->length);
+		p = xdr_encode_opaque_fixed(p, &err->stateid,
+					    NFS4_STATEID_SIZE);
+		p = xdr_encode_opaque_fixed(p, &err->deviceid,
+					    NFS4_DEVICEID4_SIZE);
+		*p++ = cpu_to_be32(err->status);
+		*p++ = cpu_to_be32(err->opnum);
+		*count += 1;
+		list_del(&err->list);
+		kfree(err);
+		dprintk("%s: offset %llu length %llu status %d op %d count %d\n",
+			__func__, err->offset, err->length, err->status,
+			err->opnum, *count);
+	}
+
+	return 0;
+}
+
+bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg)
+{
+	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_deviceid_node *devid;
+	int idx;
+
+	for (idx = 0; idx < FF_LAYOUT_MIRROR_COUNT(lseg); idx++) {
+		mirror = FF_LAYOUT_COMP(lseg, idx);
+		if (mirror && mirror->mirror_ds) {
+			devid = &mirror->mirror_ds->id_node;
+			if (!ff_layout_test_devid_unavailable(devid))
+				return true;
+		}
+	}
+
+	return false;
+}
+
+module_param(dataserver_retrans, uint, 0644);
+MODULE_PARM_DESC(dataserver_retrans, "The  number of times the NFSv4.1 client "
+			"retries a request before it attempts further "
+			" recovery  action.");
+module_param(dataserver_timeo, uint, 0644);
+MODULE_PARM_DESC(dataserver_timeo, "The time (in tenths of a second) the "
+			"NFSv4.1  client  waits for a response from a "
+			" data server before it retries an NFS request.");
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 297c8f6..5f6d409 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7787,9 +7787,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 	spin_lock(&lo->plh_inode->i_lock);
 	if (lrp->res.lrs_present)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-	clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
-	smp_mb__after_atomic();
-	wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
+	pnfs_clear_layoutreturn_waitbit(lo);
 	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
 	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 	lo->plh_block_lgets--;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c4c9fe6..0fb0f19 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -910,7 +910,9 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 			pnfs_layout_io_set_failed(lo, range->iomode);
 		}
 		return NULL;
-	}
+	} else
+		pnfs_layout_clear_fail_bit(lo,
+				pnfs_iomode_to_fail_bit(range->iomode));
 
 	return lseg;
 }
@@ -930,6 +932,13 @@ static void pnfs_clear_layoutcommit(struct inode *inode,
 	}
 }
 
+void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
+{
+	clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
+	smp_mb__after_atomic();
+	wake_up_bit(&lo->plh_flags, NFS_LAYOUT_RETURN);
+}
+
 static int
 pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 		       enum pnfs_iomode iomode, bool sync)
@@ -943,6 +952,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 		status = -ENOMEM;
 		spin_lock(&ino->i_lock);
 		lo->plh_block_lgets--;
+		pnfs_clear_layoutreturn_waitbit(lo);
 		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
 		spin_unlock(&ino->i_lock);
 		pnfs_put_layout_hdr(lo);
@@ -1418,6 +1428,15 @@ static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
 				   TASK_UNINTERRUPTIBLE);
 }
 
+static void pnfs_clear_first_layoutget(struct pnfs_layout_hdr *lo)
+{
+	unsigned long *bitlock = &lo->plh_flags;
+
+	clear_bit_unlock(NFS_LAYOUT_FIRST_LAYOUTGET, bitlock);
+	smp_mb__after_atomic();
+	wake_up_bit(bitlock, NFS_LAYOUT_FIRST_LAYOUTGET);
+}
+
 /*
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
@@ -1499,6 +1518,8 @@ lookup_again:
 		spin_unlock(&ino->i_lock);
 		dprintk("%s wait for layoutreturn\n", __func__);
 		if (pnfs_prepare_to_retry_layoutget(lo)) {
+			if (first)
+				pnfs_clear_first_layoutget(lo);
 			pnfs_put_layout_hdr(lo);
 			dprintk("%s retrying\n", __func__);
 			goto lookup_again;
@@ -1533,13 +1554,8 @@ lookup_again:
 	pnfs_clear_retry_layoutget(lo);
 	atomic_dec(&lo->plh_outstanding);
 out_put_layout_hdr:
-	if (first) {
-		unsigned long *bitlock = &lo->plh_flags;
-
-		clear_bit_unlock(NFS_LAYOUT_FIRST_LAYOUTGET, bitlock);
-		smp_mb__after_atomic();
-		wake_up_bit(bitlock, NFS_LAYOUT_FIRST_LAYOUTGET);
-	}
+	if (first)
+		pnfs_clear_first_layoutget(lo);
 	pnfs_put_layout_hdr(lo);
 out:
 	dprintk("%s: inode %s/%llu pNFS layout segment %s for "
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5643a07..d52796e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -278,6 +278,7 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       u64 count,
 					       enum pnfs_iomode iomode,
 					       gfp_t gfp_flags);
+void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo);
 
 void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
 int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 022b761..de7c91c 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -516,6 +516,7 @@ enum pnfs_layouttype {
 	LAYOUT_NFSV4_1_FILES  = 1,
 	LAYOUT_OSD2_OBJECTS = 2,
 	LAYOUT_BLOCK_VOLUME = 3,
+	LAYOUT_FLEX_FILES = 4,
 };
 
 /* used for both layout return and recall */
-- 
1.9.3

