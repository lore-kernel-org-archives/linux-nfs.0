Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 220DFC282E1
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DDADE21773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ss3PdLMh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730455AbfDXNjY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:24 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:33654 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730425AbfDXNjX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:23 -0400
Received: by mail-it1-f195.google.com with SMTP id v8so5383122itf.0;
        Wed, 24 Apr 2019 06:39:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=VGQb6bDqTcBA+Yvlo/MAkVfne4uEYGwoB24T+fyhy+o=;
        b=Ss3PdLMho4D/r9GllZ0SvQI2UzpG08XMbzX6KkkJTA+uVox7AFir8k+P1z18c0od1e
         cqMRu1sTLYNzqPJG1Z64lvEFhw4C+KJmNTrRpcujroxyRhBHM3Nof5PWPduWDA8gOzDR
         WO1bMT13ULRnbo9eXLVWqPt5mxF/NP9gUVqCd4p7o3t4zhxLkTr+Mpp4SAWKYiX+r04G
         ICYtJ3WzsFOGUX986+FuLQcnFB6fLndYfu81489ZJwQUVxwBFFBYorfB6/Kxy+fKxdw7
         fYv3dQrm96PVc4i1kU7tmghtE8gBGuBq5rFhTVPiPZ/qEGjERpSohYlDwoVKWR7kKHgY
         Za6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=VGQb6bDqTcBA+Yvlo/MAkVfne4uEYGwoB24T+fyhy+o=;
        b=hZ6Qpij/3YwuEv+PCLovB8sCiZwsb+GD+i8TFXBh2Gd8L9q+y450chALaOZiSW131I
         kApkN8atix6y+fHSbkXUfZ/74s7plt33oSmX0t5q46cuGrMBFBZdijPWs/6wqz+QDgy8
         UfpXdB3p+5NdiQ04XwNpsyklgucZuu7Sb2DLuk3cxtHDEB482LSgKQby2Ngg35HWRQKd
         8b2WYFw7gskpHPj8E8Ryss9HjhmfQ7HrQUPzAarzmruk09SOtIXgpvhQ9tjybIufJCVs
         W5TbmkEFxE0gPRtYnLbY9l7w3n/FXvudCbiAFTAVZKGVY63iZxzGZLwq7lQWubgKXM1Q
         MfAg==
X-Gm-Message-State: APjAAAXUx9pGo2iDW+JZJppE4cWLMMr6CV9LKT3AuXQWvwdiOsvgKFph
        MPdyw3borhT9YMY9Do4N3v0=
X-Google-Smtp-Source: APXvYqwTJYPkU/BxW+Yd7Zkqz0sc/Fio1jPuBTJCUIOvAAAlTejtb462r+kkeTbzQRrlcsQbNCYLlA==
X-Received: by 2002:a02:4049:: with SMTP id n70mr14072649jaa.42.1556113162963;
        Wed, 24 Apr 2019 06:39:22 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id a16sm9272752itc.36.2019.04.24.06.39.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:22 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODdLCa011286;
        Wed, 24 Apr 2019 13:39:21 GMT
Subject: [PATCH v3 06/21] xprtrdma: Allocate req's regbufs at xprt create
 time
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:21 -0400
Message-ID: <20190424133921.5077.73010.stgit@manet.1015granger.net>
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

Allocating an rpcrdma_req's regbufs at xprt create time enables
a pair of micro-optimizations:

First, if these regbufs are always there, we can eliminate two
conditional branches from the hot xprt_rdma_allocate path.

Second, by allocating a 1KB buffer, it places a lower bound on the
size of these buffers, without adding yet another conditional
branch. The lower bound reduces the number of hardway re-
allocations. In fact, for some workloads it completely eliminates
hardway allocations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   18 ++++--------------
 net/sunrpc/xprtrdma/transport.c   |    4 ++--
 net/sunrpc/xprtrdma/verbs.c       |   34 ++++++++++++++++++++++++++--------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    2 +-
 4 files changed, 33 insertions(+), 25 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 6170ec7..e1a125a 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -28,10 +28,10 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 	unsigned int i;
 
 	for (i = 0; i < (count << 1); i++) {
-		struct rpcrdma_regbuf *rb;
 		size_t size;
 
-		req = rpcrdma_req_create(r_xprt, GFP_KERNEL);
+		size = min_t(size_t, r_xprt->rx_data.inline_rsize, PAGE_SIZE);
+		req = rpcrdma_req_create(r_xprt, size, GFP_KERNEL);
 		if (!req)
 			return -ENOMEM;
 		rqst = &req->rl_slot;
@@ -42,20 +42,10 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 		spin_lock(&xprt->bc_pa_lock);
 		list_add(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
 		spin_unlock(&xprt->bc_pa_lock);
-
-		size = r_xprt->rx_data.inline_rsize;
-		rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, GFP_KERNEL);
-		if (!rb)
-			goto out_fail;
-		req->rl_sendbuf = rb;
-		xdr_buf_init(&rqst->rq_snd_buf, rdmab_data(rb),
-			     min_t(size_t, size, PAGE_SIZE));
+		xdr_buf_init(&rqst->rq_snd_buf, rdmab_data(req->rl_sendbuf),
+			     size);
 	}
 	return 0;
