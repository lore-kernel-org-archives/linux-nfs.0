Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86B76C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 541462184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XsW+wnrZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730241AbfC2WCB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:01 -0400
Received: from mail-it1-f181.google.com ([209.85.166.181]:51106 "EHLO
        mail-it1-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730137AbfC2WCB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:01 -0400
Received: by mail-it1-f181.google.com with SMTP id m137so6224378ita.0
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=itCHmiCshLTM2+BHulEM3xFyqyjflEgWdjjcXgdFrpU=;
        b=XsW+wnrZDIseJtJ3izG8raPm0zqq5PJt3SESDkaKsxe1lTaPI90baqLOVMpHSAVfVR
         vMoUZIN36spv2joptMZ8VdN+q4p92sWWWmRiLiEYSJt8i4GvZNOw1wJASXOP+BM0rVB5
         I4BKWTzbd2PlW6DraWlhZSyL2Xz/D1us7wTy/fHCEnThiMZk7NhEeQt3Ol11AMDw70zY
         XfJSQJPuJfUe0ZABPKNs0N7PSl6aWQxJqKVCJ7hioHDG9dkaItFaBGAauLeKyeNZA80K
         DqJ40jyW6hjoaRzcoD9NFCjjMDcOgNHrEHv/iHeoYr+OcUR6uusnt4wlUFF30fVOzRKj
         jEDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=itCHmiCshLTM2+BHulEM3xFyqyjflEgWdjjcXgdFrpU=;
        b=S0S+3Lg/5Ach7QLFhJ6CzWCvx/ggSpdMkVGF76JJYZgawgfcuYRdxBYatgGAMniLwA
         orxI2jIcIY9jmOAYbC05Z9Ze5tUARXXut8ffnMnHfobtfcJcif/OEA7SmdLAlS7pDYNv
         sybYCJ2L/Kp50y477z83gIUnMnanRJcMskKWY9JxUDUXiGCl+fsYIMvEYYx9qCrJPy+Q
         /J90yIdIXSuvQ7Kd301FD7AAbfe1vAnTREUTaUW1cBOrzDoFFUMrfTYwBZWXkf/w1HFE
         /0sKTc/11TfPl2jvd0fqDHMR/ViNlaEcUXGHEys6BnWaLzplm7Ql4cc7ayqzahkR8m18
         sglA==
X-Gm-Message-State: APjAAAUpwyIqrRlnshETLladhtFydiTCp+kyi81gdF117KnK1m7Fj575
        bdgOEF2iATlXbWBArvmeoJ0MTV8=
X-Google-Smtp-Source: APXvYqz65mhCAkDi3i2p/cWpLF0RN+g0a0bDNRHhGoimuMgsnZTnWQZVTlPmPwgj6MU50Tj/1tMcVA==
X-Received: by 2002:a24:68cb:: with SMTP id v194mr5620563itb.145.1553896919819;
        Fri, 29 Mar 2019 15:01:59 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.01.59
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:01:59 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/28] SUNRPC: Refactor rpc_sleep_on()
Date:   Fri, 29 Mar 2019 17:59:24 -0400
Message-Id: <20190329215948.107328-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-4-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
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

