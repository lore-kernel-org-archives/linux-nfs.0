Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:38046 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbeACUiv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jan 2018 15:38:51 -0500
Subject: [PATCH 6/6] SUNRPC: Micro-optimize __rpc_execute
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Jan 2018 15:38:49 -0500
Message-ID: <20180103203849.29209.23116.stgit@manet.1015granger.net>
In-Reply-To: <20180103203540.29209.4620.stgit@manet.1015granger.net>
References: <20180103203540.29209.4620.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The common case: There are 13 to 14 actions per RPC, and tk_callback
is non-NULL in only one of them. There's no need to store a NULL in
the tk_callback field during each FSM step.

This slightly improves throughput results in dbench and other multi-
threaded benchmarks on my two-socket client on 56Gb InfiniBand, but
will probably be inconsequential on slower systems.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/sched.c |   24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index c292a5e..896691a 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -755,21 +755,19 @@ static void __rpc_execute(struct rpc_task *task)
 		void (*do_action)(struct rpc_task *);
 
 		/*
-		 * Execute any pending callback first.
+		 * Perform the next FSM step or a pending callback.
+		 *
+		 * tk_action may be NULL if the task has been killed.
+		 * In particular, note that rpc_killall_tasks may
+		 * do this at any time, so beware when dereferencing.
 		 */
-		do_action = task->tk_callback;
-		task->tk_callback = NULL;
-		if (do_action == NULL) {
-			/*
-			 * Perform the next FSM step.
-			 * tk_action may be NULL if the task has been killed.
-			 * In particular, note that rpc_killall_tasks may
-			 * do this at any time, so beware when dereferencing.
-			 */
-			do_action = task->tk_action;
-			if (do_action == NULL)
-				break;
+		do_action = task->tk_action;
+		if (task->tk_callback) {
+			do_action = task->tk_callback;
+			task->tk_callback = NULL;
 		}
+		if (!do_action)
+			break;
 		trace_rpc_task_run_action(task->tk_client, task, do_action);
 		do_action(task);
 

