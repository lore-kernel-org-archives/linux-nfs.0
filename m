Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5319AC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 23FCC2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YXgrzgBe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730303AbfC2WCJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:09 -0400
Received: from mail-it1-f180.google.com ([209.85.166.180]:55152 "EHLO
        mail-it1-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730345AbfC2WCJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:09 -0400
Received: by mail-it1-f180.google.com with SMTP id w18so6171253itj.4
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7+RfCsGjh57kJxTNv8RdAa7jguDzc4P+IDzwvzUYqlE=;
        b=YXgrzgBeIqgMTo541zf4pjvjMF/dBq6jx6Y28bEo8Q4y6I0P4gLP0Os4RyK3DS4BAv
         /HVVh7hnsc45JQ3VJK0MhFkx0UGt1JObnucebZrwU8BSo89n21VqeNdzQC7idwkjtlz3
         MiUBHKhtIcpUCvM3wGdRDRv+xUJUkNdzbrso2E0jJtLCevdhR6DCy1y/CBTqtey/x2ox
         GJp8kovOVuqQh0JLBk4QnywxiTrJjZmVe4waKdHURo7b5+VpxFcWz4Hg4PhH6+kJjFKD
         hg5zS4VoWNRDLc4tIhoP6L9TA2h7Tae/bZIfTekci31izK3dRyuNIrBJfRcXmPr782Ge
         lE2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=7+RfCsGjh57kJxTNv8RdAa7jguDzc4P+IDzwvzUYqlE=;
        b=T0YbFz538rdXt14szznEQk6VFENfiLIMnSy+jWC7/d5df2oa4+l1+CtI0jRwWdy3hL
         swIH6SOJ7Loi/P0+Q7WCVpPV4jzJotjM+YDR0zYJlPGyaH3UdA1ZfWrTMJn6Ti7QRYlX
         eUa93Hwb+yyemUaW7iCH7LGZ/X+uNxM+uUaS5++krvg5+O0uFJXLMl7y9+Hu/19ieybY
         biVxMeqgLOS8dKYK0ZOf+Nt+JZNHMAxOkL3KnCLDiYxSCZ/XeyXw4AllnO79vSR5gxVx
         wIV4w9urCqz0PckuEQUTvpAoEnvACJz2tT5q2QhkeCQC9QysoHkaa4hDcEpLVj84qkkP
         heIQ==
X-Gm-Message-State: APjAAAXE4m8VKKS/IYt00YRFt7ldJ/PN6b/Q+/iV63vDASF/Lc/Q2L1c
        M+e0l724owFXod4th+ucwBGUWmc=
X-Google-Smtp-Source: APXvYqxPVLWsq2D9yR9KbWCIiK7iEyGxFrBTwyHkBvXHADjDZ0rAIA5znxkg/PJJpdfV0Gy9bMmlzQ==
X-Received: by 2002:a24:4acd:: with SMTP id k196mr6455345itb.101.1553896928144;
        Fri, 29 Mar 2019 15:02:08 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:07 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 14/28] SUNRPC: Ensure to ratelimit the "server not responding" syslog messages
Date:   Fri, 29 Mar 2019 17:59:34 -0400
Message-Id: <20190329215948.107328-15-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-14-trond.myklebust@hammerspace.com>
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
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In particular, the timeout messages can be very noisy, so we ought to
ratelimit them in order to avoid spamming the syslog.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c921a5aff790..c0b79d307579 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2354,7 +2354,8 @@ rpc_check_timeout(struct rpc_task *task)
 			return;
 
 		if (clnt->cl_chatty) {
-			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
+			pr_notice_ratelimited(
+				"%s: server %s not responding, timed out\n",
 				clnt->cl_program->name,
 				task->tk_xprt->servername);
 		}
@@ -2368,9 +2369,10 @@ rpc_check_timeout(struct rpc_task *task)
 	if (!(task->tk_flags & RPC_CALL_MAJORSEEN)) {
 		task->tk_flags |= RPC_CALL_MAJORSEEN;
 		if (clnt->cl_chatty) {
-			printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
-			clnt->cl_program->name,
-			task->tk_xprt->servername);
+			pr_notice_ratelimited(
+				"%s: server %s not responding, still trying\n",
+				clnt->cl_program->name,
+				task->tk_xprt->servername);
 		}
 	}
 	rpc_force_rebind(clnt);
@@ -2400,7 +2402,7 @@ call_decode(struct rpc_task *task)
 
 	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
 		if (clnt->cl_chatty) {
-			printk(KERN_NOTICE "%s: server %s OK\n",
+			pr_notice_ratelimited("%s: server %s OK\n",
 				clnt->cl_program->name,
 				task->tk_xprt->servername);
 		}
-- 
2.20.1

