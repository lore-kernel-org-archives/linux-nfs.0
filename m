Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33490 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272Ab1JNRgZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 13:36:25 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Brent Welch <welch@panasas.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 5/6] pnfs-obj: Support for RAID5 read-4-write interface.
Date: Fri, 14 Oct 2011 19:36:16 +0200
Message-ID: <1318613776-3839-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E98703E.7040605@panasas.com>
References: <4E98703E.7040605@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The ore need suplied a r4w_get_page/r4w_put_page API
from Filesystem so it can get cache pages to read-into when
writing parial stripes.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/objio_osd.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 3161da6..c807ab9 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -459,6 +459,43 @@ static void _write_done(struct ore_io_state *ios, void *private)
 	objlayout_write_done(&objios->oir, status, objios->sync);
 }
 
+static struct page *__r4w_get_page(void *priv, u64 offset, bool *uptodate)
+{
+	struct objio_state *objios = priv;
+	struct nfs_write_data *wdata = objios->oir.rpcdata;
+	pgoff_t index = offset / PAGE_SIZE;
+	struct page *page = find_get_page(wdata->inode->i_mapping, index);
+
+	if (!page) {
+		page = find_or_create_page(wdata->inode->i_mapping,
+						index, GFP_NOFS);
+		if (unlikely(!page)) {
+			dprintk("%s: grab_cache_page Failed index=0x%lx\n",
+				__func__, index);
+			return NULL;
+		}
+		unlock_page(page);
+	}
+	if (PageDirty(page) || PageWriteback(page))
+		*uptodate = true;
+	else
+		*uptodate = PageUptodate(page);
+	dprintk("%s: index=0x%lx uptodate=%d\n", __func__, index, *uptodate);
+	return page;
+}
+
+static void __r4w_put_page(void *priv, struct page *page)
+{
+	dprintk("%s: index=0x%lx\n", __func__, page->index);
+	page_cache_release(page);
+	return;
+}
+
+static const struct _ore_r4w_op _r4w_op = {
+	.get_page = &__r4w_get_page,
+	.put_page = &__r4w_put_page,
+};
+
 int objio_write_pagelist(struct nfs_write_data *wdata, int how)
 {
 	struct objio_state *objios;
@@ -472,6 +509,7 @@ int objio_write_pagelist(struct nfs_write_data *wdata, int how)
 		return ret;
 
 	objios->sync = 0 != (how & FLUSH_SYNC);
+	objios->ios->r4w = &_r4w_op;
 
 	if (!objios->sync)
 		objios->ios->done = _write_done;
-- 
1.7.2.3

