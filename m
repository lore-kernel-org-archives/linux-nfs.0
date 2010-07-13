From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 23/30] mm: methods for teaching filesystems about PG_swapcache pages
Date: Tue, 13 Jul 2010 06:21:10 -0400
Message-ID: <20100713102110.2835.14816.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org,
        lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        davem@davemloft.net
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

>From 50e813068c51de733bbbdd04eb4af9c43919cd57 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 13:09:50 +0800
Subject: [PATCH 23/30]  mm: methods for teaching filesystems about PG_swapcache pages

In order to teach filesystems to handle swap cache pages, three new page
functions are introduced:

  pgoff_t page_file_index(struct page *);
  loff_t page_file_offset(struct page *);
  struct address_space *page_file_mapping(struct page *);

page_file_index() - gives the offset of this page in the file in
PAGE_CACHE_SIZE blocks. Like page->index is for mapped pages, this function
also gives the correct index for PG_swapcache pages.

page_file_offset() - uses page_file_index(), so that it will give the expected
result, even for PG_swapcache pages.

page_file_mapping() - gives the mapping backing the actual page; that is for
swap cache pages it will give swap_file->f_mapping.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/linux/mm.h      |   25 +++++++++++++++++++++++++
 include/linux/pagemap.h |    5 +++++
 mm/swapfile.c           |   19 +++++++++++++++++++
 3 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 32033ba..0cf97fc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -663,6 +663,17 @@ static inline void *page_rmapping(struct page *page)
 	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
 }
 
+extern struct address_space *__page_file_mapping(struct page *);
+
+static inline
+struct address_space *page_file_mapping(struct page *page)
+{
+	if (unlikely(PageSwapCache(page)))
+		return __page_file_mapping(page);
+
+	return page->mapping;
+}
+
 static inline int PageAnon(struct page *page)
 {
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
@@ -679,6 +690,20 @@ static inline pgoff_t page_index(struct page *page)
 	return page->index;
 }
 
+extern pgoff_t __page_file_index(struct page *page);
+
+/*
+ * Return the file index of the page. Regular pagecache pages use ->index
+ * whereas swapcache pages use swp_offset(->private)
+ */
+static inline pgoff_t page_file_index(struct page *page)
+{
+	if (unlikely(PageSwapCache(page)))
+		return __page_file_index(page);
+
+	return page->index;
+}
+
 /*
  * The atomic page->_mapcount, like _count, starts from -1:
  * so that transitions both from it and to it can be tracked,
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e12cdc6..64eda5b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -285,6 +285,11 @@ static inline loff_t page_offset(struct page *page)
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
 				     unsigned long address);
 
+static inline loff_t page_file_offset(struct page *page)
+{
+	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
+}
+
 static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 					unsigned long address)
 {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index a7baef1..d8a05e4 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2261,6 +2261,25 @@ struct swap_info_struct *page_swap_info(struct page *page)
 }
 
 /*
+ * out-of-line __page_file_ methods to avoid include hell.
+ */
+
+struct address_space *__page_file_mapping(struct page *page)
+{
+	VM_BUG_ON(!PageSwapCache(page));
+	return page_swap_info(page)->swap_file->f_mapping;
+}
+EXPORT_SYMBOL_GPL(__page_file_mapping);
+
+pgoff_t __page_file_index(struct page *page)
+{
+	swp_entry_t swap = { .val = page_private(page) };
+	VM_BUG_ON(!PageSwapCache(page));
+	return swp_offset(swap);
+}
+EXPORT_SYMBOL_GPL(__page_file_index);
+
+/*
  * swap_lock prevents swap_map being freed. Don't grab an extra
  * reference on the swaphandle, it doesn't matter if it becomes unused.
  */
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
