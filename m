Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19426 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932907Ab1CWN2I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 09:28:08 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 10/12] NFSv4.1: filelayout driver specific code for COMMIT
Date: Wed, 23 Mar 2011 09:27:53 -0400
Message-Id: <1300886875-5016-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Implement all the hooks created in the previous patches.
This requires exporting quite a few functions and adding a few
structure fields.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c          |    1 +
 fs/nfs/internal.h       |   14 +++
 fs/nfs/nfs4filelayout.c |  235 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c           |    1 +
 fs/nfs/write.c          |   21 +++--
 include/linux/nfs_fs.h  |    1 +
 include/linux/nfs_xdr.h |    1 +
 7 files changed, 267 insertions(+), 7 deletions(-)

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
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 03ff80c..97e75a2 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -213,6 +213,37 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 	return 0;
 }
 
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
+	return 0;
+}
+
 static void filelayout_write_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
@@ -240,6 +271,16 @@ static void filelayout_write_release(void *data)
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
@@ -252,6 +293,12 @@ struct rpc_call_ops filelayout_write_call_ops = {
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
@@ -574,6 +621,191 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
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
@@ -581,6 +813,9 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.alloc_lseg		= filelayout_alloc_lseg,
 	.free_lseg		= filelayout_free_lseg,
 	.pg_test		= filelayout_pg_test,
+	.mark_pnfs_commit	= filelayout_mark_pnfs_commit,
+	.choose_commit_list	= filelayout_choose_commit_list,
+	.commit_pagelist	= filelayout_commit_pagelist,
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
 };
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f38813a..c675659 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -259,6 +259,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		pnfs_free_lseg_list(&free_me);
 	}
 }
+EXPORT_SYMBOL_GPL(put_lseg);
 
 static bool
 should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index cae5d16..e7aeda0 100644
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
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index f64ea14..9d434f0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -193,6 +193,7 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 	struct pnfs_layout_hdr *layout;
+	atomic_t		commits_outstanding;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2c2c67d..ac0c0e5 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1040,6 +1040,7 @@ struct nfs_write_data {
 	struct nfs_writeres	res;		/* result struct */
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
+	int			ds_commit_index;
 	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 #ifdef CONFIG_NFS_V4
-- 
1.7.2.1

