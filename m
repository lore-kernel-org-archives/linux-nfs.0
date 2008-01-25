From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 028/112] SUNRPC: Unexport rpc_init_task() and rpc_execute()
Date: Fri, 25 Jan 2008 11:37:31 -0500
Message-ID: <20080125163730.31887.19996.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14402 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756112AbYAYRAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:19 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09UO010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:17 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/sched.h |    1 -
 net/sunrpc/sched.c           |    4 +---
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 60a05c7..23481a5 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -247,7 +247,6 @@ struct rpc_wait_queue {
  */
 struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
 struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
-void		rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *);
 void		rpc_put_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_release_calldata(const struct rpc_call_ops *, void *);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index b1ad3b8..96f4fdd 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -737,7 +737,6 @@ void rpc_execute(struct rpc_task *task)
 	rpc_set_running(task);
 	__rpc_execute(task);
 }
-EXPORT_SYMBOL_GPL(rpc_execute);
 
 static void rpc_async_schedule(struct work_struct *work)
 {
@@ -815,7 +814,7 @@ EXPORT_SYMBOL_GPL(rpc_free);
 /*
  * Creation and deletion of RPC task structures
  */
-void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *task_setup_data)
+static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *task_setup_data)
 {
 	memset(task, 0, sizeof(*task));
 	init_timer(&task->tk_timer);
@@ -866,7 +865,6 @@ void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *task_setu
 	dprintk("RPC:       new task initialized, procpid %u\n",
 				task_pid_nr(current));
 }
-EXPORT_SYMBOL_GPL(rpc_init_task);
 
 static struct rpc_task *
 rpc_alloc_task(void)
