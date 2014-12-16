Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:59864 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbaLPTCh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:37 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so14628354pab.35
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:37 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 17/50] sunrpc: add rpc_count_iostats_idx
Date: Tue, 16 Dec 2014 11:01:20 -0800
Message-Id: <1418756513-95187-18-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

Add a call to tally stats for a task under a different statsidx than
what's contained in the task structure.

This is needed to properly account for pnfs reads/writes when the
DS nfs version != the MDS version.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 include/linux/sunrpc/metrics.h |  2 ++
 net/sunrpc/stats.c             | 26 +++++++++++++++++++-------
 2 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/metrics.h b/include/linux/sunrpc/metrics.h
index eecb5a7..89f2ca1 100644
--- a/include/linux/sunrpc/metrics.h
+++ b/include/linux/sunrpc/metrics.h
@@ -79,6 +79,8 @@ struct rpc_clnt;
 struct rpc_iostats *	rpc_alloc_iostats(struct rpc_clnt *);
 void			rpc_count_iostats(const struct rpc_task *,
 					  struct rpc_iostats *);
+void			rpc_count_iostats_metrics(const struct rpc_task *,
+					  struct rpc_iostats *);
 void			rpc_print_iostats(struct seq_file *, struct rpc_clnt *);
 void			rpc_free_iostats(struct rpc_iostats *);
 
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 9711a15..2ecb994 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -140,22 +140,20 @@ void rpc_free_iostats(struct rpc_iostats *stats)
 EXPORT_SYMBOL_GPL(rpc_free_iostats);
 
 /**
- * rpc_count_iostats - tally up per-task stats
+ * rpc_count_iostats_metrics - tally up per-task stats
  * @task: completed rpc_task
- * @stats: array of stat structures
+ * @op_metrics: stat structure for OP that will accumulate stats from @task
  */
-void rpc_count_iostats(const struct rpc_task *task, struct rpc_iostats *stats)
+void rpc_count_iostats_metrics(const struct rpc_task *task,
+			       struct rpc_iostats *op_metrics)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	struct rpc_iostats *op_metrics;
 	ktime_t delta, now;
 
-	if (!stats || !req)
+	if (!op_metrics || !req)
 		return;
 
 	now = ktime_get();
-	op_metrics = &stats[task->tk_msg.rpc_proc->p_statidx];
-
 	spin_lock(&op_metrics->om_lock);
 
 	op_metrics->om_ops++;
@@ -175,6 +173,20 @@ void rpc_count_iostats(const struct rpc_task *task, struct rpc_iostats *stats)
 
 	spin_unlock(&op_metrics->om_lock);
 }
+EXPORT_SYMBOL_GPL(rpc_count_iostats_metrics);
+
+/**
+ * rpc_count_iostats - tally up per-task stats
+ * @task: completed rpc_task
+ * @stats: array of stat structures
+ *
+ * Uses the statidx from @task
+ */
+void rpc_count_iostats(const struct rpc_task *task, struct rpc_iostats *stats)
+{
+	rpc_count_iostats_metrics(task,
+				  &stats[task->tk_msg.rpc_proc->p_statidx]);
+}
 EXPORT_SYMBOL_GPL(rpc_count_iostats);
 
 static void _print_name(struct seq_file *seq, unsigned int op,
-- 
1.9.3

