Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E26B3C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A5FA221773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tKM1e2gf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730457AbfDXNja (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:30 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:55554 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730419AbfDXNja (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:30 -0400
Received: by mail-it1-f194.google.com with SMTP id y134so6325235itc.5;
        Wed, 24 Apr 2019 06:39:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=7vWhTvVwPPs45OnXYmhkdIwb6y6K4seVmZvOCs+5jHo=;
        b=tKM1e2gfr0CzIBzcBb7Re9kesmkv0QKc19KiTM+B5GSLrL7qgigguj0zCfc8d5K/Ff
         EshaCBmcZcp0uzO4fdLMpcD6F8xRfCiOzJnV3u09GKAFR73Ffm/w5IoQhZteezTkSq7x
         ViOBOWOy5JZUUojKfXdS0nlJ1CFdDaBk6Rx83TsOARUePGgOJCmwkkcse8laal798G22
         tFL1JbUvYRubW/edc0H3VfG8tHRa5LdNsh9gJ1MAYNrEeZAcsuCRs4juwII0Npldb1FO
         UYI66CwRRycSqKWx73cmiigt3wXsHwKhCOeB21R9Uc+b6O7tNIji4ufKt++u+GZbJOTT
         K+nw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=7vWhTvVwPPs45OnXYmhkdIwb6y6K4seVmZvOCs+5jHo=;
        b=MhdTHfJywJtmUsXTqJ7HKzTJaR1Gyi+1sbIXCIp7PWlw2YzUxVzGrNDXabhkPSF+Vr
         LuhcogVsdombOAu2NrBxxWJLdFLYhTN0fJT06WDUb8sdTvjuXdscMQ7ARGCjewtE5aQK
         9jhkQo/a9OrWIu/gRgXaKvQbGBG6Ek36IIgoxSBd3SSVGgFZQd5bv73I+NdBBe0R8kSB
         S6IvCUXLMe6MNg1o5f/hRq2qjVH2cGknrRdcg1BsTP53WGh9MsuoaK67WUcURiIagnmQ
         xHGvZIxVCS0Ik0qln3sCs+NoN48EhXlzuVvqRPTI/HNJ3FzSPXznb4jD3bZIptLQiotd
         mm0A==
X-Gm-Message-State: APjAAAWToOMtj8qZK6KrVPz71XZDD0okgM1pCfojsK3KDUBMJbvuaTcW
        USyt1OoGeClvBHPPIm4Q2PM=
X-Google-Smtp-Source: APXvYqxxFz75fO5auXwMnnmDo8OjvKbQ7gMjwMkn9Db0+NtwKJ9otxnS4dQbPFkj9s2Bbdhv2eAstw==
X-Received: by 2002:a24:ba0e:: with SMTP id p14mr6287431itf.31.1556113168262;
        Wed, 24 Apr 2019 06:39:28 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q1sm886969iob.43.2019.04.24.06.39.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:27 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODdRgD011289;
        Wed, 24 Apr 2019 13:39:27 GMT
Subject: [PATCH v3 07/21] xprtrdma: De-duplicate "allocate new,
 free old regbuf"
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:27 -0400
Message-ID: <20190424133927.5077.65654.stgit@manet.1015granger.net>
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

Clean up by providing an API to do this common task.

At this point, the difference between rpcrdma_get_sendbuf and
rpcrdma_get_recvbuf has become tiny. These can be collapsed into a
single helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   59 ++++++++-------------------------------
 net/sunrpc/xprtrdma/verbs.c     |   25 +++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +
 3 files changed, 39 insertions(+), 47 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 09a4693..47d2e00 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -585,52 +585,15 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 	rpc_wake_up_next(&xprt->backlog);
 }
 
-static bool
-rpcrdma_get_sendbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
-		    size_t size, gfp_t flags)
+static bool rpcrdma_check_regbuf(struct rpcrdma_xprt *r_xprt,
+				 struct rpcrdma_regbuf *rb, size_t size,
+				 gfp_t flags)
 {
-	struct rpcrdma_regbuf *rb;
-
-	if (likely(rdmab_length(req->rl_sendbuf) >= size))
-		return true;
-
-	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, flags);
-	if (!rb)
-		return false;
-
-	rpcrdma_free_regbuf(req->rl_sendbuf);
-	r_xprt->rx_stats.hardway_register_count += size;
-	req->rl_sendbuf = rb;
-	return true;
-}
-
-/* The rq_rcv_buf is used only if a Reply chunk is necessary.
- * The decision to use a Reply chunk is made later in
- * rpcrdma_marshal_req. This buffer is registered at that time.
- *
- * Otherwise, the associated RPC Reply arrives in a separate
- * Receive buffer, arbitrarily chosen by the HCA. The buffer
- * allocated here for the RPC Reply is not utilized in that
- * case. See rpcrdma_inline_fixup.
- *
- * A regbuf is used here to remember the buffer size.
- */
-static bool
-rpcrdma_get_recvbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
-		    size_t size, gfp_t flags)
-{
-	struct rpcrdma_regbuf *rb;
-
-	if (likely(rdmab_length(req->rl_recvbuf) >= size))
-		return true;
-
-	rb = rpcrdma_alloc_regbuf(size, DMA_NONE, flags);
-	if (!rb)
-		return false;
-
-	rpcrdma_free_regbuf(req->rl_recvbuf);
-	r_xprt->rx_stats.hardway_register_count += size;
-	req->rl_recvbuf = rb;
+	if (unlikely(rdmab_length(rb) < size)) {
+		if (!rpcrdma_regbuf_realloc(rb, size, flags))
+			return false;
+		r_xprt->rx_stats.hardway_register_count += size;
+	}
 	return true;
 }
 
