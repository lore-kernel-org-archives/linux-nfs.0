Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20886 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755395Ab1CWMak (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 08:30:40 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/11] NFSv4.1: filelayout driver specific code for COMMIT
Date: Wed, 23 Mar 2011 08:30:11 -0400
Message-Id: <1300883412-32296-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
References: <1300883412-32296-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Implement all the hooks created in the previous patches.
This requires exporting quite a few functions and adding a few
structure fields.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c           |    3 +
 fs/nfs/inode.c          |    1 +
 fs/nfs/internal.h       |   14 +++
 fs/nfs/nfs4_fs.h        |    2 +
 fs/nfs/nfs4filelayout.c |  253 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c       |   94 +++++++++++++++++
 fs/nfs/nfs4xdr.c        |  129 ++++++++++++++++++++++++
 fs/nfs/pnfs.c           |   95 ++++++++++++++++++
 fs/nfs/pnfs.h           |    9 ++-
 fs/nfs/write.c          |   36 +++++--
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_fs.h  |    2 +
 include/linux/nfs_xdr.h |   24 +++++
 13 files changed, 654 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d85a534..85cb95d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -326,6 +326,9 @@ nfs_file_fsync(struct file *file, int datasync)
 		ret = xchg(&ctx->error, 0);
 	if (!ret && status < 0)
 		ret = status;
+	if (!ret && !datasync)
+		/* application has asked for meta-data sync */
+		ret = pnfs_layoutcommit_inode(inode, 1);
 	return ret;
 }
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 01768e5..10bc234 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1471,6 +1471,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
 	nfsi->layout = NULL;
+	atomic_set(&nfsi->commits_outstanding, 0);
 #endif
 }
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 72e0bdd..f9bd8bd 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -276,11 +276,25 @@ extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
 /* write.c */
+extern void nfs_commit_free(struct nfs_write_data *p);
 extern int nfs_initiate_write(struct nfs_write_data *data,
 			      struct rpc_clnt *clnt,
 			      const struct rpc_call_ops *call_ops,
 			      int how);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
+extern int nfs_initiate_commit(struct nfs_write_data *data,
+			       struct rpc_clnt *clnt,
+			       const struct rpc_call_ops *call_ops,
+			       int how);
+extern void nfs_init_commit(struct nfs_write_data *data,
+			    struct list_head *head,
+			    struct pnfs_layout_segment *lseg);
+void nfs_retry_commit(struct list_head *page_list,
+		      struct pnfs_layout_segment *lseg);
+void nfs_commit_clear_lock(struct nfs_inode *nfsi);
+void nfs_commitdata_release(void *data);
+void nfs_commit_release_pages(struct nfs_write_data *data);
+
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
 		struct page *, struct page *);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c64be1c..1e612d1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -262,6 +262,8 @@ extern int nfs4_proc_destroy_session(struct nfs4_session *);
 extern int nfs4_init_session(struct nfs_server *server);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
+extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
+				  int sync);
 
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 03ff80c..fc1a0e9 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -154,6 +154,23 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 }
 
 /*
+ * We reference the rpc_cred of the first WRITE that triggers the need for
+ * a LAYOUTCOMMIT, and use it to send the layoutcommit compound.
+ * rfc5661 is not clear about which credential should be used.
+ */
+static void
+filelayout_set_layoutcommit(struct nfs_write_data *wdata)
+{
+	if (FILELAYOUT_LSEG(wdata->lseg)->commit_through_mds ||
+	    wdata->res.verf->committed == NFS_FILE_SYNC)
+		return;
+
+	pnfs_set_layoutcommit(wdata);
+	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
+		(unsigned long) wdata->lseg->pls_end_pos);
+}
+
+/*
  * Call ops for the async read/write cases
  * In the case of dense layouts, the offset needs to be reset to its
  * original value.
@@ -210,6 +227,38 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 		return -EAGAIN;
 	}
 
+	filelayout_set_layoutcommit(data);
+	return 0;
+}
+
+/* Fake up some data that will cause nfs_commit_release to retry the writes. */
+static void prepare_to_resend_writes(struct nfs_write_data *data)
+{
+	struct nfs_page *first = nfs_list_entry(data->pages.next);
+
+	data->task.tk_status = 0;
+	memcpy(data->verf.verifier, first->wb_verf.verifier,
+	       sizeof(first->wb_verf.verifier));
+	data->verf.verifier[0]++; /* ensure verifier mismatch */
+}
+
+static int filelayout_commit_done_cb(struct rpc_task *task,
+				     struct nfs_write_data *data)
+{
+	int reset = 0;
+
+	if (filelayout_async_handle_error(task, data->args.context->state,
+					  data->ds_clp, &reset) == -EAGAIN) {
+		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
+			__func__, data->ds_clp, data->ds_clp->cl_session);
+		if (reset) {
+			prepare_to_resend_writes(data);
+			filelayout_set_lo_fail(data->lseg);
+		} else
+			nfs_restart_rpc(task, data->ds_clp);
+		return -EAGAIN;
+	}
+
 	return 0;
 }
 
@@ -240,6 +289,16 @@ static void filelayout_write_release(void *data)
 	wdata->mds_ops->rpc_release(data);
 }
 
