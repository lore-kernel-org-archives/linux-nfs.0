Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36490 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756547Ab2CUTqy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:46:54 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 07/12] NFSv4.1 Check invalid deviceid upon slot table waitq wakeup
Date: Wed, 21 Mar 2012 15:46:19 -0400
Message-Id: <1332359184-1887-8-git-send-email-andros@netapp.com>
In-Reply-To: <1332359184-1887-1-git-send-email-andros@netapp.com>
References: <1332359184-1887-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Tasks sleeping on the slot table waitq wake to the rpc_prepare_task state.
Reset the task for io through the MDS if the deviceid is invalid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index fdec7a8..b73818f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -241,6 +241,12 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
+	if (filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(rdata->lseg))) {
+		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		filelayout_reset_read(task, rdata);
+		rpc_restart_call_prepare(task);
+		return;
+	}
 	rdata->read_done_cb = filelayout_read_done_cb;
 
 	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
@@ -341,6 +347,12 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
 
+	if (filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(wdata->lseg))) {
+		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		filelayout_reset_write(task, wdata);
+		rpc_restart_call_prepare(task);
+		return;
+	}
 	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
 				&wdata->args.seq_args, &wdata->res.seq_res,
 				task))
@@ -372,6 +384,18 @@ static void filelayout_write_release(void *data)
 	wdata->mds_ops->rpc_release(data);
 }
 
+static void filelayout_commit_prepare(struct rpc_task *task, void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
+				&wdata->args.seq_args, &wdata->res.seq_res,
+				task))
+		return;
+
+	rpc_call_start(task);
+}
+
 static void filelayout_commit_release(void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
@@ -398,7 +422,7 @@ static const struct rpc_call_ops filelayout_write_call_ops = {
 };
 
 static const struct rpc_call_ops filelayout_commit_call_ops = {
-	.rpc_call_prepare = filelayout_write_prepare,
+	.rpc_call_prepare = filelayout_commit_prepare,
 	.rpc_call_done = filelayout_write_call_done,
 	.rpc_count_stats = filelayout_write_count_stats,
 	.rpc_release = filelayout_commit_release,
-- 
1.7.6.4

