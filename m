Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3785FC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F0895217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="u958k8sM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728276AbfDPNhU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:37:20 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:34388 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726215AbfDPNhU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:37:20 -0400
Received: by mail-io1-f66.google.com with SMTP id n11so17630295ioh.1;
        Tue, 16 Apr 2019 06:37:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=aAflIV5rN8NeJOxbGqfrZMQxSqDecIsDEDcv+IaEVCc=;
        b=u958k8sMGbxGqJQESh93I6Sy5GhmVFrPVuDNzKRRtsGEsoLAiddysqEVrP3X3tNfNb
         pbXNwUryuYlQoCDolvY6K0jLY1vlWoadJ6JOuZpAA8uL/xUYZArvQzPDe+tVhuyJZUng
         M3q1JSKFPcHXlpK1MNvrKnIuZs98I75P8sdYIGWTmG8l2gl+4LbAaEGq6oGcxoMn5La6
         RBqzUQVKQzCNNkCIlREWdICzvQG8Xgrf+voKR2OG9a3ffVNdcmiUKcEawJaZMEMOoErH
         DzdqJwOQLifBl10mJBVjY8MPIjl9plknnnHpm9cjkz4lL2N2ppr+KSktEwDPcXGjolOs
         46UQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=aAflIV5rN8NeJOxbGqfrZMQxSqDecIsDEDcv+IaEVCc=;
        b=sNrRqhAZ3bUrSUf8wDXiTXlBgvSw5msrIVwVfqJsAsu408hzQR7Qdrmj5HJIdp/NE4
         +mfm4Hj+65Jk2eckcf9W6wjq/YmuIbA/G8ZtcgeKvF6VSfBWxKuT3SNvuzRzqtdr6CkK
         g9lnUeLUDQVI/rB7HMLx6ZaBJGqK4NOIWPstU0JU6KjNXkr2iniPLXzCKMSNAt7e0DhO
         OKd/wsVOy1dyYB467JQq8WVW7125ZvOjvgNYRbFIKlkfICoLnyS8jQ7e8i8bShdgMx27
         D1FuaoHWuhco6Bde0wVEoBq/9d+FNszVJqlCjYdi35rg7Rin5IDhADp3qF5j/JQrExqS
         SSRQ==
X-Gm-Message-State: APjAAAXBvPcHjMl7ZuZ6G1a/3RtHzLMrpD2Ze5F4r42dZW+Ub3owlDp0
        3N6PTamqObXtyZJ5uiNE6OXpQSEM
X-Google-Smtp-Source: APXvYqyuJu+oT7Mef65YAZayY4RO9x8feTWecDj7gKSKyL+oOMQhnSo+Ht/K/HARJrVWIabkxtsCyA==
X-Received: by 2002:a5d:9252:: with SMTP id e18mr18599183iol.97.1555421838812;
        Tue, 16 Apr 2019 06:37:18 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s124sm9880637itb.42.2019.04.16.06.37.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:37:18 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDbH0d021211;
        Tue, 16 Apr 2019 13:37:17 GMT
Subject: [PATCH v2 05/21] xprtrdma: rpcrdma_regbuf alignment
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:37:17 -0400
Message-ID: <20190416133717.23113.38965.stgit@manet.1015granger.net>
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

Allocate the struct rpcrdma_regbuf separately from the I/O buffer
to better guarantee the alignment of the I/O buffer and eliminate
the wasted space between the rpcrdma_regbuf metadata and the buffer
itself.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    6 +++---
 net/sunrpc/xprtrdma/rpc_rdma.c    |    4 ++--
 net/sunrpc/xprtrdma/transport.c   |    8 ++++----
 net/sunrpc/xprtrdma/verbs.c       |   27 ++++++++++++++++-----------
 net/sunrpc/xprtrdma/xprt_rdma.h   |   19 ++++++++++---------
 5 files changed, 35 insertions(+), 29 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 713961a..6170ec7 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -45,10 +45,10 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 
 		size = r_xprt->rx_data.inline_rsize;
 		rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, GFP_KERNEL);
-		if (IS_ERR(rb))
+		if (!rb)
 			goto out_fail;
 		req->rl_sendbuf = rb;
-		xdr_buf_init(&rqst->rq_snd_buf, rb->rg_base,
+		xdr_buf_init(&rqst->rq_snd_buf, rdmab_data(rb),
 			     min_t(size_t, size, PAGE_SIZE));
 	}
 	return 0;
@@ -123,7 +123,7 @@ static int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
 
 	rpcrdma_set_xdrlen(&req->rl_hdrbuf, 0);
 	xdr_init_encode(&req->rl_stream, &req->rl_hdrbuf,
-			req->rl_rdmabuf->rg_base, rqst);
+			rdmab_data(req->rl_rdmabuf), rqst);
 
 	p = xdr_reserve_space(&req->rl_stream, 28);
 	if (unlikely(!p))
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b759b16..cf99c55 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -747,8 +747,8 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	int ret;
 
 	rpcrdma_set_xdrlen(&req->rl_hdrbuf, 0);
-	xdr_init_encode(xdr, &req->rl_hdrbuf,
-			req->rl_rdmabuf->rg_base, rqst);
+	xdr_init_encode(xdr, &req->rl_hdrbuf, rdmab_data(req->rl_rdmabuf),
+			rqst);
 
 	/* Fixed header fields */
 	ret = -EMSGSIZE;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 5d26135..e3b5b91 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -595,7 +595,7 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 		return true;
 
 	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, flags);
-	if (IS_ERR(rb))
+	if (!rb)
 		return false;
 
 	rpcrdma_free_regbuf(req->rl_sendbuf);
