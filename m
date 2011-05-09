Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38053 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab1EIRLE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:11:04 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 24/29] pnfs-obj: objlayout_encode_layoutreturn Implementation.
Date: Mon,  9 May 2011 20:10:56 +0300
Message-Id: <1304961056-4682-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
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

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[use new alloc/free_layout API]
[apply types rename]
[convert to new pnfs-submit changes]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c                    |   11 ++-
 fs/nfs/objlayout/objio_osd.c        |    2 +
 fs/nfs/objlayout/objlayout.c        |  229 ++++++++++++++++++++++++++++++++++-
 fs/nfs/objlayout/objlayout.h        |   19 +++
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |   54 ++++++++
 5 files changed, 313 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 75ad9e1..368c2a2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -340,7 +340,16 @@ static int nfs4_stat_to_errno(int);
 #define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
 #define encode_layoutreturn_maxsz (8 + op_encode_hdr_maxsz + \
 				encode_stateid_maxsz + \
-				1 /* FIXME: opaque lrf_body always empty at the moment */)
+				1 /* lrf_body size */ + \
+				1 /* olr_ioerr_report count */ + \
+				/* minimum space for one pnfs-obj err */ + \
+				XDR_QUADLEN(NFS4_DEVICEID4_SIZE) + \
+				2 /* partition_id */ + \
+				2 /* object_id */ + \
+				2 /* offset */ + \
+				2 /* length */ + \
+				1 /* iswrite */ + \
+				1 /* errno */ )
 #define decode_layoutreturn_maxsz (op_decode_hdr_maxsz + \
 				1 + decode_stateid_maxsz)
 #else /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index c47c953..023f2b2 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -729,6 +729,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 
 	.read_pagelist           = objlayout_read_pagelist,
 	.write_pagelist          = objlayout_write_pagelist,
+
+	.encode_layoutreturn     = objlayout_encode_layoutreturn,
 };
 
 void *objio_init_mt(void)
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 04fcadd..c47e03d 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -37,6 +37,7 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <scsi/osd_initiator.h>
 #include "objlayout.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
@@ -52,6 +53,10 @@ objlayout_alloc_layout_hdr(struct inode *inode)
 	struct objlayout *objlay;
 
 	objlay = kzalloc(sizeof(struct objlayout), GFP_KERNEL);
+	if (objlay) {
+		spin_lock_init(&objlay->lock);
+		INIT_LIST_HEAD(&objlay->err_list);
+	}
 	dprintk("%s: Return %p\n", __func__, objlay);
 	return &objlay->pnfs_layout;
 }
@@ -66,6 +71,7 @@ objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
 
 	dprintk("%s: objlay %p\n", __func__, objlay);
 
+	WARN_ON(!list_empty(&objlay->err_list));
 	kfree(objlay);
 }
 
@@ -300,6 +306,7 @@ objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 		pgbase &= ~PAGE_MASK;
 	}
 
+	INIT_LIST_HEAD(&state->err_list);
 	state->objlseg = objlseg;
 	state->rpcdata = rpcdata;
 	state->pages = pages;
