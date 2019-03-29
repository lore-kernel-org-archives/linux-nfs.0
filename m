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
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5D8BC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A0FAB2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t531HpBi"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730237AbfC2WCA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:00 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:52864 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730137AbfC2WB7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:01:59 -0400
Received: by mail-it1-f196.google.com with SMTP id g17so6188303ita.2
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:01:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zz773VegMbcU2sacF+d/IbwCEchGH41iyaN0Z+U7NKQ=;
        b=t531HpBiKz31qKYv8XYdUN8KI0aACgJeMrEB0/KuHsSMfpiT7twJF1LHgnlvAErfYo
         88kQFdu4Q75lUuq+63xsdSzHpSUiI+zs8nLhTZ6clpKPo7++h7fOyfzhknvGTCmnuObi
         dzoPxJtkiph/RxsSH166s6kBuddb9fZsAozHuiW1oYdwV8O1M6e2WLmGdSUuFRdQoHZc
         Hmk+TDux7btTGjxnY43c7aUlr7rdQg//3be27RqpZJoNtWbUQSZWGuyeKbpJLsyntNuz
         lhOVLUO3cEuxIzMjnSrkCeBanCB48WOxQx/j3qJOYRqhKxS+dna0uK+t/SluP8y/KPCA
         xGgQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zz773VegMbcU2sacF+d/IbwCEchGH41iyaN0Z+U7NKQ=;
        b=VCFzfeugAPqYGi3RDvxKL1wVJRtpmr0cZug6t5gqh3AHomRAfG6m9e6KWXlNPQ+YA0
         V4MQxAfbn1XDzr+qAPPGN1xlX0JVv21lyXhqJKtJ/+8VMEQSaL5P8fLdvc6Zkr6zBhiM
         oqyW8BmAkGfi6q/d+Pyt1oWU+8RbusECyDE6RP0es0v+pkDqW/n1qIwG09tSsMzkMYpF
         cc1MmNorYMIrBItGzgioDKoMIBTUVvEUgwEOIvjC8ztPGQGmVgGPby/uLd36CbDJuCOG
         CbKSDGz5oopSPUV78WoTWLNCE91wmI2Oty6Ts+cF1jRN9ckHlw8cikSp7WVkBlAD9e2Y
         Ryhw==
X-Gm-Message-State: APjAAAXH45utnXjghigOzDv+n1/xpxv+SFAEmEp1Udk1+/JpMUrNWtZ/
        GLiT2XHhiAo7Jult9dDvlTeqnN4=
X-Google-Smtp-Source: APXvYqw9Zpanc0qkxUaUJ0E7ztrbKqI0u/4+pdUekJgBCWfEBXohR3qt6RDw+0BSDTRnVDIiQG6bhg==
X-Received: by 2002:a24:2101:: with SMTP id e1mr6379116ita.151.1553896918223;
        Fri, 29 Mar 2019 15:01:58 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.01.57
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:01:57 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/28] SUNRPC: Refactor rpc_restart_call/rpc_restart_call_prepare
Date:   Fri, 29 Mar 2019 17:59:22 -0400
Message-Id: <20190329215948.107328-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-2-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
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

