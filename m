Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CD39C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 377BB20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n4JMRmBI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726335AbfDGSB0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:26 -0400
Received: from mail-it1-f174.google.com ([209.85.166.174]:38426 "EHLO
        mail-it1-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726388AbfDGSB0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:26 -0400
Received: by mail-it1-f174.google.com with SMTP id f22so17363723ita.3
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=itCHmiCshLTM2+BHulEM3xFyqyjflEgWdjjcXgdFrpU=;
        b=n4JMRmBIcd+VKnG5ZJM6BwCQbh9o94et3Uyf6qH2VeddB90cXSXQOKO+uR9u5IvQMl
         qbfXXIgxndDjckI416yViImUZUdW77IwJpfWQMOP5kPTiFGkNg/RrKNM8uxpRXbva3Ca
         v6MIz8gDirzJngp4PFrUTMau1/vG5mw6dtJRliTATqys4O8B1OAAOeshhaunVxZTqKvO
         xPRD8dhYGIg2CILWaWMkIAbt6m7Mw+Eu5OMmIvrrN+lK1A3kHn8sxX4g7hi6uFIuc8Fl
         BbaDRtcYfB3TSh9FAKdPlVT/7nh6ne5CK35z3QYEdwgW1KFy4sy1MHNvhifFodqYWR4C
         4/Rg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=itCHmiCshLTM2+BHulEM3xFyqyjflEgWdjjcXgdFrpU=;
        b=qybb9YmnmZh4rU3R2MCuQQLO6HH12D53QRZ++ucJa1oQtoYdtXUskA5ubkoB+CTxLG
         aWigrWHDbI7/QE3dPwjK1nTp+gLcQTMqdK+kQNHx7y3eBSQERJLS4Sp1DuHYnG3DPOHr
         A4mzCLN5H1g3fd8mZdos8MbeK8m9sW9VlQY56ua5XOUf87EHWyrJEvaJKuUoWJoGru3h
         XYbCsE/lKX1JsyUD7sjdQ4KIKnId6RhH3dq8pDGKpYm5gDfOpLycgHNYiPv1qeBLQudK
         88RHxBrRsTMi05qdz4iurwtWeAKvLDfhL/9t5hv0AN18e7Ar1vSTf/hItUOAXY3ZCqSu
         yJ0g==
X-Gm-Message-State: APjAAAVuhc9EaSbIIn2U7nCgd+zt7Sc2wJT1unDQyugx0OgPmnG+RR57
        z3E0LEROJriuYhvjKVeVEl4wkeA=
X-Google-Smtp-Source: APXvYqy8o1h8kz14N0bl7kYEaOGpKuqJ8gxjzBOd8uHBYvcGeo9dt5kt2dFaJDuuTu8k3hEOnq+83Q==
X-Received: by 2002:a05:6638:26e:: with SMTP id x14mr18056261jaq.32.1554660084880;
        Sun, 07 Apr 2019 11:01:24 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:24 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 04/29] SUNRPC: Refactor rpc_sleep_on()
Date:   Sun,  7 Apr 2019 13:58:47 -0400
Message-Id: <20190407175912.23528-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-4-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

rpc_sleep_on() does not need to set the task->tk_callback under the
queue lock, so move that out.
Also refactor the check for whether the task is active.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/sched.c | 40 ++++++++++++++++++++++++----------------
 1 file changed, 24 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 3d6cb91ba598..8e96a841dd11 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -362,7 +362,6 @@ static void rpc_make_runnable(struct workqueue_struct *wq,
  */
 static void __rpc_sleep_on_priority(struct rpc_wait_queue *q,
 		struct rpc_task *task,
-		rpc_action action,
 		unsigned char queue_priority)
 {
 	dprintk("RPC: %5u sleep_on(queue \"%s\" time %lu)\n",
@@ -372,27 +371,39 @@ static void __rpc_sleep_on_priority(struct rpc_wait_queue *q,
 
 	__rpc_add_wait_queue(q, task, queue_priority);
 
-	WARN_ON_ONCE(task->tk_callback != NULL);
-	task->tk_callback = action;
 	__rpc_add_timer(q, task);
 }
 
-void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
-				rpc_action action)
+static void rpc_set_tk_callback(struct rpc_task *task, rpc_action action)
+{
+	if (action && !WARN_ON_ONCE(task->tk_callback != NULL))
+		task->tk_callback = action;
+}
+
+static bool rpc_sleep_check_activated(struct rpc_task *task)
 {
 	/* We shouldn't ever put an inactive task to sleep */
-	WARN_ON_ONCE(!RPC_IS_ACTIVATED(task));
-	if (!RPC_IS_ACTIVATED(task)) {
+	if (WARN_ON_ONCE(!RPC_IS_ACTIVATED(task))) {
 		task->tk_status = -EIO;
 		rpc_put_task_async(task);
-		return;
+		return false;
 	}
+	return true;
+}
+
+void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
+				rpc_action action)
+{
+	if (!rpc_sleep_check_activated(task))
+		return;
+
+	rpc_set_tk_callback(task, action);
 
 	/*
 	 * Protect the queue operations.
 	 */
 	spin_lock_bh(&q->lock);
-	__rpc_sleep_on_priority(q, task, action, task->tk_priority);
+	__rpc_sleep_on_priority(q, task, task->tk_priority);
 	spin_unlock_bh(&q->lock);
 }
 EXPORT_SYMBOL_GPL(rpc_sleep_on);
@@ -400,19 +411,16 @@ EXPORT_SYMBOL_GPL(rpc_sleep_on);
 void rpc_sleep_on_priority(struct rpc_wait_queue *q, struct rpc_task *task,
 		rpc_action action, int priority)
 {
-	/* We shouldn't ever put an inactive task to sleep */
-	WARN_ON_ONCE(!RPC_IS_ACTIVATED(task));
-	if (!RPC_IS_ACTIVATED(task)) {
-		task->tk_status = -EIO;
-		rpc_put_task_async(task);
+	if (!rpc_sleep_check_activated(task))
 		return;
-	}
+
+	rpc_set_tk_callback(task, action);
 
 	/*
 	 * Protect the queue operations.
 	 */
 	spin_lock_bh(&q->lock);
-	__rpc_sleep_on_priority(q, task, action, priority - RPC_PRIORITY_LOW);
+	__rpc_sleep_on_priority(q, task, priority - RPC_PRIORITY_LOW);
 	spin_unlock_bh(&q->lock);
 }
 EXPORT_SYMBOL_GPL(rpc_sleep_on_priority);
-- 
2.20.1

