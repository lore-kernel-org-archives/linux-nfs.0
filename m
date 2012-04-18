Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181Ab2DRRqf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:46:35 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 3/6] NFS: Create a submount rpc_op
Date: Wed, 18 Apr 2012 13:46:22 -0400
Message-Id: <1334771185-9841-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
References: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This simplifies the code for v2 and v3 and gives v4 a chance to decide
on referrals without needing to modify the generic client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |   19 +++++-----
 fs/nfs/namespace.c      |   89 ++++++++++++++++++++---------------------------
 fs/nfs/nfs3proc.c       |    1 +
 fs/nfs/nfs4_fs.h        |    6 ++++
 fs/nfs/nfs4namespace.c  |   33 +++++++++++++++++-
 fs/nfs/nfs4proc.c       |    5 +--
 fs/nfs/proc.c           |    1 +
 include/linux/nfs_xdr.h |    2 ++
 8 files changed, 90 insertions(+), 66 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b499cd0..a7995b3 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -185,17 +185,6 @@ static inline void nfs_fs_proc_exit(void)
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
@@ -281,8 +270,16 @@ extern void nfs_sb_deactive(struct super_block *sb);
 extern char *nfs_path(char **p, struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
 extern struct vfsmount *nfs_d_automount(struct path *path);
+struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
+				 struct nfs_fattr *, struct rpc_clnt *);
+struct vfsmount *nfs_submount(struct nfs_server *, struct dentry *,
+			      struct nfs_fh *, struct nfs_fattr *);
+
 #ifdef CONFIG_NFS_V4
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
+int nfs_lookup_with_sec(struct nfs_server *, struct dentry *, struct dentry *,
+			struct nfs_fh *, struct nfs_fattr *);
+
 #endif
 
 /* getroot.c */
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 3e40460..5f401fa 100644
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
@@ -174,41 +169,32 @@ out:
 	return ret;
 }
 
-static int nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
-			       struct dentry *dentry, struct path *path,
-			       struct nfs_fh *fh, struct nfs_fattr *fattr,
-			       rpc_authflavor_t *flavor)
+int nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
+			struct dentry *dentry, struct nfs_fh *fh,
+			struct nfs_fattr *fattr)
 {
 	struct rpc_clnt *clone;
 	struct rpc_auth *auth;
+	rpc_authflavor_t flavor;
 	int err;
 
-	err = nfs_negotiate_security(parent, path->dentry, flavor);
+	err = nfs_negotiate_security(parent, dentry, &flavor);
 	if (err < 0)
 		goto out;
 	clone  = rpc_clone_client(server->client);
-	auth   = rpcauth_create(*flavor, clone);
+	auth   = rpcauth_create(flavor, clone);
 	if (!auth) {
 		err = -EIO;
 		goto out_shutdown;
 	}
 	err = server->nfs_client->rpc_ops->lookup(clone, parent->d_inode,
-						  &path->dentry->d_name,
+						  &dentry->d_name,
 						  fh, fattr);
 out_shutdown:
 	rpc_shutdown_client(clone);
 out:
 	return err;
 }
-#else /* CONFIG_NFS_V4 */
-static inline int nfs_lookup_with_sec(struct nfs_server *server,
-				      struct dentry *parent, struct dentry *dentry,
-				      struct path *path, struct nfs_fh *fh,
-				      struct nfs_fattr *fattr,
-				      rpc_authflavor_t *flavor)
-{
-	return -EPERM;
-}
 #endif /* CONFIG_NFS_V4 */
 
 /*
@@ -227,11 +213,8 @@ struct vfsmount *nfs_d_automount(struct path *path)
 {
 	struct vfsmount *mnt;
 	struct nfs_server *server = NFS_SERVER(path->dentry->d_inode);
-	struct dentry *parent;
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
-	int err;
-	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
 
 	dprintk("--> nfs_d_automount()\n");
 
@@ -246,24 +229,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 		goto out;
 
 	dprintk("%s: enter\n", __func__);
-
-	/* Look it up again to get its attributes */
-	parent = dget_parent(path->dentry);
-	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
-						  &path->dentry->d_name,
-						  fh, fattr);
-	if (err == -EPERM && NFS_PROTO(parent->d_inode)->secinfo != NULL)
-		err = nfs_lookup_with_sec(server, parent, path->dentry, path, fh, fattr, &flavor);
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
 
@@ -336,14 +302,13 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
  * @authflavor - security flavor to use when performing the mount
  *
  */
