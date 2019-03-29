Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14830C10F05
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D44C0218A5
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BUAadduX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730316AbfC2WCG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:06 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:43909 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730303AbfC2WCF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:05 -0400
Received: by mail-io1-f66.google.com with SMTP id x3so2971117iol.10
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bNrgjUvS3hhAMqUYc+SvBMF91w3FDr05DxciDPgvPU8=;
        b=BUAadduXbw27cd7+DJjCZA6UX5JiGKL8mcS3SQipocZmanT6z3VxvPxYKM74xW+gsv
         3nZrwZxiupPwDpxeo8R9w7OyY2PoRZ4iGtcoZvHfpf5COWSW8+9MNqiCwI2fR/cirydk
         1iqRkfidSgoXeEa5o5pYehSxNS01sJuWhaDxypTjgH3yKryx2t28cXDYPu8/kUXmECOW
         c5jhnxtHrrh9jFXJvVlsdmlt8GmZK996B/rlf+Z9bKNjkUh1nFT8XITn9ucGjC9AlIiH
         5VkjQuoAvVE1N+sqvNhjH6NYOdlzhnOzvC0yXT7ozyYwQnMs2tp5Pxs+2s2JBxj+X2HS
         ZspQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=bNrgjUvS3hhAMqUYc+SvBMF91w3FDr05DxciDPgvPU8=;
        b=BSbw26bQwP0yEDaijRFNSY+jtvXCRCgzsW8UY1idZgRNM8jRQegU+AnkxqUAfk9h86
         vXO+F0ujc1haGxT0JZkI0Yguf/03G6FzYSawyfKw8pqWssJU87c8RZ9+nJVAm0456J2j
         1aV4rJ/SB/Z8icLVIUgrAYzoX0tLtXsgDZD1Wsm/DFu7t9lwwJHi1FkXIEtrBq21fXn7
         Fl2xa+uc6VMbMOKLhwZI4oxXPCfS/9Wd6kGCYAm88zhvraPkf4GoT6T7o8SiCdgTGcgu
         Ic5WpQh/n4Bn4l0y7hGMWqJTI+TiH/Lp14C3Y6l/CTgAGgIuHI8HaLvS4+rkSxEzNDen
         HZ2g==
X-Gm-Message-State: APjAAAWvpfwJSa3VteenEMgnjD1/qptY39BMEbFSN411J5isEDBsMiBF
        axP+jnolwfwRzsMlc8x3yJOmvh4=
X-Google-Smtp-Source: APXvYqxthN06501u5x/Ip32JMdtvgFdp3q6S5WvAvEW8/ftNbOZMG2qtP/2IVzYunOHSXQIfN9dlng==
X-Received: by 2002:a6b:db19:: with SMTP id t25mr34926939ioc.140.1553896924502;
        Fri, 29 Mar 2019 15:02:04 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:03 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/28] SUNRPC: Ensure that the transport layer respect major timeouts
Date:   Fri, 29 Mar 2019 17:59:30 -0400
Message-Id: <20190329215948.107328-11-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-10-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ensure that when in the transport layer, we don't sleep past
a major timeout.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 36af1a1929af..642cc0f64e44 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -73,6 +73,15 @@ static void	 xprt_destroy(struct rpc_xprt *xprt);
 static DEFINE_SPINLOCK(xprt_list_lock);
 static LIST_HEAD(xprt_list);
 
+static unsigned long xprt_request_timeout(const struct rpc_rqst *req)
+{
+	unsigned long timeout = jiffies + req->rq_timeout;
+
+	if (time_before(timeout, req->rq_majortimeo))
+		return timeout;
+	return req->rq_majortimeo;
+}
+
 /**
  * xprt_register_transport - register a transport implementation
  * @transport: transport to register
@@ -212,7 +221,7 @@ int xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 	task->tk_status = -EAGAIN;
 	if  (RPC_IS_SOFT(task))
 		rpc_sleep_on_timeout(&xprt->sending, task, NULL,
-				jiffies + req->rq_timeout);
+				xprt_request_timeout(req));
 	else
 		rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
@@ -279,7 +288,7 @@ int xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task)
 	task->tk_status = -EAGAIN;
 	if (RPC_IS_SOFT(task))
 		rpc_sleep_on_timeout(&xprt->sending, task, NULL,
-				jiffies + req->rq_timeout);
+				xprt_request_timeout(req));
 	else
 		rpc_sleep_on(&xprt->sending, task, NULL);
 	return 0;
@@ -795,7 +804,7 @@ void xprt_connect(struct rpc_task *task)
 	if (!xprt_connected(xprt)) {
 		task->tk_rqstp->rq_connect_cookie = xprt->connect_cookie;
 		rpc_sleep_on_timeout(&xprt->pending, task, NULL,
-				jiffies + task->tk_rqstp->rq_timeout);
+				xprt_request_timeout(task->tk_rqstp));
 
 		if (test_bit(XPRT_CLOSING, &xprt->state))
 			return;
@@ -1087,7 +1096,7 @@ void xprt_wait_for_reply_request_def(struct rpc_task *task)
 	struct rpc_rqst *req = task->tk_rqstp;
 
 	rpc_sleep_on_timeout(&req->rq_xprt->pending, task, xprt_timer,
-			jiffies + req->rq_timeout);
+			xprt_request_timeout(req));
 }
 EXPORT_SYMBOL_GPL(xprt_wait_for_reply_request_def);
 
-- 
2.20.1

