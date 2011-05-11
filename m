Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39597 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756772Ab1EKWFG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2011 18:05:06 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Ensure that layoutget uses the correct gfp modes
Date: Wed, 11 May 2011 18:04:37 -0400
Message-Id: <1305151477-26890-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Currently, writebacks may end up recursing back into the filesystem due to
GFP_KERNEL direct reclaims in the pnfs subsystem.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |   25 ++++++++++++++-----------
 fs/nfs/nfs4filelayout.h    |    2 +-
 fs/nfs/nfs4filelayoutdev.c |   34 +++++++++++++++++-----------------
 fs/nfs/pnfs.c              |   33 +++++++++++++++++++--------------
 fs/nfs/pnfs.h              |    4 ++--
 fs/nfs/read.c              |    4 ++--
 fs/nfs/write.c             |    4 ++--
 include/linux/nfs_xdr.h    |    1 +
 8 files changed, 58 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 6f8192f..ecc7c51 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -416,7 +416,8 @@ static int
 filelayout_check_layout(struct pnfs_layout_hdr *lo,
 			struct nfs4_filelayout_segment *fl,
 			struct nfs4_layoutget_res *lgr,
-			struct nfs4_deviceid *id)
+			struct nfs4_deviceid *id,
+			gfp_t gfp_flags)
 {
 	struct nfs4_file_layout_dsaddr *dsaddr;
 	int status = -EINVAL;
@@ -439,7 +440,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	/* find and reference the deviceid */
 	dsaddr = nfs4_fl_find_get_deviceid(id);
 	if (dsaddr == NULL) {
-		dsaddr = get_device_info(lo->plh_inode, id);
+		dsaddr = get_device_info(lo->plh_inode, id, gfp_flags);
 		if (dsaddr == NULL)
 			goto out;
 	}
@@ -500,7 +501,8 @@ static int
 filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 			 struct nfs4_filelayout_segment *fl,
 			 struct nfs4_layoutget_res *lgr,
-			 struct nfs4_deviceid *id)
+			 struct nfs4_deviceid *id,
+			 gfp_t gfp_flags)
 {
 	struct xdr_stream stream;
 	struct xdr_buf buf = {
@@ -516,7 +518,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 
 	dprintk("%s: set_layout_map Begin\n", __func__);
 
-	scratch = alloc_page(GFP_KERNEL);
+	scratch = alloc_page(gfp_flags);
 	if (!scratch)
 		return -ENOMEM;
 
@@ -554,13 +556,13 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 		goto out_err;
 
 	fl->fh_array = kzalloc(fl->num_fh * sizeof(struct nfs_fh *),
-			       GFP_KERNEL);
+			       gfp_flags);
 	if (!fl->fh_array)
 		goto out_err;
 
 	for (i = 0; i < fl->num_fh; i++) {
 		/* Do we want to use a mempool here? */
-		fl->fh_array[i] = kmalloc(sizeof(struct nfs_fh), GFP_KERNEL);
+		fl->fh_array[i] = kmalloc(sizeof(struct nfs_fh), gfp_flags);
 		if (!fl->fh_array[i])
 			goto out_err_free;
 
@@ -605,19 +607,20 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 
 static struct pnfs_layout_segment *
 filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
-		      struct nfs4_layoutget_res *lgr)
+		      struct nfs4_layoutget_res *lgr,
+		      gfp_t gfp_flags)
 {
 	struct nfs4_filelayout_segment *fl;
 	int rc;
 	struct nfs4_deviceid id;
 
 	dprintk("--> %s\n", __func__);
-	fl = kzalloc(sizeof(*fl), GFP_KERNEL);
+	fl = kzalloc(sizeof(*fl), gfp_flags);
 	if (!fl)
 		return NULL;
 
-	rc = filelayout_decode_layout(layoutid, fl, lgr, &id);
-	if (rc != 0 || filelayout_check_layout(layoutid, fl, lgr, &id)) {
+	rc = filelayout_decode_layout(layoutid, fl, lgr, &id, gfp_flags);
+	if (rc != 0 || filelayout_check_layout(layoutid, fl, lgr, &id, gfp_flags)) {
 		_filelayout_free_lseg(fl);
 		return NULL;
 	}
@@ -633,7 +636,7 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		int size = (fl->stripe_type == STRIPE_SPARSE) ?
 			fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
 
-		fl->commit_buckets = kcalloc(size, sizeof(struct list_head), GFP_KERNEL);
+		fl->commit_buckets = kcalloc(size, sizeof(struct list_head), gfp_flags);
 		if (!fl->commit_buckets) {
 			filelayout_free_lseg(&fl->generic_hdr);
 			return NULL;
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 7c44579..2b461d7 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -104,6 +104,6 @@ extern struct nfs4_file_layout_dsaddr *
 nfs4_fl_find_get_deviceid(struct nfs4_deviceid *dev_id);
 extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
-get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id);
+get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index de5350f..db07c7a 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -225,11 +225,11 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 }
 
 static struct nfs4_pnfs_ds *
-nfs4_pnfs_ds_add(struct inode *inode, u32 ip_addr, u32 port)
+nfs4_pnfs_ds_add(struct inode *inode, u32 ip_addr, u32 port, gfp_t gfp_flags)
 {
 	struct nfs4_pnfs_ds *tmp_ds, *ds;
 
-	ds = kzalloc(sizeof(*tmp_ds), GFP_KERNEL);
+	ds = kzalloc(sizeof(*tmp_ds), gfp_flags);
 	if (!ds)
 		goto out;
 
@@ -261,7 +261,7 @@ out:
  * Currently only support ipv4, and one multi-path address.
  */
 static struct nfs4_pnfs_ds *
-decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode)
+decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode, gfp_t gfp_flags)
 {
 	struct nfs4_pnfs_ds *ds = NULL;
 	char *buf;
@@ -303,7 +303,7 @@ decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode)
 			rlen);
 		goto out_err;
 	}
