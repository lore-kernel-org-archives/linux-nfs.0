Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51649 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab2FHMNW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 08:13:22 -0400
Message-ID: <4FD1EC54.9070909@panasas.com>
Date: Fri, 8 Jun 2012 15:13:08 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Subject: [PATCH 3/6] pnfs-obj: Fix __r4w_get_page when offset is beyond i_size
References: <4FD1CEA8.3090105@panasas.com>
In-Reply-To: <4FD1CEA8.3090105@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


It is very common for the end of the file to be unaligned on
stripe size. But since we know it's beyond file's end then
the XOR should be preformed with all zeros.

Old code used to just read zeros out of the OSD devices, which is a great
waist. But what scares me more about this situation is that, we now have
pages attached to the file's mapping that are beyond i_size. I don't
like the kind of bugs this calls for.

Fix both birds, by returning a global zero_page, if offset is beyond
i_size.

TODO:
	Change the API to ->__r4w_get_page() so a NULL can be
	returned without being considered as error, since XOR API
	treats NULL entries as zero_pages.

[Bug since 3.2. Should apply the same way to all Kernels since]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index b47277b..0e7c833 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -480,14 +480,28 @@ static void _write_done(struct ore_io_state *ios, void *private)
 	objlayout_write_done(&objios->oir, status, objios->sync);
 }
 
+static struct page *g_zero_page;
+
 static struct page *__r4w_get_page(void *priv, u64 offset, bool *uptodate)
 {
 	struct objio_state *objios = priv;
 	struct nfs_write_data *wdata = objios->oir.rpcdata;
 	struct address_space *mapping = wdata->header->inode->i_mapping;
 	pgoff_t index = offset / PAGE_SIZE;
-	struct page *page = find_get_page(mapping, index);
+	struct page *page;
+	loff_t i_size = i_size_read(wdata->header->inode);
+
+	if (offset >= i_size) {
+		if (!g_zero_page) {
+			g_zero_page = alloc_page(GFP_NOFS);
+			clear_highpage(g_zero_page);
+		}
+		*uptodate = true;
+		dprintk("%s: g_zero_page index=0x%lx\n", __func__, index);
+		return g_zero_page;
+	}
 
+	page = find_get_page(mapping, index);
 	if (!page) {
 		page = find_or_create_page(mapping, index, GFP_NOFS);
 		if (unlikely(!page)) {
@@ -507,8 +521,10 @@ static struct page *__r4w_get_page(void *priv, u64 offset, bool *uptodate)
 
 static void __r4w_put_page(void *priv, struct page *page)
 {
-	dprintk("%s: index=0x%lx\n", __func__, page->index);
-	page_cache_release(page);
+	dprintk("%s: index=0x%lx\n", __func__,
+		(page == g_zero_page) ? -1UL : page->index);
+	if (g_zero_page != page)
+		page_cache_release(page);
 	return;
 }
 
@@ -615,6 +631,8 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
 static void __exit
 objlayout_exit(void)
 {
+	if (g_zero_page)
+		__free_page(g_zero_page);
 	pnfs_unregister_layoutdriver(&objlayout_type);
 	printk(KERN_INFO "NFS: %s: Unregistered OSD pNFS Layout Driver\n",
 	       __func__);
-- 
1.7.10.2.677.gb6bc67f


