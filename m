Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26064 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753141Ab2DZU4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:56:33 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 8/9] NFS: Create a submount rpc_op
Date: Thu, 26 Apr 2012 16:56:11 -0400
Message-Id: <1335473772-4401-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>
References: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This simplifies the code for v2 and v3 and gives v4 a chance to decide
on referrals without needing to modify the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |   15 +++-------
 fs/nfs/namespace.c      |   75 +++++++++++++----------------------------------
 fs/nfs/nfs3proc.c       |    1 +
 fs/nfs/nfs4_fs.h        |    2 ++
 fs/nfs/nfs4namespace.c  |   24 ++++++++++++++-
 fs/nfs/nfs4proc.c       |    1 +
 fs/nfs/proc.c           |    1 +
 include/linux/nfs_xdr.h |    2 ++
 8 files changed, 54 insertions(+), 67 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index a7e2497..f4e7066 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -185,17 +185,6 @@ static inline void nfs_fs_proc_exit(void)
 }
 #endif
 
-/* nfs4namespace.c */
-#ifdef CONFIG_NFS_V4
-extern struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *dentry);
-#else
-static inline
-struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *dentry)
-{
-	return ERR_PTR(-ENOENT);
-}
-#endif
-
 /* callback_xdr.c */
 extern struct svc_version nfs4_callback_version1;
 extern struct svc_version nfs4_callback_version4;
@@ -280,6 +269,10 @@ extern void nfs_sb_deactive(struct super_block *sb);
 extern char *nfs_path(char **p, struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
 extern struct vfsmount *nfs_d_automount(struct path *path);
+struct vfsmount *nfs_submount(struct nfs_server *, struct dentry *,
+			      struct nfs_fh *, struct nfs_fattr *);
+struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
+				 struct nfs_fattr *, rpc_authflavor_t);
 
 /* getroot.c */
 extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 2a9591b..e36fd8a 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -26,11 +26,6 @@ static LIST_HEAD(nfs_automount_list);
 static DECLARE_DELAYED_WORK(nfs_automount_task, nfs_expire_automounts);
 int nfs_mountpoint_expiry_timeout = 500 * HZ;
 
-static struct vfsmount *nfs_do_submount(struct dentry *dentry,
-					struct nfs_fh *fh,
-					struct nfs_fattr *fattr,
-					rpc_authflavor_t authflavor);
-
 /*
  * nfs_path - reconstruct the path given an arbitrary dentry
  * @base - used to return pointer to the end of devname part of path
@@ -118,35 +113,6 @@ Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
 
-#ifdef CONFIG_NFS_V4
-static struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
-					      struct qstr *name,
-					      struct nfs_fh *fh,
-					      struct nfs_fattr *fattr)
-{
-	int err;
-
-	if (NFS_PROTO(dir)->version == 4)
-		return nfs4_proc_lookup_mountpoint(dir, name, fh, fattr);
-
-	err = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, name, fh, fattr);
-	if (err)
-		return ERR_PTR(err);
-	return rpc_clone_client(NFS_SERVER(dir)->client);
-}
-#else /* CONFIG_NFS_V4 */
-static inline struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
-						     struct qstr *name,
-						     struct nfs_fh *fh,
-						     struct nfs_fattr *fattr)
-{
-	int err = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, name, fh, fattr);
-	if (err)
-		return ERR_PTR(err);
-	return rpc_clone_client(NFS_SERVER(dir)->client);
-}
-#endif /* CONFIG_NFS_V4 */
-
 /*
  * nfs_d_automount - Handle crossing a mountpoint on the server
  * @path - The mountpoint
@@ -162,10 +128,9 @@ static inline struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
 struct vfsmount *nfs_d_automount(struct path *path)
 {
 	struct vfsmount *mnt;
-	struct dentry *parent;
+	struct nfs_server *server = NFS_SERVER(path->dentry->d_inode);
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
-	struct rpc_clnt *client;
 
 	dprintk("--> nfs_d_automount()\n");
 
@@ -181,21 +146,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 
 	dprintk("%s: enter\n", __func__);
 
-	/* Look it up again to get its attributes */
-	parent = dget_parent(path->dentry);
-	client = nfs_lookup_mountpoint(parent->d_inode, &path->dentry->d_name, fh, fattr);
-	dput(parent);
-	if (IS_ERR(client)) {
-		mnt = ERR_CAST(client);
-		goto out;
-	}
-
-	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
-		mnt = nfs_do_refmount(client, path->dentry);
-	else
-		mnt = nfs_do_submount(path->dentry, fh, fattr, client->cl_auth->au_flavor);
-	rpc_shutdown_client(client);
-
+	mnt = server->nfs_client->rpc_ops->submount(server, path->dentry, fh, fattr);
 	if (IS_ERR(mnt))
 		goto out;
 