+static void filelayout_commit_release(void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	nfs_commit_release_pages(wdata);
+	if (atomic_dec_and_test(&NFS_I(wdata->inode)->commits_outstanding))
+		nfs_commit_clear_lock(NFS_I(wdata->inode));
+	nfs_commitdata_release(wdata);
+}
+
 struct rpc_call_ops filelayout_read_call_ops = {
 	.rpc_call_prepare = filelayout_read_prepare,
 	.rpc_call_done = filelayout_read_call_done,
@@ -252,6 +311,12 @@ struct rpc_call_ops filelayout_write_call_ops = {
 	.rpc_release = filelayout_write_release,
 };
 
+struct rpc_call_ops filelayout_commit_call_ops = {
+	.rpc_call_prepare = filelayout_write_prepare,
+	.rpc_call_done = filelayout_write_call_done,
+	.rpc_release = filelayout_commit_release,
+};
+
 static enum pnfs_try_status
 filelayout_read_pagelist(struct nfs_read_data *data)
 {
@@ -574,6 +639,191 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	return (p_stripe == r_stripe);
 }
 
+static bool filelayout_mark_pnfs_commit(struct pnfs_layout_segment *lseg)
+{
+	return !FILELAYOUT_LSEG(lseg)->commit_through_mds;
+}
+
+static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
+{
+	if (fl->stripe_type == STRIPE_SPARSE)
+		return nfs4_fl_calc_ds_index(&fl->generic_hdr, j);
+	else
+		return j;
+}
+
+struct list_head *filelayout_choose_commit_list(struct nfs_page *req)
+{
+	struct pnfs_layout_segment *lseg = req->wb_commit_lseg;
+	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
+	u32 i, j;
+	struct list_head *list;
+
+	/* Note that we are calling nfs4_fl_calc_j_index on each page
+	 * that ends up being committed to a data server.  An attractive
+	 * alternative is to add a field to nfs_write_data and nfs_page
+	 * to store the value calculated in filelayout_write_pagelist
+	 * and just use that here.
+	 */
+	j = nfs4_fl_calc_j_index(lseg,
+				 (loff_t)req->wb_index << PAGE_CACHE_SHIFT);
+	i = select_bucket_index(fl, j);
+	list = &fl->commit_buckets[i];
+	if (list_empty(list)) {
+		/* Non-empty buckets hold a reference on the lseg */
+		get_lseg(lseg);
+	}
+	return list;
+}
+
+static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
+{
+	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
+
+	if (flseg->stripe_type == STRIPE_SPARSE)
+		return i;
+	else
+		return nfs4_fl_calc_ds_index(lseg, i);
+}
+
+static struct nfs_fh *
+select_ds_fh_from_commit(struct pnfs_layout_segment *lseg, u32 i)
+{
+	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
+
+	if (flseg->stripe_type == STRIPE_SPARSE) {
+		if (flseg->num_fh == 1)
+			i = 0;
+		else if (flseg->num_fh == 0)
+			/* Use the MDS OPEN fh set in nfs_read_rpcsetup */
+			return NULL;
+	}
+	return flseg->fh_array[i];
+}
+
+static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
+{
+	struct pnfs_layout_segment *lseg = data->lseg;
+	struct nfs4_pnfs_ds *ds;
+	u32 idx;
+	struct nfs_fh *fh;
+
+	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
+	ds = nfs4_fl_prepare_ds(lseg, idx);
+	if (!ds) {
+		printk(KERN_ERR "%s: prepare_ds failed, use MDS\n", __func__);
+		set_bit(lo_fail_bit(IOMODE_RW), &lseg->pls_layout->plh_flags);
+		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
+		prepare_to_resend_writes(data);
+		data->mds_ops->rpc_release(data);
+		return -EAGAIN;
+	}
+	dprintk("%s ino %lu, how %d\n", __func__, data->inode->i_ino, how);
+	data->write_done_cb = filelayout_commit_done_cb;
+	data->ds_clp = ds->ds_clp;
+	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
+	if (fh)
+		data->args.fh = fh;
+	return nfs_initiate_commit(data, ds->ds_clp->cl_rpcclient,
+				   &filelayout_commit_call_ops, how);
+}
+
+/*
+ * This is only useful while we are using whole file layouts.
+ */
+static struct pnfs_layout_segment *find_only_write_lseg(struct inode *inode)
+{
+	struct pnfs_layout_segment *lseg, *rv = NULL;
+
+	spin_lock(&inode->i_lock);
+	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
+		if (lseg->pls_range.iomode == IOMODE_RW)
+			rv = get_lseg(lseg);
+	spin_unlock(&inode->i_lock);
+	return rv;
+}
+
+static int alloc_ds_commits(struct inode *inode, struct list_head *list)
+{
+	struct pnfs_layout_segment *lseg;
+	struct nfs4_filelayout_segment *fl;
+	struct nfs_write_data *data;
+	int i, j;
+
+	/* Won't need this when non-whole file layout segments are supported
+	 * instead we will use a pnfs_layout_hdr structure */
+	lseg = find_only_write_lseg(inode);
+	if (!lseg)
+		return 0;
+	fl = FILELAYOUT_LSEG(lseg);
+	for (i = 0; i < fl->number_of_buckets; i++) {
+		if (list_empty(&fl->commit_buckets[i]))
+			continue;
+		data = nfs_commitdata_alloc();
+		if (!data)
+			goto out_bad;
+		data->ds_commit_index = i;
+		data->lseg = lseg;
+		list_add(&data->pages, list);
+	}
+	put_lseg(lseg);
+	return 0;
+
+out_bad:
+	for (j = i; j < fl->number_of_buckets; j++) {
+		if (list_empty(&fl->commit_buckets[i]))
+			continue;
+		nfs_retry_commit(&fl->commit_buckets[i], lseg);
+		put_lseg(lseg);  /* associated with emptying bucket */
+	}
+	put_lseg(lseg);
+	/* Caller will clean up entries put on list */
+	return -ENOMEM;
+}
+
+/* This follows nfs_commit_list pretty closely */
+static int
+filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
+			   int how)
+{
+	struct nfs_write_data	*data, *tmp;
+	LIST_HEAD(list);
+
+	if (!list_empty(mds_pages)) {
+		data = nfs_commitdata_alloc();
+		if (!data)
+			goto out_bad;
+		data->lseg = NULL;
+		list_add(&data->pages, &list);
+	}
+
+	if (alloc_ds_commits(inode, &list))
+		goto out_bad;
+
+	list_for_each_entry_safe(data, tmp, &list, pages) {
+		list_del_init(&data->pages);
+		atomic_inc(&NFS_I(inode)->commits_outstanding);
+		if (!data->lseg) {
+			nfs_init_commit(data, mds_pages, NULL);
+			nfs_initiate_commit(data, NFS_CLIENT(inode),
+					    data->mds_ops, how);
+		} else {
+			nfs_init_commit(data, &FILELAYOUT_LSEG(data->lseg)->commit_buckets[data->ds_commit_index], data->lseg);
+			filelayout_initiate_commit(data, how);
+		}
+	}
+	return 0;
+ out_bad:
+	list_for_each_entry_safe(data, tmp, &list, pages) {
+		nfs_retry_commit(&data->pages, data->lseg);
+		list_del_init(&data->pages);
+		nfs_commit_free(data);
+	}
+	nfs_retry_commit(mds_pages, NULL);
+	nfs_commit_clear_lock(NFS_I(inode));
+	return -ENOMEM;
+}
+
 static struct pnfs_layoutdriver_type filelayout_type = {
 	.id			= LAYOUT_NFSV4_1_FILES,
 	.name			= "LAYOUT_NFSV4_1_FILES",
@@ -581,6 +831,9 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.alloc_lseg		= filelayout_alloc_lseg,
 	.free_lseg		= filelayout_free_lseg,
 	.pg_test		= filelayout_pg_test,
+	.mark_pnfs_commit	= filelayout_mark_pnfs_commit,
+	.choose_commit_list	= filelayout_choose_commit_list,
+	.commit_pagelist	= filelayout_commit_pagelist,
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5d61ccc..6f2f402 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5616,6 +5616,100 @@ int nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 }
 EXPORT_SYMBOL_GPL(nfs4_proc_getdeviceinfo);
 
