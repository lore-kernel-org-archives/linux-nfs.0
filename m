Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 4461D380FDF;
	Tue,  6 Oct 2026 09:01:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791277278; cv=none; b=slY3JTOtKwLl+6+2XRExsOca2i/ycK0rFAfKkwsnnsMtJ7g/KxEtSn54rLgzDx+BaZTmL5ai7JcO1CX0VggioNy1bkmR/Gx/WC3i2a6ZYn4tIO+XOJ3aeu9wuwVOmwSObJIVElWyRAVa7CWfZERmUH7gMwem5RvRNahrVm8m0Qw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791277278; c=relaxed/simple;
	bh=AELUTqlq3anC70GDmOecyI7mp3TZUze0YupBeXyhFto=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=d+vvgNFg5u/6AcFKqoiByb2RFBdyroIn64XFgNgtAkNEla9Cj42Htx0XRD26nDPd2i0RGY6T6TvzDQQKYeEXo7p6vXE8IrI4Tfz9qgbVhFwvU0AfiPxaUzVRzNcQrST89wQCEgVZy+Y6932O8Z9NnuWtWmgcnO18/UjGanstcmU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=nFOg0mt9; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="nFOg0mt9"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 264DC1A25;
	Tue,  6 Oct 2026 02:01:13 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id D02843F86F;
	Tue,  6 Oct 2026 02:01:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791277276; bh=AELUTqlq3anC70GDmOecyI7mp3TZUze0YupBeXyhFto=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=nFOg0mt9FbLeldUBKwCuALHHocuo3GOzrAlbbcdmWN/7xp1tGw/BGXPtsVRHy4l2E
	 INggRlKCZh2MWEJ5gHDmcNLO1KtIXovQFHdAy7aQt5W66NjFQ91fbJ8Rpq/HytwAA0
	 Uc+RLLfF7nRQhL5BDUQC2hzkL8tpcbl83vTrXOw4=
From: J Louis Kaplan <Louis.Kaplan@arm.com>
To: cel@kernel.org,
	dai.ngo@oracle.com,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	anna@kernel.org,
	jgg@ziepe.ca,
	leon@kernel.org,
	trondmy@kernel.org,
	J Louis Kaplan <Louis.Kaplan@arm.com>
Subject: [RFC PATCH 6/6] sunrpc: Allocate svc request pages from large folios
Date: Tue,  6 Oct 2026 10:00:28 +0100
Message-ID: <20261006090028.3412544-7-Louis.Kaplan@arm.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
References: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Bulk allocation of base pages does not guarantee physical
contiguity, limiting opportunities to coalesce service buffers.

Allocate large folios opportunistically and populate the service
page arrays with their constituent pages. Cap folio size at
64 KiB and allocation order at PAGE_ALLOC_COSTLY_ORDER, falling
back through smaller orders to bulk base-page allocation.

Retain one reference per populated page-array slot so existing
page-based ownership and release paths remain valid.

Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
Assisted-by: LLM
---
 net/sunrpc/svc_xprt.c | 44 ++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 39 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 9858dfcb846a8..90ec75a848da9 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -19,6 +19,7 @@
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/sizes.h>
 #include <trace/events/sunrpc.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
@@ -708,20 +709,53 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 static bool svc_fill_pages(struct svc_rqst *rqstp, struct page **pages,
 			   unsigned long npages)
 {
-	unsigned long filled, ret;
+	unsigned int order = min_t(unsigned int, PAGE_ALLOC_COSTLY_ORDER,
+				   get_order(SZ_64K));
+	unsigned long filled = 0;
 
-	for (filled = 0; filled < npages; filled = ret) {
-		ret = alloc_pages_bulk(GFP_KERNEL, npages, pages);
-		if (ret > filled)
+	/*
+	 * Prefer folios no larger than 64 KiB or the page allocator's
+	 * costly-order threshold. After a failure, use smaller orders for
+	 * the rest of this fill; order zero is handled by the bulk allocator.
+	 * All callers provide a range containing only NULL entries.
+	 */
+	while (filled < npages) {
+		struct folio *folio;
+		unsigned int nr_pages;
+		unsigned long ret;
+
+		while (order && (1UL << order) > npages - filled)
+			order--;
+
+		if (order) {
+			folio = folio_alloc(GFP_NOWAIT, order);
+			if (!folio) {
+				order--;
+				continue;
+			}
+
+			nr_pages = folio_nr_pages(folio);
+			folio_ref_add(folio, nr_pages - 1);
+			for (unsigned int i = 0; i < nr_pages; i++)
+				pages[filled + i] = folio_page(folio, i);
+			filled += nr_pages;
+			continue;
+		}
+
+		ret = alloc_pages_bulk(GFP_KERNEL, npages - filled,
+				       pages + filled);
+		if (ret) {
+			filled += ret;
 			/* Made progress, don't sleep yet */
 			continue;
+		}
 
 		set_current_state(TASK_IDLE);
 		if (svc_thread_should_stop(rqstp)) {
 			set_current_state(TASK_RUNNING);
 			return false;
 		}
-		trace_svc_alloc_arg_err(npages, ret);
+		trace_svc_alloc_arg_err(npages, filled);
 		memalloc_retry_wait(GFP_KERNEL);
 	}
 	return true;
-- 
2.43.0

