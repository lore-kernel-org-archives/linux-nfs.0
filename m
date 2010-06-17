From: andros@netapp.com
Subject: [PATCH 4/7] pnfs-submit: merge sync and async layoutcommit
Date: Thu, 17 Jun 2010 15:34:53 -0400
Message-ID: <1276803296-9438-5-git-send-email-andros@netapp.com>
References: <1276803296-9438-1-git-send-email-andros@netapp.com>
 <1276803296-9438-2-git-send-email-andros@netapp.com>
 <1276803296-9438-3-git-send-email-andros@netapp.com>
 <1276803296-9438-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56790 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760233Ab0FQTfc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 15:35:32 -0400
In-Reply-To: <1276803296-9438-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c        |   80 ++++++++++++++++------------------------------
 fs/nfs/pnfs.c            |   11 +++---
 fs/nfs/pnfs.h            |    3 +-
 include/linux/pnfs_xdr.h |    1 -
 4 files changed, 35 insertions(+), 60 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1269689..71cb928 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5603,46 +5603,6 @@ out:
 	return status;
 }
 
-static int _pnfs4_sync_layoutcommit(struct pnfs_layoutcommit_data *data)
-{
-	struct inode *inode = data->args.inode;
-	struct nfs_fattr *fattr = data->res.fattr;
-	struct nfs_server *server = NFS_SERVER(inode);
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT],
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = data->cred,
-	};
-	int status;
-
-	dprintk("NFS call layoutcommit %lld @ %lld\n",
-		data->args.lseg.length, data->args.lseg.offset);
-
-	nfs_fattr_init(fattr);
-	status = nfs4_call_sync(server, &msg, &data->args, &data->res, 0);
-	dprintk("NFS reply layoutcommit: %d\n", status);
-
-	return status;
-}
-
-static int pnfs4_sync_layoutcommit(struct pnfs_layoutcommit_data *data)
-{
-	struct nfs4_exception exception = { };
-	int err;
-
-	do {
-		err = nfs4_handle_exception(NFS_SERVER(data->args.inode),
-					_pnfs4_sync_layoutcommit(data),
-					&exception);
-	} while (exception.retry);
-
-	data->status = err;
-	put_rpccred(data->cred);
-	pnfs_layoutcommit_free(data);
-	return err;
-}
-
 static void pnfs_layoutcommit_prepare(struct rpc_task *task, void *data)
 {
 	struct pnfs_layoutcommit_data *ldata =
@@ -5656,14 +5616,13 @@ static void pnfs_layoutcommit_prepare(struct rpc_task *task, void *data)
 }
 
 static void
-pnfs_layoutcommit_rpc_done(struct rpc_task *task, void *calldata)
+pnfs_layoutcommit_done(struct rpc_task *task, void *calldata)
 {
 	struct pnfs_layoutcommit_data *data =
 		(struct pnfs_layoutcommit_data *)calldata;
 	struct nfs_server *server = NFS_SERVER(data->args.inode);
 
 	data->status = task->tk_status;
-	put_rpccred(data->cred);
 
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 
@@ -5673,18 +5632,22 @@ pnfs_layoutcommit_rpc_done(struct rpc_task *task, void *calldata)
 
 static void pnfs_layoutcommit_release(void *lcdata)
 {
+	struct pnfs_layoutcommit_data *data =
+		(struct pnfs_layoutcommit_data *)lcdata;
+
+	put_rpccred(data->cred);
 	pnfs_layoutcommit_free(lcdata);
 }
 
 static const struct rpc_call_ops pnfs_layoutcommit_ops = {
 	.rpc_call_prepare = pnfs_layoutcommit_prepare,
-	.rpc_call_done = pnfs_layoutcommit_rpc_done,
+	.rpc_call_done = pnfs_layoutcommit_done,
 	.rpc_release = pnfs_layoutcommit_release,
 };
 
 /* Execute a layoutcommit to the server */
 static int
-pnfs_async_layoutcommit(struct pnfs_layoutcommit_data *data)
+_pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data, int issync)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT],
@@ -5701,30 +5664,43 @@ pnfs_async_layoutcommit(struct pnfs_layoutcommit_data *data)
 		.flags = RPC_TASK_ASYNC,
 	};
 	struct rpc_task *task;
+	int status = 0;
 
 	dprintk("NFS: %4d initiating layoutcommit call. %llu@%llu lbw: %llu "
-		"type: %d\n",
+		"type: %d issync %d\n",
 		data->task.tk_pid,
 		data->args.lseg.length,
 		data->args.lseg.offset,
 		data->args.lastbytewritten,
-		data->args.layout_type);
+		data->args.layout_type, issync);
 
 	data->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	dprintk("%s: rpc_run_task returned error %ld\n",
-		__func__, PTR_ERR(task));
+	if (!issync)
+		goto out;
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0)
+		goto out;
+	status = data->status;
+out:
+	dprintk("%s: status %d\n", __func__, status);
 	rpc_put_task(task);
 	return 0;
 }
 
-int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data)
+int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data, int issync)
 {
-	return data->is_sync ?
-			pnfs4_sync_layoutcommit(data) :
-			pnfs_async_layoutcommit(data);
+	struct nfs4_exception exception = { };
+	int err;
+
+	do {
+		err = nfs4_handle_exception(NFS_SERVER(data->args.inode),
+					_pnfs4_proc_layoutcommit(data, issync),
+					&exception);
+	} while (exception.retry);
+	return err;
 }
 
 static void
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e19e9be..a2754aa 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1560,14 +1560,13 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 static int
 pnfs_layoutcommit_setup(struct inode *inode,
 			struct pnfs_layoutcommit_data *data,
-			loff_t write_begin_pos, loff_t write_end_pos, int sync)
+			loff_t write_begin_pos, loff_t write_end_pos)
 {
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	int result = 0;
 
-	dprintk("%s Begin (sync:%d)\n", __func__, sync);
+	dprintk("--> %s\n", __func__);
 
-	data->is_sync = sync;
 	data->args.inode = inode;
 	data->args.fh = NFS_FH(inode);
 	data->args.layout_type = nfss->pnfs_curr_ld->id;
@@ -1587,7 +1586,7 @@ pnfs_layoutcommit_setup(struct inode *inode,
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
 
-	dprintk("%s End Status %d\n", __func__, result);
+	dprintk("<-- %s Status %d\n", __func__, result);
 	return result;
 }
 
@@ -1632,13 +1631,13 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 
 	/* Set up layout commit args */
 	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
-					 write_end_pos, sync);
+					 write_end_pos);
 	if (status) {
 		/* The layout driver failed to setup the layoutcommit */
 		put_rpccred(data->cred);
 		goto out_free;
 	}
-	status = pnfs4_proc_layoutcommit(data);
+	status = pnfs4_proc_layoutcommit(data, sync);
 out:
 	dprintk("%s end (err:%d)\n", __func__, status);
 	return status;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 07552d5..78776f3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -25,7 +25,8 @@
 extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
-extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data);
+extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data,
+				   int issync);
 extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait);
 
 /* pnfs.c */
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 154b04e..d3d0d78 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -83,7 +83,6 @@ struct pnfs_layoutcommit_res {
 
 struct pnfs_layoutcommit_data {
 	struct rpc_task task;
-	bool is_sync;
 	struct rpc_cred *cred;
 	struct nfs_fattr fattr;
 	struct pnfs_layoutcommit_arg args;
-- 
1.6.6

