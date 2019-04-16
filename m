Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E9F6C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DB22C217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Un2KIU8U"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726946AbfDPNhg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:37:36 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:46685 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726215AbfDPNhg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:37:36 -0400
Received: by mail-io1-f68.google.com with SMTP id p23so17593799iol.13;
        Tue, 16 Apr 2019 06:37:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=jCK1EP0XtK2rAAh2eJtHbaFK2vX3Bl19vYrWTj080hU=;
        b=Un2KIU8U9pLvwpEhMRXyVWbiiv7ablOkSO61Ifj3YNLQTVP924td8alQ4MQhJVGk6X
         UiZXXW4xp3t9d9/hhxEb/MkXsBM2YadXexN+a/6IXspGOfI5bW17Uyyp+5dQ0up7ZIl9
         XfipPzkGftDEOXmQnCb69iiy6epA6gf3wa8bXu9M4WDaQxr3Af0iDwxJj2Q0CgNz4Iy6
         lTOHujQ3ynU/oMgHSLm/cXz5uW6AkrZaTY6s71M96hUN9limM/6iigniKSyjKCL9w1B/
         Su8mgxD1JFkiXJiIN3iiUsFHHDk8VkZh22L5aOAcTu2R5kjFdRxu4mc1cuP3x6s6R17R
         nlYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=jCK1EP0XtK2rAAh2eJtHbaFK2vX3Bl19vYrWTj080hU=;
        b=RdDbPtLqvgMs+dSFWrLrZAamOxSMYn120k34AUgd6wiXb+ME82jDpt5kpRk642KW24
         nNJXDNRy2Tdy4LprgC2Ms6bckUyhvvPDFLGgmcXF1N4H/Ck+bLD/tUlC0QWPJTdJvJ5U
         f2C5PeXcCyXXV+GMc19ZIBeT+FK3cTZOEGoQBtVcmr070nWhy7o2Hs2KKVc4/ooQfyd6
         OmzC9Mht0XWh3nBtBIfGAt8q1B9/jQlfdVQYx1zVIUuDt6zOviu0F2U1O+l4cyaCTt+T
         i/FiEkTL1iYpk99ZzXZ/y0eUxtB9QFrxOEtDC8/HfcBLD7s4U6zs7TVxxxNWuZGzYjGT
         9G9w==
X-Gm-Message-State: APjAAAW+Y/4PzixbIwmcnM7ckbGt3NNB0n0UzpwGDLhOTvhDgSanFz5k
        FqHbDT6cmmf0xt6Ux07TZvKXzSO6
X-Google-Smtp-Source: APXvYqw5lSEI9PLMUGlHBrmwcv2RXqZKOuAibON8DnuItqNBaNXdleEwAVYeHsr6s3VTYaMH376lzw==
X-Received: by 2002:a6b:b386:: with SMTP id c128mr52998754iof.218.1555421854811;
        Tue, 16 Apr 2019 06:37:34 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x79sm9407317ita.17.2019.04.16.06.37.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:37:34 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDbXQN021220;
        Tue, 16 Apr 2019 13:37:33 GMT
Subject: [PATCH v2 08/21] xprtrdma: Clean up regbuf helpers
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:37:33 -0400
Message-ID: <20190416133733.23113.75843.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

For code legibility, clean up the function names to be consistent
with the pattern: "rpcrdma" _ object-type _ action

Also rpcrdma_regbuf_alloc and rpcrdma_regbuf_free no longer have any
callers outside of verbs.c, and can thus be made static.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   47 ++++++++++-----------
 net/sunrpc/xprtrdma/verbs.c     |   88 +++++++++++++++++----------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   27 ++++++++----
 3 files changed, 80 insertions(+), 82 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index cf99c55..231a44b 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -536,22 +536,21 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 /* Prepare an SGE for the RPC-over-RDMA transport header.
  */
