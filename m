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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10DD3C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DB4C420896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BOGyl3+m"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726417AbfDGSBa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:30 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:40745 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726409AbfDGSB3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:29 -0400
Received: by mail-io1-f66.google.com with SMTP id d201so9088218iof.7
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=byabvxxmICV7URMFFD2mJ+S6tFfR9tedVIX8kLsaKcA=;
        b=BOGyl3+mURrN2kjUOMu03jFwhILxfx3xlRX+B74Qw7QQnr1lrlYmDYSM69HXbuoHBc
         2qiCFd/Gq9FJA+W1zUmoJiDOvp8ISmQ7iL10Oqd+TNmfxdWBmPyKl0WWTW2azhmidxRH
         deFf8NQb+e5h1Qo9UXVpKD+mUvvKAW4xyQf8+PDyTRw5CSw2lvTm59qtaOtxDHqUQQB6
         3+DkEc1PHwOtSvTkmQjhSkoDP/1soR/IxgoCfeAJaswiHDIDpntkfXdC9+lT2c/XDE5f
         bt4mo5LSbwMS/NMNGO5HHALlfwbja7eqEot6Ukxtaoo2g4B3ty5zLUGeI5OmT72os12a
         kPdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=byabvxxmICV7URMFFD2mJ+S6tFfR9tedVIX8kLsaKcA=;
        b=em0gYN52oZz848ToW64FjkaopKh2qE/MksatjGzyfnm058Z8kxZ0vn1zdGjrkel+um
         qgtkBQtQvCei+08KwZQEDLBtX9MgzA0xbLaKUMaSqDrPGd5gXKYEZXlyXmNr/6knKL9I
         EOWeoAFq3HPw+Tkc9mkY+e7IrnsUDEl8ee9usIyp41L/IDxRHQU/qm/BADrrZAoCbljj
         ECovMCSrz9OczrhlzrdnnrzdovYhxUxieIudGAARfdYaQ73M5/vJncbeexT/PEqT/TXr
         KHnZSxX/bWLJA7tY9RGTN4WrOEWN1hbrKJQ9eAUb7uuh+fBX6UvJ3QVDvv9HXSybAsHv
         HtHQ==
X-Gm-Message-State: APjAAAXzt5NFUlbtU1BijKfYwi/H3nwTKFWELMif6KrR1wDFq5/t21n6
        RIXMvd5iV8zCj7ZlhIYZLNNoUJs=
X-Google-Smtp-Source: APXvYqwJpNYpTMDIyVC46mzvWfpsHjmIJloWcm/x5M3S6wIQa3NnLhm/0Iy1jTBHuPT0FN7sBH2c+w==
X-Received: by 2002:a6b:3f86:: with SMTP id m128mr6237882ioa.275.1554660088541;
        Sun, 07 Apr 2019 11:01:28 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:27 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 08/29] SUNRPC: Simplify queue timeouts using timer_reduce()
Date:   Sun,  7 Apr 2019 13:58:51 -0400
Message-Id: <20190407175912.23528-9-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-8-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Simplify the setting of queue timeouts by using the timer_reduce()
function.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h | 1 -
 net/sunrpc/sched.c           | 6 ++----
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 0b7d333f624e..c41f5f498b3b 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -183,7 +183,6 @@ struct rpc_task_setup {
 struct rpc_timer {
 	struct timer_list timer;
 	struct list_head list;
-	unsigned long expires;
 };
 
 /*
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 40944c34a9e4..301e0f7f1dc9 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -92,8 +92,7 @@ __rpc_disable_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 static void
 rpc_set_queue_timer(struct rpc_wait_queue *queue, unsigned long expires)
 {
-	queue->timer_list.expires = expires;
-	mod_timer(&queue->timer_list.timer, expires);
+	timer_reduce(&queue->timer_list.timer, expires);
 }
 
 /*
@@ -107,8 +106,7 @@ __rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task,
 		task->tk_pid, jiffies_to_msecs(timeout - jiffies));
 
 	task->tk_timeout = timeout;
-	if (list_empty(&queue->timer_list.list) || time_before(timeout, queue->timer_list.expires))
-		rpc_set_queue_timer(queue, timeout);
+	rpc_set_queue_timer(queue, timeout);
 	list_add(&task->u.tk_wait.timer_list, &queue->timer_list.list);
 }
 
-- 
2.20.1

