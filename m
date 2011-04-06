Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29608 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756188Ab1DFSda (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 14:33:30 -0400
Message-ID: <4D9CB1F8.4060708@netapp.com>
Date: Wed, 06 Apr 2011 14:33:28 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Dan Carpenter <error27@gmail.com>
Subject: NFS: Fix a signed vs. unsigned secinfo bug
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

rpc_authflavor_t is cast from an unsigned int, but the
initial code tried to use it as a signed int.  I fix
this by passing an rpc_authflavor_t pointer around, and
returning signed integers from functions.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Reported-by: Dan Carpenter <error27@gmail.com>

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 9166fcb..89fc160 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -148,67 +148,64 @@ static rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors,
 	return pseudoflavor;
 }
 
-static rpc_authflavor_t nfs_negotiate_security(const struct dentry *parent, const struct dentry *dentry)
+static int nfs_negotiate_security(const struct dentry *parent,
+				  const struct dentry *dentry,
+				  rpc_authflavor_t *flavor)
 {
-	int status = 0;
 	struct page *page;
 	struct nfs4_secinfo_flavors *flavors;
 	int (*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
-	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
+	int ret = -EPERM;
 
 	secinfo = NFS_PROTO(parent->d_inode)->secinfo;
 	if (secinfo != NULL) {
 		page = alloc_page(GFP_KERNEL);
 		if (!page) {
-			status = -ENOMEM;
+			ret = -ENOMEM;
 			goto out;
 		}
 		flavors = page_address(page);
-		status = secinfo(parent->d_inode, &dentry->d_name, flavors);
-		flavor = nfs_find_best_sec(flavors, dentry->d_inode);
+		ret = secinfo(parent->d_inode, &dentry->d_name, flavors);
+		*flavor = nfs_find_best_sec(flavors, dentry->d_inode);
 		put_page(page);
 	}
 
-	return flavor;
-
 out:
-	status = -ENOMEM;
-	return status;
+	return ret;
 }
 
-static rpc_authflavor_t nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
-				     struct dentry *dentry, struct path *path,
-				     struct nfs_fh *fh, struct nfs_fattr *fattr)
+static int nfs_lookup_with_sec(struct nfs_server *server, struct dentry *parent,
+			       struct dentry *dentry, struct path *path,
+			       struct nfs_fh *fh, struct nfs_fattr *fattr,
+			       rpc_authflavor_t *flavor)
 {
-	rpc_authflavor_t flavor;
 	struct rpc_clnt *clone;
 	struct rpc_auth *auth;
 	int err;
 
-	flavor = nfs_negotiate_security(parent, path->dentry);
-	if (flavor < 0)
+	err = nfs_negotiate_security(parent, path->dentry, flavor);
+	if (err < 0)
 		goto out;
 	clone  = rpc_clone_client(server->client);
-	auth   = rpcauth_create(flavor, clone);
+	auth   = rpcauth_create(*flavor, clone);
 	if (!auth) {
-		flavor = -EIO;
+		err = -EIO;
 		goto out_shutdown;
 	}
 	err = server->nfs_client->rpc_ops->lookup(clone, parent->d_inode,
 						  &path->dentry->d_name,
 						  fh, fattr);
-	if (err < 0)
-		flavor = err;
 out_shutdown:
 	rpc_shutdown_client(clone);
 out:
-	return flavor;
+	return err;
 }
 #else /* CONFIG_NFS_V4 */
-static inline rpc_authflavor_t nfs_lookup_with_sec(struct nfs_server *server,
-				     struct dentry *parent, struct dentry *dentry,
-				     struct path *path, struct nfs_fh *fh,
-				     struct nfs_fattr *fattr)
+static inline int nfs_lookup_with_sec(struct nfs_server *server,
+				      struct dentry *parent, struct dentry *dentry,
+				      struct path *path, struct nfs_fh *fh,
+				      struct nfs_fattr *fattr,
+				      rpc_authflavor_t *flavor)
 {
 	return -EPERM;
 }
@@ -234,7 +231,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
 	int err;
-	rpc_authflavor_t flavor = 1;
+	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
 
 	dprintk("--> nfs_d_automount()\n");
 
@@ -255,13 +252,8 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
 						  &path->dentry->d_name,
 						  fh, fattr);
-	if (err == -EPERM) {
-		flavor = nfs_lookup_with_sec(server, parent, path->dentry, path, fh, fattr);
-		if (flavor < 0)
-			err = flavor;
-		else
-			err = 0;
-	}
+	if (err == -EPERM && NFS_PROTO(parent->d_inode)->secinfo != NULL)
+		err = nfs_lookup_with_sec(server, parent, path->dentry, path, fh, fattr, &flavor);
 	dput(parent);
 	if (err != 0) {
 		mnt = ERR_PTR(err);
