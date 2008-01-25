From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 022/112] SUNRPC: Allow rpc_init_task() to initialise the
	rpc_task->tk_msg
Date: Fri, 25 Jan 2008 11:37:29 -0500
Message-ID: <20080125163728.31887.23411.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14350 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888AbYAYQ7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:54 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxrZq010219
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:53 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for the removal of rpc_call_setup().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c  |   11 ++++-------
 net/sunrpc/sched.c |   11 +++++++++++
 2 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7aeffee..6eb79c4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -540,13 +540,10 @@ struct rpc_task *rpc_run_task(const struct rpc_task_setup *task_setup_data)
 		goto out;
 	}
 
-	if (task_setup_data->rpc_message != NULL) {
-		rpc_call_setup(task, task_setup_data->rpc_message, 0);
-		if (task->tk_status != 0) {
-			ret = ERR_PTR(task->tk_status);
-			rpc_put_task(task);
-			goto out;
-		}
+	if (task->tk_status != 0) {
+		ret = ERR_PTR(task->tk_status);
+		rpc_put_task(task);
+		goto out;
 	}
 	atomic_inc(&task->tk_count);
 	/* Mask signals on synchronous RPC calls and RPCSEC_GSS upcalls */
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0adbddb..76c834d 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -849,6 +849,17 @@ void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *task_setu
 	if (task->tk_ops->rpc_call_prepare != NULL)
 		task->tk_action = rpc_prepare_task;
 
+	if (task_setup_data->rpc_message != NULL) {
+		memcpy(&task->tk_msg, task_setup_data->rpc_message, sizeof(task->tk_msg));
+		/* Bind the user cred */
+		if (task->tk_msg.rpc_cred != NULL)
+			rpcauth_holdcred(task);
+		else
+			rpcauth_bindcred(task);
+		if (task->tk_action == NULL)
+			rpc_call_start(task);
+	}
+
 	/* starting timestamp */
 	task->tk_start = jiffies;
 
