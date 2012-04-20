Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34188 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757405Ab2DTSgs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:36:48 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 07/28] NFS: add a struct nfs_commit_data to replace nfs_write_data in commits
Date: Fri, 20 Apr 2012 14:35:49 -0400
Message-Id: <1334946970-27470-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
References: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commits don't need the vectors of pages, etc. that writes do. Split out
a separate structure for the commit operation.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c         |   17 +++++-------
 fs/nfs/internal.h       |   13 +++++----
 fs/nfs/nfs3proc.c       |   10 ++++++-
 fs/nfs/nfs3xdr.c        |    6 ++--
 fs/nfs/nfs4filelayout.c |   65 +++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4proc.c       |   23 ++++++++++++----
 fs/nfs/nfs4xdr.c        |    8 +++---
 fs/nfs/proc.c           |    8 +++++-
 fs/nfs/write.c          |   50 +++++++++++++++++++++--------------
 include/linux/nfs_fs.h  |    4 +-
 include/linux/nfs_xdr.h |   45 ++++++++++++++++++++++++++++++--
 11 files changed, 173 insertions(+), 76 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 8a89423..5897dfe 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -82,7 +82,7 @@ struct nfs_direct_req {
 
 	/* commit state */
 	struct list_head	rewrite_list;	/* saved nfs_write_data structs */
-	struct nfs_write_data *	commit_data;	/* special write_data for commits */
+	struct nfs_commit_data *commit_data;	/* special write_data for commits */
 	int			flags;
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
@@ -524,7 +524,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 
 static void nfs_direct_commit_result(struct rpc_task *task, void *calldata)
 {
-	struct nfs_write_data *data = calldata;
+	struct nfs_commit_data *data = calldata;
 
 	/* Call the NFS version-specific code */
 	NFS_PROTO(data->inode)->commit_done(task, data);
@@ -532,8 +532,8 @@ static void nfs_direct_commit_result(struct rpc_task *task, void *calldata)
 
 static void nfs_direct_commit_release(void *calldata)
 {
-	struct nfs_write_data *data = calldata;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+	struct nfs_commit_data *data = calldata;
+	struct nfs_direct_req *dreq = data->dreq;
 	int status = data->task.tk_status;
 
 	if (status < 0) {
@@ -551,14 +551,14 @@ static void nfs_direct_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_direct_ops = {
-	.rpc_call_prepare = nfs_write_prepare,
+	.rpc_call_prepare = nfs_commit_prepare,
 	.rpc_call_done = nfs_direct_commit_result,
 	.rpc_release = nfs_direct_commit_release,
 };
 
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 {
-	struct nfs_write_data *data = dreq->commit_data;
+	struct nfs_commit_data *data = dreq->commit_data;
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
@@ -581,9 +581,6 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->args.fh = NFS_FH(data->inode);
 	data->args.offset = 0;
 	data->args.count = 0;
-	data->args.context = dreq->ctx;
-	data->args.lock_context = dreq->l_ctx;
-	data->res.count = 0;
 	data->res.fattr = &data->fattr;
 	data->res.verf = &data->verf;
 	nfs_fattr_init(&data->fattr);
@@ -625,7 +622,7 @@ static void nfs_alloc_commit_data(struct nfs_direct_req *dreq)
 {
 	dreq->commit_data = nfs_commitdata_alloc();
 	if (dreq->commit_data != NULL)
-		dreq->commit_data->req = (struct nfs_page *) dreq;
+		dreq->commit_data->dreq = dreq;
 }
 #else
 static inline void nfs_alloc_commit_data(struct nfs_direct_req *dreq)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2476dc6..87e899d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -314,24 +314,25 @@ extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_writedata_release(struct nfs_write_data *wdata);
-extern void nfs_commit_free(struct nfs_write_data *p);
+extern void nfs_commit_free(struct nfs_commit_data *p);
 extern int nfs_initiate_write(struct nfs_write_data *data,
 			      struct rpc_clnt *clnt,
 			      const struct rpc_call_ops *call_ops,
 			      int how);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
-extern int nfs_initiate_commit(struct nfs_write_data *data,
-			       struct rpc_clnt *clnt,
+extern void nfs_commit_prepare(struct rpc_task *task, void *calldata);
+extern int nfs_initiate_commit(struct rpc_clnt *clnt,
+			       struct nfs_commit_data *data,
 			       const struct rpc_call_ops *call_ops,
 			       int how);
-extern void nfs_init_commit(struct nfs_write_data *data,
+extern void nfs_init_commit(struct nfs_commit_data *data,
 			    struct list_head *head,
 			    struct pnfs_layout_segment *lseg);
 void nfs_retry_commit(struct list_head *page_list,
 		      struct pnfs_layout_segment *lseg);
 void nfs_commit_clear_lock(struct nfs_inode *nfsi);
-void nfs_commitdata_release(void *data);
-void nfs_commit_release_pages(struct nfs_write_data *data);
+void nfs_commitdata_release(struct nfs_commit_data *data);
+void nfs_commit_release_pages(struct nfs_commit_data *data);
 void nfs_request_add_commit_list(struct nfs_page *req, struct list_head *head);
 void nfs_request_remove_commit_list(struct nfs_page *req);
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 5242eae..b1daca7 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -848,7 +848,12 @@ static void nfs3_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_
 	rpc_call_start(task);
 }
 
-static int nfs3_commit_done(struct rpc_task *task, struct nfs_write_data *data)
+static void nfs3_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
+{
+	rpc_call_start(task);
+}
+
+static int nfs3_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 {
 	if (nfs3_async_handle_jukebox(task, data->inode))
 		return -EAGAIN;
@@ -856,7 +861,7 @@ static int nfs3_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	return 0;
 }
 
-static void nfs3_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
+static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
 {
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_COMMIT];
 }
@@ -907,6 +912,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.write_rpc_prepare = nfs3_proc_write_rpc_prepare,
 	.write_done	= nfs3_write_done,
 	.commit_setup	= nfs3_proc_commit_setup,
+	.commit_rpc_prepare = nfs3_proc_commit_rpc_prepare,
 	.commit_done	= nfs3_commit_done,
 	.lock		= nfs3_proc_lock,
 	.clear_acl_cache = nfs3_forget_cached_acls,
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index a77cc9a..01e53e9 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1287,7 +1287,7 @@ static void nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req,
  *	};
  */
 static void encode_commit3args(struct xdr_stream *xdr,
-			       const struct nfs_writeargs *args)
+			       const struct nfs_commitargs *args)
 {
 	__be32 *p;
 
@@ -1300,7 +1300,7 @@ static void encode_commit3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_commit3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_writeargs *args)
+				     const struct nfs_commitargs *args)
 {
 	encode_commit3args(xdr, args);
 }
@@ -2319,7 +2319,7 @@ out_status:
  */
 static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_writeres *result)
+				   struct nfs_commitres *result)
 {
 	enum nfs_stat status;
 	int error;
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 15aeba2..675ce3b 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -250,7 +250,7 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 }
 
 /* Fake up some data that will cause nfs_commit_release to retry the writes. */
