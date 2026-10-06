Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id E57AE37F333;
	Tue,  6 Oct 2026 09:01:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791277272; cv=none; b=I6bDgnyPbzX+YwAguTyqbatMqIfgppf6YOdUKPqb7rHSgBL1QYhxpnJUYa9zxjBAjuKR5a3EECx16CYaXAimtiuLF/Kcoi0edUq/UzCGXnc0AxfQTIAgv0EPtztM4xYc35KrLosnWP8g+GJt3qUzTpITxUKm+sYETosTIeqzN00=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791277272; c=relaxed/simple;
	bh=habC6Teu9KcqdMCOKZxsiUCoom1+QelBvnB1D+2y1kY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pqqgx7O7L+rBY+1ZhfpyJPl2btNgyvDJnSO92iRaanjs42sDmAGTGmQ4JUsaXxIfugwzHu05rjUjNkB86BOOLQaVCksEJqWETwQ9HjPC0wOKC1NNsBGAvIpRQNkDj08xd/CLGEnvptpg1or7YTDZLoaJDygzrq1uOayVLjHa0zA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=RhkBi63S; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="RhkBi63S"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2AB541684;
	Tue,  6 Oct 2026 02:01:07 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id CDD4C3F86F;
	Tue,  6 Oct 2026 02:01:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791277270; bh=habC6Teu9KcqdMCOKZxsiUCoom1+QelBvnB1D+2y1kY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=RhkBi63SSH4r2Tyo8AH5/ruKW36Su9PDN/X8rbrXnff0wHjORDXK8bprarc8Ij1GP
	 R0iGRuEYukUVSDA6axk91iKHHsX3R/3seiHcrnbKN7gF6nSvjt+GlUt+O3wIQ7IR0c
	 5rjZmOvdnOBaw/F5ZM5LaACB0L8SODsBf2HZTPso=
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
Subject: [RFC PATCH 3/6] svcrdma: Coalesce contiguous pages when mapping replies
Date: Tue,  6 Oct 2026 10:00:25 +0100
Message-ID: <20261006090028.3412544-4-Louis.Kaplan@arm.com>
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

Mapping reply pagelists one page at a time uses a separate direct
memory access (DMA) mapping and scatter/gather entry (SGE) for
each base page, even when those pages are physically contiguous.

Instead, map contiguous runs as multipage bvecs, capped by the device's
mapping and segment length limits. Use the same coalescing rules
when counting SGEs for the pull-up decision, avoiding unnecessary
copying when the coalesced reply fits the Send SGE limit.

Virtual-mapping devices bypass device-limit check.

Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
Assisted-by: LLM
---
 include/linux/sunrpc/svc_rdma.h       |  15 ++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c | 112 +++++++++++++++-----------
 2 files changed, 82 insertions(+), 45 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 71bd5bcc5ce2a..c296bf8b8b1e3 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -42,6 +42,7 @@
 
 #ifndef SVC_RDMA_H
 #define SVC_RDMA_H
+#include <linux/dma-mapping.h>
 #include <linux/llist.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svcsock.h>
@@ -134,6 +135,20 @@ static inline struct svcxprt_rdma *svc_rdma_rqst_rdma(struct svc_rqst *rqstp)
 	return container_of(xprt, struct svcxprt_rdma, sc_xprt);
 }
 
+static inline unsigned int
+svc_rdma_max_bvec_len(const struct svcxprt_rdma *rdma)
+{
+	struct ib_device *device = rdma->sc_cm_id->device;
+
+	if (ib_uses_virt_dma(device))
+		return UINT_MAX;
+
+	/* Respect both DMA mapping and RDMA device segment limits. */
+	return min_t(size_t,
+		     dma_max_mapping_size(device->dma_device),
+		     ib_dma_max_seg_size(device));
+}
+
 /*
  * Default connection parameters
  */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index efa352ddf9d71..9f2e3ee3c2936 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -260,10 +260,8 @@ static void svc_rdma_send_ctxt_unmap(struct svcxprt_rdma *rdma,
 		trace_svcrdma_dma_unmap_page(&ctxt->sc_cid,
 					     ctxt->sc_sges[i].addr,
 					     ctxt->sc_sges[i].length);
-		ib_dma_unmap_page(device,
-				  ctxt->sc_sges[i].addr,
-				  ctxt->sc_sges[i].length,
-				  DMA_TO_DEVICE);
+		ib_dma_unmap_bvec(device, ctxt->sc_sges[i].addr,
+				  ctxt->sc_sges[i].length, DMA_TO_DEVICE);
 	}
 }
 
@@ -730,44 +728,45 @@ svc_rdma_encode_reply_chunk(struct svc_rdma_recv_ctxt *rctxt,
 }
 
 struct svc_rdma_map_data {
-	struct svcxprt_rdma		*md_rdma;
 	struct svc_rdma_send_ctxt	*md_ctxt;
+	unsigned int			md_max_bvec_len;
 };
 
 /**
- * svc_rdma_page_dma_map - DMA map one page
+ * svc_rdma_bvec_dma_map - DMA map one physically contiguous bvec
  * @data: pointer to arguments
- * @page: struct page to DMA map
- * @offset: offset into the page
- * @len: number of bytes to map
+ * @bv: contiguous range to DMA map
  *
  * Returns:
  *   %0 if DMA mapping was successful
- *   %-EIO if the page cannot be DMA mapped
+ *   %-EIO if the range cannot be DMA mapped
  */
