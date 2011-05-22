Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38902 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab1EVQwX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 12:52:23 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 16/23] pnfs: support for non-rpc layout drivers
Date: Sun, 22 May 2011 19:52:03 +0300
Message-Id: <1306083123-11061-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD93D3E.9010909@panasas.com>
References: <4DD93D3E.9010909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Non-rpc layout driver such as for objects and blocks
implement their own I/O path and error handling logic.
Therefore bypass NFS-based error handling for these layout drivers.

[fix lseg ref-count bugs, and null de-refs]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[get rid of PNFS_USE_RPC_CODE]
[get rid of __nfs4_write_done_cb]
[revert useless change in nfs4_write_done_cb]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h       |    1 +
 fs/nfs/nfs4proc.c       |   13 +++++++++--
 fs/nfs/pnfs.c           |   52 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h           |    2 +
 include/linux/nfs_xdr.h |    2 +
 5 files changed, 66 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ce118ce..bcf0f0f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -310,6 +310,7 @@ extern int nfs_migrate_page(struct address_space *,
 #endif
 
 /* nfs4proc.c */
+extern void __nfs4_read_done_cb(struct nfs_read_data *);
 extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
 extern int nfs4_init_client(struct nfs_client *clp,
 			    const struct rpc_timeout *timeparms,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 69c0f3c..61f30b2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3174,6 +3174,11 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 	return err;
 }
 
+void __nfs4_read_done_cb(struct nfs_read_data *data)
+{
+	nfs_invalidate_atime(data->inode);
+}
+
 static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
@@ -3183,7 +3188,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 		return -EAGAIN;
 	}
 
-	nfs_invalidate_atime(data->inode);
+	__nfs4_read_done_cb(data);
 	if (task->tk_status > 0)
 		renew_lease(server, data->timestamp);
 	return 0;
@@ -3197,7 +3202,8 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	return data->read_done_cb(task, data);
+	return data->read_done_cb ? data->read_done_cb(task, data) :
+				    nfs4_read_done_cb(task, data);
 }
 
 static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message *msg)
@@ -3242,7 +3248,8 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
-	return data->write_done_cb(task, data);
+	return data->write_done_cb ? data->write_done_cb(task, data) :
+		nfs4_write_done_cb(task, data);
 }
 
 /* Reset the the nfs_write_data to send the write to the MDS. */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7f283b2..d4f8ba8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -254,7 +254,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = lseg->pls_layout->plh_inode;
 
-	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
+	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
 	if (list_empty(&lseg->pls_layout->plh_segs)) {
 		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
@@ -1059,6 +1059,31 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	pgio->pg_test = (ld && ld->pg_test) ? pnfs_write_pg_test : NULL;
 }
 
+/*
+ * Called by non rpc-based layout drivers
+ */
+int
+pnfs_ld_write_done(struct nfs_write_data *data)
+{
+	int status;
+
+	if (!data->pnfs_error) {
+		pnfs_set_layoutcommit(data);
+		data->mds_ops->rpc_call_done(&data->task, data);
+		data->mds_ops->rpc_release(data);
+		return 0;
+	}
+
+	put_lseg(data->lseg);
+	data->lseg = NULL;
+	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
+		data->pnfs_error);
+	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
+				    data->mds_ops, NFS_FILE_SYNC);
+	return status ? : -EAGAIN;
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
+
 enum pnfs_try_status
 pnfs_try_to_write_data(struct nfs_write_data *wdata,
 			const struct rpc_call_ops *call_ops, int how)
@@ -1084,6 +1109,31 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 }
 
 /*
+ * Called by non rpc-based layout drivers
+ */
+int
+pnfs_ld_read_done(struct nfs_read_data *data)
+{
+	int status;
+
+	if (!data->pnfs_error) {
+		__nfs4_read_done_cb(data);
+		data->mds_ops->rpc_call_done(&data->task, data);
+		data->mds_ops->rpc_release(data);
+		return 0;
+	}
+
+	put_lseg(data->lseg);
+	data->lseg = NULL;
+	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
+		data->pnfs_error);
+	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
+				   data->mds_ops);
+	return status ? : -EAGAIN;
+}
+EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
+
+/*
  * Call the appropriate parallel I/O subsystem read function.
  */
 enum pnfs_try_status
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e24c7fb..2f8776b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -166,6 +166,8 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
+int pnfs_ld_write_done(struct nfs_write_data *);
+int pnfs_ld_read_done(struct nfs_read_data *);
 
 static inline int lo_fail_bit(u32 iomode)
 {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 890dce2..39c1e1b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1086,6 +1086,7 @@ struct nfs_read_data {
 	const struct rpc_call_ops *mds_ops;
 	int (*read_done_cb) (struct rpc_task *task, struct nfs_read_data *data);
 	__u64			mds_offset;
+	int			pnfs_error;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
@@ -1111,6 +1112,7 @@ struct nfs_write_data {
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
 	__u64			mds_offset;	/* Filelayout dense stripe */
+	int			pnfs_error;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
-- 
1.7.2.3