-static void prepare_to_resend_writes(struct nfs_write_data *data)
+static void prepare_to_resend_writes(struct nfs_commit_data *data)
 {
 	struct nfs_page *first = nfs_list_entry(data->pages.next);
 
@@ -261,11 +261,11 @@ static void prepare_to_resend_writes(struct nfs_write_data *data)
 }
 
 static int filelayout_commit_done_cb(struct rpc_task *task,
-				     struct nfs_write_data *data)
+				     struct nfs_commit_data *data)
 {
 	int reset = 0;
 
-	if (filelayout_async_handle_error(task, data->args.context->state,
+	if (filelayout_async_handle_error(task, data->context->state,
 					  data->ds_clp, &reset) == -EAGAIN) {
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
@@ -315,15 +315,42 @@ static void filelayout_write_release(void *data)
 	wdata->mds_ops->rpc_release(data);
 }
 
-static void filelayout_commit_release(void *data)
+static void filelayout_commit_prepare(struct rpc_task *task, void *data)
 {
-	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
+	struct nfs_commit_data *wdata = data;
 
-	nfs_commit_release_pages(wdata);
-	if (atomic_dec_and_test(&NFS_I(wdata->inode)->commits_outstanding))
-		nfs_commit_clear_lock(NFS_I(wdata->inode));
-	put_lseg(wdata->lseg);
-	nfs_commitdata_release(wdata);
+	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
+				&wdata->args.seq_args, &wdata->res.seq_res,
+				task))
+		return;
+
+	rpc_call_start(task);
+}
+
+static void filelayout_write_commit_done(struct rpc_task *task, void *data)
+{
+	struct nfs_commit_data *wdata = data;
+
+	/* Note this may cause RPC to be resent */
+	wdata->mds_ops->rpc_call_done(task, data);
+}
+
+static void filelayout_commit_count_stats(struct rpc_task *task, void *data)
+{
+	struct nfs_commit_data *cdata = data;
+
+	rpc_count_iostats(task, NFS_SERVER(cdata->inode)->client->cl_metrics);
+}
+
+static void filelayout_commit_release(void *calldata)
+{
+	struct nfs_commit_data *data = calldata;
+
+	nfs_commit_release_pages(data);
+	if (atomic_dec_and_test(&NFS_I(data->inode)->commits_outstanding))
+		nfs_commit_clear_lock(NFS_I(data->inode));
+	put_lseg(data->lseg);
+	nfs_commitdata_release(data);
 }
 
 static const struct rpc_call_ops filelayout_read_call_ops = {
@@ -341,9 +368,9 @@ static const struct rpc_call_ops filelayout_write_call_ops = {
 };
 
 static const struct rpc_call_ops filelayout_commit_call_ops = {
-	.rpc_call_prepare = filelayout_write_prepare,
-	.rpc_call_done = filelayout_write_call_done,
-	.rpc_count_stats = filelayout_write_count_stats,
+	.rpc_call_prepare = filelayout_commit_prepare,
+	.rpc_call_done = filelayout_write_commit_done,
+	.rpc_count_stats = filelayout_commit_count_stats,
 	.rpc_release = filelayout_commit_release,
 };
 
@@ -922,7 +949,7 @@ select_ds_fh_from_commit(struct pnfs_layout_segment *lseg, u32 i)
 	return flseg->fh_array[i];
 }
 
-static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
+static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 {
 	struct pnfs_layout_segment *lseg = data->lseg;
 	struct nfs4_pnfs_ds *ds;
@@ -941,12 +968,12 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 		return -EAGAIN;
 	}
 	dprintk("%s ino %lu, how %d\n", __func__, data->inode->i_ino, how);
-	data->write_done_cb = filelayout_commit_done_cb;
+	data->commit_done_cb = filelayout_commit_done_cb;
 	data->ds_clp = ds->ds_clp;
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
 		data->args.fh = fh;
-	return nfs_initiate_commit(data, ds->ds_clp->cl_rpcclient,
+	return nfs_initiate_commit(ds->ds_clp->cl_rpcclient, data,
 				   &filelayout_commit_call_ops, how);
 }
 
@@ -1008,7 +1035,7 @@ alloc_ds_commits(struct inode *inode, struct list_head *list)
 {
 	struct nfs4_fl_commit_info *fl_cinfo;
 	struct nfs4_fl_commit_bucket *bucket;
-	struct nfs_write_data *data;
+	struct nfs_commit_data *data;
 	int i, j;
 	unsigned int nreq = 0;
 
@@ -1044,7 +1071,7 @@ static int
 filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 			   int how)
 {
-	struct nfs_write_data	*data, *tmp;
+	struct nfs_commit_data *data, *tmp;
 	LIST_HEAD(list);
 	unsigned int nreq = 0;
 
@@ -1071,7 +1098,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 		list_del_init(&data->pages);
 		if (!data->lseg) {
 			nfs_init_commit(data, mds_pages, NULL);
-			nfs_initiate_commit(data, NFS_CLIENT(inode),
+			nfs_initiate_commit(NFS_CLIENT(inode), data,
 					    data->mds_ops, how);
 		} else {
 			struct nfs4_fl_commit_info *fl_cinfo;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f82bde0..54f6268 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3413,7 +3413,17 @@ static void nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_
 	rpc_call_start(task);
 }
 
-static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_write_data *data)
+static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
+{
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+				&data->args.seq_args,
+				&data->res.seq_res,
+				task))
+		return;
+	rpc_call_start(task);
+}
+
+static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_commit_data *data)
 {
 	struct inode *inode = data->inode;
 
@@ -3425,14 +3435,14 @@ static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_write_data *dat
 	return 0;
 }
 
