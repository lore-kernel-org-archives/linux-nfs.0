Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7088 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754404Ab0HMVdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:21 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 44/50] pnfs_submit: filelayout commit
Date: Fri, 13 Aug 2010 17:31:56 -0400
Message-Id: <1281735122-1496-45-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-44-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
 <1281735122-1496-35-git-send-email-andros@netapp.com>
 <1281735122-1496-36-git-send-email-andros@netapp.com>
 <1281735122-1496-37-git-send-email-andros@netapp.com>
 <1281735122-1496-38-git-send-email-andros@netapp.com>
 <1281735122-1496-39-git-send-email-andros@netapp.com>
 <1281735122-1496-40-git-send-email-andros@netapp.com>
 <1281735122-1496-41-git-send-email-andros@netapp.com>
 <1281735122-1496-42-git-send-email-andros@netapp.com>
 <1281735122-1496-43-git-send-email-andros@netapp.com>
 <1281735122-1496-44-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c          |    2 +
 fs/nfs/nfs4filelayout.c |  171 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/write.c          |   30 +++++---
 3 files changed, 192 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0360336..30d9ac6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -644,6 +644,7 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 		atomic_inc(&ctx->lock_context.count);
 	return ctx;
 }
+EXPORT_SYMBOL(get_nfs_open_context);
 
 static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 {
@@ -996,6 +997,7 @@ void nfs_fattr_init(struct nfs_fattr *fattr)
 	fattr->time_start = jiffies;
 	fattr->gencount = nfs_inc_attr_generation_counter();
 }
+EXPORT_SYMBOL(nfs_fattr_init);
 
 struct nfs_fattr *nfs_alloc_fattr(void)
 {
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 8c5702b..fea1772 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -501,6 +501,176 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 	_filelayout_free_lseg(lseg);
 }
 
+/* Allocate a new nfs_write_data struct and initialize */
+static struct nfs_write_data *
+filelayout_clone_write_data(struct nfs_write_data *old)
+{
+	static struct nfs_write_data *new;
+
+	new = nfs_commitdata_alloc();
+	if (!new)
+		goto out;
+	kref_init(&new->refcount);
+	new->parent      = old;
+	kref_get(&old->refcount);
+	new->inode       = old->inode;
+	new->cred        = old->cred;
+	new->args.offset = 0;
+	new->args.count  = 0;
+	new->res.count   = 0;
+	new->res.fattr   = &new->fattr;
+	nfs_fattr_init(&new->fattr);
+	new->res.verf    = &new->verf;
+	new->args.context = get_nfs_open_context(old->args.context);
+	new->pdata.lseg = NULL;
+	new->pdata.call_ops = old->pdata.call_ops;
+	new->pdata.how = old->pdata.how;
+out:
+	return new;
+}
+
+static void filelayout_commit_call_done(struct rpc_task *task, void *data)
+{
+	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+
+	wdata->pdata.call_ops->rpc_call_done(task, data);
+}
+
+static struct rpc_call_ops filelayout_commit_call_ops = {
+	.rpc_call_prepare = nfs_write_prepare,
+	.rpc_call_done = filelayout_commit_call_done,
+	.rpc_release = filelayout_write_release,
+};
+
+/*
+ * Execute a COMMIT op to the MDS or to each data server on which a page
+ * in 'pages' exists.
+ * Invoke the pnfs_commit_complete callback.
+ */
+enum pnfs_try_status
+filelayout_commit(struct nfs_write_data *data, int sync)
+{
+	LIST_HEAD(head);
+	struct nfs_page *req;
+	loff_t file_offset = 0;
+	u16 idx, i;
+	struct list_head **ds_page_list = NULL;
+	u16 *indices_used;
+	int num_indices_seen = 0;
+	const struct rpc_call_ops *call_ops;
+	struct rpc_clnt *clnt;
+	struct nfs_write_data **clone_list = NULL;
+	struct nfs_write_data *dsdata;
+	struct nfs4_pnfs_ds *ds;
+
+	dprintk("%s data %p sync %d\n", __func__, data, sync);
+
+	/* Alloc room for both in one go */
+	ds_page_list = kzalloc((NFS4_PNFS_MAX_MULTI_CNT + 1) *
+			       (sizeof(u16) + sizeof(struct list_head *)),
+			       GFP_KERNEL);
+	if (!ds_page_list)
+		goto mem_error;
+	indices_used = (u16 *) (ds_page_list + NFS4_PNFS_MAX_MULTI_CNT + 1);
+	/*
+	 * Sort pages based on which ds to send to.
+	 * MDS is given index equal to NFS4_PNFS_MAX_MULTI_CNT.
+	 * Note we are assuming there is only a single lseg in play.
+	 * When that is not true, we could first sort on lseg, then
+	 * sort within each as we do here.
+	 */
+	while (!list_empty(&data->pages)) {
+		req = nfs_list_entry(data->pages.next);
+		nfs_list_remove_request(req);
+		if (!req->wb_lseg ||
+		    ((struct nfs4_filelayout_segment *)
+		     LSEG_LD_DATA(req->wb_lseg))->commit_through_mds)
+			idx = NFS4_PNFS_MAX_MULTI_CNT;
+		else {
+			file_offset = (loff_t)req->wb_index << PAGE_CACHE_SHIFT;
+			idx = nfs4_fl_calc_ds_index(req->wb_lseg, file_offset);
+		}
+		if (ds_page_list[idx]) {
+			/* Already seen this idx */
+			list_add(&req->wb_list, ds_page_list[idx]);
+		} else {
+			/* New idx not seen so far */
+			list_add_tail(&req->wb_list, &head);
+			indices_used[num_indices_seen++] = idx;
+		}
+		ds_page_list[idx] = &req->wb_list;
+	}
+	/* Once created, clone must be released via call_op */
+	clone_list = kzalloc(num_indices_seen *
+			     sizeof(struct nfs_write_data *), GFP_KERNEL);
+	if (!clone_list)
+		goto mem_error;
+	for (i = 0; i < num_indices_seen - 1; i++) {
+		clone_list[i] = filelayout_clone_write_data(data);
+		if (!clone_list[i])
+			goto mem_error;
+	}
+	clone_list[i] = data;
+	/*
+	 * Now send off the RPCs to each ds.  Note that it is important
+	 * that any RPC to the MDS be sent last (or at least after all
+	 * clones have been made.)
+	 */
+	for (i = 0; i < num_indices_seen; i++) {
+		dsdata = clone_list[i];
+		idx = indices_used[i];
+		list_cut_position(&dsdata->pages, &head, ds_page_list[idx]);
+		if (idx == NFS4_PNFS_MAX_MULTI_CNT) {
+			call_ops = data->pdata.call_ops;;
+			clnt = NFS_CLIENT(dsdata->inode);
+			ds = NULL;
+		} else {
+			struct nfs_fh *fh;
+
+			call_ops = &filelayout_commit_call_ops;
+			req = nfs_list_entry(dsdata->pages.next);
+			ds = nfs4_fl_prepare_ds(req->wb_lseg, idx);
+			if (!ds) {
+				/* Trigger retry of this chunk through MDS */
+				dsdata->task.tk_status = -EIO;
+				data->pdata.call_ops->rpc_release(dsdata);
+				continue;
+			}
+			clnt = ds->ds_clp->cl_rpcclient;
+			dsdata->fldata.ds_nfs_client = ds->ds_clp;
+			file_offset = (loff_t)req->wb_index << PAGE_CACHE_SHIFT;
+			fh = nfs4_fl_select_ds_fh(req->wb_lseg, file_offset);
+			if (fh)
+				dsdata->args.fh = fh;
+		}
+		dprintk("%s: Initiating commit: %llu USE DS:\n",
+			__func__, file_offset);
+		print_ds(ds);
+
+		/* Send COMMIT to data server */
+		nfs_initiate_commit(dsdata, clnt, call_ops, sync);
+	}
+	kfree(clone_list);
+	kfree(ds_page_list);
+	return PNFS_ATTEMPTED;
+
+ mem_error:
+	if (clone_list) {
+		for (i = 0; i < num_indices_seen - 1; i++) {
+			if (!clone_list[i])
+				break;
+			data->pdata.call_ops->rpc_release(clone_list[i]);
+		}
+		kfree(clone_list);
+	}
+	kfree(ds_page_list);
+	/* One of these will be empty, but doesn't hurt to do both */
+	nfs_mark_list_commit(&head);
+	nfs_mark_list_commit(&data->pages);
+	data->pdata.call_ops->rpc_release(data);
+	return PNFS_ATTEMPTED;
+}
+
 /* Return the stripesize for the specified file */
 ssize_t
 filelayout_get_stripesize(struct pnfs_layout_type *layoutid)
