From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfs: handle nfs_{read,write,commit}_rpcsetup errors
Date: Mon, 14 Apr 2008 20:31:18 +0300
Message-ID: <1208194278-6165-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bzq-219-195-70.pop.bezeqint.net ([62.219.195.70]:59935 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734AbYDNRbt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 13:31:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, nfs_{read,write,commit}_rpcsetup return no errors.
All three call rpc_run_task that can fail when out of memory.
Ignoring these failures leads to hangs.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/read.c  |   35 +++++++++++++++++++++--------
 fs/nfs/write.c |   66 ++++++++++++++++++++++++++++++++++++-------------------
 2 files changed, 68 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 5a70be5..85df148 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -156,7 +156,7 @@ static void nfs_readpage_release(struct nfs_page *req)
 /*
  * Set up the NFS read request struct
  */
-static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
+static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		const struct rpc_call_ops *call_ops,
 		unsigned int count, unsigned int offset)
 {
@@ -204,8 +204,10 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 			(unsigned long long)data->args.offset);
 
 	task = rpc_run_task(&task_setup_data);
-	if (!IS_ERR(task))
-		rpc_put_task(task);
+	if (unlikely(IS_ERR(task)))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
 }
 
 static void
@@ -242,6 +244,7 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 	size_t rsize = NFS_SERVER(inode)->rsize, nbytes;
 	unsigned int offset;
 	int requests = 0;
+	int ret = -ENOMEM;
 	LIST_HEAD(list);
 
 	nfs_list_remove_request(req);
@@ -271,8 +274,12 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 
 		if (nbytes < rsize)
 			rsize = nbytes;
-		nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
-				  rsize, offset);
+		ret = nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
+					rsize, offset);
+		if (unlikely(ret)) {
+			list_add(&data->pages, &list);
+			goto out_bad;
+		}
 		offset += rsize;
 		nbytes -= rsize;
 	} while (nbytes != 0);
@@ -280,14 +287,17 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 	return 0;
 
 out_bad:
+	requests = 0;
 	while (!list_empty(&list)) {
 		data = list_entry(list.next, struct nfs_read_data, pages);
 		list_del(&data->pages);
 		nfs_readdata_free(data);
+		requests++;
 	}
 	SetPageError(page);
-	nfs_readpage_release(req);
-	return -ENOMEM;
+	if (atomic_sub_return(requests, &req->wb_complete) <= 0)
+		nfs_readpage_release(req);
+	return ret;
 }
 
 static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned int npages, size_t count, int flags)
@@ -295,6 +305,7 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_read_data	*data;
+	int			ret = -ENOMEM;
 
 	data = nfs_readdata_alloc(npages);
 	if (!data)
@@ -311,11 +322,15 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	}
 	req = nfs_list_entry(data->pages.next);
 
-	nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
-	return 0;
+	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
+	if (likely(!ret))
+		return 0;
+
+	head = &data->pages;
+	nfs_readdata_free(data);
 out_bad:
 	nfs_async_read_error(head);
-	return -ENOMEM;
+	return ret;
 }
 
 /*
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bed6341..a58bfd2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -785,7 +785,7 @@ static int flush_task_priority(int how)
 /*
  * Set up the argument/result storage required for the RPC call.
  */
