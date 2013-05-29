Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4891 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966427Ab3E2UFc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 May 2013 16:05:32 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4: Close another NFSv4 recovery race
Date: Wed, 29 May 2013 16:05:25 -0400
Message-Id: <1369857925-42068-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369857925-42068-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1369857925-42068-1-git-send-email-Trond.Myklebust@netapp.com>
 <1369857925-42068-2-git-send-email-Trond.Myklebust@netapp.com>
 <1369857925-42068-3-git-send-email-Trond.Myklebust@netapp.com>
 <1369857925-42068-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

State recovery currently relies on being able to find a valid
nfs_open_context in the inode->open_files list.
We therefore need to put the nfs_open_context on the list while
we're still protected by the sp->so_reclaim_seqcount in order
to avoid reboot races.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c         | 16 ++++++++++++----
 fs/nfs/nfs4proc.c      |  7 +++++--
 include/linux/nfs_fs.h |  1 +
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c1c7a9d..c121982 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -713,16 +713,23 @@ EXPORT_SYMBOL_GPL(put_nfs_open_context);
  * Ensure that mmap has a recent RPC credential for use when writing out
  * shared pages
  */
-void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx)
+void nfs_inode_attach_open_context(struct nfs_open_context *ctx)
 {
-	struct inode *inode = file_inode(filp);
+	struct inode *inode = ctx->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	filp->private_data = get_nfs_open_context(ctx);
 	spin_lock(&inode->i_lock);
 	list_add(&ctx->list, &nfsi->open_files);
 	spin_unlock(&inode->i_lock);
 }
+EXPORT_SYMBOL_GPL(nfs_inode_attach_open_context);
+
+void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx)
+{
+	filp->private_data = get_nfs_open_context(ctx);
+	if (list_empty(&ctx->list))
+		nfs_inode_attach_open_context(ctx);
+}
 EXPORT_SYMBOL_GPL(nfs_file_set_open_context);
 
 /*
@@ -748,10 +755,11 @@ struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_c
 
 static void nfs_file_clear_open_context(struct file *filp)
 {
-	struct inode *inode = file_inode(filp);
 	struct nfs_open_context *ctx = nfs_file_open_context(filp);
 
 	if (ctx) {
+		struct inode *inode = ctx->dentry->d_inode;
+
 		filp->private_data = NULL;
 		spin_lock(&inode->i_lock);
 		list_move_tail(&ctx->list, &NFS_I(inode)->open_files);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3225149..a2bf0e8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2000,8 +2000,11 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 		goto out;
 
 	ctx->state = state;
-	if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
-		nfs4_schedule_stateid_recovery(server, state);
+	if (dentry->d_inode == state->inode) {
+		nfs_inode_attach_open_context(ctx);
+		if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
+			nfs4_schedule_stateid_recovery(server, state);
+	}
 out:
 	return ret;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index fc01d5c..1384ed9 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -356,6 +356,7 @@ extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ct
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
 extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode);
+extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
 extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
 extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
-- 
1.8.1.4