@@ -655,9 +618,11 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 	if (RPC_IS_SWAPPER(task))
 		flags = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
 
-	if (!rpcrdma_get_sendbuf(r_xprt, req, rqst->rq_callsize, flags))
+	if (!rpcrdma_check_regbuf(r_xprt, req->rl_sendbuf, rqst->rq_callsize,
+				  flags))
 		goto out_fail;
-	if (!rpcrdma_get_recvbuf(r_xprt, req, rqst->rq_rcvsize, flags))
+	if (!rpcrdma_check_regbuf(r_xprt, req->rl_recvbuf, rqst->rq_rcvsize,
+				  flags))
 		goto out_fail;
 
 	rqst->rq_buffer = rdmab_data(req->rl_sendbuf);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 77e0f21..734dfe5 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1400,6 +1400,31 @@ struct rpcrdma_regbuf *
 }
 
 /**
+ * rpcrdma_regbuf_realloc - re-allocate a SEND/RECV buffer
+ * @rb: regbuf to reallocate
+ * @size: size of buffer to be allocated, in bytes
+ * @flags: GFP flags
+ *
+ * Returns true if reallocation was successful. If false is
+ * returned, @rb is left untouched.
+ */
+bool rpcrdma_regbuf_realloc(struct rpcrdma_regbuf *rb, size_t size, gfp_t flags)
+{
+	void *buf;
+
+	buf = kmalloc(size, flags);
+	if (!buf)
+		return false;
+
+	rpcrdma_dma_unmap_regbuf(rb);
+	kfree(rb->rg_data);
+
+	rb->rg_data = buf;
+	rb->rg_iov.length = size;
+	return true;
+}
+
+/**
  * __rpcrdma_map_regbuf - DMA-map a regbuf
  * @ia: controlling rpcrdma_ia
  * @rb: regbuf to be mapped
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 03d5ce4..751d476 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -552,6 +552,8 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, size_t size,
 
 struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
 					    gfp_t);
+bool rpcrdma_regbuf_realloc(struct rpcrdma_regbuf *rb, size_t size,
+			    gfp_t flags);
 bool __rpcrdma_dma_map_regbuf(struct rpcrdma_ia *, struct rpcrdma_regbuf *);
 void rpcrdma_free_regbuf(struct rpcrdma_regbuf *);
 