+static void nfs4_layoutcommit_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_layoutcommit_data *data = calldata;
+	struct nfs_server *server = NFS_SERVER(data->args.inode);
+
+	if (nfs4_setup_sequence(server, &data->args.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+
+static void
+nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_layoutcommit_data *data = calldata;
+	struct nfs_server *server = NFS_SERVER(data->args.inode);
+
+	if (!nfs4_sequence_done(task, &data->res.seq_res))
+		return;
+
+	switch (task->tk_status) { /* Just ignore these failures */
+	case NFS4ERR_DELEG_REVOKED: /* layout was recalled */
+	case NFS4ERR_BADIOMODE:     /* no IOMODE_RW layout for range */
+	case NFS4ERR_BADLAYOUT:     /* no layout */
+	case NFS4ERR_GRACE:	    /* loca_recalim always false */
+		task->tk_status = 0;
+	}
+
+	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
+		nfs_restart_rpc(task, server->nfs_client);
+		return;
+	}
+
+	if (task->tk_status == 0)
+		nfs_post_op_update_inode_force_wcc(data->args.inode,
+						   data->res.fattr);
+}
+
+static void nfs4_layoutcommit_release(void *calldata)
+{
+	struct nfs4_layoutcommit_data *data = calldata;
+
+	/* Matched by references in pnfs_set_layoutcommit */
+	put_lseg(data->lseg);
+	put_rpccred(data->cred);
+	kfree(data);
+}
+
+static const struct rpc_call_ops nfs4_layoutcommit_ops = {
+	.rpc_call_prepare = nfs4_layoutcommit_prepare,
+	.rpc_call_done = nfs4_layoutcommit_done,
+	.rpc_release = nfs4_layoutcommit_release,
+};
+
+int
+nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, int sync)
+{
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTCOMMIT],
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = data->cred,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.task = &data->task,
+		.rpc_client = NFS_CLIENT(data->args.inode),
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_layoutcommit_ops,
+		.callback_data = data,
+		.flags = RPC_TASK_ASYNC,
+	};
+	struct rpc_task *task;
+	int status = 0;
+
+	dprintk("NFS: %4d initiating layoutcommit call. sync %d "
+		"lbw: %llu inode %lu\n",
+		data->task.tk_pid, sync,
+		data->args.lastbytewritten,
+		data->args.inode->i_ino);
+
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	if (!sync)
+		goto out;
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0)
+		goto out;
+	status = task->tk_status;
+out:
+	dprintk("%s: status %d\n", __func__, status);
+	rpc_put_task(task);
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 07cdf92..207d399 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -324,6 +324,18 @@ static int nfs4_stat_to_errno(int);
 #define decode_layoutget_maxsz	(op_decode_hdr_maxsz + 8 + \
 				decode_stateid_maxsz + \
 				XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE))
