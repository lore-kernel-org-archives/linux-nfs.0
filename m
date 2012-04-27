Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36842 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754871Ab2D0Vpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:34 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 06/13] NFSv4.1: mark deviceid invalid on filelayout DS connection errors
Date: Fri, 27 Apr 2012 17:53:46 -0400
Message-Id: <1335563633-7191-7-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This prevents the use of any layout for i/o that references the deviceid.
I/O is redirected through the MDS.

Redirect the unhandled failed I/O to the MDS without marking either the
layout or the deviceid invalid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |  130 +++++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4filelayout.h |    3 +
 fs/nfs/pnfs.c           |    6 ++-
 fs/nfs/pnfs.h           |    4 ++
 4 files changed, 108 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 0db8c07..f503cbe5 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -82,29 +82,77 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 	BUG();
 }
 
+static void filelayout_reset_write(struct nfs_write_data *data)
+{
+	struct nfs_pgio_header *hdr = data->header;
+	struct inode *inode = hdr->inode;
+	struct rpc_task *task = &data->task;
+
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		dprintk("%s Reset task %5u for i/o through MDS "
+			"(req %s/%lld, %u bytes @ offset %llu)\n", __func__,
+			data->task.tk_pid,
+			inode->i_sb->s_id,
+			(long long)NFS_FILEID(inode),
+			data->args.count,
+			(unsigned long long)data->args.offset);
+
+		task->tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
+							&hdr->pages,
+							hdr->completion_ops);
+	}
+}
+
+static void filelayout_reset_read(struct nfs_read_data *data)
+{
+	struct nfs_pgio_header *hdr = data->header;
+	struct inode *inode = hdr->inode;
+	struct rpc_task *task = &data->task;
+
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
+		dprintk("%s Reset task %5u for i/o through MDS "
+			"(req %s/%lld, %u bytes @ offset %llu)\n", __func__,
+			data->task.tk_pid,
+			inode->i_sb->s_id,
+			(long long)NFS_FILEID(inode),
+			data->args.count,
+			(unsigned long long)data->args.offset);
+
+		task->tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
+							&hdr->pages,
+							hdr->completion_ops);
+	}
+}
+
 static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs4_state *state,
 					 struct nfs_client *clp,