-static void nfs_write_rpcsetup(struct nfs_page *req,
+static int nfs_write_rpcsetup(struct nfs_page *req,
 		struct nfs_write_data *data,
 		const struct rpc_call_ops *call_ops,
 		unsigned int count, unsigned int offset,
@@ -847,8 +847,10 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 		(unsigned long long)data->args.offset);
 
 	task = rpc_run_task(&task_setup_data);
-	if (!IS_ERR(task))
-		rpc_put_task(task);
+	if (unlikely(IS_ERR(task)))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
 }
 
 /*
@@ -863,6 +865,7 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
 	size_t wsize = NFS_SERVER(inode)->wsize, nbytes;
 	unsigned int offset;
 	int requests = 0;
+	int ret = -ENOMEM;
 	LIST_HEAD(list);
 
 	nfs_list_remove_request(req);
@@ -891,8 +894,12 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
 
 		if (nbytes < wsize)
 			wsize = nbytes;
-		nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
-				   wsize, offset, how);
+		ret = nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
+					 wsize, offset, how);
+		if (unlikely(ret)) {
+			list_add(&data->pages, &list);
+			goto out_bad;
+		}
 		offset += wsize;
 		nbytes -= wsize;
 	} while (nbytes != 0);
@@ -900,15 +907,19 @@ static int nfs_flush_multi(struct inode *inode, struct list_head *head, unsigned
 	return 0;
 
 out_bad:
+	requests = 0;
 	while (!list_empty(&list)) {
 		data = list_entry(list.next, struct nfs_write_data, pages);
 		list_del(&data->pages);
 		nfs_writedata_release(data);
+		requests++;
 	}
 	nfs_redirty_request(req);
-	nfs_end_page_writeback(req->wb_page);
-	nfs_clear_page_tag_locked(req);
-	return -ENOMEM;
+	if (atomic_sub_return(requests, &req->wb_complete) <= 0) {
+		nfs_end_page_writeback(req->wb_page);
+		nfs_clear_page_tag_locked(req);
+	}
+	return ret;
 }
 
 /*
@@ -924,6 +935,7 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 	struct nfs_page		*req;
 	struct page		**pages;
 	struct nfs_write_data	*data;
+	int			ret = -ENOMEM;
 
 	data = nfs_writedata_alloc(npages);
 	if (!data)
@@ -940,9 +952,12 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 	req = nfs_list_entry(data->pages.next);
 
 	/* Set up the argument struct */
-	nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, how);
+	ret = nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, how);
+	if (likely(!ret))
+		return 0;
 
-	return 0;
+	head = &data->pages;
+	nfs_writedata_free(data);
  out_bad:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -951,7 +966,7 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
 		nfs_end_page_writeback(req->wb_page);
 		nfs_clear_page_tag_locked(req);
 	}
-	return -ENOMEM;
+	return ret;
 }
 
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
@@ -1167,19 +1182,18 @@ void nfs_commit_release(void *wdata)
 /*
  * Set up the argument/result storage required for the RPC call.
  */
-static void nfs_commit_rpcsetup(struct list_head *head,
+static int nfs_commit_rpcsetup(struct nfs_page *req,
 		struct nfs_write_data *data,
 		int how)
 {
-	struct nfs_page *first = nfs_list_entry(head->next);
-	struct inode *inode = first->wb_context->path.dentry->d_inode;
+	struct inode *inode = req->wb_context->path.dentry->d_inode;
 	int flags = (how & FLUSH_SYNC) ? 0 : RPC_TASK_ASYNC;
 	int priority = flush_task_priority(how);
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
-		.rpc_cred = first->wb_context->cred,
+		.rpc_cred = req->wb_context->cred,
 	};
 	struct rpc_task_setup task_setup_data = {
 		.task = &data->task,
@@ -1194,8 +1208,6 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
 
-	list_splice_init(head, &data->pages);
-
 	data->inode	  = inode;
 	data->cred	  = msg.rpc_cred;
 
@@ -1214,8 +1226,10 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 
 	task = rpc_run_task(&task_setup_data);
-	if (!IS_ERR(task))
-		rpc_put_task(task);
+	if (unlikely(IS_ERR(task)))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
 }
 
 /*
@@ -1225,17 +1239,23 @@ static int
 nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 {
 	struct nfs_write_data	*data;
-	struct nfs_page         *req;
+	struct nfs_page         *req = nfs_list_entry(head->next);
+	int			ret = -ENOMEM;
 
 	data = nfs_commit_alloc();
 
 	if (!data)
 		goto out_bad;
 
+	list_splice_init(head, &data->pages);
+
 	/* Set up the argument struct */
-	nfs_commit_rpcsetup(head, data, how);
+	ret = nfs_commit_rpcsetup(req, data, how);
+	if (likely(!ret))
+		return 0;
 
-	return 0;
+	head = &data->pages;
+	nfs_commit_free(data);
  out_bad:
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -1246,7 +1266,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 				BDI_RECLAIMABLE);
 		nfs_clear_page_tag_locked(req);
 	}
-	return -ENOMEM;
+	return ret;
 }
 
 /*
-- 
1.5.3.3