-	buf = kmalloc(rlen + 1, GFP_KERNEL);
+	buf = kmalloc(rlen + 1, gfp_flags);
 	if (!buf) {
 		dprintk("%s: Not enough memory\n", __func__);
 		goto out_err;
@@ -333,7 +333,7 @@ decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode)
 	sscanf(pstr, "-%d-%d", &tmp[0], &tmp[1]);
 	port = htons((tmp[0] << 8) | (tmp[1]));
 
-	ds = nfs4_pnfs_ds_add(inode, ip_addr, port);
+	ds = nfs4_pnfs_ds_add(inode, ip_addr, port, gfp_flags);
 	dprintk("%s: Decoded address and port %s\n", __func__, buf);
 out_free:
 	kfree(buf);
@@ -343,7 +343,7 @@ out_err:
 
 /* Decode opaque device data and return the result */
 static struct nfs4_file_layout_dsaddr*
-decode_device(struct inode *ino, struct pnfs_device *pdev)
+decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
 {
 	int i;
 	u32 cnt, num;
@@ -362,7 +362,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev)
 	struct page *scratch;
 
 	/* set up xdr stream */
-	scratch = alloc_page(GFP_KERNEL);
+	scratch = alloc_page(gfp_flags);
 	if (!scratch)
 		goto out_err;
 
@@ -384,7 +384,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev)
 	}
 
 	/* read stripe indices */
-	stripe_indices = kcalloc(cnt, sizeof(u8), GFP_KERNEL);
+	stripe_indices = kcalloc(cnt, sizeof(u8), gfp_flags);
 	if (!stripe_indices)
 		goto out_err_free_scratch;
 
@@ -423,7 +423,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev)
 
 	dsaddr = kzalloc(sizeof(*dsaddr) +
 			(sizeof(struct nfs4_pnfs_ds *) * (num - 1)),
-			GFP_KERNEL);
+			gfp_flags);
 	if (!dsaddr)
 		goto out_err_free_stripe_indices;
 
