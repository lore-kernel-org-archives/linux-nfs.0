Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33478 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272Ab1JNRgC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 13:36:02 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Brent Welch <welch@panasas.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 4/6] exofs: Support for RAID5 read-4-write interface.
Date: Fri, 14 Oct 2011 19:35:53 +0200
Message-ID: <1318613753-3808-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E98703E.7040605@panasas.com>
References: <4E98703E.7040605@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The ore need suplied a r4w_get_page/r4w_put_page API
from Filesystem so it can get cache pages to read-into when
writing parial stripes.

Also I commented out and NULLed the .writepage (singular)
vector. Because it gives terrible write pattern to raid
and is apparently not needed. Even in OOM conditions the
system copes (even better) with out it.

TODO: How to specify to write_cache_pages() to start
      or include a certain page?

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/inode.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 86c0ac8..3e5f3a6 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -63,6 +63,7 @@ struct page_collect {
 	bool read_4_write; /* This means two things: that the read is sync
 			    * And the pages should not be unlocked.
 			    */
+	struct page *that_locked_page;
 };
 
 static void _pcol_init(struct page_collect *pcol, unsigned expected_pages,
@@ -81,6 +82,7 @@ static void _pcol_init(struct page_collect *pcol, unsigned expected_pages,
 	pcol->length = 0;
 	pcol->pg_first = -1;
 	pcol->read_4_write = false;
+	pcol->that_locked_page = NULL;
 }
 
 static void _pcol_reset(struct page_collect *pcol)
@@ -93,6 +95,7 @@ static void _pcol_reset(struct page_collect *pcol)
 	pcol->length = 0;
 	pcol->pg_first = -1;
 	pcol->ios = NULL;
+	pcol->that_locked_page = NULL;
 
 	/* this is probably the end of the loop but in writes
 	 * it might not end here. don't be left with nothing
@@ -391,6 +394,8 @@ static int readpage_strip(void *data, struct page *page)
 		EXOFS_ERR("PageUptodate(0x%lx, 0x%lx)\n", pcol->inode->i_ino,
 			  page->index);
 
+	pcol->that_locked_page = page;
+
 	if (page->index < end_index)
 		len = PAGE_CACHE_SIZE;
 	else if (page->index == end_index)
@@ -560,6 +565,56 @@ static void writepages_done(struct ore_io_state *ios, void *p)
 	EXOFS_DBGMSG2("writepages_done END\n");
 }
 
+static struct page *__r4w_get_page(void *priv, u64 offset, bool *uptodate)
+{
+	struct page_collect *pcol = priv;
+	pgoff_t index = offset / PAGE_SIZE;
+
+	if (!pcol->that_locked_page ||
+	    (pcol->that_locked_page->index != index)) {
+		struct page *page = find_get_page(pcol->inode->i_mapping, index);
+
+		if (!page) {
+			page = find_or_create_page(pcol->inode->i_mapping,
+						   index, GFP_NOFS);
+			if (unlikely(!page)) {
+				EXOFS_DBGMSG("grab_cache_page Failed "
+					"index=0x%llx\n", _LLU(index));
+				return NULL;
+			}
+			unlock_page(page);
+		}
+		if (PageDirty(page) || PageWriteback(page))
+			*uptodate = true;
+		else
+			*uptodate = PageUptodate(page);
+		EXOFS_DBGMSG("index=0x%lx uptodate=%d\n", index, *uptodate);
+		return page;
+	} else {
+		EXOFS_DBGMSG("YES that_locked_page index=0x%lx\n",
+			     pcol->that_locked_page->index);
+		*uptodate = true;
+		return pcol->that_locked_page;
+	}
+}
+
+static void __r4w_put_page(void *priv, struct page *page)
+{
+	struct page_collect *pcol = priv;
+
+	if (pcol->that_locked_page != page) {
+		EXOFS_DBGMSG("index=0x%lx\n", page->index);
+		page_cache_release(page);
+		return;
+	}
+	EXOFS_DBGMSG("that_locked_page index=0x%lx\n", page->index);
+}
+
+static const struct _ore_r4w_op _r4w_op = {
+	.get_page = &__r4w_get_page,
+	.put_page = &__r4w_put_page,
+};
+
 static int write_exec(struct page_collect *pcol)
 {
 	struct exofs_i_info *oi = exofs_i(pcol->inode);
@@ -589,6 +644,7 @@ static int write_exec(struct page_collect *pcol)
 	ios = pcol->ios;
 	ios->pages = pcol_copy->pages;
 	ios->done = writepages_done;
+	ios->r4w = &_r4w_op;
 	ios->private = pcol_copy;
 
 	/* pages ownership was passed to pcol_copy */
@@ -773,6 +829,7 @@ static int exofs_writepages(struct address_space *mapping,
 	return 0;
 }
 
+/*
 static int exofs_writepage(struct page *page, struct writeback_control *wbc)
 {
 	struct page_collect pcol;
@@ -788,7 +845,7 @@ static int exofs_writepage(struct page *page, struct writeback_control *wbc)
 
 	return write_exec(&pcol);
 }
-
+*/
 /* i_mutex held using inode->i_size directly */
 static void _write_failed(struct inode *inode, loff_t to)
 {
@@ -894,7 +951,7 @@ static void exofs_invalidatepage(struct page *page, unsigned long offset)
 const struct address_space_operations exofs_aops = {
 	.readpage	= exofs_readpage,
 	.readpages	= exofs_readpages,
-	.writepage	= exofs_writepage,
+	.writepage	= NULL,
 	.writepages	= exofs_writepages,
 	.write_begin	= exofs_write_begin_export,
 	.write_end	= exofs_write_end,
-- 
1.7.2.3