-
-out_fail:
-	rpcrdma_req_destroy(req);
-	return -ENOMEM;
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index e3b5b91..09a4693 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -591,7 +591,7 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 {
 	struct rpcrdma_regbuf *rb;
 
-	if (req->rl_sendbuf && rdmab_length(req->rl_sendbuf) >= size)
+	if (likely(rdmab_length(req->rl_sendbuf) >= size))
 		return true;
 
 	rb = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, flags);
@@ -621,7 +621,7 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 {
 	struct rpcrdma_regbuf *rb;
 
-	if (req->rl_recvbuf && rdmab_length(req->rl_recvbuf) >= size)
+	if (likely(rdmab_length(req->rl_recvbuf) >= size))
 		return true;
 
 	rb = rpcrdma_alloc_regbuf(size, DMA_NONE, flags);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index f88fd39..77e0f21 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -998,11 +998,13 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 /**
  * rpcrdma_req_create - Allocate an rpcrdma_req object
  * @r_xprt: controlling r_xprt
+ * @size: initial size, in bytes, of send and receive buffers
  * @flags: GFP flags passed to memory allocators
  *
  * Returns an allocated and fully initialized rpcrdma_req or NULL.
  */
-struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
+struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, size_t size,
+				       gfp_t flags)
 {
 	struct rpcrdma_buffer *buffer = &r_xprt->rx_buf;
 	struct rpcrdma_regbuf *rb;
@@ -1010,22 +1012,37 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 
 	req = kzalloc(sizeof(*req), flags);
 	if (req == NULL)
-		return NULL;
+		goto out1;
 
 	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE, DMA_TO_DEVICE, flags);
-	if (!rb) {
-		kfree(req);
-		return NULL;
-	}
+	if (!rb)
+		goto out2;
 	req->rl_rdmabuf = rb;
 	xdr_buf_init(&req->rl_hdrbuf, rdmab_data(rb), rdmab_length(rb));
+
+	req->rl_sendbuf = rpcrdma_alloc_regbuf(size, DMA_TO_DEVICE, flags);
+	if (!req->rl_sendbuf)
+		goto out3;
+
+	req->rl_recvbuf = rpcrdma_alloc_regbuf(size, DMA_NONE, flags);
+	if (!req->rl_recvbuf)
+		goto out4;
+
 	req->rl_buffer = buffer;
 	INIT_LIST_HEAD(&req->rl_registered);
-
 	spin_lock(&buffer->rb_lock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
 	spin_unlock(&buffer->rb_lock);
 	return req;
+
+out4:
+	kfree(req->rl_sendbuf);
+out3:
+	kfree(req->rl_rdmabuf);
+out2:
+	kfree(req);
+out1:
+	return NULL;
 }
 
 static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
@@ -1090,7 +1107,8 @@ static bool rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt, bool temp)
 	for (i = 0; i < buf->rb_max_requests; i++) {
 		struct rpcrdma_req *req;
 
-		req = rpcrdma_req_create(r_xprt, GFP_KERNEL);
+		req = rpcrdma_req_create(r_xprt, RPCRDMA_V1_DEF_INLINE_SIZE,
+					 GFP_KERNEL);
 		if (!req)
 			goto out;
 		list_add(&req->rl_list, &buf->rb_send_bufs);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 1af9674..03d5ce4 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -529,7 +529,7 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 /*
  * Buffer calls - xprtrdma/verbs.c
  */
-struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt,
+struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, size_t size,
 				       gfp_t flags);
 void rpcrdma_req_destroy(struct rpcrdma_req *req);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);

