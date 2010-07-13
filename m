From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 06/30] mm: kmem_alloc_estimate()
Date: Tue, 13 Jul 2010 06:17:59 -0400
Message-ID: <20100713101758.2835.26517.sendpatchset@danny.redhat>
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

>From 4a2dff5cf02e9d7f6ee9345c337697c4ab66c6dc Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 10:41:22 +0800
Subject: [PATCH 06/30] mm: kmem_alloc_estimate()

Provide a method to get the upper bound on the pages needed to allocate
a given number of objects from a given kmem_cache.

This lays the foundation for a generic reserve framework as presented in
a later patch in this series. This framework needs to convert object demand
(kmalloc() bytes, kmem_cache_alloc() objects) to pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/linux/slab.h |    4 ++
 mm/slab.c            |   75 +++++++++++++++++++++++++++++++++++++++++++
 mm/slob.c            |   67 ++++++++++++++++++++++++++++++++++++++
 mm/slub.c            |   87 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 233 insertions(+), 0 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 49d1247..b57b9ca 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -108,6 +108,8 @@ unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kern_ptr_validate(const void *ptr, unsigned long size);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+unsigned kmem_alloc_estimate(struct kmem_cache *cachep,
+			gfp_t flags, int objects);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -144,6 +146,8 @@ void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 void kzfree(const void *);
 size_t ksize(const void *);
