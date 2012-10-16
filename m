Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15883 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755047Ab2JPQbD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:03 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 08/25] SUNRPC: remove BUG_ON() from rpc_sleep_on*()
Date: Tue, 16 Oct 2012 12:30:26 -0400
Message-Id: <1350405043-39316-8-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE() and clean up by calling rpc_exit().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/sched.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6357fcb..ec9513d 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -343,7 +343,11 @@ void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 				rpc_action action)
 {
 	/* We shouldn't ever put an inactive task to sleep */
-	BUG_ON(!RPC_IS_ACTIVATED(task));
+	WARN_ON_ONCE(!RPC_IS_ACTIVATED(task));
+	if (!RPC_IS_ACTIVATED(task)) {
+		rpc_exit(task, -EINVAL);
+		return;
+	}
 
 	/*
 	 * Protect the queue operations.
@@ -358,7 +362,11 @@ void rpc_sleep_on_priority(struct rpc_wait_queue *q, struct rpc_task *task,
 		rpc_action action, int priority)
 {
 	/* We shouldn't ever put an inactive task to sleep */
-	BUG_ON(!RPC_IS_ACTIVATED(task));
+	WARN_ON_ONCE(!RPC_IS_ACTIVATED(task));
+	if (!RPC_IS_ACTIVATED(task)) {
+		rpc_exit(task, -EINVAL);
+		return;
+	}
 
 	/*
 	 * Protect the queue operations.
-- 
1.7.9.6 (Apple Git-31.1)