@@ -330,7 +337,54 @@ objlayout_iodone(struct objlayout_io_state *state)
 {
 	dprintk("%s: state %p status\n", __func__, state);
 
-	objlayout_free_io_state(state);
+	if (likely(state->status >= 0)) {
+		objlayout_free_io_state(state);
+	} else {
+		struct objlayout *objlay = OBJLAYOUT(state->objlseg->lseg.pls_layout);
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
+			int osd_error, u64 offset, u64 length, bool is_write)
+{
+	struct pnfs_osd_ioerr *ioerr = &state->ioerrs[index];
+
+	BUG_ON(index >= state->num_comps);
+	if (osd_error) {
+		struct pnfs_osd_layout *layout =
+			(typeof(layout))state->objlseg->pnfs_osd_layout;
+
+		ioerr->oer_component = layout->olo_comps[index].oc_object_id;
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
@@ -496,3 +550,176 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	wdata->pnfs_error = status;
 	return PNFS_ATTEMPTED;
 }
+
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
+encode_accumulated_error(struct objlayout *objlay, struct xdr_stream *xdr)
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
+	BUG_ON(pnfs_osd_xdr_encode_ioerr(xdr, &accumulated_err));
+}
+
+void
+objlayout_encode_layoutreturn(struct pnfs_layout_hdr *pnfslay,
+			      struct xdr_stream *xdr,
+			      const struct nfs4_layoutreturn_args *args)
+{
+	struct objlayout *objlay = OBJLAYOUT(pnfslay);
+	struct objlayout_io_state *state, *tmp;
+	__be32 *start, *uninitialized_var(last_xdr);
+
+	dprintk("%s: Begin\n", __func__);
+	start = xdr_reserve_space(xdr, 4);
+	BUG_ON(!start);
+
+	spin_lock(&objlay->lock);
+
+	list_for_each_entry_safe(state, tmp, &objlay->err_list, err_list) {
+		unsigned i;
+		int res = 0;
+
+		for (i = 0; i < state->num_comps && !res; i++) {
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
+			last_xdr = xdr->p;
+			res = pnfs_osd_xdr_encode_ioerr(xdr, &state->ioerrs[i]);
+		}
+
+		/* TODO: use xdr_write_pages */
+		if (unlikely(res)) {
+			/* no space for even one error descriptor */
+			BUG_ON(last_xdr == start + 1);
+
+			/* we've encountered a situation with lots and lots of
+			 * errors and no space to encode them all. Use the last
+			 * available slot to report the union of all the
+			 * remaining errors.
+			 */
+			xdr_rewind_stream(xdr, last_xdr -
+					       pnfs_osd_ioerr_xdr_sz() / 4);
+			encode_accumulated_error(objlay, xdr);
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
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 54dbd55..31fd34b 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -59,6 +59,10 @@ struct objlayout_segment {
  */
 struct objlayout {
 	struct pnfs_layout_hdr pnfs_layout;
+
+	 /* for layout_return */
+	spinlock_t lock;
+	struct list_head err_list;
 };
 
 static inline struct objlayout *
@@ -85,6 +89,16 @@ struct objlayout_io_state {
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
@@ -144,4 +158,9 @@ extern enum pnfs_try_status objlayout_write_pagelist(
 	struct nfs_write_data *,
 	int how);
 
+extern void objlayout_encode_layoutreturn(
+	struct pnfs_layout_hdr *,
+	struct xdr_stream *,
+	const struct nfs4_layoutreturn_args *);
+
 #endif /* _OBJLAYOUT_H */
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index cc2de07..232b32c49 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -351,3 +351,57 @@ void pnfs_osd_xdr_decode_deviceaddr(
 
 	__xdr_read_calc_deviceaddr(p, deviceaddr, &freespace);
 }
+
+/*
+ * struct pnfs_osd_objid {
+ * 	struct pnfs_deviceid	oid_device_id;
+ * 	u64			oid_partition_id;
+ * 	u64			oid_object_id;
+ */
+static inline int pnfs_osd_xdr_encode_objid(struct xdr_stream *xdr,
+					    struct pnfs_osd_objid *object_id)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 32);
+	if (!p)
+		return -E2BIG;
+
+	p = xdr_encode_opaque_fixed(p, &object_id->oid_device_id.data,
+				    sizeof(object_id->oid_device_id.data));
+	p = xdr_encode_hyper(p, object_id->oid_partition_id);
+	p = xdr_encode_hyper(p, object_id->oid_object_id);
+
+	return 0;
+}
+
+/*
+ * struct pnfs_osd_ioerr {
+ * 	struct pnfs_osd_objid	oer_component;
+ * 	u64			oer_comp_offset;
+ * 	u64			oer_comp_length;
+ * 	u32			oer_iswrite;
+ * 	u32			oer_errno;
+ * };
+ */
+int pnfs_osd_xdr_encode_ioerr(struct xdr_stream *xdr,
+			      struct pnfs_osd_ioerr *ioerr)
+{
+	__be32 *p;
+	int ret;
+
+	ret = pnfs_osd_xdr_encode_objid(xdr, &ioerr->oer_component);
+	if (ret)
+		return ret;
+
+	p = xdr_reserve_space(xdr, 24);
+	if (!p)
+		return -E2BIG;
+
+	p = xdr_encode_hyper(p, ioerr->oer_comp_offset);
+	p = xdr_encode_hyper(p, ioerr->oer_comp_length);
+	*p++ = cpu_to_be32(ioerr->oer_iswrite);
+	*p   = cpu_to_be32(ioerr->oer_errno);
+
+	return 0;
+}
-- 
1.7.3.4

