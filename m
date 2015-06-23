Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36440 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbbFWLwj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2015 07:52:39 -0400
Received: by paceq1 with SMTP id eq1so5590812pac.3
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jun 2015 04:52:38 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH-v2 05/10] pNFS/flexfiles: add layoutstats tracking
Date: Tue, 23 Jun 2015 19:51:59 +0800
Message-Id: <1435060324-13279-6-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
References: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 191 +++++++++++++++++++++++++++++++--
 fs/nfs/flexfilelayout/flexfilelayout.h |  22 ++++
 2 files changed, 202 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7d05089..acbe677 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -415,6 +415,129 @@ ff_layout_get_lseg_count(struct nfs4_ff_layout_segment *fls)
 	return 1;
 }
 
+static void
+nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer)
+{
+	ktime_t old;
+
+	/*
+	 * Note: careful here!
+	 * If the counter is zero, then we must not increment it until after
+	 * we've set the start_time.
+	 * If we were instead to use atomic_inc_return(), then another
+	 * request might come in, bump, and then call end_busy_timer()
+	 * before we've set the timer->start_time.
+	 */
+	old = timer->start_time;
+	if (atomic_inc_not_zero(&timer->n_ops) == 0) {
+		cmpxchg(&timer->start_time, old, ktime_get());
+		atomic_inc(&timer->n_ops);
+	}
+}
+
+static ktime_t
+nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer)
+{
+	ktime_t start, now;
+
+	now = ktime_get();
+	start = xchg(&timer->start_time, now);
+	atomic_dec(&timer->n_ops);
+	return ktime_sub(now, start);
+}
+
+static ktime_t
+nfs4_ff_layout_calc_completion_time(struct rpc_task *task)
+{
+	return ktime_sub(ktime_get(), task->tk_start);
+}
+
+static void
+nfs4_ff_layoutstat_start_io(struct nfs4_ff_layoutstat *layoutstat)
+{
+	nfs4_ff_start_busy_timer(&layoutstat->busy_timer);
+}
+
+static void
+nfs4_ff_layout_stat_io_update_requested(struct nfs4_ff_layoutstat *layoutstat,
+		__u64 requested)
+{
+	struct nfs4_ff_io_stat *iostat = &layoutstat->io_stat;
+
+	iostat->ops_requested++;
+	iostat->bytes_requested += requested;
+}
+
+static void
+nfs4_ff_layout_stat_io_update_completed(struct nfs4_ff_layoutstat *layoutstat,
+		__u64 requested,
+		__u64 completed,
+		ktime_t time_completed)
+{
+	struct nfs4_ff_io_stat *iostat = &layoutstat->io_stat;
+	ktime_t timer;
+
+	iostat->ops_completed++;
+	iostat->bytes_completed += completed;
+	iostat->bytes_not_delivered += requested - completed;
+
+	timer = nfs4_ff_end_busy_timer(&layoutstat->busy_timer);
+	iostat->total_busy_time =
+			ktime_add(iostat->total_busy_time, timer);
+	iostat->aggregate_completion_time =
+			ktime_add(iostat->aggregate_completion_time, time_completed);
+}
+
+static void
+nfs4_ff_layout_stat_io_start_read(struct nfs4_ff_layout_mirror *mirror,
+		__u64 requested)
+{
+	spin_lock(&mirror->lock);
+	nfs4_ff_layoutstat_start_io(&mirror->read_stat);
+	nfs4_ff_layout_stat_io_update_requested(&mirror->read_stat, requested);
+	spin_unlock(&mirror->lock);
+}
+
+static void
+nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
+		struct nfs4_ff_layout_mirror *mirror,
+		__u64 requested,
+		__u64 completed)
+{
+	spin_lock(&mirror->lock);
+	nfs4_ff_layout_stat_io_update_completed(&mirror->read_stat,
+			requested, completed,
+			nfs4_ff_layout_calc_completion_time(task));
+	spin_unlock(&mirror->lock);
+}
+
+static void
+nfs4_ff_layout_stat_io_start_write(struct nfs4_ff_layout_mirror *mirror,
+		__u64 requested)
+{
+	spin_lock(&mirror->lock);
+	nfs4_ff_layoutstat_start_io(&mirror->write_stat);
+	nfs4_ff_layout_stat_io_update_requested(&mirror->write_stat, requested);
+	spin_unlock(&mirror->lock);
+}
+
+static void
+nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
+		struct nfs4_ff_layout_mirror *mirror,
+		__u64 requested,
+		__u64 completed,
+		enum nfs3_stable_how committed)
+{
+	if (committed == NFS_UNSTABLE)
+		requested = completed = 0;
+
+	spin_lock(&mirror->lock);
+	nfs4_ff_layout_stat_io_update_completed(&mirror->write_stat,
+			requested, completed,
+			nfs4_ff_layout_calc_completion_time(task));
+	spin_unlock(&mirror->lock);
+}
+
 static int
 ff_layout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 			    struct nfs_commit_info *cinfo,
