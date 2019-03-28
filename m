Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14393C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D73DD2184E
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vOWqqhPC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727068AbfC1U4T (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:19 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:33208 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726248AbfC1U4S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:18 -0400
Received: by mail-io1-f66.google.com with SMTP id b6so20848iog.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5ouCXh9TswibOEYyqCZQnuH8aNs7rUu1bqJGunz5ZWo=;
        b=vOWqqhPCCoW6A9aM33kXfVMkryU6tbeEp9ExPC3K2CuIf+0U4j8Mb5/UWAUZ1NzjnP
         NLKfBOSeG8C+8xHg0AY9CdPKKviivOPk8bX88tM/S2qWHuBErcSf2DDEwM/xGTNa0lYx
         7sMD52j9sz8SoBC4UuWkaKQzHzdPIzE+q4oRLkUasaOQsrwKERHpy2oKys5e46xFu1Gt
         Q4mlJuQ1SWMdjMXSHlIKJQUDmtv7d6Y0yfQGcZSfNMEx3um73Y3TVKEaaM53SDZB42bX
         GJWxNo2nJGtXaovo0eLF8ZYwJpuL7NIaapn90K+Y8TX9q1R1q4czv1nFn/meKE0dj9Bm
         4teg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=5ouCXh9TswibOEYyqCZQnuH8aNs7rUu1bqJGunz5ZWo=;
        b=iS7F38mkvVugr8ZJoE4hjLsk+GI9AcBw7iv71uv1xekGWrJ4k/F3/PSCiCvzB4a+nt
         cbaNZ5ats1kE51r00mviNz/c1eKZnMczkRdrgRxG5MJJzKo4cQDZSrJcga4Ed4BrOzGh
         tqE77ieDUJ3UIQZLVQT4X9vQ/n0r5lVZ6RQs284vU3SHGEnIhjUc7mXhvG4jy9wzECEd
         89kTqaGqRpp3ZV9NZT0iBSK3VwMcLQ8KgPVtmPkPjWKilMmyngVHIgEeg/znXDs01Bzh
         tbHghC38QDUhhkBy5+CeZlJs2e2/bCdIjtDlESG+2mGskNq0EWvRjANMTXegk4NPm5G6
         9uLQ==
X-Gm-Message-State: APjAAAWbadG2/y3kVgM8J7IdWM1MVX2BofsSj+A+dlDOte92XBD3iyXQ
        tqYxPAL0/elhBFa5M9QeP6Cx+og=
X-Google-Smtp-Source: APXvYqxjr32yfAoKIltLwxuDMDCuqVHEJjUKDMurqOUC4mLgTVg3kXmHsHi3yVNZM7wNjsvp+8YQ+w==
X-Received: by 2002:a6b:e305:: with SMTP id u5mr31351660ioc.262.1553806577312;
        Thu, 28 Mar 2019 13:56:17 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:16 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 10/25] SUNRPC: Make "no retrans timeout" soft tasks behave like softconn for timeouts
Date:   Thu, 28 Mar 2019 16:52:24 -0400
Message-Id: <20190328205239.29674-11-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-10-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a soft NFSv4 request is sent, then we don't need it to time out unless
the connection breaks. The reason is that as long as the connection is
unbroken, the protocol states that the server is not allowed to drop the
request.  IOW: as long as the connection remains unbroken, the client may
assume that all transmitted RPC requests are being processed by the server,
and that retransmissions and timeouts of those requests are unwarranted.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a9e5e81c67be..d943566a06b2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2344,6 +2344,16 @@ rpc_check_timeout(struct rpc_task *task)
 	}
 
 	if (RPC_IS_SOFT(task)) {
+		/*
+		 * Once a "no retrans timeout" soft tasks (a.k.a NFSv4) has
+		 * been sent, it should time out only if the transport
+		 * connection gets terminally broken.
+		 */
+		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
+		    (task->tk_flags & RPC_TASK_SENT) &&
+		    rpc_check_connected(task->tk_rqstp))
+			return;
+
 		if (clnt->cl_chatty) {
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
 				clnt->cl_program->name,
-- 
2.20.1

