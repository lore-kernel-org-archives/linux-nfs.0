Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:47571 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933455AbdKCRqI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 13:46:08 -0400
Received: by mail-io0-f196.google.com with SMTP id h70so7961677ioi.4
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 10:46:08 -0700 (PDT)
Subject: [PATCH 1/2] sunrpc: Fix rpc_task_begin trace point
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 03 Nov 2017 13:46:06 -0400
Message-ID: <20171103174606.31080.88748.stgit@manet.1015granger.net>
In-Reply-To: <20171103174509.31080.80937.stgit@manet.1015granger.net>
References: <20171103174509.31080.80937.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpc_task_begin trace point always display a task ID of zero.
Move the trace point call site so that it picks up the new task ID.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/sched.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0cc8383..f9db5fe 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -274,10 +274,9 @@ static inline void rpc_task_set_debuginfo(struct rpc_task *task)
 
 static void rpc_set_active(struct rpc_task *task)
 {
-	trace_rpc_task_begin(task->tk_client, task, NULL);
-
 	rpc_task_set_debuginfo(task);
 	set_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
+	trace_rpc_task_begin(task->tk_client, task, NULL);
 }
 
 /*