+unsigned kmalloc_estimate_objs(size_t, gfp_t, int);
+unsigned kmalloc_estimate_bytes(gfp_t, size_t);
 
 /*
  * Allocator specific definitions. These are mainly used to establish optimized
diff --git a/mm/slab.c b/mm/slab.c
index d8cd757..2a0dd0d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3913,6 +3913,81 @@ const char *kmem_cache_name(struct kmem_cache *cachep)
 EXPORT_SYMBOL_GPL(kmem_cache_name);
 
 /*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @objects objects from @cachep.
+ */
+unsigned kmem_alloc_estimate(struct kmem_cache *cachep,
+		gfp_t flags, int objects)
+{
+	/*
+	 * (1) memory for objects,
+	 */
+	unsigned nr_slabs = DIV_ROUND_UP(objects, cachep->num);
+	unsigned nr_pages = nr_slabs << cachep->gfporder;
+
+	/*
+	 * (2) memory for each per-cpu queue (nr_cpu_ids),
+	 * (3) memory for each per-node alien queues (nr_cpu_ids), and
+	 * (4) some amount of memory for the slab management structures
+	 *
+	 * XXX: truely account these
+	 */
+	nr_pages += 1 + ilog2(nr_pages);
+
+	return nr_pages;
+}
+
+/*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @count objects of @size bytes from kmalloc given @flags.
+ */
+unsigned kmalloc_estimate_objs(size_t size, gfp_t flags, int count)
+{
+	struct kmem_cache *s = kmem_find_general_cachep(size, flags);
+	if (!s)
+		return 0;
+
+	return kmem_alloc_estimate(s, flags, count);
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_objs);
+
+/*
+ * Calculate the upper bound of pages requires to sequentially allocate @bytes
+ * from kmalloc in an unspecified number of allocations of nonuniform size.
+ */
+unsigned kmalloc_estimate_bytes(gfp_t flags, size_t bytes)
+{
+	unsigned long pages;
+	struct cache_sizes *csizep = malloc_sizes;
+
+	/*
+	 * multiply by two, in order to account the worst case slack space
+	 * due to the power-of-two allocation sizes.
+	 */
+	pages = DIV_ROUND_UP(2 * bytes, PAGE_SIZE);
+
+	/*
+	 * add the kmem_cache overhead of each possible kmalloc cache
+	 */
+	for (csizep = malloc_sizes; csizep->cs_cachep; csizep++) {
+		struct kmem_cache *s;
+
+#ifdef CONFIG_ZONE_DMA
+		if (unlikely(flags & __GFP_DMA))
+			s = csizep->cs_dmacachep;
+		else
+#endif
+			s = csizep->cs_cachep;
+
+		if (s)
+			pages += kmem_alloc_estimate(s, flags, 0);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_bytes);
+
+/*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
 static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
diff --git a/mm/slob.c b/mm/slob.c
index b84b611..0caf938 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -695,6 +695,73 @@ int slab_is_available(void)
 	return slob_ready;
 }
 
+static __slob_estimate(unsigned size, unsigned align, unsigned objects)
+{
+	unsigned nr_pages;
+
+	size = SLOB_UNIT * SLOB_UNITS(size + align - 1);
+
+	if (size <= PAGE_SIZE) {
+		nr_pages = DIV_ROUND_UP(objects, PAGE_SIZE / size);
+	} else {
+		nr_pages = objects << get_order(size);
+	}
+
+	return nr_pages;
+}
+
+/*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @objects objects from @cachep.
+ */
+unsigned kmem_alloc_estimate(struct kmem_cache *c, gfp_t flags, int objects)
+{
+	unsigned size = c->size;
+
+	if (c->flags & SLAB_DESTROY_BY_RCU)
+		size += sizeof(struct slob_rcu);
+
+	return __slob_estimate(size, c->align, objects);
+}
+
+/*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @count objects of @size bytes from kmalloc given @flags.
+ */
+unsigned kmalloc_estimate_objs(size_t size, gfp_t flags, int count)
+{
+	unsigned align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+
+	return __slob_estimate(size, align, count);
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_objs);
+
+/*
+ * Calculate the upper bound of pages requires to sequentially allocate @bytes
+ * from kmalloc in an unspecified number of allocations of nonuniform size.
+ */
+unsigned kmalloc_estimate_bytes(gfp_t flags, size_t bytes)
+{
+	unsigned long pages;
+
+	/*
+	 * Multiply by two, in order to account the worst case slack space
+	 * due to the power-of-two allocation sizes.
+	 *
+	 * While not true for slob, it cannot do worse than that for sequential
+	 * allocations.
+	 */
+	pages = DIV_ROUND_UP(2 * bytes, PAGE_SIZE);
+
+	/*
+	 * Our power of two series starts at PAGE_SIZE, so add one page.
+	 */
+	pages++;
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_bytes);
+
 void __init kmem_cache_init(void)
 {
 	slob_ready = 1;
diff --git a/mm/slub.c b/mm/slub.c
index 7a5d6dc..056545e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2435,6 +2435,42 @@ const char *kmem_cache_name(struct kmem_cache *s)
 }
 EXPORT_SYMBOL(kmem_cache_name);
 
+/*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @objects objects from @cachep.
+ *
+ * We should use s->min_objects because those are the least efficient.
+ */
+unsigned kmem_alloc_estimate(struct kmem_cache *s, gfp_t flags, int objects)
+{
+	unsigned long pages;
+	struct kmem_cache_order_objects x;
+
+	if (WARN_ON(!s) || WARN_ON(!oo_objects(s->min)))
+		return 0;
+
+	x = s->min;
+	pages = DIV_ROUND_UP(objects, oo_objects(x)) << oo_order(x);
+
+	/*
+	 * Account the possible additional overhead if the slab holds more that
+	 * one object. Use s->max_objects because that's the worst case.
+	 */
+	x = s->oo;
+	if (oo_objects(x) > 1) {
+		/*
+		 * Account the possible additional overhead if per cpu slabs
+		 * are currently empty and have to be allocated. This is very
+		 * unlikely but a possible scenario immediately after
+		 * kmem_cache_shrink.
+		 */
+		pages += num_possible_cpus() << oo_order(x);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kmem_alloc_estimate);
+
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
 							const char *text)
 {
@@ -2868,6 +2904,57 @@ void kfree(const void *x)
 EXPORT_SYMBOL(kfree);
 
 /*
+ * Calculate the upper bound of pages required to sequentially allocate
+ * @count objects of @size bytes from kmalloc given @flags.
+ */
+unsigned kmalloc_estimate_objs(size_t size, gfp_t flags, int count)
+{
+	struct kmem_cache *s = get_slab(size, flags);
+	if (!s)
+		return 0;
+
+	return kmem_alloc_estimate(s, flags, count);
+
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_objs);
+
+/*
+ * Calculate the upper bound of pages requires to sequentially allocate @bytes
+ * from kmalloc in an unspecified number of allocations of nonuniform size.
+ */
+unsigned kmalloc_estimate_bytes(gfp_t flags, size_t bytes)
+{
+	int i;
+	unsigned long pages;
+
+	/*
+	 * multiply by two, in order to account the worst case slack space
+	 * due to the power-of-two allocation sizes.
+	 */
+	pages = DIV_ROUND_UP(2 * bytes, PAGE_SIZE);
+
+	/*
+	 * add the kmem_cache overhead of each possible kmalloc cache
+	 */
+	for (i = 1; i < PAGE_SHIFT; i++) {
+		struct kmem_cache *s;
+
+#ifdef CONFIG_ZONE_DMA
+		if (unlikely(flags & SLUB_DMA))
+			s = dma_kmalloc_cache(i, flags);
+		else
+#endif
+			s = &kmalloc_caches[i];
+
+		if (s)
+			pages += kmem_alloc_estimate(s, flags, 0);
+	}
+
+	return pages;
+}
+EXPORT_SYMBOL_GPL(kmalloc_estimate_bytes);
+
+/*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
  * most items in use come first. New allocations will then fill those up
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
