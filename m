Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755057Ab0IPOYL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 10:24:11 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] nfs: make sillyrename an async operation
Date: Thu, 16 Sep 2010 10:24:05 -0400
Message-Id: <1284647045-18286-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
References: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A synchronous rename can be interrupted by a SIGKILL. If that happens
during a sillyrename operation, it's possible for the rename call to
be sent to the server, but the task exits before processing the
reply. If this happens, the sillyrenamed file won't get cleaned up
during nfs_dentry_iput and the server is left with a dangling .nfs* file
hanging around.

Fix this problem by turning sillyrename into an asynchronous operation
and have the task doing the sillyrename just wait on the reply. If the
task is killed before the sillyrename completes, it'll still proceed
to completion.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs3proc.c       |   23 ++++++
 fs/nfs/nfs4proc.c       |   30 +++++++
 fs/nfs/proc.c           |   19 +++++
 fs/nfs/unlink.c         |  200 ++++++++++++++++++++++++++++++++++++++++++++---
 include/linux/nfs_xdr.h |    2 +
 5 files changed, 263 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index c5cccf1..b6c8932 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -438,6 +438,27 @@ nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	return 1;
 }
 
+static void
+nfs3_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+{
+	msg->rpc_proc = &nfs3_procedures[NFS3PROC_RENAME];
+}
+
+static int
+nfs3_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
+		      struct inode *new_dir)
+{
+	struct nfs_renameres *res;
+
+	if (nfs3_async_handle_jukebox(task, old_dir))
+		return 0;
+	res = task->tk_msg.rpc_resp;
+
+	nfs_post_op_update_inode(old_dir, res->old_fattr);
+	nfs_post_op_update_inode(new_dir, res->new_fattr);
+	return 1;
+}
+
 static int
 nfs3_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		 struct inode *new_dir, struct qstr *new_name)
@@ -842,6 +863,8 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.unlink_setup	= nfs3_proc_unlink_setup,
 	.unlink_done	= nfs3_proc_unlink_done,
 	.rename		= nfs3_proc_rename,
+	.rename_setup	= nfs3_proc_rename_setup,
+	.rename_done	= nfs3_proc_rename_done,
 	.link		= nfs3_proc_link,
 	.symlink	= nfs3_proc_symlink,
 	.mkdir		= nfs3_proc_mkdir,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 120a8a6..d58e049 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2671,6 +2671,34 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	return 1;
 }
 
+static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+{
+	struct nfs_server *server = NFS_SERVER(dir);
+	struct nfs_renameargs *arg = msg->rpc_argp;
+	struct nfs_renameres *res = msg->rpc_resp;
+
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
+	arg->bitmask = server->attr_bitmask;
+	res->server = server;
+}
+
+static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
+				 struct inode *new_dir)
+{
+	struct nfs_renameres *res = task->tk_msg.rpc_resp;
+
+	if (!nfs4_sequence_done(task, &res->seq_res))
+		return 0;
+	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
+		return 0;
+
+	update_changeattr(old_dir, &res->old_cinfo);
+	nfs_post_op_update_inode(old_dir, res->old_fattr);
+	update_changeattr(new_dir, &res->new_cinfo);
+	nfs_post_op_update_inode(new_dir, res->new_fattr);
+	return 1;
+}
+
 static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
 {
@@ -5443,6 +5471,8 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.unlink_setup	= nfs4_proc_unlink_setup,
 	.unlink_done	= nfs4_proc_unlink_done,
 	.rename		= nfs4_proc_rename,
+	.rename_setup	= nfs4_proc_rename_setup,
+	.rename_done	= nfs4_proc_rename_done,
 	.link		= nfs4_proc_link,
 	.symlink	= nfs4_proc_symlink,
 	.mkdir		= nfs4_proc_mkdir,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 5c70b58..17dc25f 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -365,6 +365,23 @@ static int nfs_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	return 1;
 }
 
+static void
+nfs_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
+{
+	msg->rpc_proc = &nfs_procedures[NFSPROC_RENAME];
+}
+
+static int
+nfs_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
+		     struct inode *new_dir)
+{
+	if (nfs_async_handle_expired_key(task))
+		return 0;
+	nfs_mark_for_revalidate(old_dir);
+	nfs_mark_for_revalidate(new_dir);
+	return 1;
+}
+
 static int
 nfs_proc_rename(struct inode *old_dir, struct qstr *old_name,
 		struct inode *new_dir, struct qstr *new_name)
