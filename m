Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13901 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758229Ab2DIUxO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:53:14 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 26/26] NFS: rewrite directio write to use async coalesce code
Date: Mon,  9 Apr 2012 16:52:24 -0400
Message-Id: <1334004744-31842-27-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This also has the advantage that it allows directio to use pnfs.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c         |  514 ++++++++++++++++++++---------------------------
 fs/nfs/internal.h       |   16 ++
 fs/nfs/nfs4filelayout.c |   44 ++++-
 fs/nfs/pnfs.h           |   17 ++
 fs/nfs/write.c          |   32 ++--
 5 files changed, 307 insertions(+), 316 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 409a9a0..bd25e9e 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -56,6 +56,7 @@
 
 #include "internal.h"
 #include "iostat.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -81,16 +82,19 @@ struct nfs_direct_req {
 	struct completion	completion;	/* wait for i/o completion */
 
 	/* commit state */
-	struct list_head	rewrite_list;	/* saved nfs_write_data structs */
-	struct nfs_commit_data *commit_data;	/* special write_data for commits */
+	struct nfs_mds_commit_info mds_cinfo;	/* Storage for cinfo */
+	struct pnfs_ds_commit_info ds_cinfo;	/* Storage for cinfo */
+	struct work_struct	work;
 	int			flags;
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
 	struct nfs_writeverf	verf;		/* unstable write verifier */
 };
 
+static const struct nfs_io_completion_ops nfs_direct_write_compl_ops;
+static const struct nfs_commit_completion_ops nfs_direct_commit_compl_ops;
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode);
-static const struct rpc_call_ops nfs_write_direct_ops;
+static void nfs_direct_write_schedule_work(struct work_struct *work);
 
 static inline void get_dreq(struct nfs_direct_req *dreq)
 {
@@ -131,6 +135,16 @@ static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 		page_cache_release(pages[i]);
 }
 
+void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
+			      struct nfs_direct_req *dreq)
+{
+	cinfo->lock = &dreq->lock;
+	cinfo->mds = &dreq->mds_cinfo;
+	cinfo->ds = &dreq->ds_cinfo;
+	cinfo->dreq = dreq;
+	cinfo->compl_ops = &nfs_direct_commit_compl_ops;
+}
+
 static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 {
 	struct nfs_direct_req *dreq;
@@ -142,7 +156,10 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 	kref_init(&dreq->kref);
 	kref_get(&dreq->kref);
 	init_completion(&dreq->completion);
-	INIT_LIST_HEAD(&dreq->rewrite_list);
+	dreq->mds_cinfo.ncommit = 0;
+	INIT_LIST_HEAD(&dreq->mds_cinfo.list);
+	INIT_WORK(&dreq->work, nfs_direct_write_schedule_work);
+	memset(&dreq->ds_cinfo, 0, sizeof(dreq->ds_cinfo));
 	dreq->iocb = NULL;
 	dreq->ctx = NULL;
 	dreq->l_ctx = NULL;
@@ -449,112 +466,60 @@ out:
 	return result;
 }
 
-static void nfs_direct_writehdr_release(struct nfs_write_header *whdr)
-{
-	struct nfs_write_data *data = &whdr->rpc_data;
-
-	if (data->pages.pagevec != data->pages.page_array)
-		kfree(data->pages.pagevec);
-	nfs_writehdr_free(&whdr->header);
-}
-
-static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
-{
-	while (!list_empty(&dreq->rewrite_list)) {
-		struct nfs_pgio_header *hdr = list_entry(dreq->rewrite_list.next, struct nfs_pgio_header, pages);
-		struct nfs_write_header *whdr = container_of(hdr, struct nfs_write_header, header);
-		struct nfs_page_array *p = &whdr->rpc_data.pages;
-
-		list_del(&hdr->pages);
-		nfs_direct_release_pages(p->pagevec, p->npages);
-		nfs_direct_writehdr_release(whdr);
-	}
-}
-
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
-	struct inode *inode = dreq->inode;
-	struct list_head *p;
-	struct nfs_write_data *data;
-	struct nfs_pgio_header *hdr;
-	struct rpc_task *task;
-	struct rpc_message msg = {
-		.rpc_cred = dreq->ctx->cred,
-	};
-	struct rpc_task_setup task_setup_data = {
-		.rpc_client = NFS_CLIENT(inode),
-		.rpc_message = &msg,
-		.callback_ops = &nfs_write_direct_ops,
-		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
-	};
+	struct nfs_pageio_descriptor desc;
+	struct nfs_page *req, *tmp;
+	LIST_HEAD(reqs);
+	struct nfs_commit_info cinfo;
+	LIST_HEAD(failed);
+
+	nfs_init_cinfo_from_dreq(&cinfo, dreq);
+	pnfs_recover_commit_reqs(dreq->inode, &reqs, &cinfo);
+	spin_lock(cinfo.lock);
+	nfs_scan_commit_list(&cinfo.mds->list, &reqs, &cinfo, 0);
+	spin_unlock(cinfo.lock);
 
 	dreq->count = 0;
 	get_dreq(dreq);
 
