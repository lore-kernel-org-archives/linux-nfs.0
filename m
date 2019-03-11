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
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBB1FC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8AD9B20652
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="leTwuNzD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727059AbfCKBbJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 10 Mar 2019 21:31:09 -0400
Received: from mail-io1-f43.google.com ([209.85.166.43]:45312 "EHLO
        mail-io1-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727017AbfCKBbI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2019 21:31:08 -0400
Received: by mail-io1-f43.google.com with SMTP id x9so2596245iog.12
        for <linux-nfs@vger.kernel.org>; Sun, 10 Mar 2019 18:31:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9iBB59kGK8qfP8sIMKf6cSe+ibEf9BWC8paPRH7y7Bg=;
        b=leTwuNzDGhHdg1VA3s8KvSqoNrhaDJdkJRtl0XvMlUedvMc89oT3CiL39vgUJH7Tpc
         fwoEbQYHWlNqkb+6dcV5E8ND23m4NCGc0GdRZOmkLvt9zi7wLh3Fqfehcp7U9s9J0Swd
         ZHGj4jr1k8dqKK8dwVROT7fe5MhzPdfHhw8HeFPPl/tW/SBEjLXLhfkUFWMSzjDW0rVf
         bqEiJSOWKHghfjrxQbWEkSzdD5h2p1/Ag2FR0l4WwPCKUbFz4uzmHHqVCq+8/Bud2iv1
         wtZxYBYU+GTCeL8ODGdEuUGgiDlK4eFYcLoSLme70fExifEZ1JMRz1HNdKoNmkLFKOtX
         fRvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=9iBB59kGK8qfP8sIMKf6cSe+ibEf9BWC8paPRH7y7Bg=;
        b=HhM0w0lXhiDoZpu6w44FugxVJYbRDDMjGCk+R0xgMFCCzXYegjHeyA3/Uz239fAiTO
         ymNWvW8qWLxQC9/clH9kVxsMmdvR7qfqXmnVg13xffWS3ayyfM8MrCibZ2vP1kMjIsLT
         /8KiAWo+JnjC+C6uCK3RKMkfaU00YI81i0K2Iy/8Qj1JEUM+gc//ZGU5SqDtaxYG317v
         lqrqeOIT9e3cfHMmNH/kBogvPyT+yIbpF5VxSQnxlATZ+A71rr2lYP6Ji4t9N27wQSU9
         1LV6TXJp7peP6JuYUdfZKcTJrnffa2fjpbUnuJ0S/4YlPYmwQ8Mf54hupB64pVbiIa3f
         QPNg==
X-Gm-Message-State: APjAAAXk0KweoDJlxq2IDHSJfO0rQQg1h5LnArNK6sjTDXzDb2DP3oVl
        tD4XZ3/Z4yKwlbQSLsQy6kHO/ug=
X-Google-Smtp-Source: APXvYqx/ZFJOkJ952P3sCU9LnzWusYh4UCaQzP8LCyXMZwKb/kqs4L29MVj/MzYPp5n94AP0CI01hw==
X-Received: by 2002:a6b:6214:: with SMTP id f20mr14507666iog.213.1552267866959;
        Sun, 10 Mar 2019 18:31:06 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id p79sm7515011itb.7.2019.03.10.18.31.06
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Mar 2019 18:31:06 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] SUNRPC: Check whether the task was transmitted before rebind/reconnect
Date:   Sun, 10 Mar 2019 21:29:55 -0400
Message-Id: <20190311012957.3994-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190311012957.3994-2-trond.myklebust@hammerspace.com>
References: <20190311012957.3994-1-trond.myklebust@hammerspace.com>
 <20190311012957.3994-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Before initiating transport actions that require putting the task to sleep,
such as rebinding or reconnecting, we should check whether or not the task
was already transmitted.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 44 ++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 40 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9cf63e6339f4..67c955d8b21b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1811,6 +1811,24 @@ call_encode(struct rpc_task *task)
 		task->tk_action = call_connect;
 }
 
+/*
+ * Helpers to check if the task was already transmitted, and
+ * to take action when that is the case.
+ */
+static bool
+rpc_task_transmitted(struct rpc_task *task)
+{
+	return !test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate);
+}
+
+static void
+rpc_task_handle_transmitted(struct rpc_task *task)
+{
+	xprt_end_transmit(task);
+	task->tk_action = call_transmit_status;
+	call_transmit_status(task);
+}
+
 /*
  * 4.	Get the server port number if not yet set
  */
@@ -1819,6 +1837,11 @@ call_bind(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_rqstp->rq_xprt;
 
+	if (rpc_task_transmitted(task)) {
+		rpc_task_handle_transmitted(task);
+		return;
+	}
+
 	dprint_status(task);
 
 	task->tk_action = call_connect;
@@ -1837,6 +1860,11 @@ call_bind_status(struct rpc_task *task)
 {
 	int status = -EIO;
 
+	if (rpc_task_transmitted(task)) {
+		rpc_task_handle_transmitted(task);
+		return;
+	}
+
 	if (task->tk_status >= 0) {
 		dprint_status(task);
 		task->tk_status = 0;
@@ -1916,6 +1944,11 @@ call_connect(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_rqstp->rq_xprt;
 
+	if (rpc_task_transmitted(task)) {
+		rpc_task_handle_transmitted(task);
+		return;
+	}
+
 	dprintk("RPC: %5u call_connect xprt %p %s connected\n",
 			task->tk_pid, xprt,
 			(xprt_connected(xprt) ? "is" : "is not"));
@@ -1942,10 +1975,8 @@ call_connect_status(struct rpc_task *task)
 	struct rpc_clnt *clnt = task->tk_client;
 	int status = task->tk_status;
 
-	/* Check if the task was already transmitted */
-	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
-		xprt_end_transmit(task);
-		task->tk_action = call_transmit_status;
+	if (rpc_task_transmitted(task)) {
+		rpc_task_handle_transmitted(task);
 		return;
 	}
 
@@ -2001,6 +2032,11 @@ call_connect_status(struct rpc_task *task)
 static void
 call_transmit(struct rpc_task *task)
 {
+	if (rpc_task_transmitted(task)) {
+		rpc_task_handle_transmitted(task);
+		return;
+	}
+
 	dprint_status(task);
 
 	task->tk_action = call_transmit_status;
-- 
2.20.1

