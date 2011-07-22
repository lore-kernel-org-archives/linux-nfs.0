Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:1493 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238Ab1GVNRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 09:17:41 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>,
        Mel Gorman <mel@csn.ul.ie>, Michel Lespinasse <walken@google.com>,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH 01/13] mm: Make some struct page's const.
Date: Fri, 22 Jul 2011 14:17:21 +0100
Message-ID: <1311340653-19336-1-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These uses are read-only and in a subsequent patch I have a const struct page
in my hand...

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/mm.h |   10 +++++-----
 mm/sparse.c        |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9670f71..550ec8f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -636,7 +636,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
-static inline enum zone_type page_zonenum(struct page *page)
+static inline enum zone_type page_zonenum(const struct page *page)
 {
 	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
 }
@@ -664,15 +664,15 @@ static inline int zone_to_nid(struct zone *zone)
 }
 
 #ifdef NODE_NOT_IN_PAGE_FLAGS
-extern int page_to_nid(struct page *page);
+extern int page_to_nid(const struct page *page);
 #else
-static inline int page_to_nid(struct page *page)
+static inline int page_to_nid(const struct page *page)
 {
 	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
 }
 #endif
 
-static inline struct zone *page_zone(struct page *page)
+static inline struct zone *page_zone(const struct page *page)
 {
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
 }
@@ -717,7 +717,7 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
  */
 #include <linux/vmstat.h>
 
-static __always_inline void *lowmem_page_address(struct page *page)
+static __always_inline void *lowmem_page_address(const struct page *page)
 {
 	return __va(PFN_PHYS(page_to_pfn(page)));
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index aa64b12..858e1df 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -40,7 +40,7 @@ static u8 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
 static u16 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
 #endif
 
-int page_to_nid(struct page *page)
+int page_to_nid(const struct page *page)
 {
 	return section_to_node_table[page_to_section(page)];
 }
-- 
1.7.2.5