-	list_for_each(p, &dreq->rewrite_list) {
-		hdr = list_entry(p, struct nfs_pgio_header, pages);
-		data = &(container_of(hdr, struct nfs_write_header, header))->rpc_data;
-
-		get_dreq(dreq);
-
-		/* Use stable writes */
-		data->args.stable = NFS_FILE_SYNC;
-
-		/*
-		 * Reset data->res.
-		 */
-		nfs_fattr_init(&data->fattr);
-		data->res.count = data->args.count;
-		memset(&data->verf, 0, sizeof(data->verf));
-
-		/*
-		 * Reuse data->task; data->args should not have changed
-		 * since the original request was sent.
-		 */
-		task_setup_data.task = &data->task;
-		task_setup_data.callback_data = data;
-		msg.rpc_argp = &data->args;
-		msg.rpc_resp = &data->res;
-		NFS_PROTO(inode)->write_setup(data, &msg);
-
-		/*
-		 * We're called via an RPC callback, so BKL is already held.
-		 */
-		task = rpc_run_task(&task_setup_data);
-		if (!IS_ERR(task))
-			rpc_put_task(task);
-
-		dprintk("NFS: %5u rescheduled direct write call (req %s/%Ld, %u bytes @ offset %Lu)\n",
-				data->task.tk_pid,
-				inode->i_sb->s_id,
-				(long long)NFS_FILEID(inode),
-				data->args.count,
-				(unsigned long long)data->args.offset);
-	}
+	nfs_pageio_init_write(&desc, dreq->inode, FLUSH_STABLE,
+			      &nfs_direct_write_compl_ops);
+	desc.pg_dreq = dreq;
 
-	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, inode);
-}
+	list_for_each_entry_safe(req, tmp, &reqs, wb_list) {
+		if (!nfs_pageio_add_request(&desc, req)) {
+			nfs_list_add_request(req, &failed);
+			spin_lock(cinfo.lock);
+			dreq->flags = 0;
+			dreq->error = -EIO;
+			spin_unlock(cinfo.lock);
+		}
+	}
+	nfs_pageio_complete(&desc);
 
-static void nfs_direct_commit_result(struct rpc_task *task, void *calldata)
-{
-	struct nfs_commit_data *data = calldata;
+	while (!list_empty(&failed)) {
+		page_cache_release(req->wb_page);
+		nfs_release_request(req);
+		nfs_unlock_request(req);
+	}
 
-	/* Call the NFS version-specific code */
-	NFS_PROTO(data->inode)->commit_done(task, data);
+	if (put_dreq(dreq))
+		nfs_direct_write_complete(dreq, dreq->inode);
 }
 
-static void nfs_direct_commit_release(void *calldata)
+static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 {
-	struct nfs_commit_data *data = calldata;
 	struct nfs_direct_req *dreq = data->dreq;
+	struct nfs_commit_info cinfo;
+	struct nfs_page *req;
 	int status = data->task.tk_status;
 
+	nfs_init_cinfo_from_dreq(&cinfo, dreq);
 	if (status < 0) {
 		dprintk("NFS: %5u commit failed with error %d.\n",
-				data->task.tk_pid, status);
+			data->task.tk_pid, status);
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 	} else if (memcmp(&dreq->verf, &data->verf, sizeof(data->verf))) {
 		dprintk("NFS: %5u commit verify failed\n", data->task.tk_pid);
@@ -562,59 +527,48 @@ static void nfs_direct_commit_release(void *calldata)
 	}
 
 	dprintk("NFS: %5u commit returned %d\n", data->task.tk_pid, status);
