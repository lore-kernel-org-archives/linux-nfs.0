Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19730 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab1EUKaK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:30:10 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/13] SQUASHME: re-reorder the functions so it compares better with raids base
Date: Sat, 21 May 2011 13:29:58 +0300
Message-Id: <1305973798-17250-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch is based on pnfs-exofs. It will not patch on pnfs-submit
because of a one-liner patch  that comes after pnfs-submit. (I have
one for there as well)

It is here so I can compare with previouse code .i.e pnfs-all-2.6.38
and so it patches with all the work I have in my trees.

I'm reverting to the old functions order. All this code
shuffling was out of place, and gave me lots of grief. If at all
it must be done as a very last-last step. After there is no
more development to do. (And will still break all out of tree
work. Then why?)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c        |   52 ++++----
 fs/nfs/objlayout/objlayout.c        |  246 ++++++++++++++++++-----------------
 fs/nfs/objlayout/objlayout.h        |   24 ++--
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |   46 ++++----
 4 files changed, 186 insertions(+), 182 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index e7a0fcb..a2cb9a3 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -142,6 +142,31 @@ struct objio_segment {
 	struct osd_dev	*ods[1];
 };
 
+struct objio_state;
+typedef ssize_t (*objio_done_fn)(struct objio_state *ios);
+
+struct objio_state {
+	/* Generic layer */
+	struct objlayout_io_state ol_state;
+
+	struct objio_segment *objio_seg;
+
+	struct kref kref;
+	objio_done_fn done;
+	void *private;
+
+	unsigned long length;
+	unsigned numdevs; /* Actually used devs in this IO */
+	/* A per-device variable array of size numdevs */
+	struct _objio_per_comp {
+		struct bio *bio;
+		struct osd_request *or;
+		unsigned long length;
+		u64 offset;
+		unsigned dev;
+	} per_dev[];
+};
+
 /* Send and wait for a get_device_info of devices in the layout,
    then look them up with the osd_initiator library */
 static struct osd_dev *_device_lookup(struct pnfs_layout_hdr *pnfslay,
@@ -225,31 +250,6 @@ out:
 	return err;
 }
 
-struct objio_state;
-typedef ssize_t (*objio_done_fn)(struct objio_state *ios);
-
-struct objio_state {
-	/* Generic layer */
-	struct objlayout_io_state ol_state;
-
-	struct objio_segment *objio_seg;
-
-	struct kref kref;
-	objio_done_fn done;
-	void *private;
-
-	unsigned long length;
-	unsigned numdevs; /* Actually used devs in this IO */
-	/* A per-device variable array of size numdevs */
-	struct _objio_per_comp {
-		struct bio *bio;
-		struct osd_request *or;
-		unsigned long length;
-		u64 offset;
-		unsigned dev;
-	} per_dev[];
-};
-
 static int _verify_data_map(struct pnfs_osd_layout *layout)
 {
 	struct pnfs_osd_data_map *data_map = &layout->olo_map;
@@ -976,8 +976,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.read_pagelist           = objlayout_read_pagelist,
 	.write_pagelist          = objlayout_write_pagelist,
 
+	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
 	.encode_layoutreturn     = objlayout_encode_layoutreturn,
-	.encode_layoutcommit     = objlayout_encode_layoutcommit,
 };
 
 void *objio_init_mt(void)
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index a477492..a04e232 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -152,107 +152,6 @@ objlayout_free_lseg(struct pnfs_layout_segment *lseg)
 	kfree(objlseg);
 }
 
