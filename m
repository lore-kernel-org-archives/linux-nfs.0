Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD279C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9A4C6217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fnxxPLu4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726645AbfDPNhK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:37:10 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:40800 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726576AbfDPNhJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:37:09 -0400
Received: by mail-it1-f193.google.com with SMTP id k64so8891562itb.5;
        Tue, 16 Apr 2019 06:37:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=TDIS49it7CovxgFPNsYlURa4c8OOVx10i8Vi5zHgfrA=;
        b=fnxxPLu4HMqGqfKz0cBJz3yHSDhWe+1QIQLEuFQ27s0RpRErlhKzg+atCyMcdZMvbl
         9OkMi9XkeoWww2mc1TxPnQ5HfTZwmYI9owbnWMXr6a0ASiHgfxbx2bmhnb8vhCCDV94k
         p6bVnlj258QQuC9BmrwiUuV70sfJJmjSLLRGuNB20/vi48g0c82I6m5pyiQFcFasreKa
         zU0QIaIvN7PZMvFwzzY7+ytVJ/uV10++qy+krg4yDo27i2V9mctA0Pefj+vSHMPx3vAj
         2G3Sop5ddtV0qXbZ7ZjGzENMkWXG1oPtM+eeU+vWXUzLp3jvA3FF9n8QJIDAp/3xnfrr
         E0Ng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=TDIS49it7CovxgFPNsYlURa4c8OOVx10i8Vi5zHgfrA=;
        b=JZEf7ROxGypLjhE3DKKcR+jCeegLzMjc71kxRTFpjznVF0X0UqnM2k/70uNanS0Az8
         hhrWBDbVJhU4YYfDqPgpKio7rjHSHOJcf49X4ZJFTBIZouwZvv5UyjsRrTTmGaHdS2/w
         eR2l5IRTAe86QV5EZ/xpqhwTrvppcHAr2c9KxC6tAGVweC9mrGYS2bYwvqy8oca6NG/3
         9hDwe/nKbPZoPR2ExAycn9jpEbB1WOOHtwS3iZdFhThCg9Kb/wYRalrHQ1wMMbtLJiBz
         MZn+4gWxFtHiBbXs0l/seacsRKpNEkBOghAZRSwhyJ2boSuqwgU+Z8UEGnp9kdTwBfcE
         HQ6A==
X-Gm-Message-State: APjAAAUC4Y5utH213rpP/gr/jK/Hkq5Lr3ds6HpPHd13ukdEXGYWB9qf
        DubD5rjzDY8NDfOCZc8t614A4jPK
X-Google-Smtp-Source: APXvYqwdDlR3O9sy3g6QZDnN1izwVCjPaQL5jb9mJl3yMViORaYn0Z4x5ZqAnMj8NUpqUqHeflodQw==
X-Received: by 2002:a05:660c:95:: with SMTP id t21mr30355276itj.6.1555421828377;
        Tue, 16 Apr 2019 06:37:08 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y11sm9605562ita.14.2019.04.16.06.37.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:37:07 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDb63j021205;
        Tue, 16 Apr 2019 13:37:06 GMT
Subject: [PATCH v2 03/21] xprtrdma: Clean up rpcrdma_create_req()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:37:06 -0400
Message-ID: <20190416133706.23113.32437.stgit@manet.1015granger.net>
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

Eventually, I'd like to invoke rpcrdma_create_req() during the
call_reserve step. Memory allocation there probably needs to use
GFP_NOIO. Therefore a set of GFP flags needs to be passed in.

As an additional clean up, just return a pointer or NULL, because
the only error return code here is -ENOMEM.

Lastly, clean up the function names to be consistent with the
pattern: "rpcrdma" _ object-type _ action

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    6 +++---
 net/sunrpc/xprtrdma/verbs.c       |   29 ++++++++++++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    3 ++-
 3 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index d79b18c..713961a 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -31,9 +31,9 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 		struct rpcrdma_regbuf *rb;
 		size_t size;
 
-		req = rpcrdma_create_req(r_xprt);
-		if (IS_ERR(req))
-			return PTR_ERR(req);
+		req = rpcrdma_req_create(r_xprt, GFP_KERNEL);
+		if (!req)
+			return -ENOMEM;
 		rqst = &req->rl_slot;
 
 		rqst->rq_xprt = xprt;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 30cfc0e..71fc41f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -996,22 +996,27 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 	rpcrdma_mrs_create(r_xprt);
 }
 
-struct rpcrdma_req *
-rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
+/**
+ * rpcrdma_req_create - Allocate an rpcrdma_req object
+ * @r_xprt: controlling r_xprt
+ * @flags: GFP flags passed to memory allocators
+ *
+ * Returns an allocated and fully initialized rpcrdma_req or NULL.
+ */
+struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt, gfp_t flags)
 {
 	struct rpcrdma_buffer *buffer = &r_xprt->rx_buf;
 	struct rpcrdma_regbuf *rb;
 	struct rpcrdma_req *req;
 
-	req = kzalloc(sizeof(*req), GFP_KERNEL);
+	req = kzalloc(sizeof(*req), flags);
 	if (req == NULL)
-		return ERR_PTR(-ENOMEM);
+		return NULL;
 
-	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE,
-				  DMA_TO_DEVICE, GFP_KERNEL);
+	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE, DMA_TO_DEVICE, flags);
 	if (IS_ERR(rb)) {
 		kfree(req);
-		return ERR_PTR(-ENOMEM);
+		return NULL;
 	}
 	req->rl_rdmabuf = rb;
 	xdr_buf_init(&req->rl_hdrbuf, rb->rg_base, rdmab_length(rb));
@@ -1086,16 +1091,14 @@ struct rpcrdma_req *
 
 	INIT_LIST_HEAD(&buf->rb_send_bufs);
 	INIT_LIST_HEAD(&buf->rb_allreqs);
+
+	rc = -ENOMEM;
 	for (i = 0; i < buf->rb_max_requests; i++) {
 		struct rpcrdma_req *req;
 
-		req = rpcrdma_create_req(r_xprt);
-		if (IS_ERR(req)) {
-			dprintk("RPC:       %s: request buffer %d alloc"
-				" failed\n", __func__, i);
-			rc = PTR_ERR(req);
+		req = rpcrdma_req_create(r_xprt, GFP_KERNEL);
+		if (!req)
 			goto out;
-		}
 		list_add(&req->rl_list, &buf->rb_send_bufs);
 	}
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 10f6593..539558f 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -528,7 +528,8 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 /*
  * Buffer calls - xprtrdma/verbs.c
  */
-struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
+struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt,
+				       gfp_t flags);
 void rpcrdma_req_destroy(struct rpcrdma_req *req);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);

