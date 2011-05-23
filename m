Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9186 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756546Ab1EWQjW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 12:39:22 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH v6 24/26] pnfs-obj: report errors and .encode_layoutreturn Implementation.
Date: Mon, 23 May 2011 19:39:09 +0300
Message-Id: <1306168749-11831-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDA8C3D.5080706@panasas.com>
References: <4DDA8C3D.5080706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Boaz Harrosh <bharrosh@panasas.com>

An io_state pre-allocates an error information structure for each
possible osd-device that might error during IO. When IO is done if all
was well the io_state is freed. (as today). If the I/O has ended with an
error, the io_state is queued on a per-layout err_list. When eventually
encode_layoutreturn() is called, each error is properly encoded on the
XDR buffer and only then the io_state is removed from err_list and
de-allocated.

It is up to the io_engine to fill in the segment that fault and the type
of osd_error that occurred. By calling objlayout_io_set_result() for
each failing device.

In objio_osd:
* Allocate io-error descriptors space as part of io_state
* Use generic objlayout error reporting at end of io.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   44 ++++++++-
 fs/nfs/objlayout/objlayout.c |  232 +++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/objlayout/objlayout.h |   23 ++++
 3 files changed, 297 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 95fb687..19b7a2c 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -384,13 +384,17 @@ int objio_alloc_io_state(struct pnfs_layout_segment *lseg,
 	struct objio_state *ios;
 	const unsigned first_size = sizeof(*ios) +
 				objio_seg->num_comps * sizeof(ios->per_dev[0]);
+	const unsigned sec_size = objio_seg->num_comps *
+						sizeof(ios->ol_state.ioerrs[0]);
 
 	dprintk("%s: num_comps=%d\n", __func__, objio_seg->num_comps);
-	ios = kzalloc(first_size, gfp_flags);
+	ios = kzalloc(first_size + sec_size, gfp_flags);
 	if (unlikely(!ios))
 		return -ENOMEM;
 
 	ios->layout = objio_seg;
+	ios->ol_state.ioerrs = ((void *)ios) + first_size;
+	ios->ol_state.num_comps = objio_seg->num_comps;
 
 	*outp = &ios->ol_state;
 	return 0;
@@ -404,6 +408,36 @@ void objio_free_io_state(struct objlayout_io_state *ol_state)
 	kfree(ios);
 }
 
+enum pnfs_osd_errno osd_pri_2_pnfs_err(enum osd_err_priority oep)
+{
+	switch (oep) {
+	case OSD_ERR_PRI_NO_ERROR:
+		return (enum pnfs_osd_errno)0;
+
+	case OSD_ERR_PRI_CLEAR_PAGES:
+		BUG_ON(1);
+		return 0;
+
+	case OSD_ERR_PRI_RESOURCE:
+		return PNFS_OSD_ERR_RESOURCE;
+	case OSD_ERR_PRI_BAD_CRED:
+		return PNFS_OSD_ERR_BAD_CRED;
+	case OSD_ERR_PRI_NO_ACCESS:
+		return PNFS_OSD_ERR_NO_ACCESS;
+	case OSD_ERR_PRI_UNREACHABLE:
+		return PNFS_OSD_ERR_UNREACHABLE;
+	case OSD_ERR_PRI_NOT_FOUND:
+		return PNFS_OSD_ERR_NOT_FOUND;
+	case OSD_ERR_PRI_NO_SPACE:
+		return PNFS_OSD_ERR_NO_SPACE;
+	default:
+		WARN_ON(1);
+		/* fallthrough */
+	case OSD_ERR_PRI_EIO:
+		return PNFS_OSD_ERR_EIO;
+	}
+}
+
 static void _clear_bio(struct bio *bio)
 {
 	struct bio_vec *bv;
@@ -450,6 +484,12 @@ static int _io_check(struct objio_state *ios, bool is_write)
 			continue; /* we recovered */
 		}
 		dev = ios->per_dev[i].dev;