+#define encode_layoutcommit_maxsz (op_encode_hdr_maxsz +          \
+				2 /* offset */ + \
+				2 /* length */ + \
+				1 /* reclaim */ + \
+				encode_stateid_maxsz + \
+				1 /* new offset (true) */ + \
+				2 /* last byte written */ + \
+				1 /* nt_timechanged (false) */ + \
+				1 /* layoutupdate4 layout type */ + \
+				1 /* NULL filelayout layoutupdate4 payload */)
+#define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
+
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -727,6 +739,17 @@ static int nfs4_stat_to_errno(int);
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz +        \
 				decode_layoutget_maxsz)
+#define NFS4_enc_layoutcommit_sz (compound_encode_hdr_maxsz + \
+				encode_sequence_maxsz +\
+				encode_putfh_maxsz + \
+				encode_layoutcommit_maxsz + \
+				encode_getattr_maxsz)
+#define NFS4_dec_layoutcommit_sz (compound_decode_hdr_maxsz + \
+				decode_sequence_maxsz + \
+				decode_putfh_maxsz + \
+				decode_layoutcommit_maxsz + \
+				decode_getattr_maxsz)
+
 
 const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				      compound_encode_hdr_maxsz +
@@ -1816,6 +1839,34 @@ encode_layoutget(struct xdr_stream *xdr,
 	hdr->nops++;
 	hdr->replen += decode_layoutget_maxsz;
 }
+
+static int
+encode_layoutcommit(struct xdr_stream *xdr,
+		    const struct nfs4_layoutcommit_args *args,
+		    struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	dprintk("%s: lbw: %llu type: %d\n", __func__, args->lastbytewritten,
+		NFS_SERVER(args->inode)->pnfs_curr_ld->id);
+
+	p = reserve_space(xdr, 48 + NFS4_STATEID_SIZE);
+	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
+	/* Only whole file layouts */
+	p = xdr_encode_hyper(p, 0); /* offset */
+	p = xdr_encode_hyper(p, NFS4_MAX_UINT64); /* length */
+	*p++ = cpu_to_be32(0); /* reclaim */
+	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
+	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
+	p = xdr_encode_hyper(p, args->lastbytewritten);
+	*p++ = cpu_to_be32(0); /* Never send time_modify_changed */
+	*p++ = cpu_to_be32(NFS_SERVER(args->inode)->pnfs_curr_ld->id);/* type */
+	*p++ = cpu_to_be32(0); /* no file layout payload */
+
+	hdr->nops++;
+	hdr->replen += decode_layoutcommit_maxsz;
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2607,6 +2658,26 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
 	encode_layoutget(xdr, args, &hdr);
 	encode_nops(&hdr);
 }
+
+/*
+ *  Encode LAYOUTCOMMIT request
+ */
+static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
+				     struct xdr_stream *xdr,
+				     struct nfs4_layoutcommit_args *args)
+{
+	struct compound_hdr hdr = {
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
+	};
+
+	encode_compound_hdr(xdr, req, &hdr);
+	encode_sequence(xdr, &args->seq_args, &hdr);
+	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
+	encode_layoutcommit(xdr, args, &hdr);
+	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
@@ -5007,6 +5078,35 @@ out_overflow:
 	print_overflow_msg(__func__, xdr);
 	return -EIO;
 }
