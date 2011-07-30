From: Jim Rees <rees@umich.edu>
Subject: [PATCH v6 16/26] pnfsblock: call and parse getdevicelist
Date: Sat, 30 Jul 2011 13:08:39 -0400
Message-ID: <1312045729-27554-17-git-send-email-rees@umich.edu>
References: <1312045729-27554-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:49606 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499Ab1G3RJS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 13:09:18 -0400
In-Reply-To: <1312045729-27554-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

Call GETDEVICELIST during mount, then call and parse GETDEVICEINFO
for each device returned.

[pnfsblock: get rid of deprecated xdr macros]
Signed-off-by: Jim Rees <rees@umich.edu>
[pnfsblock: fix pnfs_deviceid references]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fix print format warnings for sector_t and size_t]
[pnfs-block: #include <linux/vmalloc.h>]
[pnfsblock: no PNFS_NFS_SERVER]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsblock: fix bug determining size of striped volume]
[pnfsblock: fix oops when using multiple devices]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
[pnfsblock: get rid of vmap and deviceid->area structure]
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c    |  138 ++++++++++++++++++++++++++++++++++-
 fs/nfs/blocklayout/blocklayout.h    |   13 +++-
 fs/nfs/blocklayout/blocklayoutdev.c |   13 +++-
 fs/nfs/pnfs.h                       |    1 -
 include/linux/nfs_fs_sb.h           |    1 +
 5 files changed, 158 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 5793b0e..c4d2ee0 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -158,17 +158,153 @@ bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
 {
 }
 