+		objlayout_io_set_result(&ios->ol_state, dev,
+					&ios->layout->comps[dev].oc_object_id,
+					osd_pri_2_pnfs_err(osi.osd_err_pri),
+					ios->per_dev[i].offset,
+					ios->per_dev[i].length,
+					is_write);
 
 		if (osi.osd_err_pri >= oep) {
 			oep = osi.osd_err_pri;
@@ -963,6 +1003,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.pg_test                 = objlayout_pg_test,
 
 	.free_deviceid_node	 = objio_free_deviceid_node,
+
+	.encode_layoutreturn     = objlayout_encode_layoutreturn,
 };
 
 MODULE_DESCRIPTION("pNFS Layout Driver for OSD2 objects");
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 5157ef6..f7caecf 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -50,6 +50,10 @@ objlayout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 	struct objlayout *objlay;
 
 	objlay = kzalloc(sizeof(struct objlayout), gfp_flags);
+	if (objlay) {
+		spin_lock_init(&objlay->lock);
+		INIT_LIST_HEAD(&objlay->err_list);
+	}
 	dprintk("%s: Return %p\n", __func__, objlay);
 	return &objlay->pnfs_layout;
 }
@@ -64,6 +68,7 @@ objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
 
 	dprintk("%s: objlay %p\n", __func__, objlay);
 
+	WARN_ON(!list_empty(&objlay->err_list));
 	kfree(objlay);
 }
 
@@ -183,6 +188,7 @@ objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 		pgbase &= ~PAGE_MASK;
 	}
 
+	INIT_LIST_HEAD(&state->err_list);
 	state->lseg = lseg;
 	state->rpcdata = rpcdata;
 	state->pages = pages;