+	while (!list_empty(&data->pages)) {
+		req = nfs_list_entry(data->pages.next);
+		nfs_list_remove_request(req);
+		if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES) {
+			/* Note the rewrite will go through mds */
+			nfs_mark_request_commit(req, NULL, &cinfo);
+		} else {
+			page_cache_release(req->wb_page);
+			nfs_release_request(req);
+		}
+		nfs_unlock_request(req);
+	}
+
 	nfs_direct_write_complete(dreq, data->inode);
-	nfs_commit_free(data);
 }
 
-static const struct rpc_call_ops nfs_commit_direct_ops = {
-	.rpc_call_prepare = nfs_commit_prepare,
-	.rpc_call_done = nfs_direct_commit_result,
-	.rpc_release = nfs_direct_commit_release,
+static void nfs_direct_error_cleanup(struct nfs_inode *nfsi)
+{
+	/* There is no lock to clear */
+}
+
+static const struct nfs_commit_completion_ops nfs_direct_commit_compl_ops = {
+	.completion = nfs_direct_commit_complete,
+	.error_cleanup = nfs_direct_error_cleanup,
 };
 
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 {
-	struct nfs_commit_data *data = dreq->commit_data;
-	struct rpc_task *task;
-	struct rpc_message msg = {
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = dreq->ctx->cred,
-	};
-	struct rpc_task_setup task_setup_data = {
-		.task = &data->task,
-		.rpc_client = NFS_CLIENT(dreq->inode),
-		.rpc_message = &msg,
-		.callback_ops = &nfs_commit_direct_ops,
-		.callback_data = data,
-		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
-	};
-
-	data->inode = dreq->inode;
-	data->cred = msg.rpc_cred;
-
-	data->args.fh = NFS_FH(data->inode);
-	data->args.offset = 0;
-	data->args.count = 0;
-	data->res.fattr = &data->fattr;
-	data->res.verf = &data->verf;
-	nfs_fattr_init(&data->fattr);
-
-	NFS_PROTO(data->inode)->commit_setup(data, &msg);
-
-	/* Note: task.tk_ops->rpc_release will free dreq->commit_data */
-	dreq->commit_data = NULL;
-
-	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
-
-	task = rpc_run_task(&task_setup_data);
-	if (!IS_ERR(task))
-		rpc_put_task(task);
+	int res;
+	struct nfs_commit_info cinfo;
+	LIST_HEAD(mds_list);
+
+	nfs_init_cinfo_from_dreq(&cinfo, dreq);
+	nfs_scan_commit(dreq->inode, &mds_list, &cinfo);
+	res = nfs_generic_commit_list(dreq->inode, &mds_list, 0, &cinfo);
+	if (res < 0) /* res == -ENOMEM */
+		nfs_direct_write_reschedule(dreq);
 }
 
-static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
+static void nfs_direct_write_schedule_work(struct work_struct *work)
 {
+	struct nfs_direct_req *dreq = container_of(work, struct nfs_direct_req, work);
 	int flags = dreq->flags;
 
 	dreq->flags = 0;
@@ -626,90 +580,29 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
-			if (dreq->commit_data != NULL)
-				nfs_commit_free(dreq->commit_data);
-			nfs_direct_free_writedata(dreq);
-			nfs_zap_mapping(inode, inode->i_mapping);
+			nfs_zap_mapping(dreq->inode, dreq->inode->i_mapping);
 			nfs_direct_complete(dreq);
 	}
 }
 
-static void nfs_alloc_commit_data(struct nfs_direct_req *dreq)
+static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
 {
-	dreq->commit_data = nfs_commitdata_alloc();
-	if (dreq->commit_data != NULL)
-		dreq->commit_data->dreq = dreq;
+	schedule_work(&dreq->work); /* Calls nfs_direct_write_schedule_work */
 }
+
 #else