-static struct vfsmount *nfs_do_submount(struct dentry *dentry,
-					struct nfs_fh *fh,
-					struct nfs_fattr *fattr,
-					rpc_authflavor_t authflavor)
+struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
+				 struct nfs_fattr *fattr, struct rpc_clnt *client)
 {
 	struct nfs_clone_mount mountdata = {
 		.sb = dentry->d_sb,
 		.dentry = dentry,
+		.client = client,
 		.fh = fh,
 		.fattr = fattr,
 	};
@@ -363,13 +328,7 @@ static struct vfsmount *nfs_do_submount(struct dentry *dentry,
 	if (IS_ERR(devname))
 		goto free_page;
 
-	mountdata.client = rpc_clone_client(NFS_SB(dentry->d_sb)->client);
-	if (IS_ERR(mountdata.client))
-		goto free_page;
-
 	mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
-	if (IS_ERR(mnt))
-		rpc_shutdown_client(mountdata.client);
 free_page:
 	free_page((unsigned long)page);
 out:
@@ -378,3 +337,29 @@ out:
 	dprintk("<-- nfs_do_submount() = %p\n", mnt);
 	return mnt;
 }
+
+struct vfsmount *nfs_submount(struct nfs_server *server, struct dentry *dentry,
+			      struct nfs_fh *fh, struct nfs_fattr *fattr)
+{
+	int err;
+	struct dentry *parent = dget_parent(dentry);
+	struct rpc_clnt *client;
+	struct vfsmount *mnt;
+
+	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
+						  &dentry->d_name, fh, fattr);
+	dput(parent);
+
+	if (err != 0)
+		return ERR_PTR(err);
+
+	client = rpc_clone_client(server->client);
+	if (IS_ERR(client))
+		return ERR_CAST(client);
+
+	mnt = nfs_do_submount(dentry, fh, fattr, client);
+	if (IS_ERR(mnt))
+		rpc_shutdown_client(client);
+
+	return mnt;
+}
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 5242eae..0ac098a 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -911,5 +911,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.lock		= nfs3_proc_lock,
 	.clear_acl_cache = nfs3_forget_cached_acls,
 	.close_context	= nfs_close_context,
+	.submount	= nfs_submount,
 	.init_client	= nfs_init_client,
 };
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 41a89d0..e761268 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -204,6 +204,10 @@ struct nfs4_state_maintenance_ops {
 extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
+/* nfs4namespace.c */
+struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
+			       struct nfs_fh *, struct nfs_fattr *);
+
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
@@ -214,6 +218,8 @@ extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, boo
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern int nfs4_proc_lookup(struct rpc_clnt *, struct inode *, struct qstr *,
+			    struct nfs_fh *, struct nfs_fattr *);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index be5268d..a12b747 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -224,7 +224,7 @@ out:
  * @dentry - dentry of referral
  *
  */
-struct vfsmount *nfs_do_refmount(struct dentry *dentry)
+static struct vfsmount *nfs_do_refmount(struct dentry *dentry)
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
 	struct dentry *parent;
@@ -266,3 +266,34 @@ out:
 	dprintk("%s: done\n", __func__);
 	return mnt;
 }
+
+struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
+			       struct nfs_fh *fh, struct nfs_fattr *fattr)
+{
+	int err;
+	struct dentry *parent = dget_parent(dentry);
+	struct rpc_clnt *client;
+	struct vfsmount *ret;
+
+	/* Look it up again to get its attributes */
+	err = nfs4_proc_lookup(server->client, parent->d_inode, &dentry->d_name, fh, fattr);
+	if (err == -EPERM)
+		err = nfs_lookup_with_sec(server, parent, dentry, fh, fattr);
+	dput(parent);
+
+	if (err != 0)
+		return ERR_PTR(err);
+
+	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
+		return nfs_do_refmount(dentry);
+
+	client = rpc_clone_client(server->client);
+	if (IS_ERR(client))
+		return ERR_CAST(client);
+
+	ret = nfs_do_submount(dentry, fh, fattr, client);
+	if (IS_ERR(ret))
+		rpc_shutdown_client(client);
+
+	return ret;
+}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 826c3d5..9e21e25 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2530,8 +2530,8 @@ void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr, struct nfs_fh *fh)
 	fattr->nlink = 2;
 }
 
-static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
-			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
+		     struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs4_exception exception = { };
 	int err;
@@ -6504,6 +6504,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.clear_acl_cache = nfs4_zap_acl_attr,
 	.close_context  = nfs4_close_context,
 	.open_context	= nfs4_atomic_open,
+	.submount	= nfs4_submount,
 	.init_client	= nfs4_init_client,
 	.secinfo	= nfs4_proc_secinfo,
 };
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b63b6f4..da18f86 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -767,5 +767,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.lock		= nfs_proc_lock,
 	.lock_check_bounds = nfs_lock_check_bounds,
 	.close_context	= nfs_close_context,
+	.submount	= nfs_submount,
 	.init_client	= nfs_init_client,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bfd0d1b..3c94c80 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1282,6 +1282,8 @@ struct nfs_rpc_ops {
 				struct nfs_open_context *ctx,
 				int open_flags,
 				struct iattr *iattr);
+	struct vfsmount *(*submount)(struct nfs_server *, struct dentry *,
+				     struct nfs_fh *, struct nfs_fattr *);
 	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t, int);
 	int	(*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
-- 
1.7.10

