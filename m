Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35366 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758649AbaDVV3K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:29:10 -0400
Received: by mail-ig0-f175.google.com with SMTP id h3so3551965igd.14
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:29:09 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 08/17] nfs: page group support in nfs_mark_uptodate
Date: Tue, 22 Apr 2014 17:29:16 -0400
Message-Id: <1398202165-78897-9-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-1-git-send-email-dros@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change how nfs_mark_uptodate checks to see if writes cover a whole page.

This patch should have no effect yet since all page groups currently
have one request, but will come into play when pg_test functions are
modified to split pages into sub-page regions.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/write.c | 74 ++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 67 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c6f6449..43892e0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -211,18 +211,78 @@ static void nfs_set_pageerror(struct page *page)
 	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
 }
 
+/*
+ * nfs_page_group_search_locked
+ * @head - head request of page group
+ * @page_offset - offset into page
+ *
+ * Search page group with head @head to find a request that contains the
+ * page offset @page_offset.
+ *
+ * Returns a pointer to the first matching nfs request, or NULL if no
+ * match is found.
+ *
+ * Must be called with the page group lock held
+ */
+static struct nfs_page *
+nfs_page_group_search_locked(struct nfs_page *head, unsigned int page_offset)
+{
+	struct nfs_page *req;
+
+	WARN_ON_ONCE(head != head->wb_head);
+	WARN_ON_ONCE(!test_bit(PG_HEADLOCK, &head->wb_head->wb_flags));
+
+	req = head;
+	do {
+		if (page_offset >= req->wb_pgbase &&
+		    page_offset < (req->wb_pgbase + req->wb_bytes))
+			return req;
+
+		req = req->wb_this_page;
+	} while (req != head);
+
+	return NULL;
+}
+
+/*
+ * nfs_page_group_covers_page
+ * @head - head request of page group
+ *
+ * Return true if the page group with head @head covers the whole page,
+ * returns false otherwise
+ */
+static bool nfs_page_group_covers_page(struct nfs_page *req)
+{
+	struct nfs_page *tmp;
+	unsigned int pos = 0;
+	unsigned int len = nfs_page_length(req->wb_page);
+
+	nfs_page_group_lock(req);
+
+	do {
+		tmp = nfs_page_group_search_locked(req->wb_head, pos);
+		if (tmp) {
+			/* no way this should happen */
+			WARN_ON_ONCE(tmp->wb_pgbase != pos);
+			pos += tmp->wb_bytes - (pos - tmp->wb_pgbase);
+		}
+	} while (tmp && pos < len);
+
+	nfs_page_group_unlock(req);
+	WARN_ON_ONCE(pos > len);
+	return pos == len;
+}
+
 /* We can set the PG_uptodate flag if we see that a write request
  * covers the full page.
  */
-static void nfs_mark_uptodate(struct page *page, unsigned int base, unsigned int count)
+static void nfs_mark_uptodate(struct nfs_page *req)
 {
-	if (PageUptodate(page))
-		return;
-	if (base != 0)
+	if (PageUptodate(req->wb_page))
 		return;
-	if (count != nfs_page_length(page))
+	if (!nfs_page_group_covers_page(req))
 		return;
-	SetPageUptodate(page);
+	SetPageUptodate(req->wb_page);
 }
 
 static int wb_priority(struct writeback_control *wbc)
@@ -854,7 +914,7 @@ static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
 		return PTR_ERR(req);
 	/* Update file length */
 	nfs_grow_file(page, offset, count);
-	nfs_mark_uptodate(page, req->wb_pgbase, req->wb_bytes);
+	nfs_mark_uptodate(req);
 	nfs_mark_request_dirty(req);
 	nfs_unlock_and_release_request(req);
 	return 0;
-- 
1.8.5.2 (Apple Git-48)