@@ -213,7 +219,52 @@ objlayout_iodone(struct objlayout_io_state *state)
 {
 	dprintk("%s: state %p status\n", __func__, state);
 
-	objlayout_free_io_state(state);
+	if (likely(state->status >= 0)) {
+		objlayout_free_io_state(state);
+	} else {
+		struct objlayout *objlay = OBJLAYOUT(state->lseg->pls_layout);
+
+		spin_lock(&objlay->lock);
+		list_add(&objlay->err_list, &state->err_list);
+		spin_unlock(&objlay->lock);
+	}
+}
+
+/*
+ * objlayout_io_set_result - Set an osd_error code on a specific osd comp.
+ *
+ * The @index component IO failed (error returned from target). Register
+ * the error for later reporting at layout-return.
+ */
+void
+objlayout_io_set_result(struct objlayout_io_state *state, unsigned index,
+			struct pnfs_osd_objid *pooid, int osd_error,
+			u64 offset, u64 length, bool is_write)
+{
+	struct pnfs_osd_ioerr *ioerr = &state->ioerrs[index];
+
+	BUG_ON(index >= state->num_comps);
+	if (osd_error) {
+		ioerr->oer_component = *pooid;
+		ioerr->oer_comp_offset = offset;
+		ioerr->oer_comp_length = length;
+		ioerr->oer_iswrite = is_write;
+		ioerr->oer_errno = osd_error;
+
+		dprintk("%s: err[%d]: errno=%d is_write=%d dev(%llx:%llx) "
+			"par=0x%llx obj=0x%llx offset=0x%llx length=0x%llx\n",
+			__func__, index, ioerr->oer_errno,
+			ioerr->oer_iswrite,
+			_DEVID_LO(&ioerr->oer_component.oid_device_id),
+			_DEVID_HI(&ioerr->oer_component.oid_device_id),
+			ioerr->oer_component.oid_partition_id,
+			ioerr->oer_component.oid_object_id,
+			ioerr->oer_comp_offset,
+			ioerr->oer_comp_length);
+	} else {
+		/* User need not call if no error is reported */
+		ioerr->oer_errno = 0;
+	}
 }
 
 /* Function scheduled on rpc workqueue to call ->nfs_readlist_complete().
@@ -382,6 +433,185 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	return PNFS_ATTEMPTED;
 }
 
+static int
+err_prio(u32 oer_errno)
+{
+	switch (oer_errno) {
+	case 0:
+		return 0;
+
+	case PNFS_OSD_ERR_RESOURCE:
+		return OSD_ERR_PRI_RESOURCE;
+	case PNFS_OSD_ERR_BAD_CRED:
+		return OSD_ERR_PRI_BAD_CRED;
+	case PNFS_OSD_ERR_NO_ACCESS:
+		return OSD_ERR_PRI_NO_ACCESS;
+	case PNFS_OSD_ERR_UNREACHABLE:
+		return OSD_ERR_PRI_UNREACHABLE;
+	case PNFS_OSD_ERR_NOT_FOUND:
+		return OSD_ERR_PRI_NOT_FOUND;
+	case PNFS_OSD_ERR_NO_SPACE:
+		return OSD_ERR_PRI_NO_SPACE;
+	default:
+		WARN_ON(1);
+		/* fallthrough */
+	case PNFS_OSD_ERR_EIO:
+		return OSD_ERR_PRI_EIO;
+	}
+}
+
+static void
+merge_ioerr(struct pnfs_osd_ioerr *dest_err,
+	    const struct pnfs_osd_ioerr *src_err)
+{
+	u64 dest_end, src_end;
+
+	if (!dest_err->oer_errno) {
+		*dest_err = *src_err;
+		/* accumulated device must be blank */
+		memset(&dest_err->oer_component.oid_device_id, 0,
+			sizeof(dest_err->oer_component.oid_device_id));
+
+		return;
+	}
+
+	if (dest_err->oer_component.oid_partition_id !=
+				src_err->oer_component.oid_partition_id)
+		dest_err->oer_component.oid_partition_id = 0;
+
+	if (dest_err->oer_component.oid_object_id !=
+				src_err->oer_component.oid_object_id)
+		dest_err->oer_component.oid_object_id = 0;
+
+	if (dest_err->oer_comp_offset > src_err->oer_comp_offset)
+		dest_err->oer_comp_offset = src_err->oer_comp_offset;
+
+	dest_end = end_offset(dest_err->oer_comp_offset,
+			      dest_err->oer_comp_length);
+	src_end =  end_offset(src_err->oer_comp_offset,
+			      src_err->oer_comp_length);
+	if (dest_end < src_end)
+		dest_end = src_end;
+
+	dest_err->oer_comp_length = dest_end - dest_err->oer_comp_offset;
+
+	if ((src_err->oer_iswrite == dest_err->oer_iswrite) &&
+	    (err_prio(src_err->oer_errno) > err_prio(dest_err->oer_errno))) {
+			dest_err->oer_errno = src_err->oer_errno;
+	} else if (src_err->oer_iswrite) {
+		dest_err->oer_iswrite = true;
+		dest_err->oer_errno = src_err->oer_errno;
+	}
+}
+
+static void
+encode_accumulated_error(struct objlayout *objlay, __be32 *p)
+{
+	struct objlayout_io_state *state, *tmp;
+	struct pnfs_osd_ioerr accumulated_err = {.oer_errno = 0};
+
+	list_for_each_entry_safe(state, tmp, &objlay->err_list, err_list) {
+		unsigned i;
+
+		for (i = 0; i < state->num_comps; i++) {
+			struct pnfs_osd_ioerr *ioerr = &state->ioerrs[i];
+
+			if (!ioerr->oer_errno)
+				continue;
+
+			printk(KERN_ERR "%s: err[%d]: errno=%d is_write=%d "
+				"dev(%llx:%llx) par=0x%llx obj=0x%llx "
+				"offset=0x%llx length=0x%llx\n",
+				__func__, i, ioerr->oer_errno,
+				ioerr->oer_iswrite,
+				_DEVID_LO(&ioerr->oer_component.oid_device_id),
+				_DEVID_HI(&ioerr->oer_component.oid_device_id),
+				ioerr->oer_component.oid_partition_id,
+				ioerr->oer_component.oid_object_id,
+				ioerr->oer_comp_offset,
+				ioerr->oer_comp_length);
+
+			merge_ioerr(&accumulated_err, ioerr);
+		}
+		list_del(&state->err_list);
+		objlayout_free_io_state(state);
+	}
+
+	pnfs_osd_xdr_encode_ioerr(p, &accumulated_err);
+}
+
+void
+objlayout_encode_layoutreturn(struct pnfs_layout_hdr *pnfslay,
+			      struct xdr_stream *xdr,
+			      const struct nfs4_layoutreturn_args *args)
+{
+	struct objlayout *objlay = OBJLAYOUT(pnfslay);
+	struct objlayout_io_state *state, *tmp;
+	__be32 *start;
+
+	dprintk("%s: Begin\n", __func__);
+	start = xdr_reserve_space(xdr, 4);
+	BUG_ON(!start);
+
+	spin_lock(&objlay->lock);
+
+	list_for_each_entry_safe(state, tmp, &objlay->err_list, err_list) {
+		__be32 *last_xdr = NULL, *p;
+		unsigned i;
+		int res = 0;
+
+		for (i = 0; i < state->num_comps; i++) {
+			struct pnfs_osd_ioerr *ioerr = &state->ioerrs[i];
+
+			if (!ioerr->oer_errno)
+				continue;
+
+			dprintk("%s: err[%d]: errno=%d is_write=%d "
+				"dev(%llx:%llx) par=0x%llx obj=0x%llx "
+				"offset=0x%llx length=0x%llx\n",
+				__func__, i, ioerr->oer_errno,
+				ioerr->oer_iswrite,
+				_DEVID_LO(&ioerr->oer_component.oid_device_id),
+				_DEVID_HI(&ioerr->oer_component.oid_device_id),
+				ioerr->oer_component.oid_partition_id,
+				ioerr->oer_component.oid_object_id,
+				ioerr->oer_comp_offset,
+				ioerr->oer_comp_length);
+
+			p = pnfs_osd_xdr_ioerr_reserve_space(xdr);
+			if (unlikely(!p)) {
+				res = -E2BIG;
+				break; /* accumulated_error */
+			}
+
+			last_xdr = p;
+			pnfs_osd_xdr_encode_ioerr(p, &state->ioerrs[i]);
+		}
+
+		/* TODO: use xdr_write_pages */
+		if (unlikely(res)) {
+			/* no space for even one error descriptor */
+			BUG_ON(!last_xdr);
+
+			/* we've encountered a situation with lots and lots of
+			 * errors and no space to encode them all. Use the last
+			 * available slot to report the union of all the
+			 * remaining errors.
+			 */
+			encode_accumulated_error(objlay, last_xdr);
+			goto loop_done;
+		}
+		list_del(&state->err_list);
+		objlayout_free_io_state(state);
+	}
+loop_done:
+	spin_unlock(&objlay->lock);
+
+	*start = cpu_to_be32((xdr->p - start - 1) * 4);
+	dprintk("%s: Return\n", __func__);
+}
+
+
 /*
  * Get Device Info API for io engines
  */
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 9a405e8..b0bb975 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -50,6 +50,10 @@
  */
 struct objlayout {
 	struct pnfs_layout_hdr pnfs_layout;
+
+	 /* for layout_return */
+	spinlock_t lock;
+	struct list_head err_list;
 };
 
 static inline struct objlayout *