@@ -268,10 +219,8 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
  * @authflavor - security flavor to use when performing the mount
  *
  */
-static struct vfsmount *nfs_do_submount(struct dentry *dentry,
-					struct nfs_fh *fh,
-					struct nfs_fattr *fattr,
-					rpc_authflavor_t authflavor)
+struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
+				 struct nfs_fattr *fattr, rpc_authflavor_t authflavor)
 {
 	struct nfs_clone_mount mountdata = {
 		.sb = dentry->d_sb,
@@ -304,3 +253,19 @@ out:
 	dprintk("<-- nfs_do_submount() = %p\n", mnt);
 	return mnt;
 }
+
+struct vfsmount *nfs_submount(struct nfs_server *server, struct dentry *dentry,
+			      struct nfs_fh *fh, struct nfs_fattr *fattr)
+{
+	int err;
+	struct dentry *parent = dget_parent(dentry);
+
+	/* Look it up again to get its attributes */
+	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
+						  &dentry->d_name, fh, fattr);
+	dput(parent);
+	if (err != 0)
+		return ERR_PTR(err);
+
+	return nfs_do_submount(dentry, fh, fattr, server->client->cl_auth->au_flavor);
+}
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 5242eae..d39d1d7 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -876,6 +876,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.file_inode_ops	= &nfs3_file_inode_operations,
 	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs3_proc_get_root,
+	.submount	= nfs_submount,
 	.getattr	= nfs3_proc_getattr,
 	.setattr	= nfs3_proc_setattr,
 	.lookup		= nfs3_proc_lookup,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 53a487e..97365b0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -208,6 +208,8 @@ extern const struct inode_operations nfs4_dir_inode_operations;
 /* nfs4namespace.c */
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
+struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
+			       struct nfs_fh *, struct nfs_fattr *);
 
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 56427f1..01f56bb 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -305,7 +305,7 @@ out:
  * @dentry - dentry of referral
  *
  */
-struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *dentry)
+static struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *dentry)
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
 	struct dentry *parent;
@@ -346,3 +346,25 @@ out:
 	dprintk("%s: done\n", __func__);
 	return mnt;
 }
+
+struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
+			       struct nfs_fh *fh, struct nfs_fattr *fattr)
+{
+	struct dentry *parent = dget_parent(dentry);
+	struct rpc_clnt *client;
+	struct vfsmount *mnt;
+
+	/* Look it up again to get its attributes and sec flavor */
+	client = nfs4_proc_lookup_mountpoint(parent->d_inode, &dentry->d_name, fh, fattr);
+	dput(parent);
+	if (IS_ERR(client))
+		return ERR_CAST(client);
+
+	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
+		mnt = nfs_do_refmount(client, dentry);
+	else
+		mnt = nfs_do_submount(dentry, fh, fattr, client->cl_auth->au_flavor);
+
+	rpc_shutdown_client(client);
+	return mnt;
+}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ecbbf36..279bbd9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6557,6 +6557,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.file_inode_ops	= &nfs4_file_inode_operations,
 	.file_ops	= &nfs4_file_operations,
 	.getroot	= nfs4_proc_get_root,
+	.submount	= nfs4_submount,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
 	.lookup		= nfs4_proc_lookup,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b63b6f4..8dfe960 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -733,6 +733,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.file_inode_ops	= &nfs_file_inode_operations,
 	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs_proc_get_root,
+	.submount	= nfs_submount,
 	.getattr	= nfs_proc_getattr,
 	.setattr	= nfs_proc_setattr,
 	.lookup		= nfs_proc_lookup,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6cba0a1..ada3acd 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1234,6 +1234,8 @@ struct nfs_rpc_ops {
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
+	struct vfsmount *(*submount) (struct nfs_server *, struct dentry *,
+				      struct nfs_fh *, struct nfs_fattr *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
-- 
1.7.10

