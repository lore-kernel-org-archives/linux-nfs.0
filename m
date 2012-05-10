Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23496 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760530Ab2EJTHv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 15:07:51 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 02/14] NFS: Create a single nfs_get_root()
Date: Thu, 10 May 2012 15:07:31 -0400
Message-Id: <1336676863-9698-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
References: <1336676863-9698-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch splits out the NFS v4 specific functionality of
nfs4_get_root() into its own rpc_op called by the generic client, and
leaves nfs4_proc_get_rootfh() as its own stand alone function.  This
also allows me to change nfs4_remote_mount(), nfs4_xdev_mount() and
nfs4_remote_referral_mount() to use the generic client's nfs_get_root()
function.  Later patches in this series will collapse these functions
into one common function, so using the same get_root() function
everywhere simplifies future changes.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/getroot.c  |   83 -----------------------------------------------------
 fs/nfs/nfs4proc.c |   28 +++++++++++++++++-
 fs/nfs/super.c    |    6 ++--
 3 files changed, 30 insertions(+), 87 deletions(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 8a0f33e..8abfb19 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -178,87 +178,4 @@ out:
 	return ret;
 }
 
-/*
- * get an NFS4 root dentry from the root filehandle
- */
-struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh,
-			     const char *devname)
-{
-	struct nfs_server *server = NFS_SB(sb);
-	struct nfs_fattr *fattr = NULL;
-	struct dentry *ret;
-	struct inode *inode;
-	void *name = kstrdup(devname, GFP_KERNEL);
-	int error;
-
-	dprintk("--> nfs4_get_root()\n");
-
-	if (!name)
-		return ERR_PTR(-ENOMEM);
-
-	/* get the info about the server and filesystem */
-	error = nfs4_server_capabilities(server, mntfh);
-	if (error < 0) {
-		dprintk("nfs_get_root: getcaps error = %d\n",
-			-error);
-		kfree(name);
-		return ERR_PTR(error);
-	}
-
-	fattr = nfs_alloc_fattr();
-	if (fattr == NULL) {
-		kfree(name);
-		return ERR_PTR(-ENOMEM);
-	}
-
-	/* get the actual root for this mount */
-	error = server->nfs_client->rpc_ops->getattr(server, mntfh, fattr);
-	if (error < 0) {
-		dprintk("nfs_get_root: getattr error = %d\n", -error);
-		ret = ERR_PTR(error);
-		goto out;
-	}
-
-	if (fattr->valid & NFS_ATTR_FATTR_FSID &&
-	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
-		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
-
-	inode = nfs_fhget(sb, mntfh, fattr);
-	if (IS_ERR(inode)) {
-		dprintk("nfs_get_root: get root inode failed\n");
-		ret = ERR_CAST(inode);
-		goto out;
-	}
-
-	error = nfs_superblock_set_dummy_root(sb, inode);
-	if (error != 0) {
-		ret = ERR_PTR(error);
-		goto out;
-	}
-
-	/* root dentries normally start off anonymous and get spliced in later
-	 * if the dentry tree reaches them; however if the dentry already
-	 * exists, we'll pick it up at this point and use it as the root
-	 */
-	ret = d_obtain_alias(inode);
-	if (IS_ERR(ret)) {
-		dprintk("nfs_get_root: get root dentry failed\n");
-		goto out;
-	}
-
-	security_d_instantiate(ret, inode);
-	spin_lock(&ret->d_lock);
-	if (IS_ROOT(ret) && !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
-		ret->d_fsdata = name;
-		name = NULL;
-	}
-	spin_unlock(&ret->d_lock);
-out:
-	if (name)
-		kfree(name);
-	nfs_free_fattr(fattr);
-	dprintk("<-- nfs4_get_root()\n");
-	return ret;
-}
-
 #endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 69212d2..e6ab15f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -80,6 +80,7 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
+static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -2363,6 +2364,31 @@ int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_map_errors(status);
 }
 
+static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
+			      struct nfs_fsinfo *info)
+{
+	int error;
+	struct nfs_fattr *fattr = info->fattr;
+
+	error = nfs4_server_capabilities(server, mntfh);
+	if (error < 0) {
+		dprintk("nfs4_get_root: getcaps error = %d\n", -error);
+		return error;
+	}
+
+	error = nfs4_proc_getattr(server, mntfh, fattr);
+	if (error < 0) {
+		dprintk("nfs4_get_root: getattr error = %d\n", -error);
+		return error;
+	}
+
+	if (fattr->valid & NFS_ATTR_FATTR_FSID &&
+	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
+		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
+
+	return error;
+}
+
 /*
  * Get locations and (maybe) other attributes of a referral.
  * Note that we'll actually follow the referral later when
@@ -6539,7 +6565,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.dir_inode_ops	= &nfs4_dir_inode_operations,
 	.file_inode_ops	= &nfs4_file_inode_operations,
 	.file_ops	= &nfs4_file_operations,
-	.getroot	= nfs4_proc_get_rootfh,
+	.getroot	= nfs4_proc_get_root,
 	.submount	= nfs4_submount,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4ac7fca..75b1717 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2727,7 +2727,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 		nfs_fscache_get_super_cookie(s, data->fscache_uniq, NULL);
 	}
 
-	mntroot = nfs4_get_root(s, mntfh, dev_name);
+	mntroot = nfs_get_root(s, mntfh, dev_name);
 	if (IS_ERR(mntroot)) {
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
@@ -2991,7 +2991,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 		nfs_fscache_get_super_cookie(s, NULL, data);
 	}
 
-	mntroot = nfs4_get_root(s, data->fh, dev_name);
+	mntroot = nfs_get_root(s, data->fh, dev_name);
 	if (IS_ERR(mntroot)) {
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
@@ -3082,7 +3082,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 		nfs_fscache_get_super_cookie(s, NULL, data);
 	}
 
-	mntroot = nfs4_get_root(s, mntfh, dev_name);
+	mntroot = nfs_get_root(s, mntfh, dev_name);
 	if (IS_ERR(mntroot)) {
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
-- 
1.7.10.1

