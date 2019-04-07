Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6929C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 991A920896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DAmB9tqC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726437AbfDGSBb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:31 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:39222 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726409AbfDGSBb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:31 -0400
Received: by mail-io1-f66.google.com with SMTP id e13so9079621ioq.6
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bNrgjUvS3hhAMqUYc+SvBMF91w3FDr05DxciDPgvPU8=;
        b=DAmB9tqCZ7GV9M6ZvDwuOFhb+Pz8cR71z4JV6im4ysFasO92V8e5oqnpMpcx2aUw8O
         ohTKBTqWA/DNkah+8ZnsyrLuhG4xRbfkLEjKnTiy45sS1jT9gnsrbPxnRUwiRWxSanMo
         5BPLEQq59+pXcorznisqfsFsCYkrMZ4OdAb0DOBS/fje+CYWugileRGsUYqdqAw60i35
         lswGVnzz7MwVTGYd1qvWoyZYvPsMcKl/OhdewyQFIeymNcWTreyFfZj5gkH4dj8+qPbk
         HlzP7xRu9AhHH8vsVNL5HYZcC3aeFr/lDdETJVRicQhGPd9ICnoE+CyDry85eq94hmuL
         gESg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=bNrgjUvS3hhAMqUYc+SvBMF91w3FDr05DxciDPgvPU8=;
        b=nQjxsoJisVql1e9pKxyreOTnADU4xtd7/dwQ4rh02isDH2TJ5HSWLQUW6Caic4vIYk
         MGVTJPxTk6/GfDv2DWjD7yKOcDVS3c7t898D0YSjb1rWRFe5/c+2glueOPQnG+3Yxfua
         I17iX1dFDKI4VetWy+62FH3x6zNcxMRcNLrTawR6lJnxsLI4M3prbINw0I0cG/Jk+ebR
         FFn1h6lCnUxHj7xzirrX24mcRPDPrnIr6+FED9vvK6kPsuoi4zGIe5mJ5MHeWoUd2o4w
         hxen0+cSKE6gXeLwJlTZYSJrBJklSCevtSYzuYBsMf1H0Bhu3Z5S2p/7rf0UR7POijq4
         0P0g==
X-Gm-Message-State: APjAAAWpDUqL6w7kXN1JntsZaR+PjgYKxexEFvkMeMooBT3c1WV973IU
        lKDjGk5yoKpTqTaJgCl8EyEuDmU=
X-Google-Smtp-Source: APXvYqyBP4zK4Tee7W0Y5I/R+qW4vRr0y7Sa9IU4HQbjeHGINDi+lwxXMHxyHD49/hh2hlbwP8C4ng==
X-Received: by 2002:a6b:641a:: with SMTP id t26mr15165434iog.41.1554660090159;
        Sun, 07 Apr 2019 11:01:30 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:29 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 10/29] SUNRPC: Ensure that the transport layer respect major timeouts
Date:   Sun,  7 Apr 2019 13:58:53 -0400
Message-Id: <20190407175912.23528-11-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-10-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
 <20190407175912.23528-10-trond.myklebust@hammerspace.com>
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

