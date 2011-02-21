Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30383 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754648Ab1BURto (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Feb 2011 12:49:44 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 7/7] NFSv4.1: pnfs filelayout driver write
Date: Mon, 21 Feb 2011 12:49:36 -0500
Message-Id: <1298310576-13523-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
References: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Allows the pnfs filelayout driver to write to the data servers.

Note that COMMIT to data servers will be implemented in a future
patch.  To avoid improper behavior, for the moment any WRITE to a data
server that would also require a COMMIT to the data server is sent
NFS_FILE_SYNC.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/internal.h       |    5 ++
 fs/nfs/nfs4filelayout.c |   99 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c       |   17 ++++++++
 fs/nfs/write.c          |    5 ++-
 include/linux/nfs_xdr.h |    2 +
 5 files changed, 126 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1a3228e..d1ddc23 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -276,6 +276,10 @@ extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
+extern int nfs_initiate_write(struct nfs_write_data *data,
+			      struct rpc_clnt *clnt,
+			      const struct rpc_call_ops *call_ops,
+			      int how);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
@@ -291,6 +295,7 @@ extern int nfs4_init_client(struct nfs_client *clp,
 			    const char *ip_addr,
 			    rpc_authflavor_t authflavour,
 			    int noresvport);
+extern void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data);
 extern int _nfs4_call_sync(struct nfs_server *server,
 			   struct rpc_message *msg,
 			   struct nfs4_sequence_args *args,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 553adea..bfd30de 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -189,12 +189,69 @@ static void filelayout_read_release(void *data)
 	rdata->mds_ops->rpc_release(data);
 }
 
+static int filelayout_write_done_cb(struct rpc_task *task,
+				struct nfs_write_data *data)
+{
+	int reset = 0;
+
+	if (filelayout_async_handle_error(task, data->args.context->state,
+					  data->ds_clp, &reset) == -EAGAIN) {
+		struct nfs_client *clp;
+
+		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
+			__func__, data->ds_clp, data->ds_clp->cl_session);
+		if (reset) {
+			nfs4_reset_write(task, data);
+			filelayout_set_lo_fail(data->lseg);
+			clp = NFS_SERVER(data->inode)->nfs_client;
+		} else
+			clp = data->ds_clp;
+		nfs_restart_rpc(task, clp);
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
+static void filelayout_write_prepare(struct rpc_task *task, void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
+				&wdata->args.seq_args, &wdata->res.seq_res,
+				0, task))
+		return;
+
+	rpc_call_start(task);
+}
+
+static void filelayout_write_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	/* Note this may cause RPC to be resent */
+	wdata->mds_ops->rpc_call_done(task, data);
+}
+
+static void filelayout_write_release(void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	wdata->mds_ops->rpc_release(data);
+}
+
 struct rpc_call_ops filelayout_read_call_ops = {
 	.rpc_call_prepare = filelayout_read_prepare,
 	.rpc_call_done = filelayout_read_call_done,
 	.rpc_release = filelayout_read_release,
 };
 
+struct rpc_call_ops filelayout_write_call_ops = {
+	.rpc_call_prepare = filelayout_write_prepare,
+	.rpc_call_done = filelayout_write_call_done,
+	.rpc_release = filelayout_write_release,
+};
+
 static enum pnfs_try_status
 filelayout_read_pagelist(struct nfs_read_data *data)
 {
@@ -236,10 +293,50 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	return PNFS_ATTEMPTED;
 }
 