-struct objlayout_deviceinfo {
-	struct page *page;
-	struct pnfs_osd_deviceaddr da; /* This must be last */
-};
-
-/* Initialize and call nfs_getdeviceinfo, then decode and return a
- * "struct pnfs_osd_deviceaddr *" Eventually objlayout_put_deviceinfo()
- * should be called.
- */
-int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
-	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr)
-{
-	struct objlayout_deviceinfo *odi;
-	struct pnfs_device pd;
-	struct super_block *sb;
-	struct page *page, **pages;
-	size_t sz;
-	u32 *p;
-	int err;
-
-	page = alloc_page(GFP_KERNEL);
-	if (!page)
-		return -ENOMEM;
-
-	pages = &page;
-	pd.pages = pages;
-
-	memcpy(&pd.dev_id, d_id, sizeof(*d_id));
-	pd.layout_type = LAYOUT_OSD2_OBJECTS;
-	pd.pages = &page;
-	pd.pgbase = 0;
-	pd.pglen = PAGE_SIZE;
-	pd.mincount = 0;
-
-	sb = pnfslay->plh_inode->i_sb;
-	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd);
-	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
-	if (err)
-		goto err_out;
-
-	p = page_address(page);
-	sz = pnfs_osd_xdr_deviceaddr_incore_sz(p);
-	odi = kzalloc(sz + (sizeof(*odi) - sizeof(odi->da)), GFP_KERNEL);
-	if (!odi) {
-		err = -ENOMEM;
-		goto err_out;
-	}
-	pnfs_osd_xdr_decode_deviceaddr(&odi->da, p);
-	odi->page = page;
-	*deviceaddr = &odi->da;
-	return 0;
-
-err_out:
-	__free_page(page);
-	return err;
-}
-
-void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
-{
-	struct objlayout_deviceinfo *odi = container_of(deviceaddr,
-						struct objlayout_deviceinfo,
-						da);
-
-	__free_page(odi->page);
-	kfree(odi);
-}
-
-/*
- * Perform the objio specific init_mt method.
- * Set the layout driver private data pointer for later use.
- */
-int
-objlayout_set_layoutdriver(struct nfs_server *server,
-			   const struct nfs_fh *mntfh)
-{
-	void *data;
-
-	data = objio_init_mt();
-	if (IS_ERR(data)) {
-		printk(KERN_INFO "%s: objlayout lib not ready err=%ld\n",
-		       __func__, PTR_ERR(data));
-		return PTR_ERR(data);
-	}
-	server->pnfs_ld_data = data;
-
-	dprintk("%s: Return data=%p\n", __func__, data);
-	return 0;
-}
-
-/*
- * Perform the objio specific fini_mt method to release the
- * layoutdriver private data.
- */
-int
-objlayout_unset_layoutdriver(struct nfs_server *server)
-{
-	dprintk("%s: Begin %p\n", __func__, server->pnfs_ld_data);
-	objio_fini_mt(server->pnfs_ld_data);
-	return 0;
-}
-
 /*
  * I/O Operations
  */
@@ -553,6 +452,35 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
 	return PNFS_ATTEMPTED;
 }
 
+void
+objlayout_encode_layoutcommit(struct pnfs_layout_hdr *pnfslay,
+			      struct xdr_stream *xdr,
+			      const struct nfs4_layoutcommit_args *args)
+{
+	struct objlayout *objlay = OBJLAYOUT(pnfslay);
+	struct pnfs_osd_layoutupdate lou;
+	__be32 *start;
+
+	dprintk("%s: Begin\n", __func__);
+
+	spin_lock(&objlay->lock);
+	lou.dsu_valid = (objlay->delta_space_valid == OBJ_DSU_VALID);
+	lou.dsu_delta = objlay->delta_space_used;
+	objlay->delta_space_used = 0;
+	objlay->delta_space_valid = OBJ_DSU_INIT;
+	lou.olu_ioerr_flag = !list_empty(&objlay->err_list);
+	spin_unlock(&objlay->lock);
+
+	start = xdr_reserve_space(xdr, 4);
+
+	BUG_ON(pnfs_osd_xdr_encode_layoutupdate(xdr, &lou));
+
+	*start = cpu_to_be32((xdr->p - start - 1) * 4);
+
+	dprintk("%s: Return delta_space_used %lld err %d\n", __func__,
+		lou.dsu_delta, lou.olu_ioerr_flag);
+}
+
 static int
 err_prio(u32 oer_errno)
 {
@@ -726,31 +654,107 @@ loop_done:
 	dprintk("%s: Return\n", __func__);
 }
 
