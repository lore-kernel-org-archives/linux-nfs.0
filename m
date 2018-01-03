Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:44084 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbeACUin (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jan 2018 15:38:43 -0500
Subject: [PATCH 5/6] SUNRPC: task_run_action should display tk_callback
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Jan 2018 15:38:41 -0500
Message-ID: <20180103203841.29209.13773.stgit@manet.1015granger.net>
In-Reply-To: <20180103203540.29209.4620.stgit@manet.1015granger.net>
References: <20180103203540.29209.4620.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This shows up in every RPC:

     kworker/4:1-19772 [004]  3467.373443: rpc_task_run_action:  task:4711@2 flags=0e81 state=0005 status=0 action=call_status
     kworker/4:1-19772 [004]  3467.373444: rpc_task_run_action:  task:4711@2 flags=0e81 state=0005 status=0 action=call_status

What's actually going on is that the first iteration of the RPC
scheduler is invoking the function in tk_callback (in this case,
xprt_timer), then invoking call_status on the next iteration.

Feeding do_action, rather than tk_action, to the "task_run_action"
trace point will now always display the correct FSM step.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/sched.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index b1b49ed..c292a5e 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -770,7 +770,7 @@ static void __rpc_execute(struct rpc_task *task)
 			if (do_action == NULL)
 				break;
 		}
-		trace_rpc_task_run_action(task->tk_client, task, task->tk_action);
+		trace_rpc_task_run_action(task->tk_client, task, do_action);
 		do_action(task);
 
 		/*