-					 int *reset)
+					 struct pnfs_layout_segment *lseg)
 {
-	struct nfs_server *mds_server = NFS_SERVER(state->inode);
+	struct inode *inode = lseg->pls_layout->plh_inode;
+	struct nfs_server *mds_server = NFS_SERVER(inode);
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	struct nfs_client *mds_client = mds_server->nfs_client;
 
 	if (task->tk_status >= 0)
 		return 0;
-	*reset = 0;
 
 	switch (task->tk_status) {
 	/* MDS state errors */
 	case -NFS4ERR_DELEG_REVOKED:
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_BAD_STATEID:
+		if (state == NULL)
+			break;
 		nfs_remove_bad_delegation(state->inode);
 	case -NFS4ERR_OPENMODE:
+		if (state == NULL)
+			break;
 		nfs4_schedule_stateid_recovery(mds_server, state);
 		goto wait_on_recovery;
 	case -NFS4ERR_EXPIRED:
-		nfs4_schedule_stateid_recovery(mds_server, state);
+		if (state != NULL)
+			nfs4_schedule_stateid_recovery(mds_server, state);
 		nfs4_schedule_lease_recovery(mds_client);
 		goto wait_on_recovery;
 	/* DS session errors */
@@ -127,11 +175,22 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		break;
 	case -NFS4ERR_RETRY_UNCACHED_REP:
 		break;
+	/* RPC connection errors */
+	case -ECONNREFUSED:
+	case -EHOSTDOWN:
+	case -EHOSTUNREACH:
+	case -ENETUNREACH:
+	case -EIO:
+	case -ETIMEDOUT:
+	case -EPIPE:
+		dprintk("%s DS connection error %d\n", __func__,
+			task->tk_status);
+		filelayout_mark_devid_invalid(devid);
+		/* fall through */
 	default:
-		dprintk("%s DS error. Retry through MDS %d\n", __func__,
+		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
-		*reset = 1;
-		break;
+		return -NFS4ERR_RESET_TO_MDS;
 	}
 out:
 	task->tk_status = 0;
@@ -148,16 +207,17 @@ wait_on_recovery:
 static int filelayout_read_done_cb(struct rpc_task *task,
 				struct nfs_read_data *data)
 {
-	int reset = 0;
+	struct nfs_pgio_header *hdr = data->header;
+	int err;
 
-	dprintk("%s DS read\n", __func__);
+	err = filelayout_async_handle_error(task, data->args.context->state,
+					    data->ds_clp, hdr->lseg);
 
-	if (filelayout_async_handle_error(task, data->args.context->state,
-					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
-			nfs4_reset_read(task, data);
+	switch (err) {
+	case -NFS4ERR_RESET_TO_MDS:
+		filelayout_reset_read(data);
+		return task->tk_status;
+	case -EAGAIN:
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -230,14 +290,17 @@ static void filelayout_read_release(void *data)
 static int filelayout_write_done_cb(struct rpc_task *task,
 				struct nfs_write_data *data)
 {
-	int reset = 0;
-
-	if (filelayout_async_handle_error(task, data->args.context->state,
-					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
-			nfs4_reset_write(task, data);
+	struct nfs_pgio_header *hdr = data->header;
+	int err;
+
+	err = filelayout_async_handle_error(task, data->args.context->state,
+					    data->ds_clp, hdr->lseg);
+
+	switch (err) {
+	case -NFS4ERR_RESET_TO_MDS:
+		filelayout_reset_write(data);
+		return task->tk_status;
+	case -EAGAIN:
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -260,16 +323,17 @@ static void prepare_to_resend_writes(struct nfs_commit_data *data)
 static int filelayout_commit_done_cb(struct rpc_task *task,
 				     struct nfs_commit_data *data)
 {
-	int reset = 0;
-
-	if (filelayout_async_handle_error(task, data->context->state,
-					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
-			prepare_to_resend_writes(data);
-		else
-			rpc_restart_call_prepare(task);
+	int err;
+
+	err = filelayout_async_handle_error(task, NULL, data->ds_clp,
+					    data->lseg);
+
+	switch (err) {
+	case -NFS4ERR_RESET_TO_MDS:
+		prepare_to_resend_writes(data);
+		return -EAGAIN;
+	case -EAGAIN:
+		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 6fb1901..3259be6 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -48,6 +48,9 @@
 #define NFS4_PNFS_MAX_STRIPE_CNT 4096
 #define NFS4_PNFS_MAX_MULTI_CNT  256 /* 256 fit into a u8 stripe_index */
 
+/* error codes for internal use */
+#define NFS4ERR_RESET_TO_MDS   12001
+
 enum stripetype4 {
 	STRIPE_SPARSE = 1,
 	STRIPE_DENSE = 2
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 463eb2f..78fd7eb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1175,7 +1175,7 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
-static int pnfs_write_done_resend_to_mds(struct inode *inode,
+int pnfs_write_done_resend_to_mds(struct inode *inode,
 				struct list_head *head,
 				const struct nfs_pgio_completion_ops *compl_ops)
 {
@@ -1203,6 +1203,7 @@ static int pnfs_write_done_resend_to_mds(struct inode *inode,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(pnfs_write_done_resend_to_mds);
 
 static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
 {
@@ -1330,7 +1331,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 
-static int pnfs_read_done_resend_to_mds(struct inode *inode,
+int pnfs_read_done_resend_to_mds(struct inode *inode,
 				struct list_head *head,
 				const struct nfs_pgio_completion_ops *compl_ops)
 {
@@ -1354,6 +1355,7 @@ static int pnfs_read_done_resend_to_mds(struct inode *inode,
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(pnfs_read_done_resend_to_mds);
 
 static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8efbee7..681875d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -222,6 +222,10 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       gfp_t gfp_flags);
 
 void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
+int pnfs_read_done_resend_to_mds(struct inode *inode, struct list_head *head,
+			const struct nfs_pgio_completion_ops *compl_ops);
+int pnfs_write_done_resend_to_mds(struct inode *inode, struct list_head *head,
+			const struct nfs_pgio_completion_ops *compl_ops);
 
 /* nfs4_deviceid_flags */
 enum {
-- 
1.7.6.4

