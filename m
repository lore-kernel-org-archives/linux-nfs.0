Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:39230 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932506AbaCQLHK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2014 07:07:10 -0400
Received: by mail-qc0-f171.google.com with SMTP id x13so5637460qcv.2
        for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2014 04:07:10 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/5] nfs: convert nfs_rename to use async_rename infrastructure
Date: Mon, 17 Mar 2014 07:06:56 -0400
Message-Id: <1395054418-14504-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
References: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There isn't much sense in maintaining two separate versions of rename
code. Convert nfs_rename to use the asynchronous rename infrastructure
that nfs_sillyrename uses, and emulate synchronous behavior by having
the task just wait on the reply.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4a48fe4b84b6..e6f8e2c97653 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1911,6 +1911,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	struct inode *old_inode = old_dentry->d_inode;
 	struct inode *new_inode = new_dentry->d_inode;
 	struct dentry *dentry = NULL, *rehash = NULL;
+	struct rpc_task *task;
 	int error = -EBUSY;
 
 	dfprintk(VFS, "NFS: rename(%pd2 -> %pd2, ct=%d)\n",
@@ -1958,8 +1959,16 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (new_inode != NULL)
 		NFS_PROTO(new_inode)->return_delegation(new_inode);
 
-	error = NFS_PROTO(old_dir)->rename(old_dir, &old_dentry->d_name,
-					   new_dir, &new_dentry->d_name);
+	task = nfs_async_rename(old_dir, new_dir, old_dentry, new_dentry, NULL);
+	if (IS_ERR(task)) {
+		error = PTR_ERR(task);
+		goto out;
+	}
+
+	error = rpc_wait_for_completion_task(task);
+	if (error == 0)
+		error = task->tk_status;
+	rpc_put_task(task);
 	nfs_mark_for_revalidate(old_inode);
 out:
 	if (rehash)
-- 
1.8.5.3

