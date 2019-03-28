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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C876C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3A05C21850
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d21jEdiR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726100AbfC1U4K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:10 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:35513 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727181AbfC1U4K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:10 -0400
Received: by mail-it1-f193.google.com with SMTP id w15so505300itc.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zz773VegMbcU2sacF+d/IbwCEchGH41iyaN0Z+U7NKQ=;
        b=d21jEdiRTFyMa8dlcy2LT1gfvsFPRCMk3XApz98RWXVF/SyxNhHHhN8lFuic+wIT+m
         D5VIQZRm7aPOqH2dqL333xBDIyYqBa8uCxVfTmrguACBLbZQrTVPMcFDyC7TO+IDQNgB
         lNB9nQM+ciGnCXv3aI8jz2PpMS5cxhT+5H+P7kVnNztJtdDc7ulKsin3vJEK6Yx25rLD
         X0Qd+37YTeaLCSVYONFpF+yRiOfXhtJ5/y74vlKRTcdF3hKNtLRvJyyMJzEkY9BcDqXa
         Ax/rZhHHnUeEoOoGaqtLmktpBGP37Peq5ZWQ6ln00GoEB/XsHd2bTQ6qqGQWnteZAtOg
         Qq2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zz773VegMbcU2sacF+d/IbwCEchGH41iyaN0Z+U7NKQ=;
        b=tKX0G8vmNkZ1z9aDXuz65lRga/DjbSztr1HYf6QMfTWKMuA0l3dAeUI/f/G6HLUrq6
         0jdnpZOwYgXQg8clUXNTYv92E4BYsPRz1bksy/jnhFoImc3Aq3fIXbdMx2VsjUBvvUU3
         h1ZXe4bCqAEEbhnqKg9njTTon5unjOr2ySgwQ9vtwhtOAWYMnTIYYSj61IcfWvcs9nb8
         iTLh7P2g7hDCYYNiNxRz3leEkaalcgWSDpPut3EGAp2D49W72kw7eqP8hf/wGat96nws
         qXJzbcdzLx0IVYEzSQIENfZJ45p2FZ8S7KBAQtNDVFE4MAtw09ArsRdPSQ4Dg0k6Wik2
         QMSw==
X-Gm-Message-State: APjAAAVxo0XSuRdaNak+eLPF1u36GLkMHY8l4p3atT14gUQbDUXMsmyS
        JtybTCf6SPBMzHJuYfkup1paKMk=
X-Google-Smtp-Source: APXvYqz0oFQmcU68JwdeJ51z4t42qChOYegRwApa4MxoE3kSazw9hGmMoL4Oto28n84KgTkOdoDIhQ==
X-Received: by 2002:a02:5f58:: with SMTP id r85mr31935636jab.56.1553806568964;
        Thu, 28 Mar 2019 13:56:08 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:08 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 02/25] SUNRPC: Refactor rpc_restart_call/rpc_restart_call_prepare
Date:   Thu, 28 Mar 2019 16:52:16 -0400
Message-Id: <20190328205239.29674-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-2-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
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

