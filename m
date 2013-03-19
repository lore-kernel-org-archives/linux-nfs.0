Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19796 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754719Ab3CSNHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:48 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/11] NFS: Don't accept more reads/writes if the open context recovery failed
Date: Tue, 19 Mar 2013 09:07:34 -0400
Message-Id: <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the state recovery failed, we want to ensure that the application
doesn't try to use the same file descriptor for more reads or writes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c |  8 ++++++++
 fs/nfs/nfs4state.c      | 16 ++++++++++++++++
 fs/nfs/pagelist.c       |  2 ++
 fs/nfs/read.c           |  2 ++
 fs/nfs/write.c          |  2 ++
 include/linux/nfs_fs.h  |  1 +
 6 files changed, 31 insertions(+)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e4a29fb..2533ad4 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -306,6 +306,10 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = data;
 
+	if (unlikely(test_bit(NFS_CONTEXT_BAD, &rdata->args.context->flags))) {
+		rpc_exit(task, -EIO);
+		return;
+	}
 	if (filelayout_reset_to_mds(rdata->header->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_read(rdata);
@@ -408,6 +412,10 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = data;
 
+	if (unlikely(test_bit(NFS_CONTEXT_BAD, &wdata->args.context->flags))) {
+		rpc_exit(task, -EIO);
+		return;
+	}
 	if (filelayout_reset_to_mds(wdata->header->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_write(wdata);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index fec1c5b..8db102c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1328,9 +1328,25 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 		nfs4_schedule_state_manager(clp);
 }
 
+static void nfs4_state_mark_open_context_bad(struct nfs4_state *state)
+{
+	struct inode *inode = state->inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_open_context *ctx;
+
+	spin_lock(&inode->i_lock);
+	list_for_each_entry(ctx, &nfsi->open_files, list) {
+		if (ctx->state != state)
+			continue;
+		set_bit(NFS_CONTEXT_BAD, &ctx->flags);
+	}
+	spin_unlock(&inode->i_lock);
+}
+
 static void nfs4_state_mark_recovery_failed(struct nfs4_state *state, int error)
 {
 	set_bit(NFS_STATE_RECOVERY_FAILED, &state->flags);
+	nfs4_state_mark_open_context_bad(state);
 }
 
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e56e846..7f09330 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -104,6 +104,8 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	struct nfs_page		*req;
 	struct nfs_lock_context *l_ctx;
 
+	if (test_bit(NFS_CONTEXT_BAD, &ctx->flags))
+		return ERR_PTR(-EBADF);
 	/* try to allocate the request struct */
 	req = nfs_page_alloc();
 	if (req == NULL)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index a5e5d98..70a26c6 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -514,6 +514,8 @@ void nfs_read_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
 	NFS_PROTO(data->header->inode)->read_rpc_prepare(task, data);
+	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
+		rpc_exit(task, -EIO);
 }
 
 static const struct rpc_call_ops nfs_read_common_ops = {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c483cc5..a2c7c28 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1251,6 +1251,8 @@ void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
 	NFS_PROTO(data->header->inode)->write_rpc_prepare(task, data);
+	if (unlikely(test_bit(NFS_CONTEXT_BAD, &data->args.context->flags)))
+		rpc_exit(task, -EIO);
 }
 
 void nfs_commit_prepare(struct rpc_task *task, void *calldata)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1cc2568..f6b1956 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -77,6 +77,7 @@ struct nfs_open_context {
 	unsigned long flags;
 #define NFS_CONTEXT_ERROR_WRITE		(0)
 #define NFS_CONTEXT_RESEND_WRITES	(1)
+#define NFS_CONTEXT_BAD			(2)
 	int error;
 
 	struct list_head list;
-- 
1.8.1.4