@@ -452,7 +452,7 @@ decode_device(struct inode *ino, struct pnfs_device *pdev)
 		for (j = 0; j < mp_count; j++) {
 			if (j == 0) {
 				dsaddr->ds_list[i] = decode_and_add_ds(&stream,
-					ino);
+					ino, gfp_flags);
 				if (dsaddr->ds_list[i] == NULL)
 					goto out_err_free_deviceid;
 			} else {
@@ -503,12 +503,12 @@ out_err:
  * available devices.
  */
 static struct nfs4_file_layout_dsaddr *
-decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
+decode_and_add_device(struct inode *inode, struct pnfs_device *dev, gfp_t gfp_flags)
 {
 	struct nfs4_file_layout_dsaddr *d, *new;
 	long hash;
 
-	new = decode_device(inode, dev);
+	new = decode_device(inode, dev, gfp_flags);
 	if (!new) {
 		printk(KERN_WARNING "%s: Could not decode or add device\n",
 			__func__);
@@ -537,7 +537,7 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev)
  * of available devices, and return it.
  */
 struct nfs4_file_layout_dsaddr *
-get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id)
+get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags)
 {
 	struct pnfs_device *pdev = NULL;
 	u32 max_resp_sz;
@@ -556,17 +556,17 @@ get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id)
 	dprintk("%s inode %p max_resp_sz %u max_pages %d\n",
 		__func__, inode, max_resp_sz, max_pages);
 
-	pdev = kzalloc(sizeof(struct pnfs_device), GFP_KERNEL);
+	pdev = kzalloc(sizeof(struct pnfs_device), gfp_flags);
 	if (pdev == NULL)
 		return NULL;
 
-	pages = kzalloc(max_pages * sizeof(struct page *), GFP_KERNEL);
+	pages = kzalloc(max_pages * sizeof(struct page *), gfp_flags);
 	if (pages == NULL) {
 		kfree(pdev);
 		return NULL;
 	}
 	for (i = 0; i < max_pages; i++) {
-		pages[i] = alloc_page(GFP_KERNEL);
+		pages[i] = alloc_page(gfp_flags);
 		if (!pages[i])
 			goto out_free;
 	}
@@ -587,7 +587,7 @@ get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id)
 	 * Found new device, need to decode it and then add it to the
 	 * list of known devices for this mountpoint.
 	 */
-	dsaddr = decode_and_add_device(inode, pdev);
+	dsaddr = decode_and_add_device(inode, pdev, gfp_flags);
 out_free:
 	for (i = 0; i < max_pages; i++)
 		__free_page(pages[i]);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ff681ab..036cda4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -466,7 +466,8 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 static struct pnfs_layout_segment *
 send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
-	   u32 iomode)
+	   u32 iomode,
+	   gfp_t gfp_flags)
 {
 	struct inode *ino = lo->plh_inode;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -479,7 +480,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	dprintk("--> %s\n", __func__);
 
 	BUG_ON(ctx == NULL);
-	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
+	lgp = kzalloc(sizeof(*lgp), gfp_flags);
 	if (lgp == NULL)
 		return NULL;
 
@@ -487,12 +488,12 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
 	max_pages = max_resp_sz >> PAGE_SHIFT;
 
-	pages = kzalloc(max_pages * sizeof(struct page *), GFP_KERNEL);
+	pages = kzalloc(max_pages * sizeof(struct page *), gfp_flags);
 	if (!pages)
 		goto out_err_free;
 
 	for (i = 0; i < max_pages; i++) {
-		pages[i] = alloc_page(GFP_KERNEL);
+		pages[i] = alloc_page(gfp_flags);
 		if (!pages[i])
 			goto out_err_free;
 	}
@@ -508,6 +509,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	lgp->args.layout.pages = pages;
 	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
 	lgp->lsegpp = &lseg;
+	lgp->gfp_flags = gfp_flags;
 
 	/* Synchronously retrieve layout information from server and
 	 * store in lseg.
@@ -665,11 +667,11 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 }
 
 static struct pnfs_layout_hdr *
-alloc_init_layout_hdr(struct inode *ino)
+alloc_init_layout_hdr(struct inode *ino, gfp_t gfp_flags)
 {
 	struct pnfs_layout_hdr *lo;
 
-	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
+	lo = kzalloc(sizeof(struct pnfs_layout_hdr), gfp_flags);
 	if (!lo)
 		return NULL;
 	atomic_set(&lo->plh_refcount, 1);
@@ -681,7 +683,7 @@ alloc_init_layout_hdr(struct inode *ino)
 }
 
 static struct pnfs_layout_hdr *
-pnfs_find_alloc_layout(struct inode *ino)
+pnfs_find_alloc_layout(struct inode *ino, gfp_t gfp_flags)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_hdr *new = NULL;
@@ -696,7 +698,7 @@ pnfs_find_alloc_layout(struct inode *ino)
 			return nfsi->layout;
 	}
 	spin_unlock(&ino->i_lock);
-	new = alloc_init_layout_hdr(ino);
+	new = alloc_init_layout_hdr(ino, gfp_flags);
 	spin_lock(&ino->i_lock);
 
 	if (likely(nfsi->layout == NULL))	/* Won the race? */
@@ -756,7 +758,8 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
-		   enum pnfs_iomode iomode)
+		   enum pnfs_iomode iomode,
+		   gfp_t gfp_flags)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
@@ -767,7 +770,7 @@ pnfs_update_layout(struct inode *ino,
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		return NULL;
 	spin_lock(&ino->i_lock);
-	lo = pnfs_find_alloc_layout(ino);
+	lo = pnfs_find_alloc_layout(ino, gfp_flags);
 	if (lo == NULL) {
 		dprintk("%s ERROR: can't get pnfs_layout_hdr\n", __func__);
 		goto out_unlock;
@@ -807,7 +810,7 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&clp->cl_lock);
 	}
 
