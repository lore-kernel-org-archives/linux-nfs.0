Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 162EBC4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DAC2E2184E
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KOPWh8Aa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727200AbfC1U4U (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:20 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:52674 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726679AbfC1U4T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:19 -0400
Received: by mail-it1-f196.google.com with SMTP id g17so470840ita.2
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LDKwyWzrN2LfmMMdwBLp8X6mkvE7eY5ZD8OK2VVLSE0=;
        b=KOPWh8Aaek44ig3bOVC30x2GmQpZyzsk5Xao9eMUDYvPawre+15HDq0KEBRQSxtNXm
         r6PIbiJYm1abLOuGwTWusmEsrE5Tne3XF96v8G24QTFxPhj7Y6COAS3KfrI0BgmAcwZo
         deXP1qAC+ZqCKaQaGTZAVCXukQyynjwNpmZF2XqmGa+1nBvO7ol9BSMO12oVSBpGn5FT
         bY1mhTDgLi7GBiwV5abrdmYWY2qxJnsPQTqOZXIH3c3Cz9qhF7g5G8N7o4IH/yqBGR4p
         C4mCsfGL0x4I2pTKEXRL7veUfacrETq7i8p3/Z04UkmVHVO3vCjwZBSG/AJ1Vu5Nt+mN
         PxOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=LDKwyWzrN2LfmMMdwBLp8X6mkvE7eY5ZD8OK2VVLSE0=;
        b=J8nHSrDww3f89a5TR2K1qCZDEcL4XaS4oHy4cQMX1dK0Y6wiO7RtvP5oZDm4cNnFMr
         Ddel+mbGZh59TvUjbsX0rNDYDC91IlMFfApdXySxnkF70XtbD/FSE9EhPQMmduhxO8AD
         dlhjR32KR6P3MGPbUS0SILo7eZboWYwPnuwYu9fiqBIunxu/yfU9vlesXfzxP1nw7X+U
         YD6bH756FO7th4JaBraEhyOwWKFUB3EID7VbI1zRGFONKlfn8YkSe5f3P4nM5w4P2jXB
         t1zTS/WjVOzl6SxBw40TXzljUTBDEQdZe6eCzPbCdthFjiOazLFHn2JTttGS1WZ9emvw
         LjcA==
X-Gm-Message-State: APjAAAXL4jflwsvhmWeySHK5QM8tiNup8ayBZNL4/XUgqIwNqGpR2rSk
        iGZERgXIgRR/pNDRhhYfLtxkLs4=
X-Google-Smtp-Source: APXvYqxgvnD78a5YqWBbffNkpzq7LW7DEYdSXasE3UGVJX0qXJDJgxgMbaf+KrjpOb3rKutqZHbTiw==
X-Received: by 2002:a02:745:: with SMTP id f66mr33870417jaf.137.1553806578230;
        Thu, 28 Mar 2019 13:56:18 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.17
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:17 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 11/25] SUNRPC: Start the first major timeout calculation at task creation
Date:   Thu, 28 Mar 2019 16:52:25 -0400
Message-Id: <20190328205239.29674-12-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-11-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
 <20190328205239.29674-9-trond.myklebust@hammerspace.com>
 <20190328205239.29674-10-trond.myklebust@hammerspace.com>
 <20190328205239.29674-11-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When calculating the major timeout for a new task, when we know that the
connection has been broken, use the task->tk_start to ensure that we also
take into account the time spent waiting for a slot or session slot. This
ensures that we fail over soft requests relatively quickly once the
connection has actually been broken, and the first requests have
started to fail.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 44 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 34 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 6b2b71a2ec43..fcd827f032c0 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -569,18 +569,44 @@ bool xprt_write_space(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_write_space);
 
-static void xprt_reset_majortimeo(struct rpc_rqst *req)
+static unsigned long xprt_abs_ktime_to_jiffies(ktime_t abstime)
+{
+	s64 delta = ktime_to_ns(ktime_get() - abstime);
+	return likely(delta >= 0) ?
+		jiffies - nsecs_to_jiffies(delta) :
+		jiffies + nsecs_to_jiffies(-delta);
+}
+
+static unsigned long xprt_calc_majortimeo(struct rpc_rqst *req)
 {
 	const struct rpc_timeout *to = req->rq_task->tk_client->cl_timeout;
+	unsigned long majortimeo = req->rq_timeout;
 
-	req->rq_majortimeo = req->rq_timeout;
 	if (to->to_exponential)
-		req->rq_majortimeo <<= to->to_retries;
+		majortimeo <<= to->to_retries;
+	else
+		majortimeo += to->to_increment * to->to_retries;
+	if (majortimeo > to->to_maxval || majortimeo == 0)
+		majortimeo = to->to_maxval;
+	return majortimeo;
+}
+
+static void xprt_reset_majortimeo(struct rpc_rqst *req)
+{
+	req->rq_majortimeo += xprt_calc_majortimeo(req);
+}
+
+static void xprt_init_majortimeo(struct rpc_task *task, struct rpc_rqst *req)
+{
+	unsigned long time_init;
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	if (likely(xprt && xprt_connected(xprt)))
+		time_init = jiffies;
 	else
-		req->rq_majortimeo += to->to_increment * to->to_retries;
-	if (req->rq_majortimeo > to->to_maxval || req->rq_majortimeo == 0)
-		req->rq_majortimeo = to->to_maxval;
-	req->rq_majortimeo += jiffies;
+		time_init = xprt_abs_ktime_to_jiffies(task->tk_start);
+	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
+	req->rq_majortimeo = time_init + xprt_calc_majortimeo(req);
 }
 
 /**
@@ -997,7 +1023,6 @@ xprt_request_enqueue_receive(struct rpc_task *task)
 	set_bit(RPC_TASK_NEED_RECV, &task->tk_runstate);
 	spin_unlock(&xprt->queue_lock);
 
-	xprt_reset_majortimeo(req);
 	/* Turn off autodisconnect */
 	del_singleshot_timer_sync(&xprt->timer);
 }
@@ -1631,7 +1656,6 @@ xprt_request_init(struct rpc_task *task)
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct rpc_rqst	*req = task->tk_rqstp;
 
-	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
@@ -1644,7 +1668,7 @@ xprt_request_init(struct rpc_task *task)
 	req->rq_snd_buf.bvec = NULL;
 	req->rq_rcv_buf.bvec = NULL;
 	req->rq_release_snd_buf = NULL;
-	xprt_reset_majortimeo(req);
+	xprt_init_majortimeo(task, req);
 	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
 			req, ntohl(req->rq_xid));
 }
-- 
2.20.1