@@ -534,6 +704,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 
 struct layoutdriver_io_operations filelayout_io_operations = {
+	.commit                  = filelayout_commit,
 	.read_pagelist           = filelayout_read_pagelist,
 	.write_pagelist          = filelayout_write_pagelist,
 	.alloc_layout            = filelayout_alloc_layout,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 668c4c1..2251551 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -60,6 +60,7 @@ struct nfs_write_data *nfs_commitdata_alloc(void)
 	}
 	return p;
 }
+EXPORT_SYMBOL(nfs_commitdata_alloc);
 
 void nfs_commit_free(struct nfs_write_data *p)
 {
@@ -1395,6 +1396,23 @@ static int nfs_commit_rpcsetup(struct list_head *head,
 				    how, pnfs);
 }
 
+/* Handle memory error during commit */
+void nfs_mark_list_commit(struct list_head *head)
+{
+	struct nfs_page         *req;
+
+	while (!list_empty(head)) {
+		req = nfs_list_entry(head->next);
+		nfs_list_remove_request(req);
+		nfs_mark_request_commit(req);
+		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				BDI_RECLAIMABLE);
+		nfs_clear_page_tag_locked(req);
+	}
+}
+EXPORT_SYMBOL(nfs_mark_list_commit);
+
 /*
  * Commit dirty pages
  */
@@ -1402,25 +1420,15 @@ static int
 nfs_commit_list(struct inode *inode, struct list_head *head, int how, int pnfs)
 {
 	struct nfs_write_data	*data;
-	struct nfs_page         *req;
 
 	data = nfs_commitdata_alloc();
-
 	if (!data)
 		goto out_bad;
 
 	/* Set up the argument struct */
 	return nfs_commit_rpcsetup(head, data, how, pnfs);
  out_bad:
-	while (!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_mark_request_commit(req);
-		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
-				BDI_RECLAIMABLE);
-		nfs_clear_page_tag_locked(req);
-	}
+	nfs_mark_list_commit(head);
 	nfs_commit_clear_lock(NFS_I(inode));
 	return -ENOMEM;
 }
-- 
1.6.2.5

