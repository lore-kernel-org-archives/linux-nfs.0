Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48333 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030918Ab2CSSyr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:54:47 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 4/4] NFS: Remove nfs4_setup_sequence from generic rename code
Date: Mon, 19 Mar 2012 14:54:42 -0400
Message-Id: <1332183282-9743-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332183282-9743-1-git-send-email-bjschuma@netapp.com>
References: <1332183282-9743-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This is an NFS v4 specific operation, so it belongs in the NFS v4 code
and not the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs3proc.c       |    6 ++++++
 fs/nfs/nfs4proc.c       |   11 +++++++++++
 fs/nfs/proc.c           |    6 ++++++
 fs/nfs/unlink.c         |   23 +----------------------
 include/linux/nfs_xdr.h |   13 +++++++++++++
 5 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 7f3f957..5242eae 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -450,6 +450,11 @@ nfs3_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_RENAME];
 }
 
+static void nfs3_proc_rename_rpc_prepare(struct rpc_task *task, struct nfs_renamedata *data)
+{
+	rpc_call_start(task);
+}
+
 static int
 nfs3_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 		      struct inode *new_dir)
@@ -883,6 +888,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.unlink_done	= nfs3_proc_unlink_done,
 	.rename		= nfs3_proc_rename,
 	.rename_setup	= nfs3_proc_rename_setup,
+	.rename_rpc_prepare = nfs3_proc_rename_rpc_prepare,
 	.rename_done	= nfs3_proc_rename_done,
 	.link		= nfs3_proc_link,
 	.symlink	= nfs3_proc_symlink,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 918af9c..d98f985 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2814,6 +2814,16 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	nfs41_init_sequence(&arg->seq_args, &res->seq_res, 1);
 }
 
+static void nfs4_proc_rename_rpc_prepare(struct rpc_task *task, struct nfs_renamedata *data)
+{
+	if (nfs4_setup_sequence(NFS_SERVER(data->old_dir),
+				&data->args.seq_args,
+				&data->res.seq_res,
+				task))
+		return;
+	rpc_call_start(task);
+}
+
 static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 				 struct inode *new_dir)
 {
@@ -6463,6 +6473,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.unlink_done	= nfs4_proc_unlink_done,
 	.rename		= nfs4_proc_rename,
 	.rename_setup	= nfs4_proc_rename_setup,
+	.rename_rpc_prepare = nfs4_proc_rename_rpc_prepare,
 	.rename_done	= nfs4_proc_rename_done,
 	.link		= nfs4_proc_link,
 	.symlink	= nfs4_proc_symlink,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 528b9a2..b63b6f4 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -377,6 +377,11 @@ nfs_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	msg->rpc_proc = &nfs_procedures[NFSPROC_RENAME];
 }
 
+static void nfs_proc_rename_rpc_prepare(struct rpc_task *task, struct nfs_renamedata *data)
+{
+	rpc_call_start(task);
+}
+
 static int
 nfs_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 		     struct inode *new_dir)
@@ -740,6 +745,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.unlink_done	= nfs_proc_unlink_done,
 	.rename		= nfs_proc_rename,
 	.rename_setup	= nfs_proc_rename_setup,
+	.rename_rpc_prepare = nfs_proc_rename_rpc_prepare,
 	.rename_done	= nfs_proc_rename_done,
 	.link		= nfs_proc_link,
 	.symlink	= nfs_proc_symlink,
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 9c5a798..3210a03 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -323,18 +323,6 @@ nfs_cancel_async_unlink(struct dentry *dentry)
 	spin_unlock(&dentry->d_lock);
 }
 
-struct nfs_renamedata {
-	struct nfs_renameargs	args;
-	struct nfs_renameres	res;
-	struct rpc_cred		*cred;
-	struct inode		*old_dir;
-	struct dentry		*old_dentry;
-	struct nfs_fattr	old_fattr;
-	struct inode		*new_dir;
-	struct dentry		*new_dentry;
-	struct nfs_fattr	new_fattr;
-};
-
 /**
  * nfs_async_rename_done - Sillyrename post-processing
  * @task: rpc_task of the sillyrename
@@ -385,25 +373,16 @@ static void nfs_async_rename_release(void *calldata)
 	kfree(data);
 }
 
-#if defined(CONFIG_NFS_V4_1)
 static void nfs_rename_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_renamedata *data = calldata;
-	struct nfs_server *server = NFS_SERVER(data->old_dir);
-
-	if (nfs4_setup_sequence(server, &data->args.seq_args,
-				&data->res.seq_res, task))
-		return;
-	rpc_call_start(task);
+	NFS_PROTO(data->old_dir)->rename_rpc_prepare(task, data);
 }
-#endif /* CONFIG_NFS_V4_1 */
 
 static const struct rpc_call_ops nfs_rename_ops = {
 	.rpc_call_done = nfs_async_rename_done,
 	.rpc_release = nfs_async_rename_release,
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs_rename_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 };
 
 /**
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8d93e68..bfd0d1b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1201,6 +1201,18 @@ struct nfs_unlinkdata {
 	struct nfs_fattr dir_attr;
 };
 
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
 struct nfs_access_entry;
 struct nfs_client;
 struct rpc_timeout;
@@ -1235,6 +1247,7 @@ struct nfs_rpc_ops {
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
 	void	(*rename_setup)  (struct rpc_message *msg, struct inode *dir);
+	void	(*rename_rpc_prepare)(struct rpc_task *task, struct nfs_renamedata *);
 	int	(*rename_done) (struct rpc_task *task, struct inode *old_dir, struct inode *new_dir);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);
 	int	(*symlink) (struct inode *, struct dentry *, struct page *,
-- 
1.7.9.4