-static inline void nfs_alloc_commit_data(struct nfs_direct_req *dreq)
-{
-	dreq->commit_data = NULL;
-}
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
 {
-	nfs_direct_free_writedata(dreq);
 	nfs_zap_mapping(inode, inode->i_mapping);
 	nfs_direct_complete(dreq);
 }
 #endif
 
-static void nfs_direct_write_result(struct rpc_task *task, void *calldata)
-{
-	struct nfs_write_data *data = calldata;
-
-	nfs_writeback_done(task, data);
-}
-
 /*
  * NB: Return the value of the first error return code.  Subsequent
  *     errors after the first one are ignored.
  */
-static void nfs_direct_write_release(void *calldata)
-{
-	struct nfs_write_data *data = calldata;
-	struct nfs_pgio_header *hdr = data->header;
-	struct nfs_direct_req *dreq = (struct nfs_direct_req *) hdr->req;
-	int status = data->task.tk_status;
-
-	spin_lock(&dreq->lock);
-
-	if (unlikely(status < 0)) {
-		/* An error has occurred, so we should not commit */
-		dreq->flags = 0;
-		dreq->error = status;
-	}
-	if (unlikely(dreq->error != 0))
-		goto out_unlock;
-
-	dreq->count += data->res.count;
-
-	if (data->res.verf->committed != NFS_FILE_SYNC) {
-		switch (dreq->flags) {
-			case 0:
-				memcpy(&dreq->verf, &data->verf, sizeof(dreq->verf));
-				dreq->flags = NFS_ODIRECT_DO_COMMIT;
-				break;
-			case NFS_ODIRECT_DO_COMMIT:
-				if (memcmp(&dreq->verf, &data->verf, sizeof(dreq->verf))) {
-					dprintk("NFS: %5u write verify failed\n", data->task.tk_pid);
-					dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
-				}
-		}
-	}
-out_unlock:
-	spin_unlock(&dreq->lock);
-
-	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, hdr->inode);
-}
-
-static const struct rpc_call_ops nfs_write_direct_ops = {
-	.rpc_call_prepare = nfs_write_prepare,
-	.rpc_call_done = nfs_direct_write_result,
-	.rpc_release = nfs_direct_write_release,
-};
-
 /*
  * For each wsize'd chunk of the user's buffer, dispatch an NFS WRITE
  * operation.  If nfs_writedata_alloc() or get_user_pages() fails,
@@ -717,143 +610,181 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
  * handled automatically by nfs_direct_write_result().  Otherwise, if
  * no requests have been sent, just return an error.
  */