-static bool
-rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
-			u32 len)
+static bool rpcrdma_prepare_hdr_sge(struct rpcrdma_xprt *r_xprt,
+				    struct rpcrdma_req *req, u32 len)
 {
 	struct rpcrdma_sendctx *sc = req->rl_sendctx;
 	struct rpcrdma_regbuf *rb = req->rl_rdmabuf;
 	struct ib_sge *sge = sc->sc_sges;
 
-	if (!rpcrdma_dma_map_regbuf(ia, rb))
+	if (!rpcrdma_regbuf_dma_map(r_xprt, rb))
 		goto out_regbuf;
 	sge->addr = rdmab_addr(rb);
 	sge->length = len;
 	sge->lkey = rdmab_lkey(rb);
 
-	ib_dma_sync_single_for_device(rdmab_device(rb), sge->addr,
-				      sge->length, DMA_TO_DEVICE);
+	ib_dma_sync_single_for_device(rdmab_device(rb), sge->addr, sge->length,
+				      DMA_TO_DEVICE);
 	sc->sc_wr.num_sge++;
 	return true;
 
@@ -563,22 +562,21 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 /* Prepare the Send SGEs. The head and tail iovec, and each entry
  * in the page list, gets its own SGE.
  */
-static bool
-rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
-			 struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
+static bool rpcrdma_prepare_msg_sges(struct rpcrdma_xprt *r_xprt,
+				     struct rpcrdma_req *req,
+				     struct xdr_buf *xdr,
+				     enum rpcrdma_chunktype rtype)
 {
 	struct rpcrdma_sendctx *sc = req->rl_sendctx;
 	unsigned int sge_no, page_base, len, remaining;
 	struct rpcrdma_regbuf *rb = req->rl_sendbuf;
-	struct ib_device *device = ia->ri_device;
 	struct ib_sge *sge = sc->sc_sges;
-	u32 lkey = ia->ri_pd->local_dma_lkey;
 	struct page *page, **ppages;
 
 	/* The head iovec is straightforward, as it is already
 	 * DMA-mapped. Sync the content that has changed.
 	 */
-	if (!rpcrdma_dma_map_regbuf(ia, rb))
+	if (!rpcrdma_regbuf_dma_map(r_xprt, rb))
 		goto out_regbuf;
 	sge_no = 1;
 	sge[sge_no].addr = rdmab_addr(rb);
@@ -626,13 +624,14 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 				goto out_mapping_overflow;
 
 			len = min_t(u32, PAGE_SIZE - page_base, remaining);
-			sge[sge_no].addr = ib_dma_map_page(device, *ppages,
-							   page_base, len,
-							   DMA_TO_DEVICE);
-			if (ib_dma_mapping_error(device, sge[sge_no].addr))
+			sge[sge_no].addr =
+				ib_dma_map_page(rdmab_device(rb), *ppages,
+						page_base, len, DMA_TO_DEVICE);
+			if (ib_dma_mapping_error(rdmab_device(rb),
+						 sge[sge_no].addr))
 				goto out_mapping_err;
 			sge[sge_no].length = len;
-			sge[sge_no].lkey = lkey;
+			sge[sge_no].lkey = rdmab_lkey(rb);
 
 			sc->sc_unmap_count++;
 			ppages++;
@@ -653,13 +652,13 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 map_tail:
 		sge_no++;
-		sge[sge_no].addr = ib_dma_map_page(device, page,
-						   page_base, len,
-						   DMA_TO_DEVICE);
-		if (ib_dma_mapping_error(device, sge[sge_no].addr))
+		sge[sge_no].addr =
+			ib_dma_map_page(rdmab_device(rb), page, page_base, len,
+					DMA_TO_DEVICE);
+		if (ib_dma_mapping_error(rdmab_device(rb), sge[sge_no].addr))
 			goto out_mapping_err;
 		sge[sge_no].length = len;
-		sge[sge_no].lkey = lkey;
+		sge[sge_no].lkey = rdmab_lkey(rb);
 		sc->sc_unmap_count++;
 	}
 
@@ -707,11 +706,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	req->rl_sendctx->sc_req = req;
 	__clear_bit(RPCRDMA_REQ_F_TX_RESOURCES, &req->rl_flags);
 
-	if (!rpcrdma_prepare_hdr_sge(&r_xprt->rx_ia, req, hdrlen))
+	if (!rpcrdma_prepare_hdr_sge(r_xprt, req, hdrlen))
 		return -EIO;
 
 	if (rtype != rpcrdma_areadch)
-		if (!rpcrdma_prepare_msg_sges(&r_xprt->rx_ia, req, xdr, rtype))
+		if (!rpcrdma_prepare_msg_sges(r_xprt, req, xdr, rtype))
 			return -EIO;
 
 	return 0;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 734dfe5..81548fc2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -76,7 +76,11 @@
 static void rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc);
 static void rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_destroy(struct rpcrdma_buffer *buf);
