Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38603 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755052Ab1I2OrO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 10:47:14 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 03/13] FS-Cache: Validate page mapping pointer value
To: moseleymark@gmail.com, mark@pogo.org.uk, jlayton@redhat.com,
        steved@redhat.com
Cc: linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2011 15:46:13 +0100
Message-ID: <20110929144613.5812.97149.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
References: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add information to indicate whether page->mapping should have a value or not,
and to log a warning if it is wrong.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/rdwr.c          |   26 +++++++++++++++++---------
 fs/fscache/page.c             |   36 +++++++++++++++++++++++++++++++++---
 include/linux/fscache-cache.h |    6 ++++--
 3 files changed, 54 insertions(+), 14 deletions(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 0186fc1..e8c3766 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -177,7 +177,7 @@ static void cachefiles_read_copier(struct fscache_operation *_op)
 		if (PageUptodate(monitor->back_page)) {
 			copy_highpage(monitor->netfs_page, monitor->back_page);
 			fscache_mark_page_cached(monitor->op,
-						 monitor->netfs_page);
+						 monitor->netfs_page, true);
 			error = 0;
 		} else if (!PageError(monitor->back_page)) {
 			/* the page has probably been truncated */
@@ -334,7 +334,7 @@ backing_page_already_present:
 backing_page_already_uptodate:
 	_debug("- uptodate");
 
-	fscache_mark_page_cached(op, netpage);
+	fscache_mark_page_cached(op, netpage, true);
 
 	copy_highpage(netpage, backpage);
 	fscache_end_io(op, netpage, 0);
@@ -446,7 +446,7 @@ int cachefiles_read_or_alloc_page(struct fscache_retrieval *op,
 						       &pagevec);
 	} else if (cachefiles_has_space(cache, 0, 1) == 0) {
 		/* there's space in the cache we can use */
-		fscache_mark_page_cached(op, page);
+		fscache_mark_page_cached(op, page, true);
 		ret = -ENODATA;
 	} else {
 		ret = -ENOBUFS;
@@ -622,7 +622,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		page_cache_release(backpage);
 		backpage = NULL;
 
-		fscache_mark_page_cached(op, netpage);
+		fscache_mark_page_cached(op, netpage, true);
 
 		page_cache_get(netpage);
 		if (!pagevec_add(&lru_pvec, netpage))
@@ -704,6 +704,14 @@ int cachefiles_read_or_alloc_pages(struct fscache_retrieval *op,
 	       object->fscache.debug_id, atomic_read(&op->op.usage),
 	       *nr_pages);
 
+	{
+		struct page *q, *_q;
+		list_for_each_entry_safe(q, _q, pages, lru) {
+			ASSERT(!q->mapping);
+			ASSERT(!PageFsCache(q));
+		}
+	}
+
 	if (!object->backer)
 		return -ENOBUFS;
 
@@ -757,13 +765,13 @@ int cachefiles_read_or_alloc_pages(struct fscache_retrieval *op,
 			(*nr_pages)--;
 			nrbackpages++;
 		} else if (space && pagevec_add(&pagevec, page) == 0) {
-			fscache_mark_pages_cached(op, &pagevec);
+			fscache_mark_pages_cached(op, &pagevec, false);
 			ret = -ENODATA;
 		}
 	}
 
 	if (pagevec_count(&pagevec) > 0)
-		fscache_mark_pages_cached(op, &pagevec);
+		fscache_mark_pages_cached(op, &pagevec, false);
 
 	if (list_empty(pages))
 		ret = 0;
