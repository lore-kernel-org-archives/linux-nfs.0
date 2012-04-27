Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760638Ab2D0R15 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 13:27:57 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v5 4/9] NFS: Fix following referral mount points with different security
Date: Fri, 27 Apr 2012 13:27:41 -0400
Message-Id: <1335547666-28315-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335547666-28315-1-git-send-email-bjschuma@netapp.com>
References: <1335547666-28315-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I create a new proc_lookup_mountpoint() to use when submounting an NFS
v4 share.  This function returns an rpc_clnt to use for performing an
fs_locations() call on a referral's mountpoint.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h      |    4 ++--
 fs/nfs/namespace.c     |   44 ++++++++++++++++++++++++++++++++++----------
 fs/nfs/nfs4_fs.h       |    6 ++++--
 fs/nfs/nfs4namespace.c |    4 ++--
 fs/nfs/nfs4proc.c      |   40 ++++++++++++++++++++++++++++++----------
 5 files changed, 72 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 45966d9..49c09b4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -186,10 +186,10 @@ static inline void nfs_fs_proc_exit(void)
 
 /* nfs4namespace.c */
 #ifdef CONFIG_NFS_V4
-extern struct vfsmount *nfs_do_refmount(struct dentry *dentry);
+extern struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *dentry);
 #else
 static inline
-struct vfsmount *nfs_do_refmount(struct dentry *dentry)
+struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *dentry)
 {
 	return ERR_PTR(-ENOENT);
 }
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 1807866..b9a593d 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -200,6 +200,22 @@ out_shutdown:
 out:
 	return err;
 }
+
+static struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
+					      struct qstr *name,
+					      struct nfs_fh *fh,
+					      struct nfs_fattr *fattr)
+{
+	int err;
+
+	if (NFS_PROTO(dir)->version == 4)
+		return nfs4_proc_lookup_mountpoint(dir, name, fh, fattr);
+
+	err = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, name, fh, fattr);
+	if (err)
+		return ERR_PTR(err);
+	return rpc_clone_client(NFS_SERVER(dir)->client);
+}
 #else /* CONFIG_NFS_V4 */
 static inline int nfs_lookup_with_sec(struct nfs_server *server,
 				      struct dentry *parent, struct dentry *dentry,
@@ -209,6 +225,17 @@ static inline int nfs_lookup_with_sec(struct nfs_server *server,
 {
 	return -EPERM;
 }
+
+static inline struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
+						     struct qstr *name,
+						     struct nfs_fh *fh,
+						     struct nfs_fattr *fattr)
+{
+	int err = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, name, fh, fattr);
+	if (err)
+		return ERR_PTR(err);
+	return rpc_clone_client(NFS_SERVER(dir)->client);
+}
 #endif /* CONFIG_NFS_V4 */
 
 /*
@@ -226,11 +253,10 @@ static inline int nfs_lookup_with_sec(struct nfs_server *server,
 struct vfsmount *nfs_d_automount(struct path *path)
 {
 	struct vfsmount *mnt;
-	struct nfs_server *server = NFS_SERVER(path->dentry->d_inode);
 	struct dentry *parent;
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
-	int err;
+	struct rpc_clnt *client;
 	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
 
 	dprintk("--> nfs_d_automount()\n");
@@ -249,21 +275,19 @@ struct vfsmount *nfs_d_automount(struct path *path)
 
 	/* Look it up again to get its attributes */
 	parent = dget_parent(path->dentry);
-	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
-						  &path->dentry->d_name,
-						  fh, fattr);
-	if (err == -EPERM && NFS_PROTO(parent->d_inode)->secinfo != NULL)
-		err = nfs_lookup_with_sec(server, parent, path->dentry, path, fh, fattr, &flavor);
+	client = nfs_lookup_mountpoint(parent->d_inode, &path->dentry->d_name, fh, fattr);
 	dput(parent);
