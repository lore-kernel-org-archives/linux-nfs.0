Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBD0CC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:53:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B951921473
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:53:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J7+aRjbl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728431AbeLQWxs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 17:53:48 -0500
Received: from mail-oi1-f194.google.com ([209.85.167.194]:44374 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728393AbeLQWxs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 17:53:48 -0500
Received: by mail-oi1-f194.google.com with SMTP id m6so392096oig.11
        for <linux-nfs@vger.kernel.org>; Mon, 17 Dec 2018 14:53:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QRleCmCjbdBgpQjone5OFISkdxenEUacgJh7zknH83s=;
        b=J7+aRjblFC3Q4FR6P8jvpmCVRMPeoUV8GJ3QhdpFEUGJSndeKcZ0Tuy/DlVZZKZOrb
         GHy/LWlu4gFgDkwSGu+te1UqkWwKOmD54T8n04hCrNHOeJ/ph8N9YvC0Qe69rgieGi5u
         uwo4S4TYTPF+OMuoqrh+aWuAIvcD3DB8ZUTf0Vh9Mwz8u1CMY/PW4ihXqQjywfR/n+Ob
         I8ZyKtgYSf8s7/7Btt3CvJjVVJMcamK+QKdHaHyWnqyQEyPrGLlTu6Pp7MCfHVBoecUw
         /xRxazl/PbbFtjQJ/PgKYtrFHX62dLpBzTrpl+hh9KM/FHektWu7mvfjCoE11vhCHk/F
         fn+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=QRleCmCjbdBgpQjone5OFISkdxenEUacgJh7zknH83s=;
        b=mZ8WDGaAHULncMumT0KTBamOGumXOTdqoESK3OC9YJEzGyZJuXvaFgL5dEqCIaXw/w
         skeAKVL+B/Bk/0d3r/eGFilOV+3s7+uRTjSSUbP16sCmqOm/rn0L1mOtm9mR25WZVJh5
         1gesuNlE6TGYtmB6NM/8OKAhVj2RZl0UqJhNWydqyrgQWVwfe0wlCWvHKxr6eoKQUhg4
         5jrlS81fR448YPMopoiO7eywILrQ3yaeAIAQJMq2BaZ4sjmt8hA3gtf6BjINk2L+hLvF
         b6Ime08XvKLEjhy2eIcBFAmJbHeVUWWxVXixd1p+Gw1iTPwOI5mW1togIQThd8f9x4U9
         FvAQ==
X-Gm-Message-State: AA+aEWYcrnhREIOR9d8ebdcEWXNTBHlvUAas5+Q1ijdRal0GVX0CsQYj
        LMDsUH0hDtL3fjfLT43Vug==
X-Google-Smtp-Source: AFSGD/U4VHplbrwqPhaylcA4vzoVAmQFRwxBoWnyrjGgeHnwlU+5CtOF0ZOCFsO3538Krs8NuKcQow==
X-Received: by 2002:aca:e755:: with SMTP id e82mr6022765oih.153.1545087226847;
        Mon, 17 Dec 2018 14:53:46 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 30sm6984266ots.52.2018.12.17.14.53.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 14:53:46 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Dave Wysochanski <dwysocha@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] SUNRPC: Remove xprt_connect_status()
Date:   Mon, 17 Dec 2018 17:52:35 -0500
Message-Id: <20181217225235.124448-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181217225235.124448-2-trond.myklebust@hammerspace.com>
References: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
 <20181217225235.124448-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Over the years, xprt_connect_status() has been superseded by
call_connect_status(), which now handles all the errors that
xprt_connect_status() does and more. Since the latter converts
all errors that it doesn't recognise to EIO, then it is time
for it to be retired.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 32 +-------------------------------
 1 file changed, 1 insertion(+), 31 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3fb001dff670..73547d17d3c6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -67,7 +67,6 @@
  */
 static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
 static __be32	xprt_alloc_xid(struct rpc_xprt *xprt);
-static void	xprt_connect_status(struct rpc_task *task);
 static void	 xprt_destroy(struct rpc_xprt *xprt);
 
 static DEFINE_SPINLOCK(xprt_list_lock);
@@ -822,7 +821,7 @@ void xprt_connect(struct rpc_task *task)
 	if (!xprt_connected(xprt)) {
 		task->tk_timeout = task->tk_rqstp->rq_timeout;
 		task->tk_rqstp->rq_connect_cookie = xprt->connect_cookie;
-		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
+		rpc_sleep_on(&xprt->pending, task, NULL);
 
 		if (test_bit(XPRT_CLOSING, &xprt->state))
 			return;
@@ -841,35 +840,6 @@ void xprt_connect(struct rpc_task *task)
 	xprt_release_write(xprt, task);
 }
 
-static void xprt_connect_status(struct rpc_task *task)
-{
-	switch (task->tk_status) {
-	case 0:
-		dprintk("RPC: %5u xprt_connect_status: connection established\n",
-				task->tk_pid);
-		break;
-	case -ECONNREFUSED:
-	case -ECONNRESET:
-	case -ECONNABORTED:
-	case -ENETUNREACH:
-	case -EHOSTUNREACH:
-	case -EPIPE:
-	case -ENOTCONN:
-	case -EAGAIN:
-		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
-		break;
-	case -ETIMEDOUT:
-		dprintk("RPC: %5u xprt_connect_status: connect attempt timed "
-				"out\n", task->tk_pid);
-		break;
-	default:
-		dprintk("RPC: %5u xprt_connect_status: error %d connecting to "
-				"server %s\n", task->tk_pid, -task->tk_status,
-				task->tk_rqstp->rq_xprt->servername);
-		task->tk_status = -EIO;
-	}
-}
-
 enum xprt_xid_rb_cmp {
 	XID_RB_EQUAL,
 	XID_RB_LEFT,
-- 
2.19.2