+
+static int decode_layoutcommit(struct xdr_stream *xdr,
+			       struct rpc_rqst *req,
+			       struct nfs4_layoutcommit_res *res)
+{
+	__be32 *p;
+	__u32 sizechanged;
+	int status;
+
+	status = decode_op_hdr(xdr, OP_LAYOUTCOMMIT);
+	if (status)
+		return status;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	sizechanged = be32_to_cpup(p);
+
+	if (sizechanged) {
+		/* throw away new size */
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
+	}
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -6068,6 +6168,34 @@ static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp,
 out:
 	return status;
 }
+
+/*
+ * Decode LAYOUTCOMMIT response
+ */
+static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
+				     struct xdr_stream *xdr,
+				     struct nfs4_layoutcommit_res *res)
+{
+	struct compound_hdr hdr;
+	int status;
+
+	status = decode_compound_hdr(xdr, &hdr);
+	if (status)
+		goto out;
+	status = decode_sequence(xdr, &res->seq_res, rqstp);
+	if (status)
+		goto out;
+	status = decode_putfh(xdr);
+	if (status)
+		goto out;
+	status = decode_layoutcommit(xdr, rqstp, res);
+	if (status)
+		goto out;
+	decode_getfattr(xdr, res->fattr, res->server,
+			!RPC_IS_ASYNC(rqstp->rq_task));
+out:
+	return status;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 /**
@@ -6269,6 +6397,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 	PROC(RECLAIM_COMPLETE,	enc_reclaim_complete,	dec_reclaim_complete),
 	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
 	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
+	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f38813a..2a08ca0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -259,6 +259,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		pnfs_free_lseg_list(&free_me);
 	}
 }
+EXPORT_SYMBOL_GPL(put_lseg);
 
 static bool
 should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
@@ -945,3 +946,97 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
+
+/*
+ * Currently there is only one (whole file) write lseg.
+ */
+static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
+{
+	struct pnfs_layout_segment *lseg, *rv = NULL;
+
+	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
+		if (lseg->pls_range.iomode == IOMODE_RW)
+			rv = lseg;
+	return rv;
+}
+
+void
+pnfs_set_layoutcommit(struct nfs_write_data *wdata)
+{
+	struct nfs_inode *nfsi = NFS_I(wdata->inode);
+	loff_t end_pos = wdata->args.offset + wdata->res.count;
+
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
+		/* references matched in nfs4_layoutcommit_release */
+		get_lseg(wdata->lseg);
+		wdata->lseg->pls_lc_cred =
+			get_rpccred(wdata->args.context->state->owner->so_cred);
+		mark_inode_dirty_sync(wdata->inode);
+		dprintk("%s: Set layoutcommit for inode %lu ",
+			__func__, wdata->inode->i_ino);
+	}
+	if (end_pos > wdata->lseg->pls_end_pos)
+		wdata->lseg->pls_end_pos = end_pos;
+	spin_unlock(&nfsi->vfs_inode.i_lock);
+}
+EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
+
+int
+pnfs_layoutcommit_inode(struct inode *inode, int sync)
+{
+	struct nfs4_layoutcommit_data *data;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct pnfs_layout_segment *lseg;
+	struct rpc_cred *cred;
+	loff_t end_pos;
+	int status = 0;
+
+	dprintk("--> %s inode %lu\n", __func__, inode->i_ino);
+
+	/* Note kzalloc ensures data->res.seq_res.sr_slot == NULL */
+	data = kzalloc(sizeof(*data), GFP_NOFS);
+	spin_lock(&inode->i_lock);
+
+	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
+		spin_unlock(&inode->i_lock);
+		kfree(data);
+		goto out;
+	}
+	/*
+	 * Currently only one (whole file) write lseg which is referenced
+	 * in pnfs_set_layoutcommit and will be found.
+	 */
+	lseg = pnfs_list_write_lseg(inode);
+
+	end_pos = lseg->pls_end_pos;
+	cred = lseg->pls_lc_cred;
+	lseg->pls_end_pos = 0;
+	lseg->pls_lc_cred = NULL;
+
+	if (!data) {
+		put_lseg(lseg);
+		spin_unlock(&inode->i_lock);
+		put_rpccred(cred);
+		status = -ENOMEM;
+		goto out;
+	} else {
+		memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
+			sizeof(nfsi->layout->plh_stateid.data));
+	}
+	spin_unlock(&inode->i_lock);
+
+	data->args.inode = inode;
+	data->lseg = lseg;
+	data->cred = cred;
+	nfs_fattr_init(&data->fattr);
+	data->args.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
+	data->res.fattr = &data->fattr;
+	data->args.lastbytewritten = end_pos - 1;
+	data->res.server = NFS_SERVER(inode);
+
+	status = nfs4_proc_layoutcommit(data, sync);
+out:
+	dprintk("<-- %s status %d\n", __func__, status);
+	return status;
+}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5370f1b..0806c77 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -43,6 +43,8 @@ struct pnfs_layout_segment {
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
+	struct rpc_cred	*pls_lc_cred; /* LAYOUTCOMMIT credential */
+	loff_t pls_end_pos; /* LAYOUTCOMMIT write end */
 };
 
 enum pnfs_try_status {
@@ -152,7 +154,8 @@ bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
-
+void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
+int pnfs_layoutcommit_inode(struct inode *inode, int sync);
 
 static inline int lo_fail_bit(u32 iomode)
 {
@@ -325,6 +328,10 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
 {
 }
 
+static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index cae5d16..a03c11f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -59,6 +59,7 @@ struct nfs_write_data *nfs_commitdata_alloc(void)
 	}
 	return p;
 }
