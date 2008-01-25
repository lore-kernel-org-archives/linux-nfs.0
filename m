From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 026/112] SUNRPC: allow the caller of rpc_run_task to
	preallocate the struct rpc_task
Date: Fri, 25 Jan 2008 11:37:30 -0500
Message-ID: <20080125163730.31887.54907.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755027AbYAYQ77 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:59 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseY010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:57 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/sched.c           |   16 ++++++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index c9444fd..60a05c7 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -118,6 +118,7 @@ struct rpc_call_ops {
 };
 
 struct rpc_task_setup {
+	struct rpc_task *task;
 	struct rpc_clnt *rpc_client;
 	const struct rpc_message *rpc_message;
 	const struct rpc_call_ops *callback_ops;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 76c834d..b1ad3b8 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -886,16 +886,20 @@ static void rpc_free_task(struct rcu_head *rcu)
  */
 struct rpc_task *rpc_new_task(const struct rpc_task_setup *setup_data)
 {
-	struct rpc_task	*task;
-
-	task = rpc_alloc_task();
-	if (!task)
-		goto out;
+	struct rpc_task	*task = setup_data->task;
+	unsigned short flags = 0;
+
+	if (task == NULL) {
+		task = rpc_alloc_task();
+		if (task == NULL)
+			goto out;
+		flags = RPC_TASK_DYNAMIC;
+	}
 
 	rpc_init_task(task, setup_data);
 
+	task->tk_flags |= flags;
 	dprintk("RPC:       allocated task %p\n", task);
-	task->tk_flags |= RPC_TASK_DYNAMIC;
 out:
 	return task;
 }
