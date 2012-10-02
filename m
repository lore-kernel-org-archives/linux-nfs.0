Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e1.ny.us.ibm.com ([32.97.182.141]:38471 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547Ab2JBWRs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 18:17:48 -0400
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 2 Oct 2012 18:17:47 -0400
Date: Tue, 2 Oct 2012 15:17:36 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
To: Alexander Graf <agraf@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, anton@samba.org,
        skinsbursky@parallels.com, bfields@redhat.com,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: Re: [REGRESSION] nfsd crashing with 3.6.0-rc7 on PowerPC
Message-ID: <20121002221736.GB29218@linux.vnet.ibm.com>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de>
 <CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
 <DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de>
 <20120928151043.GA19102@fieldses.org>
 <2A52FC96-148C-4F7A-9950-E152E0C6698D@suse.de>
 <1349139509.3847.2.camel@pasglop>
 <20121002214327.GA29218@linux.vnet.ibm.com>
 <9257E705-4EF9-4347-945C-B4A7582C427F@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9257E705-4EF9-4347-945C-B4A7582C427F@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02.10.2012 [23:47:39 +0200], Alexander Graf wrote:
> 
> On 02.10.2012, at 23:43, Nishanth Aravamudan wrote:
> 
> > Hi Ben,
> > 
> > On 02.10.2012 [10:58:29 +1000], Benjamin Herrenschmidt wrote:
> >> On Mon, 2012-10-01 at 16:03 +0200, Alexander Graf wrote:
> >>> Phew. Here we go :). It looks to be more of a PPC specific problem
> >>> than it appeared as at first:
> >> 
> >> Ok, so I suspect the problem is the pushing down of the locks which
> >> breaks with iommu backends that have a separate flush callback. In
> >> that case, the flush moves out of the allocator lock.
> >> 
> >> Now we do call flush before we return, still, but it becomes racy
> >> I suspect, but somebody needs to give it a closer look. I'm hoping
> >> Anton or Nish will later today.
> > 
> > Started looking into this. If your suspicion were accurate, wouldn't the
> > bisection have stopped at 0e4bc95d87394364f408627067238453830bdbf3
> > ("powerpc/iommu: Reduce spinlock coverage in iommu_alloc and
> > iommu_free")?
> > 
> > Alex, the error is reproducible, right?
> 
> Yes. I'm having a hard time to figure out if the reason my U4 based G5
> Mac crashes and fails reading data is the same since I don't have a
> serial connection there, but I assume so.

Ok, great, thanks. Yeah, that would imply (I think) that the I would
have thought the lock pushdown in the above commit (or even in one of
the others in Anton's series) would have been the real source if it was
a lock-based race. But that's just my first sniff at what Ben was
suggesting. Still reading/understanding the code.

> > Does it go away by reverting
> > that commit against mainline? Just trying to narrow down my focus.
> 
> The patch doesn't revert that easily. Mind to provide a revert patch
> so I can try?

The following at least builds on defconfig here:

diff --git a/arch/powerpc/include/asm/iommu.h b/arch/powerpc/include/asm/iommu.h
index cbfe678..957a83f 100644
--- a/arch/powerpc/include/asm/iommu.h
+++ b/arch/powerpc/include/asm/iommu.h
@@ -53,16 +53,6 @@ static __inline__ __attribute_const__ int get_iommu_order(unsigned long size)
  */
 #define IOMAP_MAX_ORDER		13
 
-#define IOMMU_POOL_HASHBITS	2
-#define IOMMU_NR_POOLS		(1 << IOMMU_POOL_HASHBITS)
-
-struct iommu_pool {
-	unsigned long start;
-	unsigned long end;
-	unsigned long hint;
-	spinlock_t lock;
-} ____cacheline_aligned_in_smp;
-
 struct iommu_table {
 	unsigned long  it_busno;     /* Bus number this table belongs to */
 	unsigned long  it_size;      /* Size of iommu table in entries */
@@ -71,10 +61,10 @@ struct iommu_table {
 	unsigned long  it_index;     /* which iommu table this is */
 	unsigned long  it_type;      /* type: PCI or Virtual Bus */
 	unsigned long  it_blocksize; /* Entries in each block (cacheline) */
-	unsigned long  poolsize;
-	unsigned long  nr_pools;
-	struct iommu_pool large_pool;
-	struct iommu_pool pools[IOMMU_NR_POOLS];
+	unsigned long  it_hint;      /* Hint for next alloc */
+	unsigned long  it_largehint; /* Hint for large allocs */
+	unsigned long  it_halfpoint; /* Breaking point for small/large allocs */
+	spinlock_t     it_lock;      /* Protects it_map */
 	unsigned long *it_map;       /* A simple allocation bitmap for now */
 };
 
diff --git a/arch/powerpc/kernel/iommu.c b/arch/powerpc/kernel/iommu.c
index ff5a6ce..9a31f3c 100644
--- a/arch/powerpc/kernel/iommu.c
+++ b/arch/powerpc/kernel/iommu.c
@@ -62,26 +62,6 @@ static int __init setup_iommu(char *str)
 
 __setup("iommu=", setup_iommu);
 
-static DEFINE_PER_CPU(unsigned int, iommu_pool_hash);
-
-/*
- * We precalculate the hash to avoid doing it on every allocation.
- *
- * The hash is important to spread CPUs across all the pools. For example,
- * on a POWER7 with 4 way SMT we want interrupts on the primary threads and
- * with 4 pools all primary threads would map to the same pool.
- */
-static int __init setup_iommu_pool_hash(void)
-{
-	unsigned int i;
-
-	for_each_possible_cpu(i)
-		per_cpu(iommu_pool_hash, i) = hash_32(i, IOMMU_POOL_HASHBITS);
-
-	return 0;
-}
-subsys_initcall(setup_iommu_pool_hash);
-
 #ifdef CONFIG_FAIL_IOMMU
 
 static DECLARE_FAULT_ATTR(fail_iommu);
@@ -184,8 +164,6 @@ static unsigned long iommu_range_alloc(struct device *dev,
 	unsigned long align_mask;
 	unsigned long boundary_size;
 	unsigned long flags;
-	unsigned int pool_nr;
-	struct iommu_pool *pool;
 
 	align_mask = 0xffffffffffffffffl >> (64 - align_order);
 
@@ -201,46 +179,38 @@ static unsigned long iommu_range_alloc(struct device *dev,
 	if (should_fail_iommu(dev))
 		return DMA_ERROR_CODE;
 
-	/*
-	 * We don't need to disable preemption here because any CPU can
-	 * safely use any IOMMU pool.
-	 */
-	pool_nr = __raw_get_cpu_var(iommu_pool_hash) & (tbl->nr_pools - 1);
-
-	if (largealloc)
-		pool = &(tbl->large_pool);
-	else
-		pool = &(tbl->pools[pool_nr]);
-
-	spin_lock_irqsave(&(pool->lock), flags);
+	spin_lock_irqsave(&(tbl->it_lock), flags);
 
-again:
-	if ((pass == 0) && handle && *handle)
+	if (handle && *handle)
 		start = *handle;
 	else
-		start = pool->hint;
+		start = largealloc ? tbl->it_largehint : tbl->it_hint;
 
-	limit = pool->end;
+	/* Use only half of the table for small allocs (15 pages or less) */
+	limit = largealloc ? tbl->it_size : tbl->it_halfpoint;
+
+	if (largealloc && start < tbl->it_halfpoint)
+		start = tbl->it_halfpoint;
 
 	/* The case below can happen if we have a small segment appended
 	 * to a large, or when the previous alloc was at the very end of
 	 * the available space. If so, go back to the initial start.
 	 */
 	if (start >= limit)
-		start = pool->start;
+		start = largealloc ? tbl->it_largehint : tbl->it_hint;
+
+ again:
 
 	if (limit + tbl->it_offset > mask) {
 		limit = mask - tbl->it_offset + 1;
 		/* If we're constrained on address range, first try
 		 * at the masked hint to avoid O(n) search complexity,
-		 * but on second pass, start at 0 in pool 0.
+		 * but on second pass, start at 0.
 		 */
-		if ((start & mask) >= limit || pass > 0) {
-			pool = &(tbl->pools[0]);
-			start = pool->start;
-		} else {
+		if ((start & mask) >= limit || pass > 0)
+			start = 0;
+		else
 			start &= mask;
-		}
 	}
 
 	if (dev)
@@ -254,25 +224,17 @@ again:
 			     tbl->it_offset, boundary_size >> IOMMU_PAGE_SHIFT,
 			     align_mask);
 	if (n == -1) {
-		if (likely(pass == 0)) {
-			/* First try the pool from the start */
-			pool->hint = pool->start;
-			pass++;
-			goto again;
-
-		} else if (pass <= tbl->nr_pools) {
-			/* Now try scanning all the other pools */
-			spin_unlock(&(pool->lock));
-			pool_nr = (pool_nr + 1) & (tbl->nr_pools - 1);
-			pool = &tbl->pools[pool_nr];
-			spin_lock(&(pool->lock));
-			pool->hint = pool->start;
+		if (likely(pass < 2)) {
+			/* First failure, just rescan the half of the table.
+			 * Second failure, rescan the other half of the table.
+			 */
+			start = (largealloc ^ pass) ? tbl->it_halfpoint : 0;
+			limit = pass ? tbl->it_size : limit;
 			pass++;
 			goto again;
-
 		} else {
-			/* Give up */
-			spin_unlock_irqrestore(&(pool->lock), flags);
+			/* Third failure, give up */
+			spin_unlock_irqrestore(&(tbl->it_lock), flags);
 			return DMA_ERROR_CODE;
 		}
 	}
@@ -282,10 +244,10 @@ again:
 	/* Bump the hint to a new block for small allocs. */
 	if (largealloc) {
 		/* Don't bump to new block to avoid fragmentation */
-		pool->hint = end;
+		tbl->it_largehint = end;
 	} else {
 		/* Overflow will be taken care of at the next allocation */
-		pool->hint = (end + tbl->it_blocksize - 1) &
+		tbl->it_hint = (end + tbl->it_blocksize - 1) &
 		                ~(tbl->it_blocksize - 1);
 	}
 
@@ -293,8 +255,7 @@ again:
 	if (handle)
 		*handle = end;
 
-	spin_unlock_irqrestore(&(pool->lock), flags);
-
+	spin_unlock_irqrestore(&(tbl->it_lock), flags);
 	return n;
 }
 
@@ -369,45 +330,23 @@ static bool iommu_free_check(struct iommu_table *tbl, dma_addr_t dma_addr,
 	return true;
 }
 
-static struct iommu_pool *get_pool(struct iommu_table *tbl,
-				   unsigned long entry)
-{
-	struct iommu_pool *p;
-	unsigned long largepool_start = tbl->large_pool.start;
-
-	/* The large pool is the last pool at the top of the table */
-	if (entry >= largepool_start) {
-		p = &tbl->large_pool;
-	} else {
-		unsigned int pool_nr = entry / tbl->poolsize;
-
-		BUG_ON(pool_nr > tbl->nr_pools);
-		p = &tbl->pools[pool_nr];
-	}
-
-	return p;
-}
-
 static void __iommu_free(struct iommu_table *tbl, dma_addr_t dma_addr,
 			 unsigned int npages)
 {
 	unsigned long entry, free_entry;
 	unsigned long flags;
-	struct iommu_pool *pool;
 
 	entry = dma_addr >> IOMMU_PAGE_SHIFT;
 	free_entry = entry - tbl->it_offset;
 
-	pool = get_pool(tbl, free_entry);
-
 	if (!iommu_free_check(tbl, dma_addr, npages))
 		return;
 
 	ppc_md.tce_free(tbl, entry, npages);
 
-	spin_lock_irqsave(&(pool->lock), flags);
+	spin_lock_irqsave(&(tbl->it_lock), flags);
 	bitmap_clear(tbl->it_map, free_entry, npages);
-	spin_unlock_irqrestore(&(pool->lock), flags);
+	spin_unlock_irqrestore(&(tbl->it_lock), flags);
 }
 
 static void iommu_free(struct iommu_table *tbl, dma_addr_t dma_addr,
@@ -649,8 +588,9 @@ struct iommu_table *iommu_init_table(struct iommu_table *tbl, int nid)
 	unsigned long sz;
 	static int welcomed = 0;
 	struct page *page;
-	unsigned int i;
-	struct iommu_pool *p;
+
+	/* Set aside 1/4 of the table for large allocations. */
+	tbl->it_halfpoint = tbl->it_size * 3 / 4;
 
 	/* number of bytes needed for the bitmap */
 	sz = (tbl->it_size + 7) >> 3;
@@ -669,28 +609,9 @@ struct iommu_table *iommu_init_table(struct iommu_table *tbl, int nid)
 	if (tbl->it_offset == 0)
 		set_bit(0, tbl->it_map);
 
-	/* We only split the IOMMU table if we have 1GB or more of space */
-	if ((tbl->it_size << IOMMU_PAGE_SHIFT) >= (1UL * 1024 * 1024 * 1024))
-		tbl->nr_pools = IOMMU_NR_POOLS;
-	else
-		tbl->nr_pools = 1;
-
-	/* We reserve the top 1/4 of the table for large allocations */
-	tbl->poolsize = (tbl->it_size * 3 / 4) / tbl->nr_pools;
-
-	for (i = 0; i < tbl->nr_pools; i++) {
-		p = &tbl->pools[i];
-		spin_lock_init(&(p->lock));
-		p->start = tbl->poolsize * i;
-		p->hint = p->start;
-		p->end = p->start + tbl->poolsize;
-	}
-
-	p = &tbl->large_pool;
-	spin_lock_init(&(p->lock));
-	p->start = tbl->poolsize * i;
-	p->hint = p->start;
-	p->end = tbl->it_size;
+	tbl->it_hint = 0;
+	tbl->it_largehint = tbl->it_halfpoint;
+	spin_lock_init(&tbl->it_lock);
 
 	iommu_table_clear(tbl);
 
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index dca2136..b673200 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -518,6 +518,7 @@ cell_iommu_setup_window(struct cbe_iommu *iommu, struct device_node *np,
 	__set_bit(0, window->table.it_map);
 	tce_build_cell(&window->table, window->table.it_offset, 1,
 		       (unsigned long)iommu->pad_page, DMA_TO_DEVICE, NULL);
+	window->table.it_hint = window->table.it_blocksize;
 
 	return window;
 }

