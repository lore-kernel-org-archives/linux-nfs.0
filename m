From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/24] NFS: Reduce the stack footprint of nfs_follow_mountpoint()
Date: Fri, 16 Apr 2010 16:31:01 -0400
Message-ID: <1271449882-8580-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3335 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932414Ab0DPUbZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:25 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMkw026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:24 -0700 (PDT)
In-Reply-To: <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/namespace.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 7888cf3..db6aa36 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -105,8 +105,8 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 	struct vfsmount *mnt;
 	struct nfs_server *server = NFS_SERVER(dentry->d_inode);
 	struct dentry *parent;
-	struct nfs_fh fh;
-	struct nfs_fattr fattr;
+	struct nfs_fh *fh = NULL;
+	struct nfs_fattr *fattr = NULL;
 	int err;
 
 	dprintk("--> nfs_follow_mountpoint()\n");
@@ -115,6 +115,12 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 	if (IS_ROOT(dentry))
 		goto out_err;
 
+	err = -ENOMEM;
+	fh = nfs_alloc_fhandle();
+	fattr = nfs_alloc_fattr();
+	if (fh == NULL || fattr == NULL)
+		goto out_err;
+
 	dprintk("%s: enter\n", __func__);
 	dput(nd->path.dentry);
 	nd->path.dentry = dget(dentry);
@@ -123,16 +129,16 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 	parent = dget_parent(nd->path.dentry);
 	err = server->nfs_client->rpc_ops->lookup(parent->d_inode,
 						  &nd->path.dentry->d_name,
-						  &fh, &fattr);
+						  fh, fattr);
 	dput(parent);
 	if (err != 0)
 		goto out_err;
 
-	if (fattr.valid & NFS_ATTR_FATTR_V4_REFERRAL)
+	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
 		mnt = nfs_do_refmount(nd->path.mnt, nd->path.dentry);
 	else
-		mnt = nfs_do_submount(nd->path.mnt, nd->path.dentry, &fh,
-				      &fattr);
+		mnt = nfs_do_submount(nd->path.mnt, nd->path.dentry, fh,
+				      fattr);
 	err = PTR_ERR(mnt);
 	if (IS_ERR(mnt))
 		goto out_err;
@@ -151,6 +157,8 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 	nd->path.dentry = dget(mnt->mnt_root);
 	schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
 out:
+	nfs_free_fattr(fattr);
+	nfs_free_fhandle(fh);
 	dprintk("%s: done, returned %d\n", __func__, err);
 
 	dprintk("<-- nfs_follow_mountpoint() = %d\n", err);
-- 
1.6.6.1

