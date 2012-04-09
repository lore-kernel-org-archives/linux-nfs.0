Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758236Ab2DIUxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:53:00 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/26] NFS: create nfs_commit_completion_ops
Date: Mon,  9 Apr 2012 16:52:20 -0400
Message-Id: <1334004744-31842-23-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Factors out the code that needs to change when directio
starts using these code paths.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/internal.h       |    5 ++---
 fs/nfs/nfs4filelayout.c |   12 ++++--------
 fs/nfs/write.c          |   31 +++++++++++++++++++++----------
 include/linux/nfs_xdr.h |    9 +++++++++
 4 files changed, 36 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index cbdea5e..d08f048 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -347,13 +347,12 @@ extern int nfs_initiate_commit(struct rpc_clnt *clnt,
 			       int how);
 extern void nfs_init_commit(struct nfs_commit_data *data,
 			    struct list_head *head,
-			    struct pnfs_layout_segment *lseg);
+			    struct pnfs_layout_segment *lseg,
+			    struct nfs_commit_info *cinfo);
 void nfs_retry_commit(struct list_head *page_list,
 		      struct pnfs_layout_segment *lseg,
 		      struct nfs_commit_info *cinfo);
-void nfs_commit_clear_lock(struct nfs_inode *nfsi);
 void nfs_commitdata_release(struct nfs_commit_data *data);
-void nfs_commit_release_pages(struct nfs_commit_data *data);
 void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *dst,
 				 struct nfs_commit_info *cinfo);
 void nfs_request_remove_commit_list(struct nfs_page *req,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index a1860ac..96a6141 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -347,12 +347,8 @@ static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
 static void filelayout_commit_release(void *calldata)
 {
 	struct nfs_commit_data *data = calldata;
-	struct nfs_commit_info cinfo;
 
-	nfs_commit_release_pages(data);
-	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
-	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
-		nfs_commit_clear_lock(NFS_I(data->inode));
+	data->compl_ops->completion(data);
 	put_lseg(data->lseg);
 	nfs_commitdata_release(data);
 }
@@ -1082,7 +1078,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 	nreq += alloc_ds_commits(cinfo, &list);
 
 	if (nreq == 0) {
-		nfs_commit_clear_lock(NFS_I(inode));
+		cinfo->compl_ops->error_cleanup(NFS_I(inode));
 		goto out;
 	}
 
@@ -1091,14 +1087,14 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 	list_for_each_entry_safe(data, tmp, &list, pages) {
 		list_del_init(&data->pages);
 		if (!data->lseg) {
-			nfs_init_commit(data, mds_pages, NULL);
+			nfs_init_commit(data, mds_pages, NULL, cinfo);
 			nfs_initiate_commit(NFS_CLIENT(inode), data,
 					    data->mds_ops, how);
 		} else {
 			struct pnfs_commit_bucket *buckets;
 
 			buckets = cinfo->ds->buckets;
-			nfs_init_commit(data, &buckets[data->ds_commit_index].committing, data->lseg);
+			nfs_init_commit(data, &buckets[data->ds_commit_index].committing, data->lseg, cinfo);
 			filelayout_initiate_commit(data, how);
 		}
 	}
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 30dcc4f..ceb3979 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -46,6 +46,7 @@ static void nfs_redirty_request(struct nfs_page *req);
 static const struct rpc_call_ops nfs_write_common_ops;
 static const struct rpc_call_ops nfs_commit_ops;
 static const struct nfs_io_completion_ops nfs_asynch_write_compl_ops;
+static const struct nfs_commit_completion_ops nfs_commit_compl_ops;
 
 static struct kmem_cache *nfs_wdata_cachep;
 static mempool_t *nfs_wdata_mempool;
@@ -499,6 +500,7 @@ static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
 	cinfo->lock = &inode->i_lock;
 	cinfo->mds = &NFS_I(inode)->commit_info;
 	cinfo->ds = pnfs_get_ds_info(inode);
+	cinfo->compl_ops = &nfs_commit_compl_ops;
 }
 
 void nfs_init_cinfo(struct nfs_commit_info *cinfo,
@@ -1356,13 +1358,12 @@ static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 	return (ret < 0) ? ret : 1;
 }
 
-void nfs_commit_clear_lock(struct nfs_inode *nfsi)
+static void nfs_commit_clear_lock(struct nfs_inode *nfsi)
 {
 	clear_bit(NFS_INO_COMMIT, &nfsi->flags);
 	smp_mb__after_clear_bit();
 	wake_up_bit(&nfsi->flags, NFS_INO_COMMIT);
 }
