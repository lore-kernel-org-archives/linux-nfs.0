Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C599D3A5E78;
	Thu, 23 Jul 2026 05:47:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784785632; cv=none; b=OK/z78sD9u9pda0w9L5DgZbkv2w1iVRspFHP/r/A/ND2GvAlmMQqGqal/a/68lMsW04iO/VwJsjTvYoVDTCNRYWLTSKsv39QKuX4y6xawWNmsop8mFRP5BuXo2f0gWAIae1VI0gn6ZatrqUeKtM1ngbjfJD1NHzYiesqJdemmI4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784785632; c=relaxed/simple;
	bh=JKlVujbKqPmSjU4imQ8+jc4U5jq+Qtfs4fW/S0ydewQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dejWfarDUZtBEokq9wv2J8plXURWiOg7zw9n6En43O5CcAlxvzTawYitVnvxxYpt4QEt/G+wLZuWy48cUpyb+uQwdwj1/5y6aELlooYtiRbfoO6ahwGi/Px/tRbf8umzQb3+QmJ7UvtXetgFs6sp/cFREUehwVaEEy1N5qhbX+Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=Q3GzORIT; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Q3GzORIT"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description;
	bh=SCgrBV4+wiYD8yTajffrCoLTiOuVuwvpUdCa94y7WYw=; b=Q3GzORIT8IOzxH4aY6CLKstcSn
	8RWluq5HE3u2ureWMAc32d7zum9Dtn7XTrXkqpMQevAphF/RU/rizQhCD2WFKZGD2fXaB1puAfoV9
	jfYGjSUVWuEwhRg3LjFY+3KWt7x0/U6FvyN762Kn27KdPm2T3+tVQ6tZD8PXElk8P0YS4xA1E7I0K
	Bq98lSMl2faOXexrO9n3XC50Lx7f/DbhodkZcRMvyv5APhB5KKZb6hw+Xd0XDYEiY6AC6Z5mdMveF
	99AeknObJ78qDzaAPHRjRPniQ5tylPCiAiPrB0XT6/czQgybnJPfTHu1Y4G78WRnb4gGR6UODZFSp
	111OQjeQ==;
Received: from 217-76-162-32.static.highway.a1.net ([217.76.162.32] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wmmGs-0000000DV1n-1gJf;
	Thu, 23 Jul 2026 05:47:04 +0000
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
Date: Thu, 23 Jul 2026 07:46:05 +0200
Message-ID: <20260723054622.3460249-3-hch@lst.de>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260723054622.3460249-1-hch@lst.de>
References: <20260723054622.3460249-1-hch@lst.de>
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
swap.  There is no functional change, just a move of the declarations.

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
 mm/zswap.c               |  2 +-
 9 files changed, 47 insertions(+), 32 deletions(-)
 create mode 100644 include/linux/swap_ops.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 15dd00c7ffec..713275f62ec4 100644
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
index 9b8ee902f972..efe24bb36ce1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -58,6 +58,7 @@
 #include <linux/random.h>
 #include <linux/mmu_notifier.h>
 #include <linux/parser.h>
+#include <linux/swap_ops.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
diff --git a/mm/zswap.c b/mm/zswap.c
index 4e76a4a87cdc..9c4c337790fd 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -20,7 +20,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/atomic.h>
-#include <linux/swap.h>
+#include <linux/swap_ops.h>
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <linux/mempolicy.h>
-- 
2.53.0

