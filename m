Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16006 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754841Ab2JPQbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:39 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 23/25] SUNRPC: remove BUG_ON()s checking RPC_IS_QUEUED()
Date: Tue, 16 Oct 2012 12:30:41 -0400
Message-Id: <1350405043-39316-23-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace two BUG_ON() calls with WARN_ON_ONCE() and early returns.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/sched.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 5dcc1ff..2d72af1 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -133,7 +133,9 @@ static void __rpc_add_wait_queue(struct rpc_wait_queue *queue,
 		struct rpc_task *task,
 		unsigned char queue_priority)
 {
-	BUG_ON (RPC_IS_QUEUED(task));
+	WARN_ON_ONCE(RPC_IS_QUEUED(task));
+	if (RPC_IS_QUEUED(task))
+		return;
 
 	if (RPC_IS_PRIORITY(queue))
 		__rpc_add_wait_queue_priority(queue, task, queue_priority);
@@ -705,7 +707,9 @@ static void __rpc_execute(struct rpc_task *task)
 	dprintk("RPC: %5u __rpc_execute flags=0x%x\n",
 			task->tk_pid, task->tk_flags);
 
-	BUG_ON(RPC_IS_QUEUED(task));
+	WARN_ON_ONCE(RPC_IS_QUEUED(task));
+	if (RPC_IS_QUEUED(task))
+		return;
 
 	for (;;) {
 		void (*do_action)(struct rpc_task *);
-- 
1.7.9.6 (Apple Git-31.1)

