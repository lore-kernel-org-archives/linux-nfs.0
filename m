From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 09/30] mm: system wide ALLOC_NO_WATERMARK
Date: Tue, 13 Jul 2010 06:18:32 -0400
Message-ID: <20100713101832.2835.42184.sendpatchset@danny.redhat>
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

>From 6d9ae36dfe34cdbc6e1fc52e6db0b27286eb4b58 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 10:46:50 +0800
Subject: [PATCH 09/30] mm: system wide ALLOC_NO_WATERMARK

The reserve is proportionally distributed over all (!highmem) zones in the
system. So we need to allow an emergency allocation access to all zones. In
order to do that we need to break out of any mempolicy boundaries we might
have.

In my opinion that does not break mempolicies as those are user oriented
and not system oriented. That is, system allocations are not guaranteed to be
within mempolicy boundaries. For instance IRQs don't even have a mempolicy.

So breaking out of mempolicy boundaries for 'rare' emergency allocations,
which are always system allocations (as opposed to user) is ok.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 mm/page_alloc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6c85e9e..21d64f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1995,6 +1995,11 @@ restart:
 rebalance:
 	/* Allocate without watermarks if the context allows */
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
+		/*
+		 * break out mempolicy boundaries
+		 */
+		zonelist = node_zonelist(numa_node_id(), gfp_mask);
+
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
