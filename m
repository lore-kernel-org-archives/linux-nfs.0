Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33605 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745Ab2JWOxX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:23 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 08/25] SUNRPC: remove BUG_ON from rpc_sleep_on*
Date: Tue, 23 Oct 2012 10:43:32 -0400
Message-Id: <1351003429-18887-9-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE() and clean up after inactive task.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/sched.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6357fcb..f494b35 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -343,7 +343,12 @@ void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 				rpc_action action)
 {
 	/* We shouldn't ever put an inactive task to sleep */
-	BUG_ON(!RPC_IS_ACTIVATED(task));
+	WARN_ON_ONCE(!RPC_IS_ACTIVATED(task));
+	if (!RPC_IS_ACTIVATED(task)) {
+		task->tk_status = -EIO;
+		rpc_put_task_async(task);
+		return;
+	}
 
 	/*
 	 * Protect the queue operations.
@@ -358,7 +363,12 @@ void rpc_sleep_on_priority(struct rpc_wait_queue *q, struct rpc_task *task,
 		rpc_action action, int priority)
 {
 	/* We shouldn't ever put an inactive task to sleep */
-	BUG_ON(!RPC_IS_ACTIVATED(task));
+	WARN_ON_ONCE(!RPC_IS_ACTIVATED(task));
+	if (!RPC_IS_ACTIVATED(task)) {
+		task->tk_status = -EIO;
+		rpc_put_task_async(task);
+		return;
+	}
 
 	/*
 	 * Protect the queue operations.
-- 
1.7.9.6 (Apple Git-31.1)