-	if (err != 0) {
-		mnt = ERR_PTR(err);
+	if (IS_ERR(client)) {
+		mnt = ERR_CAST(client);
 		goto out;
 	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
-		mnt = nfs_do_refmount(path->dentry);
+		mnt = nfs_do_refmount(client, path->dentry);
 	else
 		mnt = nfs_do_submount(path->dentry, fh, fattr, flavor);
+	rpc_shutdown_client(client);
+
 	if (IS_ERR(mnt))
 		goto out;
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c82c2cd..8d75021 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -216,8 +216,10 @@ extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
-extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
-		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struct qstr *,
+				  struct nfs4_fs_locations *, struct page *);
+extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
+			    struct nfs_fh *, struct nfs_fattr *);
 extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 9f8681b..a7f3ded 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -300,7 +300,7 @@ out:
  * @dentry - dentry of referral
  *
  */
-struct vfsmount *nfs_do_refmount(struct dentry *dentry)
+struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *dentry)
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
 	struct dentry *parent;
@@ -326,7 +326,7 @@ struct vfsmount *nfs_do_refmount(struct dentry *dentry)
 	dprintk("%s: getting locations for %s/%s\n",
 		__func__, parent->d_name.name, dentry->d_name.name);
 
-	err = nfs4_proc_fs_locations(parent->d_inode, &dentry->d_name, fs_locations, page);
+	err = nfs4_proc_fs_locations(client, parent->d_inode, &dentry->d_name, fs_locations, page);
 	dput(parent);
 	if (err != 0 ||
 	    fs_locations->nlocations <= 0 ||
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3d92fe6..75eb883 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2377,8 +2377,9 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  * Note that we'll actually follow the referral later when
  * we detect fsid mismatch in inode revalidation
  */
-static int nfs4_get_referral(struct inode *dir, const struct qstr *name,
-			     struct nfs_fattr *fattr, struct nfs_fh *fhandle)
+static int nfs4_get_referral(struct rpc_clnt *client, struct inode *dir,
+			     const struct qstr *name, struct nfs_fattr *fattr,
+			     struct nfs_fh *fhandle)
 {
 	int status = -ENOMEM;
 	struct page *page = NULL;
@@ -2391,7 +2392,7 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name,
 	if (locations == NULL)
 		goto out;
 
-	status = nfs4_proc_fs_locations(dir, name, locations, page);
+	status = nfs4_proc_fs_locations(client, dir, name, locations, page);
 	if (status != 0)
 		goto out;
 	/* Make sure server returned a different fsid for the referral */
@@ -2550,7 +2551,7 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 			err = -ENOENT;
 			goto out;
 		case -NFS4ERR_MOVED:
-			err = nfs4_get_referral(dir, name, fattr, fhandle);
+			err = nfs4_get_referral(client, dir, name, fattr, fhandle);
 			goto out;
 		case -NFS4ERR_WRONGSEC:
 			err = -EPERM;
@@ -2591,6 +2592,21 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 	return status;
 }
 
+struct rpc_clnt *
+nfs4_proc_lookup_mountpoint(struct inode *dir, struct qstr *name,
+			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+{
+	int status;
+	struct rpc_clnt *client = rpc_clone_client(NFS_CLIENT(dir));
+
+	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr);
+	if (status < 0) {
+		rpc_shutdown_client(client);
+		return ERR_PTR(status);
+	}
+	return client;
+}
+
 static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -4951,8 +4967,10 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 	fattr->nlink = 2;
 }
 
-static int _nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
-		struct nfs4_fs_locations *fs_locations, struct page *page)
+static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
+				   const struct qstr *name,
+				   struct nfs4_fs_locations *fs_locations,
+				   struct page *page)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	u32 bitmask[2] = {
@@ -4986,19 +5004,21 @@ static int _nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
 }
 
-int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
-		struct nfs4_fs_locations *fs_locations, struct page *page)
+int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
+			   const struct qstr *name,
+			   struct nfs4_fs_locations *fs_locations,
+			   struct page *page)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_fs_locations(dir, name, fs_locations, page),
+				_nfs4_proc_fs_locations(client, dir, name, fs_locations, page),
 				&exception);
 	} while (exception.retry);
 	return err;
-- 
1.7.10

