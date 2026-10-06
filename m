Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 314A53264D6;
	Tue,  6 Oct 2026 09:01:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791277277; cv=none; b=FGp5N0+M/s76YtIz8C100ZF4mqMBSN418imHTJbqXeai83dElbRYuuQVLkRRD2AD9ywDqjbub46ce6VGJl4m6Z0Tz+X9o83XUhS+y28DqX5n+KIiWvQbv7JdbtRXlwrdxf69SC4qfI2VxGb64ibClfGjZN3ZTT/NWaVqNt9Crs0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791277277; c=relaxed/simple;
	bh=arJ0m3qXBVceTD93xZic+LKbAkh+xHh4zRoDUEINAeg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uCdVhDxq5/IQbtDo+vpvR15hNUZWWiZRPvMN3+VNqj12lEgbAhfTf0XUl2sl9PkNZiG+Zevl7LsJG1GLNS9PVu3WyLuBfIGgbVZQrg2SYxZsQtT8qktw5jehtKW9A2GUBRzMyHw5AmiCr06ULu1cv9qgltheFkZy3ECVR1B7VLg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=bvm/FcmO; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="bvm/FcmO"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2B1B01A00;
	Tue,  6 Oct 2026 02:01:11 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id D69EF3F86F;
	Tue,  6 Oct 2026 02:01:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791277274; bh=arJ0m3qXBVceTD93xZic+LKbAkh+xHh4zRoDUEINAeg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=bvm/FcmOmVc3tJwsWpSx1avIIyFrvLKAKp1qJqfviWEi+eteFuXTCvkvRh7BKZZkU
	 6QR1d15FimO+riScAJm8BmT0ftoI+JzlXcQmJfvorIY+1yqFH11U6O783oyiwdk5cZ
	 HE+vaaP25NQhSvj8PmyoqzgUvdDN+oJpf6oCPgcA=
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
Subject: [RFC PATCH 5/6] svcrdma: Coalesce contiguous pages in RDMA Read chunks
Date: Tue,  6 Oct 2026 10:00:27 +0100
Message-ID: <20261006090028.3412544-6-Louis.Kaplan@arm.com>
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

Read chunks currently describe their destination buffers with one
bvec per base page. Coalesce contiguous destination pages to reduce
the number of entries passed to the transport mapping code.

Derive the number of consumed pages from the final page cursor,
since one bvec can now cover several pages.

Limit each iWARP Read context to one memory region: the core
registration code cannot split a coalesced entry between regions.
The force_mr case on other transports remains unresolved.

Update comment for multipage bvecs.

Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
Assisted-by: LLM
---
 drivers/infiniband/core/rw.c      |   7 +--
 net/sunrpc/xprtrdma/svc_rdma_rw.c | 101 ++++++++++++++++++------------
 2 files changed, 65 insertions(+), 43 deletions(-)

