From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 01/30] mm: serialize access to min_free_kbytes
Date: Tue, 13 Jul 2010 06:17:02 -0400
Message-ID: <20100713101702.2835.19139.sendpatchset@danny.redhat>
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

>From bc55bacd6bcc0f8a69c0d7e0d554c78237233e07 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Mon, 12 Jul 2010 17:58:34 +0800
Subject: [PATCH 01/30] mm: serialize access to min_free_kbytes

There is a small race between the procfs caller and the memory hotplug caller
of setup_per_zone_wmarks(). Not a big deal, but the next patch will add yet
another caller. Time to close the gap.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 mm/page_alloc.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 50a6d10..ebf0af7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -165,6 +165,7 @@ static char * const zone_names[MAX_NR_ZONES] = {
 	 "Movable",
 };
 
+static DEFINE_SPINLOCK(min_free_lock);
 int min_free_kbytes = 1024;
 
 static unsigned long __meminitdata nr_kernel_pages;
@@ -4839,13 +4840,13 @@ static void setup_per_zone_lowmem_reserve(void)
 }
 
 /**
- * setup_per_zone_wmarks - called when min_free_kbytes changes
+ * __setup_per_zone_wmarks - called when min_free_kbytes changes
  * or when memory is hot-{added|removed}
  *
  * Ensures that the watermark[min,low,high] values for each zone are set
  * correctly with respect to min_free_kbytes.
  */
-void setup_per_zone_wmarks(void)
+static void __setup_per_zone_wmarks(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
@@ -4943,6 +4944,15 @@ static void __init setup_per_zone_inactive_ratio(void)
 		calculate_zone_inactive_ratio(zone);
 }
 
+void setup_per_zone_wmarks(void)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&min_free_lock, flags);
+	__setup_per_zone_wmarks();
+	spin_unlock_irqrestore(&min_free_lock, flags);
+}
+
 /*
  * Initialise min_free_kbytes.
  *
@@ -4978,7 +4988,7 @@ static int __init init_per_zone_wmark_min(void)
 		min_free_kbytes = 128;
 	if (min_free_kbytes > 65536)
 		min_free_kbytes = 65536;
-	setup_per_zone_wmarks();
+	__setup_per_zone_wmarks();
 	setup_per_zone_lowmem_reserve();
 	setup_per_zone_inactive_ratio();
 	return 0;
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
