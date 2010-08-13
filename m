Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23015 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754532Ab0HMVdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:21 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 47/50] SQUASHME pnfs_post_submit: direct i/o
Date: Fri, 13 Aug 2010 17:31:59 -0400
Message-Id: <1281735122-1496-48-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-47-git-send-email-andros@netapp.com>
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
 <1281735122-1496-45-git-send-email-andros@netapp.com>
 <1281735122-1496-46-git-send-email-andros@netapp.com>
 <1281735122-1496-47-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/direct.c |  160 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 92 insertions(+), 68 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index ad4cd31..3ef9b0c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -267,6 +267,38 @@ static const struct rpc_call_ops nfs_read_direct_ops = {
 	.rpc_release = nfs_direct_read_release,
 };
 
+static long nfs_direct_read_execute(struct nfs_read_data *data,
+				    struct rpc_task_setup *task_setup_data,
+				    struct rpc_message *msg)
+{
+	struct inode *inode = data->inode;
+	struct rpc_task *task;
+
+	nfs_fattr_init(&data->fattr);
+	msg->rpc_argp = &data->args;
+	msg->rpc_resp = &data->res;
+
+	task_setup_data->task = &data->task;
+	task_setup_data->callback_data = data;
+	NFS_PROTO(inode)->read_setup(data, msg);
+
+	task = rpc_run_task(task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+
+	rpc_put_task(task);
+
+	dprintk("NFS: %5u initiated direct read call "
+		"(req %s/%lld, %u bytes @ offset %llu)\n",
+		data->task.tk_pid,
+		inode->i_sb->s_id,
+		(long long)NFS_FILEID(inode),
+		data->args.count,
+		(unsigned long long)data->args.offset);
+
+	return 0;
+}
+
 /*
  * For each rsize'd chunk of the user's buffer, dispatch an NFS READ
  * operation.  If nfs_readdata_alloc() or get_user_pages() fails,
@@ -283,7 +315,6 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
 	size_t rsize = NFS_SERVER(inode)->rsize;
-	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = ctx->cred,
 	};
@@ -343,26 +374,9 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.fattr = &data->fattr;
 		data->res.eof = 0;
 		data->res.count = bytes;
-		nfs_fattr_init(&data->fattr);
-		msg.rpc_argp = &data->args;
-		msg.rpc_resp = &data->res;
 
-		task_setup_data.task = &data->task;
-		task_setup_data.callback_data = data;
-		NFS_PROTO(inode)->read_setup(data, &msg);
-
-		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
+		if (nfs_direct_read_execute(data, &task_setup_data, &msg))
 			break;
-		rpc_put_task(task);
-
-		dprintk("NFS: %5u initiated direct read call "
-			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
-				data->task.tk_pid,
-				inode->i_sb->s_id,
-				(long long)NFS_FILEID(inode),
-				bytes,
-				(unsigned long long)data->args.offset);
 
 		started += bytes;
 		user_addr += bytes;
@@ -448,12 +462,15 @@ static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+static long nfs_direct_write_execute(struct nfs_write_data *data,
+				     struct rpc_task_setup *task_setup_data,
+				     struct rpc_message *msg);
+
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct inode *inode = dreq->inode;
 	struct list_head *p;
 	struct nfs_write_data *data;
-	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = dreq->ctx->cred,
 	};
@@ -487,25 +504,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 		 * Reuse data->task; data->args should not have changed
 		 * since the original request was sent.
 		 */
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
+		nfs_direct_write_execute(data, &task_setup_data, &msg);
 	}
 
 	if (put_dreq(dreq))
@@ -548,10 +547,31 @@ static const struct rpc_call_ops nfs_commit_direct_ops = {
 	.rpc_release = nfs_direct_commit_release,
 };
 
+static long nfs_direct_commit_execute(struct nfs_direct_req *dreq,
+				      struct nfs_write_data *data,
+				      struct rpc_task_setup *task_setup_data,
+				      struct rpc_message *msg)
+{
+	struct rpc_task *task;
+
+	NFS_PROTO(data->inode)->commit_setup(data, msg);
+
+	/* Note: task.tk_ops->rpc_release will free dreq->commit_data */
+	dreq->commit_data = NULL;
+
+	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
+
+	task = rpc_run_task(task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+
+	rpc_put_task(task);
+	return 0;
+}
+
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 {
 	struct nfs_write_data *data = dreq->commit_data;
-	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &data->args,
 		.rpc_resp = &data->res,
@@ -579,16 +599,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->res.verf = &data->verf;
 	nfs_fattr_init(&data->fattr);
 
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
+	nfs_direct_commit_execute(dreq, data, &task_setup_data, &msg);
 }
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode)
@@ -690,6 +701,36 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
 	.rpc_release = nfs_direct_write_release,
 };
 
+static long nfs_direct_write_execute(struct nfs_write_data *data,
+				     struct rpc_task_setup *task_setup_data,
+				     struct rpc_message *msg)
+{
+	struct inode *inode = data->inode;
+	struct rpc_task *task;
+
+	task_setup_data->task = &data->task;
+	task_setup_data->callback_data = data;
+	msg->rpc_argp = &data->args;
+	msg->rpc_resp = &data->res;
+	NFS_PROTO(inode)->write_setup(data, msg);
+
+	task = rpc_run_task(task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+
+	rpc_put_task(task);
+
+	dprintk("NFS: %5u initiated direct write call "
+		"(req %s/%lld, %u bytes @ offset %llu)\n",
+		data->task.tk_pid,
+		inode->i_sb->s_id,
+		(long long)NFS_FILEID(inode),
+		data->args.count,
+		(unsigned long long)data->args.offset);
+
+	return 0;
+}
+
 /*
  * For each wsize'd chunk of the user's buffer, dispatch an NFS WRITE
  * operation.  If nfs_writedata_alloc() or get_user_pages() fails,
@@ -705,7 +746,6 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 	struct inode *inode = ctx->path.dentry->d_inode;
 	unsigned long user_addr = (unsigned long)iov->iov_base;
 	size_t count = iov->iov_len;
-	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_cred = ctx->cred,
 	};
@@ -771,24 +811,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.verf = &data->verf;
 		nfs_fattr_init(&data->fattr);
 
-		task_setup_data.task = &data->task;
-		task_setup_data.callback_data = data;
-		msg.rpc_argp = &data->args;
-		msg.rpc_resp = &data->res;
-		NFS_PROTO(inode)->write_setup(data, &msg);
-
-		task = rpc_run_task(&task_setup_data);
-		if (IS_ERR(task))
+		if (nfs_direct_write_execute(data, &task_setup_data, &msg))
 			break;
-		rpc_put_task(task);
-
-		dprintk("NFS: %5u initiated direct write call "
-			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",
-				data->task.tk_pid,
-				inode->i_sb->s_id,
-				(long long)NFS_FILEID(inode),
-				bytes,
-				(unsigned long long)data->args.offset);
 
 		started += bytes;
 		user_addr += bytes;
-- 
1.6.2.5