-static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
+static ssize_t nfs_direct_write_schedule_segment(struct nfs_pageio_descriptor *desc,
 						 const struct iovec *iov,
-						 loff_t pos, int sync)
+						 loff_t pos)
 {
+	struct nfs_direct_req *dreq = desc->pg_dreq;
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->dentry->d_inode;
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
-	struct rpc_task *task;
-	struct rpc_message msg = {
-		.rpc_cred = ctx->cred,
-	};
-	struct rpc_task_setup task_setup_data = {
-		.rpc_client = NFS_CLIENT(inode),
-		.rpc_message = &msg,
-		.callback_ops = &nfs_write_direct_ops,
-		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
-	};
 	size_t wsize = NFS_SERVER(inode)->wsize;
 	unsigned int pgbase;
 	int result;
 	ssize_t started = 0;
+	struct page **pagevec = NULL;
+	unsigned int npages;
 
 	do {
-		struct nfs_write_header *whdr;
-		struct nfs_write_data *data;
-		struct nfs_page_array *pages;
 		size_t bytes;
+		int i;
 
 		pgbase = user_addr & ~PAGE_MASK;
-		bytes = min(wsize,count);
+		bytes = min(max(wsize, PAGE_SIZE), count);
 
 		result = -ENOMEM;
-		whdr = nfs_writehdr_alloc();
-		if (unlikely(!whdr))
-			break;
-
-		data = nfs_writedata_alloc(&whdr->header, nfs_page_array_len(pgbase, bytes));
-		if (!data) {
-			nfs_writehdr_free(&whdr->header);
+		npages = nfs_page_array_len(pgbase, bytes);
+		if (!pagevec)
+			pagevec = kmalloc(npages * sizeof(struct page *), GFP_KERNEL);
+		if (!pagevec)
 			break;
-		}
-		data->header = &whdr->header;
-		atomic_inc(&data->header->refcnt);
-		pages = &data->pages;
 
 		down_read(&current->mm->mmap_sem);
 		result = get_user_pages(current, current->mm, user_addr,
-					pages->npages, 0, 0, pages->pagevec, NULL);
+					npages, 0, 0, pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
-		if (result < 0) {
-			nfs_direct_writehdr_release(whdr);
+		if (result < 0)
 			break;
-		}
-		if ((unsigned)result < pages->npages) {
+
+		if ((unsigned)result < npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
-				nfs_direct_release_pages(pages->pagevec, result);
-				nfs_direct_writehdr_release(whdr);
+				nfs_direct_release_pages(pagevec, result);
 				break;
 			}
 			bytes -= pgbase;
-			pages->npages = result;
+			npages = result;
 		}
 
-		get_dreq(dreq);
-
-		list_move_tail(&whdr->header.pages, &dreq->rewrite_list);
-
-		whdr->header.req = (struct nfs_page *) dreq;
-		whdr->header.inode = inode;
-		whdr->header.cred = msg.rpc_cred;
-		data->args.fh = NFS_FH(inode);
-		data->args.context = ctx;
-		data->args.lock_context = dreq->l_ctx;
-		data->args.offset = pos;
-		data->args.pgbase = pgbase;
-		data->args.pages = pages->pagevec;
-		data->args.count = bytes;
-		data->args.stable = sync;
-		data->res.fattr = &data->fattr;
-		data->res.count = bytes;
-		data->res.verf = &data->verf;
-		nfs_fattr_init(&data->fattr);
-
-		task_setup_data.task = &data->task;
-		task_setup_data.callback_data = data;
-		msg.rpc_argp = &data->args;
-		msg.rpc_resp = &data->res;
-		NFS_PROTO(inode)->write_setup(data, &msg);
-
-		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
-			break;
+		for (i = 0; i < npages; i++) {
+			struct nfs_page *req;
+			unsigned int req_len = min(bytes, PAGE_SIZE - pgbase);
 
-		dprintk("NFS: %5u initiated direct write call "
-			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
-				task->tk_pid,
-				inode->i_sb->s_id,
-				(long long)NFS_FILEID(inode),
-				bytes,
-				(unsigned long long)data->args.offset);
-		rpc_put_task(task);
-
-		started += bytes;
-		user_addr += bytes;
-		pos += bytes;
-
-		/* FIXME: Remove this useless math from the final patch */
-		pgbase += bytes;
-		pgbase &= ~PAGE_MASK;
-		BUG_ON(pgbase != (user_addr & ~PAGE_MASK));
-
-		count -= bytes;
+			req = nfs_create_request(dreq->ctx, dreq->inode,
+						 pagevec[i],
+						 pgbase, req_len);
+			if (IS_ERR(req)) {
+				nfs_direct_release_pages(pagevec + i,
+							 npages - i);
+				result = PTR_ERR(req);
+				break;
+			}
+			nfs_lock_request(req);
+			req->wb_index = pos >> PAGE_SHIFT;
+			req->wb_offset = pos & ~PAGE_MASK;
+			if (!nfs_pageio_add_request(desc, req)) {
+				result = desc->pg_error;
+				nfs_unlock_request(req);
+				nfs_release_request(req);
+				nfs_direct_release_pages(pagevec + i,
+							 npages - i);
+			}
+			pgbase = 0;
+			bytes -= req_len;
+			started += req_len;
+			user_addr += req_len;
+			pos += req_len;
+			count -= req_len;
+		}
 	} while (count != 0);
 
+	kfree(pagevec);
+
 	if (started)
 		return started;
 	return result < 0 ? (ssize_t) result : -EFAULT;
 }
 