-static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
+static struct rpcrdma_regbuf *
+rpcrdma_regbuf_alloc(size_t size, enum dma_data_direction direction,
+		     gfp_t flags);
+static void rpcrdma_regbuf_dma_unmap(struct rpcrdma_regbuf *rb);
+static void rpcrdma_regbuf_free(struct rpcrdma_regbuf *rb);
 static void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
 
 /* Wait for outstanding transport work to finish.
@@ -437,11 +441,11 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	 * mappings and MRs are gone.
 	 */
 	list_for_each_entry(rep, &buf->rb_recv_bufs, rr_list)
-		rpcrdma_dma_unmap_regbuf(rep->rr_rdmabuf);
+		rpcrdma_regbuf_dma_unmap(rep->rr_rdmabuf);
 	list_for_each_entry(req, &buf->rb_allreqs, rl_all) {
-		rpcrdma_dma_unmap_regbuf(req->rl_rdmabuf);
-		rpcrdma_dma_unmap_regbuf(req->rl_sendbuf);
-		rpcrdma_dma_unmap_regbuf(req->rl_recvbuf);
+		rpcrdma_regbuf_dma_unmap(req->rl_rdmabuf);
+		rpcrdma_regbuf_dma_unmap(req->rl_sendbuf);
+		rpcrdma_regbuf_dma_unmap(req->rl_recvbuf);
 	}
 	rpcrdma_mrs_destroy(buf);
 	ib_dealloc_pd(ia->ri_pd);
@@ -1014,17 +1018,17 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, size_t size,
 	if (req == NULL)
 		goto out1;
 
-	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE, DMA_TO_DEVICE, flags);
+	rb = rpcrdma_regbuf_alloc(RPCRDMA_HDRBUF_SIZE, DMA_TO_DEVICE, flags);
 	if (!rb)
 		goto out2;
 	req->rl_rdmabuf = rb;
 	xdr_buf_init(&req->rl_hdrbuf, rdmab_data(rb), rdmab_length(rb));
 
-	req->rl_sendbuf = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, flags);
+	req->rl_sendbuf = rpcrdma_regbuf_alloc(size, DMA_TO_DEVICE, flags);
 	if (!req->rl_sendbuf)
 		goto out3;
 
-	req->rl_recvbuf = rpcrdma_alloc_regbuf(size, DMA_NONE, flags);
+	req->rl_recvbuf = rpcrdma_regbuf_alloc(size, DMA_NONE, flags);
 	if (!req->rl_recvbuf)
 		goto out4;
 
@@ -1055,7 +1059,7 @@ static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
 	if (rep == NULL)
 		goto out;
 
