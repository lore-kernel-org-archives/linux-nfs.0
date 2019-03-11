Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EA10C10F03
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6ABDE20652
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gRyf1XJj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726901AbfCKBbH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 10 Mar 2019 21:31:07 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:34714 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727017AbfCKBbH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2019 21:31:07 -0400
Received: by mail-io1-f67.google.com with SMTP id n11so1537819ioh.1
        for <linux-nfs@vger.kernel.org>; Sun, 10 Mar 2019 18:31:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sTQstrRQpEwoll4XVAuITGwDtJFVfhFLj4gsmO2N23Q=;
        b=gRyf1XJjTOvctGdimQWcGnj2RGyj/r48JlA5bjz+JoFJT7TlraGMz9wVFRe0r0Q0dd
         K21Jb7qFvxH3c0XVCCFmKV5DMbO/261wyp520AQIZmScpmknO7BgemqM/u8lm2JVR/pL
         3BrWIe6ZWcxYSzkGvFfsJZq/sWXzlSDbk2XbslqcTbxJ/r561TjGR29AiAp9/v+hl5ua
         g7WNLPksEy2JCYr74rk+DDXhjHMQFcW35zFuHQ0IGIuI7dVGLXvdkQERl969BgC8LHf0
         lsQsG0HxHuo1GIWnX15oBzhG2Gu6NJmi8zEzOXWruSMPp1zOodXhbUqHwfcy/9qL56jK
         OnxQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=sTQstrRQpEwoll4XVAuITGwDtJFVfhFLj4gsmO2N23Q=;
        b=ZmtQqCsxbpZO9lvc/KjVPYLqCoW0OqLtKEtDYLQrJ6gw5+pWyYf0HJooloyp6NvArv
         g7NBcnNmoIpy9KHjH9Ee7yZNoD8KZ6vOqv0QjCfafri4A5y/h+7gbqD/7z0lpuFZKDqt
         MY8TXyN5AyakzI1BXa33sa64DxW/ksr+c1YZbwmySGO3P8W1XXM3HwKOJ3/7ZujvFdIJ
         havtTit43vrmQY4oRB+VrJJWpZ0K+FU9jigVVUsojtbyiBQe3FiCue1+Kwl+ZtSKP18w
         fOUxy9ImZt9Y5u7I1UKVu1vbNH3aOyQzIdBSZfH/r0kPFukbAXjrBDzA5+Gh5dE6YcLV
         CyCw==
X-Gm-Message-State: APjAAAXZq76/BH6f+d6+bQaz8EsqGt+nWGWYaWHNHwtzJIshtBfnipUX
        77McbVuD12IUZOZYjHvClvbPMgo=
X-Google-Smtp-Source: APXvYqxny1oRCjzF92BYQnF7FUxJVm4p6ClpwN0geyEadx2IHv3mAsgiOlv3dWOoykxy+jolXHfvCA==
X-Received: by 2002:a6b:90e:: with SMTP id t14mr15437789ioi.19.1552267866162;
        Sun, 10 Mar 2019 18:31:06 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id p79sm7515011itb.7.2019.03.10.18.31.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Mar 2019 18:31:05 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] SUNRPC: Remove redundant calls to RPC_IS_QUEUED()
Date:   Sun, 10 Mar 2019 21:29:54 -0400
Message-Id: <20190311012957.3994-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190311012957.3994-1-trond.myklebust@hammerspace.com>
References: <20190311012957.3994-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The RPC task wakeup calls all check for RPC_IS_QUEUED() before taking any
locks. In addition, rpc_exit() already calls rpc_wake_up_queued_task().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c  | 3 ---
 net/sunrpc/sched.c | 3 +--
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a0e7322fc171..9cf63e6339f4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -833,9 +833,6 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 		if (!(rovr->tk_flags & RPC_TASK_KILLED)) {
 			rovr->tk_flags |= RPC_TASK_KILLED;
 			rpc_exit(rovr, -EIO);
-			if (RPC_IS_QUEUED(rovr))
-				rpc_wake_up_queued_task(rovr->tk_waitqueue,
-							rovr);
 		}
 	}
 	spin_unlock(&clnt->cl_lock);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index f21557213a43..28956c70100a 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -785,8 +785,7 @@ void rpc_exit(struct rpc_task *task, int status)
 {
 	task->tk_status = status;
 	task->tk_action = rpc_exit_task;
-	if (RPC_IS_QUEUED(task))
-		rpc_wake_up_queued_task(task->tk_waitqueue, task);
+	rpc_wake_up_queued_task(task->tk_waitqueue, task);
 }
 EXPORT_SYMBOL_GPL(rpc_exit);
 
-- 
2.20.1

