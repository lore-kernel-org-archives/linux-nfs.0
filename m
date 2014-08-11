Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:35976 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765AbaHKUEr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 16:04:47 -0400
Received: from [83.175.99.196] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XGvpl-0003NX-KR
	for linux-nfs@vger.kernel.org; Mon, 11 Aug 2014 20:04:45 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] pnfs/blocklayout: use the device id cache
Date: Mon, 11 Aug 2014 22:06:57 +0200
Message-Id: <1407787617-26050-5-git-send-email-hch@lst.de>
In-Reply-To: <1407787617-26050-1-git-send-email-hch@lst.de>
References: <1407787617-26050-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c    | 149 ++----------------------------------
 fs/nfs/blocklayout/blocklayout.h    |  25 ++----
 fs/nfs/blocklayout/blocklayoutdev.c |  88 +++++++++------------
 fs/nfs/blocklayout/blocklayoutdm.c  |  26 +------
 fs/nfs/blocklayout/extent_tree.c    |  27 ++++---
 5 files changed, 65 insertions(+), 250 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index fae8144..996578a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -119,6 +119,8 @@ static struct bio *bl_alloc_init_bio(int npg, sector_t isect,
 				     void (*end_io)(struct bio *, int err),
 				     struct parallel_io *par)
 {
+	struct pnfs_block_dev *dev =
+		container_of(be->be_device, struct pnfs_block_dev, d_node);
 	struct bio *bio;
 
 	npg = min(npg, BIO_MAX_PAGES);
@@ -131,7 +133,7 @@ static struct bio *bl_alloc_init_bio(int npg, sector_t isect,
 	if (bio) {
 		bio->bi_iter.bi_sector = isect - be->be_f_offset +
 			be->be_v_offset;
-		bio->bi_bdev = be->be_mdev;
+		bio->bi_bdev = dev->d_bdev;
 		bio->bi_end_io = end_io;
 		bio->bi_private = par;
 	}
@@ -514,96 +516,9 @@ bl_cleanup_layoutcommit(struct nfs4_layoutcommit_data *lcdata)
 	ext_tree_mark_committed(BLK_LO2EXT(lo), lcdata->res.status);
 }
 
-static void free_blk_mountid(struct block_mount_id *mid)
-{
-	if (mid) {
-		struct pnfs_block_dev *dev, *tmp;
-
-		/* No need to take bm_lock as we are last user freeing bm_devlist */
-		list_for_each_entry_safe(dev, tmp, &mid->bm_devlist, bm_node) {
-			list_del(&dev->bm_node);
-			bl_free_block_dev(dev);
-		}
-		kfree(mid);
-	}
-}
-
-/* This is mostly copied from the filelayout_get_device_info function.
- * It seems much of this should be at the generic pnfs level.
- */
-static struct pnfs_block_dev *
-nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
-			struct nfs4_deviceid *d_id)
-{
-	struct pnfs_device *dev;
-	struct pnfs_block_dev *rv;
-	u32 max_resp_sz;
-	int max_pages;
-	struct page **pages = NULL;
-	int i, rc;
-
-	/*
-	 * Use the session max response size as the basis for setting
-	 * GETDEVICEINFO's maxcount
-	 */
-	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
-	max_pages = nfs_page_array_len(0, max_resp_sz);
-	dprintk("%s max_resp_sz %u max_pages %d\n",
-		__func__, max_resp_sz, max_pages);
-
-	dev = kmalloc(sizeof(*dev), GFP_NOFS);
-	if (!dev) {
-		dprintk("%s kmalloc failed\n", __func__);
-		return ERR_PTR(-ENOMEM);
-	}
-
-	pages = kcalloc(max_pages, sizeof(struct page *), GFP_NOFS);
-	if (pages == NULL) {
-		kfree(dev);
-		return ERR_PTR(-ENOMEM);
-	}
-	for (i = 0; i < max_pages; i++) {
-		pages[i] = alloc_page(GFP_NOFS);
-		if (!pages[i]) {
-			rv = ERR_PTR(-ENOMEM);
-			goto out_free;
-		}
-	}
-
-	memcpy(&dev->dev_id, d_id, sizeof(*d_id));
-	dev->layout_type = LAYOUT_BLOCK_VOLUME;
-	dev->pages = pages;
-	dev->pgbase = 0;
-	dev->pglen = PAGE_SIZE * max_pages;
-	dev->mincount = 0;
-	dev->maxcount = max_resp_sz - nfs41_maxgetdevinfo_overhead;
-
-	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
-	rc = nfs4_proc_getdeviceinfo(server, dev, NULL);
-	dprintk("%s getdevice info returns %d\n", __func__, rc);
-	if (rc) {
-		rv = ERR_PTR(rc);
-		goto out_free;
-	}
-
-	rv = nfs4_blk_decode_device(server, dev);
- out_free:
-	for (i = 0; i < max_pages; i++)
-		__free_page(pages[i]);
-	kfree(pages);
-	kfree(dev);
-	return rv;
-}
-
 static int
 bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 {
-	struct block_mount_id *b_mt_id = NULL;
-	struct pnfs_devicelist *dlist = NULL;
-	struct pnfs_block_dev *bdev;
-	LIST_HEAD(block_disklist);
-	int status, i;
-
 	dprintk("%s enter\n", __func__);
 
 	if (server->pnfs_blksize == 0) {
@@ -616,60 +531,7 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 		return -EINVAL;
 	}
 
-	b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_NOFS);
-	if (!b_mt_id) {
-		status = -ENOMEM;
-		goto out_error;
-	}
-	/* Initialize nfs4 block layout mount id */
-	spin_lock_init(&b_mt_id->bm_lock);
-	INIT_LIST_HEAD(&b_mt_id->bm_devlist);
-
-	dlist = kmalloc(sizeof(struct pnfs_devicelist), GFP_NOFS);
-	if (!dlist) {
-		status = -ENOMEM;
-		goto out_error;
-	}
-	dlist->eof = 0;
-	while (!dlist->eof) {
-		status = nfs4_proc_getdevicelist(server, fh, dlist);
-		if (status)
-			goto out_error;
-		dprintk("%s GETDEVICELIST numdevs=%i, eof=%i\n",
-			__func__, dlist->num_devs, dlist->eof);
-		for (i = 0; i < dlist->num_devs; i++) {
-			bdev = nfs4_blk_get_deviceinfo(server, fh,
-						       &dlist->dev_id[i]);
-			if (IS_ERR(bdev)) {
-				status = PTR_ERR(bdev);
-				goto out_error;
-			}
-			spin_lock(&b_mt_id->bm_lock);
-			list_add(&bdev->bm_node, &b_mt_id->bm_devlist);
-			spin_unlock(&b_mt_id->bm_lock);
-		}
-	}
-	dprintk("%s SUCCESS\n", __func__);
-	server->pnfs_ld_data = b_mt_id;
-
- out_return:
-	kfree(dlist);
-	return status;
-
- out_error:
-	free_blk_mountid(b_mt_id);
-	goto out_return;
-}
-
-static int
-bl_clear_layoutdriver(struct nfs_server *server)
-{
-	struct block_mount_id *b_mt_id = server->pnfs_ld_data;
-
-	dprintk("%s enter\n", __func__);
-	free_blk_mountid(b_mt_id);
-	dprintk("%s RETURNS\n", __func__);
-	return 0;
+	return nfs4_deviceid_getdevicelist(server, fh);
 }
 
 static bool
