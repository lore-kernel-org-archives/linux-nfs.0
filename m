Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEF30C10F0E
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BAF2720896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NIkqbGIo"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726360AbfDGSBY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:24 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:38886 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726335AbfDGSBY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:24 -0400
Received: by mail-it1-f193.google.com with SMTP id f22so17363622ita.3
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zz773VegMbcU2sacF+d/IbwCEchGH41iyaN0Z+U7NKQ=;
        b=NIkqbGIocS8LjHen8TtQoWeyu0FVm9/S701KPkkJP+47wNjYURtbJSGYrIEy+yRiWm
         kWcFmYeJIL1LQiGPKTgS91RSgEGJjAokEKRVCtPcatA0zYzFSjtbV3cUjkXCvU+bvntX
         Em/NuEOBXPxMTzZpZIS4O59we7+Sxc4fFaOdjqRq6XP0til34XcTrltgftPxVSrEwa9j
         htVTkNeBH7ueyBQg/H2RbmVarf3qeconBfSSnz2V77mhcE3eu3p2xEkcvhuR2um3M2rx
         AU4XdfD0M2nJYGaThYKEJ7bKiPa/k5vAwKzN56k38MmlL3FVJc0jNmOaa9bD/n5/NZmI
         vLSw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zz773VegMbcU2sacF+d/IbwCEchGH41iyaN0Z+U7NKQ=;
        b=f9OeXm1BaYB2oC4fM5Ryk9AP6PPBr8PBlh2VS6y3VDkVtxAXnAzcXX2gX4uZdIOQCT
         NMtj3RM+e3tdfA8JnzrWoemI745ZXnY1P2mRM+XhSK7D4rgKpjqUJw8Mi/XFdotfXy+C
         fjEj3sfVnW9DrbLn6WNeMSwsXImNfZi/FJAngKwXMlFGxeSak2WjuG99uM3n97yvlNb+
         VYwET2ZOZ3JbK+OJABJ6G9zuTrsSq/qWFiozHRv0xEHhYlGzl/70k71PwO2dsc417YfU
         TRCOOgBq+skKesqc7J4SvxCPY7RT4tSOEmaeXCSE2OomgK7clUaeysDR26Z8kTou7GkP
         Jh1g==
X-Gm-Message-State: APjAAAUb7rq3K6zUGeVEdvwcybVSuFfJjGmzvppfnA9PtLLDyaTdoetc
        vdJNLhodSADo3BUIJOkTwg==
X-Google-Smtp-Source: APXvYqz1G4N5mordk8rHOYxthlpJHJAS1T6S21q5GIbTD+l7RioeTEtRRk8cBjQODR14Wluo4A7hfQ==
X-Received: by 2002:a02:cbda:: with SMTP id u26mr18392371jaq.7.1554660083101;
        Sun, 07 Apr 2019 11:01:23 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:22 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/29] SUNRPC: Refactor rpc_restart_call/rpc_restart_call_prepare
Date:   Sun,  7 Apr 2019 13:58:45 -0400
Message-Id: <20190407175912.23528-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-2-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 30f5995c6a68..88b4685e7977 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1464,20 +1464,13 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 }
 EXPORT_SYMBOL_GPL(rpc_force_rebind);
 
-/*
- * Restart an (async) RPC call from the call_prepare state.
- * Usually called from within the exit handler.
- */
-int
-rpc_restart_call_prepare(struct rpc_task *task)
+static int
+__rpc_restart_call(struct rpc_task *task, void (*action)(struct rpc_task *))
 {
-	task->tk_action = call_start;
 	task->tk_status = 0;
-	if (task->tk_ops->rpc_call_prepare != NULL)
-		task->tk_action = rpc_prepare_task;
+	task->tk_action = action;
 	return 1;
 }
-EXPORT_SYMBOL_GPL(rpc_restart_call_prepare);
 
 /*
  * Restart an (async) RPC call. Usually called from within the
@@ -1486,12 +1479,23 @@ EXPORT_SYMBOL_GPL(rpc_restart_call_prepare);
 int
 rpc_restart_call(struct rpc_task *task)
 {
-	task->tk_action = call_start;
-	task->tk_status = 0;
-	return 1;
+	return __rpc_restart_call(task, call_start);
 }
 EXPORT_SYMBOL_GPL(rpc_restart_call);
 
+/*
+ * Restart an (async) RPC call from the call_prepare state.
+ * Usually called from within the exit handler.
+ */
+int
+rpc_restart_call_prepare(struct rpc_task *task)
+{
+	if (task->tk_ops->rpc_call_prepare != NULL)
+		return __rpc_restart_call(task, rpc_prepare_task);
+	return rpc_restart_call(task);
+}
+EXPORT_SYMBOL_GPL(rpc_restart_call_prepare);
+
 const char
 *rpc_proc_name(const struct rpc_task *task)
 {
-- 
2.20.1

