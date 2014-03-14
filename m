Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:42531 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbaCNRrS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2014 13:47:18 -0400
Received: by mail-qa0-f50.google.com with SMTP id o15so2876796qap.9
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2014 10:47:17 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] nfs: convert nfs_rename to use async_rename infrastructure
Date: Fri, 14 Mar 2014 13:47:03 -0400
Message-Id: <1394819225-13713-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1394819225-13713-1-git-send-email-jlayton@redhat.com>
References: <1394819225-13713-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There isn't much sense in maintaining two separate versions of rename
code. Convert nfs_rename to use the asynchronous rename infrastructure
that nfs_sillyrename uses, and emulate synchronous behavior by having
the task just wait on the reply.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4a48fe4b84b6..70099b402b0d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1911,6 +1911,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	struct inode *old_inode = old_dentry->d_inode;
 	struct inode *new_inode = new_dentry->d_inode;
 	struct dentry *dentry = NULL, *rehash = NULL;
+	struct rpc_task *task;
 	int error = -EBUSY;
 
 	dfprintk(VFS, "NFS: rename(%pd2 -> %pd2, ct=%d)\n",
@@ -1958,23 +1959,38 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (new_inode != NULL)
 		NFS_PROTO(new_inode)->return_delegation(new_inode);
 
-	error = NFS_PROTO(old_dir)->rename(old_dir, &old_dentry->d_name,
-					   new_dir, &new_dentry->d_name);
+	task = nfs_async_rename(old_dir, new_dir, old_dentry, new_dentry, NULL);
+	if (IS_ERR(task)) {
+		error = PTR_ERR(task);
+		goto out_dput;
+	}
+
+	error = rpc_wait_for_completion_task(task);
+	if (error == 0)
+		error = task->tk_status;
+	rpc_put_task(task);
 	nfs_mark_for_revalidate(old_inode);
 out:
 	if (rehash)
 		d_rehash(rehash);
 	trace_nfs_rename_exit(old_dir, old_dentry,
 			new_dir, new_dentry, error);
-	if (!error) {
+	switch (error) {
+	case 0:
 		if (new_inode != NULL)
 			nfs_drop_nlink(new_inode);
 		d_move(old_dentry, new_dentry);
 		nfs_set_verifier(new_dentry,
 					nfs_save_change_attribute(new_dir));
-	} else if (error == -ENOENT)
+		break;
+	case -ENOENT:
 		nfs_dentry_handle_enoent(old_dentry);
-
+		break;
+	case -ERESTARTSYS:
+		d_drop(old_dentry);
+		d_drop(new_dentry);
+	}
+out_dput:
 	/* new dentry created? */
 	if (dentry)
 		dput(dentry);
-- 
1.8.5.3

