Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181Ab2DRRqh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:46:37 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 5/6] NFS: Remove extra rpc_clnt argument to proc_lookup
Date: Wed, 18 Apr 2012 13:46:24 -0400
Message-Id: <1334771185-9841-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
References: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
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
 fs/nfs/nfs4_fs.h        |    3 +--
 fs/nfs/nfs4proc.c       |    2 +-
 fs/nfs/proc.c           |    2 +-
 include/linux/nfs_xdr.h |    3 +--
 7 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4aaf031..c2a80c0 100644
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
index 3138077..884aa78 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -262,8 +262,7 @@ struct vfsmount *nfs_submount(struct nfs_server *server, struct dentry *dentry,
 	struct rpc_clnt *client;
 	struct vfsmount *mnt;
 
-	err = server->nfs_client->rpc_ops->lookup(server->client, parent->d_inode,
-						  &dentry->d_name, fh, fattr);
+	err = server->nfs_client->rpc_ops->lookup(parent->d_inode, &dentry->d_name, fh, fattr);
 	dput(parent);
 
 	if (err != 0)
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 0ac098a..a8dbec0 100644
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
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a3471234..6488a01 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -220,8 +220,7 @@ extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, boo
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
-extern int nfs4_proc_lookup(struct rpc_clnt *, struct inode *, struct qstr *,
-			    struct nfs_fh *, struct nfs_fattr *);
+extern int nfs4_proc_lookup(struct inode *, struct qstr *, struct nfs_fh *, struct nfs_fattr *);
 struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9f83a22..b4d8010 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2566,7 +2566,7 @@ out:
 	return err;
 }
 
-int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qstr *name,
+int nfs4_proc_lookup(struct inode *dir, struct qstr *name,
 		     struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	int status;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index da18f86..a72ee08 100644
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
index 24c11b2..cfc907d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1233,8 +1233,7 @@ struct nfs_rpc_ops {
 			    struct nfs_fattr *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
-	int	(*lookup)  (struct rpc_clnt *clnt, struct inode *, struct qstr *,
-			    struct nfs_fh *, struct nfs_fattr *);
+	int	(*lookup)  (struct inode *, struct qstr *, struct nfs_fh *, struct nfs_fattr *);
 	int	(*access)  (struct inode *, struct nfs_access_entry *);
 	int	(*readlink)(struct inode *, struct page *, unsigned int,
 			    unsigned int);
-- 
1.7.10