+static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
+{
+	struct nfs_direct_req *dreq = hdr->dreq;
+	struct nfs_commit_info cinfo;
+	int bit = -1;
+	struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+
+	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
+		goto out_put;
+
+	nfs_init_cinfo_from_dreq(&cinfo, dreq);
+
+	spin_lock(&dreq->lock);
+
+	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
+		dreq->flags = 0;
+		dreq->error = hdr->error;
+	}
+	if (dreq->error != 0)
+		bit = NFS_IOHDR_ERROR;
+	else {
+		dreq->count += (hdr->first_error - req_offset(hdr->req));
+		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags)) {
+			dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+			bit = NFS_IOHDR_NEED_RESCHED;
+		} else if (test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags)) {
+			if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES)
+				bit = NFS_IOHDR_NEED_RESCHED;
+			else if (dreq->flags == 0) {
+				memcpy(&dreq->verf, &req->wb_verf,
+				       sizeof(dreq->verf));
+				bit = NFS_IOHDR_NEED_COMMIT;
+				dreq->flags = NFS_ODIRECT_DO_COMMIT;
+			} else if (dreq->flags == NFS_ODIRECT_DO_COMMIT) {
+				if (memcmp(&dreq->verf, &req->wb_verf, sizeof(dreq->verf))) {
+					dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+					bit = NFS_IOHDR_NEED_RESCHED;
+				} else
+					bit = NFS_IOHDR_NEED_COMMIT;
+			}
+		}
+	}
+	spin_unlock(&dreq->lock);
+
+	while (!list_empty(&hdr->pages)) {
+		req = nfs_list_entry(hdr->pages.next);
+		nfs_list_remove_request(req);
+		switch (bit) {
+		case NFS_IOHDR_NEED_RESCHED:
+		case NFS_IOHDR_NEED_COMMIT:
+			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
+			break;
+		default:
+			page_cache_release(req->wb_page);
+			nfs_release_request(req);
+		}
+		nfs_unlock_request(req);
+	}
+
+out_put:
+	if (put_dreq(dreq))
+		nfs_direct_write_complete(dreq, hdr->inode);
+	hdr->release(hdr);
+}
+
+static const struct nfs_io_completion_ops nfs_direct_write_compl_ops = {
+	.error_cleanup = nfs_sync_pgio_error,
+	.init_hdr = nfs_direct_pgio_init,
+	.completion = nfs_direct_write_completion,
+};
+
 static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 					       const struct iovec *iov,
 					       unsigned long nr_segs,
-					       loff_t pos, int sync)
+					       loff_t pos)
 {
+	struct nfs_pageio_descriptor desc;
 	ssize_t result = 0;
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
+	nfs_pageio_init_write(&desc, dreq->inode, FLUSH_COND_STABLE,
+			      &nfs_direct_write_compl_ops);
+	desc.pg_dreq = dreq;
 	get_dreq(dreq);
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_write_schedule_segment(dreq, vec,
-							   pos, sync);
+		result = nfs_direct_write_schedule_segment(&desc, vec, pos);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -861,6 +792,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			break;
 		pos += vec->iov_len;
 	}
+	nfs_pageio_complete(&desc);
 
 	/*
 	 * If no bytes were started, return the error, and let the
@@ -883,16 +815,10 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t result = -ENOMEM;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
 	struct nfs_direct_req *dreq;
-	size_t wsize = NFS_SERVER(inode)->wsize;
-	int sync = NFS_UNSTABLE;
 
 	dreq = nfs_direct_req_alloc();
 	if (!dreq)
 		goto out;
-	nfs_alloc_commit_data(dreq);
-
-	if (dreq->commit_data == NULL || count <= wsize)
-		sync = NFS_FILE_SYNC;
 
 	dreq->inode = inode;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
@@ -902,7 +828,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, sync);
+	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 out_release:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d08f048..1436d23 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -323,6 +323,9 @@ extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
+extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
+				struct inode *inode, int ioflags,
+				const struct nfs_io_completion_ops *compl_ops);
 extern struct nfs_write_header *nfs_writehdr_alloc(void);
 extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
 extern struct nfs_write_data *nfs_writedata_alloc(struct nfs_pgio_header *hdr,
@@ -349,6 +352,15 @@ extern void nfs_init_commit(struct nfs_commit_data *data,
 			    struct list_head *head,
 			    struct pnfs_layout_segment *lseg,
 			    struct nfs_commit_info *cinfo);
+int nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
+			 struct nfs_commit_info *cinfo, int max);
+int nfs_scan_commit(struct inode *inode, struct list_head *dst,
+		    struct nfs_commit_info *cinfo);
+void nfs_mark_request_commit(struct nfs_page *req,
+			     struct pnfs_layout_segment *lseg,
+			     struct nfs_commit_info *cinfo);
+int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
+			    int how, struct nfs_commit_info *cinfo);
 void nfs_retry_commit(struct list_head *page_list,
 		      struct pnfs_layout_segment *lseg,
 		      struct nfs_commit_info *cinfo);
@@ -368,6 +380,10 @@ extern int nfs_migrate_page(struct address_space *,
 #define nfs_migrate_page NULL
 #endif
 
+/* direct.c */
+void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
+			      struct nfs_direct_req *dreq);
+
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
 extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9bbc798..87aa10a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -995,12 +995,9 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 }
 
 static int
