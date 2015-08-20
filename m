Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36863 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbbHTSZ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 14:25:57 -0400
Received: by pawq9 with SMTP id q9so33528291paw.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 11:25:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/pnfs: Ensure the flexfiles layoutstats timers are consistent
Date: Thu, 20 Aug 2015 13:25:54 -0500
Message-Id: <1440095154-11492-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to ensure that the stopwatches for the busy timer and the
aggregate timer are consistent. This means that they need to use
the same start/stop times.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 51 ++++++++++++++++------------------
 1 file changed, 24 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4bd3cff94190..0fcb8670f25f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -419,42 +419,35 @@ ff_layout_get_lseg_count(struct nfs4_ff_layout_segment *fls)
 }
 
 static void
-nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer)
+nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 {
 	/* first IO request? */
 	if (atomic_inc_return(&timer->n_ops) == 1) {
-		timer->start_time = ktime_get();
+		timer->start_time = now;
 	}
 }
 
 static ktime_t
-nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer)
+nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 {
-	ktime_t start, now;
+	ktime_t start;
 
 	if (atomic_dec_return(&timer->n_ops) < 0)
 		WARN_ON_ONCE(1);
 
-	now = ktime_get();
 	start = timer->start_time;
 	timer->start_time = now;
 	return ktime_sub(now, start);
 }
 
-static ktime_t
-nfs4_ff_layout_calc_completion_time(struct rpc_task *task)
-{
-	return ktime_sub(ktime_get(), task->tk_start);
-}
-
 static bool
 nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
-			    struct nfs4_ff_layoutstat *layoutstat)
+			    struct nfs4_ff_layoutstat *layoutstat,
+			    ktime_t now)
 {
 	static const ktime_t notime = {0};
-	ktime_t now = ktime_get();
 
-	nfs4_ff_start_busy_timer(&layoutstat->busy_timer);
+	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
 	if (ktime_equal(mirror->start_time, notime))
 		mirror->start_time = now;
 	if (ktime_equal(mirror->last_report_time, notime))
@@ -482,30 +475,33 @@ static void
 nfs4_ff_layout_stat_io_update_completed(struct nfs4_ff_layoutstat *layoutstat,
 		__u64 requested,
 		__u64 completed,
-		ktime_t time_completed)
+		ktime_t time_completed,
+		ktime_t time_started)
 {
 	struct nfs4_ff_io_stat *iostat = &layoutstat->io_stat;
+	ktime_t completion_time = ktime_sub(time_completed, time_started);
 	ktime_t timer;
 
 	iostat->ops_completed++;
 	iostat->bytes_completed += completed;
 	iostat->bytes_not_delivered += requested - completed;
 
-	timer = nfs4_ff_end_busy_timer(&layoutstat->busy_timer);
+	timer = nfs4_ff_end_busy_timer(&layoutstat->busy_timer, time_completed);
 	iostat->total_busy_time =
 			ktime_add(iostat->total_busy_time, timer);
 	iostat->aggregate_completion_time =
-			ktime_add(iostat->aggregate_completion_time, time_completed);
+			ktime_add(iostat->aggregate_completion_time,
+					completion_time);
 }
 
 static void
 nfs4_ff_layout_stat_io_start_read(struct nfs4_ff_layout_mirror *mirror,
-		__u64 requested)
+		__u64 requested, ktime_t now)
 {
 	bool report;
 
 	spin_lock(&mirror->lock);
-	report = nfs4_ff_layoutstat_start_io(mirror, &mirror->read_stat);
+	report = nfs4_ff_layoutstat_start_io(mirror, &mirror->read_stat, now);
 	nfs4_ff_layout_stat_io_update_requested(&mirror->read_stat, requested);
 	spin_unlock(&mirror->lock);
 
@@ -523,18 +519,18 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 	spin_lock(&mirror->lock);
 	nfs4_ff_layout_stat_io_update_completed(&mirror->read_stat,
 			requested, completed,
-			nfs4_ff_layout_calc_completion_time(task));
+			ktime_get(), task->tk_start);
 	spin_unlock(&mirror->lock);
 }
 
 static void
 nfs4_ff_layout_stat_io_start_write(struct nfs4_ff_layout_mirror *mirror,
-		__u64 requested)
+		__u64 requested, ktime_t now)
 {
 	bool report;
 
 	spin_lock(&mirror->lock);
-	report = nfs4_ff_layoutstat_start_io(mirror , &mirror->write_stat);
+	report = nfs4_ff_layoutstat_start_io(mirror , &mirror->write_stat, now);
 	nfs4_ff_layout_stat_io_update_requested(&mirror->write_stat, requested);
 	spin_unlock(&mirror->lock);
 
@@ -555,8 +551,7 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 
 	spin_lock(&mirror->lock);
 	nfs4_ff_layout_stat_io_update_completed(&mirror->write_stat,
-			requested, completed,
-			nfs4_ff_layout_calc_completion_time(task));
+			requested, completed, ktime_get(), task->tk_start);
 	spin_unlock(&mirror->lock);
 }
 
@@ -1063,7 +1058,8 @@ static int ff_layout_read_prepare_common(struct rpc_task *task,
 {
 	nfs4_ff_layout_stat_io_start_read(
 			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
-			hdr->args.count);
+			hdr->args.count,
+			task->tk_start);
 
 	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
 		rpc_exit(task, -EIO);
@@ -1249,7 +1245,8 @@ static int ff_layout_write_prepare_common(struct rpc_task *task,
 {
 	nfs4_ff_layout_stat_io_start_write(
 			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
-			hdr->args.count);
+			hdr->args.count,
+			task->tk_start);
 
 	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
 		rpc_exit(task, -EIO);
@@ -1330,7 +1327,7 @@ static void ff_layout_commit_prepare_common(struct rpc_task *task,
 {
 	nfs4_ff_layout_stat_io_start_write(
 			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
-			0);
+			0, task->tk_start);
 }
 
 static void ff_layout_commit_prepare_v3(struct rpc_task *task, void *data)
-- 
2.4.3

