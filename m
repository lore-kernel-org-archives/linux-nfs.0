Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2BAEC43612
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9087420879
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mMenZZsv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726769AbfABWyW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 17:54:22 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:51906 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729935AbfABWyW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 17:54:22 -0500
Received: by mail-it1-f194.google.com with SMTP id w18so43105100ite.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 14:54:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=4TytOV/lqVOrINb4NIjPNzviApMZbjwDnOpJOOSPzxY=;
        b=mMenZZsvu2Wf3NsccKYIY1NXdrWZpPh2tM977rq/A88C2m5pka11WE9lj4hINurY8G
         XkocvT0lcTwgQxo1HdPKmqGljwM8o3pHky8V4S6r+VOIcHg3ciXfSDuiWa9YmlwgtQ+r
         66whyth7wCjyygCCKzu0OR2AgO0tsW/fGcRPYY5BNDOkQ6UGXoBlCvT0Rt8mFBlVtrEf
         CbufzOP5+SderjZzi5eiWRz3C4tSqQWZlYsyr92BmXWVmMYihxvU7wiqjbPzrZZHAZqz
         2VkqSy6A4EaQGZZsvRdA26zdJxNvX4PGOaatpZtLlnsR3qU9TSVhZ4JfuVdA4BYrIbia
         r08A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=4TytOV/lqVOrINb4NIjPNzviApMZbjwDnOpJOOSPzxY=;
        b=M6sE+Hrqz/yQBAdLashAPoys7u9Etr+OIX243PQRFHIslCkdxLeqqjPQgUuWZxZTl4
         718Rt2DJRUvHHJqhGfLv/Ginowr74sE1O6m/+WT45eK1VNYErpl+hWFiiOGBX9OwqMi1
         keZjAmPAL57hebEF8bTvuYfu+1Lts80gTJeggEileRoJcxP9vtKptnflqgUODc3ai+Hb
         rK8YHGxfNQBb6acCVMTSJ/cy4cBAnSjKbnizPCgccy1AjM2e7Tng7EMAkltP5bNwFnug
         7SvYT6sBBrzEoDCoPYBUs2z3bU0W7isxdeQj+OL+X8vqP8mrfcIpBOKmTkEgzF2+nn9m
         +UnA==
X-Gm-Message-State: AA+aEWbnXDLO3UmvkcJ+9NoDmlXpad/Hx5KsY4vhGZx5xB5S2N0ttl3Y
        Vg3uxgwZPjYFpalHRnUG6w==
X-Google-Smtp-Source: AFSGD/W/8aqOSq3WkP/7BXT55xPULQQib0ySahanhqm8+AA7w0u0gwOy+MZGflqm7o8CUreoOfYlAA==
X-Received: by 2002:a24:d857:: with SMTP id b84mr28456005itg.149.1546469661760;
        Wed, 02 Jan 2019 14:54:21 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d3sm23036154itc.40.2019.01.02.14.54.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 14:54:21 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request transmission
Date:   Wed,  2 Jan 2019 17:53:10 -0500
Message-Id: <20190102225313.2097-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When we resend a request, ensure that the 'rq_bytes_sent' is reset
to zero.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 1 -
 net/sunrpc/xprt.c | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 24cbddc44c88..2189fbc4c570 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1738,7 +1738,6 @@ rpc_xdr_encode(struct rpc_task *task)
 	xdr_buf_init(&req->rq_rcv_buf,
 		     req->rq_rbuffer,
 		     req->rq_rcvsize);
-	req->rq_bytes_sent = 0;
 
 	p = rpc_encode_header(task);
 	if (p == NULL) {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 73547d17d3c6..9075ae150ae5 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1151,6 +1151,7 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 	struct rpc_xprt *xprt = req->rq_xprt;
 
 	if (xprt_request_need_enqueue_transmit(task, req)) {
+		req->rq_bytes_sent = 0;
 		spin_lock(&xprt->queue_lock);
 		/*
 		 * Requests that carry congestion control credits are added
-- 
2.20.1

