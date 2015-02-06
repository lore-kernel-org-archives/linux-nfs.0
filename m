Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:47594 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbbBFEpK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 23:45:10 -0500
Received: by mail-ig0-f182.google.com with SMTP id h15so5416610igd.3
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 20:45:09 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v3 1/5] NFSv4: Ensure we reference the inode for return-on-close in delegreturn
Date: Thu,  5 Feb 2015 23:45:03 -0500
Message-Id: <1423197907-75541-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we have to do a return-on-close in the delegreturn code, then
we must ensure that the inode and super block remain referenced.

Cc: Peng Tao <tao.peng@primarydata.com>
Cc: stable@vger.kernel.org # 3.17.x
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/internal.h | 22 +++++++++++++++++++++-
 fs/nfs/nfs4proc.c | 14 +++++++++-----
 fs/nfs/super.c    |  9 ++++++---
 3 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index a98cf2006179..21469e6e3834 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -391,7 +391,7 @@ extern struct rpc_stat nfs_rpcstat;
 
 extern int __init register_nfs_fs(void);
 extern void __exit unregister_nfs_fs(void);
-extern void nfs_sb_active(struct super_block *sb);
+extern bool nfs_sb_active(struct super_block *sb);
 extern void nfs_sb_deactive(struct super_block *sb);
 
 /* namespace.c */
@@ -514,6 +514,26 @@ extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
 
+static inline struct inode *nfs_igrab_and_active(struct inode *inode)
+{
+	inode = igrab(inode);
+	if (inode != NULL && !nfs_sb_active(inode->i_sb)) {
+		iput(inode);
+		inode = NULL;
+	}
+	return inode;
+}
+
+static inline void nfs_iput_and_deactive(struct inode *inode)
+{
+	if (inode != NULL) {
+		struct super_block *sb = inode->i_sb;
+
+		iput(inode);
+		nfs_sb_deactive(sb);
+	}
+}
+
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cd4295d84d54..dd892a4e7eb3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5175,9 +5175,13 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 static void nfs4_delegreturn_release(void *calldata)
 {
 	struct nfs4_delegreturndata *data = calldata;
+	struct inode *inode = data->inode;
 
-	if (data->roc)
-		pnfs_roc_release(data->inode);
+	if (inode) {
+		if (data->roc)
+			pnfs_roc_release(inode);
+		nfs_iput_and_deactive(inode);
+	}
 	kfree(calldata);
 }
 
@@ -5234,9 +5238,9 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
-	data->inode = inode;
-	data->roc = list_empty(&NFS_I(inode)->open_files) ?
-		    pnfs_roc(inode) : false;
+	data->inode = nfs_igrab_and_active(inode);
+	if (data->inode)
+		data->roc = nfs4_roc(inode);
 
 	task_setup_data.callback_data = data;
 	msg.rpc_argp = &data->args;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 31a11b0e885d..368d9395d2e7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -405,12 +405,15 @@ void __exit unregister_nfs_fs(void)
 	unregister_filesystem(&nfs_fs_type);
 }
 
-void nfs_sb_active(struct super_block *sb)
+bool nfs_sb_active(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
-	if (atomic_inc_return(&server->active) == 1)
-		atomic_inc(&sb->s_active);
+	if (!atomic_inc_not_zero(&sb->s_active))
+		return false;
+	if (atomic_inc_return(&server->active) != 1)
+		atomic_dec(&sb->s_active);
+	return true;
 }
 EXPORT_SYMBOL_GPL(nfs_sb_active);
 
-- 
2.1.0

