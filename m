Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58884 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228Ab1BPSjQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 13:39:16 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pNFS wave 3 Version 2 15/18] NFSv4.1: filelayout async error handler
Date: Tue, 15 Feb 2011 03:39:00 -0500
Message-Id: <1297759143-2045-16-git-send-email-andros@netapp.com>
In-Reply-To: <1297759143-2045-1-git-send-email-andros@netapp.com>
References: <1297759143-2045-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Use our own async error handler.
Mark the layout as failed and retry i/o through the MDS on specified errors.

Update the mds_offset in nfs_readpage_retry so that a failed short-read retry
to a DS gets correctly resent through the MDS.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h           |    1 +
 fs/nfs/nfs4filelayout.c     |   79 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c           |   33 +++++++++++++++---
 fs/nfs/nfs4state.c          |    1 +
 fs/nfs/read.c               |    1 +
 include/linux/nfs_xdr.h     |    1 +
 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/clnt.c           |    8 ++++
 8 files changed, 119 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5e9df99..1a3228e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -285,6 +285,7 @@ extern int nfs_migrate_page(struct address_space *,
 #endif
 
 /* nfs4proc.c */
+extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
 extern int nfs4_init_client(struct nfs_client *clp,
 			    const struct rpc_timeout *timeparms,
 			    const char *ip_addr,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index f421ef0..9ae1a47e 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -40,6 +40,8 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Dean Hildebrand <dhildebz@umich.edu>");
 MODULE_DESCRIPTION("The NFSv4 file layout driver");
 
+#define FILELAYOUT_POLL_RETRY_MAX     (15*HZ)
+
 static int
 filelayout_set_layoutdriver(struct nfs_server *nfss)
 {
@@ -100,6 +102,81 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 	BUG();
 }
 
+/* For data server errors we don't recover from */
+static void
+filelayout_set_lo_fail(struct pnfs_layout_segment *lseg)
+{
+	if (lseg->pls_range.iomode == IOMODE_RW) {
+		dprintk("%s Setting layout IOMODE_RW fail bit\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
+	} else {
+		dprintk("%s Setting layout IOMODE_READ fail bit\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
+	}
+}
+
+static int filelayout_async_handle_error(struct rpc_task *task,
+					 struct nfs4_state *state,
+					 struct nfs_client *clp,
+					 int *reset)
+{
+	if (task->tk_status >= 0)
+		return 0;
+	switch (task->tk_status) {
+	case -NFS4ERR_BADSESSION:
+	case -NFS4ERR_BADSLOT:
+	case -NFS4ERR_BAD_HIGH_SLOT:
+	case -NFS4ERR_DEADSESSION:
+	case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+	case -NFS4ERR_SEQ_FALSE_RETRY:
+	case -NFS4ERR_SEQ_MISORDERED:
+		dprintk("%s ERROR %d, Reset session. Exchangeid "
+			"flags 0x%x\n", __func__, task->tk_status,
+			clp->cl_exchange_flags);
+		nfs4_schedule_state_recovery(clp);
+		task->tk_status = 0;
+		return -EAGAIN;
+	case -NFS4ERR_DELAY:
+	case -NFS4ERR_GRACE:
+	case -EKEYEXPIRED:
+		rpc_delay(task, FILELAYOUT_POLL_RETRY_MAX);
+		task->tk_status = 0;
+		return -EAGAIN;
+	default:
+		dprintk("%s DS error. Retry through MDS %d\n", __func__,
+			task->tk_status);
+		*reset = 1;
+		task->tk_status = 0;
+		return -EAGAIN;
+	}
+}
+
+/* NFS_PROTO call done callback routines */
+
+static int filelayout_read_done_cb(struct rpc_task *task,
+				struct nfs_read_data *data)
+{
+	struct nfs_client *clp = data->ds_clp;
+	int reset = 0;
+
+	dprintk("%s DS read\n", __func__);
+
+	if (filelayout_async_handle_error(task, data->args.context->state,
+					  data->ds_clp, &reset) == -EAGAIN) {
+		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
+			__func__, data->ds_clp, data->ds_clp->cl_session);
+		if (reset) {
+			nfs4_reset_read(task, data);
+			filelayout_set_lo_fail(data->lseg);
+			clp = NFS_SERVER(data->inode)->nfs_client;
+		}
+		nfs_restart_rpc(task, clp);
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
 /*
  * Call ops for the async read/write cases
  * In the case of dense layouts, the offset needs to be reset to its
@@ -109,6 +186,8 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
+	rdata->read_done_cb = filelayout_read_done_cb;
+
 	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
 				&rdata->args.seq_args, &rdata->res.seq_res,
 				0, task))
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 64fb39b..f91e259 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3075,15 +3075,10 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 	return err;
 }
 
-static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
+static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
-	dprintk("--> %s\n", __func__);
-
-	if (!nfs4_sequence_done(task, &data->res.seq_res))
-		return -EAGAIN;
-
 	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
 		nfs_restart_rpc(task, server->nfs_client);
 		return -EAGAIN;
@@ -3095,12 +3090,38 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	return 0;
 }
 
+static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
+{
+
+	dprintk("--> %s\n", __func__);
+
+	if (!nfs4_sequence_done(task, &data->res.seq_res))
+		return -EAGAIN;
+
+	return data->read_done_cb(task, data);
+}
+
 static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
 {
 	data->timestamp   = jiffies;
+	data->read_done_cb = nfs4_read_done_cb;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
 }
 
+/* Reset the the nfs_read_data to send the read to the MDS. */
+void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
+{
+	dprintk("%s Reset task for i/o through\n", __func__);
+	/* offsets will differ in the dense stripe case */
+	data->args.offset = data->mds_offset;
+	data->ds_clp = NULL;
+	data->args.fh     = NFS_FH(data->inode);
+	data->read_done_cb = nfs4_read_done_cb;
+	task->tk_ops = data->mds_ops;
+	rpc_task_reset_client(task, NFS_CLIENT(data->inode));
+}
+EXPORT_SYMBOL_GPL(nfs4_reset_read);
+
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 9e33e88..6da026a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1022,6 +1022,7 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 	nfs4_schedule_state_manager(clp);
 }
+EXPORT_SYMBOL_GPL(nfs4_schedule_state_recovery);
 
 int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
 {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 5fc4ecc..5c5fbac 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -395,6 +395,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 		return;
 
 	/* Yes, so retry the read at the end of the data */
+	data->mds_offset += resp->count;
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b63faef..eb0e870 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1020,6 +1020,7 @@ struct nfs_read_data {
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 	const struct rpc_call_ops *mds_ops;
+	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
 	__u64			mds_offset;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index ef9476a..db7bcaf 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -129,6 +129,7 @@ struct rpc_create_args {
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
 				struct rpc_program *, u32);
+void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt);
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 57d344c..5c4df70 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -597,6 +597,14 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 	}
 }
 
+void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt)
+{
+	rpc_task_release_client(task);
+	rpc_task_set_client(task, clnt);
+}
+EXPORT_SYMBOL_GPL(rpc_task_reset_client);
+
+
 static void
 rpc_task_set_rpc_message(struct rpc_task *task, const struct rpc_message *msg)
 {
-- 
1.7.2.3

