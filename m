From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 05/30] mm: sl[au]b: add knowledge of reserve pages
Date: Tue, 13 Jul 2010 06:17:47 -0400
Message-ID: <20100713101747.2835.45722.sendpatchset@danny.redhat>
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

>From fba0bdebc34d3db41a2c975eb38e9548ea5c2ed1 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 10:40:05 +0800
Subject: [PATCH 05/30] mm: sl[au]b: add knowledge of reserve pages

Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
contexts that are entitled to it. This is done to ensure reserve pages don't
leak out and get consumed.

The basic pattern used for all # allocators is the following, for each active
slab page we store if it came from an emergency allocation. When we find it
did, make sure the current allocation context would have been able to allocate
page from the emergency reserves as well. In that case allow the allocation. If
not, force a new slab allocation. When that works the memory pressure has
lifted enough to allow this context to get an object, otherwise fail the
allocation.

[mszeredi@suse.cz: Fix use of uninitialized variable in cache_grow]
[dfeng@redhat.com: Minor fix related with SLABDEBUG]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/linux/slub_def.h |    1 +
 mm/slab.c                |   62 +++++++++++++++++++++++++++++++++++++++------
 mm/slob.c                |   16 +++++++++++-
 mm/slub.c                |   42 ++++++++++++++++++++++++++-----
 4 files changed, 104 insertions(+), 17 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 6447a72..9ef61f4 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -39,6 +39,7 @@ struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to first free per cpu object */
 	struct page *page;	/* The slab from which we are allocating */
 	int node;		/* The node of the page (or -1 for debug) */
+	int reserve;		/* Did the current page come from the reserve */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
diff --git a/mm/slab.c b/mm/slab.c
index 4e9c46f..d8cd757 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -120,6 +120,8 @@
 #include	<asm/tlbflush.h>
 #include	<asm/page.h>
 
+#include 	"internal.h"
+
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_RED_ZONE & SLAB_POISON.
  *		  0 for faster, smaller code (especially in the critical paths).
