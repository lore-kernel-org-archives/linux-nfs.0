Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ozlabs.org ([203.10.76.45]:39488 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752977Ab2JDE5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Oct 2012 00:57:22 -0400
Date: Thu, 4 Oct 2012 14:57:10 +1000
From: Anton Blanchard <anton@samba.org>
To: Alexander Graf <agraf@suse.de>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, skinsbursky@parallels.com,
        bfields@redhat.com, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: [PATCH] powerpc/iommu: Fix multiple issues with IOMMU pools code
Message-ID: <20121004145710.2cf95dcd@kryten>
In-Reply-To: <E141CA01-F58C-47B1-8ED5-A314D1DEC968@suse.de>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de>
	<CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
	<DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de>
	<20120928151043.GA19102@fieldses.org>
	<2A52FC96-148C-4F7A-9950-E152E0C6698D@suse.de>
	<1349139509.3847.2.camel@pasglop>
	<20121002214327.GA29218@linux.vnet.ibm.com>
	<9257E705-4EF9-4347-945C-B4A7582C427F@suse.de>
	<20121002221736.GB29218@linux.vnet.ibm.com>
	<E141CA01-F58C-47B1-8ED5-A314D1DEC968@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Alex,

Looks to be a preempt issue with the iommu pools code. I did find a
couple more bugs along the way too.

Anton
--

There are a number of issues in the recent IOMMU pools code:

- On a preempt kernel we might switch CPUs in the middle of building
  a scatter gather list. When this happens the handle hint passed in
  no longer falls within the local CPU's pool. Check for this and
  fall back to the pool hint.

- We were missing a spin_unlock/spin_lock in one spot where we
  switch pools.

- We need to provide locking around dart_tlb_invalidate_all and
  dart_tlb_invalidate_one now that the global lock is gone.

Reported-by: Alexander Graf <agraf@suse.de>
Signed-off-by: Anton Blanchard <anton@samba.org>
---

There is still an issue with the lazy u3 flushing, but I wanted
to get this out for testing.

Index: b/arch/powerpc/kernel/iommu.c
===================================================================
--- a/arch/powerpc/kernel/iommu.c
+++ b/arch/powerpc/kernel/iommu.c
@@ -215,7 +215,8 @@ static unsigned long iommu_range_alloc(s
 	spin_lock_irqsave(&(pool->lock), flags);
 
 again:
-	if ((pass == 0) && handle && *handle)
+	if ((pass == 0) && handle && *handle &&
+	    (*handle >= pool->start) && (*handle < pool->end))
 		start = *handle;
 	else
 		start = pool->hint;
@@ -236,7 +237,9 @@ again:
 		 * but on second pass, start at 0 in pool 0.
 		 */
 		if ((start & mask) >= limit || pass > 0) {
+			spin_unlock(&(pool->lock));
 			pool = &(tbl->pools[0]);
+			spin_lock(&(pool->lock));
 			start = pool->start;
 		} else {
 			start &= mask;
Index: b/arch/powerpc/sysdev/dart_iommu.c
===================================================================
--- a/arch/powerpc/sysdev/dart_iommu.c
+++ b/arch/powerpc/sysdev/dart_iommu.c
@@ -74,11 +74,16 @@ static int dart_is_u4;
 
 #define DBG(...)
 
+static DEFINE_SPINLOCK(invalidate_lock);
+
 static inline void dart_tlb_invalidate_all(void)
 {
 	unsigned long l = 0;
 	unsigned int reg, inv_bit;
 	unsigned long limit;
+	unsigned long flags;
+
+	spin_lock_irqsave(&invalidate_lock, flags);
 
 	DBG("dart: flush\n");
 
@@ -111,12 +116,17 @@ retry:
 			panic("DART: TLB did not flush after waiting a long "
 			      "time. Buggy U3 ?");
 	}
+
+	spin_unlock_irqrestore(&invalidate_lock, flags);
 }
 
 static inline void dart_tlb_invalidate_one(unsigned long bus_rpn)
 {
 	unsigned int reg;
 	unsigned int l, limit;
+	unsigned long flags;
+
+	spin_lock_irqsave(&invalidate_lock, flags);
 
 	reg = DART_CNTL_U4_ENABLE | DART_CNTL_U4_IONE |
 		(bus_rpn & DART_CNTL_U4_IONE_MASK);
@@ -138,6 +148,8 @@ wait_more:
 			panic("DART: TLB did not flush after waiting a long "
 			      "time. Buggy U4 ?");
 	}
+
+	spin_unlock_irqrestore(&invalidate_lock, flags);
 }
 
 static void dart_flush(struct iommu_table *tbl)
