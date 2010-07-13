From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 10/30] mm: __GFP_MEMALLOC
Date: Tue, 13 Jul 2010 06:18:43 -0400
Message-ID: <20100713101843.2835.12822.sendpatchset@danny.redhat>
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

>From 78618cc83e6a21b876c30a8fb3940ccc1f5b99e1 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 10:49:16 +0800
Subject: [PATCH 10/30] mm: __GFP_MEMALLOC

__GFP_MEMALLOC will allow the allocation to disregard the watermarks,
much like PF_MEMALLOC.

It allows one to pass along the memalloc state in object related allocation
flags as opposed to task related flags, such as sk->sk_allocation.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/linux/gfp.h |    3 ++-
 mm/page_alloc.c     |    4 +++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 975609c..c608e26 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -47,6 +47,7 @@ struct vm_area_struct;
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* See above */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* See above */
 #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* See above */
+#define __GFP_MEMALLOC  ((__force gfp_t)0x2000u)/* Use emergency reserves */
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
@@ -98,7 +99,7 @@ struct vm_area_struct;
 /* Control page allocator reclaim behavior */
 #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
 			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
-			__GFP_NORETRY|__GFP_NOMEMALLOC)
+			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
 
 /* Control slab gfp mask during early boot */
 #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 21d64f7..f7d3060 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1930,7 +1930,9 @@ int gfp_to_alloc_flags(gfp_t gfp_mask)
 		alloc_flags |= ALLOC_HARDER;
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (!in_irq() && (p->flags & PF_MEMALLOC))
+		if (gfp_mask & __GFP_MEMALLOC)
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (!in_irq() && (p->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (!in_interrupt() &&
 				unlikely(test_thread_flag(TIF_MEMDIE)))
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