-	lseg = send_layoutget(lo, ctx, iomode);
+	lseg = send_layoutget(lo, ctx, iomode, gfp_flags);
 	if (!lseg && first) {
 		spin_lock(&clp->cl_lock);
 		list_del_init(&lo->plh_layouts);
@@ -846,7 +849,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out;
 	}
 	/* Inject layout blob into I/O device driver */
-	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res);
+	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res, lgp->gfp_flags);
 	if (!lseg || IS_ERR(lseg)) {
 		if (!lseg)
 			status = -ENOMEM;
@@ -899,7 +902,8 @@ static int pnfs_read_pg_test(struct nfs_pageio_descriptor *pgio,
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   prev->wb_context,
-						   IOMODE_READ);
+						   IOMODE_READ,
+						   GFP_KERNEL);
 	}
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
@@ -921,7 +925,8 @@ static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   prev->wb_context,
-						   IOMODE_RW);
+						   IOMODE_RW,
+						   GFP_NOFS);
 	}
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bc48272..5c67535 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -70,7 +70,7 @@ struct pnfs_layoutdriver_type {
 	const u32 id;
 	const char *name;
 	struct module *owner;
-	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
+	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
 	/* test for nfs page cache coalescing */
@@ -126,7 +126,7 @@ void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type);
+		   enum pnfs_iomode access_type, gfp_t gfp_flags);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 7cded2b..2bcf0dc 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -288,7 +288,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 	atomic_set(&req->wb_complete, requests);
 
 	BUG_ON(desc->pg_lseg != NULL);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ);
+	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ, GFP_KERNEL);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
@@ -351,7 +351,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
 	}
 	req = nfs_list_entry(data->pages.next);
 	if ((!lseg) && list_is_singular(&data->pages))
-		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ);
+		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ, GFP_KERNEL);
 
 	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, desc->pg_count,
 				0, lseg);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3bd5d7e..49c715b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -939,7 +939,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	atomic_set(&req->wb_complete, requests);
 
 	BUG_ON(desc->pg_lseg);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW);
+	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW, GFP_NOFS);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
@@ -1013,7 +1013,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 	}
 	req = nfs_list_entry(data->pages.next);
 	if ((!lseg) && list_is_singular(&data->pages))
-		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW);
+		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW, GFP_NOFS);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit))
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 890dce2..7e371f7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -233,6 +233,7 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_args args;
 	struct nfs4_layoutget_res res;
 	struct pnfs_layout_segment **lsegpp;
+	gfp_t gfp_flags;
 };
 
 struct nfs4_getdeviceinfo_args {
-- 
1.7.4.4

