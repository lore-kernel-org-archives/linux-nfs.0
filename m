Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:45314 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932556AbaCQLHI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2014 07:07:08 -0400
Received: by mail-qa0-f52.google.com with SMTP id m5so5152721qaj.11
        for <linux-nfs@vger.kernel.org>; Mon, 17 Mar 2014 04:07:08 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/5] nfs: abstract out code needed to complete a sillyrename
Date: Mon, 17 Mar 2014 07:06:54 -0400
Message-Id: <1395054418-14504-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
References: <1395054418-14504-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The async rename code is currently "polluted" with some parts that are
really just for sillyrenames. Add a new "complete" operation vector to
the nfs_renamedata to separate out the stuff that just needs to be done
for a sillyrename.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/unlink.c         | 22 ++++++++++++++++++----
 include/linux/nfs_xdr.h |  1 +
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 11d78944de79..3e6798c9ba1f 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -353,8 +353,8 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
 		return;
 	}
 
-	if (task->tk_status != 0)
-		nfs_cancel_async_unlink(old_dentry);
+	if (data->complete)
+		data->complete(task, data);
 }
 
 /**
@@ -401,7 +401,8 @@ static const struct rpc_call_ops nfs_rename_ops = {
  */
 static struct rpc_task *
 nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
-		 struct dentry *old_dentry, struct dentry *new_dentry)
+		 struct dentry *old_dentry, struct dentry *new_dentry,
+		 void (*complete)(struct rpc_task *, struct nfs_renamedata *))
 {
 	struct nfs_renamedata *data;
 	struct rpc_message msg = { };
@@ -438,6 +439,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 	data->new_dentry = dget(new_dentry);
 	nfs_fattr_init(&data->old_fattr);
 	nfs_fattr_init(&data->new_fattr);
+	data->complete = complete;
 
 	/* set up nfs_renameargs */
 	data->args.old_dir = NFS_FH(old_dir);
@@ -456,6 +458,17 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 	return rpc_run_task(&task_setup_data);
 }
 
+/*
+ * Perform tasks needed when a sillyrename is done such as cancelling the
+ * queued async unlink if it failed.
+ */
+static void
+nfs_complete_sillyrename(struct rpc_task *task, struct nfs_renamedata *data)
+{
+	if (task->tk_status != 0)
+		nfs_cancel_async_unlink(data->old_dentry);
+}
+
 #define SILLYNAME_PREFIX ".nfs"
 #define SILLYNAME_PREFIX_LEN ((unsigned)sizeof(SILLYNAME_PREFIX) - 1)
 #define SILLYNAME_FILEID_LEN ((unsigned)sizeof(u64) << 1)
@@ -548,7 +561,8 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	}
 
 	/* run the rename task, undo unlink if it fails */
-	task = nfs_async_rename(dir, dir, dentry, sdentry);
+	task = nfs_async_rename(dir, dir, dentry, sdentry,
+					nfs_complete_sillyrename);
 	if (IS_ERR(task)) {
 		error = -EBUSY;
 		nfs_cancel_async_unlink(dentry);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5624e4e2763c..440d7b42525a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1402,6 +1402,7 @@ struct nfs_renamedata {
 	struct inode		*new_dir;
 	struct dentry		*new_dentry;
 	struct nfs_fattr	new_fattr;
+	void (*complete)(struct rpc_task *, struct nfs_renamedata *);
 };
 
 struct nfs_access_entry;
-- 
1.8.5.3