-	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(cdata->inline_rsize,
+	rep->rr_rdmabuf = rpcrdma_regbuf_alloc(cdata->inline_rsize,
 					       DMA_FROM_DEVICE, GFP_KERNEL);
 	if (!rep->rr_rdmabuf)
 		goto out_free;
@@ -1138,7 +1142,7 @@ static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
 
 static void rpcrdma_rep_destroy(struct rpcrdma_rep *rep)
 {
-	rpcrdma_free_regbuf(rep->rr_rdmabuf);
+	rpcrdma_regbuf_free(rep->rr_rdmabuf);
 	kfree(rep);
 }
 
@@ -1154,9 +1158,9 @@ static void rpcrdma_rep_destroy(struct rpcrdma_rep *rep)
 {
 	list_del(&req->rl_all);
 
-	rpcrdma_free_regbuf(req->rl_recvbuf);
-	rpcrdma_free_regbuf(req->rl_sendbuf);
-	rpcrdma_free_regbuf(req->rl_rdmabuf);
+	rpcrdma_regbuf_free(req->rl_recvbuf);
+	rpcrdma_regbuf_free(req->rl_sendbuf);
+	rpcrdma_regbuf_free(req->rl_rdmabuf);
 	kfree(req);
 }
 
@@ -1366,20 +1370,14 @@ struct rpcrdma_req *
 	}
 }
 
-/**
- * rpcrdma_alloc_regbuf - allocate and DMA-map memory for SEND/RECV buffers
- * @size: size of buffer to be allocated, in bytes
- * @direction: direction of data movement
- * @flags: GFP flags
- *
- * Returns a pointer to a rpcrdma_regbuf object, or NULL.
+/* Returns a pointer to a rpcrdma_regbuf object, or NULL.
  *
  * xprtrdma uses a regbuf for posting an outgoing RDMA SEND, or for
  * receiving the payload of RDMA RECV operations. During Long Calls
  * or Replies they may be registered externally via frwr_map.
  */
-struct rpcrdma_regbuf *
-rpcrdma_alloc_regbuf(size_t size, enum dma_data_direction direction,
+static struct rpcrdma_regbuf *
+rpcrdma_regbuf_alloc(size_t size, enum dma_data_direction direction,
 		     gfp_t flags)
 {
 	struct rpcrdma_regbuf *rb;
@@ -1416,7 +1414,7 @@ bool rpcrdma_regbuf_realloc(struct rpcrdma_regbuf *rb, size_t size, gfp_t flags)
 	if (!buf)
 		return false;
 
-	rpcrdma_dma_unmap_regbuf(rb);
+	rpcrdma_regbuf_dma_unmap(rb);
 	kfree(rb->rg_data);
 
 	rb->rg_data = buf;
@@ -1425,34 +1423,33 @@ bool rpcrdma_regbuf_realloc(struct rpcrdma_regbuf *rb, size_t size, gfp_t flags)
 }
 
 /**
- * __rpcrdma_map_regbuf - DMA-map a regbuf
- * @ia: controlling rpcrdma_ia
+ * __rpcrdma_regbuf_dma_map - DMA-map a regbuf
+ * @r_xprt: controlling transport instance
  * @rb: regbuf to be mapped
+ *
+ * Returns true if the buffer is now DMA mapped to @r_xprt's device
  */
-bool
-__rpcrdma_dma_map_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
+bool __rpcrdma_regbuf_dma_map(struct rpcrdma_xprt *r_xprt,
+			      struct rpcrdma_regbuf *rb)
 {
-	struct ib_device *device = ia->ri_device;
+	struct ib_device *device = r_xprt->rx_ia.ri_device;
 
 	if (rb->rg_direction == DMA_NONE)
 		return false;
 
-	rb->rg_iov.addr = ib_dma_map_single(device,
-					    rdmab_data(rb),
-					    rdmab_length(rb),
-					    rb->rg_direction);
+	rb->rg_iov.addr = ib_dma_map_single(device, rdmab_data(rb),
+					    rdmab_length(rb), rb->rg_direction);
 	if (ib_dma_mapping_error(device, rdmab_addr(rb))) {
 		trace_xprtrdma_dma_maperr(rdmab_addr(rb));
 		return false;
 	}
 
 	rb->rg_device = device;
-	rb->rg_iov.lkey = ia->ri_pd->local_dma_lkey;
+	rb->rg_iov.lkey = r_xprt->rx_ia.ri_pd->local_dma_lkey;
 	return true;
 }
 
-static void
-rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb)
+static void rpcrdma_regbuf_dma_unmap(struct rpcrdma_regbuf *rb)
 {
 	if (!rb)
 		return;
@@ -1460,19 +1457,14 @@ bool rpcrdma_regbuf_realloc(struct rpcrdma_regbuf *rb, size_t size, gfp_t flags)
 	if (!rpcrdma_regbuf_is_mapped(rb))
 		return;
 
-	ib_dma_unmap_single(rb->rg_device, rdmab_addr(rb),
-			    rdmab_length(rb), rb->rg_direction);
+	ib_dma_unmap_single(rb->rg_device, rdmab_addr(rb), rdmab_length(rb),
+			    rb->rg_direction);
 	rb->rg_device = NULL;
 }
 
