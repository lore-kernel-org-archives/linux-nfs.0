Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC8E4C4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8C16821855
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eT+lEwtl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726216AbfC1U4N (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:13 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:50364 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726224AbfC1U4N (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:13 -0400
Received: by mail-it1-f194.google.com with SMTP id m137so490032ita.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ktOAA/pUjssSdbRV9doPBG+n+qDrux7xMAI8mmDNi3Y=;
        b=eT+lEwtl0KeKviUNzcGbIJvHVwNwkrxIjGPpMOwmLNwdwmFByclpZOfvy/Oxqi4vLP
         oUitiDngqL2a8CvTiHBVEmOcH9tgNdlX2r9s/htpt6JUYoo/V71Ge5faP4o0EqsaHCYi
         ucuZmOM/AEqQxGe7lu31cOeeVJ8wthN/aQPDV7nMoohTNVSUIPrEIXQS1sKHXw3LfROn
         L0Wwc5Ia8ayxle60RftLNANLoP8dxa37AD+iKZUoSJ1xTfuTMnmgLGf6CAXbXgGTwUOt
         x864wpxGpcoFkDcRI7uQsiaLwAWGwX22fTNlllcgJz4LeBfilhzrXDeNPZH1DMEZLXff
         6AcA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ktOAA/pUjssSdbRV9doPBG+n+qDrux7xMAI8mmDNi3Y=;
        b=ICLKTpmoqFnAV8nrxJdj+2fcjh0A0Id/td+itNMLFKIAiJ6wfbuvOYuFXim/z9KCD+
         Xp69X92baxUwFkcaNGvyU0Pp6o9rmEm194CdmyB958dXmEpM2UILu9RbFsy1xuNC9CH8
         sVoJZ1wZEA7u9l+emNz3RhbuPxnf3mMjgCpFBKyw2ZFVRJEap2gaCc+yE2WJLp1bCQHq
         yUjHJ3Ya8bpky7Sd6ifhPN0FjNSvXQLJpcxIGnYvdD19CVscXUL0N/TxdNg8er9HRGGA
         NELLBW3fVqMI0RuVJIWbjIPTWfQemDzisZjV1rrpo6LleXezIDOvCwzdS35XsOhZ9I9t
         TXMw==
X-Gm-Message-State: APjAAAWIkx4Kb/aqrb5lX1TGouJVPKlYMUeDJUSl+CiNNlRyFEsned9v
        fn5fEipd9W6Y0Jm6j+NX4xVCWrg=
X-Google-Smtp-Source: APXvYqxr9eHMDxOdXksW8TQxNm+A/zVbF6a9sEk/sgXMNL3cl/iHCQWfHpAhlOGxhCsGETVeZF3iFA==
X-Received: by 2002:a02:c04a:: with SMTP id u10mr8937695jam.59.1553806572256;
        Thu, 28 Mar 2019 13:56:12 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:11 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 05/25] SUNRPC: Remove unused argument 'action' from rpc_sleep_on_priority()
Date:   Thu, 28 Mar 2019 16:52:19 -0400
Message-Id: <20190328205239.29674-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-5-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
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

