Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 1471237F333;
	Tue,  6 Oct 2026 09:01:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791277274; cv=none; b=HgNYL8QEiBvCYUYl8QFGQa89tgk1+dXJPDQonma5nkxjZLhHkHWHtA3815AKB8xS4cell3PT96cl84qL1Ybp7dwxaOUSaP7yywhtvwIjELBj9iCx3FZ2eEkIp/ByoQ4tbg4+oncWCwrj9pDrhNG48HH+dkR6biXCIi0bg5cOG/0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791277274; c=relaxed/simple;
	bh=ywqcrRc7QUD1ae9hrzuPnCoeDpUDqqLWAOW2mEl3xRY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CHiJtWLmOKW/0mf1x7KrAuHwGGIugT7iO1HqdRcmthOzwKr9PXqautl2lHvgF3d5+on8UtF9LE9rrv5Ad5iotG+o2+5P6TrBQfqeIyuJOnpB3wSqABO/sUldb+U4LGk8ok8uSlG3YZoFKJlJ3e4mn3xZgY0oa1HIh2T64ulqBwc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=HbJPy60+; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="HbJPy60+"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2A666168F;
	Tue,  6 Oct 2026 02:01:09 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id D12DA3F86F;
	Tue,  6 Oct 2026 02:01:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791277272; bh=ywqcrRc7QUD1ae9hrzuPnCoeDpUDqqLWAOW2mEl3xRY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=HbJPy60+BP2nXVLC/rOkuhVyLUigvjC3GxA6jlUYMQxNO/jUHeyBVZEeDamqhvN3A
	 TKULGw9vQNvUTgw2bTueNcp+/NMb75d/P06s3GsDS/G91MzC1jsUj7uQbEioHfzv79
	 Gxha4ly7VLG5K02yEe5xRNuhBVfixCXbO1JKephY=
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
Subject: [RFC PATCH 4/6] svcrdma: Coalesce contiguous pages in RDMA Write chunks
Date: Tue,  6 Oct 2026 10:00:26 +0100
Message-ID: <20261006090028.3412544-5-Louis.Kaplan@arm.com>
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

When sending replies with remote direct memory access (RDMA)
Writes, the pagelist is represented by one bvec per base page.
This prevents contiguous pages from sharing a buffer descriptor.

Coalesce contiguous runs within each remote segment, subject to
device length limits. Count the resulting bvecs before acquiring
the context so its allocation reflects the coalesced entry count.
The counting pass leaves the payload cursor untouched.

Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
Assisted-by: LLM
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c | 77 +++++++++++++++++--------------
 1 file changed, 43 insertions(+), 34 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 63d00f0cc1dbd..a2e1c693b1bc1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -445,46 +445,48 @@ static int svc_rdma_post_chunk_ctxt(struct svcxprt_rdma *rdma,
 	return 0;
 }
 
-/* Build a bvec that covers one kvec in an xdr_buf.
+/*
+ * With a NULL @ctxt, bvec constructors count entries without advancing
+ * @info. Otherwise they populate the context and advance @info.
  */
-static void svc_rdma_vec_to_bvec(struct svc_rdma_write_info *info,
-				 unsigned int len,
-				 struct svc_rdma_rw_ctxt *ctxt)
+static unsigned int
+svc_rdma_vec_to_bvec(struct svc_rdma_write_info *info, unsigned int len,
+		     struct svc_rdma_rw_ctxt *ctxt)
 {
+	if (!ctxt)
+		return 1;
+
 	bvec_set_virt(&ctxt->rw_bvec[0], info->wi_base, len);
 	info->wi_base += len;
 
 	ctxt->rw_nents = 1;
+	return 1;
 }
 
 /* Build a bvec array that covers part of an xdr_buf's pagelist.
+ * If @ctxt is NULL, only count the required entries.
  */
