From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/4] NFS: Fix a deadlock with lazy umount
Date: Tue, 19 Feb 2008 18:04:59 -0500
Message-ID: <20080219230459.22007.4944.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080219230459.22007.10990.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53378 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755104AbYBSXPD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 18:15:03 -0500
In-Reply-To: <20080219230459.22007.10990.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can't allow rpc callback functions like task->tk_ops->rpc_call_prepare()
and task->tk_ops->rpc_call_done() to call mntput() in any way, since
that will cause a deadlock when the call to rpc_shutdown_client() attempts
to wait on 'task' to complete.

We can avoid the above deadlock by moving calls to mntput to
task->tk_ops->rpc_release() callback, since at that time the task will be
marked as completed, and so rpc_shutdown_client won't attempt to wait on
it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |    5 +++--
 fs/nfs/inode.c  |    6 +++++-
 fs/nfs/read.c   |    7 +++++--
 fs/nfs/write.c  |   13 ++++++++++---
 4 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 16844f9..e017040 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -323,7 +323,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->inode = inode;
 		data->cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
-		data->args.context = ctx;
+		data->args.context = get_nfs_open_context(ctx);
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
 		data->args.pages = data->pagevec;
@@ -546,6 +546,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->args.fh = NFS_FH(data->inode);
 	data->args.offset = 0;
 	data->args.count = 0;
+	data->args.context = get_nfs_open_context(dreq->ctx);
 	data->res.count = 0;
 	data->res.fattr = &data->fattr;
 	data->res.verf = &data->verf;
@@ -728,7 +729,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->inode = inode;
 		data->cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
-		data->args.context = ctx;
+		data->args.context = get_nfs_open_context(ctx);
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
 		data->args.pages = data->pagevec;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 966a885..a499fb5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -521,8 +521,12 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 
 static void __put_nfs_open_context(struct nfs_open_context *ctx, int wait)
 {
-	struct inode *inode = ctx->path.dentry->d_inode;
+	struct inode *inode;
 
+	if (ctx == NULL)
+		return;
+
+	inode = ctx->path.dentry->d_inode;
 	if (!atomic_dec_and_lock(&ctx->count, &inode->i_lock))
 		return;
 	list_del(&ctx->list);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3d7d963..fab0d37 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -73,7 +73,10 @@ static void nfs_readdata_free(struct nfs_read_data *rdata)
 
 void nfs_readdata_release(void *data)
 {
-        nfs_readdata_free(data);
+	struct nfs_read_data *rdata = data;
+
+	put_nfs_open_context(rdata->args.context);
+	nfs_readdata_free(rdata);
 }
 
 static
@@ -186,7 +189,7 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	data->args.pgbase = req->wb_pgbase + offset;
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
-	data->args.context = req->wb_context;
+	data->args.context = get_nfs_open_context(req->wb_context);
 
 	data->res.fattr   = &data->fattr;
 	data->res.count   = count;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f55c437..fb6232a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -105,8 +105,11 @@ static void nfs_writedata_free(struct nfs_write_data *wdata)
 	call_rcu_bh(&wdata->task.u.tk_rcu, nfs_writedata_rcu_free);
 }
 
-void nfs_writedata_release(void *wdata)
+void nfs_writedata_release(void *data)
 {
+	struct nfs_write_data *wdata = data;
+
+	put_nfs_open_context(wdata->args.context);
 	nfs_writedata_free(wdata);
 }
 
@@ -816,7 +819,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	data->args.pgbase = req->wb_pgbase + offset;
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
-	data->args.context = req->wb_context;
+	data->args.context = get_nfs_open_context(req->wb_context);
 	data->args.stable  = NFS_UNSTABLE;
 	if (how & FLUSH_STABLE) {
 		data->args.stable = NFS_DATA_SYNC;
@@ -1153,8 +1156,11 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-void nfs_commit_release(void *wdata)
+void nfs_commit_release(void *data)
 {
+	struct nfs_write_data *wdata = data;
+
+	put_nfs_open_context(wdata->args.context);
 	nfs_commit_free(wdata);
 }
 
@@ -1197,6 +1203,7 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	/* Note: we always request a commit of the entire inode */
 	data->args.offset = 0;
 	data->args.count  = 0;
+	data->args.context = get_nfs_open_context(first->wb_context);
 	data->res.count   = 0;
 	data->res.fattr   = &data->fattr;
 	data->res.verf    = &data->verf;