-static int svc_rdma_page_dma_map(void *data, struct page *page,
-				 unsigned long offset, unsigned int len)
+static int svc_rdma_bvec_dma_map(void *data, struct bio_vec *bv)
 {
 	struct svc_rdma_map_data *args = data;
-	struct svcxprt_rdma *rdma = args->md_rdma;
 	struct svc_rdma_send_ctxt *ctxt = args->md_ctxt;
+	struct svcxprt_rdma *rdma = ctxt->sc_rdma;
 	struct ib_device *dev = rdma->sc_cm_id->device;
 	dma_addr_t dma_addr;
 
+	if (bv->bv_len > args->md_max_bvec_len)
+		return -EIO;
+	if (WARN_ON_ONCE(ctxt->sc_send_wr.num_sge >= rdma->sc_max_send_sges))
+		return -EIO;
 	++ctxt->sc_cur_sge_no;
 
-	dma_addr = ib_dma_map_page(dev, page, offset, len, DMA_TO_DEVICE);
+	dma_addr = ib_dma_map_bvec(dev, bv, DMA_TO_DEVICE);
 	if (ib_dma_mapping_error(dev, dma_addr))
 		goto out_maperr;
 
-	trace_svcrdma_dma_map_page(&ctxt->sc_cid, dma_addr, len);
+	trace_svcrdma_dma_map_page(&ctxt->sc_cid, dma_addr, bv->bv_len);
 	ctxt->sc_sges[ctxt->sc_cur_sge_no].addr = dma_addr;
-	ctxt->sc_sges[ctxt->sc_cur_sge_no].length = len;
+	ctxt->sc_sges[ctxt->sc_cur_sge_no].length = bv->bv_len;
 	ctxt->sc_send_wr.num_sge++;
 	return 0;
 
 out_maperr:
-	trace_svcrdma_dma_map_err(&ctxt->sc_cid, dma_addr, len);
+	trace_svcrdma_dma_map_err(&ctxt->sc_cid, dma_addr, bv->bv_len);
 	return -EIO;
 }
 
