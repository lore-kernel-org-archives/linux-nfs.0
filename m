Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36842 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755060Ab2D0Vpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:35 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 08/13] NFSv4.1 Check invalid deviceid upon slot table waitq wakeup
Date: Fri, 27 Apr 2012 17:53:48 -0400
Message-Id: <1335563633-7191-9-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Tasks sleeping on the slot table waitq wake to the rpc_prepare_task state.
Reset the task for io through the MDS if the deviceid is invalid.

The reset functions put the io pages through the pageio layer which has the
advantage of re-coalescing which allows for the MDS and DS having different
r/wsizes. Exit the awakened task without executing the rpc_call_done routine.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index f503cbe5..1b9bedb 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -252,7 +252,14 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
 static void filelayout_read_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = data;
+	struct pnfs_layout_segment *lseg = rdata->header->lseg;
 
+	if (filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(lseg))) {
+		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		filelayout_reset_read(rdata);
+		rpc_exit(task, 0);
+		return;
+	}
 	rdata->read_done_cb = filelayout_read_done_cb;
 
 	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
@@ -269,6 +276,9 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
+	if (test_bit(NFS_IOHDR_REDO, &rdata->header->flags))
+		return;
+
 	/* Note this may cause RPC to be resent */
 	rdata->header->mds_ops->rpc_call_done(task, data);
 }
@@ -343,7 +353,14 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 static void filelayout_write_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = data;
+	struct pnfs_layout_segment *lseg = wdata->header->lseg;
 
+	if (filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(lseg))) {
+		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		filelayout_reset_write(wdata);
+		rpc_exit(task, 0);
+		return;
+	}
 	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
 				&wdata->args.seq_args, &wdata->res.seq_res,
 				task))
@@ -356,6 +373,9 @@ static void filelayout_write_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = data;
 
+	if (test_bit(NFS_IOHDR_REDO, &wdata->header->flags))
+		return;
+
 	/* Note this may cause RPC to be resent */
 	wdata->header->mds_ops->rpc_call_done(task, data);
 }
-- 
1.7.6.4