@@ -809,7 +817,7 @@ int cachefiles_allocate_page(struct fscache_retrieval *op,
 
 	ret = cachefiles_has_space(cache, 0, 1);
 	if (ret == 0)
-		fscache_mark_page_cached(op, page);
+		fscache_mark_page_cached(op, page, true);
 	else
 		ret = -ENOBUFS;
 
@@ -852,11 +860,11 @@ int cachefiles_allocate_pages(struct fscache_retrieval *op,
 
 		list_for_each_entry(page, pages, lru) {
 			if (pagevec_add(&pagevec, page) == 0)
-				fscache_mark_pages_cached(op, &pagevec);
+				fscache_mark_pages_cached(op, &pagevec, false);
 		}
 
 		if (pagevec_count(&pagevec) > 0)
-			fscache_mark_pages_cached(op, &pagevec);
+			fscache_mark_pages_cached(op, &pagevec, false);
 		ret = -ENODATA;
 	} else {
 		ret = -ENOBUFS;
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index d7c663c..5e793b5 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -918,11 +918,13 @@ EXPORT_SYMBOL(__fscache_uncache_page);
  * fscache_mark_page_cached - Mark a page as being cached
  * @op: The retrieval op pages are being marked for
  * @page: The page to be marked
+ * @should_have_mapping: True if the pages should have a mapping set
  *
  * Mark a netfs page as being cached.  After this is called, the netfs
  * must call fscache_uncache_page() to remove the mark.
  */
-void fscache_mark_page_cached(struct fscache_retrieval *op, struct page *page)
+void fscache_mark_page_cached(struct fscache_retrieval *op, struct page *page,
+			      bool should_have_mapping)
 {
 	struct fscache_cookie *cookie = op->op.object->cookie;
 
@@ -941,6 +943,31 @@ void fscache_mark_page_cached(struct fscache_retrieval *op, struct page *page)
 			       cookie->def->name, page->index);
 		}
 	}
+	if (should_have_mapping && !page->mapping) {
+		static bool once_only;
+		if (!once_only) {
+			once_only = 1;
+			printk(KERN_ALERT
+			       "FSC: page:%p count:%d mapcount:%d NO_MAPPING"
+			       " index:%#lx\n",
+			       page, page_count(page), page_mapcount(page),
+			       page->index);
+			WARN_ON(1);
+		}
+	}
+
+	if (!should_have_mapping && page->mapping) {
+		static bool once_only;
+		if (!once_only) {
+			once_only = 1;
+			printk(KERN_ALERT
+			       "FSC: page:%p count:%d mapcount:%d MAPPING:%p"
+			       " index:%#lx\n",
+			       page, page_count(page), page_mapcount(page),
+			       page->mapping, page->index);
+			WARN_ON(1);
+		}
+	}
 
 	if (cookie->def->mark_page_cached)
 		cookie->def->mark_page_cached(cookie->netfs_data,
@@ -952,17 +979,20 @@ EXPORT_SYMBOL(fscache_mark_page_cached);
  * fscache_mark_pages_cached - Mark pages as being cached
  * @op: The retrieval op pages are being marked for
  * @pagevec: The pages to be marked
+ * @should_have_mapping: True if the pages should have a mapping set
  *
  * Mark a bunch of netfs pages as being cached.  After this is called,
  * the netfs must call fscache_uncache_page() to remove the mark.
  */
 void fscache_mark_pages_cached(struct fscache_retrieval *op,
-			       struct pagevec *pagevec)
+			       struct pagevec *pagevec,
+			       bool should_have_mapping)
 {
 	unsigned long loop;
 
 	for (loop = 0; loop < pagevec->nr; loop++)
-		fscache_mark_page_cached(op, pagevec->pages[loop]);
+		fscache_mark_page_cached(op, pagevec->pages[loop],
+					 should_have_mapping);
 
 	pagevec_reinit(pagevec);
 }
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 485c011..ae155f1 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -505,10 +505,12 @@ extern void fscache_withdraw_cache(struct fscache_cache *cache);
 extern void fscache_io_error(struct fscache_cache *cache);
 
 extern void fscache_mark_page_cached(struct fscache_retrieval *op,
-				     struct page *page);
+				     struct page *page,
+				     bool should_have_mapping);
 
 extern void fscache_mark_pages_cached(struct fscache_retrieval *op,
-				      struct pagevec *pagevec);
+				      struct pagevec *pagevec,
+				      bool should_have_mapping);
 
 extern bool fscache_object_sleep_till_congested(signed long *timeoutp);
 