@@ -909,6 +1032,10 @@ ff_layout_reset_to_mds(struct pnfs_layout_segment *lseg, int idx)
 static int ff_layout_read_prepare_common(struct rpc_task *task,
 					 struct nfs_pgio_header *hdr)
 {
+	nfs4_ff_layout_stat_io_start_read(
+			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
+			hdr->args.count);
+
 	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
 		rpc_exit(task, -EIO);
 		return -EIO;
@@ -962,15 +1089,15 @@ static void ff_layout_read_prepare_v4(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
-	if (ff_layout_read_prepare_common(task, hdr))
-		return;
-
 	if (ff_layout_setup_sequence(hdr->ds_clp,
 				     &hdr->args.seq_args,
 				     &hdr->res.seq_res,
 				     task))
 		return;
 
+	if (ff_layout_read_prepare_common(task, hdr))
+		return;
+
 	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
 			hdr->args.lock_context, FMODE_READ) == -EIO)
 		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
@@ -982,6 +1109,10 @@ static void ff_layout_read_call_done(struct rpc_task *task, void *data)
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
+	nfs4_ff_layout_stat_io_end_read(task,
+			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
+			hdr->args.count, hdr->res.count);
+
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags) &&
 	    task->tk_status == 0) {
 		nfs4_sequence_done(task, &hdr->res.seq_res);
@@ -1083,6 +1214,10 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 static int ff_layout_write_prepare_common(struct rpc_task *task,
 					  struct nfs_pgio_header *hdr)
 {
+	nfs4_ff_layout_stat_io_start_write(
+			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
+			hdr->args.count);
+
 	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
 		rpc_exit(task, -EIO);
 		return -EIO;
@@ -1116,15 +1251,15 @@ static void ff_layout_write_prepare_v4(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
-	if (ff_layout_write_prepare_common(task, hdr))
-		return;
-
 	if (ff_layout_setup_sequence(hdr->ds_clp,
 				     &hdr->args.seq_args,
 				     &hdr->res.seq_res,
 				     task))
 		return;
 
+	if (ff_layout_write_prepare_common(task, hdr))
+		return;
+
 	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
 			hdr->args.lock_context, FMODE_WRITE) == -EIO)
 		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
@@ -1134,6 +1269,11 @@ static void ff_layout_write_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
+	nfs4_ff_layout_stat_io_end_write(task,
+			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
+			hdr->args.count, hdr->res.count,
+			hdr->res.verf->committed);
+
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags) &&
 	    task->tk_status == 0) {
 		nfs4_sequence_done(task, &hdr->res.seq_res);
@@ -1152,8 +1292,17 @@ static void ff_layout_write_count_stats(struct rpc_task *task, void *data)
 	    &NFS_CLIENT(hdr->inode)->cl_metrics[NFSPROC4_CLNT_WRITE]);
 }
 
+static void ff_layout_commit_prepare_common(struct rpc_task *task,
+		struct nfs_commit_data *cdata)
+{
+	nfs4_ff_layout_stat_io_start_write(
+			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
+			0);
+}
+
 static void ff_layout_commit_prepare_v3(struct rpc_task *task, void *data)
 {
+	ff_layout_commit_prepare_common(task, data);
 	rpc_call_start(task);
 }
 