+/* Perform async writes. */
 static enum pnfs_try_status
 filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 {
-	return PNFS_NOT_ATTEMPTED;
+	struct pnfs_layout_segment *lseg = data->lseg;
+	struct nfs4_pnfs_ds *ds;
+	loff_t offset = data->args.offset;
+	u32 j, idx;
+	struct nfs_fh *fh;
+
+	/* Retrieve the correct rpc_client for the byte range */
+	j = nfs4_fl_calc_j_index(lseg, offset);
+	idx = nfs4_fl_calc_ds_index(lseg, j);
+	ds = nfs4_fl_prepare_ds(lseg, idx);
+	if (!ds) {
+		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
+		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
+		return PNFS_NOT_ATTEMPTED;
+	}
+	dprintk("%s ino %lu sync %d req %Zu@%llu DS:%x:%hu\n", __func__,
+		data->inode->i_ino, sync, (size_t) data->args.count, offset,
+		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
+
+	/* We can't handle commit to ds yet */
+	if (!FILELAYOUT_LSEG(lseg)->commit_through_mds)
+		data->args.stable = NFS_FILE_SYNC;
+
+	data->write_done_cb = filelayout_write_done_cb;
+	data->ds_clp = ds->ds_clp;
+	fh = nfs4_fl_select_ds_fh(lseg, j);
+	if (fh)
+		data->args.fh = fh;
+	/*
+	 * Get the file offset on the dserver. Set the write offset to
+	 * this offset and save the original offset.
+	 */
+	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
+	data->mds_offset = offset;
+
+	/* Perform an asynchronous write */
+	nfs_initiate_write(data, ds->ds_clp->cl_rpcclient,
+			   &filelayout_write_call_ops, sync);
+	return PNFS_ATTEMPTED;
 }
 
 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4ec34e2..c2ba9c4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3144,6 +3144,23 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	return data->write_done_cb(task, data);
 }
 
+/* Reset the the nfs_write_data to send the write to the MDS. */
+void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data)
+{
+	dprintk("%s Reset task for i/o through\n", __func__);
+	put_lseg(data->lseg);
+	data->lseg          = NULL;
+	data->ds_clp        = NULL;
+	data->write_done_cb = nfs4_write_done_cb;
+	data->args.fh       = NFS_FH(data->inode);
+	data->args.bitmask  = data->res.server->cache_consistency_bitmask;
+	data->args.offset   = data->mds_offset;
+	data->res.fattr     = &data->fattr;
+	task->tk_ops        = data->mds_ops;
+	rpc_task_reset_client(task, NFS_CLIENT(data->inode));
+}
+EXPORT_SYMBOL_GPL(nfs4_reset_write);
+
 static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b6b683d..a10f120 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -783,7 +783,7 @@ static int flush_task_priority(int how)
 	return RPC_PRIORITY_NORMAL;
 }
 
-static int nfs_initiate_write(struct nfs_write_data *data,
+int nfs_initiate_write(struct nfs_write_data *data,
 		       struct rpc_clnt *clnt,
 		       const struct rpc_call_ops *call_ops,
 		       int how)
@@ -833,6 +833,7 @@ static int nfs_initiate_write(struct nfs_write_data *data,
 out:
 	return ret;
 }
+EXPORT_SYMBOL(nfs_initiate_write);
 
 /*
  * Set up the argument/result storage required for the RPC call.
@@ -1194,6 +1195,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		 */
 		static unsigned long    complain;
 
+		/* Note this will print the MDS for a DS write */
 		if (time_before(complain, jiffies)) {
 			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
@@ -1214,6 +1216,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 			/* Was this an NFSv2 write or an NFSv3 stable write? */
 			if (resp->verf->committed != NFS_UNSTABLE) {
 				/* Resend from where the server left off */
+				data->mds_offset += resp->count;
 				argp->offset += resp->count;
 				argp->pgbase += resp->count;
 				argp->count -= resp->count;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c82ad33..3440f5a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1039,11 +1039,13 @@ struct nfs_write_data {
 	struct nfs_writeargs	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
 	struct pnfs_layout_segment *lseg;
+	struct nfs_client	*ds_clp;	/* pNFS data server */
 	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 #ifdef CONFIG_NFS_V4
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
+	__u64			mds_offset;	/* Filelayout dense stripe */
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.7.2.1