+static void free_blk_mountid(struct block_mount_id *mid)
+{
+	if (mid) {
+		struct pnfs_block_dev *dev;
+		spin_lock(&mid->bm_lock);
+		while (!list_empty(&mid->bm_devlist)) {
+			dev = list_first_entry(&mid->bm_devlist,
+					       struct pnfs_block_dev,
+					       bm_node);
+			list_del(&dev->bm_node);
+			bl_free_block_dev(dev);
+		}
+		spin_unlock(&mid->bm_lock);
+		kfree(mid);
+	}
+}
+
+/* This is mostly copied from the filelayout's get_device_info function.
+ * It seems much of this should be at the generic pnfs level.
+ */
+static struct pnfs_block_dev *
+nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
+			struct nfs4_deviceid *d_id)
+{
+	struct pnfs_device *dev;
+	struct pnfs_block_dev *rv = NULL;
+	u32 max_resp_sz;
+	int max_pages;
+	struct page **pages = NULL;
+	int i, rc;
+
+	/*
+	 * Use the session max response size as the basis for setting
+	 * GETDEVICEINFO's maxcount
+	 */
+	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
+	max_pages = max_resp_sz >> PAGE_SHIFT;
+	dprintk("%s max_resp_sz %u max_pages %d\n",
+		__func__, max_resp_sz, max_pages);
+
+	dev = kmalloc(sizeof(*dev), GFP_NOFS);
+	if (!dev) {
+		dprintk("%s kmalloc failed\n", __func__);
+		return NULL;
+	}
+
+	pages = kzalloc(max_pages * sizeof(struct page *), GFP_NOFS);
+	if (pages == NULL) {
+		kfree(dev);
+		return NULL;
+	}
+	for (i = 0; i < max_pages; i++) {
+		pages[i] = alloc_page(GFP_NOFS);
+		if (!pages[i])
+			goto out_free;
+	}
+
+	memcpy(&dev->dev_id, d_id, sizeof(*d_id));
+	dev->layout_type = LAYOUT_BLOCK_VOLUME;
+	dev->pages = pages;
+	dev->pgbase = 0;
+	dev->pglen = PAGE_SIZE * max_pages;
+	dev->mincount = 0;
+
+	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
+	rc = nfs4_proc_getdeviceinfo(server, dev);
+	dprintk("%s getdevice info returns %d\n", __func__, rc);
+	if (rc)
+		goto out_free;
+
+	rv = nfs4_blk_decode_device(server, dev);
+ out_free:
+	for (i = 0; i < max_pages; i++)
+		__free_page(pages[i]);
+	kfree(pages);
+	kfree(dev);
+	return rv;
+}
+
 static int
 bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 {
+	struct block_mount_id *b_mt_id = NULL;
+	struct pnfs_devicelist *dlist = NULL;
+	struct pnfs_block_dev *bdev;
+	LIST_HEAD(block_disklist);
+	int status = 0, i;
+
 	dprintk("%s enter\n", __func__);
-	return 0;
+
+	if (server->pnfs_blksize == 0) {
+		dprintk("%s Server did not return blksize\n", __func__);
+		return -EINVAL;
+	}
+	b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_NOFS);
+	if (!b_mt_id) {
+		status = -ENOMEM;
+		goto out_error;
+	}
+	/* Initialize nfs4 block layout mount id */
+	spin_lock_init(&b_mt_id->bm_lock);
+	INIT_LIST_HEAD(&b_mt_id->bm_devlist);
+
+	dlist = kmalloc(sizeof(struct pnfs_devicelist), GFP_NOFS);
+	if (!dlist) {
+		status = -ENOMEM;
+		goto out_error;
+	}
+	dlist->eof = 0;
+	while (!dlist->eof) {
+		status = nfs4_proc_getdevicelist(server, fh, dlist);
+		if (status)
+			goto out_error;
+		dprintk("%s GETDEVICELIST numdevs=%i, eof=%i\n",
+			__func__, dlist->num_devs, dlist->eof);
+		for (i = 0; i < dlist->num_devs; i++) {
+			bdev = nfs4_blk_get_deviceinfo(server, fh,
+						       &dlist->dev_id[i]);
+			if (!bdev) {
+				status = -ENODEV;
+				goto out_error;
+			}
+			spin_lock(&b_mt_id->bm_lock);
+			list_add(&bdev->bm_node, &b_mt_id->bm_devlist);
+			spin_unlock(&b_mt_id->bm_lock);
+		}
+	}
+	dprintk("%s SUCCESS\n", __func__);
+	server->pnfs_ld_data = b_mt_id;
+
+ out_return:
+	kfree(dlist);
+	return status;
+
+ out_error:
+	free_blk_mountid(b_mt_id);
+	goto out_return;
 }
 
 static int
 bl_clear_layoutdriver(struct nfs_server *server)
 {
+	struct block_mount_id *b_mt_id = server->pnfs_ld_data;
+
 	dprintk("%s enter\n", __func__);
+	free_blk_mountid(b_mt_id);
+	dprintk("%s RETURNS\n", __func__);
 	return 0;
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 581d8f4..d645880 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -38,6 +38,11 @@
 
 #include "../pnfs.h"
 
+struct block_mount_id {
+	spinlock_t			bm_lock;    /* protects list */
+	struct list_head		bm_devlist; /* holds pnfs_block_dev */
+};
+
 struct pnfs_block_dev {
 	struct list_head		bm_node;
 	struct nfs4_deviceid		bm_mdevid;    /* associated devid */
@@ -99,7 +104,10 @@ struct pnfs_block_layout {
 	sector_t		bl_blocksize;  /* Server blocksize in sectors */
 };
 
-static inline struct pnfs_block_layout *BLK_LO2EXT(struct pnfs_layout_hdr *lo)
+#define BLK_ID(lo) ((struct block_mount_id *)(NFS_SERVER(lo->plh_inode)->pnfs_ld_data))
+
+static inline struct pnfs_block_layout *
+BLK_LO2EXT(struct pnfs_layout_hdr *lo)
 {
 	return container_of(lo, struct pnfs_block_layout, bl_layout);
 }
@@ -137,8 +145,7 @@ void bl_pipe_destroy_msg(struct rpc_pipe_msg *);
 struct block_device *nfs4_blkdev_get(dev_t dev);
 int nfs4_blkdev_put(struct block_device *bdev);
 struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
-						struct pnfs_device *dev,
-						struct list_head *sdlist);
+						struct pnfs_device *dev);
 int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 				struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
 
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 64da33a..b23fe60 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -116,8 +116,7 @@ void bl_pipe_destroy_msg(struct rpc_pipe_msg *msg)
  */
 struct pnfs_block_dev *
 nfs4_blk_decode_device(struct nfs_server *server,
-		       struct pnfs_device *dev,
-		       struct list_head *sdlist)
+		       struct pnfs_device *dev)
 {
 	struct pnfs_block_dev *rv = NULL;
 	struct block_device *bd = NULL;
@@ -129,6 +128,7 @@ nfs4_blk_decode_device(struct nfs_server *server,
 	uint8_t *dataptr;
 	DECLARE_WAITQUEUE(wq, current);
 	struct bl_dev_msg *reply = &bl_mount_reply;
+	int offset, len, i;
 
 	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
 	dprintk("%s: deviceid: %s, mincount: %d\n", __func__, dev->dev_id.data,
@@ -143,7 +143,14 @@ nfs4_blk_decode_device(struct nfs_server *server,
 
 	memcpy(msg.data, &bl_msg, sizeof(bl_msg));
 	dataptr = (uint8_t *) msg.data;
-	memcpy(&dataptr[sizeof(bl_msg)], dev->area, dev->mincount);
+	len = dev->mincount;
+	offset = sizeof(bl_msg);
+	for (i = 0; len > 0; i++) {
+		memcpy(&dataptr[offset], page_address(dev->pages[i]),
+				len < PAGE_CACHE_SIZE ? len : PAGE_CACHE_SIZE);
+		len -= PAGE_CACHE_SIZE;
+		offset += PAGE_CACHE_SIZE;
+	}
 	msg.len = sizeof(bl_msg) + dev->mincount;
 
 	dprintk("%s CALLING USERSPACE DAEMON\n", __func__);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f271425..82dde37 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -141,7 +141,6 @@ struct pnfs_device {
 	unsigned int  layout_type;
 	unsigned int  mincount;
 	struct page **pages;
-	void          *area;
 	unsigned int  pgbase;
 	unsigned int  pglen;
 };
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b2ea8b8..cc03fc1 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -146,6 +146,7 @@ struct nfs_server {
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
 	struct rpc_wait_queue	roc_rpcwaitq;
 	u32			pnfs_blksize;	/* layout_blksize attr */
+	void			*pnfs_ld_data;	/* per mount point data */
 
 	/* the following fields are protected by nfs_client->cl_lock */
 	struct rb_root		state_owners;
-- 
1.7.4.1

