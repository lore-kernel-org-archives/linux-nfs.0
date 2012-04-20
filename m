Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4512 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757469Ab2DTTIq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 15:08:46 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 6/8] NFS: Fix following referral mount points with different security
Date: Fri, 20 Apr 2012 15:08:36 -0400
Message-Id: <1334948918-4706-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1334948918-4706-1-git-send-email-bjschuma@netapp.com>
References: <1334948918-4706-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I create a new proc_lookup_mountpoint() to use when submounting an NFS
v4 share.  This function returns an rpc_clnt to use for performing an
fs_locations() call on a referral's mountpoint.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4_fs.h       |    6 ++++--
 fs/nfs/nfs4namespace.c |   24 ++++++++++++++----------
 fs/nfs/nfs4proc.c      |   40 ++++++++++++++++++++++++++++++----------
 3 files changed, 48 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 640a499..16846e9 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -218,8 +218,10 @@ extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
-extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
-		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struct qstr *,
+		struct nfs4_fs_locations *, struct page *);
+struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
+			    struct nfs_fh *, struct nfs_fattr *);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index b6baa6e..3cb3746 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -305,7 +305,7 @@ out:
  * @dentry - dentry of referral
  *
  */
-static struct vfsmount *nfs_do_refmount(struct dentry *dentry)
+static struct vfsmount *nfs_do_refmount(struct rpc_clnt *client, struct dentry *dentry)
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
 	struct dentry *parent;
@@ -331,7 +331,7 @@ static struct vfsmount *nfs_do_refmount(struct dentry *dentry)
 	dprintk("%s: getting locations for %s/%s\n",
 		__func__, parent->d_name.name, dentry->d_name.name);
 
-	err = nfs4_proc_fs_locations(parent->d_inode, &dentry->d_name, fs_locations, page);
+	err = nfs4_proc_fs_locations(client, parent->d_inode, &dentry->d_name, fs_locations, page);
 	dput(parent);
 	if (err != 0 ||
 	    fs_locations->nlocations <= 0 ||
@@ -350,17 +350,21 @@ out:
 struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 			       struct nfs_fh *fh, struct nfs_fattr *fattr)
 {
-	int err;
 	struct dentry *parent = dget_parent(dentry);
+	struct rpc_clnt *client;
+	struct vfsmount *mnt;
 
-	/* Look it up again to get its attributes */
-	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
-						  &dentry->d_name, fh, fattr);
+	/* Look it up again to get its attributes and sec flavor*/
+	client = nfs4_proc_lookup_mountpoint(parent->d_inode, &dentry->d_name, fh, fattr);
 	dput(parent);
-	if (err != 0)
-		return ERR_PTR(err);
+	if (IS_ERR(client))
+		return ERR_CAST(client);
 
 	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
-		return nfs_do_refmount(dentry);
-	return nfs_do_submount(dentry, fh, fattr, server->client->cl_auth->au_flavor);
+		mnt = nfs_do_refmount(client, dentry);
+	else
+		mnt = nfs_do_submount(dentry, fh, fattr, client->cl_auth->au_flavor);
+
+	rpc_shutdown_client(client);
+	return mnt;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3da1d7a..6a07dd3 100644
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
@@ -4949,8 +4965,10 @@ static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
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
@@ -4984,19 +5002,21 @@ static int _nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
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