-static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
+static int nfs4_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 {
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
-	return data->write_done_cb(task, data);
+	return data->commit_done_cb(task, data);
 }
 
-static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
+static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
@@ -3441,8 +3451,8 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 		data->res.fattr = NULL;
 	} else
 		data->args.bitmask = server->cache_consistency_bitmask;
-	if (!data->write_done_cb)
-		data->write_done_cb = nfs4_commit_done_cb;
+	if (data->commit_done_cb == NULL)
+		data->commit_done_cb = nfs4_commit_done_cb;
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
@@ -6498,6 +6508,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.write_rpc_prepare = nfs4_proc_write_rpc_prepare,
 	.write_done	= nfs4_write_done,
 	.commit_setup	= nfs4_proc_commit_setup,
+	.commit_rpc_prepare = nfs4_proc_commit_rpc_prepare,
 	.commit_done	= nfs4_commit_done,
 	.lock		= nfs4_proc_lock,
 	.clear_acl_cache = nfs4_zap_acl_attr,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c74fdb1..c7ed9cb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1103,7 +1103,7 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 	encode_nfs4_stateid(xdr, arg->stateid);
 }
 
-static void encode_commit(struct xdr_stream *xdr, const struct nfs_writeargs *args, struct compound_hdr *hdr)
+static void encode_commit(struct xdr_stream *xdr, const struct nfs_commitargs *args, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -2447,7 +2447,7 @@ static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
  *  a COMMIT request
  */
 static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_writeargs *args)
