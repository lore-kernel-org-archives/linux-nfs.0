Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51179 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1FGRbs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:31:48 -0400
Date: Tue, 7 Jun 2011 13:31:45 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 47/88] pnfsblock: use the session max response size for
 getdeviceinfo's maxcount
Message-ID: <6e98d9a006aaadf59863b74a3985fb99e0f33c97.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Mike Sager <sager@netapp.com>

Per Trond, no need to try a small maxcount first.  Base the maxcount
on the session's max response size.

Same change as for files.  Untested for blocks though.

Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   62 ++++++++++++++++++++-----------------
 1 files changed, 33 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index cf306e9..65cf104 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -694,59 +694,63 @@ nfs4_blk_get_deviceinfo(struct super_block *sb, struct nfs_fh *fh,
 {
 	struct pnfs_device *dev;
 	struct pnfs_block_dev *rv = NULL;
-	int maxpages = NFS4_GETDEVINFO_MAXSIZE >> PAGE_SHIFT;
-	struct page *pages[maxpages];
-	int alloced_pages = 0, used_pages = 1;
-	int j, rc;
+	u32 max_resp_sz;
+	int max_pages;
+	struct page **pages = NULL;
+	int i, rc;
+	struct nfs_server *server = NFS_SB(sb);
+
+	/*
+	 * Use the session max response size as the basis for setting
+	 * GETDEVICEINFO's maxcount
+	 */
+	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
+	max_pages = max_resp_sz >> PAGE_SHIFT;
+	dprintk("%s max_resp_sz %u max_pages %d\n",
+		__func__, max_resp_sz, max_pages);
 
-	dprintk("%s enter\n", __func__);
 	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
 	if (!dev) {
 		dprintk("%s kmalloc failed\n", __func__);
 		return NULL;
 	}
- retry_once:
-	dprintk("%s trying used_pages %d\n", __func__, used_pages);
-	for (; alloced_pages < used_pages; alloced_pages++) {
-		pages[alloced_pages] = alloc_page(GFP_KERNEL);
-		if (!pages[alloced_pages])
-			goto out_free;
+
+	pages = kzalloc(max_pages * sizeof(struct page *), GFP_KERNEL);
+	if (pages == NULL) {
+		kfree(dev);
+		return NULL;
 	}
-	/* set dev->area */
-	if (used_pages == 1)
-		dev->area = page_address(pages[0]);
-	else {
-		dev->area = vmap(pages, used_pages, VM_MAP, PAGE_KERNEL);
-		if (!dev->area)
+	for (i = 0; i < max_pages; i++) {
+		pages[i] = alloc_page(GFP_KERNEL);
+		if (!pages[i])
 			goto out_free;
 	}
 
+	/* set dev->area */
+	dev->area = vmap(pages, max_pages, VM_MAP, PAGE_KERNEL);
+	if (!dev->area)
+		goto out_free;
+
 	memcpy(&dev->dev_id, d_id, sizeof(*d_id));
 	dev->layout_type = LAYOUT_BLOCK_VOLUME;
 	dev->dev_notify_types = 0;
 	dev->pages = pages;
 	dev->pgbase = 0;
-	dev->pglen = PAGE_SIZE * used_pages;
+	dev->pglen = PAGE_SIZE * max_pages;
 	dev->mincount = 0;
 
 	rc = pnfs_callback_ops->nfs_getdeviceinfo(sb, dev);
-	dprintk("%s getdevice info returns %d used_pages %d\n", __func__, rc,
-		used_pages);
-	if (rc == -ETOOSMALL && used_pages == 1) {
-		dev->area = NULL;
-		used_pages = (dev->mincount + PAGE_SIZE - 1) >> PAGE_SHIFT;
-		if (used_pages > 1 && used_pages <= maxpages)
-			goto retry_once;
-	}
+	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc)
 		goto out_free;
 
 	rv = nfs4_blk_decode_device(sb, dev, sdlist);
  out_free:
-	if (used_pages > 1 && dev->area != NULL)
+	if (dev->area != NULL)
 		vunmap(dev->area);
-	for (j = 0; j < alloced_pages; j++)
-		__free_page(pages[j]);
+	for (i = 0; i < max_pages; i++)
+		__free_page(pages[i]);
+	kfree(pages);
 	kfree(dev);
 	return rv;
 }
-- 
1.7.4.1

