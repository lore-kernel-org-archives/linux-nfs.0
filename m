Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176Ab2DRRqg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:46:36 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 4/6] NFS: Do secinfo as part of lookup
Date: Wed, 18 Apr 2012 13:46:23 -0400
Message-Id: <1334771185-9841-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
References: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Whenever lookup sees wrongsec do a secinfo and retry the lookup to find
important attributes, such as "is this a referral mountpoint".  This
means that  secinfo is done in v4 code only, we can remove the rpc_op.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |    8 ----
 fs/nfs/namespace.c      |   84 --------------------------------------
 fs/nfs/nfs4_fs.h        |    5 +++
 fs/nfs/nfs4namespace.c  |  102 ++++++++++++++++++++++++++++++++++++++++-------
 fs/nfs/nfs4proc.c       |   77 ++++++++++++++++++++++++++---------
 fs/nfs/nfs4xdr.c        |    2 -
 include/linux/nfs_xdr.h |    1 -
 7 files changed, 151 insertions(+), 128 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index a7995b3..9d7d4d1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -224,7 +224,6 @@ extern const u32 nfs41_maxwrite_overhead;
 /* nfs4proc.c */
 #ifdef CONFIG_NFS_V4
 extern struct rpc_procinfo nfs4_procedures[];
-void nfs_fixup_secinfo_attributes(struct nfs_fattr *, struct nfs_fh *);
 #endif
 
 extern int nfs4_init_ds_session(struct nfs_client *clp);
@@ -275,13 +274,6 @@ struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
 struct vfsmount *nfs_submount(struct nfs_server *, struct dentry *,
 			      struct nfs_fh *, struct nfs_fattr *);
 
-#ifdef CONFIG_NFS_V4
-rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
-int nfs_lookup_with_sec(struct nfs_server *, struct dentry *, struct dentry *,
-			struct nfs_fh *, struct nfs_fattr *);
-
-#endif
-
 /* getroot.c */
 extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
 				   const char *);
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 5f401fa..3138077 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -113,90 +113,6 @@ Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
 
-#ifdef CONFIG_NFS_V4
-rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
-{
-	struct gss_api_mech *mech;
-	struct xdr_netobj oid;
-	int i;
-	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
-
-	for (i = 0; i < flavors->num_flavors; i++) {
-		struct nfs4_secinfo_flavor *flavor;
-		flavor = &flavors->flavors[i];
-
-		if (flavor->flavor == RPC_AUTH_NULL || flavor->flavor == RPC_AUTH_UNIX) {
-			pseudoflavor = flavor->flavor;
-			break;
-		} else if (flavor->flavor == RPC_AUTH_GSS) {
-			oid.len  = flavor->gss.sec_oid4.len;
-			oid.data = flavor->gss.sec_oid4.data;
-			mech = gss_mech_get_by_OID(&oid);
-			if (!mech)
-				continue;
-			pseudoflavor = gss_svc_to_pseudoflavor(mech, flavor->gss.service);
-			gss_mech_put(mech);
-			break;
-		}
-	}
-
-	return pseudoflavor;
-}
-
-static int nfs_negotiate_security(const struct dentry *parent,
-				  const struct dentry *dentry,
-				  rpc_authflavor_t *flavor)
-{
-	struct page *page;
-	struct nfs4_secinfo_flavors *flavors;
-	int (*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
-	int ret = -EPERM;
-
-	secinfo = NFS_PROTO(parent->d_inode)->secinfo;
-	if (secinfo != NULL) {
-		page = alloc_page(GFP_KERNEL);
-		if (!page) {
-			ret = -ENOMEM;
-			goto out;
-		}
-		flavors = page_address(page);
-		ret = secinfo(parent->d_inode, &dentry->d_name, flavors);
-		*flavor = nfs_find_best_sec(flavors);
-		put_page(page);
-	}
-
-out:
-	return ret;
-}
-
-int nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
-			struct dentry *dentry, struct nfs_fh *fh,
-			struct nfs_fattr *fattr)
-{
-	struct rpc_clnt *clone;
-	struct rpc_auth *auth;
-	rpc_authflavor_t flavor;
-	int err;
-
-	err = nfs_negotiate_security(parent, dentry, &flavor);
-	if (err < 0)
-		goto out;
-	clone  = rpc_clone_client(server->client);
-	auth   = rpcauth_create(flavor, clone);
-	if (!auth) {
-		err = -EIO;
-		goto out_shutdown;
-	}
-	err = server->nfs_client->rpc_ops->lookup(clone, parent->d_inode,
-						  &dentry->d_name,
-						  fh, fattr);
-out_shutdown:
-	rpc_shutdown_client(clone);
-out:
-	return err;
-}
-#endif /* CONFIG_NFS_V4 */
-
 /*
  * nfs_d_automount - Handle crossing a mountpoint on the server
  * @path - The mountpoint
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e761268..a3471234 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -207,6 +207,8 @@ extern const struct inode_operations nfs4_dir_inode_operations;
 /* nfs4namespace.c */
 struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
 			       struct nfs_fh *, struct nfs_fattr *);
+struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
+rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
@@ -220,6 +222,9 @@ extern int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir, co
 		struct nfs4_fs_locations *fs_locations, struct page *page);
 extern int nfs4_proc_lookup(struct rpc_clnt *, struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
+struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
+			    struct nfs_fh *, struct nfs_fattr *);
+int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 extern int nfs4_release_lockowner(struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index a12b747..a2d08bd 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -108,6 +108,84 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 	return ret;
 }
 
+rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
+{
+	struct gss_api_mech *mech;
+	struct xdr_netobj oid;
+	int i;
+	rpc_authflavor_t pseudoflavor = RPC_AUTH_UNIX;
+
+	for (i = 0; i < flavors->num_flavors; i++) {
+		struct nfs4_secinfo_flavor *flavor;
+		flavor = &flavors->flavors[i];
+
+		if (flavor->flavor == RPC_AUTH_NULL || flavor->flavor == RPC_AUTH_UNIX) {
+			pseudoflavor = flavor->flavor;
+			break;
+		} else if (flavor->flavor == RPC_AUTH_GSS) {
+			oid.len  = flavor->gss.sec_oid4.len;
+			oid.data = flavor->gss.sec_oid4.data;
+			mech = gss_mech_get_by_OID(&oid);
+			if (!mech)
+				continue;
+			pseudoflavor = gss_svc_to_pseudoflavor(mech, flavor->gss.service);
+			gss_mech_put(mech);
+			break;
+		}
+	}
+
+	return pseudoflavor;
+}
+
+static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr *name)
+{
+	struct page *page;
+	struct nfs4_secinfo_flavors *flavors;
+	rpc_authflavor_t flavor;
+	int err;
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
+	flavors = page_address(page);
+
+	err = nfs4_proc_secinfo(inode, name, flavors);
+	if (err < 0) {
+		flavor = err;
+		goto out;
+	}
+
+	flavor = nfs_find_best_sec(flavors);
+
+out:
+	put_page(page);
+	return flavor;
+}
+
+/*
+ * Please call rpc_shutdown_client() when you are done with this client.
+ */
+struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *inode,
+					struct qstr *name)
+{
+	struct rpc_clnt *clone;
+	struct rpc_auth *auth;
+	rpc_authflavor_t flavor;
+
+	flavor = nfs4_negotiate_security(inode, name);
+	if (flavor < 0)
+		return ERR_PTR(flavor);
+
+	clone  = rpc_clone_client(clnt);
+	auth   = rpcauth_create(flavor, clone);
+	if (!auth) {
+		rpc_shutdown_client(clone);
+		clone = ERR_PTR(-EIO);
+	}
+
+	return clone;
+}
+
 static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 				     char *page, char *page2,
 				     const struct nfs4_fs_location *location)
@@ -224,7 +302,7 @@ out:
  * @dentry - dentry of referral
  *
  */
-static struct vfsmount *nfs_do_refmount(struct dentry *dentry)
+static struct vfsmount *nfs_do_refmount(struct dentry *dentry, struct rpc_clnt *client)
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
 	struct dentry *parent;
@@ -250,7 +328,7 @@ static struct vfsmount *nfs_do_refmount(struct dentry *dentry)
 	dprintk("%s: getting locations for %s/%s\n",
 		__func__, parent->d_name.name, dentry->d_name.name);
 
