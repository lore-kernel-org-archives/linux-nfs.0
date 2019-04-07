Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F07D1C282DE
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C3E2520896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dpTHbfKv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726415AbfDGSBg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:36 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:55258 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726457AbfDGSBf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:35 -0400
Received: by mail-it1-f195.google.com with SMTP id a190so17229821ite.4
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=7+RfCsGjh57kJxTNv8RdAa7jguDzc4P+IDzwvzUYqlE=;
        b=dpTHbfKvPQDAajGxETo1jdDxVLNuKIU+nv8A3GH6DtQzW38Bk/g5qqbAlRrCQon/Dw
         czA7hE/S+13Q4tn67gm5OIsjfWflh+MR49GAEKxTXksCWAPwxX4Ot6g5F+T07HfBNpGS
         F+eH9sHA/GtK9lowSsKi8hFKfCJiWwS759FZTyjRDquaF9kBh+8YB1MbIgGaP3lXX52Z
         +NfKo4rtTjFy1SfA/fxK1Qhx2Zo+B93M6lxHMA5yowJFgOkheW3GKVfhDIhbuDbz7Y9Y
         DIDULyOC/cg0oKFIprzhRO2k6YOmj0wsywh00ZzqV77X/qZKFUnZm0cCdUJEaSq1cnmP
         wQYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=7+RfCsGjh57kJxTNv8RdAa7jguDzc4P+IDzwvzUYqlE=;
        b=GUtfysY1AigfCROl9Ppd3p+LCjerKehr1RVLZYByrh4/56P4j26HFllY4/ugzs1ITw
         FmcDKmPaBF7hhHB0oMB9yxa3fohNDjfOX3EamSO+6GCsikoXooarOxkWGjNURMQENC5m
         LXkci33OAkiklXAAGbQmO+7ZKpPr5AwDsl20kbV1Nj9ngCfWip72R5Nw0Xirc2q3tJXP
         we7plhwYe2DDPxgwzvZMkGRWn3qW/n28rE8oI9U/gxtJHqBmGcdNt6T9CJnYvK53800j
         uWdsDj03vyeJLhAg92ntZZQaoX9I9WstaHgohmen1hRIzMtS5FnzGBNxeEwN55j6cPuI
         K6FQ==
X-Gm-Message-State: APjAAAVU0Dy+mhzZ//VAC4z5qL5SUrdpJJLkZ+kZFd0YeZi9UGuVSg5u
        TkEROH10pWtP6RQSyoQkE2SI7a4=
X-Google-Smtp-Source: APXvYqx/p8AC9BhkAY7AV9EAY9x7KXl6LW57kotBoeKeFQEBYu3VgXqKILo27Deqkv/FTC2KZGFhOw==
X-Received: by 2002:a24:9414:: with SMTP id j20mr18122081ite.91.1554660094764;
        Sun, 07 Apr 2019 11:01:34 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:33 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 14/29] SUNRPC: Ensure to ratelimit the "server not responding" syslog messages
Date:   Sun,  7 Apr 2019 13:58:57 -0400
Message-Id: <20190407175912.23528-15-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-14-trond.myklebust@hammerspace.com>
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
 <20190407175912.23528-11-trond.myklebust@hammerspace.com>
 <20190407175912.23528-12-trond.myklebust@hammerspace.com>
 <20190407175912.23528-13-trond.myklebust@hammerspace.com>
 <20190407175912.23528-14-trond.myklebust@hammerspace.com>
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

