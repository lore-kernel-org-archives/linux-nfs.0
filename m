Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:39145 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab1GRP0e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2011 11:26:34 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        viro@ZenIV.linux.org.uk
Subject: [PATCH] nfs: don't use d_move in nfs_async_rename_done
Date: Mon, 18 Jul 2011 11:26:30 -0400
Message-Id: <1311002790-6650-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If the task that initiated the sillyrename ends up being killed by a
fatal signal, then it will eventually return back to userspace and end
up releasing the i_mutex. d_move however needs to be done while holding
the i_mutex.

Instead of using d_move here, just unhash the old and new dentries to
prevent them from being found by lookups. With this change though, the
dentries are now incorrect post-rename and do not reflect the actual
name of the file on the server. I'm proceeding under the assumption
that since they are unhashed that this isn't really a problem.

In order for the sillydelete to still work though, the dname must be
copied earlier when setting up the sillydelete info, and the name must
be recopied if the sillydelete info has to be moved to a new dentry.

Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/unlink.c |   29 +++++++++++++++++++----------
 1 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 8d6864c..7687f4f 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -147,7 +147,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 
 	alias = d_lookup(parent, &data->args.name);
 	if (alias != NULL) {
-		int ret = 0;
+		int ret;
 		void *devname_garbage = NULL;
 
 		/*
@@ -155,14 +155,16 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 		 * the sillyrename information to the aliased dentry.
 		 */
 		nfs_free_dname(data);
+		ret = nfs_copy_dname(alias, data);
 		spin_lock(&alias->d_lock);
-		if (alias->d_inode != NULL &&
+		if (ret == 0 && alias->d_inode != NULL &&
 		    !(alias->d_flags & DCACHE_NFSFS_RENAMED)) {
 			devname_garbage = alias->d_fsdata;
 			alias->d_fsdata = data;
 			alias->d_flags |= DCACHE_NFSFS_RENAMED;
 			ret = 1;
-		}
+		} else
+			ret = 0;
 		spin_unlock(&alias->d_lock);
 		nfs_dec_sillycount(dir);
 		dput(alias);
@@ -171,8 +173,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 		 * point dentry is definitely not a root, so we won't need
 		 * that anymore.
 		 */
-		if (devname_garbage)
-			kfree(devname_garbage);
+		kfree(devname_garbage);
 		return ret;
 	}
 	data->dir = igrab(dir);
@@ -204,8 +205,6 @@ static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
 	if (parent == NULL)
 		goto out_free;
 	dir = parent->d_inode;
-	if (nfs_copy_dname(dentry, data) != 0)
-		goto out_dput;
 	/* Non-exclusive lock protects against concurrent lookup() calls */
 	spin_lock(&dir->i_lock);
 	if (atomic_inc_not_zero(&NFS_I(dir)->silly_count) == 0) {
@@ -366,6 +365,8 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
 	struct nfs_renamedata *data = calldata;
 	struct inode *old_dir = data->old_dir;
 	struct inode *new_dir = data->new_dir;
+	struct dentry *old_dentry = data->old_dentry;
+	struct dentry *new_dentry = data->new_dentry;
 
 	if (!NFS_PROTO(old_dir)->rename_done(task, old_dir, new_dir)) {
 		nfs_restart_rpc(task, NFS_SERVER(old_dir)->nfs_client);
@@ -373,12 +374,12 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
 	}
 
 	if (task->tk_status != 0) {
-		nfs_cancel_async_unlink(data->old_dentry);
+		nfs_cancel_async_unlink(old_dentry);
 		return;
 	}
 
-	nfs_set_verifier(data->old_dentry, nfs_save_change_attribute(old_dir));
-	d_move(data->old_dentry, data->new_dentry);
+	d_drop(old_dentry);
+	d_drop(new_dentry);
 }
 
 /**
@@ -560,6 +561,14 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	if (error)
 		goto out_dput;
 
+	/* populate unlinkdata with the right dname */
+	error = nfs_copy_dname(sdentry,
+				(struct nfs_unlinkdata *)dentry->d_fsdata);
+	if (error) {
+		nfs_cancel_async_unlink(dentry);
+		goto out_dput;
+	}
+
 	/* run the rename task, undo unlink if it fails */
 	task = nfs_async_rename(dir, dir, dentry, sdentry);
 	if (IS_ERR(task)) {
-- 
1.7.6