@@ -776,20 +775,18 @@ static int svc_rdma_page_dma_map(void *data, struct page *page,
  * @data: pointer to arguments
  * @iov: kvec to DMA map
  *
- * ib_dma_map_page() is used here because svc_rdma_dma_unmap()
- * handles DMA-unmap and it uses ib_dma_unmap_page() exclusively.
- *
  * Returns:
  *   %0 if DMA mapping was successful
  *   %-EIO if the iovec cannot be DMA mapped
  */
 static int svc_rdma_iov_dma_map(void *data, const struct kvec *iov)
 {
+	struct bio_vec bv;
+
 	if (!iov->iov_len)
 		return 0;
-	return svc_rdma_page_dma_map(data, virt_to_page(iov->iov_base),
-				     offset_in_page(iov->iov_base),
-				     iov->iov_len);
+	bvec_set_virt(&bv, iov->iov_base, iov->iov_len);
+	return svc_rdma_bvec_dma_map(data, &bv);
 }
 
 /**
@@ -798,7 +795,7 @@ static int svc_rdma_iov_dma_map(void *data, const struct kvec *iov)
  * @data: pointer to arguments
  *
  * Returns:
- *   %0 if DMA mapping was successful
+ *   The number of mapped bytes if DMA mapping was successful
  *   %-EIO if DMA mapping failed
  *
  * On failure, any DMA mappings that have been already done must be
@@ -806,9 +803,11 @@ static int svc_rdma_iov_dma_map(void *data, const struct kvec *iov)
  */
 static int svc_rdma_xb_dma_map(const struct xdr_buf *xdr, void *data)
 {
-	unsigned int len, remaining;
+	struct svc_rdma_map_data *args = data;
+	unsigned int remaining;
 	unsigned long pageoff;
 	struct page **ppages;
+	unsigned int nr_pages;
 	int ret;
 
 	ret = svc_rdma_iov_dma_map(data, &xdr->head[0]);
@@ -818,15 +817,25 @@ static int svc_rdma_xb_dma_map(const struct xdr_buf *xdr, void *data)
 	ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
 	pageoff = offset_in_page(xdr->page_base);
 	remaining = xdr->page_len;
+	nr_pages = DIV_ROUND_UP(pageoff + remaining, PAGE_SIZE);
 	while (remaining) {
-		len = min_t(u32, PAGE_SIZE - pageoff, remaining);
-
-		ret = svc_rdma_page_dma_map(data, *ppages++, pageoff, len);
+		struct bio_vec bv;
+		unsigned int bytes = svc_pages_to_bvec(&bv, ppages,
+				nr_pages, pageoff, remaining,
+				args->md_max_bvec_len);
+		unsigned int advanced =
+				(pageoff + bytes) >> PAGE_SHIFT;
+
+		if (!bytes)
+			return -EIO;
+		ret = svc_rdma_bvec_dma_map(data, &bv);
 		if (ret < 0)
 			return ret;
 
-		remaining -= len;
-		pageoff = 0;
+		pageoff = offset_in_page(pageoff + bytes);
+		ppages += advanced;
+		nr_pages -= advanced;
+		remaining -= bytes;
 	}
 
 	ret = svc_rdma_iov_dma_map(data, &xdr->tail[0]);
@@ -836,10 +845,27 @@ static int svc_rdma_xb_dma_map(const struct xdr_buf *xdr, void *data)
 	return xdr->len;
 }
 
+static unsigned int
+svc_rdma_xb_page_sges(const struct xdr_buf *xdr,
+		      unsigned int max_bvec_len)
+{
+	const unsigned long offset = offset_in_page(xdr->page_base);
+	const unsigned int nr_pages =
+		DIV_ROUND_UP(offset + xdr->page_len, PAGE_SIZE);
+	struct page *const *ppages;
+
+	if (!xdr->page_len)
+		return 0;
+	ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
+	return svc_pages_to_bvecs(NULL, ppages, nr_pages, offset,
+				  xdr->page_len, max_bvec_len);
+}
+
 struct svc_rdma_pullup_data {
 	u8		*pd_dest;
 	unsigned int	pd_length;
 	unsigned int	pd_num_sges;
+	unsigned int	pd_max_bvec_len;
 };
 
 /**
@@ -848,25 +874,22 @@ struct svc_rdma_pullup_data {
  * @data: pointer to arguments
  *
  * Returns:
- *   Number of SGEs needed to Send the contents of @xdr inline
+ *   %0 if the SGE count was updated
+ *   %-EIO if the page list cannot be described
  */
 static int svc_rdma_xb_count_sges(const struct xdr_buf *xdr,
 				  void *data)
 {
 	struct svc_rdma_pullup_data *args = data;
-	unsigned int remaining;
-	unsigned long offset;
+	unsigned int page_sges =
+		svc_rdma_xb_page_sges(xdr, args->pd_max_bvec_len);
 
 	if (xdr->head[0].iov_len)
 		++args->pd_num_sges;
 
-	offset = offset_in_page(xdr->page_base);
-	remaining = xdr->page_len;
-	while (remaining) {
-		++args->pd_num_sges;
-		remaining -= min_t(u32, PAGE_SIZE - offset, remaining);
-		offset = 0;
-	}
+	if (xdr->page_len && !page_sges)
+		return -EIO;
+	args->pd_num_sges += page_sges;
 
 	if (xdr->tail[0].iov_len)
 		++args->pd_num_sges;
@@ -896,6 +919,7 @@ static int svc_rdma_check_pull_up(const struct svcxprt_rdma *rdma,
 	struct svc_rdma_pullup_data args = {
 		.pd_length	= sctxt->sc_hdrbuf.len,
 		.pd_num_sges	= 1,
+		.pd_max_bvec_len = svc_rdma_max_bvec_len(rdma),
 	};
 	int ret;
 
@@ -964,7 +988,6 @@ static int svc_rdma_xb_linearize(const struct xdr_buf *xdr,
 
 /**
  * svc_rdma_pull_up_reply_msg - Copy Reply into a single buffer
- * @rdma: controlling transport
  * @sctxt: send_ctxt for the Send WR; xprt hdr is already prepared
  * @write_pcl: Write chunk list provided by client
  * @xdr: prepared xdr_buf containing RPC message
@@ -979,8 +1002,7 @@ static int svc_rdma_xb_linearize(const struct xdr_buf *xdr,
  *   %0 if pull-up was successful
  *   %-EMSGSIZE if a buffer manipulation problem occurred
  */
-static int svc_rdma_pull_up_reply_msg(const struct svcxprt_rdma *rdma,
-				      struct svc_rdma_send_ctxt *sctxt,
+static int svc_rdma_pull_up_reply_msg(struct svc_rdma_send_ctxt *sctxt,
 				      const struct svc_rdma_pcl *write_pcl,
 				      const struct xdr_buf *xdr)
 {
@@ -1021,8 +1043,8 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 			   const struct xdr_buf *xdr)
 {
 	struct svc_rdma_map_data args = {
-		.md_rdma	= rdma,
 		.md_ctxt	= sctxt,
+		.md_max_bvec_len = svc_rdma_max_bvec_len(rdma),
 	};
 	int ret;
 
@@ -1043,7 +1065,7 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 	if (ret < 0)
 		return ret;
 	if (ret)
-		return svc_rdma_pull_up_reply_msg(rdma, sctxt, write_pcl, xdr);
+		return svc_rdma_pull_up_reply_msg(sctxt, write_pcl, xdr);
 
 	return pcl_process_nonpayloads(write_pcl, xdr,
 				       svc_rdma_xb_dma_map, &args);
-- 
2.43.0

