From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 04/30] mm: tag reseve pages
Date: Tue, 13 Jul 2010 06:17:36 -0400
Message-ID: <20100713101736.2835.76110.sendpatchset@danny.redhat>
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

>From 14f7823986429b8374d18e3f648cd84575296e03 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Mon, 12 Jul 2010 18:00:37 +0800
Subject: [PATCH 04/30] mm: tag reseve pages

Tag pages allocated from the reserves with a non-zero page->reserve.
This allows us to distinguish and account reserve pages.

Since low-memory situations are transient, and unrelated the the actual
page (any page can be on the freelist when we run low), don't mark the
page in any permanent way - just pass along the information to the
allocatee.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/linux/mm_types.h |    1 +
 mm/page_alloc.c          |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b8bb9a6..a95a202 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -71,6 +71,7 @@ struct page {
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
+		int reserve;		/* page_alloc: page is a reserve page */
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 72a6be5..b9989c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1656,8 +1656,10 @@ zonelist_scan:
 try_this_zone:
 		page = buffered_rmqueue(preferred_zone, zone, order,
 						gfp_mask, migratetype);
-		if (page)
+		if (page) {
+			page->reserve = !!(alloc_flags & ALLOC_NO_WATERMARKS);
 			break;
+		}
 this_zone_full:
 		if (NUMA_BUILD)
 			zlc_mark_zone_full(zonelist, z);
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
