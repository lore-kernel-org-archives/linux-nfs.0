Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031675Ab2COSk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 14:40:57 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 1 01/11] NFSv4.1 move nfs4_reset_read and nfs_reset_write
Date: Thu, 15 Mar 2012 14:40:40 -0400
Message-Id: <1331836850-5195-2-git-send-email-andros@netapp.com>
In-Reply-To: <1331836850-5195-1-git-send-email-andros@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Only called by the file layout code

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h       |    5 +++--
 fs/nfs/nfs4filelayout.c |   35 +++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4proc.c       |   39 ++++-----------------------------------
 3 files changed, 40 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 04a9147..44066d9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -344,13 +344,14 @@ extern int nfs_migrate_page(struct address_space *,
 
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
-extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
+extern int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data);
+extern int nfs4_write_done_cb(struct rpc_task *task,
+			      struct nfs_write_data *data);
 extern int nfs4_init_client(struct nfs_client *clp,
 			    const struct rpc_timeout *timeparms,
 			    const char *ip_addr,
 			    rpc_authflavor_t authflavour,
 			    int noresvport);
-extern void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data);
 extern int _nfs4_call_sync(struct rpc_clnt *clnt,
 			   struct nfs_server *server,
 			   struct rpc_message *msg,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 379a085..447c2c9 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -82,6 +82,37 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 	BUG();
 }
 
+/* Reset the the nfs_write_data to send the write to the MDS. */
+void filelayout_reset_write(struct rpc_task *task, struct nfs_write_data *data)
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
+
+/* Reset the the nfs_read_data to send the read to the MDS. */
+void filelayout_reset_read(struct rpc_task *task, struct nfs_read_data *data)
+{
+	dprintk("%s Reset task for i/o through\n", __func__);
+	put_lseg(data->lseg);
+	data->lseg         = NULL;
+	/* offsets will differ in the dense stripe case */
+	data->args.offset  = data->mds_offset;
+	data->ds_clp       = NULL;
+	data->args.fh      = NFS_FH(data->inode);
+	data->read_done_cb = nfs4_read_done_cb;
+	task->tk_ops = data->mds_ops;
+	rpc_task_reset_client(task, NFS_CLIENT(data->inode));
+}
+
 static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs4_state *state,
 					 struct nfs_client *clp,
@@ -158,7 +189,7 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
 			pnfs_set_lo_fail(data->lseg);
-			nfs4_reset_read(task, data);
+			filelayout_reset_read(task, data);
 		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
@@ -238,7 +269,7 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
 			pnfs_set_lo_fail(data->lseg);
-			nfs4_reset_write(task, data);
+			filelayout_reset_write(task, data);
 		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5e0961a..45b67d8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3264,7 +3264,7 @@ void __nfs4_read_done_cb(struct nfs_read_data *data)
 	nfs_invalidate_atime(data->inode);
 }
 
-static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
+int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
@@ -3278,6 +3278,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 		renew_lease(server, data->timestamp);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs4_read_done_cb);
 
 static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
@@ -3299,23 +3300,7 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 }
 
-/* Reset the the nfs_read_data to send the read to the MDS. */
-void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
-{
-	dprintk("%s Reset task for i/o through\n", __func__);
-	put_lseg(data->lseg);
-	data->lseg = NULL;
-	/* offsets will differ in the dense stripe case */
-	data->args.offset = data->mds_offset;
-	data->ds_clp = NULL;
-	data->args.fh     = NFS_FH(data->inode);
-	data->read_done_cb = nfs4_read_done_cb;
-	task->tk_ops = data->mds_ops;
-	rpc_task_reset_client(task, NFS_CLIENT(data->inode));
-}
-EXPORT_SYMBOL_GPL(nfs4_reset_read);
-
-static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data)
+int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
@@ -3329,6 +3314,7 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs4_write_done_cb);
 
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
@@ -3338,23 +3324,6 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 		nfs4_write_done_cb(task, data);
 }
 
-/* Reset the the nfs_write_data to send the write to the MDS. */
-void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data)
-{
-	dprintk("%s Reset task for i/o through\n", __func__);
-	put_lseg(data->lseg);
-	data->lseg          = NULL;
-	data->ds_clp        = NULL;
-	data->write_done_cb = nfs4_write_done_cb;
-	data->args.fh       = NFS_FH(data->inode);
-	data->args.bitmask  = data->res.server->cache_consistency_bitmask;
-	data->args.offset   = data->mds_offset;
-	data->res.fattr     = &data->fattr;
-	task->tk_ops        = data->mds_ops;
-	rpc_task_reset_client(task, NFS_CLIENT(data->inode));
-}
-EXPORT_SYMBOL_GPL(nfs4_reset_write);
-
 static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
-- 
1.7.6.4

