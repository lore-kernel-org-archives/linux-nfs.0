Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F8FBC10F06
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CB0FE21855
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kJLSpMZk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726289AbfC1U4N (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:13 -0400
Received: from mail-it1-f173.google.com ([209.85.166.173]:55644 "EHLO
        mail-it1-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726307AbfC1U4M (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:12 -0400
Received: by mail-it1-f173.google.com with SMTP id z126so436179itd.5
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=itCHmiCshLTM2+BHulEM3xFyqyjflEgWdjjcXgdFrpU=;
        b=kJLSpMZkGFzFptzBS9AqvPLVAPxcxL8pCoX0PwSdPQCyef6Cq+na5EDPgBFJoX9paP
         Gv/CQwFLLFF8R99p5EL7k2i5yOHXgDJJ2hCpPzkOWCI6Qy1/V2Bwo2Y6Q1zlKN/PaoQC
         Jp+plN9t/GWicL01dQ2F2SemBpSfvkpwBYx9e6A0dg2rtfO/O6Js8lQ9Xa3chbBpaAML
         ybU8E5tCTxTRqC0wbJA8tXHdSTA8lYP+e1R0iU1lKRIIs2mTeKGVbhEyzNFSI3s+P9vz
         SaqX1vvMqab2xpZ+TwunRhJ4rN4ba729r8K0KHO7yjRtsgSBS7m/L7Y0Tj1TeHRnoT56
         XlIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=itCHmiCshLTM2+BHulEM3xFyqyjflEgWdjjcXgdFrpU=;
        b=cVSh1LAs8mWSKfc8phDb4CaL0uSFzChUvULMjsefZD+oqFg/Pj7vgxqpIhAAv7R/I5
         JxIfdlYQ3BjWCoB7wFE6mnHEPLibz1u9wpA9sVXM/5DVgG54IU6XTL98Eypk0y08vdH6
         UU1heBEjCva0WmD0QL31o5kwXVbGc/dF1FRExTUgtA14bW52u55tn9wA4ao7YKIVfHaO
         VrxYCLrput5h1uqo6jYRUwvINp4tVMeAbPpPK+B+I53ltVV92PvXyWdaL7UHrWY3up23
         eMCaq620RAWCrDsW0fUV+xmgxYRw7AT0UCDiIU4rzw5es76gsSIl+Y38GngD/GUBmKj1
         nTCw==
X-Gm-Message-State: APjAAAWiUjqjQ0styr2EDuUDEMJ5P9und6IzYuKSJPbaAFpSZPxhy4Yx
        kRU66vIkBJN+c+nKSYSF9TEtmnM=
X-Google-Smtp-Source: APXvYqyYSnAabCVJG8NBDQPLukrb58csuLalvhyScMewzNzMLhlI6nbKiT1XCl+oRUdVoHJfjlKY5A==
X-Received: by 2002:a02:b097:: with SMTP id v23mr33623578jah.42.1553806571151;
        Thu, 28 Mar 2019 13:56:11 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.10
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:10 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 04/25] SUNRPC: Refactor rpc_sleep_on()
Date:   Thu, 28 Mar 2019 16:52:18 -0400
Message-Id: <20190328205239.29674-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-4-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
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

