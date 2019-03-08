Return-Path: <SRS0=3/9x=RL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FDE3C10F03
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 00:47:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E5AC620840
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 00:47:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qnB18tEi"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726227AbfCHArh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 19:47:37 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:35717 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726248AbfCHArh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 19:47:37 -0500
Received: by mail-io1-f67.google.com with SMTP id x4so15354907ion.2
        for <linux-nfs@vger.kernel.org>; Thu, 07 Mar 2019 16:47:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/9HFUDewElV+nsL8NSHYFpzTyBHWJzEh4IYU2sa8OnQ=;
        b=qnB18tEinedVZzPvpf5GY/DWa6jCCuaS/B+kiVqnxDjNvZdesB54582zzBp2mT9xLj
         WMo6+YA1yRsWkVk6RHYeEyNLRuE5/IStYEI3cvn8AGgRjSTQG9M6Py1AJhJJnn6cK6aS
         wNUAPfmxzXk1q46By/MyL+voTSl8pm9fCj6qU3j6K3fm013g+SDo3m/039E8Hg9UR45D
         EH4UNmdF5dEni8PPi0KS2xGm+yHo8K+W0Wm/OoVyPK7HLNKsn3Q08qqvPRuonztF1oQa
         u+iGdKAWn1QbckteP8mGYTvgIrLKad0gXf1pS6yKbQ7IdnPR2R3R9fMVyS9LV6Ypv1gT
         SyTg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=/9HFUDewElV+nsL8NSHYFpzTyBHWJzEh4IYU2sa8OnQ=;
        b=qpAeYl8IF+YZ6SCFy5K25U/pbtdQ69aWAunJgW1ZqnQveDAUP4GIzQ+ffvZdP5qta7
         mAbDv21oieJTO5vFJ6jt9aZBHemWgQh5q4td1Gu8tnqJ3Ox9sd0lj3sVIHtkhXrNwMnB
         0UWdhKGZEBtqnJdbXfXAggeMLDb/zIWatZjoy9orONvSAgjWnBSo4TeYvsG3SLpc4vKY
         HDMbPxDS4wLjputDAY6hrH5vg1zDuAoprz5zSOK0ZgNBkkmSLSmUtsn2rJlP9fyDYI7m
         t/sI/uJczkWPF27GGU/ghBqI4A9J2ctfrKzgQUcItby3d3aJrLg4PWBpOmvm/06RQ9iV
         HOmw==
X-Gm-Message-State: APjAAAUKawtNqZxn/KpAXHa6E72Mvpuzl7oZ2s9OfWFbQ9NaKbhp0nM3
        /QjO9E1lwEV7NtyY+bsOEXFFIMY=
X-Google-Smtp-Source: APXvYqx81bBayAHLeQzNfDAw+A5VR6+FA3BLvcFd+Ods+WERqMwQQK8gMdyAuj1GgpI6sYks3x34ew==
X-Received: by 2002:a6b:7311:: with SMTP id e17mr8423102ioh.91.1552006055205;
        Thu, 07 Mar 2019 16:47:35 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r65sm3278223itb.19.2019.03.07.16.47.34
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 16:47:34 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/3] SUNRPC: Fix up RPC back channel transmission
Date:   Thu,  7 Mar 2019 19:46:22 -0500
Message-Id: <20190308004623.10618-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190308004623.10618-1-trond.myklebust@hammerspace.com>
References: <20190308004623.10618-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Now that transmissions happen through a queue, we require the RPC tasks
to handle error conditions that may have been set while they were
sleeping. The back channel does not currently do this, but assumes
that any error condition happens during its own call to xprt_transmit().

The solution is to ensure that the back channel splits out the
error handling just like the forward channel does.

