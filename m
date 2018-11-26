Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3186AC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E933C205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="j1udtsXl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E933C205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727020AbeK0HB5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:57 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:51689 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HB5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:57 -0500
Received: by mail-it1-f193.google.com with SMTP id x19so30404431itl.1;
        Mon, 26 Nov 2018 12:06:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=X0l7ctVTYEbpd7KCw4623zC5HYj5wPVZw7Lj3hVkMNY=;
        b=j1udtsXlbq7Q5VYw0AVLtsnlq3KEuHoAsj7/bA2KjkDms6TAORQS91a9ar7/9Dd8Gt
         3dEKTjk8Hb8N4LLf+bN64YPXNjD5q+s08Pd2naF7HIpa8G79ZTDBAO2OIV7Zyd9ekLm3
         smWgjynaANHwayGqytyMeQg0QemUy1Syhy2gjo8d3wPtLEQGBezsOBnjfTdWzlsx90Z7
         hry9zYXvswXU7pq899bZMmXlxSvUHmOderCgNfh+4Kzf7+hG/eaD5PG+pZzQmL7M1oBu
         o+E0o7xtSO45z1R+PDL2cz0Yd2CFQJqE5+dEsEPvRBGg6QQPNPtbCevgJOWIPafHSmfH
         bTrQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=X0l7ctVTYEbpd7KCw4623zC5HYj5wPVZw7Lj3hVkMNY=;
        b=f/U3mc+9Hig24+d5m/S11+/pgu4+6+EUd7R5FanbqvFm36N68X2tBb014S8qtMSS3r
         Y9fCfJksy0e/v2RwXh4DItNirG1nfRasyAKB+dTpb1fWYTwKZ0/3pAJ0JIN3J73ceRnM
         TeanpiEaaQB/vy03EpaOT9si8BtJkZhew4yQrF6jhXcVw68eYRG5nSU8QoOpv/IJfEkY
         Vz5A33oKkVAxvIuSRD9Y1Q/Tzprs4gBM+xPgtbGuc+qgENtdV2qt0A9AZrlG5TQoCXd+
         t7vh437Egk489Qmw+ldAKiVrKgTFQZQbwAT6QgzdDZxcl7a+m31GBF5GzMQV5gsNxJmq
         auFA==
X-Gm-Message-State: AA+aEWZGYpJgVutY450xDrtj1dG51FSRS39UYVnKVerWHO/m0j5tqER9
        doUkxEisWjjYHopd9jnNdZJ0UiUf
X-Google-Smtp-Source: AFSGD/Wy2+74AW+glnsWcFxLt5+m7MjB8m2eRB+6JY7SbXuD7OGiRITtEIz69yZPaH2eRh6cf3eDvQ==
X-Received: by 2002:a24:4a95:: with SMTP id k143mr12703304itb.77.1543262802475;
        Mon, 26 Nov 2018 12:06:42 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w13sm1573856itb.10.2018.11.26.12.06.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:41 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6e4w010672;
        Mon, 26 Nov 2018 20:06:40 GMT
Subject: [PATCH v2 10/20] xprtrdma: Refactor rpcrdma_create_req()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:40 -0500
Message-ID: <20181126200640.10321.54610.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In a subsequent patch, we'll be invoking rpcrdma_create_req() during
the call_reserve step. Memory allocation there needs to use
GFP_NOFS.

As an additional clean up, just return a pointer or NULL, because
the only error return code here is -ENOMEM.

Lastly, rename rpcrdma_create_req to match rpcrdma_req_destroy.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    6 +++---
 net/sunrpc/xprtrdma/verbs.c       |   28 ++++++++++++++++------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    3 ++-
 3 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 41d263c..c8a3d45 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -31,9 +31,9 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 		struct rpcrdma_regbuf *rb;
 		size_t size;
 
-		req = rpcrdma_create_req(r_xprt);
-		if (IS_ERR(req))
-			return PTR_ERR(req);
+		req = rpcrdma_req_create(&r_xprt->rx_buf, GFP_KERNEL);
+		if (!req)
+			return -ENOMEM;
 		rqst = &req->rl_slot;
 
 		rqst->rq_xprt = xprt;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index bd6bc45..42a6ef6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1061,22 +1061,28 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 	rpcrdma_mrs_create(r_xprt);
 }
 
+/**
+ * rpcrdma_req_create - Allocate an rpcrdma_req object
+ * @buffer: controlling rpcrdma_buf (and r_xprt)
+ * @flags: GFP flags passed to memory allocators
+ *
+ * Returns an allocated and fully initialized rpcrdma_req or NULL.
+ */
 struct rpcrdma_req *
-rpcrdma_create_req(struct rpcrdma_xprt *r_xprt)
+rpcrdma_req_create(struct rpcrdma_buffer *buffer, gfp_t flags)
 {
-	struct rpcrdma_buffer *buffer = &r_xprt->rx_buf;
 	struct rpcrdma_regbuf *rb;
 	struct rpcrdma_req *req;
 
-	req = kzalloc(sizeof(*req), GFP_KERNEL);
+	req = kzalloc(sizeof(*req), flags);
 	if (req == NULL)
-		return ERR_PTR(-ENOMEM);
+		return NULL;
 
 	rb = rpcrdma_alloc_regbuf(RPCRDMA_HDRBUF_SIZE,
-				  DMA_TO_DEVICE, GFP_KERNEL);
+				  DMA_TO_DEVICE, flags);
 	if (IS_ERR(rb)) {
 		kfree(req);
-		return ERR_PTR(-ENOMEM);
+		return NULL;
 	}
 	req->rl_rdmabuf = rb;
 	xdr_buf_init(&req->rl_hdrbuf, rb->rg_base, rdmab_length(rb));
@@ -1153,16 +1159,14 @@ struct rpcrdma_req *
 
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
+		req = rpcrdma_req_create(buf, GFP_KERNEL);
+		if (!req)
 			goto out;
-		}
 		list_add(&req->rl_list, &buf->rb_send_bufs);
 	}
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index e1c6235..685b65f 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -564,7 +564,8 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 /*
  * Buffer calls - xprtrdma/verbs.c
  */
-struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
+struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_buffer *buf,
+				       gfp_t flags);
 void rpcrdma_req_destroy(struct rpcrdma_req *req);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);

