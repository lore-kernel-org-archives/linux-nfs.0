Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49004 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752295AbdFPNuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Jun 2017 09:50:21 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, mszeredi@redhat.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/2] Revert "NFS: nfs_rename() handle -ERESTARTSYS dentry left behind"
Date: Fri, 16 Jun 2017 09:50:18 -0400
Message-Id: <c2d508d2180e7bfe3a93ed70b7f523cfacb4d7f9.1497620860.git.bcodding@redhat.com>
In-Reply-To: <cover.1497620860.git.bcodding@redhat.com>
References: <cover.1497620860.git.bcodding@redhat.com>
In-Reply-To: <cover.1497620860.git.bcodding@redhat.com>
References: <cover.1497620860.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 920b4530fb80430ff30ef83efe21ba1fa5623731 which could
call d_move() without holding the directory's i_mutex, and reverts commit
d4ea7e3c5c0e341c15b073016dbf3ab6c65f12f3 "NFS: Fix old dentry rehash after
move", which was a follow-up fix.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Fixes: 920b4530fb80 ("NFS: nfs_rename() handle -ERESTARTSYS dentry left behind")
Cc: stable@vger.kernel.org # v4.10+
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c | 51 ++++++++++++++++++++++++---------------------------
 1 file changed, 24 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 32ccd7754f8a..2ac00bf4ecf1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1946,29 +1946,6 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 }
 EXPORT_SYMBOL_GPL(nfs_link);
 
-static void
-nfs_complete_rename(struct rpc_task *task, struct nfs_renamedata *data)
-{
-	struct dentry *old_dentry = data->old_dentry;
-	struct dentry *new_dentry = data->new_dentry;
-	struct inode *old_inode = d_inode(old_dentry);
-	struct inode *new_inode = d_inode(new_dentry);
-
-	nfs_mark_for_revalidate(old_inode);
-
-	switch (task->tk_status) {
-	case 0:
-		if (new_inode != NULL)
-			nfs_drop_nlink(new_inode);
-		d_move(old_dentry, new_dentry);
-		nfs_set_verifier(new_dentry,
-					nfs_save_change_attribute(data->new_dir));
-		break;
-	case -ENOENT:
-		nfs_dentry_handle_enoent(old_dentry);
-	}
-}
-
 /*
  * RENAME
  * FIXME: Some nfsds, like the Linux user space nfsd, may generate a
@@ -1999,7 +1976,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 {
 	struct inode *old_inode = d_inode(old_dentry);
 	struct inode *new_inode = d_inode(new_dentry);
-	struct dentry *dentry = NULL;
+	struct dentry *dentry = NULL, *rehash = NULL;
 	struct rpc_task *task;
 	int error = -EBUSY;
 
@@ -2022,8 +1999,10 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		 * To prevent any new references to the target during the
 		 * rename, we unhash the dentry in advance.
 		 */
-		if (!d_unhashed(new_dentry))
+		if (!d_unhashed(new_dentry)) {
 			d_drop(new_dentry);
+			rehash = new_dentry;
+		}
 
 		if (d_count(new_dentry) > 2) {
 			int err;
@@ -2040,6 +2019,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 				goto out;
 
 			new_dentry = dentry;
+			rehash = NULL;
 			new_inode = NULL;
 		}
 	}
@@ -2048,8 +2028,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (new_inode != NULL)
 		NFS_PROTO(new_inode)->return_delegation(new_inode);
 
-	task = nfs_async_rename(old_dir, new_dir, old_dentry, new_dentry,
-					nfs_complete_rename);
+	task = nfs_async_rename(old_dir, new_dir, old_dentry, new_dentry, NULL);
 	if (IS_ERR(task)) {
 		error = PTR_ERR(task);
 		goto out;
@@ -2059,9 +2038,27 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (error == 0)
 		error = task->tk_status;
 	rpc_put_task(task);
+	nfs_mark_for_revalidate(old_inode);
 out:
+	if (rehash)
+		d_rehash(rehash);
 	trace_nfs_rename_exit(old_dir, old_dentry,
 			new_dir, new_dentry, error);
+	if (!error) {
+		if (new_inode != NULL)
+			nfs_drop_nlink(new_inode);
+		/*
+		 * The d_move() should be here instead of in an async RPC completion
+		 * handler because we need the proper locks to move the dentry.  If
+		 * we're interrupted by a signal, the async RPC completion handler
+		 * should mark the directories for revalidation.
+		 */
+		d_move(old_dentry, new_dentry);
+		nfs_set_verifier(new_dentry,
+					nfs_save_change_attribute(new_dir));
+	} else if (error == -ENOENT)
+		nfs_dentry_handle_enoent(old_dentry);
+
 	/* new dentry created? */
 	if (dentry)
 		dput(dentry);
-- 
2.9.3