-EXPORT_SYMBOL_GPL(nfs_commit_clear_lock);
 
 void nfs_commitdata_release(struct nfs_commit_data *data)
 {
@@ -1411,8 +1412,9 @@ EXPORT_SYMBOL_GPL(nfs_initiate_commit);
  * Set up the argument/result storage required for the RPC call.
  */
 void nfs_init_commit(struct nfs_commit_data *data,
-			    struct list_head *head,
-			    struct pnfs_layout_segment *lseg)
+		     struct list_head *head,
+		     struct pnfs_layout_segment *lseg,
+		     struct nfs_commit_info *cinfo)
 {
 	struct nfs_page *first = nfs_list_entry(head->next);
 	struct inode *inode = first->wb_context->dentry->d_inode;
@@ -1426,6 +1428,7 @@ void nfs_init_commit(struct nfs_commit_data *data,
 	data->cred	  = first->wb_context->cred;
 	data->lseg	  = lseg; /* reference transferred */
 	data->mds_ops     = &nfs_commit_ops;
+	data->compl_ops	  = cinfo->compl_ops;
 
 	data->args.fh     = NFS_FH(data->inode);
 	/* Note: we always request a commit of the entire inode */
@@ -1471,11 +1474,12 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how,
 		goto out_bad;
 
 	/* Set up the argument struct */
-	nfs_init_commit(data, head, NULL);
+	nfs_init_commit(data, head, NULL, cinfo);
+	atomic_inc(&cinfo->mds->rpcs_out);
 	return nfs_initiate_commit(NFS_CLIENT(inode), data, data->mds_ops, how);
  out_bad:
 	nfs_retry_commit(head, NULL, cinfo);
-	nfs_commit_clear_lock(NFS_I(inode));
+	cinfo->compl_ops->error_cleanup(NFS_I(inode));
 	return -ENOMEM;
 }
 
@@ -1493,10 +1497,11 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 	NFS_PROTO(data->inode)->commit_done(task, data);
 }
 
-void nfs_commit_release_pages(struct nfs_commit_data *data)
+static void nfs_commit_release_pages(struct nfs_commit_data *data)
 {
 	struct nfs_page	*req;
 	int status = data->task.tk_status;
+	struct nfs_commit_info cinfo;
 
 	while (!list_empty(&data->pages)) {
 		req = nfs_list_entry(data->pages.next);
@@ -1529,15 +1534,16 @@ void nfs_commit_release_pages(struct nfs_commit_data *data)
 	next:
 		nfs_unlock_request(req);
 	}
+	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
+	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
+		nfs_commit_clear_lock(NFS_I(data->inode));
 }
-EXPORT_SYMBOL_GPL(nfs_commit_release_pages);
 
 static void nfs_commit_release(void *calldata)
 {
 	struct nfs_commit_data *data = calldata;
 
-	nfs_commit_release_pages(data);
-	nfs_commit_clear_lock(NFS_I(data->inode));
+	data->compl_ops->completion(data);
 	nfs_commitdata_release(calldata);
 }
 
@@ -1547,6 +1553,11 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_release = nfs_commit_release,
 };
 
+static const struct nfs_commit_completion_ops nfs_commit_compl_ops = {
+	.completion = nfs_commit_release_pages,
+	.error_cleanup = nfs_commit_clear_lock,
+};
+
 static int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
 				   int how, struct nfs_commit_info *cinfo)
 {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 646100c..0ee7b3a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1258,10 +1258,18 @@ struct nfs_mds_commit_info {
 	struct list_head	list;
 };
 
+struct nfs_commit_data;
+struct nfs_inode;
+struct nfs_commit_completion_ops {
+	void (*error_cleanup) (struct nfs_inode *nfsi);
+	void (*completion) (struct nfs_commit_data *data);
+};
+
 struct nfs_commit_info {
 	spinlock_t			*lock;
 	struct nfs_mds_commit_info	*mds;
 	struct pnfs_ds_commit_info	*ds;
+	const struct nfs_commit_completion_ops *compl_ops;
 };
 
 struct nfs_commit_data {
@@ -1280,6 +1288,7 @@ struct nfs_commit_data {
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 	int			ds_commit_index;
 	const struct rpc_call_ops *mds_ops;
+	const struct nfs_commit_completion_ops *compl_ops;
 	int (*commit_done_cb) (struct rpc_task *task, struct nfs_commit_data *data);
 };
 
-- 
1.7.2.1

