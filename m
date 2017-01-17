Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:63541 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751166AbdAQUcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:52 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 03/10] NFS: Remove nfs4_wait_for_completion_rpc_task()
Date: Tue, 17 Jan 2017 15:31:58 -0500
Message-ID: <20170117203205.29033-4-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
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
index 00cb8b6c2c70..950e9cd15e5d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1244,14 +1244,6 @@ static void nfs4_opendata_put(struct nfs4_opendata *p)
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
@@ -2038,7 +2030,7 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	if (status != 0) {
 		data->cancelled = 1;
 		smp_wmb();
@@ -2205,7 +2197,7 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	if (status != 0) {
 		data->cancelled = 1;
 		smp_wmb();
@@ -5722,7 +5714,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 		return PTR_ERR(task);
 	if (!issync)
 		goto out;
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	if (status != 0)
 		goto out;
 	status = data->rpc_status;
@@ -5992,7 +5984,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	status = PTR_ERR(task);
 	if (IS_ERR(task))
 		goto out;
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 out:
 	request->fl_flags = fl_flags;
@@ -6221,7 +6213,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	ret = nfs4_wait_for_completion_rpc_task(task);
+	ret = rpc_wait_for_completion_task(task);
 	if (ret == 0) {
 		ret = data->rpc_status;
 		if (ret)
@@ -8289,7 +8281,7 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp,
 		status = PTR_ERR(task);
 		goto out;
 	}
-	status = nfs4_wait_for_completion_rpc_task(task);
+	status = rpc_wait_for_completion_task(task);
 	if (status == 0)
 		status = task->tk_status;
 	rpc_put_task(task);
@@ -8520,7 +8512,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
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

