From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/24] NFSv4: Reduce stack footprint of nfs4_get_root()
Date: Fri, 16 Apr 2010 16:31:06 -0400
Message-ID: <1271449882-8580-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932416Ab0DPUb2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:28 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMl3026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:27 -0700 (PDT)
In-Reply-To: <1271449882-8580-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/getroot.c |   76 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 46 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index ada369a..7428f7d 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -78,46 +78,52 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 {
 	struct nfs_server *server = NFS_SB(sb);
 	struct nfs_fsinfo fsinfo;
-	struct nfs_fattr fattr;
-	struct dentry *mntroot;
+	struct dentry *ret;
 	struct inode *inode;
 	int error;
 
 	/* get the actual root for this mount */
-	fsinfo.fattr = &fattr;
+	fsinfo.fattr = nfs_alloc_fattr();
+	if (fsinfo.fattr == NULL)
+		return ERR_PTR(-ENOMEM);
 
 	error = server->nfs_client->rpc_ops->getroot(server, mntfh, &fsinfo);
 	if (error < 0) {
 		dprintk("nfs_get_root: getattr error = %d\n", -error);
-		return ERR_PTR(error);
+		ret = ERR_PTR(error);
+		goto out;
 	}
 
 	inode = nfs_fhget(sb, mntfh, fsinfo.fattr);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
-		return ERR_CAST(inode);
+		ret = ERR_CAST(inode);
+		goto out;
 	}
 
 	error = nfs_superblock_set_dummy_root(sb, inode);
-	if (error != 0)
-		return ERR_PTR(error);
+	if (error != 0) {
+		ret = ERR_PTR(error);
+		goto out;
+	}
 
 	/* root dentries normally start off anonymous and get spliced in later
 	 * if the dentry tree reaches them; however if the dentry already
 	 * exists, we'll pick it up at this point and use it as the root
 	 */
-	mntroot = d_obtain_alias(inode);
-	if (IS_ERR(mntroot)) {
+	ret = d_obtain_alias(inode);
+	if (IS_ERR(ret)) {
 		dprintk("nfs_get_root: get root dentry failed\n");
-		return mntroot;
+		goto out;
 	}
 
-	security_d_instantiate(mntroot, inode);
+	security_d_instantiate(ret, inode);
 
-	if (!mntroot->d_op)
-		mntroot->d_op = server->nfs_client->rpc_ops->dentry_ops;
-
-	return mntroot;
+	if (ret->d_op == NULL)
+		ret->d_op = server->nfs_client->rpc_ops->dentry_ops;
+out:
+	nfs_free_fattr(fsinfo.fattr);
+	return ret;
 }
 
 #ifdef CONFIG_NFS_V4
@@ -168,8 +174,8 @@ out:
 struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 {
 	struct nfs_server *server = NFS_SB(sb);
-	struct nfs_fattr fattr;
-	struct dentry *mntroot;
+	struct nfs_fattr *fattr = NULL;
+	struct dentry *ret;
 	struct inode *inode;
 	int error;
 
@@ -183,40 +189,50 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 		return ERR_PTR(error);
 	}
 
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		return ERR_PTR(-ENOMEM);;
+
 	/* get the actual root for this mount */
-	error = server->nfs_client->rpc_ops->getattr(server, mntfh, &fattr);
+	error = server->nfs_client->rpc_ops->getattr(server, mntfh, fattr);
 	if (error < 0) {
 		dprintk("nfs_get_root: getattr error = %d\n", -error);
-		return ERR_PTR(error);
+		ret = ERR_PTR(error);
+		goto out;
 	}
 
-	inode = nfs_fhget(sb, mntfh, &fattr);
+	inode = nfs_fhget(sb, mntfh, fattr);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
-		return ERR_CAST(inode);
+		ret = ERR_CAST(inode);
+		goto out;
 	}
 
 	error = nfs_superblock_set_dummy_root(sb, inode);
-	if (error != 0)
-		return ERR_PTR(error);
+	if (error != 0) {
+		ret = ERR_PTR(error);
+		goto out;
+	}
 
 	/* root dentries normally start off anonymous and get spliced in later
 	 * if the dentry tree reaches them; however if the dentry already
 	 * exists, we'll pick it up at this point and use it as the root
 	 */
-	mntroot = d_obtain_alias(inode);
-	if (IS_ERR(mntroot)) {
+	ret = d_obtain_alias(inode);
+	if (IS_ERR(ret)) {
 		dprintk("nfs_get_root: get root dentry failed\n");
-		return mntroot;
+		goto out;
 	}
 
-	security_d_instantiate(mntroot, inode);
+	security_d_instantiate(ret, inode);
 
-	if (!mntroot->d_op)
-		mntroot->d_op = server->nfs_client->rpc_ops->dentry_ops;
+	if (ret->d_op == NULL)
+		ret->d_op = server->nfs_client->rpc_ops->dentry_ops;
 
+out:
+	nfs_free_fattr(fattr);
 	dprintk("<-- nfs4_get_root()\n");
-	return mntroot;
+	return ret;
 }
 
 #endif /* CONFIG_NFS_V4 */
-- 
1.6.6.1