@@ -76,6 +80,16 @@ struct objlayout_io_state {
 	int status;             /* res */
 	int eof;                /* res */
 	int committed;          /* res */
+
+	/* Error reporting (layout_return) */
+	struct list_head err_list;
+	unsigned num_comps;
+	/* Pointer to array of error descriptors of size num_comps.
+	 * It should contain as many entries as devices in the osd_layout
+	 * that participate in the I/O. It is up to the io_engine to allocate
+	 * needed space and set num_comps.
+	 */
+	struct pnfs_osd_ioerr *ioerrs;
 };
 
 /*
@@ -101,6 +115,10 @@ extern ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state,
 /*
  * callback API
  */
+extern void objlayout_io_set_result(struct objlayout_io_state *state,
+			unsigned index, struct pnfs_osd_objid *pooid,
+			int osd_error, u64 offset, u64 length, bool is_write);
+
 extern void objlayout_read_done(struct objlayout_io_state *state,
 				ssize_t status, bool sync);
 extern void objlayout_write_done(struct objlayout_io_state *state,
@@ -131,4 +149,9 @@ extern enum pnfs_try_status objlayout_write_pagelist(
 	struct nfs_write_data *,
 	int how);
 
+extern void objlayout_encode_layoutreturn(
+	struct pnfs_layout_hdr *,
+	struct xdr_stream *,
+	const struct nfs4_layoutreturn_args *);
+
 #endif /* _OBJLAYOUT_H */
-- 
1.7.3.4

