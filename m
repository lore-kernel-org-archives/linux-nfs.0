Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C27EC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E62B121773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pvx9VxdJ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730482AbfDXNj4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:56 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:37630 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730462AbfDXNj4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:56 -0400
Received: by mail-io1-f66.google.com with SMTP id a23so12073934iot.4;
        Wed, 24 Apr 2019 06:39:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=fsBiJ/lpw6BWT4kWAPYE8AsUldwtc5l59+sk/CebKOo=;
        b=Pvx9VxdJId9jStPYKCPeN5QZWt1uPe6qxPkpY/ZkYMwmW/Ftyuvf82lTnJw3wVyDF5
         NvgoMat6Pg1wW5PmUlW3aTBNElzLtPSZMAa2RvN6ALK8+CN0y0PxMm4KBhsBbEaimjzt
         T3Ak5oG4cqBYjQ+XIpHhuUNf8iNk2ts5FChPoV9Iz+lRkg0QK/NKXXHQDueY9ocIQ20k
         spV30jgi+GLRf9C6cfqqC0XfNQrSwmU16te7ZkFlSLywgCFfTyFNMhjGs8iZLb+a8rVK
         Zv3IKcbVznURS16fAcHiot1qsPZbDZ76Di1TUHHVURct4e8nwUFezDMN9w6UPUYJmEA6
         qCdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=fsBiJ/lpw6BWT4kWAPYE8AsUldwtc5l59+sk/CebKOo=;
        b=kLoXxzH7wH7TgXraWmeZ34vnooFr73BKLL/TsxJUDx0Ck6mb65yHW/Z6R4HYyU4N3f
         9lDpHnm0vlVmiADZK1NaMhZvb9W9X2kU8/5xtrrYOB3Adpr0dF/CWgBqR+9UfCeDHUly
         iCr6BQfG7L376GGUSPZPU12fflkAW1N4u2D61iSfWsSXidhSrOKnLrjMaFc8oQOh58wp
         /8kq2b2pV0KxjOkOMqjx9vgABsK/d0FOkjy+7vbxNey9pbLmsDd1EPeMRExczZQMxqmM
         suB85ZheLrvolIG1B8KPiI6LfBs+3Vv+2yOg5qDQYYUdjwTQCEKQA2WEK/aOerNXcgwr
         tBvQ==
X-Gm-Message-State: APjAAAW8WWdpti7MPW2TT8VKkYtJ01uHR7GA6OOn52gRpqT55Oie/Ptu
        QFJpI30mcXfpUwMKeianGarfg1is
X-Google-Smtp-Source: APXvYqyWjdpCxY90WFNWDhomV2KVUKTMsLYUJBdOrNwOxb0+G7eIXEWKyGqsaNf9FY80Q/+44bVhXg==
X-Received: by 2002:a6b:f008:: with SMTP id w8mr9342740ioc.251.1556113194878;
        Wed, 24 Apr 2019 06:39:54 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l20sm114996ioh.83.2019.04.24.06.39.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:54 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODdrcM011304;
        Wed, 24 Apr 2019 13:39:53 GMT
Subject: [PATCH v3 12/21] xprtrdma: Clean up sendctx functions
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:53 -0400
Message-ID: <20190424133953.5077.5363.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Minor clean-ups I've stumbled on since sendctx was merged last year.
In particular, making Send completion processing more efficient
appears to have a measurable impact on IOPS throughput.

Note: test_and_clear_bit() returns a value, thus an explicit memory
barrier is not necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   27 ++++++++++++---------------
 net/sunrpc/xprtrdma/verbs.c     |   17 ++++++++---------
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 +++--
 3 files changed, 23 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 45cba06..5cb060c 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -508,30 +508,26 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 }
 
 /**
- * rpcrdma_unmap_sendctx - DMA-unmap Send buffers
+ * rpcrdma_sendctx_unmap - DMA-unmap Send buffer
  * @sc: sendctx containing SGEs to unmap
  *
  */
-void
-rpcrdma_unmap_sendctx(struct rpcrdma_sendctx *sc)
+void rpcrdma_sendctx_unmap(struct rpcrdma_sendctx *sc)
 {
-	struct rpcrdma_ia *ia = &sc->sc_xprt->rx_ia;
 	struct ib_sge *sge;
-	unsigned int count;
 
 	/* The first two SGEs contain the transport header and
 	 * the inline buffer. These are always left mapped so
 	 * they can be cheaply re-used.
 	 */
-	sge = &sc->sc_sges[2];
-	for (count = sc->sc_unmap_count; count; ++sge, --count)
-		ib_dma_unmap_page(ia->ri_device,
-				  sge->addr, sge->length, DMA_TO_DEVICE);
+	for (sge = &sc->sc_sges[2]; sc->sc_unmap_count;
+	     ++sge, --sc->sc_unmap_count)
+		ib_dma_unmap_page(sc->sc_device, sge->addr, sge->length,
+				  DMA_TO_DEVICE);
 
-	if (test_and_clear_bit(RPCRDMA_REQ_F_TX_RESOURCES, &sc->sc_req->rl_flags)) {
-		smp_mb__after_atomic();
+	if (test_and_clear_bit(RPCRDMA_REQ_F_TX_RESOURCES,
+			       &sc->sc_req->rl_flags))
 		wake_up_bit(&sc->sc_req->rl_flags, RPCRDMA_REQ_F_TX_RESOURCES);
-	}
 }
 
 /* Prepare an SGE for the RPC-over-RDMA transport header.
@@ -578,6 +574,7 @@ static bool rpcrdma_prepare_msg_sges(struct rpcrdma_xprt *r_xprt,
 	 */
 	if (!rpcrdma_regbuf_dma_map(r_xprt, rb))
 		goto out_regbuf;
