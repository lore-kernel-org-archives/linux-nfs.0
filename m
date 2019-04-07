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
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB4C1C282E0
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AD81220896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ulgWRDpC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726403AbfDGSB1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:27 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:50689 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726388AbfDGSB0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:26 -0400
Received: by mail-it1-f193.google.com with SMTP id q14so17276997itk.0
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ktOAA/pUjssSdbRV9doPBG+n+qDrux7xMAI8mmDNi3Y=;
        b=ulgWRDpCXafYjlWCB3Wv184fHl/fbO0sc/nUeusksPFUSrQSO27DKEAV0oHz36ETn1
         rl73oKbVgOAPv9WMXuCYxQhl5zw6NFpQwBCc3BaDYuMWwKACq+CClReAyAOGZZB4nj7R
         pY1nWkqJj5kEQUUHk+l5O6jJRT2jZIkIHqh1jbVVca/71JJfZ0YoqDk3wVavnkGyVg8e
         8Yej5gM+wxlnLny8j+jbeIS1LWaGREfxcvQLxE8N+PF+1SdFW6vYz50W/imQfm16m56A
         1VSJCgYp/cBAeTvtJt6Nt8gJFeKdJIC1QscnEZYa7k0FrGBakFboRe5s1uneHn/C3IpS
         NQ9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ktOAA/pUjssSdbRV9doPBG+n+qDrux7xMAI8mmDNi3Y=;
        b=DeJKBiPMFWNCecJYLrE2peH738PP9zTXu9Y69ZJhBQ8SunVy8gneQWWsHx7Mq9PzOI
         gc2fJWgxJhoRz5P70YqdGFEmNYcYmVqQVfN9llZZ5FUFpku13/N4DK6CcSE+TEVESQkw
         A+ZV16tntD/chM1Jp2HqKl+TXMoQ0gCogiPOp6cf/gFgbaIdc23K78MfXgOojg1vJR3q
         dZjYs1n1jaYyDk0xbZmYyLH4+eNuWXzmRd5et6B/DIINgK63Bd9gESohIrjLPDJnXvQD
         GGO5D2PYMuC0su9l8N0/VM42Sg7s6M+6iNgtBqTqVK1x2y4YbDSM05ZeZK/qed2k1Chz
         JoIg==
X-Gm-Message-State: APjAAAW+wtBIolHvlsss7F9oX3egQd5eFOQMt4X0aD+fTWsYYKOeiPSd
        iU/dRuF4RNEjC88I5UQOmgxsji4=
X-Google-Smtp-Source: APXvYqzYEcEVJFPwFc6CLwERNXqs2MQ2+jYBqw44NxDEq+13FvlYJv9uRD+aH7QsOW7Vd214kK+0Sg==
X-Received: by 2002:a24:5a8d:: with SMTP id v135mr18294785ita.87.1554660085723;
        Sun, 07 Apr 2019 11:01:25 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:25 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 05/29] SUNRPC: Remove unused argument 'action' from rpc_sleep_on_priority()
Date:   Sun,  7 Apr 2019 13:58:48 -0400
Message-Id: <20190407175912.23528-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-5-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

None of the callers set the 'action' argument, so let's just remove it.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c            | 2 +-
 include/linux/sunrpc/sched.h | 1 -
 net/sunrpc/sched.c           | 7 +++----
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 741ff8c9c6ed..222eccd8a715 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1008,7 +1008,7 @@ int nfs4_setup_sequence(struct nfs_client *client,
 out_sleep:
 	if (args->sa_privileged)
 		rpc_sleep_on_priority(&tbl->slot_tbl_waitq, task,
-				NULL, RPC_PRIORITY_PRIVILEGED);
+				RPC_PRIORITY_PRIVILEGED);
 	else
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 	spin_unlock(&tbl->slot_tbl_lock);
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 852ca0f2c56c..541b89d41afb 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -231,7 +231,6 @@ void		rpc_sleep_on(struct rpc_wait_queue *, struct rpc_task *,
 					rpc_action action);
 void		rpc_sleep_on_priority(struct rpc_wait_queue *,
 					struct rpc_task *,
-					rpc_action action,
 					int priority);
 void rpc_wake_up_queued_task_on_wq(struct workqueue_struct *wq,
 		struct rpc_wait_queue *queue,
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 8e96a841dd11..04170c08b2cf 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -409,18 +409,17 @@ void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 EXPORT_SYMBOL_GPL(rpc_sleep_on);
 
 void rpc_sleep_on_priority(struct rpc_wait_queue *q, struct rpc_task *task,
-		rpc_action action, int priority)
+		int priority)
 {
 	if (!rpc_sleep_check_activated(task))
 		return;
 
-	rpc_set_tk_callback(task, action);
-
+	priority -= RPC_PRIORITY_LOW;
 	/*
 	 * Protect the queue operations.
 	 */
 	spin_lock_bh(&q->lock);
-	__rpc_sleep_on_priority(q, task, priority - RPC_PRIORITY_LOW);
+	__rpc_sleep_on_priority(q, task, priority);
 	spin_unlock_bh(&q->lock);
 }
 EXPORT_SYMBOL_GPL(rpc_sleep_on_priority);
-- 
2.20.1

