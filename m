Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38678 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756872Ab2JIVUg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Oct 2012 17:20:36 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1	do not wake up all tasks on data server reset to MDS
Date: Tue,  9 Oct 2012 17:20:08 -0400
Message-Id: <1349817608-4730-2-git-send-email-andros@netapp.com>
In-Reply-To: <1349817608-4730-1-git-send-email-andros@netapp.com>
References: <1349817608-4730-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

There is no advantage to waking up all rpc tasks on each data server disconnect
or invalid layout error.

For DS disconnect errors where the data server is reseting all I/O to the MDS,
tasks wakened from the fore channel slot table waitq are immediately reset
to use the MDS session, and do not request a data server session slot, and
so do not call nfs41_session_free_slot, and do not wake up the next task on
the data server session fore channel slot table wait queue.

Replace the call to rpc_wake_up which wakes up all tasks with a call to
rpc_wake_up_first in the filelayout I/O prepare routines for the case where
I/O is redirected to the MDS.

Share code with nfs4_check_drain_fc_complete.

Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h       |    1 +
 fs/nfs/nfs4filelayout.c |    5 ++---
 fs/nfs/nfs4proc.c       |   18 +++++++++++++-----
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 59b133c..0b48ce8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -490,6 +490,7 @@ extern int nfs40_walk_client_list(struct nfs_client *clp,
 extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
+extern bool nfs4_wake_up_first(struct nfs4_session *ses);
 
 /*
  * Determine the device name as a string
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 52d8472..d52c7d0 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -131,7 +131,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	struct nfs_server *mds_server = NFS_SERVER(inode);
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	struct nfs_client *mds_client = mds_server->nfs_client;
-	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
 
 	if (task->tk_status >= 0)
 		return 0;
@@ -191,7 +190,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		 * layout is destroyed and a new valid layout is obtained.
 		 */
 		pnfs_destroy_layout(NFS_I(inode));
-		rpc_wake_up(&tbl->slot_tbl_waitq);
 		goto reset;
 	/* RPC connection errors */
 	case -ECONNREFUSED:
@@ -206,7 +204,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		nfs4_mark_deviceid_unavailable(devid);
 		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
 		_pnfs_return_layout(inode);
-		rpc_wake_up(&tbl->slot_tbl_waitq);
 		nfs4_ds_disconnect(clp);
 		/* fall through */
 	default:
@@ -294,6 +291,7 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 	if (filelayout_reset_to_mds(rdata->header->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_read(rdata);
+		nfs4_wake_up_first(rdata->ds_clp->cl_session);
 		rpc_exit(task, 0);
 		return;
 	}
@@ -396,6 +394,7 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 	if (filelayout_reset_to_mds(wdata->header->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_write(wdata);
+		nfs4_wake_up_first(wdata->ds_clp->cl_session);
 		rpc_exit(task, 0);
 		return;
 	}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 68b21d8..f0c0a12 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -438,17 +438,25 @@ bool nfs4_set_task_privileged(struct rpc_task *task, void *dummy)
 	return true;
 }
 
-/*
- * Signal state manager thread if session fore channel is drained
- */
-static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
+bool nfs4_wake_up_first(struct nfs4_session *ses)
 {
 	if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_state)) {
 		rpc_wake_up_first(&ses->fc_slot_table.slot_tbl_waitq,
 				nfs4_set_task_privileged, NULL);
-		return;
+		return true;
 	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(nfs4_wake_up_first);
 
+/*
+ * Signal state manager thread if session fore channel is drained
+ */
+static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
+{
+
+	if (nfs4_wake_up_first(ses))
+		return;
 	if (ses->fc_slot_table.highest_used_slotid != NFS4_NO_SLOT)
 		return;
 
-- 
1.7.7.6