@@ -1161,10 +1310,30 @@ static void ff_layout_commit_prepare_v4(struct rpc_task *task, void *data)
 {
 	struct nfs_commit_data *wdata = data;
 
-	ff_layout_setup_sequence(wdata->ds_clp,
+	if (ff_layout_setup_sequence(wdata->ds_clp,
 				 &wdata->args.seq_args,
 				 &wdata->res.seq_res,
-				 task);
+				 task))
+		return;
+	ff_layout_commit_prepare_common(task, data);
+}
+
+static void ff_layout_commit_done(struct rpc_task *task, void *data)
+{
+	struct nfs_commit_data *cdata = data;
+	struct nfs_page *req;
+	__u64 count = 0;
+
+	if (task->tk_status == 0) {
+		list_for_each_entry(req, &cdata->pages, wb_list)
+			count += req->wb_bytes;
+	}
+
+	nfs4_ff_layout_stat_io_end_write(task,
+			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
+			count, count, NFS_FILE_SYNC);
+
+	pnfs_generic_write_commit_done(task, data);
 }
 
 static void ff_layout_commit_count_stats(struct rpc_task *task, void *data)
@@ -1205,14 +1374,14 @@ static const struct rpc_call_ops ff_layout_write_call_ops_v4 = {
 
 static const struct rpc_call_ops ff_layout_commit_call_ops_v3 = {
 	.rpc_call_prepare = ff_layout_commit_prepare_v3,
-	.rpc_call_done = pnfs_generic_write_commit_done,
+	.rpc_call_done = ff_layout_commit_done,
 	.rpc_count_stats = ff_layout_commit_count_stats,
 	.rpc_release = pnfs_generic_commit_release,
 };
 
 static const struct rpc_call_ops ff_layout_commit_call_ops_v4 = {
 	.rpc_call_prepare = ff_layout_commit_prepare_v4,
-	.rpc_call_done = pnfs_generic_write_commit_done,
+	.rpc_call_done = ff_layout_commit_done,
 	.rpc_count_stats = ff_layout_commit_count_stats,
 	.rpc_release = pnfs_generic_commit_release,
 };
@@ -1256,7 +1425,6 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
 	if (fh)
 		hdr->args.fh = fh;
-
 	/*
 	 * Note that if we ever decide to split across DSes,
 	 * then we may need to handle dense-like offsets.
@@ -1385,6 +1553,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
 		data->args.fh = fh;
+
 	return nfs_initiate_commit(ds_clnt, data, ds->ds_clp->rpc_ops,
 				   vers == 3 ? &ff_layout_commit_call_ops_v3 :
 					       &ff_layout_commit_call_ops_v4,
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 275e4b7..f7493f7 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -41,6 +41,26 @@ struct nfs4_ff_layout_ds_err {
 	struct nfs4_deviceid		deviceid;
 };
 
+struct nfs4_ff_io_stat {
+	__u64				ops_requested;
+	__u64				bytes_requested;
+	__u64				ops_completed;
+	__u64				bytes_completed;
+	__u64				bytes_not_delivered;
+	ktime_t				total_busy_time;
+	ktime_t				aggregate_completion_time;
+};
+
+struct nfs4_ff_busy_timer {
+	ktime_t start_time;
+	atomic_t n_ops;
+};
+
+struct nfs4_ff_layoutstat {
+	struct nfs4_ff_io_stat io_stat;
+	struct nfs4_ff_busy_timer busy_timer;
+};
+
 struct nfs4_ff_layout_mirror {
 	u32				ds_count;
 	u32				efficiency;
@@ -52,6 +72,8 @@ struct nfs4_ff_layout_mirror {
 	u32				gid;
 	struct rpc_cred			*cred;
 	spinlock_t			lock;
+	struct nfs4_ff_layoutstat	read_stat;
+	struct nfs4_ff_layoutstat	write_stat;
 };
 
 struct nfs4_ff_layout_segment {
-- 
1.8.3.1

