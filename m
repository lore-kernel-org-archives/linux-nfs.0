Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36092 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbcBAElY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 23:41:24 -0500
Received: by mail-io0-f178.google.com with SMTP id g73so145877292ioe.3
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 20:41:24 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 08/13] SUNRPC: Allow caller to specify the transport to use
Date: Sun, 31 Jan 2016 23:40:25 -0500
Message-Id: <1454301630-17358-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454301630-17358-8-git-send-email-trond.myklebust@primarydata.com>
References: <1454301630-17358-1-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-2-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-3-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-4-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-5-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-6-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-7-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is needed in order to allow the NFSv4.1 backchannel and
BIND_CONN_TO_SESSION function to work.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/sched.h | 1 +
 net/sunrpc/sched.c           | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 0b248e98ee3b..05a1809c44d9 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -103,6 +103,7 @@ struct rpc_call_ops {
 struct rpc_task_setup {
 	struct rpc_task *task;
 	struct rpc_clnt *rpc_client;
+	struct rpc_xprt *rpc_xprt;
 	const struct rpc_message *rpc_message;
 	const struct rpc_call_ops *callback_ops;
 	void *callback_data;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 73ad57a59989..fcfd48d263f6 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -909,6 +909,8 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 	/* Initialize workqueue for async tasks */
 	task->tk_workqueue = task_setup_data->workqueue;
 
+	task->tk_xprt = xprt_get(task_setup_data->rpc_xprt);
+
 	if (task->tk_ops->rpc_call_prepare != NULL)
 		task->tk_action = rpc_prepare_task;
 
-- 
2.5.0

