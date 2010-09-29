Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16449 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753408Ab0I2LMo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:12:44 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 17/17] SQUASHME: pnfs-obj: convert to new pnfs-submit changes
Date: Wed, 29 Sep 2010 13:12:41 +0200
Message-Id: <1285758761-27343-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c  |   57 ++++++++++++++++++++----------
 fs/nfs/objlayout/objlayout.c  |   77 ++++++++++++++++-------------------------
 fs/nfs/objlayout/objlayout.h  |   47 ++++++++++++++++++++++---
 fs/nfs/objlayout/panfs_shim.c |   51 ++++++++++++++++++---------
 include/linux/nfs4.h          |    2 +
 include/linux/pnfs_osd_xdr.h  |    4 +-
 6 files changed, 147 insertions(+), 91 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 75d5df4..696b6f5 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -64,7 +64,7 @@ struct objio_mount_type {
 
 struct _dev_ent {
 	struct list_head list;
-	struct pnfs_deviceid d_id;
+	struct nfs4_deviceid d_id;
 	struct osd_dev *od;
 };
 
@@ -85,7 +85,7 @@ static void _dev_list_remove_all(struct objio_mount_type *omt)
 }
 
 static struct osd_dev *___dev_list_find(struct objio_mount_type *omt,
-	struct pnfs_deviceid *d_id)
+	struct nfs4_deviceid *d_id)
 {
 	struct list_head *le;
 
@@ -100,7 +100,7 @@ static struct osd_dev *___dev_list_find(struct objio_mount_type *omt,
 }
 
 static struct osd_dev *_dev_list_find(struct objio_mount_type *omt,
-	struct pnfs_deviceid *d_id)
+	struct nfs4_deviceid *d_id)
 {
 	struct osd_dev *od;
 
@@ -111,7 +111,7 @@ static struct osd_dev *_dev_list_find(struct objio_mount_type *omt,
 }
 
 static int _dev_list_add(struct objio_mount_type *omt,
-	struct pnfs_deviceid *d_id, struct osd_dev *od)
+	struct nfs4_deviceid *d_id, struct osd_dev *od)
 {
 	struct _dev_ent *de = kzalloc(sizeof(*de), GFP_KERNEL);
 
@@ -180,10 +180,10 @@ static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
 {
 	struct pnfs_osd_layout *layout = objio_seg->layout;
 	struct pnfs_osd_deviceaddr *deviceaddr;
-	struct pnfs_deviceid *d_id;
+	struct nfs4_deviceid *d_id;
 	struct osd_dev *od;
 	struct osd_dev_info odi;
-	struct objio_mount_type *omt = PNFS_NFS_SERVER(pnfslay)->pnfs_ld_data;
+	struct objio_mount_type *omt = NFS_SERVER(pnfslay->inode)->pnfs_ld_data;
 	int err;
 
 	d_id = &layout->olo_comps[comp].oc_object_id.oid_device_id;
@@ -981,7 +981,8 @@ objlayout_get_stripesize(struct pnfs_layout_hdr *pnfslay)
 
 	list_for_each_entry(lseg, &pnfslay->segs, fi_list) {
 		int n;
-		struct objlayout_segment *objlseg = LSEG_LD_DATA(lseg);
+		struct objlayout_segment *objlseg =
+			container_of(lseg, struct objlayout_segment, lseg);
 		struct pnfs_osd_layout *lo =
 			(struct pnfs_osd_layout *)objlseg->pnfs_osd_layout;
 		struct pnfs_osd_data_map *map = &lo->olo_map;
@@ -1025,23 +1026,35 @@ objlayout_get_blocksize(void)
 	return sz;
 }
 
-static struct layoutdriver_policy_operations objlayout_policy_operations = {
 /*
  * Don't gather across stripes, but rather gather (coalesce) up to
  * the stripe size.
  *
  * FIXME: change interface to use merge_align, merge_count
  */
-	.flags                 = PNFS_LAYOUTRET_ON_SETATTR,
-	.get_stripesize        = objlayout_get_stripesize,
-	.get_blocksize         = objlayout_get_blocksize,
-};
-
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
-	.ld_io_ops = &objlayout_io_operations,
-	.ld_policy_ops = &objlayout_policy_operations,
+	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
+
+	.initialize_mountpoint   = objlayout_initialize_mountpoint,
+	.uninitialize_mountpoint = objlayout_uninitialize_mountpoint,
+
+	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
+	.free_layout_hdr         = objlayout_free_layout_hdr,
+
+	.alloc_lseg              = objlayout_alloc_lseg,
+	.free_lseg               = objlayout_free_lseg,
+
+	.get_stripesize          = objlayout_get_stripesize,
+	.get_blocksize           = objlayout_get_blocksize,
+
+	.read_pagelist           = objlayout_read_pagelist,
+	.write_pagelist          = objlayout_write_pagelist,
+	.commit                  = objlayout_commit,
+
+	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
+	.encode_layoutreturn     = objlayout_encode_layoutreturn,
 };
 
 void *objio_init_mt(void)
@@ -1069,10 +1082,16 @@ MODULE_LICENSE("GPL");
 static int __init
 objlayout_init(void)
 {
-	pnfs_client_ops = pnfs_register_layoutdriver(&objlayout_type);
-	printk(KERN_INFO "%s: Registered OSD pNFS Layout Driver\n",
-	       __func__);
-	return 0;
+	int ret = pnfs_register_layoutdriver(&objlayout_type);
+
+	if (ret)
+		printk(KERN_INFO
+			"%s: Registering OSD pNFS Layout Driver failed: error=%d\n",
+			__func__, ret);
+	else
+		printk(KERN_INFO "%s: Registered OSD pNFS Layout Driver\n",
+			__func__);
+	return ret;
 }
 
 static void __exit
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 259c616..b647577 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -49,8 +49,8 @@ struct pnfs_client_operations *pnfs_client_ops;
 /*
  * Create a objlayout layout structure for the given inode and return it.
  */
-static struct pnfs_layout_hdr *
-objlayout_alloc_layout(struct inode *inode)
+struct pnfs_layout_hdr *
+objlayout_alloc_layout_hdr(struct inode *inode)
 {
 	struct objlayout *objlay;
 
@@ -66,8 +66,8 @@ objlayout_alloc_layout(struct inode *inode)
 /*
  * Free an objlayout layout structure
  */
-static void
-objlayout_free_layout(struct pnfs_layout_hdr *lo)
+void
+objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	struct objlayout *objlay = OBJLAYOUT(lo);
 
@@ -80,13 +80,12 @@ objlayout_free_layout(struct pnfs_layout_hdr *lo)
 /*
  * Unmarshall layout and store it in pnfslay.
  */
-static struct pnfs_layout_segment *
+struct pnfs_layout_segment *
 objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 		     struct nfs4_layoutget_res *lgr)
 {
 	int status;
 	void *layout = lgr->layout.buf;
-	struct pnfs_layout_segment *lseg;
 	struct objlayout_segment *objlseg;
 	struct pnfs_osd_layout *pnfs_osd_layout;
 
@@ -95,32 +94,31 @@ objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
 	BUG_ON(!layout);
 
 	status = -ENOMEM;
-	lseg = kzalloc(sizeof(*lseg) + sizeof(*objlseg) +
-		       pnfs_osd_layout_incore_sz(layout), GFP_KERNEL);
-	if (!lseg)
+	objlseg = kzalloc(sizeof(*objlseg) +
+			  pnfs_osd_layout_incore_sz(layout), GFP_KERNEL);
+	if (!objlseg)
 		goto err;
 
-	objlseg = LSEG_LD_DATA(lseg);
 	pnfs_osd_layout = (struct pnfs_osd_layout *)objlseg->pnfs_osd_layout;
 	pnfs_osd_xdr_decode_layout(pnfs_osd_layout, layout);
 
-	status = objio_alloc_lseg(&objlseg->internal, pnfslay, lseg,
+	status = objio_alloc_lseg(&objlseg->internal, pnfslay, &objlseg->lseg,
 				  pnfs_osd_layout);
 	if (status)
 		goto err;
 
-	dprintk("%s: Return %p\n", __func__, lseg);
-	return lseg;
+	dprintk("%s: Return %p\n", __func__, &objlseg->lseg);
+	return &objlseg->lseg;
 
  err:
-	kfree(lseg);
+	kfree(objlseg);
 	return ERR_PTR(status);
 }
 
 /*
  * Free a layout segement
  */
-static void
+void
 objlayout_free_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct objlayout_segment *objlseg;
@@ -130,9 +128,9 @@ objlayout_free_lseg(struct pnfs_layout_segment *lseg)
 	if (unlikely(!lseg))
 		return;
 
-	objlseg = LSEG_LD_DATA(lseg);
+	objlseg = container_of(lseg, struct objlayout_segment, lseg);
 	objio_free_lseg(objlseg->internal);
-	kfree(lseg);
+	kfree(objlseg);
 }
 
 /*
@@ -168,7 +166,8 @@ objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 			struct pnfs_layout_segment *lseg,
 			void *rpcdata)
 {
-	struct objlayout_segment *objlseg = LSEG_LD_DATA(lseg);
+	struct objlayout_segment *objlseg =
+		container_of(lseg, struct objlayout_segment, lseg);
 	struct objlayout_io_state *state;
 	u64 lseg_end_offset;
 	size_t size_nr_pages;
@@ -199,7 +198,7 @@ objlayout_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type,
 		nr_pages = size_nr_pages;
 
 	INIT_LIST_HEAD(&state->err_list);
-	state->lseg = lseg;
+	state->objlseg = objlseg;
 	state->rpcdata = rpcdata;
 	state->pages = pages;
 	state->pgbase = pgbase;
@@ -232,7 +231,7 @@ objlayout_iodone(struct objlayout_io_state *state)
 	if (likely(state->status >= 0)) {
 		objlayout_free_io_state(state);
 	} else {
-		struct objlayout *objlay = OBJLAYOUT(state->lseg->layout);
+		struct objlayout *objlay = OBJLAYOUT(state->objlseg->lseg.layout);
 
 		spin_lock(&objlay->lock);
 		objlay->delta_space_valid = OBJ_DSU_INVALID;
@@ -255,9 +254,8 @@ objlayout_io_set_result(struct objlayout_io_state *state, unsigned index,
 
 	BUG_ON(index >= state->num_comps);
 	if (osd_error) {
-		struct objlayout_segment *objlseg = LSEG_LD_DATA(state->lseg);
 		struct pnfs_osd_layout *layout =
-				(typeof(layout))objlseg->pnfs_osd_layout;
+			(typeof(layout))state->objlseg->pnfs_osd_layout;
 
 		ioerr->oer_component = layout->olo_comps[index].oc_object_id;
 		ioerr->oer_comp_offset = offset;
@@ -290,7 +288,7 @@ static void _rpc_commit_complete(struct work_struct *work)
 	task = container_of(work, struct rpc_task, u.tk_work);
 	wdata = container_of(task, struct nfs_write_data, task);
 
-	pnfs_client_ops->nfs_commit_complete(wdata);
+	pnfs_commit_done(wdata);
 }
 
 /*
@@ -320,7 +318,7 @@ static void _rpc_read_complete(struct work_struct *work)
 	task = container_of(work, struct rpc_task, u.tk_work);
 	rdata = container_of(task, struct nfs_read_data, task);
 
-	pnfs_client_ops->nfs_readlist_complete(rdata);
+	pnfs_read_done(rdata);
 }
 
 void
@@ -341,7 +339,7 @@ objlayout_read_done(struct objlayout_io_state *state, ssize_t status, bool sync)
 	/* must not use state after this point */
 
 	if (sync)
-		pnfs_client_ops->nfs_readlist_complete(rdata);
+		pnfs_read_done(rdata);
 	else {
 		INIT_WORK(&rdata->task.u.tk_work, _rpc_read_complete);
 		schedule_work(&rdata->task.u.tk_work);
@@ -405,7 +403,7 @@ static void _rpc_write_complete(struct work_struct *work)
 	task = container_of(work, struct rpc_task, u.tk_work);
 	wdata = container_of(task, struct nfs_write_data, task);
 
-	pnfs_client_ops->nfs_writelist_complete(wdata);
+	pnfs_writeback_done(wdata);
 }
 
 void
@@ -431,7 +429,7 @@ objlayout_write_done(struct objlayout_io_state *state, ssize_t status,
 	/* must not use state after this point */
 
 	if (sync)
-		pnfs_client_ops->nfs_writelist_complete(wdata);
+		pnfs_writeback_done(wdata);
 	else {
 		INIT_WORK(&wdata->task.u.tk_work, _rpc_write_complete);
 		schedule_work(&wdata->task.u.tk_work);
@@ -683,7 +681,7 @@ struct objlayout_deviceinfo {
  * should be called.
  */
 int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
-	struct pnfs_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr)
+	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr)
 {
 	struct objlayout_deviceinfo *odi;
 	struct pnfs_device pd;
@@ -701,14 +699,13 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 
 	memcpy(&pd.dev_id, d_id, sizeof(*d_id));
 	pd.layout_type = LAYOUT_OSD2_OBJECTS;
-	pd.dev_notify_types = 0;
 	pd.pages = &page;
 	pd.pgbase = 0;
 	pd.pglen = PAGE_SIZE;
 	pd.mincount = 0;
 
-	sb = PNFS_INODE(pnfslay)->i_sb;
-	err = pnfs_client_ops->nfs_getdeviceinfo(PNFS_NFS_SERVER(pnfslay), &pd);
+	sb = pnfslay->inode->i_sb;
+	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->inode), &pd);
 	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
 	if (err)
 		goto err_out;
@@ -746,7 +743,7 @@ void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
  * Return the pnfs_mount_type structure so the
  * pNFS_client can refer to the mount point later on.
  */
-static int
+int
 objlayout_initialize_mountpoint(struct nfs_server *server,
 				const struct nfs_fh *mntfh)
 {
@@ -767,24 +764,10 @@ objlayout_initialize_mountpoint(struct nfs_server *server,
 /*
  * Uninitialize a mountpoint
  */
-static int
+int
 objlayout_uninitialize_mountpoint(struct nfs_server *server)
 {
 	dprintk("%s: Begin %p\n", __func__, server->pnfs_ld_data);
 	objio_fini_mt(server->pnfs_ld_data);
 	return 0;
 }
-
-struct layoutdriver_io_operations objlayout_io_operations = {
-	.commit                  = objlayout_commit,
-	.read_pagelist           = objlayout_read_pagelist,
-	.write_pagelist          = objlayout_write_pagelist,
-	.alloc_layout            = objlayout_alloc_layout,
-	.free_layout             = objlayout_free_layout,
-	.alloc_lseg              = objlayout_alloc_lseg,
-	.free_lseg               = objlayout_free_lseg,
-	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
-	.encode_layoutreturn     = objlayout_encode_layoutreturn,
-	.initialize_mountpoint   = objlayout_initialize_mountpoint,
-	.uninitialize_mountpoint = objlayout_uninitialize_mountpoint,
-};
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index adec7ad..cad24a4 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -44,13 +44,14 @@
 #define _OBJLAYOUT_H
 
 #include <linux/nfs_fs.h>
-#include <linux/nfs4_pnfs.h>
 #include <linux/pnfs_osd_xdr.h>
+#include "../pnfs.h"
 
 /*
  * in-core layout segment
  */
 struct objlayout_segment {
+	struct pnfs_layout_segment lseg;
 	void *internal;    /* for provider internal use */
 	u8 pnfs_osd_layout[];
 };
@@ -85,7 +86,7 @@ OBJLAYOUT(struct pnfs_layout_hdr *lo)
  * embedded in objects provider io_state data structure
  */
 struct objlayout_io_state {
-	struct pnfs_layout_segment *lseg;
+	struct objlayout_segment *objlseg;
 
 	struct page **pages;
 	unsigned pgbase;
@@ -139,7 +140,7 @@ extern void objlayout_io_set_result(struct objlayout_io_state *state,
 static inline void
 objlayout_add_delta_space_used(struct objlayout_io_state *state, s64 space_used)
 {
-	struct objlayout *objlay = OBJLAYOUT(state->lseg->layout);
+	struct objlayout *objlay = OBJLAYOUT(state->objlseg->lseg.layout);
 
 	/* If one of the I/Os errored out and the delta_space_used was
 	 * invalid we render the complete report as invalid. Protocol mandate
@@ -159,13 +160,47 @@ extern void objlayout_write_done(struct objlayout_io_state *state,
 				 ssize_t status, bool sync);
 
 extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
-	struct pnfs_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr);
+	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr);
 extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
 
 /*
  * exported generic objects function vectors
  */
-extern struct layoutdriver_io_operations objlayout_io_operations;
-extern struct pnfs_client_operations *pnfs_client_ops;
+
+extern int objlayout_initialize_mountpoint(
+	struct nfs_server *,
+	const struct nfs_fh *);
+extern int objlayout_uninitialize_mountpoint(struct nfs_server *);
+
+extern struct pnfs_layout_hdr *objlayout_alloc_layout_hdr(struct inode *);
+extern void objlayout_free_layout_hdr(struct pnfs_layout_hdr *);
+
+extern struct pnfs_layout_segment *objlayout_alloc_lseg(
+	struct pnfs_layout_hdr *,
+	struct nfs4_layoutget_res *);
+extern void objlayout_free_lseg(struct pnfs_layout_segment *);
+
+extern enum pnfs_try_status objlayout_read_pagelist(
+	struct nfs_read_data *,
+	unsigned nr_pages);
+
+extern enum pnfs_try_status objlayout_write_pagelist(
+	struct nfs_write_data *,
+	unsigned nr_pages,
+	int how);
+
+extern enum pnfs_try_status objlayout_commit(
+	struct nfs_write_data *,
+	int how);
+
+extern void objlayout_encode_layoutcommit(
+	struct pnfs_layout_hdr *,
+	struct xdr_stream *,
+	const struct nfs4_layoutcommit_args *);
+
+extern void objlayout_encode_layoutreturn(
+	struct pnfs_layout_hdr *,
+	struct xdr_stream *,
+	const struct nfs4_layoutreturn_args *);
 
 #endif /* _OBJLAYOUT_H */
diff --git a/fs/nfs/objlayout/panfs_shim.c b/fs/nfs/objlayout/panfs_shim.c
index fd46e96..9a499a9 100644
--- a/fs/nfs/objlayout/panfs_shim.c
+++ b/fs/nfs/objlayout/panfs_shim.c
@@ -463,8 +463,7 @@ objio_read_pagelist(struct objlayout_io_state *ol_state)
 {
 	struct panfs_shim_io_state *state = container_of(ol_state,
 					struct panfs_shim_io_state, ol_state);
-	struct objlayout_segment *lseg = LSEG_LD_DATA(ol_state->lseg);
-	pan_sm_map_cap_t *mcs = (pan_sm_map_cap_t *)lseg->internal;
+	pan_sm_map_cap_t *mcs = (pan_sm_map_cap_t *)ol_state->objlseg->internal;
 	ssize_t status = 0;
 	pan_status_t rc = PAN_SUCCESS;
 
@@ -544,8 +543,7 @@ objio_write_pagelist(struct objlayout_io_state *ol_state,
 {
 	struct panfs_shim_io_state *state = container_of(ol_state,
 					struct panfs_shim_io_state, ol_state);
-	struct objlayout_segment *lseg = LSEG_LD_DATA(ol_state->lseg);
-	pan_sm_map_cap_t *mcs = (pan_sm_map_cap_t *)lseg->internal;
+	pan_sm_map_cap_t *mcs = (pan_sm_map_cap_t *)ol_state->objlseg->internal;
 	ssize_t status = 0;
 	pan_status_t rc = PAN_SUCCESS;
 
@@ -636,7 +634,8 @@ panlayout_get_stripesize(struct pnfs_layout_hdr *pnfslay)
 
 	list_for_each_entry(lseg, &pnfslay->segs, fi_list) {
 		int n;
-		struct objlayout_segment *panlseg = LSEG_LD_DATA(lseg);
+		struct objlayout_segment *panlseg =
+			container_of(lseg, struct objlayout_segment, lseg);
 		struct pnfs_osd_layout *lo =
 			(struct pnfs_osd_layout *)panlseg->pnfs_osd_layout;
 		struct pnfs_osd_data_map *map = &lo->olo_map;
@@ -688,25 +687,37 @@ panlayout_get_blocksize(void)
 	return sz;
 }
 
-static struct layoutdriver_policy_operations panlayout_policy_operations = {
 /*
  * Don't gather across stripes, but rather gather (coalesce) up to
  * the stripe size.
  *
  * FIXME: change interface to use merge_align, merge_count
  */
-	.flags                 = PNFS_LAYOUTRET_ON_SETATTR,
-	.get_stripesize        = panlayout_get_stripesize,
-	.get_blocksize         = panlayout_get_blocksize,
-};
-
 #define PNFS_LAYOUT_PANOSD (NFS4_PNFS_PRIVATE_LAYOUT | LAYOUT_OSD2_OBJECTS)
 
 static struct pnfs_layoutdriver_type panlayout_type = {
 	.id = PNFS_LAYOUT_PANOSD,
 	.name = "PNFS_LAYOUT_PANOSD",
-	.ld_io_ops = &objlayout_io_operations,
-	.ld_policy_ops = &panlayout_policy_operations,
+	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
+
+	.initialize_mountpoint   = objlayout_initialize_mountpoint,
+	.uninitialize_mountpoint = objlayout_uninitialize_mountpoint,
+
+	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
+	.free_layout_hdr         = objlayout_free_layout_hdr,
+
+	.alloc_lseg              = objlayout_alloc_lseg,
+	.free_lseg               = objlayout_free_lseg,
+
+	.get_stripesize          = panlayout_get_stripesize,
+	.get_blocksize           = panlayout_get_blocksize,
+
+	.read_pagelist           = objlayout_read_pagelist,
+	.write_pagelist          = objlayout_write_pagelist,
+	.commit                  = objlayout_commit,
+
+	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
+	.encode_layoutreturn     = objlayout_encode_layoutreturn,
 };
 
 MODULE_DESCRIPTION("pNFS Layout Driver for Panasas OSDs");
@@ -716,10 +727,16 @@ MODULE_LICENSE("GPL");
 static int __init
 panlayout_init(void)
 {
-	pnfs_client_ops = pnfs_register_layoutdriver(&panlayout_type);
-	printk(KERN_INFO "%s: Registered Panasas OSD pNFS Layout Driver\n",
-	       __func__);
-	return 0;
+	int ret = pnfs_register_layoutdriver(&panlayout_type);
+
+	if (ret)
+		printk(KERN_INFO
+			"%s: Registering Panasas OSD pNFS Layout Driver failed: error=%d\n",
+			__func__, ret);
+	else
+		printk(KERN_INFO "%s: Registered Panasas OSD pNFS Layout Driver\n",
+			__func__);
+	return ret;
 }
 
 static void __exit
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index fef61e4..df29296 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -588,6 +588,8 @@ enum pnfs_layouttype {
 	LAYOUT_NFSV4_1_FILES  = 1,
 	LAYOUT_OSD2_OBJECTS = 2,
 	LAYOUT_BLOCK_VOLUME = 3,
+
+	NFS4_PNFS_PRIVATE_LAYOUT = 0x80000000
 };
 
 /* used for both layout return and recall */
diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
index 8fc21b0..b404f33 100644
--- a/include/linux/pnfs_osd_xdr.h
+++ b/include/linux/pnfs_osd_xdr.h
@@ -118,7 +118,7 @@ pnfs_osd_data_map_incore_sz(void)
  *   };
  */
 struct pnfs_osd_objid {
-	struct pnfs_deviceid	oid_device_id;
+	struct nfs4_deviceid	oid_device_id;
 	u64			oid_partition_id;
 	u64			oid_object_id;
 };
@@ -133,7 +133,7 @@ struct pnfs_osd_objid {
 static inline int
 pnfs_osd_objid_xdr_sz(void)
 {
-	return (NFS4_PNFS_DEVICEID4_SIZE / 4) + 2 + 2;
+	return (NFS4_DEVICEID4_SIZE / 4) + 2 + 2;
 }
 
 static inline size_t
-- 
1.7.2.3

