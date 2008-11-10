From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 32/85] nfs41: sequence setup/done support
Date: Mon, 10 Nov 2008 22:23:49 +0200
Message-ID: <1226348629-8287-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48796 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbYKJUXz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:23:55 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Imlpement the rpc_call_validate_args methods for
asynchronuos nfs rpcs, call nfs41_setup_sequence from
respective rpc_call_validate_args methods.

Call nfs4_sequence_done from respective rpc_call_done methods.

Note that we need to pass a pointer to the nfs_server in calls data
for passing on to nfs4_sequence_done.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/direct.c         |    1 +
 fs/nfs/nfs4_fs.h        |   10 ++++++
 fs/nfs/nfs4proc.c       |   80 ++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/read.c           |   23 +++++++++++++
 fs/nfs/unlink.c         |   16 +++++++++
 fs/nfs/write.c          |   23 +++++++++++++
 include/linux/nfs_xdr.h |    7 ++--
 7 files changed, 152 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 08f6b04..d4ae559 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -306,6 +306,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		if (unlikely(!data))
 			break;
 
+		data->args.server = NFS_SERVER(inode);
 		down_read(&current->mm->mmap_sem);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 1, 0, data->pagevec, NULL);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index bef2fca..d0aac94 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -190,11 +190,21 @@ extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
 extern struct nfs4_state_recovery_ops nfs4_network_partition_recovery_ops;
 #if defined(CONFIG_NFS_V4_1)
+extern int nfs4_setup_sequence(struct nfs_client *clp,
+	struct nfs41_sequence_args *args, struct nfs41_sequence_res *res,
+	int cache_reply, struct rpc_task *task);
 extern void nfs4_put_session(struct nfs4_session **session);
 extern void nfs4_get_session(struct nfs_client *clp);
 extern struct nfs4_session *nfs4_alloc_session(void);
 extern int nfs4_proc_create_session(struct nfs4_session *);
 extern int nfs4_proc_destroy_session(struct nfs4_session *);
+#else /* CONFIG_NFS_v4_1 */
+static inline int nfs4_setup_sequence(struct nfs_client *clp,
+	struct nfs41_sequence_args *args, struct nfs41_sequence_res *res,
+	int cache_reply, struct rpc_task *task)
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const u32 nfs4_fattr_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6d90b07..19ed79c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1196,6 +1196,10 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
+	if (nfs4_setup_sequence(data->o_arg.server->nfs_client,
+				&data->o_arg.seq_args,
+				&data->o_res.seq_res, 1, task))
+		return;
 	rpc_call_start(task);
 	return;
 out_no_action:
@@ -1206,8 +1210,15 @@ out_no_action:
 static void nfs4_open_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
+	struct nfs_server *server;
 
+	server = data->o_arg.server;
 	data->rpc_status = task->tk_status;
+
+	nfs4_sequence_done(server, &data->o_res.seq_res, task->tk_status);
+	/* no restart */
+	nfs4_sequence_free_slot(server, &data->o_res.seq_res);
+
 	if (RPC_ASSASSINATED(task))
 		return;
 	if (task->tk_status == 0) {
@@ -1589,6 +1600,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	struct nfs4_state *state = calldata->state;
 	struct nfs_server *server = NFS_SERVER(calldata->inode);
 
+	nfs4_sequence_done(server, &calldata->res.seq_res, task->tk_status);
 	if (RPC_ASSASSINATED(task))
 		return;
         /* hmm. we are done with the inode, and in the process of freeing
@@ -1651,6 +1663,10 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		calldata->arg.open_flags = FMODE_WRITE;
 	}
 	calldata->timestamp = jiffies;
+	if (nfs4_setup_sequence((NFS_SERVER(calldata->inode))->nfs_client,
+				&calldata->arg.seq_args, &calldata->res.seq_res,
+				1, task))
+		return;
 	rpc_call_start(task);
 }
 
@@ -1690,7 +1706,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	};
 	int status = -ENOMEM;
 
-	calldata = kmalloc(sizeof(*calldata), GFP_KERNEL);
+	calldata = kzalloc(sizeof(*calldata), GFP_KERNEL);
 	if (calldata == NULL)
 		goto out;
 	calldata->inode = state->inode;
@@ -2367,6 +2383,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
 	struct nfs_removeres *res = task->tk_msg.rpc_resp;
 
+	nfs4_sequence_done(res->server, &res->seq_res, task->tk_status);
 	if (nfs4_async_handle_error(task, res->server) == -EAGAIN)
 		return 0;
 	nfs4_sequence_free_slot(res->server, &res->seq_res);
@@ -2824,15 +2841,23 @@ static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
+	int status;
+
+	dprintk("--> %s\n", __func__);
+	status = task->tk_status >= 0 ? 0 : task->tk_status;
 
+	/* nfs4_sequence_free_slot called in the read rpc_call_done */
+	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 	if (nfs4_async_handle_error(task, server) == -EAGAIN) {
 		rpc_restart_call(task);
+		dprintk("<-- %s status= %d\n", __func__, -EAGAIN);
 		return -EAGAIN;
 	}
 
 	nfs_invalidate_atime(data->inode);
 	if (task->tk_status > 0)
 		renew_lease(server, data->timestamp);
+	dprintk("<-- %s status= %d. returning 0\n", __func__, status);
 	return 0;
 }
 
