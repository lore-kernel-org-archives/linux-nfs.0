Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DEAEA345731;
	Wed, 22 Jul 2026 13:06:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784725615; cv=none; b=Ej/vYrH4HCv2htok3T+LCQP1EOK50Q+CMukJLXRaRArohePYkUBUMNJ+ODckR+LxjPmaeVF96M5uuLzeIy8hfTWjkzNdH7qDhsm7Z9OnlVel/gjaqD1NFmoQwmYL08NkMnCyrUR9aETLpDI8+yIsEYXB3B7b9Thd2C+el4OTK8U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784725615; c=relaxed/simple;
	bh=hfWnfqPleF4wgg5Mu1aQwXqGbwO1jhtgaUH6S43lxjY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=vCUEDjRi0gTu71FQqK3zsLMhqVkPVNxAZvnZKQYL2O3BncN7dORRaR5LtppEL/jQ/EPKtO2POEcvG0P9RNxTfN4sDr5udAYRIhQxZixLf3gEm2huC5hJkayteUwOf0q3tbpjF1AEROOo341OYXTNFW7335c7XJSEV0ZW+9KgOcU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=vZGP0+ov; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="vZGP0+ov"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description;
	bh=qmP1+k44uQ0XzsS2fg67ij07ScstcQcZVV2Jbwuyduw=; b=vZGP0+ovGndQzTzHorEOgZRIsX
	SZKZtFESuUcSYvvMJ7SEctBCIYheC8pQ5U48ntqDLN9yH8G0Tc6XjiwtKgJUHDF60XUe3Wg9nmmcC
	P8KapGGgmmkswd1xz2unK7a7Ya+ZcPm0KZ7ZAEB59QAkS1p1ywXI2cI0AiInKYn5SgDByI76LpW1n
	NwsNDP2YfAD6npLdBZlyYhyYtbSUo1BkXUyqaAn+SZJ+qy/ar6ksvkC8y1pKvf/Ty4yiCT1Y5sCI1
	QQcH7NNzIVTR/8YSVR93U87B9NxZrZPFuSfyO3PyQvsZgrL4Pmcvdc6XcHFwQY0XN8VBP6RcGNzNg
	7wbA69IQ==;
Received: from [2001:4bb8:2d6:3a78:eb21:714c:af4c:ee7d] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wmWer-0000000Bpq3-2owx;
	Wed, 22 Jul 2026 13:06:46 +0000
From: Christoph Hellwig <hch@lst.de>
To: 
Cc: baoquan.he@linux.dev,
	akpm@linux-foundation.org,
	chrisl@kernel.org,
	usama.arif@linux.dev,
	kasong@tencent.com,
	nphamcs@gmail.com,
	shikemeng@huaweicloud.com,
	youngjun.park@lge.com,
	ryncsn@gmail.com,
	trondmy@kernel.org,
	anna@kernel.org,
	sfrench@samba.org,
	linux-mm@kvack.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] mm/swap: add a new swap_ops.h header to allow for pluggable swap ops
Date: Wed, 22 Jul 2026 15:06:08 +0200
Message-ID: <20260722130615.3163560-3-hch@lst.de>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260722130615.3163560-1-hch@lst.de>
References: <20260722130615.3163560-1-hch@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Add a new header to declare the swap_iocb, swap_ops and swap_ctx to
allow for swap_ops implementations outside of mm/page_io.c.  This
will be used to remove the double indirection for file system-based
swap.

Note that there already is a swapops.h header, which is totally
unrelated to struct swap_ops.  The close naming is a bit unfortunate,
but I could not think of a better name for this header.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 MAINTAINERS              |  1 +
 include/linux/swap_ops.h | 39 +++++++++++++++++++++++++++++++++++++++
 mm/madvise.c             |  1 +
 mm/page_io.c             | 10 +---------
 mm/shmem.c               |  1 +
 mm/swap.h                | 23 +----------------------
 mm/swap_state.c          |  1 +
 mm/vmscan.c              |  1 +
 8 files changed, 46 insertions(+), 31 deletions(-)
 create mode 100644 include/linux/swap_ops.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 5da77924c6f0..cda42b7ed945 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -17240,6 +17240,7 @@ S:	Maintained
 F:	Documentation/ABI/testing/sysfs-kernel-mm-swap
 F:	Documentation/mm/swap-table.rst
 F:	include/linux/swap.h
+F:	include/linux/swap_ops.h
 F:	include/linux/swapfile.h
 F:	include/linux/swapops.h
 F:	mm/page_io.c