-	err = nfs4_proc_fs_locations(NFS_CLIENT(parent->d_inode), parent->d_inode,
+	err = nfs4_proc_fs_locations(client, parent->d_inode,
 				     &dentry->d_name, fs_locations, page);
 	dput(parent);
 	if (err != 0 ||
@@ -270,29 +348,23 @@ out:
 struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 			       struct nfs_fh *fh, struct nfs_fattr *fattr)
 {
-	int err;
 	struct dentry *parent = dget_parent(dentry);
 	struct rpc_clnt *client;
 	struct vfsmount *ret;
 
 	/* Look it up again to get its attributes */
-	err = nfs4_proc_lookup(server->client, parent->d_inode, &dentry->d_name, fh, fattr);
-	if (err == -EPERM)
-		err = nfs_lookup_with_sec(server, parent, dentry, fh, fattr);
+	client = nfs4_proc_lookup_mountpoint(parent->d_inode, &dentry->d_name, fh, fattr);
 	dput(parent);
 
-	if (err != 0)
-		return ERR_PTR(err);
-
-	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
-		return nfs_do_refmount(dentry);
-
-	client = rpc_clone_client(server->client);
 	if (IS_ERR(client))
 		return ERR_CAST(client);
 
-	ret = nfs_do_submount(dentry, fh, fattr, client);
-	if (IS_ERR(ret))
+	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
+		ret = nfs_do_refmount(dentry, client);
+	else
+		ret = nfs_do_submount(dentry, fh, fattr, client);
+
+	if (IS_ERR(ret) || (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL))
 		rpc_shutdown_client(client);
 
 	return ret;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9e21e25..9f83a22 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2520,39 +2520,81 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 	return status;
 }
 
-void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr, struct nfs_fh *fh)
+static void nfs_fixup_secinfo_attributes(struct nfs_fattr *fattr)
 {
-	memset(fh, 0, sizeof(struct nfs_fh));
-	fattr->fsid.major = 1;
 	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
-		NFS_ATTR_FATTR_NLINK | NFS_ATTR_FATTR_FSID | NFS_ATTR_FATTR_MOUNTPOINT;
+		NFS_ATTR_FATTR_NLINK | NFS_ATTR_FATTR_MOUNTPOINT;
 	fattr->mode = S_IFDIR | S_IRUGO | S_IXUGO;
 	fattr->nlink = 2;
 }
 
-int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
-		     struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
+				   struct qstr *name, struct nfs_fh *fhandle,
+				   struct nfs_fattr *fattr)
 {
 	struct nfs4_exception exception = { };
+	struct rpc_clnt *client = *clnt;
 	int err;
-	do {
-		int status;
 
-		status = _nfs4_proc_lookup(clnt, dir, name, fhandle, fattr);
-		switch (status) {
+	do {
+		err = _nfs4_proc_lookup(client, dir, name, fhandle, fattr);
+		switch (err) {
 		case -NFS4ERR_BADNAME:
-			return -ENOENT;
+			err = -ENOENT;
+			goto out;
 		case -NFS4ERR_MOVED:
-			return nfs4_get_referral(clnt, dir, name, fattr, fhandle);
+			err = nfs4_get_referral(client, dir, name, fattr, fhandle);
+			goto out;
 		case -NFS4ERR_WRONGSEC:
-			nfs_fixup_secinfo_attributes(fattr, fhandle);
+			err = -EPERM;
+			if (client != *clnt)
+				goto out;
+			client = nfs4_create_sec_client(client, dir, name);
+			exception.retry = 1;
+			break;
+		default:
+			err = nfs4_handle_exception(NFS_SERVER(dir), err, &exception);
 		}
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				status, &exception);
 	} while (exception.retry);
+
+out:
+	if (err == 0)
+		*clnt = client;
+	else if (client != *clnt)
+		rpc_shutdown_client(client);
+
 	return err;
 }
 
+int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
+		     struct nfs_fh *fhandle, struct nfs_fattr *fattr)
+{
+	int status;
+	struct rpc_clnt *client = NFS_CLIENT(dir);
+
+	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr);
+	if (client != NFS_CLIENT(dir)) {
+		rpc_shutdown_client(client);
+		nfs_fixup_secinfo_attributes(fattr);
+	}
+	return status;
+}
+
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
@@ -4954,8 +4996,8 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 	return status;
 }
 
-static int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
-		struct nfs4_secinfo_flavors *flavors)
+int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
+		      struct nfs4_secinfo_flavors *flavors)
 {
 	struct nfs4_exception exception = { };
 	int err;
@@ -6506,7 +6548,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.open_context	= nfs4_atomic_open,
 	.submount	= nfs4_submount,
 	.init_client	= nfs4_init_client,
-	.secinfo	= nfs4_proc_secinfo,
 };
 
 static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c74fdb1..eca81b1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4257,8 +4257,6 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 	status = decode_attr_error(xdr, bitmap, &err);
 	if (status < 0)
 		goto xdr_error;
-	if (err == -NFS4ERR_WRONGSEC)
-		nfs_fixup_secinfo_attributes(fattr, fh);
 
 	status = decode_attr_filehandle(xdr, bitmap, fh);
 	if (status < 0)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3c94c80..24c11b2 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1286,7 +1286,6 @@ struct nfs_rpc_ops {
 				     struct nfs_fh *, struct nfs_fattr *);
 	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t, int);
-	int	(*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 };
 
 /*
-- 
1.7.10

