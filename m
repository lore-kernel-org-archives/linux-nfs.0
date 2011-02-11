Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34575 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757168Ab1BKPmq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 10:42:46 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 1/4] RPC: remove check for impossible condition in rpc_make_runnable
Date: Fri, 11 Feb 2011 10:42:35 -0500
Message-Id: <1297438958-24861-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1297438958-24861-1-git-send-email-iisaman@netapp.com>
References: <1297438958-24861-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

queue_work() only returns 0 or 1, never a negative value.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 net/sunrpc/sched.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 243fc09..bb8f54f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -285,15 +285,8 @@ static void rpc_make_runnable(struct rpc_task *task)
 	if (rpc_test_and_set_running(task))
 		return;
 	if (RPC_IS_ASYNC(task)) {
-		int status;
-
 		INIT_WORK(&task->u.tk_work, rpc_async_schedule);
-		status = queue_work(rpciod_workqueue, &task->u.tk_work);
-		if (status < 0) {
-			printk(KERN_WARNING "RPC: failed to add task to queue: error: %d!\n", status);
-			task->tk_status = status;
-			return;
-		}
+		queue_work(rpciod_workqueue, &task->u.tk_work);
 	} else
 		wake_up_bit(&task->tk_runstate, RPC_TASK_QUEUED);
 }
-- 
1.7.2.1

