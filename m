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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68FF4C10F0A
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 34A7B2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J0tc/tSn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730267AbfC2WCC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:02 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:37016 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730144AbfC2WCB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:01 -0400
Received: by mail-it1-f195.google.com with SMTP id u65so6272019itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ktOAA/pUjssSdbRV9doPBG+n+qDrux7xMAI8mmDNi3Y=;
        b=J0tc/tSnrkWDiMwzt0U5AhA6fBOJcs0RB94wB1T61tN7ANuA/CPIdPzC8Uuj2sGzP2
         /ApewWPivLd3Ncph9FQB9MfHboQvVJ2t5/jZnx033m7xZR/csSXX/Jr3L38DpSug5QDH
         R703Uw/yLMzkmrqq1Q6jCRRo2BNk4iOVbmv2wX3Kc+UOxtB197e4WaQ2gQ3KPLCwkTb/
         7OIrkdA/bG87vsbdZL7oqjISkyfYEA7gPHUGkdbl5Pxso6059M4RdUuaNB752VQ+l+Lz
         0kiPYghmL8kvpjsV4/9t5sU0pXD/o2s4M2GyFhlZSSfdLy0Z4nvRgPlhC9z0+AKy8+b2
         wlpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ktOAA/pUjssSdbRV9doPBG+n+qDrux7xMAI8mmDNi3Y=;
        b=OF76khHcEz50V4kyRVnGOMJrk2hn4J06AuCnJPHHHsWdHzqBlwlNAlkzx2U4Q/wVAA
         94B24PRQ1q92RyPIYmVgB41N6BV2FejZiqwgfg7fjEYNoTJSdyXzjOOPoJBtn70nQ/FR
         vyAmXwKcCuTsNB0jsQslMmjiI05iQG3AEdQoLbJy16WCphUdK9i4Pul+5jhjpdOHDzgS
         NxxnBM5vhRyRxtXf+RVaABVnbMOO/eNeTSJaI0tIc1Ewql+lUb/RIVc1iMMZGSJNW5Lu
         Wjl3p0rX1Vn1I8/qq2HKRU+sCewjxWPQYr2kTSgiV0C3LkETcACXC5INIy1t+8Ab7GcQ
         wv3g==
X-Gm-Message-State: APjAAAWrkLcZ3C0rpP0NQaQizUfH7OVNf5YqrQ4DKjpv4GkpSuybGU/e
        cl8tgrfXRBIujNHCc6i7lNRzwg0=
X-Google-Smtp-Source: APXvYqwvkUkYVnj4SvkDil12e/vZ/B+Lk8n5Rn2PH2Biv0bQhB39y5lwfWzyLggoUX6vHpLPr0Hw8g==
X-Received: by 2002:a24:dc41:: with SMTP id q62mr6571803itg.94.1553896920576;
        Fri, 29 Mar 2019 15:02:00 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.01.59
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:00 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/28] SUNRPC: Remove unused argument 'action' from rpc_sleep_on_priority()
Date:   Fri, 29 Mar 2019 17:59:25 -0400
Message-Id: <20190329215948.107328-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-5-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
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

