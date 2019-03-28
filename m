Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70596C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4089221850
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NwyMyf7Y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727182AbfC1U4R (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:17 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:50374 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726224AbfC1U4R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:17 -0400
Received: by mail-it1-f196.google.com with SMTP id m137so490249ita.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CKqr29vQaN4sNjVtSiBBgpVkL8l4vpGa4AABsIgSvPc=;
        b=NwyMyf7YuE33cnp/ThAED4vuVAa8GRVyl+HrsURsdozG3xgGHhl5UX1XdLvpVfsz3u
         gBPAsup2YrE1eDE4tvuovwOn+MhrPeCm9secXzVjNZJw8/6kKSs4SwtLubTSLg05JdVH
         6/Lkdtnqa7/uARiXhUzB59gK5twDPiIpwpZtxhP0ZhvLL4dAXkhwIkuy8Zd4/cWOars7
         UL7hclGabMUGAJ3eS758OJjd7cX7HEP+OdAlhnHPiMhJMuNVyxavHuKb40O4BUtrpEiJ
         4+3Mom9eJojPHZCcCp7KQabuKTmOvCl0f1sEhoIdNLJvfM2QTd63nbMmgAE+DjBJ69g8
         XTqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=CKqr29vQaN4sNjVtSiBBgpVkL8l4vpGa4AABsIgSvPc=;
        b=iOSZ1LTOVWzmdApGR2eFhprV+3eP66l1CnlNXmU2+XDF/omDAyNndL4dhZ0GUOosRd
         yiA9KuCYw8zGCa0iLOmqmhKeT6MZVUeiuMzJ+ZZj+Cn86AzCHUYFdIwhn//nA6xfD887
         Ss9M+55jy9HRuD6EXqVvJLo7559TOWwUuqOinG1/AgfkWbECoIUJ1Qxbbm3LPzATkCGB
         WBdoxUIs4xIvHPvpzqk5SqtFjGkYEz0YVqCxqn9wF+AXAFRPR0KRzDor7wabg82mR9i5
         K3XiShcL10l0PCsP/qvNT4r+drdnGlK+Ar6pl+xHUP5SgOhiVWHMSqoQ4iMnYzNXRqjL
         FjXQ==
X-Gm-Message-State: APjAAAW6mjlXlbBY6AHGKPDA1YUYGPijznopW3DVXTxElhaT3KRjJhb9
        NdWTfIY5ZmZgfg8QkfBy7GWFMUI=
X-Google-Smtp-Source: APXvYqynhvyEj3ryy7Wo0ZOfg2jxUbuMzzgd9NAY4kqBSodHt2csKBmXTe2Cx1vSClqAlomwQFOn0Q==
X-Received: by 2002:a05:6638:61a:: with SMTP id g26mr9020060jar.83.1553806575073;
        Thu, 28 Mar 2019 13:56:15 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:14 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 08/25] SUNRPC: Ensure that the transport layer respect major timeouts
Date:   Thu, 28 Mar 2019 16:52:22 -0400
Message-Id: <20190328205239.29674-9-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-8-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
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
index 7c3623b17493..6b2b71a2ec43 100644
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

