Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:41572 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757002Ab3EVW67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 18:58:59 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Remove redundant call to rpc_set_running() in __rpc_execute()
Date: Wed, 22 May 2013 18:58:28 -0400
Message-Id: <1369263508-54488-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC_TASK_RUNNING flag will always have been set in rpc_make_runnable()
once we get past the test for out_of_line_wait_on_bit() returning
ERESTARTSYS.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/sched.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index dcbd69c..b7b32c3 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -790,7 +790,6 @@ static void __rpc_execute(struct rpc_task *task)
 			task->tk_flags |= RPC_TASK_KILLED;
 			rpc_exit(task, -ERESTARTSYS);
 		}
-		rpc_set_running(task);
 		dprintk("RPC: %5u sync task resuming\n", task->tk_pid);
 	}
 
-- 
1.8.1.4

