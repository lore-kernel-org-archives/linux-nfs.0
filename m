Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:39470 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaKZTo5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Nov 2014 14:44:57 -0500
Received: by mail-qc0-f178.google.com with SMTP id b13so2939203qcw.9
        for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 11:44:56 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/5] sunrpc: eliminate RPC_TRACEPOINTS
Date: Wed, 26 Nov 2014 14:44:42 -0500
Message-Id: <1417031084-17576-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
References: <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
 <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
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
index 51143757b8f7..43f38ee9668c 100644
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

