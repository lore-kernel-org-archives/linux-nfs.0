Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:43378 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbaKQV6T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 16:58:19 -0500
Received: by mail-qc0-f176.google.com with SMTP id i17so2838073qcy.21
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 13:58:16 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] sunrpc: eliminate RPC_TRACEPOINTS
Date: Mon, 17 Nov 2014 16:58:05 -0500
Message-Id: <1416261485-24686-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416261485-24686-1-git-send-email-jlayton@primarydata.com>
References: <1416261485-24686-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's always set to the same value as CONFIG_TRACEPOINTS, so we can just
use that instead.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/debug.h | 9 ---------
 include/linux/sunrpc/sched.h | 6 +++---
 net/sunrpc/sched.c           | 2 +-
 3 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index b646b3e99666..680c8de0f2c0 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -10,15 +10,6 @@
 
 #include <uapi/linux/sunrpc/debug.h>
 
-
-/*
- * Enable RPC debugging/profiling.
- */
-#ifdef CONFIG_TRACEPOINTS
-#define RPC_TRACEPOINTS
-#endif
-/* #define  RPC_PROFILE */
-
 /*
  * Debugging macros etc
  */
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index fecdbf1b4797..5f1e6bd4c316 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -79,7 +79,7 @@ struct rpc_task {
 	unsigned short		tk_flags;	/* misc flags */
 	unsigned short		tk_timeouts;	/* maj timeouts */
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || defined(RPC_TRACEPOINTS)
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || IS_ENABLED(CONFIG_TRACEPOINTS)
 	unsigned short		tk_pid;		/* debugging aid */
 #endif
 	unsigned char		tk_priority : 2,/* Task priority */
@@ -187,7 +187,7 @@ struct rpc_wait_queue {
 	unsigned char		nr;			/* # tasks remaining for cookie */
 	unsigned short		qlen;			/* total # tasks waiting in queue */
 	struct rpc_timer	timer_list;
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || defined(RPC_TRACEPOINTS)
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || IS_ENABLED(CONFIG_TRACEPOINTS)
 	const char *		name;
 #endif
 };
@@ -251,7 +251,7 @@ static inline int rpc_wait_for_completion_task(struct rpc_task *task)
 	return __rpc_wait_for_completion_task(task, NULL);
 }
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || defined (RPC_TRACEPOINTS)
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || IS_ENABLED(CONFIG_TRACEPOINTS)
 static inline const char * rpc_qname(const struct rpc_wait_queue *q)
 {
 	return ((q && q->name) ? q->name : "unknown");
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 574b2977fc4b..d20f2329eea3 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -258,7 +258,7 @@ static int rpc_wait_bit_killable(struct wait_bit_key *key)
 	return 0;
 }
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || defined(RPC_TRACEPOINTS)
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG) || IS_ENABLED(CONFIG_TRACEPOINTS)
 static void rpc_task_set_debuginfo(struct rpc_task *task)
 {
 	static atomic_t rpc_pid;
-- 
2.1.0