diff --git a/drivers/infiniband/core/rw.c b/drivers/infiniband/core/rw.c
index 4fafe393a48c7..f9e0a5b8ea806 100644
--- a/drivers/infiniband/core/rw.c
+++ b/drivers/infiniband/core/rw.c
@@ -706,10 +706,9 @@ int rdma_rw_ctx_init_bvec(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 	 * is a throughput optimization, not a correctness requirement.
 	 * (iWARP, which does require MRs, is handled by the check above.)
 	 *
-	 * The rdma_rw_io_needs_mr() gate is not used here because nr_bvec
-	 * is a raw page count that overstates DMA entry demand -- the bvec
-	 * caller has no post-DMA-coalescing segment count, and feeding the
-	 * inflated count into the MR path exhausts the pool on RDMA READs.
+	 * We do not use max_sgl_rd to switch non-iWARP READs to MRs. Doing so
+	 * would require the MR builder to split multipage bvecs across MRs,
+	 * which it does not yet support. The force_mr case is handled above.
 	 */
 	return rdma_rw_init_map_wrs_bvec(ctx, qp, bvecs, nr_bvec, &iter,
 			remote_addr, rkey, dir);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index a2e1c693b1bc1..074a75d251c96 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -789,54 +789,78 @@ static int svc_rdma_build_read_segment(struct svc_rqst *rqstp,
 {
 	struct svcxprt_rdma *rdma = svc_rdma_rqst_rdma(rqstp);
 	struct svc_rdma_chunk_ctxt *cc = &head->rc_cc;
-	unsigned int bvec_idx, nr_bvec, seg_len, len, total;
+	struct ib_device *dev = rdma->sc_cm_id->device;
+	unsigned int max_bvec_len = svc_rdma_max_bvec_len(rdma);
+	u64 remote_offset = segment->rs_offset;
+	unsigned int nr_bvec, len, remaining, total;
+	unsigned int base_pages;
 	struct svc_rdma_rw_ctxt *ctxt;
 	int ret;
 
-	len = segment->rs_length;
-	if (check_add_overflow(head->rc_pageoff, len, &total))
+	remaining = segment->rs_length;
+	if (check_add_overflow(head->rc_pageoff, remaining, &total))
 		return -EINVAL;
-	nr_bvec = PAGE_ALIGN(total) >> PAGE_SHIFT;
-	ctxt = svc_rdma_get_rw_ctxt(rdma, nr_bvec);
-	if (!ctxt)
-		return -ENOMEM;
-	ctxt->rw_nents = nr_bvec;
-
-	for (bvec_idx = 0; bvec_idx < ctxt->rw_nents; bvec_idx++) {
-		seg_len = min_t(unsigned int, len,
-				PAGE_SIZE - head->rc_pageoff);
-
-		if (!head->rc_pageoff)
-			head->rc_page_count++;
+	base_pages = PAGE_ALIGN(total) >> PAGE_SHIFT;
+	if (!remaining || head->rc_curpage >= rqstp->rq_maxpages ||
+	    base_pages > rqstp->rq_maxpages - head->rc_curpage)
+		goto out_overrun;
+
+	while (remaining) {
+		base_pages = DIV_ROUND_UP(head->rc_pageoff + remaining,
+					  PAGE_SIZE);
+
+		/*
+		 * The bvec MR builder cannot split a coalesced SG entry between
+		 * MRs. iWARP always uses MRs for RDMA Reads, so keep each context
+		 * within one MR. force_mr on other transports remains subject to
+		 * the core limitation.
+		 */
+		if (rdma_protocol_iwarp(dev, rdma->sc_port_num)) {
+			unsigned int nr_mrs = rdma_rw_mr_factor(dev,
+							rdma->sc_port_num,
+							base_pages);
 
-		bvec_set_page(&ctxt->rw_bvec[bvec_idx],
-			      rqstp->rq_pages[head->rc_curpage],
-			      seg_len, head->rc_pageoff);
+			base_pages = DIV_ROUND_UP(base_pages, nr_mrs);
+		}
 
-		head->rc_pageoff += seg_len;
-		if (head->rc_pageoff == PAGE_SIZE) {
-			head->rc_curpage++;
-			head->rc_pageoff = 0;
+		len = min_t(unsigned int, remaining,
+			    (base_pages << PAGE_SHIFT) - head->rc_pageoff);
+		nr_bvec = svc_pages_to_bvecs(NULL,
+					     rqstp->rq_pages + head->rc_curpage,
+					     base_pages, head->rc_pageoff, len,
+					     max_bvec_len);
+		if (!nr_bvec)
+			goto out_overrun;
+		ctxt = svc_rdma_get_rw_ctxt(rdma, nr_bvec);
+		if (!ctxt)
+			return -ENOMEM;
+		ctxt->rw_nents = svc_pages_to_bvecs(ctxt->rw_bvec,
+						    rqstp->rq_pages + head->rc_curpage,
+						    base_pages, head->rc_pageoff, len,
+						    max_bvec_len);
+		if (WARN_ON_ONCE(ctxt->rw_nents != nr_bvec)) {
+			svc_rdma_put_rw_ctxt(rdma, ctxt);
+			goto out_overrun;
 		}
-		len -= seg_len;
+		total = head->rc_pageoff + len;
+		head->rc_curpage += total >> PAGE_SHIFT;
+		head->rc_pageoff = offset_in_page(total);
 
-		if (len && ((head->rc_curpage + 1) > rqstp->rq_maxpages))
-			goto out_put;
-	}
+		ret = svc_rdma_rw_ctx_init(rdma, ctxt, remote_offset,
+					   segment->rs_handle, len,
+					   DMA_FROM_DEVICE);
+		if (ret < 0)
+			return -EIO;
 
-	ret = svc_rdma_rw_ctx_init(rdma, ctxt, segment->rs_offset,
-				   segment->rs_handle, segment->rs_length,
-				   DMA_FROM_DEVICE);
-	if (ret < 0)
-		return -EIO;
+		list_add(&ctxt->rw_list, &cc->cc_rwctxts);
+		cc->cc_sqecount += ret;
+		remote_offset += len;
+		remaining -= len;
+	}
 	percpu_counter_inc(&svcrdma_stat_read);
-
-	list_add(&ctxt->rw_list, &cc->cc_rwctxts);
-	cc->cc_sqecount += ret;
 	return 0;
 
-out_put:
-	svc_rdma_put_rw_ctxt(rdma, ctxt);
+out_overrun:
 	trace_svcrdma_page_overrun_err(&cc->cc_cid, head->rc_curpage);
 	return -EINVAL;
 }
@@ -908,9 +932,6 @@ static int svc_rdma_copy_inline_range(struct svc_rqst *rqstp,
 		page_len = min_t(unsigned int, remaining,
 				 PAGE_SIZE - head->rc_pageoff);
 
-		if (!head->rc_pageoff)
-			head->rc_page_count++;
-
 		dst = page_address(rqstp->rq_pages[head->rc_curpage]);
 		memcpy((unsigned char *)dst + head->rc_pageoff, src + offset, page_len);
 
@@ -1170,6 +1191,8 @@ static void svc_rdma_clear_rqst_pages(struct svc_rqst *rqstp,
 {
 	unsigned int i;
 
+	/* The cursor identifies every page touched while rebuilding the call. */
+	head->rc_page_count = head->rc_curpage + !!head->rc_pageoff;
 	for (i = 0; i < head->rc_page_count; i++) {
 		head->rc_pages[i] = rqstp->rq_pages[i];
 		rqstp->rq_pages[i] = NULL;
-- 
2.43.0