-filelayout_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
-			       struct nfs_commit_info *cinfo,
-			       int max)
+transfer_commit_list(struct list_head *src, struct list_head *dst,
+		     struct nfs_commit_info *cinfo, int max)
 {
-	struct list_head *src = &bucket->written;
-	struct list_head *dst = &bucket->committing;
 	struct nfs_page *req, *tmp;
 	int ret = 0;
 
@@ -1013,9 +1010,22 @@ filelayout_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 		nfs_list_add_request(req, dst);
 		ret++;
-		if (ret == max)
+		if ((ret == max) && !cinfo->dreq)
 			break;
 	}
+	return ret;
+}
+
+static int
+filelayout_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
+			       struct nfs_commit_info *cinfo,
+			       int max)
+{
+	struct list_head *src = &bucket->written;
+	struct list_head *dst = &bucket->committing;
+	int ret;
+
+	ret = transfer_commit_list(src, dst, cinfo, max);
 	if (ret) {
 		cinfo->ds->nwritten -= ret;
 		cinfo->ds->ncommitting += ret;
@@ -1045,6 +1055,27 @@ static int filelayout_scan_commit_lists(struct nfs_commit_info *cinfo,
 	return rv;
 }
 
+/* Pull everything off the committing lists and dump into @dst */
+static void filelayout_recover_commit_reqs(struct list_head *dst,
+					   struct nfs_commit_info *cinfo)
+{
+	struct pnfs_commit_bucket *b;
+	int i;
+
+	/* NOTE cinfo->lock is NOT held, relying on fact that this is
+	 * only called on single thread per dreq.
+	 * Can't take the lock because need to do put_lseg
+	 */
+	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
+		if (transfer_commit_list(&b->written, dst, cinfo, 0)) {
+			BUG_ON(!list_empty(&b->written));
+			put_lseg(b->wlseg);
+			b->wlseg = NULL;
+		}
+	}
+	cinfo->ds->nwritten = 0;
+}
+
 static unsigned int
 alloc_ds_commits(struct nfs_commit_info *cinfo, struct list_head *list)
 {
@@ -1169,6 +1200,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.mark_request_commit	= filelayout_mark_request_commit,
 	.clear_request_commit	= filelayout_clear_request_commit,
 	.scan_commit_lists	= filelayout_scan_commit_lists,
+	.recover_commit_reqs	= filelayout_recover_commit_reqs,
 	.commit_pagelist	= filelayout_commit_pagelist,
 	.read_pagelist		= filelayout_read_pagelist,
 	.write_pagelist		= filelayout_write_pagelist,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5e4a51c..c35cfdb 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -102,6 +102,8 @@ struct pnfs_layoutdriver_type {
 				      struct nfs_commit_info *cinfo);
 	int (*scan_commit_lists) (struct nfs_commit_info *cinfo,
 				  int max);
+	void (*recover_commit_reqs) (struct list_head *list,
+				     struct nfs_commit_info *cinfo);
 	int (*commit_pagelist)(struct inode *inode,
 			       struct list_head *mds_pages,
 			       int how,
@@ -323,6 +325,15 @@ pnfs_scan_commit_lists(struct inode *inode, struct nfs_commit_info *cinfo,
 		return NFS_SERVER(inode)->pnfs_curr_ld->scan_commit_lists(cinfo, max);
 }
 
+static inline void
+pnfs_recover_commit_reqs(struct inode *inode, struct list_head *list,
+			 struct nfs_commit_info *cinfo)
+{
+	if (cinfo->ds == NULL || cinfo->ds->nwritten == 0)
+		return;
+	NFS_SERVER(inode)->pnfs_curr_ld->recover_commit_reqs(list, cinfo);
+}
+
 /* Should the pNFS client commit and return the layout upon a setattr */
 static inline bool
 pnfs_ld_layoutret_on_setattr(struct inode *inode)
@@ -456,6 +467,12 @@ pnfs_scan_commit_lists(struct inode *inode, struct nfs_commit_info *cinfo,
 	return 0;
 }
 
+static inline void
+pnfs_recover_commit_reqs(struct inode *inode, struct list_head *list,
+			 struct nfs_commit_info *cinfo)
+{
+}
+
 static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	return 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index aabc103..fceb7cc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -39,9 +39,6 @@
 /*
  * Local function declarations
  */
-static void nfs_pageio_init_write(struct nfs_pageio_descriptor *desc,
-				  struct inode *inode, int ioflags,
-				  const struct nfs_io_completion_ops *compl_ops);
 static void nfs_redirty_request(struct nfs_page *req);
 static const struct rpc_call_ops nfs_write_common_ops;
 static const struct rpc_call_ops nfs_commit_ops;
@@ -512,14 +509,17 @@ void nfs_init_cinfo(struct nfs_commit_info *cinfo,
 		    struct inode *inode,
 		    struct nfs_direct_req *dreq)
 {
-	nfs_init_cinfo_from_inode(cinfo, inode);
+	if (dreq)
+		nfs_init_cinfo_from_dreq(cinfo, dreq);
+	else
+		nfs_init_cinfo_from_inode(cinfo, inode);
 }
 EXPORT_SYMBOL_GPL(nfs_init_cinfo);
 
 /*
  * Add a request to the inode's commit list.
  */
-static void
+void
 nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 			struct nfs_commit_info *cinfo)
 {
@@ -561,7 +561,7 @@ int nfs_write_need_commit(struct nfs_write_data *data)
 }
 
 #else
-static void
+void
 nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 			struct nfs_commit_info *cinfo)
 {
@@ -626,7 +626,7 @@ nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 }
 
 /* cinfo->lock held by caller */
-static int
+int
 nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 		     struct nfs_commit_info *cinfo, int max)
 {
@@ -641,7 +641,7 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 		nfs_request_remove_commit_list(req, cinfo);
 		nfs_list_add_request(req, dst);
 		ret++;
-		if (ret == max)
+		if ((ret == max) && !cinfo->dreq)
 			break;
 	}
 	return ret;
