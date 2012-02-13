Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48529 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006Ab2BMWWM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Feb 2012 17:22:12 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Mon, 13 Feb 2012 17:22:08 -0500
Message-Id: <1329171728-3980-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Include RPC statistics from all data servers in /proc/self/mountstats for pNFS
filelayout mounts.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
Cleaned up version after comments from Trond.  This patch accumulates 
reads, writes and commits (the only DS operations) on the rpc_iostats of 
the nfs_server associated with the mount.

I was confused last week about where we breaking counting stats only for a 
mountpoint -- What I was seeing was two mounts sharing stats if they were the
same server AND the same filesystem on the server.  This patch does not address
that issue.

This patch still counts DS operations on the DS::nfs_client::rpc_clnt's stats
structures.  Assuming this patch is OK, I plan on submitting a patch that will 
show MDS-only and individual DS stats somewhere in /proc/fs/nfsfs/.

 fs/nfs/nfs4filelayout.c        |   19 +++++++++++++++++++
 include/linux/sunrpc/metrics.h |    6 ++++--
 include/linux/sunrpc/sched.h   |    1 +
 net/sunrpc/stats.c             |    8 ++++----
 net/sunrpc/xprt.c              |    5 ++++-
 5 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 79be7ac..47e8f34 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -33,6 +33,8 @@
 #include <linux/nfs_page.h>
 #include <linux/module.h>
 
+#include <linux/sunrpc/metrics.h>
+
 #include "internal.h"
 #include "nfs4filelayout.h"
 
@@ -189,6 +191,13 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 	rdata->mds_ops->rpc_call_done(task, data);
 }
 
+static void filelayout_read_count_stats(struct rpc_task *task, void *data)
+{
+	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
+
+	rpc_count_iostats(task, NFS_SERVER(rdata->inode)->client->cl_metrics);
+}
+
 static void filelayout_read_release(void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
@@ -268,6 +277,13 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 	wdata->mds_ops->rpc_call_done(task, data);
 }
 
+static void filelayout_write_count_stats(struct rpc_task *task, void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	rpc_count_iostats(task, NFS_SERVER(wdata->inode)->client->cl_metrics);
+}
+
 static void filelayout_write_release(void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
@@ -288,18 +304,21 @@ static void filelayout_commit_release(void *data)
 struct rpc_call_ops filelayout_read_call_ops = {
 	.rpc_call_prepare = filelayout_read_prepare,
 	.rpc_call_done = filelayout_read_call_done,
+	.rpc_count_stats = filelayout_read_count_stats,
 	.rpc_release = filelayout_read_release,
 };
 
 struct rpc_call_ops filelayout_write_call_ops = {
 	.rpc_call_prepare = filelayout_write_prepare,
 	.rpc_call_done = filelayout_write_call_done,
+	.rpc_count_stats = filelayout_write_count_stats,
 	.rpc_release = filelayout_write_release,
 };
 
 struct rpc_call_ops filelayout_commit_call_ops = {
 	.rpc_call_prepare = filelayout_write_prepare,
 	.rpc_call_done = filelayout_write_call_done,
+	.rpc_count_stats = filelayout_write_count_stats,
 	.rpc_release = filelayout_commit_release,
 };
 
diff --git a/include/linux/sunrpc/metrics.h b/include/linux/sunrpc/metrics.h
index b6edbc0..1565bbe 100644
--- a/include/linux/sunrpc/metrics.h
+++ b/include/linux/sunrpc/metrics.h
@@ -74,14 +74,16 @@ struct rpc_clnt;
 #ifdef CONFIG_PROC_FS
 
 struct rpc_iostats *	rpc_alloc_iostats(struct rpc_clnt *);
-void			rpc_count_iostats(struct rpc_task *);
+void			rpc_count_iostats(const struct rpc_task *,
+					  struct rpc_iostats *);
 void			rpc_print_iostats(struct seq_file *, struct rpc_clnt *);
 void			rpc_free_iostats(struct rpc_iostats *);
 
 #else  /*  CONFIG_PROC_FS  */
 
 static inline struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt) { return NULL; }
-static inline void rpc_count_iostats(struct rpc_task *task) {}
+static inline void rpc_count_iostats(const struct rpc_task *task,
+				     struct rpc_iostats *stats) {}
 static inline void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt) {}
 static inline void rpc_free_iostats(struct rpc_iostats *stats) {}
 
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 22dfc24..dc0c3cc 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -103,6 +103,7 @@ typedef void			(*rpc_action)(struct rpc_task *);
 struct rpc_call_ops {
 	void (*rpc_call_prepare)(struct rpc_task *, void *);
 	void (*rpc_call_done)(struct rpc_task *, void *);
+	void (*rpc_count_stats)(struct rpc_task *, void *);
 	void (*rpc_release)(void *);
 };
 
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 3c4f688..1eb3304 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -133,20 +133,19 @@ EXPORT_SYMBOL_GPL(rpc_free_iostats);
 /**
  * rpc_count_iostats - tally up per-task stats
  * @task: completed rpc_task
+ * @stats: array of stat structures
  *
  * Relies on the caller for serialization.
  */
-void rpc_count_iostats(struct rpc_task *task)
+void rpc_count_iostats(const struct rpc_task *task, struct rpc_iostats *stats)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
-	struct rpc_iostats *stats;
 	struct rpc_iostats *op_metrics;
 	ktime_t delta;
 
-	if (!task->tk_client || !task->tk_client->cl_metrics || !req)
+	if (!stats || !req)
 		return;
 
-	stats = task->tk_client->cl_metrics;
 	op_metrics = &stats[task->tk_msg.rpc_proc->p_statidx];
 
 	op_metrics->om_ops++;
@@ -164,6 +163,7 @@ void rpc_count_iostats(struct rpc_task *task)
 	delta = ktime_sub(ktime_get(), task->tk_start);
 	op_metrics->om_execute = ktime_add(op_metrics->om_execute, delta);
 }
+EXPORT_SYMBOL_GPL(rpc_count_iostats);
 
 static void _print_name(struct seq_file *seq, unsigned int op,
 			struct rpc_procinfo *procs)
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index efe5495..ab7a28f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1132,7 +1132,10 @@ void xprt_release(struct rpc_task *task)
 		return;
 
 	xprt = req->rq_xprt;
-	rpc_count_iostats(task);
+	if (task->tk_client)
+		rpc_count_iostats(task, task->tk_client->cl_metrics);
+	if (task->tk_ops->rpc_count_stats != NULL)
+		task->tk_ops->rpc_count_stats(task, task->tk_calldata);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt->ops->release_xprt(xprt, task);
 	if (xprt->ops->release_request)
-- 
1.7.4.4

