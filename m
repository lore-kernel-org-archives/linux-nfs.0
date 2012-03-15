Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032108Ab2COSlC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 14:41:02 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 1 07/11] NFSv4.1 Check invalid deviceid upon slot table waitq wakeup
Date: Thu, 15 Mar 2012 14:40:46 -0400
Message-Id: <1331836850-5195-8-git-send-email-andros@netapp.com>
In-Reply-To: <1331836850-5195-1-git-send-email-andros@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Register a new filelayout DS rpc_action callback for sleeping on the fore
channel slot table waitq.  Avoid any additional RPC FSM states
(such as timeout) when waking up to an invalid deviceid and reset
the task for io to the MDS.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   26 ++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c       |    4 ++--
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 26c83b0..8531161 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -232,6 +232,18 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
 		(unsigned long) NFS_I(wdata->inode)->layout->plh_lwb);
 }
 
+static void filelayout_read_sleepon_cb(struct rpc_task *task)
+{
+	struct nfs_read_data *rd = (struct nfs_read_data *)task->tk_calldata;
+
+	if (rd->lseg &&
+	    filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(rd->lseg))) {
+		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		filelayout_reset_read(task, rd);
+		rpc_restart_call_prepare(task);
+	}
+}
+
 /*
  * Call ops for the async read/write cases
  * In the case of dense layouts, the offset needs to be reset to its
@@ -241,6 +253,7 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
+	rdata->args.seq_args.sa_action = &filelayout_read_sleepon_cb;
 	rdata->read_done_cb = filelayout_read_done_cb;
 
 	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
@@ -336,10 +349,23 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 	return 0;
 }
 
+static void filelayout_write_sleepon_cb(struct rpc_task *task)
+{
+	struct nfs_write_data *wd = (struct nfs_write_data *)task->tk_calldata;
+
+	if (wd->lseg &&
+	    filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(wd->lseg))) {
+		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
+		filelayout_reset_write(task, wd);
+		rpc_restart_call_prepare(task);
+	}
+}
+
 static void filelayout_write_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
 
+	wdata->args.seq_args.sa_action = &filelayout_write_sleepon_cb;
 	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
 				&wdata->args.seq_args, &wdata->res.seq_res,
 				task))
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 45b67d8..e5e651e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -590,7 +590,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 
 	if (!rpc_queue_empty(&tbl->slot_tbl_waitq) &&
 	    !rpc_task_has_priority(task, RPC_PRIORITY_PRIVILEGED)) {
-		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+		rpc_sleep_on(&tbl->slot_tbl_waitq, task, args->sa_action);
 		spin_unlock(&tbl->slot_tbl_lock);
 		dprintk("%s enforce FIFO order\n", __func__);
 		return -EAGAIN;
@@ -598,7 +598,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 
 	slotid = nfs4_find_slot(tbl);
 	if (slotid == NFS4_NO_SLOT) {
-		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+		rpc_sleep_on(&tbl->slot_tbl_waitq, task, args->sa_action);
 		spin_unlock(&tbl->slot_tbl_lock);
 		dprintk("<-- %s: no free slots\n", __func__);
 		return -EAGAIN;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c1cf86c..2d86f6e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -182,6 +182,7 @@ struct nfs4_slot {
 
 struct nfs4_sequence_args {
 	struct nfs4_session	*sa_session;
+	rpc_action		sa_action;	/* for slot_tbl_waitq wakeup */
 	u32			sa_slotid;
 	u8			sa_cache_this;
 };
-- 
1.7.6.4

