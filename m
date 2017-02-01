Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43680 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751328AbdBAKql (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Feb 2017 05:46:41 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFS: nfs_rename() handle -ERESTARTSYS dentry left behind
Date: Wed,  1 Feb 2017 00:00:07 -0500
Message-Id: <612a69423fe410fef453e8488ff8d33ace3c00a4.1485922464.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An interrupted rename will leave the old dentry behind if the rename
succeeds.  Fix this by moving the final local work of the rename to
rpc_call_done so that the results of the RENAME can always be handled,
even if the original process has already returned with -ERESTARTSYS.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c | 36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fad81041f5ab..fb499a3f21b5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2002,6 +2002,29 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 }
 EXPORT_SYMBOL_GPL(nfs_link);
 
+static void
+nfs_complete_rename(struct rpc_task *task, struct nfs_renamedata *data)
+{
+	struct dentry *old_dentry = data->old_dentry;
+	struct dentry *new_dentry = data->new_dentry;
+	struct inode *old_inode = d_inode(old_dentry);
+	struct inode *new_inode = d_inode(new_dentry);
+
+	nfs_mark_for_revalidate(old_inode);
+
+	switch (task->tk_status) {
+	case 0:
+		if (new_inode != NULL)
+			nfs_drop_nlink(new_inode);
+		d_move(old_dentry, new_dentry);
+		nfs_set_verifier(new_dentry,
+					nfs_save_change_attribute(data->new_dir));
+		break;
+	case -ENOENT:
+		nfs_dentry_handle_enoent(old_dentry);
+	}
+}
+
 /*
  * RENAME
  * FIXME: Some nfsds, like the Linux user space nfsd, may generate a
@@ -2084,7 +2107,8 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (new_inode != NULL)
 		NFS_PROTO(new_inode)->return_delegation(new_inode);
 
-	task = nfs_async_rename(old_dir, new_dir, old_dentry, new_dentry, NULL);
+	task = nfs_async_rename(old_dir, new_dir, old_dentry, new_dentry,
+					nfs_complete_rename);
 	if (IS_ERR(task)) {
 		error = PTR_ERR(task);
 		goto out;
@@ -2094,21 +2118,11 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (error == 0)
 		error = task->tk_status;
 	rpc_put_task(task);
-	nfs_mark_for_revalidate(old_inode);
 out:
 	if (rehash)
 		d_rehash(rehash);
 	trace_nfs_rename_exit(old_dir, old_dentry,
 			new_dir, new_dentry, error);
-	if (!error) {
-		if (new_inode != NULL)
-			nfs_drop_nlink(new_inode);
-		d_move(old_dentry, new_dentry);
-		nfs_set_verifier(new_dentry,
-					nfs_save_change_attribute(new_dir));
-	} else if (error == -ENOENT)
-		nfs_dentry_handle_enoent(old_dentry);
-
 	/* new dentry created? */
 	if (dentry)
 		dput(dentry);
-- 
2.9.3

