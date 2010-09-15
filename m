Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753650Ab0IONYK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:24:10 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 8/8] nfs: make sillyrename an async operation
Date: Wed, 15 Sep 2010 09:24:01 -0400
Message-Id: <1284557041-4375-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
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
---
 fs/nfs/unlink.c |  198 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 183 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 42cadd1..87a65ac 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -307,6 +307,164 @@ nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
 		nfs_free_unlinkdata(data);
 }
 
+/* Cancel a queued async unlink. Called when a sillyrename run fails. */
+static void
+nfs_cancel_async_unlink(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
+		dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
+		nfs_free_unlinkdata(dentry->d_fsdata);
+	}
+	spin_unlock(&dentry->d_lock);
+}
+
+struct nfs_renamedata {
+	struct nfs_renameargs		args;
+	struct nfs_renameres		res;
+	struct rpc_cred	*		cred;
+	struct inode *			old_dir;
+	struct inode *			new_dir;
+	struct dentry *			old_dentry;
+	struct dentry *			new_dentry;
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
+	if (task->tk_status != 0)
+		return;
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
+	/* FIXME: is this OK here? Note that call_done will be done first... */
+	if (data->old_dentry->d_inode)
+		nfs_mark_for_revalidate(data->old_dentry->d_inode);
+
+	nfs_free_fattr(data->res.old_fattr);
+	nfs_free_fattr(data->res.new_fattr);
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
+ */
+static struct rpc_task *
+nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
+		 struct dentry *old_dentry, struct dentry *new_dentry)
+{
+	int error;
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
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (data == NULL)
+		return ERR_PTR(-ENOMEM);
+	task_setup_data.callback_data = data,
+
+	data->cred = rpc_lookup_cred();
+	if (IS_ERR(data->cred)) {
+		kfree(data);
+		return (struct rpc_task *)data->cred;
+	}
+	msg.rpc_argp = &data->args,
+	msg.rpc_resp = &data->res,
+	msg.rpc_cred = data->cred;
+
+	/* set up nfs_renamedata */
+	data->old_dir = old_dir;
+	atomic_inc(&old_dir->i_count);
+	data->new_dir = new_dir;
+	atomic_inc(&new_dir->i_count);
+	data->old_dentry = dget(old_dentry);
+	data->new_dentry = dget(new_dentry);
+
+	/* set up nfs_renameargs */
+	data->args.old_dir = NFS_FH(old_dir);
+	data->args.old_name = &old_dentry->d_name;
+	data->args.new_dir = NFS_FH(new_dir);
+	data->args.new_name = &new_dentry->d_name;
+
+	nfs_sb_active(old_dir->i_sb);
+
+	error = NFS_PROTO(data->old_dir)->rename_setup(&msg, old_dir);
+	if (error) {
+		nfs_async_rename_release(data);
+		return ERR_PTR(error);
+	}
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
@@ -314,11 +472,11 @@ nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
  *
  * NFSv2/3 is stateless, so the server doesn't know when the client is
  * holding a file open. To prevent problems when a file is unlinked while
- * it's still open, we perform a "silly-rename" -- that is, we rename the
- * file to a hidden file in the same directory, and only actually perform
- * the unlink once the last reference to it is put.
+ * it's still open, the client performs a "silly-rename" -- that is, it
+ * renames the file to a hidden file in the same directory, and only
+ * performs the unlink once the last reference to it is put.
  *
- * The final cleanup is done via nfs_dentry_iput.
+ * The final cleanup is done during dentry_iput.
  */
 int
 nfs_sillyrename(struct inode *dir, struct dentry *dentry)
@@ -328,8 +486,8 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	const int      countersize = sizeof(sillycounter)*2;
 	const int      slen        = sizeof(".nfs")+fileidsize+countersize-1;
 	char           silly[slen+1];
-	struct qstr    qsilly;
 	struct dentry *sdentry;
+	struct rpc_task *task;
 	int            error = -EIO;
 
 	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
@@ -371,17 +529,27 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 			goto out;
 	} while(sdentry->d_inode != NULL); /* need negative lookup */
 
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
-- 
1.7.1

