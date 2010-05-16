From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 20/22] pnfs_submit: filelayout: rewrite filelayout_commit to use new API
Date: Sat, 15 May 2010 21:23:11 -0400
Message-ID: <1273972993-15369-21-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
 <1273972993-15369-2-git-send-email-iisaman@netapp.com>
 <1273972993-15369-3-git-send-email-iisaman@netapp.com>
 <1273972993-15369-4-git-send-email-iisaman@netapp.com>
 <1273972993-15369-5-git-send-email-iisaman@netapp.com>
 <1273972993-15369-6-git-send-email-iisaman@netapp.com>
 <1273972993-15369-7-git-send-email-iisaman@netapp.com>
 <1273972993-15369-8-git-send-email-iisaman@netapp.com>
 <1273972993-15369-9-git-send-email-iisaman@netapp.com>
 <1273972993-15369-10-git-send-email-iisaman@netapp.com>
 <1273972993-15369-11-git-send-email-iisaman@netapp.com>
 <1273972993-15369-12-git-send-email-iisaman@netapp.com>
 <1273972993-15369-13-git-send-email-iisaman@netapp.com>
 <1273972993-15369-14-git-send-email-iisaman@netapp.com>
 <1273972993-15369-15-git-send-email-iisaman@netapp.com>
 <1273972993-15369-16-git-send-email-iisaman@netapp.com>
 <1273972993-15369-17-git-send-email-iisaman@netapp.com>
 <1273972993-15369-18-git-send-email-iisaman@netapp.com>
 <1273972993-15369-19-git-send-email-iisaman@netapp.com>
 <1273972993-15369-20-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754859Ab0ETKas (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:48 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQcA022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:47 -0700 (PDT)
In-Reply-To: <1273972993-15369-20-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the process, give it a much needed rewrite.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |  192 ++++++++++++++++++++++++++---------------------
 fs/nfs/write.c          |    9 ++
 2 files changed, 115 insertions(+), 86 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 789706e..6edecc7 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -530,8 +530,7 @@ filelayout_clone_write_data(struct nfs_write_data *old)
 	nfs_fattr_init(&new->fattr);
 	new->res.verf    = &new->verf;
 	new->args.context = get_nfs_open_context(old->args.context);
-	new->pdata.lseg = old->pdata.lseg;
-	kref_get(&new->pdata.lseg->kref);
+	new->pdata.lseg = NULL;
 	new->pdata.call_ops = old->pdata.call_ops;
 	new->pdata.how = old->pdata.how;
 out:
@@ -559,103 +558,124 @@ enum pnfs_try_status
 filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
 		  struct nfs_write_data *data)
 {
-	struct nfs4_filelayout_segment *nfslay;
-	struct nfs_write_data   *dsdata = NULL;
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
 	struct nfs4_pnfs_ds *ds;
-	struct nfs_page *req, *reqt;
-	struct list_head *pos, *tmp, head, head2;
-	loff_t file_offset, comp_offset;
-	enum pnfs_try_status trypnfs = PNFS_ATTEMPTED;
-	u32 idx1, idx2;
 
-	nfslay = LSEG_LD_DATA(data->pdata.lseg);
-
-	dprintk("%s data %p pnfs_client %p nfslay %p sync %d\n",
-		__func__, data, data->fldata.pnfs_client, nfslay, sync);
-
-	data->fldata.commit_through_mds = nfslay->commit_through_mds;
-	if (nfslay->commit_through_mds) {
-		dprintk("%s data %p commit through mds\n", __func__, data);
-		return PNFS_NOT_ATTEMPTED;
-	}
-
-	INIT_LIST_HEAD(&head);
-	INIT_LIST_HEAD(&head2);
-	list_add(&head, &data->pages);
-	list_del_init(&data->pages);
-
-	/* COMMIT to each Data Server */
-	while (!list_empty(&head)) {
-		req = nfs_list_entry(head.next);
-
-		file_offset = (loff_t)req->wb_index << PAGE_CACHE_SHIFT;
-
-		/* Get dserver for the current page */
-		idx1 = nfs4_fl_calc_ds_index(data->pdata.lseg, file_offset);
-		ds = nfs4_fl_prepare_ds(data->pdata.lseg, idx1);
-		if (!ds) {
-			data->pdata.pnfs_error = -EIO;
-			goto err_rewind;
+	dprintk("%s data %p pnfs_client %p sync %d\n",
+		__func__, data, data->fldata.pnfs_client, sync);
+
+	/* Alloc room for both in one go */
+	ds_page_list = kzalloc((NFS4_PNFS_MAX_MULTI_CNT + 1) *
+			       (sizeof(u16) + sizeof(struct list_head *)),
+			       GFP_KERNEL);
+	if (!ds_page_list)
+		goto mem_error;
+	indices_used = (u16 *) (ds_page_list + NFS4_PNFS_MAX_MULTI_CNT + 1);
+
+	/* Sort pages based on which ds to send to.
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
 		}
-
-		/* Gather all pages going to the current data server by
-		 * comparing their indices.
-		 * XXX: This recalculates the indices unecessarily.
-		 *      One idea would be to calc the index for every page
-		 *      and then compare if they are the same. */
-		list_for_each_safe(pos, tmp, &head) {
-			reqt = nfs_list_entry(pos);
-			comp_offset = (loff_t)reqt->wb_index << PAGE_CACHE_SHIFT;
-			idx2 = nfs4_fl_calc_ds_index(data->pdata.lseg,
-						     comp_offset);
-			if (idx1 == idx2) {
-				nfs_list_remove_request(reqt);
-				nfs_list_add_request(reqt, &head2);
-			}
+		if (ds_page_list[idx]) {
+			/* Already seen this idx */
+			list_add(&req->wb_list, ds_page_list[idx]);
+		} else {
+			/* New idx not seen so far */
+			list_add_tail(&req->wb_list, &head);
+			indices_used[num_indices_seen++] = idx;
 		}
-
-		if (!list_empty(&head)) {
-			dsdata = filelayout_clone_write_data(data);
-			if (!dsdata) {
-				/* return pages back to head */
-				list_splice(&head2, &head);
-				INIT_LIST_HEAD(&head2);
-				data->pdata.pnfs_error = -ENOMEM;
-				goto err_rewind;
-			}
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
+	/* Now send off the RPCs to each ds.  Note that it is important
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
 		} else {
-			dsdata = data;
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
+			dsdata->fldata.pnfs_client = clnt;
+			dsdata->fldata.ds_nfs_client = ds->ds_clp;
+			dsdata->args.fh = \
+				nfs4_fl_select_ds_fh(LSEG_LD_DATA(req->wb_lseg),
+						     idx);
 		}
-
-		list_add(&dsdata->pages, &head2);
-		list_del_init(&head2);
-
-		dsdata->fldata.pnfs_client = ds->ds_clp->cl_rpcclient;
-		dsdata->fldata.ds_nfs_client = ds->ds_clp;
-		dsdata->args.fh = nfs4_fl_select_ds_fh(nfslay, idx1);
-
 		dprintk("%s: Initiating commit: %llu USE DS:\n",
 			__func__, file_offset);
 		print_ds(ds);
 
 		/* Send COMMIT to data server */
-		nfs_initiate_commit(dsdata, dsdata->fldata.pnfs_client,
-				    &filelayout_commit_call_ops, sync);
+		nfs_initiate_commit(dsdata, clnt, call_ops, sync);
 	}
+	kfree(clone_list);
+	kfree(ds_page_list);
+	data->pdata.pnfs_error = 0;
+	return PNFS_ATTEMPTED;
 
-out:
-	if (data->pdata.pnfs_error)
-		printk(KERN_ERR "%s: ERROR %d\n", __func__,
-		       data->pdata.pnfs_error);
-
-	/* XXX should we send COMMIT to MDS e.g. not free data and return 1 ? */
-	return trypnfs;
-err_rewind:
-	/* put remaining pages back onto the original data->pages */
-	list_add(&data->pages, &head);
-	list_del_init(&head);
-	trypnfs = PNFS_NOT_ATTEMPTED;
-	goto out;
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
 }
 
 /* Return the stripesize for the specified file.
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 28e4907..48aa4a9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1461,6 +1461,15 @@ static void nfs_commit_release(void *calldata)
 			req->wb_bytes,
 			(long long)req_offset(req));
 		if (status < 0) {
+			if (req->wb_lseg) {
+				struct pnfs_layout_segment *lseg = req->wb_lseg;
+
+				req->wb_lseg = NULL;
+				put_lseg(lseg);
+				dprintk(" retry through MDS\n");
+				nfs_mark_request_dirty(req);
+				goto next;
+			}
 			nfs_context_set_write_error(req->wb_context, status);
 			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", status);
-- 
1.6.6.1