+	sc->sc_device = rdmab_device(rb);
 	sge_no = 1;
 	sge[sge_no].addr = rdmab_addr(rb);
 	sge[sge_no].length = xdr->head[0].iov_len;
@@ -673,12 +670,12 @@ static bool rpcrdma_prepare_msg_sges(struct rpcrdma_xprt *r_xprt,
 	return false;
 
 out_mapping_overflow:
-	rpcrdma_unmap_sendctx(sc);
+	rpcrdma_sendctx_unmap(sc);
 	pr_err("rpcrdma: too many Send SGEs (%u)\n", sge_no);
 	return false;
 
 out_mapping_err:
-	rpcrdma_unmap_sendctx(sc);
+	rpcrdma_sendctx_unmap(sc);
 	trace_xprtrdma_dma_maperr(sge[sge_no].addr);
 	return false;
 }
@@ -698,7 +695,7 @@ static bool rpcrdma_prepare_msg_sges(struct rpcrdma_xprt *r_xprt,
 			  struct rpcrdma_req *req, u32 hdrlen,
 			  struct xdr_buf *xdr, enum rpcrdma_chunktype rtype)
 {
-	req->rl_sendctx = rpcrdma_sendctx_get_locked(&r_xprt->rx_buf);
+	req->rl_sendctx = rpcrdma_sendctx_get_locked(r_xprt);
 	if (!req->rl_sendctx)
 		return -EAGAIN;
 	req->rl_sendctx->sc_wr.num_sge = 0;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 81548fc2..1ad2519 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -870,20 +870,20 @@ static unsigned long rpcrdma_sendctx_next(struct rpcrdma_buffer *buf,
 
 /**
  * rpcrdma_sendctx_get_locked - Acquire a send context
- * @buf: transport buffers from which to acquire an unused context
+ * @r_xprt: controlling transport instance
  *
  * Returns pointer to a free send completion context; or NULL if
  * the queue is empty.
  *
  * Usage: Called to acquire an SGE array before preparing a Send WR.
  *
- * The caller serializes calls to this function (per rpcrdma_buffer),
- * and provides an effective memory barrier that flushes the new value
+ * The caller serializes calls to this function (per transport), and
+ * provides an effective memory barrier that flushes the new value
  * of rb_sc_head.
  */
-struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
+struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_xprt *r_xprt)
 {
-	struct rpcrdma_xprt *r_xprt;
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_sendctx *sc;
 	unsigned long next_head;
 
@@ -908,7 +908,6 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 	 * backing up. Cause the caller to pause and try again.
 	 */
 	set_bit(RPCRDMA_BUF_F_EMPTY_SCQ, &buf->rb_flags);
-	r_xprt = container_of(buf, struct rpcrdma_xprt, rx_buf);
 	r_xprt->rx_stats.empty_sendctx_q++;
 	return NULL;
 }
@@ -920,7 +919,7 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
  * Usage: Called from Send completion to return a sendctxt
  * to the queue.
  *
- * The caller serializes calls to this function (per rpcrdma_buffer).
+ * The caller serializes calls to this function (per transport).
  */
 static void
 rpcrdma_sendctx_put_locked(struct rpcrdma_sendctx *sc)
@@ -928,7 +927,7 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 	struct rpcrdma_buffer *buf = &sc->sc_xprt->rx_buf;
 	unsigned long next_tail;
 
-	/* Unmap SGEs of previously completed by unsignaled
+	/* Unmap SGEs of previously completed but unsignaled
 	 * Sends by walking up the queue until @sc is found.
 	 */
 	next_tail = buf->rb_sc_tail;
@@ -936,7 +935,7 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 		next_tail = rpcrdma_sendctx_next(buf, next_tail);
 
 		/* ORDER: item must be accessed _before_ tail is updated */
-		rpcrdma_unmap_sendctx(buf->rb_sc_ctxs[next_tail]);
+		rpcrdma_sendctx_unmap(buf->rb_sc_ctxs[next_tail]);
 
 	} while (buf->rb_sc_ctxs[next_tail] != sc);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 7621e2d..8afb5fc 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -225,6 +225,7 @@ enum {
 struct rpcrdma_sendctx {
 	struct ib_send_wr	sc_wr;
 	struct ib_cqe		sc_cqe;
+	struct ib_device	*sc_device;
 	struct rpcrdma_xprt	*sc_xprt;
 	struct rpcrdma_req	*sc_req;
 	unsigned int		sc_unmap_count;
@@ -536,7 +537,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, size_t size,
 void rpcrdma_req_destroy(struct rpcrdma_req *req);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
-struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf);
+struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_xprt *r_xprt);
 
 struct rpcrdma_mr *rpcrdma_mr_get(struct rpcrdma_xprt *r_xprt);
 void rpcrdma_mr_put(struct rpcrdma_mr *mr);
@@ -625,7 +626,7 @@ int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 			      struct rpcrdma_req *req, u32 hdrlen,
 			      struct xdr_buf *xdr,
 			      enum rpcrdma_chunktype rtype);
-void rpcrdma_unmap_sendctx(struct rpcrdma_sendctx *sc);
+void rpcrdma_sendctx_unmap(struct rpcrdma_sendctx *sc);
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
 void rpcrdma_complete_rqst(struct rpcrdma_rep *rep);

