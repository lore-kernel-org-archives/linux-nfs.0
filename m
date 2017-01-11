Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:48676 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752415AbdAKUQ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 15:16:29 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] NFS: Remove nfs4_wait_for_completion_rpc_task()
Date: Wed, 11 Jan 2017 15:15:05 -0500
Message-ID: <20170111201506.3736-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fba6d108179b..e2f5407a66d1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1313,14 +1313,6 @@ static void nfs4_opendata_put(struct nfs4_opendata *p)
 		kref_put(&p->kref, nfs4_opendata_free);
 }
 
-static int nfs4_wait_for_completion_rpc_task(struct rpc_task *task)
-{
-	int ret;
-
-	ret = rpc_wait_for_completion_task(task);
-	return ret;
-}
-
 static bool nfs4_mode_match_open_stateid(struct nfs4_state *state,
 		fmode_t fmode)
 {
@@ -2107,7 +2099,7 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	if (status != 0) {
 		data->cancelled = 1;
 		smp_wmb();
@@ -2274,7 +2266,7 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 	task = rpc_run_task(&task_setup_data);
         if (IS_ERR(task))
                 return PTR_ERR(task);
-        status = nfs4_wait_for_completion_rpc_task(task);
+        status = rpc_wait_for_completion_task(task);
         if (status != 0) {
                 data->cancelled = 1;
                 smp_wmb();
@@ -5791,7 +5783,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 		return PTR_ERR(task);
 	if (!issync)
 		goto out;
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	if (status != 0)
 		goto out;
 	status = data->rpc_status;
@@ -6061,7 +6053,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	status = PTR_ERR(task);
 	if (IS_ERR(task))
 		goto out;
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 out:
 	request->fl_flags = fl_flags;
@@ -6290,7 +6282,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	ret = nfs4_wait_for_completion_rpc_task(task);
+	ret = rpc_wait_for_completion_task(task);
 	if (ret == 0) {
 		ret = data->rpc_status;
 		if (ret)
@@ -8358,7 +8350,7 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp,
 		status = PTR_ERR(task);
 		goto out;
 	}
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	if (status == 0)
 		status = task->tk_status;
 	rpc_put_task(task);
@@ -8590,7 +8582,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return ERR_CAST(task);
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	if (status == 0) {
 		status = nfs4_layoutget_handle_exception(task, lgp, &exception);
 		*timeout = exception.timeout;
-- 
2.11.0

