Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11580 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759201Ab2DZU4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:56:33 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 9/9] NFS: Remove extra rpc_clnt argument to proc_lookup
Date: Thu, 26 Apr 2012 16:56:12 -0400
Message-Id: <1335473772-4401-10-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>
References: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Now that I'm doing secinfo automatically in the v4 code this extra
argument isn't needed.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/dir.c            |    6 +++---
 fs/nfs/namespace.c      |    3 +--
 fs/nfs/nfs3proc.c       |    2 +-
 fs/nfs/nfs4proc.c       |    2 +-
 fs/nfs/proc.c           |    2 +-
 include/linux/nfs_xdr.h |    2 +-
 6 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8789210..82b42e2 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1143,7 +1143,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 	if (fhandle == NULL || fattr == NULL)
 		goto out_error;
 
-	error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
 	if (error)
 		goto out_bad;
 	if (nfs_compare_fh(NFS_FH(inode), fhandle))
@@ -1299,7 +1299,7 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
-	error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
 	if (error == -ENOENT)
 		goto no_entry;
 	if (error < 0) {
@@ -1646,7 +1646,7 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
 	if (dentry->d_inode)
 		goto out;
 	if (fhandle->size == 0) {
-		error = NFS_PROTO(dir)->lookup(NFS_SERVER(dir)->client, dir, &dentry->d_name, fhandle, fattr);
+		error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
 		if (error)
 			goto out_error;
 	}
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index e36fd8a..08b9c93 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -261,8 +261,7 @@ struct vfsmount *nfs_submount(struct nfs_server *server, struct dentry *dentry,
 	struct dentry *parent = dget_parent(dentry);
 
 	/* Look it up again to get its attributes */
-	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
-						  &dentry->d_name, fh, fattr);
+	err = server->nfs_client->rpc_ops->lookup(parent->d_inode, &dentry->d_name, fh, fattr);
 	dput(parent);
 	if (err != 0)
 		return ERR_PTR(err);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index d39d1d7..f03ab63 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -142,7 +142,7 @@ nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 }
 
 static int
-nfs3_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
+nfs3_proc_lookup(struct inode *dir, struct qstr *name,
 		 struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs3_diropargs	arg = {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 279bbd9..1f46bae 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2578,7 +2578,7 @@ out:
 	return err;
 }
 
-static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
+static int nfs4_proc_lookup(struct inode *dir, struct qstr *name,
 			    struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	int status;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 8dfe960..11645a2 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -178,7 +178,7 @@ nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 }
 
 static int
-nfs_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
+nfs_proc_lookup(struct inode *dir, struct qstr *name,
 		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	struct nfs_diropargs	arg = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ada3acd..3636fb6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1240,7 +1240,7 @@ struct nfs_rpc_ops {
 			    struct nfs_fattr *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
-	int	(*lookup)  (struct rpc_clnt *clnt, struct inode *, struct qstr *,
+	int	(*lookup)  (struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 	int	(*access)  (struct inode *, struct nfs_access_entry *);
 	int	(*readlink)(struct inode *, struct page *, unsigned int,
-- 
1.7.10