@@ -625,7 +625,7 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 		return true;
 
 	rb = rpcrdma_alloc_regbuf(size, DMA_NONE, flags);
-	if (IS_ERR(rb))
+	if (!rb)
 		return false;
 
 	rpcrdma_free_regbuf(req->rl_recvbuf);
@@ -660,8 +660,8 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 	if (!rpcrdma_get_recvbuf(r_xprt, req, rqst->rq_rcvsize, flags))
 		goto out_fail;
 
-	rqst->rq_buffer = req->rl_sendbuf->rg_base;
-	rqst->rq_rbuffer = req->rl_recvbuf->rg_base;
+	rqst->rq_buffer = rdmab_data(req->rl_sendbuf);
+	rqst->rq_rbuffer = rdmab_data(req->rl_recvbuf);
 	trace_xprtrdma_op_allocate(task, req);
 	return 0;
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index caa6a5d..f88fd39 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1013,12 +1013,12 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 		return NULL;
 
 	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE, DMA_TO_DEVICE, flags);
-	if (IS_ERR(rb)) {
+	if (!rb) {
 		kfree(req);
 		return NULL;
 	}
 	req->rl_rdmabuf = rb;
-	xdr_buf_init(&req->rl_hdrbuf, rb->rg_base, rdmab_length(rb));
+	xdr_buf_init(&req->rl_hdrbuf, rdmab_data(rb), rdmab_length(rb));
 	req->rl_buffer = buffer;
 	INIT_LIST_HEAD(&req->rl_registered);
 
@@ -1040,9 +1040,9 @@ static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
 
 	rep->rr_rdmabuf = rpcrdma_alloc_regbuf(cdata->inline_rsize,
 					       DMA_FROM_DEVICE, GFP_KERNEL);
-	if (IS_ERR(rep->rr_rdmabuf))
+	if (!rep->rr_rdmabuf)
 		goto out_free;
-	xdr_buf_init(&rep->rr_hdrbuf, rep->rr_rdmabuf->rg_base,
+	xdr_buf_init(&rep->rr_hdrbuf, rdmab_data(rep->rr_rdmabuf),
 		     rdmab_length(rep->rr_rdmabuf));
 
 	rep->rr_cqe.done = rpcrdma_wc_receive;
@@ -1354,8 +1354,7 @@ struct rpcrdma_req *
  * @direction: direction of data movement
  * @flags: GFP flags
  *
- * Returns an ERR_PTR, or a pointer to a regbuf, a buffer that
- * can be persistently DMA-mapped for I/O.
+ * Returns a pointer to a rpcrdma_regbuf object, or NULL.
  *
  * xprtrdma uses a regbuf for posting an outgoing RDMA SEND, or for
  * receiving the payload of RDMA RECV operations. During Long Calls
@@ -1367,14 +1366,18 @@ struct rpcrdma_regbuf *
 {
 	struct rpcrdma_regbuf *rb;
 
-	rb = kmalloc(sizeof(*rb) + size, flags);
-	if (rb == NULL)
-		return ERR_PTR(-ENOMEM);
+	rb = kmalloc(sizeof(*rb), flags);
+	if (!rb)
+		return NULL;
+	rb->rg_data = kmalloc(size, flags);
+	if (!rb->rg_data) {
+		kfree(rb);
+		return NULL;
+	}
 
 	rb->rg_device = NULL;
 	rb->rg_direction = direction;
 	rb->rg_iov.length = size;
-
 	return rb;
 }
 
@@ -1392,7 +1395,7 @@ struct rpcrdma_regbuf *
 		return false;
 
 	rb->rg_iov.addr = ib_dma_map_single(device,
-					    (void *)rb->rg_base,
+					    rdmab_data(rb),
 					    rdmab_length(rb),
 					    rb->rg_direction);
 	if (ib_dma_mapping_error(device, rdmab_addr(rb))) {
@@ -1427,6 +1430,8 @@ struct rpcrdma_regbuf *
 rpcrdma_free_regbuf(struct rpcrdma_regbuf *rb)
 {
 	rpcrdma_dma_unmap_regbuf(rb);
+	if (rb)
+		kfree(rb->rg_data);
 	kfree(rb);
 }
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 539558f..1af9674 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -121,33 +121,34 @@ struct rpcrdma_regbuf {
 	struct ib_sge		rg_iov;
 	struct ib_device	*rg_device;
 	enum dma_data_direction	rg_direction;
-	__be32			rg_base[0] __attribute__ ((aligned(256)));
+	void			*rg_data;
 };
 
-static inline u64
-rdmab_addr(struct rpcrdma_regbuf *rb)
+static inline u64 rdmab_addr(struct rpcrdma_regbuf *rb)
 {
 	return rb->rg_iov.addr;
 }
 
-static inline u32
-rdmab_length(struct rpcrdma_regbuf *rb)
+static inline u32 rdmab_length(struct rpcrdma_regbuf *rb)
 {
 	return rb->rg_iov.length;
 }
 
-static inline u32
-rdmab_lkey(struct rpcrdma_regbuf *rb)
+static inline u32 rdmab_lkey(struct rpcrdma_regbuf *rb)
 {
 	return rb->rg_iov.lkey;
 }
 
-static inline struct ib_device *
-rdmab_device(struct rpcrdma_regbuf *rb)
+static inline struct ib_device *rdmab_device(struct rpcrdma_regbuf *rb)
 {
 	return rb->rg_device;
 }
 
+static inline void *rdmab_data(const struct rpcrdma_regbuf *rb)
+{
+	return rb->rg_data;
+}
+
 #define RPCRDMA_DEF_GFP		(GFP_NOIO | __GFP_NOWARN)
 
 /* To ensure a transport can always make forward progress,