@@ -703,6 +720,8 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.unlink_setup	= nfs_proc_unlink_setup,
 	.unlink_done	= nfs_proc_unlink_done,
 	.rename		= nfs_proc_rename,
+	.rename_setup	= nfs_proc_rename_setup,
+	.rename_done	= nfs_proc_rename_done,
 	.link		= nfs_proc_link,
 	.symlink	= nfs_proc_symlink,
 	.mkdir		= nfs_proc_mkdir,
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index c3ce865..698b3e6 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -307,6 +307,174 @@ nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
 		nfs_free_unlinkdata(data);
 }
 
+/* Cancel a queued async unlink. Called when a sillyrename run fails. */
+static void
+nfs_cancel_async_unlink(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
+		struct nfs_unlinkdata *data = dentry->d_fsdata;
+
+		dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
+		spin_unlock(&dentry->d_lock);
+		nfs_free_unlinkdata(data);
+		return;
+	}
+	spin_unlock(&dentry->d_lock);
+}
+
+struct nfs_renamedata {
+	struct nfs_renameargs	args;
+	struct nfs_renameres	res;
+	struct rpc_cred		*cred;
+	struct inode		*old_dir;
+	struct dentry		*old_dentry;
+	struct nfs_fattr	old_fattr;
+	struct inode		*new_dir;
+	struct dentry		*new_dentry;
+	struct nfs_fattr	new_fattr;
+};
+
+/**
+ * nfs_async_rename_done - Sillyrename post-processing
+ * @task: rpc_task of the sillyrename
+ * @calldata: nfs_renamedata for the sillyrename
+ *
+ * Do the directory attribute updates and the d_move
+ */
+static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs_renamedata *data = calldata;
+	struct inode *old_dir = data->old_dir;
+	struct inode *new_dir = data->new_dir;
+
+	if (!NFS_PROTO(old_dir)->rename_done(task, old_dir, new_dir)) {
+		nfs_restart_rpc(task, NFS_SERVER(old_dir)->nfs_client);
+		return;
+	}
+
+	if (task->tk_status != 0) {
+		nfs_cancel_async_unlink(data->old_dentry);
+		return;
+	}
+
+	nfs_set_verifier(data->old_dentry, nfs_save_change_attribute(old_dir));
+	d_move(data->old_dentry, data->new_dentry);
+}
+
+/**
+ * nfs_async_rename_release - Release the sillyrename data.
+ * @calldata: the struct nfs_renamedata to be released
+ */
+static void nfs_async_rename_release(void *calldata)
+{
+	struct nfs_renamedata	*data = calldata;
+	struct super_block *sb = data->old_dir->i_sb;
+
+	if (data->old_dentry->d_inode)
+		nfs_mark_for_revalidate(data->old_dentry->d_inode);
+
+	dput(data->old_dentry);
+	dput(data->new_dentry);
+	iput(data->old_dir);
+	iput(data->new_dir);
+	nfs_sb_deactive(sb);
+	put_rpccred(data->cred);
+	kfree(data);
+}
+
+#if defined(CONFIG_NFS_V4_1)
+static void nfs_rename_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_renamedata *data = calldata;
+	struct nfs_server *server = NFS_SERVER(data->old_dir);
+
+	if (nfs4_setup_sequence(server, &data->args.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
+static const struct rpc_call_ops nfs_rename_ops = {
+	.rpc_call_done = nfs_async_rename_done,
+	.rpc_release = nfs_async_rename_release,
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_rename_prepare,
+#endif /* CONFIG_NFS_V4_1 */
+};
+
+/**
+ * nfs_async_rename - perform an asynchronous rename operation
+ * @old_dir: directory that currently holds the dentry to be renamed
+ * @new_dir: target directory for the rename
+ * @old_dentry: original dentry to be renamed
+ * @new_dentry: dentry to which the old_dentry should be renamed
+ *
+ * It's expected that valid references to the dentries and inodes are held
+ */
+static struct rpc_task *
+nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
+		 struct dentry *old_dentry, struct dentry *new_dentry)
+{
+	struct nfs_renamedata *data;
+	struct rpc_message msg = { };
+	struct rpc_task_setup task_setup_data = {
+		.rpc_message = &msg,
+		.callback_ops = &nfs_rename_ops,
+		.workqueue = nfsiod_workqueue,
+		.rpc_client = NFS_CLIENT(old_dir),
+		.flags = RPC_TASK_ASYNC,
+	};
+	struct rpc_task *task;
+
+	data = kmalloc(sizeof(*data), GFP_KERNEL);
+	if (data == NULL)
+		return ERR_PTR(-ENOMEM);
+	task_setup_data.callback_data = data,
+
+	data->cred = rpc_lookup_cred();
+	if (IS_ERR(data->cred)) {
+		task = (struct rpc_task *)data->cred;
+		kfree(data);
+		return task;
+	}
+
+	msg.rpc_argp = &data->args;
+	msg.rpc_resp = &data->res;
+	msg.rpc_cred = data->cred;
+
+	/* set up nfs_renamedata */
+	data->old_dir = old_dir;
+	atomic_inc(&old_dir->i_count);
+	data->new_dir = new_dir;
+	atomic_inc(&new_dir->i_count);
+	data->old_dentry = dget(old_dentry);
+	data->new_dentry = dget(new_dentry);
+	nfs_fattr_init(&data->old_fattr);
+	nfs_fattr_init(&data->new_fattr);
+
+	/* set up nfs_renameargs */
+	data->args.old_dir = NFS_FH(old_dir);
+	data->args.old_name = &old_dentry->d_name;
+	data->args.new_dir = NFS_FH(new_dir);
+	data->args.new_name = &new_dentry->d_name;
+
+	/* set up nfs_renameres */
+	data->res.old_fattr = &data->old_fattr;
+	data->res.new_fattr = &data->new_fattr;
+
+	nfs_sb_active(old_dir->i_sb);
+
+	NFS_PROTO(data->old_dir)->rename_setup(&msg, old_dir);
+
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		nfs_async_rename_release(data);
+
+	return task;
+}
+
 /**
  * nfs_sillyrename - Perform a silly-rename of a dentry
  * @dir: inode of directory that contains dentry
@@ -328,8 +496,8 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	const int      countersize = sizeof(sillycounter)*2;
 	const int      slen        = sizeof(".nfs")+fileidsize+countersize-1;
 	char           silly[slen+1];
-	struct qstr    qsilly;
 	struct dentry *sdentry;
+	struct rpc_task *task;
 	int            error = -EIO;
 
 	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
@@ -371,17 +539,27 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 			goto out;
 	} while (sdentry->d_inode != NULL); /* need negative lookup */
 
-	qsilly.name = silly;
-	qsilly.len  = strlen(silly);
-	error = NFS_PROTO(dir)->rename(dir, &dentry->d_name, dir, &qsilly);
-	if (dentry->d_inode)
-		nfs_mark_for_revalidate(dentry->d_inode);
-	if (!error) {
-		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-		d_move(dentry, sdentry);
-		error = nfs_async_unlink(dir, dentry);
-		/* If we return 0 we don't unlink */
+	/* queue unlink first. Can't do this from rpc_release as it
+	 * has to allocate memory
+	 */
+	error = nfs_async_unlink(dir, dentry);
+	if (error)
+		goto out_dput;
+
+	/* run the rename task, undo unlink if it fails */
+	task = nfs_async_rename(dir, dir, dentry, sdentry);
+	if (IS_ERR(task)) {
+		error = -EBUSY;
+		nfs_cancel_async_unlink(dentry);
+		goto out_dput;
 	}
+
+	/* wait for the RPC task to complete, unless a SIGKILL intervenes */
+	error = rpc_wait_for_completion_task(task);
+	if (error == 0)
+		error = task->tk_status;
+	rpc_put_task(task);
+out_dput:
 	dput(sdentry);
 out:
 	return error;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bfc5417..2d2ab3b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1018,6 +1018,8 @@ struct nfs_rpc_ops {
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
+	void	(*rename_setup)  (struct rpc_message *msg, struct inode *dir);
+	int	(*rename_done) (struct rpc_task *task, struct inode *old_dir, struct inode *new_dir);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);
 	int	(*symlink) (struct inode *, struct dentry *, struct page *,
 			    unsigned int, struct iattr *);
-- 
1.7.1

