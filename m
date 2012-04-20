Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4512 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757468Ab2DTTIp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 15:08:45 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 5/8] NFS: Create a submount rpc_op
Date: Fri, 20 Apr 2012 15:08:35 -0400
Message-Id: <1334948918-4706-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1334948918-4706-1-git-send-email-bjschuma@netapp.com>
References: <1334948918-4706-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This simplifies the code for v2 and v3 and gives v4 a chance to decide
on referrals without needing to modify the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |   16 +++++-----------
 fs/nfs/namespace.c      |   46 +++++++++++++++++++---------------------------
 fs/nfs/nfs3proc.c       |    1 +
 fs/nfs/nfs4_fs.h        |    2 ++
 fs/nfs/nfs4namespace.c  |   20 +++++++++++++++++++-
 fs/nfs/nfs4proc.c       |    1 +
 fs/nfs/proc.c           |    1 +
 include/linux/nfs_xdr.h |    2 ++
 8 files changed, 50 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 45966d9..1be8d3d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -184,17 +184,6 @@ static inline void nfs_fs_proc_exit(void)
 }
 #endif
 
-/* nfs4namespace.c */
-#ifdef CONFIG_NFS_V4
-extern struct vfsmount *nfs_do_refmount(struct dentry *dentry);
-#else
-static inline
-struct vfsmount *nfs_do_refmount(struct dentry *dentry)
-{
-	return ERR_PTR(-ENOENT);
-}
-#endif
-
 /* callback_xdr.c */
 extern struct svc_version nfs4_callback_version1;
 extern struct svc_version nfs4_callback_version4;
@@ -279,6 +268,11 @@ extern void nfs_sb_deactive(struct super_block *sb);
 extern char *nfs_path(char **p, struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
 extern struct vfsmount *nfs_d_automount(struct path *path);
+struct vfsmount *nfs_submount(struct nfs_server *, struct dentry *,
+			      struct nfs_fh *, struct nfs_fattr *);
+struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
+				 struct nfs_fattr *, rpc_authflavor_t);
+
 #ifdef CONFIG_NFS_V4
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 #endif
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 9accf45..e36fd8a 100644
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
@@ -134,11 +129,8 @@ struct vfsmount *nfs_d_automount(struct path *path)
 {
 	struct vfsmount *mnt;
 	struct nfs_server *server = NFS_SERVER(path->dentry->d_inode);
-	struct dentry *parent;
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
-	int err;
-	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
 
 	dprintk("--> nfs_d_automount()\n");
 
@@ -154,21 +146,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 
 	dprintk("%s: enter\n", __func__);
 
-	/* Look it up again to get its attributes */
-	parent = dget_parent(path->dentry);
-	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
-						  &path->dentry->d_name,
-						  fh, fattr);
-	dput(parent);
-	if (err != 0) {
-		mnt = ERR_PTR(err);
-		goto out;
-	}
-
-	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
-		mnt = nfs_do_refmount(path->dentry);
-	else
-		mnt = nfs_do_submount(path->dentry, fh, fattr, flavor);
+	mnt = server->nfs_client->rpc_ops->submount(server, path->dentry, fh, fattr);
 	if (IS_ERR(mnt))
 		goto out;
 
@@ -241,10 +219,8 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
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
@@ -277,3 +253,19 @@ out:
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
index 7df4520..640a499 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -207,6 +207,8 @@ extern const struct inode_operations nfs4_dir_inode_operations;
 /* nfs4namespace.c */
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
 int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
+struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
+			       struct nfs_fh *, struct nfs_fattr *);
 
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index e01cd03..b6baa6e 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -305,7 +305,7 @@ out:
  * @dentry - dentry of referral
  *
  */
-struct vfsmount *nfs_do_refmount(struct dentry *dentry)
+static struct vfsmount *nfs_do_refmount(struct dentry *dentry)
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
 	struct dentry *parent;
@@ -346,3 +346,21 @@ out:
 	dprintk("%s: done\n", __func__);
 	return mnt;
 }
+
+struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
+			       struct nfs_fh *fh, struct nfs_fattr *fattr)
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
+	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
+		return nfs_do_refmount(dentry);
+	return nfs_do_submount(dentry, fh, fattr, server->client->cl_auth->au_flavor);
+}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9b70b13..3da1d7a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6537,6 +6537,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
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
index f03c832..fbacdc8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1229,6 +1229,8 @@ struct nfs_rpc_ops {
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
+	struct vfsmount *(*submount) (struct nfs_server *, struct dentry *,
+				      struct nfs_fh *, struct nfs_fattr *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
-- 
1.7.10