@@ -656,7 +656,7 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
  * Moves requests from the inode's 'commit' request list.
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
-static int
+int
 nfs_scan_commit(struct inode *inode, struct list_head *dst,
 		struct nfs_commit_info *cinfo)
 {
@@ -680,8 +680,8 @@ static unsigned long nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 	return 0;
 }
 
-static inline int nfs_scan_commit(struct inode *inode, struct list_head *dst,
-				  struct nfs_commit_info *cinfo)
+int nfs_scan_commit(struct inode *inode, struct list_head *dst,
+		    struct nfs_commit_info *cinfo)
 {
 	return 0;
 }
@@ -1200,9 +1200,9 @@ void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
 
-static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
-				  struct inode *inode, int ioflags,
-				  const struct nfs_io_completion_ops *compl_ops)
+void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
+			   struct inode *inode, int ioflags,
+			   const struct nfs_io_completion_ops *compl_ops)
 {
 	if (!pnfs_pageio_init_write(pgio, inode, ioflags, compl_ops))
 		nfs_pageio_init_write_mds(pgio, inode, ioflags, compl_ops);
@@ -1566,8 +1566,8 @@ static const struct nfs_commit_completion_ops nfs_commit_compl_ops = {
 	.error_cleanup = nfs_commit_clear_lock,
 };
 
-static int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
-				   int how, struct nfs_commit_info *cinfo)
+int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
+			    int how, struct nfs_commit_info *cinfo)
 {
 	int status;
 
-- 
1.7.2.1