+				struct nfs_commitargs *args)
 {
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
@@ -4101,7 +4101,7 @@ static int decode_verifier(struct xdr_stream *xdr, void *verifier)
 	return decode_opaque_fixed(xdr, verifier, NFS4_VERIFIER_SIZE);
 }
 
-static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
+static int decode_commit(struct xdr_stream *xdr, struct nfs_commitres *res)
 {
 	int status;
 
@@ -6336,7 +6336,7 @@ out:
  * Decode COMMIT response
  */
 static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs_writeres *res)
+			       struct nfs_commitres *res)
 {
 	struct compound_hdr hdr;
 	int status;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b63b6f4..bf80503 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -688,8 +688,13 @@ static void nfs_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_d
 	rpc_call_start(task);
 }
 
+static void nfs_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
+{
+	BUG();
+}
+
 static void
-nfs_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
+nfs_proc_commit_setup(struct nfs_commit_data *data, struct rpc_message *msg)
 {
 	BUG();
 }
@@ -764,6 +769,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.write_rpc_prepare = nfs_proc_write_rpc_prepare,
 	.write_done	= nfs_write_done,
 	.commit_setup	= nfs_proc_commit_setup,
+	.commit_rpc_prepare = nfs_proc_commit_rpc_prepare,
 	.lock		= nfs_proc_lock,
 	.lock_check_bounds = nfs_lock_check_bounds,
 	.close_context	= nfs_close_context,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c074623..54f7c0f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -48,11 +48,12 @@ static const struct rpc_call_ops nfs_commit_ops;
 
 static struct kmem_cache *nfs_wdata_cachep;
 static mempool_t *nfs_wdata_mempool;
+static struct kmem_cache *nfs_cdata_cachep;
 static mempool_t *nfs_commit_mempool;
 
-struct nfs_write_data *nfs_commitdata_alloc(void)
+struct nfs_commit_data *nfs_commitdata_alloc(void)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOFS);
+	struct nfs_commit_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOFS);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -62,10 +63,8 @@ struct nfs_write_data *nfs_commitdata_alloc(void)
 }
 EXPORT_SYMBOL_GPL(nfs_commitdata_alloc);
 
-void nfs_commit_free(struct nfs_write_data *p)
+void nfs_commit_free(struct nfs_commit_data *p)
 {
-	if (p && (p->pagevec != &p->page_array[0]))
-		kfree(p->pagevec);
 	mempool_free(p, nfs_commit_mempool);
 }
 EXPORT_SYMBOL_GPL(nfs_commit_free);