diff --git a/include/linux/swap_ops.h b/include/linux/swap_ops.h
new file mode 100644
index 000000000000..e92b4f532604
--- /dev/null
+++ b/include/linux/swap_ops.h
@@ -0,0 +1,39 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _MM_SWAP_OPS_H
+#define _MM_SWAP_OPS_H
+
+#include <linux/swap.h> /* for SWAP_CLUSTER_MAX */
+
+struct swap_iocb {
+	union {
+		struct kiocb	iocb;
+		struct bio	bio;
+	};
+	struct bio_vec		bvecs[SWAP_CLUSTER_MAX];
+	int			nr_bvecs;
+	int			len;
+};
+
+struct swap_io_ctx {
+	struct swap_iocb	*sio;
+	struct swap_info_struct	*sis;
+};
+
+/*
+ * SWAP_OPS_F_REQUIRE_NOFS:
+ *	When set, all reclaim operations must operated as GFS_NOFS and not
+ *	just GFP_NOIO, as GFP_NOIO allocations could recourse into the
+ *	file system backing this swap file.
+ */
+#define SWAP_OPS_F_REQUIRE_NOFS		(1U << 0)
+
+struct swap_ops {
+	unsigned int		flags;
+
+	bool (*can_merge)(struct folio *folio, struct folio *prev_folio,
+			size_t prev_folio_size, int rw);
+	void (*submit_write)(struct swap_io_ctx *ctx);
+	void (*submit_read)(struct swap_io_ctx *ctx);
+};
+
+#endif /* _MM_SWAP_OPS_H */
diff --git a/mm/madvise.c b/mm/madvise.c
index 07a21ca31bad..c179938097bf 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -32,6 +32,7 @@
 #include <linux/leafops.h>
 #include <linux/shmem_fs.h>
 #include <linux/mmu_notifier.h>
+#include <linux/swap_ops.h>
 
 #include <asm/tlb.h>
 
diff --git a/mm/page_io.c b/mm/page_io.c
index c984a4023a65..e741e67d6592 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -25,6 +25,7 @@
 #include <linux/sched/task.h>
 #include <linux/delayacct.h>
 #include <linux/zswap.h>
+#include <linux/swap_ops.h>
 #include "swap.h"
 #include "swap_table.h"
 
@@ -300,15 +301,6 @@ static bool folio_blkg_can_merge(struct folio *folio, struct folio *prev_folio)
 #define bio_associate_blkg_from_page(bio, folio)		do { } while (0)
 #endif /* CONFIG_MEMCG && CONFIG_BLK_CGROUP */
 
-struct swap_iocb {
-	union {
-		struct kiocb	iocb;
-		struct bio	bio;
-	};
-	struct bio_vec		bvecs[SWAP_CLUSTER_MAX];
-	int			nr_bvecs;
-	int			len;
-};
 static mempool_t *sio_pool;
 
 int sio_pool_init(void)
diff --git a/mm/shmem.c b/mm/shmem.c
index 5071177059a9..797c42f024a0 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -41,6 +41,7 @@
 #include <linux/swapfile.h>
 #include <linux/iversion.h>
 #include <linux/unicode.h>
+#include <linux/swap_ops.h>
 #include "swap.h"
 
 static struct vfsmount *shm_mnt __ro_after_init;
diff --git a/mm/swap.h b/mm/swap.h
index abd26588abd2..19ea61c97df2 100644
--- a/mm/swap.h
+++ b/mm/swap.h
@@ -8,6 +8,7 @@
 struct mempolicy;
 struct swap_iocb;
 struct swap_memcg_table;
+struct swap_io_ctx;
 
 #if defined(MAX_POSSIBLE_PHYSMEM_BITS)
 #define SWAP_CACHE_PFN_BITS (MAX_POSSIBLE_PHYSMEM_BITS - PAGE_SHIFT)
@@ -77,28 +78,6 @@ enum swap_cluster_flags {
 	CLUSTER_FLAG_MAX,
 };
 
-struct swap_io_ctx {
-	struct swap_iocb	*sio;
-	struct swap_info_struct	*sis;
-};
-
-/*
- * SWAP_OPS_F_REQUIRE_NOFS:
- *	When set, all reclaim operations must operated as GFS_NOFS and not
- *	just GFP_NOIO, as GFP_NOIO allocations could recourse into the
- *	file system backing this swap file.
- */
-#define SWAP_OPS_F_REQUIRE_NOFS		(1U << 0)
-
-struct swap_ops {
-	unsigned int		flags;
-
-	bool (*can_merge)(struct folio *folio, struct folio *prev_folio,
-			size_t prev_folio_size, int rw);
-	void (*submit_write)(struct swap_io_ctx *ctx);
-	void (*submit_read)(struct swap_io_ctx *ctx);
-};
-
 #ifdef CONFIG_SWAP
 #include <linux/swapops.h> /* for swp_offset */
 #include <linux/blk_types.h> /* for bio_end_io_t */
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 5be825911e64..b76eb3d876fd 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -23,6 +23,7 @@
 #include <linux/huge_mm.h>
 #include <linux/shmem_fs.h>
 #include <linux/sysctl.h>
+#include <linux/swap_ops.h>
 #include "internal.h"
 #include "swap_table.h"
 #include "swap.h"
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e26c6931f5fd..a12eb79c89c5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -58,6 +58,7 @@
 #include <linux/random.h>
 #include <linux/mmu_notifier.h>
 #include <linux/parser.h>
+#include <linux/swap_ops.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
-- 
2.53.0

