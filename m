Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:32675 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945Ab1GOLQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2011 07:16:50 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
CC: linux-nfs@vger.kernel.org, Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 01/10] mm: Make some struct page's const.
Date: Fri, 15 Jul 2011 12:07:02 +0100
Message-ID: <1310728031-19569-1-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
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