@@ -1179,6 +1178,13 @@ void nfs_write_prepare(struct rpc_task *task, void *calldata)
 	NFS_PROTO(data->inode)->write_rpc_prepare(task, data);
 }
 
+void nfs_commit_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_commit_data *data = calldata;
+
+	NFS_PROTO(data->inode)->commit_rpc_prepare(task, data);
+}
+
 static const struct rpc_call_ops nfs_write_partial_ops = {
 	.rpc_call_prepare = nfs_write_prepare,
 	.rpc_call_done = nfs_writeback_done_partial,
@@ -1355,16 +1361,14 @@ void nfs_commit_clear_lock(struct nfs_inode *nfsi)
 }
 EXPORT_SYMBOL_GPL(nfs_commit_clear_lock);
 
-void nfs_commitdata_release(void *data)
+void nfs_commitdata_release(struct nfs_commit_data *data)
 {
-	struct nfs_write_data *wdata = data;
-
-	put_nfs_open_context(wdata->args.context);
-	nfs_commit_free(wdata);
+	put_nfs_open_context(data->context);
+	nfs_commit_free(data);
 }
 EXPORT_SYMBOL_GPL(nfs_commitdata_release);
 
-int nfs_initiate_commit(struct nfs_write_data *data, struct rpc_clnt *clnt,
+int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 			const struct rpc_call_ops *call_ops,
 			int how)
 {
@@ -1403,7 +1407,7 @@ EXPORT_SYMBOL_GPL(nfs_initiate_commit);
 /*
  * Set up the argument/result storage required for the RPC call.
  */
-void nfs_init_commit(struct nfs_write_data *data,
+void nfs_init_commit(struct nfs_commit_data *data,
 			    struct list_head *head,
 			    struct pnfs_layout_segment *lseg)
 {
@@ -1424,8 +1428,7 @@ void nfs_init_commit(struct nfs_write_data *data,
 	/* Note: we always request a commit of the entire inode */
 	data->args.offset = 0;
 	data->args.count  = 0;
-	data->args.context = get_nfs_open_context(first->wb_context);
-	data->res.count   = 0;
+	data->context     = get_nfs_open_context(first->wb_context);
 	data->res.fattr   = &data->fattr;
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
@@ -1455,7 +1458,7 @@ EXPORT_SYMBOL_GPL(nfs_retry_commit);
 static int
 nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 {
-	struct nfs_write_data	*data;
+	struct nfs_commit_data	*data;
 
 	data = nfs_commitdata_alloc();
 
@@ -1464,7 +1467,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 
 	/* Set up the argument struct */
 	nfs_init_commit(data, head, NULL);
-	return nfs_initiate_commit(data, NFS_CLIENT(inode), data->mds_ops, how);
+	return nfs_initiate_commit(NFS_CLIENT(inode), data, data->mds_ops, how);
  out_bad:
 	nfs_retry_commit(head, NULL);
 	nfs_commit_clear_lock(NFS_I(inode));
@@ -1476,7 +1479,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
  */
 static void nfs_commit_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs_write_data	*data = calldata;
+	struct nfs_commit_data	*data = calldata;
 
         dprintk("NFS: %5u nfs_commit_done (status %d)\n",
                                 task->tk_pid, task->tk_status);
@@ -1485,7 +1488,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 	NFS_PROTO(data->inode)->commit_done(task, data);
 }
 
-void nfs_commit_release_pages(struct nfs_write_data *data)
+void nfs_commit_release_pages(struct nfs_commit_data *data)
 {
 	struct nfs_page	*req;
 	int status = data->task.tk_status;
@@ -1526,7 +1529,7 @@ EXPORT_SYMBOL_GPL(nfs_commit_release_pages);
 
 static void nfs_commit_release(void *calldata)
 {
-	struct nfs_write_data *data = calldata;
+	struct nfs_commit_data *data = calldata;
 
 	nfs_commit_release_pages(data);
 	nfs_commit_clear_lock(NFS_I(data->inode));
@@ -1534,7 +1537,7 @@ static void nfs_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
-	.rpc_call_prepare = nfs_write_prepare,
+	.rpc_call_prepare = nfs_commit_prepare,
 	.rpc_call_done = nfs_commit_done,
 	.rpc_release = nfs_commit_release,
 };
@@ -1753,6 +1756,13 @@ int __init nfs_init_writepagecache(void)
 	if (nfs_wdata_mempool == NULL)
 		return -ENOMEM;
 
+	nfs_cdata_cachep = kmem_cache_create("nfs_commit_data",
+					     sizeof(struct nfs_commit_data),
+					     0, SLAB_HWCACHE_ALIGN,
+					     NULL);
+	if (nfs_cdata_cachep == NULL)
+		return -ENOMEM;
+
 	nfs_commit_mempool = mempool_create_slab_pool(MIN_POOL_COMMIT,
 						      nfs_wdata_cachep);
 	if (nfs_commit_mempool == NULL)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 52a1bdb..d5d68f3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -552,8 +552,8 @@ extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
-extern struct nfs_write_data *nfs_commitdata_alloc(void);
-extern void nfs_commit_free(struct nfs_write_data *wdata);
+extern struct nfs_commit_data *nfs_commitdata_alloc(void);
+extern void nfs_commit_free(struct nfs_commit_data *data);
 #else
 static inline int
 nfs_commit_inode(struct inode *inode, int how)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bfd0d1b..2aff66d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -514,6 +514,24 @@ struct nfs_writeres {
 };
 
 /*
+ * Arguments to the commit call.
+ */
+struct nfs_commitargs {
+	struct nfs_fh		*fh;
+	__u64			offset;
+	__u32			count;
+	const u32		*bitmask;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs_commitres {
+	struct nfs_fattr	*fattr;
+	struct nfs_writeverf	*verf;
+	const struct nfs_server *server;
+	struct nfs4_sequence_res	seq_res;
+};
+
+/*
  * Common arguments to the unlink call
  */
 struct nfs_removeargs {
@@ -1166,6 +1184,8 @@ struct nfs_read_data {
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
+struct nfs_direct_req;
+
 struct nfs_write_data {
 	struct rpc_task		task;
 	struct inode		*inode;
@@ -1181,7 +1201,6 @@ struct nfs_write_data {
 	struct nfs_writeres	res;		/* result struct */
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
-	int			ds_commit_index;
 	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
 #ifdef CONFIG_NFS_V4
@@ -1192,6 +1211,25 @@ struct nfs_write_data {
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
 
+struct nfs_commit_data {
+	struct rpc_task		task;
+	struct inode		*inode;
+	struct rpc_cred		*cred;
+	struct nfs_fattr	fattr;
+	struct nfs_writeverf	verf;
+	struct list_head	pages;		/* Coalesced requests we wish to flush */
+	struct list_head	list;		/* lists of struct nfs_write_data */
+	struct nfs_direct_req	*dreq;		/* O_DIRECT request */
+	struct nfs_commitargs	args;		/* argument struct */
+	struct nfs_commitres	res;		/* result struct */
+	struct nfs_open_context *context;
+	struct pnfs_layout_segment *lseg;
+	struct nfs_client	*ds_clp;	/* pNFS data server */
+	int			ds_commit_index;
+	const struct rpc_call_ops *mds_ops;
+	int (*commit_done_cb) (struct rpc_task *task, struct nfs_commit_data *data);
+};
+
 struct nfs_unlinkdata {
 	struct hlist_node list;
 	struct nfs_removeargs args;
@@ -1272,8 +1310,9 @@ struct nfs_rpc_ops {
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
 	void	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
 	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
-	void	(*commit_setup) (struct nfs_write_data *, struct rpc_message *);
-	int	(*commit_done) (struct rpc_task *, struct nfs_write_data *);
+	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
+	void	(*commit_rpc_prepare)(struct rpc_task *, struct nfs_commit_data *);
+	int	(*commit_done) (struct rpc_task *, struct nfs_commit_data *);
 	int	(*lock)(struct file *, int, struct file_lock *);
 	int	(*lock_check_bounds)(const struct file_lock *);
 	void	(*clear_acl_cache)(struct inode *);
-- 
1.7.2.1

