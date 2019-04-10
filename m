Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F06BC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E103D2075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EpCHbAjk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726014AbfDJUGz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:06:55 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:36331 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726623AbfDJUGz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:06:55 -0400
Received: by mail-io1-f66.google.com with SMTP id f6so3310130iop.3;
        Wed, 10 Apr 2019 13:06:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=KT0mNwzUZ+0Y/20uPDWSVzTVBJwcjLgX0r3gnq7x+Qc=;
        b=EpCHbAjk0l2GYLoQr2GHoiCV0RH8NB0myZlgiXvvChhc1GYMnldM0acd7EDUc+a6Aw
         woLh4GZfFA8Ai6FzMVyqpvKMB3mEniswbiJUdDr/sfr6+vjHQskNaTzb+gFvZDCzitYz
         IyzI3SNjY/KulwZAmZfdJbt100Udl8KoeqP7t9Y2sn1x2mxzC9hKCXHU1x7YTsua6PZ5
         IcptTnZKv8OHGOWuvahvXc5zcZdKQGEA8sCVwvdXn/yr8APVMtcURZc69f1PkuOw+Dwa
         xzawl/QUlNJiC4Pg5ttreFch+2EYKZ2qnB+88Y2BwRG6D0tL+D3QXkkII0JByZXQvicc
         6SOQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=KT0mNwzUZ+0Y/20uPDWSVzTVBJwcjLgX0r3gnq7x+Qc=;
        b=PQS95Kpa77s2ywIC5Rw7o4EDhYw6GNQqOKWILdJXRNismVFa9QWdYr9uUF+Gye5vxP
         Z2QJpgDKKxreyhcL41j9zlMWBRhoj7SNcZTAyaYaCdARCvhluFjbaTdKfTDcu7K2aBVn
         OIfni8xc4IfTUV0boUxmD5UBIMjh59oAsC8wTTAPs6e4gxcPkyecTsUTKii4Ds5q9VmB
         Gl2tg+I9KvR7ngBWb/7qwdeDCXA88jAiSN4KYEqCdx3iAnVuIpk2DNgunQQQ28linU2l
         vzqUu+kanLHLRAkZ+3iydJcyyY4UTc4qpNKu7z7/kFzDvavdDKU+BTjBplh1j0dapUvk
         KIqw==
X-Gm-Message-State: APjAAAVUdp/Ee3MYVsGkEHy/c9pi80MbRDFEcBGJ3YrEys7O669wHh7+
        fcosdgOBHu2KbQ/98UFhOHtqMq4z
X-Google-Smtp-Source: APXvYqzBSjlLtZvkK67EGLe3jV9GCSY0aqU+D9A4iwnBWtif+nuotx5CeU5rnK+Mzv1G1W0ba4a2vg==
X-Received: by 2002:a6b:8b50:: with SMTP id n77mr4084497iod.222.1554926814245;
        Wed, 10 Apr 2019 13:06:54 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u204sm1509823ita.33.2019.04.10.13.06.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:06:53 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK6rfg004516;
        Wed, 10 Apr 2019 20:06:53 GMT
Subject: [PATCH v1 04/19] xprtrdma: Clean up rpcrdma_create_req()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:06:53 -0400
Message-ID: <20190410200652.11522.60115.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
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
index fe005c6..82ea298 100644
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
index 6a49597..ad6d8df 100644
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