+EXPORT_SYMBOL_GPL(nfs_commitdata_alloc);
 
 void nfs_commit_free(struct nfs_write_data *p)
 {
@@ -66,6 +67,7 @@ void nfs_commit_free(struct nfs_write_data *p)
 		kfree(p->pagevec);
 	mempool_free(p, nfs_commit_mempool);
 }
+EXPORT_SYMBOL_GPL(nfs_commit_free);
 
 struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
@@ -1283,15 +1285,15 @@ static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 	return (ret < 0) ? ret : 1;
 }
 
-static void nfs_commit_clear_lock(struct nfs_inode *nfsi)
+void nfs_commit_clear_lock(struct nfs_inode *nfsi)
 {
 	clear_bit(NFS_INO_COMMIT, &nfsi->flags);
 	smp_mb__after_clear_bit();
 	wake_up_bit(&nfsi->flags, NFS_INO_COMMIT);
 }
+EXPORT_SYMBOL_GPL(nfs_commit_clear_lock);
 
-
-static void nfs_commitdata_release(void *data)
+void nfs_commitdata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
@@ -1299,8 +1301,9 @@ static void nfs_commitdata_release(void *data)
 	put_nfs_open_context(wdata->args.context);
 	nfs_commit_free(wdata);
 }
+EXPORT_SYMBOL_GPL(nfs_commitdata_release);
 