-static void svc_rdma_pagelist_to_bvec(struct svc_rdma_write_info *info,
-				      unsigned int remaining,
-				      struct svc_rdma_rw_ctxt *ctxt)
+static unsigned int
+svc_rdma_pagelist_to_bvec(struct svc_rdma_write_info *info,
+			  unsigned int remaining,
+			  struct svc_rdma_rw_ctxt *ctxt)
 {
-	unsigned int bvec_idx, bvec_len, page_off, page_no;
 	const struct xdr_buf *xdr = info->wi_xdr;
-	struct page **page;
-
-	page_off = info->wi_next_off + xdr->page_base;
-	page_no = page_off >> PAGE_SHIFT;
-	page_off = offset_in_page(page_off);
-	page = xdr->pages + page_no;
-	info->wi_next_off += remaining;
-	bvec_idx = 0;
-	do {
-		bvec_len = min_t(unsigned int, remaining,
-				 PAGE_SIZE - page_off);
-		bvec_set_page(&ctxt->rw_bvec[bvec_idx], *page, bvec_len,
-			      page_off);
-		remaining -= bvec_len;
-		page_off = 0;
-		bvec_idx++;
-		page++;
-	} while (remaining);
-
-	ctxt->rw_nents = bvec_idx;
+	unsigned int page_pos = info->wi_next_off + xdr->page_base;
+	unsigned int page_no = page_pos >> PAGE_SHIFT;
+	unsigned int max_bvec_len = svc_rdma_max_bvec_len(info->wi_rdma);
+	unsigned int page_off = offset_in_page(page_pos);
+	unsigned int nr_pages = DIV_ROUND_UP(page_off + remaining, PAGE_SIZE);
+	struct bio_vec *bvecs = ctxt ? ctxt->rw_bvec : NULL;
+	unsigned int nents;
+
+	nents = svc_pages_to_bvecs(bvecs, xdr->pages + page_no, nr_pages,
+				   page_off, remaining, max_bvec_len);
+	if (ctxt) {
+		ctxt->rw_nents = nents;
+		info->wi_next_off += remaining;
+	}
+	return nents;
 }
 
 /* Construct RDMA Write WRs to send a portion of an xdr_buf containing
@@ -492,9 +494,9 @@ static void svc_rdma_pagelist_to_bvec(struct svc_rdma_write_info *info,
  */
 static int
 svc_rdma_build_writes(struct svc_rdma_write_info *info,
-		      void (*constructor)(struct svc_rdma_write_info *info,
-					  unsigned int len,
-					  struct svc_rdma_rw_ctxt *ctxt),
+		      unsigned int (*constructor)(struct svc_rdma_write_info *,
+						  unsigned int,
+						  struct svc_rdma_rw_ctxt *),
 		      unsigned int remaining)
 {
 	struct svc_rdma_chunk_ctxt *cc = &info->wi_cc;
@@ -504,6 +506,7 @@ svc_rdma_build_writes(struct svc_rdma_write_info *info,
 	int ret;
 
 	do {
+		unsigned int nr_bvec;
 		unsigned int write_len;
 		u64 offset;
 
@@ -514,12 +517,18 @@ svc_rdma_build_writes(struct svc_rdma_write_info *info,
 		write_len = min(remaining, seg->rs_length - info->wi_seg_off);
 		if (!write_len)
 			goto out_overflow;
-		ctxt = svc_rdma_get_rw_ctxt(rdma,
-					    (write_len >> PAGE_SHIFT) + 2);
+		nr_bvec = constructor(info, write_len, NULL);
+		if (!nr_bvec)
+			return -EIO;
+
+		ctxt = svc_rdma_get_rw_ctxt(rdma, nr_bvec);
 		if (!ctxt)
 			return -ENOMEM;
 
-		constructor(info, write_len, ctxt);
+		if (WARN_ON_ONCE(constructor(info, write_len, ctxt) != nr_bvec)) {
+			svc_rdma_put_rw_ctxt(rdma, ctxt);
+			return -EIO;
+		}
 		offset = seg->rs_offset + info->wi_seg_off;
 		ret = svc_rdma_rw_ctx_init(rdma, ctxt, offset, seg->rs_handle,
 					   write_len, DMA_TO_DEVICE);
-- 
2.43.0