@@ -2847,8 +2872,11 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
-	
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode)) == -EAGAIN) {
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	/* slot is freed in nfs_writeback_done */
+	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
+	if (nfs4_async_handle_error(task, server) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
 	}
@@ -2875,6 +2903,7 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	struct inode *inode = data->inode;
 	struct nfs_server *server = NFS_SERVER(inode);
 
+	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 	if (nfs4_async_handle_error(task, server) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
@@ -3387,6 +3416,12 @@ struct nfs4_delegreturndata {
 static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegreturndata *data = calldata;
+	struct nfs_server *server = data->res.server;
+
+	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
+	/* no restart */
+	nfs4_sequence_free_slot(server, &data->res.seq_res);
+
 	data->rpc_status = task->tk_status;
 	if (data->rpc_status == 0)
 		renew_lease(data->res.server, data->timestamp);
@@ -3397,9 +3432,28 @@ static void nfs4_delegreturn_release(void *calldata)
 	kfree(calldata);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
+{
+	struct nfs_server *server;
+	struct nfs4_delegreturndata *d_data;
+
+	d_data = (struct nfs4_delegreturndata *)data;
+	server = d_data->res.server;
+
+	if (nfs4_setup_sequence(server->nfs_client, &d_data->args.seq_args,
+				&d_data->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 static const struct rpc_call_ops nfs4_delegreturn_ops = {
 	.rpc_call_done = nfs4_delegreturn_done,
 	.rpc_release = nfs4_delegreturn_release,
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs4_delegreturn_prepare,
+#endif
 };
 
 static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync)
@@ -3419,7 +3473,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	};
 	int status = 0;
 
-	data = kmalloc(sizeof(*data), GFP_KERNEL);
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data == NULL)
 		return -ENOMEM;
 	data->args.fhandle = &data->fh;
@@ -3576,7 +3630,7 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	struct nfs4_unlockdata *p;
 	struct inode *inode = lsp->ls_state->inode;
 
-	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
 		return NULL;
 	p->arg.fh = NFS_FH(inode);
@@ -3607,6 +3661,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 	struct nfs4_unlockdata *calldata = data;
 	const struct nfs_server *server = calldata->server;
 
+	nfs4_sequence_done(server, &calldata->res.seq_res, task->tk_status);
 	if (RPC_ASSASSINATED(task))
 		return;
 	switch (task->tk_status) {
@@ -3638,6 +3693,10 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	calldata->timestamp = jiffies;
+	if (nfs4_setup_sequence(calldata->server->nfs_client,
+				&calldata->arg.seq_args,
+				&calldata->res.seq_res, 1, task))
+		return;
 	rpc_call_start(task);
 }
 
@@ -3726,6 +3785,7 @@ struct nfs4_lockdata {
 	unsigned long timestamp;
 	int rpc_status;
 	int cancelled;
+	struct nfs_server *server;
 };
 
 static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
@@ -3752,6 +3812,7 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	p->arg.lock_owner.id = lsp->ls_id.id;
 	p->res.lock_seqid = p->arg.lock_seqid;
 	p->lsp = lsp;
+	p->server = server;
 	atomic_inc(&lsp->ls_count);
 	p->ctx = get_nfs_open_context(ctx);
 	memcpy(&p->fl, fl, sizeof(p->fl));
@@ -3781,6 +3842,9 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	} else
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
+	if (nfs4_setup_sequence(data->server->nfs_client, &data->arg.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
 	rpc_call_start(task);
 	dprintk("%s: done!, ret = %d\n", __func__, data->rpc_status);
 }
@@ -3788,10 +3852,16 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_lockdata *data = calldata;
+	struct nfs_server *server = data->server;
 
 	dprintk("%s: begin!\n", __func__);
 
 	data->rpc_status = task->tk_status;
+
+	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
+	/* No restart */
+	nfs4_sequence_free_slot(data->server, &data->res.seq_res);
+
 	if (RPC_ASSASSINATED(task))
 		goto out;
 	if (data->arg.new_lock_owner != 0) {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 8c2019c..3c77b26 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -22,6 +22,7 @@
 
 #include <asm/system.h>
 
+#include "nfs4_fs.h"
 #include "internal.h"
 #include "iostat.h"
 
@@ -175,6 +176,7 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 		.flags = RPC_TASK_ASYNC | swap_flags,
 	};
 
+	BUG_ON(data->args.server == NULL);
 	data->req	  = req;
 	data->inode	  = inode;
 	data->cred	  = msg.rpc_cred;
@@ -254,6 +256,7 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
 		data = nfs_readdata_alloc(1);
 		if (!data)
 			goto out_bad;
+		data->args.server = NFS_SERVER(inode);
 		list_add(&data->pages, &list);
 		requests++;
 		nbytes -= len;
@@ -305,6 +308,7 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	if (!data)
 		goto out_bad;
 
+	data->args.server = NFS_SERVER(inode);
 	pages = data->pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -404,7 +408,23 @@ static void nfs_readpage_release_partial(void *calldata)
 	nfs_readdata_release(calldata);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+void nfs_read_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_read_data *data = calldata;
+	struct nfs_server *server = data->args.server;
+
+	if (nfs4_setup_sequence(server->nfs_client, &data->args.seq_args,
+				&data->res.seq_res, 0, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 static const struct rpc_call_ops nfs_read_partial_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_read_prepare,
+#endif
 	.rpc_call_done = nfs_readpage_result_partial,
 	.rpc_release = nfs_readpage_release_partial,
 };
@@ -468,6 +488,9 @@ static void nfs_readpage_release_full(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_read_full_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_read_prepare,
+#endif
 	.rpc_call_done = nfs_readpage_result_full,
 	.rpc_release = nfs_readpage_release_full,
 };
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index ecc2953..3df3794 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -15,6 +15,7 @@
 #include <linux/wait.h>
 
 #include "internal.h"
+#include "nfs4_fs.h"
 
 struct nfs_unlinkdata {
 	struct hlist_node list;
@@ -102,9 +103,24 @@ static void nfs_async_unlink_release(void *calldata)
 	nfs_sb_deactive(sb);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_unlinkdata *data = calldata;
+	struct nfs_server *server = NFS_SERVER(data->dir);
+
+	if (nfs4_setup_sequence(server->nfs_client, &data->args.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
 static const struct rpc_call_ops nfs_unlink_ops = {
 	.rpc_call_done = nfs_async_unlink_done,
 	.rpc_release = nfs_async_unlink_release,
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_unlink_prepare,
+#endif
 };
 
 static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct nfs_unlinkdata *data)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 361a61b..7d3fdc8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -25,6 +25,7 @@
 #include "delegation.h"
 #include "internal.h"
 #include "iostat.h"
+#include "nfs4_fs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -1026,7 +1027,23 @@ out:
 	nfs_writedata_release(calldata);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+void nfs_write_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_write_data *data = calldata;
+	struct nfs_server *server = NFS_SERVER(data->inode);
+
+	if (nfs4_setup_sequence(server->nfs_client, &data->args.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 static const struct rpc_call_ops nfs_write_partial_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif
 	.rpc_call_done = nfs_writeback_done_partial,
 	.rpc_release = nfs_writeback_release_partial,
 };
@@ -1089,6 +1106,9 @@ remove_request:
 }
 
 static const struct rpc_call_ops nfs_write_full_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif
 	.rpc_call_done = nfs_writeback_done_full,
 	.rpc_release = nfs_writeback_release_full,
 };
@@ -1328,6 +1348,9 @@ static void nfs_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif
 	.rpc_call_done = nfs_commit_done,
 	.rpc_release = nfs_commit_release,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4144ea2..e932b0d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -172,7 +172,7 @@ struct nfs_openargs {
 		int		delegation_type;	/* CLAIM_PREVIOUS */
 	} u;
 	const struct qstr *	name;
-	const struct nfs_server *server;	 /* Needed for ID mapping */
+	struct nfs_server *	server;	 /* Needed for ID mapping */
 	const u32 *		bitmask;
 	__u32			claim;
 	struct nfs41_sequence_args	seq_args;
@@ -292,7 +292,7 @@ struct nfs4_delegreturnargs {
 
 struct nfs4_delegreturnres {
 	struct nfs_fattr * fattr;
-	const struct nfs_server *server;
+	struct nfs_server *server;
 	struct nfs41_sequence_res	seq_res;
 };
 
@@ -306,6 +306,7 @@ struct nfs_readargs {
 	__u32			count;
 	unsigned int		pgbase;
 	struct page **		pages;
+	struct nfs_server	*server;
 	struct nfs41_sequence_args	seq_args;
 };
 
@@ -355,7 +356,7 @@ struct nfs_removeargs {
 };
 
 struct nfs_removeres {
-	const struct nfs_server *server;
+	struct nfs_server *server;
 	struct nfs4_change_info	cinfo;
 	struct nfs_fattr	dir_attr;
 	struct nfs41_sequence_res 	seq_res;
-- 
1.6.0.2

