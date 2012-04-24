Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2751 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757169Ab2DXR4U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 13:56:20 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 4/8] NFS: Remove secinfo knowledge out of the generic client
Date: Tue, 24 Apr 2012 13:56:08 -0400
Message-Id: <1335290172-1532-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335290172-1532-1-git-send-email-bjschuma@netapp.com>
References: <1335290172-1532-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

And also remove the unneeded rpc_op.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |    3 --
 fs/nfs/namespace.c      |   95 -----------------------------------------------
 fs/nfs/nfs4_fs.h        |    1 +
 fs/nfs/nfs4namespace.c  |   29 +++++++++++++++
 fs/nfs/nfs4proc.c       |    1 -
 include/linux/nfs_xdr.h |    1 -
 6 files changed, 30 insertions(+), 100 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 45966d9..15f702f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -279,9 +279,6 @@ extern void nfs_sb_deactive(struct super_block *sb);
 extern char *nfs_path(char **p, struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
 extern struct vfsmount *nfs_d_automount(struct path *path);
-#ifdef CONFIG_NFS_V4
-rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
-#endif
 
 /* getroot.c */
 extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 1807866..9accf45 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -118,99 +118,6 @@ Elong:
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
-static int nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
-			       struct dentry *dentry, struct path *path,
-			       struct nfs_fh *fh, struct nfs_fattr *fattr,
-			       rpc_authflavor_t *flavor)
-{
-	struct rpc_clnt *clone;
-	struct rpc_auth *auth;
-	int err;
-
-	err = nfs_negotiate_security(parent, path->dentry, flavor);
-	if (err < 0)
-		goto out;
-	clone  = rpc_clone_client(server->client);
-	auth   = rpcauth_create(*flavor, clone);
-	if (!auth) {
-		err = -EIO;
-		goto out_shutdown;
-	}
-	err = server->nfs_client->rpc_ops->lookup(clone, parent->d_inode,
-						  &path->dentry->d_name,
-						  fh, fattr);
-out_shutdown:
-	rpc_shutdown_client(clone);
-out:
-	return err;
-}
-#else /* CONFIG_NFS_V4 */
-static inline int nfs_lookup_with_sec(struct nfs_server *server,
-				      struct dentry *parent, struct dentry *dentry,
-				      struct path *path, struct nfs_fh *fh,
-				      struct nfs_fattr *fattr,
-				      rpc_authflavor_t *flavor)
-{
-	return -EPERM;
-}
-#endif /* CONFIG_NFS_V4 */
-
 /*
  * nfs_d_automount - Handle crossing a mountpoint on the server
  * @path - The mountpoint
@@ -252,8 +159,6 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
 						  &path->dentry->d_name,
 						  fh, fattr);
-	if (err == -EPERM && NFS_PROTO(parent->d_inode)->secinfo != NULL)
-		err = nfs_lookup_with_sec(server, parent, path->dentry, path, fh, fattr, &flavor);
 	dput(parent);
 	if (err != 0) {
 		mnt = ERR_PTR(err);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c82c2cd..670d5e5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -206,6 +206,7 @@ extern const struct dentry_operations nfs4_dentry_operations;
 extern const struct inode_operations nfs4_dir_inode_operations;
 
 /* nfs4namespace.c */
+rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
 
 /* nfs4proc.c */
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 199eec5..e01cd03 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -108,6 +108,35 @@ static size_t nfs_parse_server_name(char *string, size_t len,
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
 static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr *name)
 {
 	struct page *page;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d6b1cd0..a9b9e28 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6575,7 +6575,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.close_context  = nfs4_close_context,
 	.open_context	= nfs4_atomic_open,
 	.init_client	= nfs4_init_client,
-	.secinfo	= nfs4_proc_secinfo,
 };
 
 static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7ba3551..6cba0a1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1289,7 +1289,6 @@ struct nfs_rpc_ops {
 				struct iattr *iattr);
 	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t, int);
-	int	(*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 };
 
 /*
-- 
1.7.10