-void
-objlayout_encode_layoutcommit(struct pnfs_layout_hdr *pnfslay,
-			      struct xdr_stream *xdr,
-			      const struct nfs4_layoutcommit_args *args)
+
+/*
+ * Get Device Info API for io engines
+ */
+struct objlayout_deviceinfo {
+	struct page *page;
+	struct pnfs_osd_deviceaddr da; /* This must be last */
+};
+
+/* Initialize and call nfs_getdeviceinfo, then decode and return a
+ * "struct pnfs_osd_deviceaddr *" Eventually objlayout_put_deviceinfo()
+ * should be called.
+ */
+int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
+	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr)
 {
-	struct objlayout *objlay = OBJLAYOUT(pnfslay);
-	struct pnfs_osd_layoutupdate lou;
-	__be32 *start;
+	struct objlayout_deviceinfo *odi;
+	struct pnfs_device pd;
+	struct super_block *sb;
+	struct page *page, **pages;
+	size_t sz;
+	u32 *p;
+	int err;
 
-	dprintk("%s: Begin\n", __func__);
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
 
-	spin_lock(&objlay->lock);
-	lou.dsu_valid = (objlay->delta_space_valid == OBJ_DSU_VALID);
-	lou.dsu_delta = objlay->delta_space_used;
-	objlay->delta_space_used = 0;
-	objlay->delta_space_valid = OBJ_DSU_INIT;
-	lou.olu_ioerr_flag = !list_empty(&objlay->err_list);
-	spin_unlock(&objlay->lock);
+	pages = &page;
+	pd.pages = pages;
 
-	start = xdr_reserve_space(xdr, 4);
+	memcpy(&pd.dev_id, d_id, sizeof(*d_id));
+	pd.layout_type = LAYOUT_OSD2_OBJECTS;
+	pd.pages = &page;
+	pd.pgbase = 0;
+	pd.pglen = PAGE_SIZE;
+	pd.mincount = 0;
 
-	BUG_ON(pnfs_osd_xdr_encode_layoutupdate(xdr, &lou));
+	sb = pnfslay->plh_inode->i_sb;
+	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd);
+	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
+	if (err)
+		goto err_out;
 
-	*start = cpu_to_be32((xdr->p - start - 1) * 4);
+	p = page_address(page);
+	sz = pnfs_osd_xdr_deviceaddr_incore_sz(p);
+	odi = kzalloc(sz + (sizeof(*odi) - sizeof(odi->da)), GFP_KERNEL);
+	if (!odi) {
+		err = -ENOMEM;
+		goto err_out;
+	}
+	pnfs_osd_xdr_decode_deviceaddr(&odi->da, p);
+	odi->page = page;
+	*deviceaddr = &odi->da;
+	return 0;
 
-	dprintk("%s: Return delta_space_used %lld err %d\n", __func__,
-		lou.dsu_delta, lou.olu_ioerr_flag);
+err_out:
+	__free_page(page);
+	return err;
+}
+
+void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr)
+{
+	struct objlayout_deviceinfo *odi = container_of(deviceaddr,
+						struct objlayout_deviceinfo,
+						da);
+
+	__free_page(odi->page);
+	kfree(odi);
+}
+
+/*
+ * Perform the objio specific init_mt method.
+ * Set the layout driver private data pointer for later use.
+ */
+int
+objlayout_set_layoutdriver(struct nfs_server *server,
+			   const struct nfs_fh *mntfh)
+{
+	void *data;
+
+	data = objio_init_mt();
+	if (IS_ERR(data)) {
+		printk(KERN_INFO "%s: objlayout lib not ready err=%ld\n",
+		       __func__, PTR_ERR(data));
+		return PTR_ERR(data);
+	}
+	server->pnfs_ld_data = data;
+
+	dprintk("%s: Return data=%p\n", __func__, data);
+	return 0;
+}
+
+/*
+ * Perform the objio specific fini_mt method to release the
+ * layoutdriver private data.
+ */
+int
+objlayout_unset_layoutdriver(struct nfs_server *server)
+{
+	dprintk("%s: Begin %p\n", __func__, server->pnfs_ld_data);
+	objio_fini_mt(server->pnfs_ld_data);
+	return 0;
 }
diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
index 3157071a..38abb01 100644
--- a/fs/nfs/objlayout/objlayout.h
+++ b/fs/nfs/objlayout/objlayout.h
@@ -59,10 +59,6 @@ struct objlayout_segment {
  */
 struct objlayout {
 	struct pnfs_layout_hdr pnfs_layout;
-	spinlock_t lock;
-
-	 /* for layout_return */
-	struct list_head err_list;
 
 	 /* for layout_commit */
 	enum osd_delta_space_valid_enum {
@@ -71,6 +67,10 @@ struct objlayout {
 		OBJ_DSU_INVALID,
 	} delta_space_valid;
 	s64 delta_space_used;  /* consumed by write ops */
+
+	 /* for layout_return */
+	spinlock_t lock;
+	struct list_head err_list;
 };
 
 static inline struct objlayout *
@@ -157,6 +157,10 @@ extern void objlayout_read_done(struct objlayout_io_state *state,
 extern void objlayout_write_done(struct objlayout_io_state *state,
 				 ssize_t status, bool sync);
 
+extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
+	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr);
+extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
+
 /*
  * exported generic objects function vectors
  */
@@ -173,10 +177,6 @@ extern struct pnfs_layout_segment *objlayout_alloc_lseg(
 	struct nfs4_layoutget_res *);
 extern void objlayout_free_lseg(struct pnfs_layout_segment *);
 
-extern int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
-	struct nfs4_deviceid *d_id, struct pnfs_osd_deviceaddr **deviceaddr);
-extern void objlayout_put_deviceinfo(struct pnfs_osd_deviceaddr *deviceaddr);
-
 extern enum pnfs_try_status objlayout_read_pagelist(
 	struct nfs_read_data *);
 
@@ -184,14 +184,14 @@ extern enum pnfs_try_status objlayout_write_pagelist(
 	struct nfs_write_data *,
 	int how);
 
-extern void objlayout_encode_layoutreturn(
+extern void objlayout_encode_layoutcommit(
 	struct pnfs_layout_hdr *,
 	struct xdr_stream *,
-	const struct nfs4_layoutreturn_args *);
+	const struct nfs4_layoutcommit_args *);
 
-extern void objlayout_encode_layoutcommit(
+extern void objlayout_encode_layoutreturn(
 	struct pnfs_layout_hdr *,
 	struct xdr_stream *,
-	const struct nfs4_layoutcommit_args *);
+	const struct nfs4_layoutreturn_args *);
 
 #endif /* _OBJLAYOUT_H */
diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index 4ff2e3e..4dea458 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -353,6 +353,29 @@ void pnfs_osd_xdr_decode_deviceaddr(
 }
 
 /*
+ * struct pnfs_osd_layoutupdate {
+ * 	u32	dsu_valid;
+ * 	s64	dsu_delta;
+ * 	u32	olu_ioerr_flag;
+ * };
+ */
+int
+pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
+				 struct pnfs_osd_layoutupdate *lou)
+{
+	__be32 *p = xdr_reserve_space(xdr, 16);
+
+	if (!p)
+		return -E2BIG;
+
+	*p++ = cpu_to_be32(lou->dsu_valid);
+	if (lou->dsu_valid)
+		p = xdr_encode_hyper(p, lou->dsu_delta);
+	*p++ = cpu_to_be32(lou->olu_ioerr_flag);
+	return 0;
+}
+
+/*
  * struct pnfs_osd_objid {
  * 	struct pnfs_deviceid	oid_device_id;
  * 	u64			oid_partition_id;
@@ -405,26 +428,3 @@ int pnfs_osd_xdr_encode_ioerr(struct xdr_stream *xdr,
 
 	return 0;
 }
-
-/*
- * struct pnfs_osd_layoutupdate {
- * 	u32	dsu_valid;
- * 	s64	dsu_delta;
- * 	u32	olu_ioerr_flag;
- * };
- */
-int
-pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
-				 struct pnfs_osd_layoutupdate *lou)
-{
-	__be32 *p = xdr_reserve_space(xdr, 16);
-
-	if (!p)
-		return -E2BIG;
-
-	*p++ = cpu_to_be32(lou->dsu_valid);
-	if (lou->dsu_valid)
-		p = xdr_encode_hyper(p, lou->dsu_delta);
-	*p++ = cpu_to_be32(lou->olu_ioerr_flag);
-	return 0;
-}
-- 
1.7.2.3