-/**
- * rpcrdma_free_regbuf - deregister and free registered buffer
- * @rb: regbuf to be deregistered and freed
- */
-void
-rpcrdma_free_regbuf(struct rpcrdma_regbuf *rb)
+static void rpcrdma_regbuf_free(struct rpcrdma_regbuf *rb)
 {
-	rpcrdma_dma_unmap_regbuf(rb);
+	rpcrdma_regbuf_dma_unmap(rb);
 	if (rb)
 		kfree(rb->rg_data);
 	kfree(rb);
@@ -1547,11 +1539,9 @@ bool rpcrdma_regbuf_realloc(struct rpcrdma_regbuf *rb, size_t size, gfp_t flags)
 		}
 
 		rb = rep->rr_rdmabuf;
-		if (!rpcrdma_regbuf_is_mapped(rb)) {
-			if (!__rpcrdma_dma_map_regbuf(&r_xprt->rx_ia, rb)) {
-				rpcrdma_recv_buffer_put(rep);
-				break;
-			}
+		if (!rpcrdma_regbuf_dma_map(r_xprt, rb)) {
+			rpcrdma_recv_buffer_put(rep);
+			break;
 		}
 
 		trace_xprtrdma_post_recv(rep->rr_recv_wr.wr_cqe);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 751d476..b942c9d 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -550,25 +550,34 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, size_t size,
 void rpcrdma_buffer_put(struct rpcrdma_req *);
 void rpcrdma_recv_buffer_put(struct rpcrdma_rep *);
 
-struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
-					    gfp_t);
 bool rpcrdma_regbuf_realloc(struct rpcrdma_regbuf *rb, size_t size,
 			    gfp_t flags);
-bool __rpcrdma_dma_map_regbuf(struct rpcrdma_ia *, struct rpcrdma_regbuf *);
-void rpcrdma_free_regbuf(struct rpcrdma_regbuf *);
+bool __rpcrdma_regbuf_dma_map(struct rpcrdma_xprt *r_xprt,
+			      struct rpcrdma_regbuf *rb);
 
-static inline bool
-rpcrdma_regbuf_is_mapped(struct rpcrdma_regbuf *rb)
+/**
+ * rpcrdma_regbuf_is_mapped - check if buffer is DMA mapped
+ *
+ * Returns true if the buffer is now mapped to rb->rg_device.
+ */
+static inline bool rpcrdma_regbuf_is_mapped(struct rpcrdma_regbuf *rb)
 {
 	return rb->rg_device != NULL;
 }
 
-static inline bool
-rpcrdma_dma_map_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
+/**
+ * rpcrdma_regbuf_dma_map - DMA-map a regbuf
+ * @r_xprt: controlling transport instance
+ * @rb: regbuf to be mapped
+ *
+ * Returns true if the buffer is currently DMA mapped.
+ */
+static inline bool rpcrdma_regbuf_dma_map(struct rpcrdma_xprt *r_xprt,
+					  struct rpcrdma_regbuf *rb)
 {
 	if (likely(rpcrdma_regbuf_is_mapped(rb)))
 		return true;
-	return __rpcrdma_dma_map_regbuf(ia, rb);
+	return __rpcrdma_regbuf_dma_map(r_xprt, rb);
 }
 
 /*

