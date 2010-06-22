From: andros@netapp.com
Subject: [PATCH 5/8] SQUASHME pnfs-submit: add error handling to layout return
Date: Tue, 22 Jun 2010 17:56:35 -0400
Message-ID: <1277243798-8181-6-git-send-email-andros@netapp.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com>
 <1277243798-8181-2-git-send-email-andros@netapp.com>
 <1277243798-8181-3-git-send-email-andros@netapp.com>
 <1277243798-8181-4-git-send-email-andros@netapp.com>
 <1277243798-8181-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36643 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811Ab0FVV4g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 17:56:36 -0400
In-Reply-To: <1277243798-8181-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   37 +++++++++++++++++++++++++++----------
 1 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5ffdfe1..0ab875f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5641,6 +5641,11 @@ static void nfs4_pnfs_layoutreturn_done(struct rpc_task *task, void *calldata)
 	dprintk("--> %s\n", __func__);
 
 	nfs4_sequence_done(server, &lrp->res.seq_res, task->tk_status);
+	if (RPC_ASSASSINATED(task))
+		return;
+
+	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
+		nfs_restart_rpc(task, server->nfs_client);
 
 	dprintk("<-- %s\n", __func__);
 }
@@ -5667,7 +5672,7 @@ static const struct rpc_call_ops nfs4_pnfs_layoutreturn_call_ops = {
 	.rpc_release = nfs4_pnfs_layoutreturn_release,
 };
 
-int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait)
+int _pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool issync)
 {
 	struct inode *ino = lrp->args.inode;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -5689,21 +5694,33 @@ int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait)
 	dprintk("--> %s\n", __func__);
 	lrp->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task)) {
-		status = PTR_ERR(task);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	if (!issync)
 		goto out;
-	}
-	if (wait) {
-		status = nfs4_wait_for_completion_rpc_task(task);
-		if (status == 0)
-			status = task->tk_status;
-	}
-	rpc_put_task(task);
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0)
+		goto out;
+	status = task->tk_status;
 out:
 	dprintk("<-- %s\n", __func__);
+	rpc_put_task(task);
 	return status;
 }
 
+int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool issync)
+{
+	struct nfs_server *server = NFS_SERVER(lrp->args.inode);
+	struct nfs4_exception exception = { };
+	int err;
+	do {
+		err = nfs4_handle_exception(server,
+				_pnfs4_proc_layoutreturn(lrp, issync),
+				&exception);
+	} while (exception.retry);
+	return err;
+}
+
 int nfs4_pnfs_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
 	struct nfs4_pnfs_getdeviceinfo_arg args = {
-- 
1.6.6