Fixes: 89f90fe1ad8b ("SUNRPC: Allow calls to xprt_transmit() to drain...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 61 +++++++++++++++++++++++++----------------------
 1 file changed, 33 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7ab4da342ab5..b9558e10c6c1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -66,9 +66,6 @@ static void	call_decode(struct rpc_task *task);
 static void	call_bind(struct rpc_task *task);
 static void	call_bind_status(struct rpc_task *task);
 static void	call_transmit(struct rpc_task *task);
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-static void	call_bc_transmit(struct rpc_task *task);
-#endif /* CONFIG_SUNRPC_BACKCHANNEL */
 static void	call_status(struct rpc_task *task);
 static void	call_transmit_status(struct rpc_task *task);
 static void	call_refresh(struct rpc_task *task);
@@ -1133,6 +1130,8 @@ rpc_call_async(struct rpc_clnt *clnt, const struct rpc_message *msg, int flags,
 EXPORT_SYMBOL_GPL(rpc_call_async);
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
+static void call_bc_encode(struct rpc_task *task);
+
 /**
  * rpc_run_bc_task - Allocate a new RPC task for backchannel use, then run
  * rpc_execute against it
@@ -1154,7 +1153,7 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	task = rpc_new_task(&task_setup_data);
 	xprt_init_bc_request(req, task);
 
-	task->tk_action = call_bc_transmit;
+	task->tk_action = call_bc_encode;
 	atomic_inc(&task->tk_count);
 	WARN_ON_ONCE(atomic_read(&task->tk_count) != 2);
 	rpc_execute(task);
@@ -2085,6 +2084,16 @@ call_transmit_status(struct rpc_task *task)
 }
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
+static void call_bc_transmit(struct rpc_task *task);
+static void call_bc_transmit_status(struct rpc_task *task);
+
+static void
+call_bc_encode(struct rpc_task *task)
+{
+	xprt_request_enqueue_transmit(task);
+	task->tk_action = call_bc_transmit;
+}
+
 /*
  * 5b.	Send the backchannel RPC reply.  On error, drop the reply.  In
  * addition, disconnect on connectivity errors.
@@ -2092,26 +2101,23 @@ call_transmit_status(struct rpc_task *task)
 static void
 call_bc_transmit(struct rpc_task *task)
 {
-	struct rpc_rqst *req = task->tk_rqstp;
-
-	if (rpc_task_need_encode(task))
-		xprt_request_enqueue_transmit(task);
-	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
-		goto out_wakeup;
-
-	if (!xprt_prepare_transmit(task))
-		goto out_retry;
-
-	if (task->tk_status < 0) {
-		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
-			"error: %d\n", task->tk_status);
-		goto out_done;
+	task->tk_action = call_bc_transmit_status;
+	if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
+		if (!xprt_prepare_transmit(task))
+			return;
+		task->tk_status = 0;
+		xprt_transmit(task);
 	}
+	xprt_end_transmit(task);
+}
 
-	xprt_transmit(task);
+static void
+call_bc_transmit_status(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
 
-	xprt_end_transmit(task);
 	dprint_status(task);
+
 	switch (task->tk_status) {
 	case 0:
 		/* Success */
@@ -2125,8 +2131,14 @@ call_bc_transmit(struct rpc_task *task)
 	case -ENOTCONN:
 	case -EPIPE:
 		break;
+	case -ENOBUFS:
+		rpc_delay(task, HZ>>2);
+		/* fall through */
+	case -EBADSLT:
 	case -EAGAIN:
-		goto out_retry;
+		task->tk_status = 0;
+		task->tk_action = call_bc_transmit;
+		return;
 	case -ETIMEDOUT:
 		/*
 		 * Problem reaching the server.  Disconnect and let the
@@ -2145,18 +2157,11 @@ call_bc_transmit(struct rpc_task *task)
 		 * We were unable to reply and will have to drop the
 		 * request.  The server should reconnect and retransmit.
 		 */
-		WARN_ON_ONCE(task->tk_status == -EAGAIN);
 		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
 			"error: %d\n", task->tk_status);
 		break;
 	}
-out_wakeup:
-	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
-out_done:
 	task->tk_action = rpc_exit_task;
-	return;
-out_retry:
-	task->tk_status = 0;
 }
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
-- 
2.20.1

