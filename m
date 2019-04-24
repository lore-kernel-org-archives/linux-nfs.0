Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DDDDC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0F4D021773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l+ex7Bea"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730428AbfDXNjI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:08 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:35711 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730426AbfDXNjI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:08 -0400
Received: by mail-io1-f67.google.com with SMTP id r18so14994890ioh.2;
        Wed, 24 Apr 2019 06:39:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=TDIS49it7CovxgFPNsYlURa4c8OOVx10i8Vi5zHgfrA=;
        b=l+ex7Bea3Tt0OgAkKlv7uCcvM/iTRzA9OMCao1BmMRh/UpuYtTCmnKJnt1QneX9xOr
         h68f9VkoLgNgJ52fQuz5xG+Km7E2KjJgrp6onXmJOb8IShNb5GgD9loBbYH/mIzZ4RfE
         1MI5DuPec4jx8c1QEENGhnthLTBHscJC7uTHY2WF2QjS0Yth4B2fDxU8zJ1GQbUuXkRX
         lvjLM5ERHtUPPEUoiGpxqQ2NypYhy4jv7/ruSGjt/avNSLXMZjRpLLIlsmW5wddHhUNg
         2QO4Z06CrSil93sw7jA7utlv6sIUfRjrqwylNYhzjRkGHZKTwp5vBF1RV9eyt5t9DISj
         JuWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=TDIS49it7CovxgFPNsYlURa4c8OOVx10i8Vi5zHgfrA=;
        b=h2Oy9/02XfFE0qXm2W/zdfs7tm1eQ3EfFQWhhQnjD4mKioEDC+qU7JXBpMTGe1xuI/
         0x9OHqSpYqyaxtRTVD2lo273zD2L7uIGukgGN+3TzlNVEp6VTioiG1NA9VJsc/6AmW6E
         WAuXY+bPWRLLjJiWXzr80afri7KvpRGN/aBZP3DOdf2IDd+kEe0IyUFaaVZC9PzxbkT/
         8Wbujx9RqinngwkjujyAoswGMrPv5PJph4n6HrkcpeZ4+8ehwaTEe0LoNQ6kmnHquMYZ
         xDnAuiazjhSS6l+7GT+LwXRBtlIbWRvy4C8Wnllb69dOkSEkHt/eaxpX62Og4r3r55Ms
         rn5w==
X-Gm-Message-State: APjAAAV8SDHTbeKy27KbERRTYmpBIpTvGnV/KDCT/ncyvasBVzBPPtdv
        M8qVoBMkF/bahgPNtBDxrUU5XqNI
X-Google-Smtp-Source: APXvYqz6MgQ/NOnZYxyfC2yHtlWjowZkS1g3PwkQxXKN/1eZ3EWvY+XbzI1tL/W5emYb/vjh5TLEkA==
X-Received: by 2002:a6b:fd10:: with SMTP id c16mr6490939ioi.172.1556113147260;
        Wed, 24 Apr 2019 06:39:07 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x10sm9301267ita.4.2019.04.24.06.39.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:06 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODd53H011277;
        Wed, 24 Apr 2019 13:39:05 GMT
Subject: [PATCH v3 03/21] xprtrdma: Clean up rpcrdma_create_req()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:05 -0400
Message-ID: <20190424133905.5077.37439.stgit@manet.1015granger.net>
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

