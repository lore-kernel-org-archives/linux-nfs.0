Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760638Ab2D0R2A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 13:28:00 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v5 6/9] NFS: Remove unused function nfs_lookup_with_sec()
Date: Fri, 27 Apr 2012 13:27:43 -0400
Message-Id: <1335547666-28315-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335547666-28315-1-git-send-email-bjschuma@netapp.com>
References: <1335547666-28315-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This fixes a compiler warning.
---
 fs/nfs/namespace.c |   62 ----------------------------------------------------
 1 file changed, 62 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 78dde30..d51868e 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -148,59 +148,6 @@ rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 	return pseudoflavor;
 }
 
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
-
 static struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
 					      struct qstr *name,
 					      struct nfs_fh *fh,
@@ -217,15 +164,6 @@ static struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
 	return rpc_clone_client(NFS_SERVER(dir)->client);
 }
 #else /* CONFIG_NFS_V4 */
-static inline int nfs_lookup_with_sec(struct nfs_server *server,
-				      struct dentry *parent, struct dentry *dentry,
-				      struct path *path, struct nfs_fh *fh,
-				      struct nfs_fattr *fattr,
-				      rpc_authflavor_t *flavor)
-{
-	return -EPERM;
-}
-
 static inline struct rpc_clnt *nfs_lookup_mountpoint(struct inode *dir,
 						     struct qstr *name,
 						     struct nfs_fh *fh,
-- 
1.7.10