-static int nfs_initiate_commit(struct nfs_write_data *data, struct rpc_clnt *clnt,
+int nfs_initiate_commit(struct nfs_write_data *data, struct rpc_clnt *clnt,
 			const struct rpc_call_ops *call_ops,
 			int how)
 {
@@ -1334,11 +1337,12 @@ static int nfs_initiate_commit(struct nfs_write_data *data, struct rpc_clnt *cln
 	rpc_put_task(task);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_initiate_commit);
 
 /*
  * Set up the argument/result storage required for the RPC call.
  */
-static void nfs_init_commit(struct nfs_write_data *data,
+void nfs_init_commit(struct nfs_write_data *data,
 			    struct list_head *head,
 			    struct pnfs_layout_segment *lseg)
 {
@@ -1365,8 +1369,9 @@ static void nfs_init_commit(struct nfs_write_data *data,
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
 }
+EXPORT_SYMBOL_GPL(nfs_init_commit);
 
-static void nfs_retry_commit(struct list_head *page_list,
+void nfs_retry_commit(struct list_head *page_list,
 		      struct pnfs_layout_segment *lseg)
 {
 	struct nfs_page *req;
@@ -1381,6 +1386,7 @@ static void nfs_retry_commit(struct list_head *page_list,
 		nfs_clear_page_tag_locked(req);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_retry_commit);
 
 /*
  * Commit dirty pages
@@ -1419,7 +1425,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 		return;
 }
 
-static void nfs_commit_release_pages(struct nfs_write_data *data)
+void nfs_commit_release_pages(struct nfs_write_data *data)
 {
 	struct nfs_page	*req;
 	int status = data->task.tk_status;
@@ -1456,6 +1462,7 @@ static void nfs_commit_release_pages(struct nfs_write_data *data)
 		nfs_clear_page_tag_locked(req);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_commit_release_pages);
 
 static void nfs_commit_release(void *calldata)
 {
@@ -1555,7 +1562,20 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 
 int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
-	return nfs_commit_unstable_pages(inode, wbc);
+	int ret;
+
+	ret = nfs_commit_unstable_pages(inode, wbc);
+	if (ret >= 0 && test_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags)) {
+		int status, sync = wbc->sync_mode;
+
+		if (wbc->nonblocking || wbc->for_background)
+				sync = 0;
+
+		status = pnfs_layoutcommit_inode(inode, sync);
+		if (status < 0)
+			return status;
+	}
+	return ret;
 }
 
 /*
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 134716e..bf22cfa 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -560,6 +560,7 @@ enum {
 	NFSPROC4_CLNT_RECLAIM_COMPLETE,
 	NFSPROC4_CLNT_LAYOUTGET,
 	NFSPROC4_CLNT_GETDEVICEINFO,
+	NFSPROC4_CLNT_LAYOUTCOMMIT,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f64ea14..5765126 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -193,6 +193,7 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 	struct pnfs_layout_hdr *layout;
+	atomic_t		commits_outstanding;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;
@@ -222,6 +223,7 @@ struct nfs_inode {
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 #define NFS_INO_PNFS_COMMIT	(8)		/* use pnfs code for commit */
+#define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2c2c67d..84f3585 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -236,6 +236,29 @@ struct nfs4_getdeviceinfo_res {
 	struct nfs4_sequence_res seq_res;
 };
 
+struct nfs4_layoutcommit_args {
+	nfs4_stateid stateid;
+	__u64 lastbytewritten;
+	struct inode *inode;
+	const u32 *bitmask;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct nfs4_layoutcommit_res {
+	struct nfs_fattr *fattr;
+	const struct nfs_server *server;
+	struct nfs4_sequence_res seq_res;
+};
+
+struct nfs4_layoutcommit_data {
+	struct rpc_task task;
+	struct nfs_fattr fattr;
+	struct pnfs_layout_segment *lseg;
+	struct rpc_cred *cred;
+	struct nfs4_layoutcommit_args args;
+	struct nfs4_layoutcommit_res res;
+};
+
 /*
  * Arguments to the open call.
  */
@@ -1040,6 +1063,7 @@ struct nfs_write_data {
 	struct nfs_writeres	res;		/* result struct */
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
+	int			ds_commit_index;
 	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 #ifdef CONFIG_NFS_V4
-- 
1.7.2.1

