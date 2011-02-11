Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34575 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757209Ab1BKPmq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 10:42:46 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2/4] RPC: clarify rpc_run_task error handling
Date: Fri, 11 Feb 2011 10:42:36 -0500
Message-Id: <1297438958-24861-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297438958-24861-1-git-send-email-iisaman@netapp.com>
References: <1297438958-24861-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

rpc_run_task can only fail if it is not passed in a preallocated task.
However, that is not at all clear with the current code.  So
remove several impossible to occur failure checks.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 net/sunrpc/clnt.c  |    6 ------
 net/sunrpc/sched.c |    6 ------
 2 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 57d344c..8b5a6b4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -636,12 +636,6 @@ struct rpc_task *rpc_run_task(const struct rpc_task_setup *task_setup_data)
 	rpc_task_set_client(task, task_setup_data->rpc_client);
 	rpc_task_set_rpc_message(task, task_setup_data->rpc_message);
 
-	if (task->tk_status != 0) {
-		int ret = task->tk_status;
-		rpc_put_task(task);
-		return ERR_PTR(ret);
-	}
-
 	if (task->tk_action == NULL)
 		rpc_call_start(task);
 
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index bb8f54f..a3f6d97 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -822,12 +822,6 @@ struct rpc_task *rpc_new_task(const struct rpc_task_setup *setup_data)
 	}
 
 	rpc_init_task(task, setup_data);
-	if (task->tk_status < 0) {
-		int err = task->tk_status;
-		rpc_put_task(task);
-		return ERR_PTR(err);
-	}
-
 	task->tk_flags |= flags;
 	dprintk("RPC:       allocated task %p\n", task);
 	return task;
-- 
1.7.2.1