@@ -244,7 +246,8 @@ struct array_cache {
 	unsigned int avail;
 	unsigned int limit;
 	unsigned int batchcount;
-	unsigned int touched;
+	unsigned int touched:1,
+		     reserve:1;
 	spinlock_t lock;
 	void *entry[];	/*
 			 * Must have this definition in here for the proper
@@ -680,6 +683,27 @@ static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
 	return cachep->array[smp_processor_id()];
 }
 
+/*
+ * If the last page came from the reserves, and the current allocation context
+ * does not have access to them, force an allocation to test the watermarks.
+ */
+static inline int slab_force_alloc(struct kmem_cache *cachep, gfp_t flags)
+{
+	if (unlikely(cpu_cache_get(cachep)->reserve) &&
+			!(gfp_to_alloc_flags(flags) & ALLOC_NO_WATERMARKS))
+		return 1;
+
+	return 0;
+}
+
+static inline void slab_set_reserve(struct kmem_cache *cachep, int reserve)
+{
+	struct array_cache *ac = cpu_cache_get(cachep);
+
+	if (unlikely(ac->reserve != reserve))
+		ac->reserve = reserve;
+}
+
 static inline struct kmem_cache *__find_general_cachep(size_t size,
 							gfp_t gfpflags)
 {
@@ -886,6 +910,7 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 		nc->limit = entries;
 		nc->batchcount = batchcount;
 		nc->touched = 0;
+		nc->reserve = 0;
 		spin_lock_init(&nc->lock);
 	}
 	return nc;
@@ -1674,7 +1699,8 @@ __initcall(cpucache_init);
  * did not request dmaable memory, we might get it, but that
  * would be relatively rare and ignorable.
  */
-static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid,
+		int *reserve)
 {
 	struct page *page;
 	int nr_pages;
@@ -1696,6 +1722,7 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	if (!page)
 		return NULL;
 
+	*reserve = page->reserve;
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -2128,6 +2155,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 	cpu_cache_get(cachep)->limit = BOOT_CPUCACHE_ENTRIES;
 	cpu_cache_get(cachep)->batchcount = 1;
 	cpu_cache_get(cachep)->touched = 0;
+	cpu_cache_get(cachep)->reserve = 0;
 	cachep->batchcount = 1;
 	cachep->limit = BOOT_CPUCACHE_ENTRIES;
 	return 0;
@@ -2813,6 +2841,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	size_t offset;
 	gfp_t local_flags;
 	struct kmem_list3 *l3;
+	int reserve = -1;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -2851,7 +2880,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	 * 'nodeid'.
 	 */
 	if (!objp)
-		objp = kmem_getpages(cachep, local_flags, nodeid);
+		objp = kmem_getpages(cachep, local_flags, nodeid, &reserve);
 	if (!objp)
 		goto failed;
 
@@ -2868,6 +2897,8 @@ static int cache_grow(struct kmem_cache *cachep,
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
 	check_irq_off();
+	if (reserve != -1)
+		slab_set_reserve(cachep, reserve);
 	spin_lock(&l3->list_lock);
 
 	/* Make slab active. */
@@ -3002,7 +3033,8 @@ bad:
 #define check_slabp(x,y) do { } while(0)
 #endif
 
-static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
+static void *cache_alloc_refill(struct kmem_cache *cachep,
+		gfp_t flags, int must_refill)
 {
 	int batchcount;
 	struct kmem_list3 *l3;
@@ -3012,6 +3044,8 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 retry:
 	check_irq_off();
 	node = numa_mem_id();
+	if (unlikely(must_refill))
+		goto force_grow;
 	ac = cpu_cache_get(cachep);
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
@@ -3081,11 +3115,14 @@ alloc_done:
 
 	if (unlikely(!ac->avail)) {
 		int x;
+force_grow:
 		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = cpu_cache_get(cachep);
-		if (!x && ac->avail == 0)	/* no objects in sight? abort */
+
+		/* no objects in sight? abort */
+		if (!x && (ac->avail == 0 || must_refill))
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
@@ -3175,17 +3212,18 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *objp;
 	struct array_cache *ac;
+	int must_refill = slab_force_alloc(cachep, flags);
 
 	check_irq_off();
 
 	ac = cpu_cache_get(cachep);
-	if (likely(ac->avail)) {
+	if (likely(ac->avail && !must_refill)) {
 		STATS_INC_ALLOCHIT(cachep);
 		ac->touched = 1;
 		objp = ac->entry[--ac->avail];
 	} else {
 		STATS_INC_ALLOCMISS(cachep);
-		objp = cache_alloc_refill(cachep, flags);
+		objp = cache_alloc_refill(cachep, flags, must_refill);
 		/*
 		 * the 'ac' may be updated by cache_alloc_refill(),
 		 * and kmemleak_erase() requires its correct value.
@@ -3243,7 +3281,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
-	int nid;
+	int nid, reserve;
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
@@ -3280,10 +3318,12 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, local_flags, numa_mem_id());
+		obj = kmem_getpages(cache, local_flags, numa_mem_id(),
+				    &reserve);
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {
+			slab_set_reserve(cache, reserve);
 			/*
 			 * Insert into the appropriate per node queues
 			 */
@@ -3323,6 +3363,9 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 	l3 = cachep->nodelists[nodeid];
 	BUG_ON(!l3);
 
+	if (unlikely(slab_force_alloc(cachep, flags)))
+		goto force_grow;
+
 retry:
 	check_irq_off();
 	spin_lock(&l3->list_lock);
@@ -3360,6 +3403,7 @@ retry:
 
 must_grow:
 	spin_unlock(&l3->list_lock);
+force_grow:
 	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL);
 	if (x)
 		goto retry;
diff --git a/mm/slob.c b/mm/slob.c
index 3f19a34..b84b611 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -71,6 +71,7 @@
 #include <trace/events/kmem.h>
 
 #include <asm/atomic.h>
+#include "internal.h"
 
 /*
  * slob_block has a field 'units', which indicates size of block if +ve,
@@ -193,6 +194,11 @@ struct slob_rcu {
 static DEFINE_SPINLOCK(slob_lock);
 
 /*
+ * tracks the reserve state for the allocator.
+ */
+static int slob_reserve;
+
+/*
  * Encode the given size and next info into a free slob block s.
  */
 static void set_slob(slob_t *s, slobidx_t size, slob_t *next)
@@ -242,7 +248,7 @@ static int slob_last(slob_t *s)
 
 static void *slob_new_pages(gfp_t gfp, int order, int node)
 {
-	void *page;
+	struct page *page;
 
 #ifdef CONFIG_NUMA
 	if (node != -1)
@@ -254,6 +260,8 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 	if (!page)
 		return NULL;
 
+	slob_reserve = page->reserve;
+
 	return page_address(page);
 }
 
@@ -326,6 +334,11 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 	slob_t *b = NULL;
 	unsigned long flags;
 
+	if (unlikely(slob_reserve)) {
+		if (!(gfp_to_alloc_flags(gfp) & ALLOC_NO_WATERMARKS))
+			goto grow;
+	}
+
 	if (size < SLOB_BREAK1)
 		slob_list = &free_slob_small;
 	else if (size < SLOB_BREAK2)
@@ -364,6 +377,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 	}
 	spin_unlock_irqrestore(&slob_lock, flags);
 
+grow:
 	/* Not enough space: must allocate a new page */
 	if (!b) {
 		b = slob_new_pages(gfp & ~__GFP_ZERO, 0, node);
diff --git a/mm/slub.c b/mm/slub.c
index 7bb7940..7a5d6dc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -27,6 +27,8 @@
 #include <linux/memory.h>
 #include <linux/math64.h>
 #include <linux/fault-inject.h>
+#include "internal.h"
+
 
 /*
  * Lock order:
@@ -1139,7 +1141,8 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 		s->ctor(object);
 }
 
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static
+struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *reserve)
 {
 	struct page *page;
 	void *start;
@@ -1153,6 +1156,8 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (!page)
 		goto out;
 
+	*reserve = page->reserve;
+
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
@@ -1606,10 +1611,20 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 {
 	void **object;
 	struct page *new;
+	int reserve;
 
 	/* We handle __GFP_ZERO in the caller */
 	gfpflags &= ~__GFP_ZERO;
 
+	if (unlikely(c->reserve)) {
+		/*
+		 * If the current slab is a reserve slab and the current
+		 * allocation context does not allow access to the reserves we
+		 * must force an allocation to test the current levels.
+		 */
+		if (!(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
+			goto grow_slab;
+	}
 	if (!c->page)
 		goto new_slab;
 
@@ -1623,8 +1638,8 @@ load_freelist:
 	object = c->page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
-		goto debug;
+	if (unlikely(SLABDEBUG && PageSlubDebug(c->page) || c->reserve))
+		goto slow_path;
 
 	c->freelist = get_freepointer(s, object);
 	c->page->inuse = c->page->objects;
@@ -1646,16 +1661,18 @@ new_slab:
 		goto load_freelist;
 	}
 
+grow_slab:
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
-	new = new_slab(s, gfpflags, node);
+	new = new_slab(s, gfpflags, node, &reserve);
 
 	if (gfpflags & __GFP_WAIT)
 		local_irq_disable();
 
 	if (new) {
 		c = __this_cpu_ptr(s->cpu_slab);
+		c->reserve = reserve;
 		stat(s, ALLOC_SLAB);
 		if (c->page)
 			flush_slab(s, c);
@@ -1667,10 +1684,20 @@ new_slab:
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);
 	return NULL;
-debug:
-	if (!alloc_debug_processing(s, c->page, object, addr))
+
+slow_path:
+	if (!c->reserve && !alloc_debug_processing(s, c->page, object, addr))
 		goto another_slab;
 
+	/*
+	 * Avoid the slub fast path in slab_alloc() by not setting
+	 * c->freelist and the fast path in slab_free() by making
+	 * node_match() fail by setting c->node to -1.
+	 *
+	 * We use this for for debug and reserve checks which need
+	 * to be done for each allocation.
+	 */
+
 	c->page->inuse++;
 	c->page->freelist = get_freepointer(s, object);
 	c->node = -1;
@@ -2095,10 +2122,11 @@ static void early_kmem_cache_node_alloc(gfp_t gfpflags, int node)
 	struct page *page;
 	struct kmem_cache_node *n;
 	unsigned long flags;
+	int reserve;
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags, node);
+	page = new_slab(kmalloc_caches, gfpflags, node, &reserve);
 
 	BUG_ON(!page);
 	if (page_to_nid(page) != node) {
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