@@ -810,7 +672,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.prepare_layoutcommit		= bl_prepare_layoutcommit,
 	.cleanup_layoutcommit		= bl_cleanup_layoutcommit,
 	.set_layoutdriver		= bl_set_layoutdriver,
-	.clear_layoutdriver		= bl_clear_layoutdriver,
+	.alloc_deviceid_node		= bl_alloc_deviceid_node,
+	.free_deviceid_node		= bl_free_deviceid_node,
 	.pg_read_ops			= &bl_pg_read_ops,
 	.pg_write_ops			= &bl_pg_write_ops,
 };
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index caae202..bdcc588 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -44,16 +44,9 @@
 #define PAGE_CACHE_SECTOR_SHIFT (PAGE_CACHE_SHIFT - SECTOR_SHIFT)
 #define SECTOR_SIZE (1 << SECTOR_SHIFT)
 
-struct block_mount_id {
-	spinlock_t			bm_lock;    /* protects list */
-	struct list_head		bm_devlist; /* holds pnfs_block_dev */
-};
-
 struct pnfs_block_dev {
-	struct list_head		bm_node;
-	struct nfs4_deviceid		bm_mdevid;    /* associated devid */
-	struct block_device		*bm_mdev;     /* meta device itself */
-	struct net			*net;
+	struct nfs4_deviceid_node	d_node;
+	struct block_device		*d_bdev;
 };
 
 enum exstate4 {
@@ -69,8 +62,7 @@ struct pnfs_block_extent {
 		struct rb_node	be_node;
 		struct list_head be_list;
 	};
-	struct nfs4_deviceid be_devid;	/* FIXME: could use device cache instead */
-	struct block_device *be_mdev;
+	struct nfs4_deviceid_node *be_device;
 	sector_t	be_f_offset;	/* the starting offset in the file */
 	sector_t	be_length;	/* the size of the extent */
 	sector_t	be_v_offset;	/* the starting offset in the volume */
@@ -90,8 +82,6 @@ struct pnfs_block_layout {
 	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
 };
 
-#define BLK_ID(lo) ((struct block_mount_id *)(NFS_SERVER(lo->plh_inode)->pnfs_ld_data))
-
 static inline struct pnfs_block_layout *
 BLK_LO2EXT(struct pnfs_layout_hdr *lo)
 {
@@ -123,14 +113,15 @@ struct bl_msg_hdr {
 /* blocklayoutdev.c */
 ssize_t bl_pipe_downcall(struct file *, const char __user *, size_t);
 void bl_pipe_destroy_msg(struct rpc_pipe_msg *);
-void nfs4_blkdev_put(struct block_device *bdev);
-struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
-						struct pnfs_device *dev);
 int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 				struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
 
+struct nfs4_deviceid_node *bl_alloc_deviceid_node(struct nfs_server *server,
+		struct pnfs_device *pdev, gfp_t gfp_mask);
+void bl_free_deviceid_node(struct nfs4_deviceid_node *d);
+
 /* blocklayoutdm.c */
-void bl_free_block_dev(struct pnfs_block_dev *bdev);
+void bl_dm_remove(struct net *net, dev_t dev);
 
 /* extent_tree.c */
 int ext_tree_insert(struct pnfs_block_layout *bl,
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index cd71b5e..d6527d2 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -53,16 +53,6 @@ static int decode_sector_number(__be32 **rp, sector_t *sp)
 	return 0;
 }
 
-/*
- * Release the block device
- */
-void nfs4_blkdev_put(struct block_device *bdev)
-{
-	dprintk("%s for device %d:%d\n", __func__, MAJOR(bdev->bd_dev),
-			MINOR(bdev->bd_dev));
-	blkdev_put(bdev, FMODE_READ);
-}
-
 ssize_t bl_pipe_downcall(struct file *filp, const char __user *src,
 			 size_t mlen)
 {
@@ -92,12 +82,12 @@ void bl_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 /*
  * Decodes pnfs_block_deviceaddr4 which is XDR encoded in dev->dev_addr_buf.
  */
-struct pnfs_block_dev *
-nfs4_blk_decode_device(struct nfs_server *server,
-		       struct pnfs_device *dev)
+struct nfs4_deviceid_node *
+bl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *dev,
+		gfp_t gfp_mask)
 {
 	struct pnfs_block_dev *rv;
-	struct block_device *bd = NULL;
+	struct block_device *bd;
 	struct bl_pipe_msg bl_pipe_msg;
 	struct rpc_pipe_msg *msg = &bl_pipe_msg.msg;
 	struct bl_msg_hdr bl_msg = {
@@ -117,11 +107,9 @@ nfs4_blk_decode_device(struct nfs_server *server,
 
 	bl_pipe_msg.bl_wq = &nn->bl_wq;
 	memset(msg, 0, sizeof(*msg));
-	msg->data = kzalloc(sizeof(bl_msg) + dev->mincount, GFP_NOFS);
-	if (!msg->data) {
-		rv = ERR_PTR(-ENOMEM);
+	msg->data = kzalloc(sizeof(bl_msg) + dev->mincount, gfp_mask);
+	if (!msg->data)
 		goto out;
-	}
 
 	memcpy(msg->data, &bl_msg, sizeof(bl_msg));
 	dataptr = (uint8_t *) msg->data;
@@ -140,7 +128,6 @@ nfs4_blk_decode_device(struct nfs_server *server,
 	rc = rpc_queue_upcall(nn->bl_device_pipe, msg);
 	if (rc < 0) {
 		remove_wait_queue(&nn->bl_wq, &wq);
-		rv = ERR_PTR(rc);
 		goto out;
 	}
 
@@ -152,7 +139,6 @@ nfs4_blk_decode_device(struct nfs_server *server,
 	if (reply->status != BL_DEVICE_REQUEST_PROC) {
 		printk(KERN_WARNING "%s failed to decode device: %d\n",
 			__func__, reply->status);
-		rv = ERR_PTR(-EINVAL);
 		goto out;
 	}
 
@@ -162,51 +148,40 @@ nfs4_blk_decode_device(struct nfs_server *server,
 		printk(KERN_WARNING "%s failed to open device %d:%d (%ld)\n",
 			__func__, reply->major, reply->minor,
 			PTR_ERR(bd));
-		rv = ERR_CAST(bd);
 		goto out;
 	}
 
-	rv = kzalloc(sizeof(*rv), GFP_NOFS);
-	if (!rv) {
-		rv = ERR_PTR(-ENOMEM);
+	rv = kzalloc(sizeof(*rv), gfp_mask);
+	if (!rv)
 		goto out;
-	}
 
-	rv->bm_mdev = bd;
-	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct nfs4_deviceid));
-	rv->net = net;
+	nfs4_init_deviceid_node(&rv->d_node, server, &dev->dev_id);
+	rv->d_bdev = bd;
+
 	dprintk("%s Created device %s with bd_block_size %u\n",
 		__func__,
 		bd->bd_disk->disk_name,
 		bd->bd_block_size);
 
+	kfree(msg->data);
+	return &rv->d_node;
+
 out:
 	kfree(msg->data);
-	return rv;
+	return NULL;
 }
 
-/* Map deviceid returned by the server to constructed block_device */
-static struct block_device *translate_devid(struct pnfs_layout_hdr *lo,
-					    struct nfs4_deviceid *id)
+void
+bl_free_deviceid_node(struct nfs4_deviceid_node *d)
 {
-	struct block_device *rv = NULL;
-	struct block_mount_id *mid;
-	struct pnfs_block_dev *dev;
-
-	dprintk("%s enter, lo=%p, id=%p\n", __func__, lo, id);
-	mid = BLK_ID(lo);
-	spin_lock(&mid->bm_lock);
-	list_for_each_entry(dev, &mid->bm_devlist, bm_node) {
-		if (memcmp(id->data, dev->bm_mdevid.data,
-			   NFS4_DEVICEID4_SIZE) == 0) {
-			rv = dev->bm_mdev;
-			goto out;
-		}
-	}
- out:
-	spin_unlock(&mid->bm_lock);
-	dprintk("%s returning %p\n", __func__, rv);
-	return rv;
+	struct pnfs_block_dev *dev =
+		container_of(d, struct pnfs_block_dev, d_node);
+	struct net *net = d->nfs_client->cl_net;
+
+	blkdev_put(dev->d_bdev, FMODE_READ);
+	bl_dm_remove(net, dev->d_bdev->bd_dev);
+
+	kfree(dev);
 }
 
 /* Tracks info needed to ensure extents in layout obey constraints of spec */
@@ -309,15 +284,20 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	 * recovery easier.
 	 */
 	for (i = 0; i < count; i++) {
+		struct nfs4_deviceid id;
+
 		be = kzalloc(sizeof(struct pnfs_block_extent), GFP_NOFS);
 		if (!be) {
 			status = -ENOMEM;
 			goto out_err;
 		}
-		memcpy(&be->be_devid, p, NFS4_DEVICEID4_SIZE);
+		memcpy(&id, p, NFS4_DEVICEID4_SIZE);
 		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
-		be->be_mdev = translate_devid(lo, &be->be_devid);
-		if (!be->be_mdev)
+
+		be->be_device =
+			nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &id,
+						lo->plh_lc_cred, gfp_flags);
+		if (!be->be_device)
 			goto out_err;
 
 		/* The next three values are read in as bytes,
@@ -364,12 +344,14 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	return status;
 
  out_err:
+	nfs4_put_deviceid_node(be->be_device);
 	kfree(be);
  out_free_list:
 	while (!list_empty(&extents)) {
 		be = list_first_entry(&extents, struct pnfs_block_extent,
 				      be_list);
 		list_del(&be->be_list);
+		nfs4_put_deviceid_node(be->be_device);
 		kfree(be);
 	}
 	goto out;
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 8999cfd..abc2e9e 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -38,7 +38,7 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
-static void dev_remove(struct net *net, dev_t dev)
+void bl_dm_remove(struct net *net, dev_t dev)
 {
 	struct bl_pipe_msg bl_pipe_msg;
 	struct rpc_pipe_msg *msg = &bl_pipe_msg.msg;
@@ -82,27 +82,3 @@ static void dev_remove(struct net *net, dev_t dev)
 out:
 	kfree(msg->data);
 }
-
-/*
- * Release meta device
- */
-static void nfs4_blk_metadev_release(struct pnfs_block_dev *bdev)
-{
-	dprintk("%s Releasing\n", __func__);
-	nfs4_blkdev_put(bdev->bm_mdev);
-	dev_remove(bdev->net, bdev->bm_mdev->bd_dev);
-}
-
-void bl_free_block_dev(struct pnfs_block_dev *bdev)
-{
-	if (bdev) {
-		if (bdev->bm_mdev) {
-			dprintk("%s Removing DM device: %d:%d\n",
-				__func__,
-				MAJOR(bdev->bm_mdev->bd_dev),
-				MINOR(bdev->bm_mdev->bd_dev));
-			nfs4_blk_metadev_release(bdev);
-		}
-		kfree(bdev);
-	}
-}
diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 3945221..32398dd 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -69,7 +69,7 @@ ext_can_merge(struct pnfs_block_extent *be1, struct pnfs_block_extent *be2)
 {
 	if (be1->be_state != be2->be_state)
 		return false;
-	if (be1->be_mdev != be2->be_mdev)
+	if (be1->be_device != be2->be_device)
 		return false;
 
 	if (be1->be_f_offset + be1->be_length != be2->be_f_offset)
@@ -94,6 +94,7 @@ ext_try_to_merge_left(struct rb_root *root, struct pnfs_block_extent *be)
 	if (left && ext_can_merge(left, be)) {
 		left->be_length += be->be_length;
 		rb_erase(&be->be_node, root);
+		nfs4_put_deviceid_node(be->be_device);
 		kfree(be);
 		return left;
 	}
@@ -109,6 +110,7 @@ ext_try_to_merge_right(struct rb_root *root, struct pnfs_block_extent *be)
 	if (right && ext_can_merge(be, right)) {
 		be->be_length += right->be_length;
 		rb_erase(&right->be_node, root);
+		nfs4_put_deviceid_node(right->be_device);
 		kfree(right);
 	}
 
@@ -133,16 +135,14 @@ __ext_tree_insert(struct rb_root *root,
 					be->be_v_offset = new->be_v_offset;
 				be->be_length += new->be_length;
 				be = ext_try_to_merge_left(root, be);
-				kfree(new);
-				return;
+				goto free_new;
 			}
 			p = &(*p)->rb_left;
 		} else if (new->be_f_offset >= ext_f_end(be)) {
 			if (merge_ok && ext_can_merge(be, new)) {
 				be->be_length += new->be_length;
 				be = ext_try_to_merge_right(root, be);
-				kfree(new);
-				return;
+				goto free_new;
 			}
 			p = &(*p)->rb_right;
 		} else {
@@ -152,6 +152,10 @@ __ext_tree_insert(struct rb_root *root,
 
 	rb_link_node(&new->be_node, parent, p);
 	rb_insert_color(&new->be_node, root);
+	return;
+free_new:
+	nfs4_put_deviceid_node(new->be_device);
+	kfree(new);
 }
 
 static int
@@ -196,9 +200,7 @@ __ext_tree_remove(struct rb_root *root, sector_t start, sector_t end)
 			new->be_length = len2;
 			new->be_state = be->be_state;
 			new->be_tag = be->be_tag;
-			new->be_mdev = be->be_mdev;
-			memcpy(&new->be_devid, &be->be_devid,
-				sizeof(struct nfs4_deviceid));
+			new->be_device = nfs4_get_deviceid(be->be_device);
 
 			__ext_tree_insert(root, new, true);
 		} else {
@@ -219,6 +221,7 @@ __ext_tree_remove(struct rb_root *root, sector_t start, sector_t end)
 			struct pnfs_block_extent *next = ext_tree_next(be);
 
 			rb_erase(&be->be_node, root);
+			nfs4_put_deviceid_node(be->be_device);
 			kfree(be);
 			be = next;
 		}
@@ -263,6 +266,7 @@ retry:
 		__ext_tree_insert(root, new, true);
 	} else if (new->be_f_offset >= be->be_f_offset) {
 		if (ext_f_end(new) <= ext_f_end(be)) {
+			nfs4_put_deviceid_node(new->be_device);
 			kfree(new);
 		} else {
 			sector_t new_len = ext_f_end(new) - ext_f_end(be);
@@ -288,6 +292,7 @@ retry:
 		}
 
 		split->be_length = be->be_f_offset - split->be_f_offset;
+		split->be_device = nfs4_get_deviceid(new->be_device);
 		__ext_tree_insert(root, split, true);
 
 		new->be_f_offset += diff;
@@ -378,9 +383,7 @@ ext_tree_split(struct rb_root *root, struct pnfs_block_extent *be,
 	new->be_length = orig_len - be->be_length;
 	new->be_state = be->be_state;
 	new->be_tag = be->be_tag;
-
-	new->be_mdev = be->be_mdev;
-	memcpy(&new->be_devid, &be->be_devid, sizeof(struct nfs4_deviceid));
+	new->be_device = nfs4_get_deviceid(be->be_device);
 
 	dprintk("%s: got 0x%lx:0x%lx!\n",
 		__func__, be->be_f_offset, ext_f_end(be));
@@ -484,7 +487,7 @@ static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
 			continue;
 		}
 
-		p = xdr_encode_opaque_fixed(p, be->be_devid.data,
+		p = xdr_encode_opaque_fixed(p, be->be_device->deviceid.data,
 				NFS4_DEVICEID4_SIZE);
 		p = xdr_encode_hyper(p, be->be_f_offset << SECTOR_SHIFT);
 		p = xdr_encode_hyper(p, be->be_length << SECTOR_SHIFT);
-- 
1.9.1

