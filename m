Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:43942 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbeCTUnq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:46 -0400
Received: by mail-io0-f195.google.com with SMTP id l12so4004213ioc.10
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] NFS: Move the delegation return down into nfs4_proc_remove()
Date: Tue, 20 Mar 2018 16:43:15 -0400
Message-Id: <20180320204320.93656-4-trond.myklebust@primarydata.com>
In-Reply-To: <20180320204320.93656-3-trond.myklebust@primarydata.com>
References: <20180320204320.93656-1-trond.myklebust@primarydata.com>
 <20180320204320.93656-2-trond.myklebust@primarydata.com>
 <20180320204320.93656-3-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the delegation return out of generic code and down into the
NFSv4 specific unlink code.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c            |  5 ++---
 fs/nfs/nfs3proc.c       |  6 +++---
 fs/nfs/nfs4proc.c       | 22 ++++++++++++++++++++--
 fs/nfs/proc.c           |  6 +++---
 include/linux/nfs_xdr.h |  2 +-
 5 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b4549e54007d..eb9d782ed674 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1798,12 +1798,11 @@ static int nfs_safe_remove(struct dentry *dentry)
 
 	trace_nfs_remove_enter(dir, dentry);
 	if (inode != NULL) {
-		NFS_PROTO(inode)->return_delegation(inode);
-		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
+		error = NFS_PROTO(dir)->remove(dir, dentry);
 		if (error == 0)
 			nfs_drop_nlink(inode);
 	} else
-		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
+		error = NFS_PROTO(dir)->remove(dir, dentry);
 	if (error == -ENOENT)
 		nfs_dentry_handle_enoent(dentry);
 	trace_nfs_remove_exit(dir, dentry, error);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 7327930ad970..f4ead71e4350 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -383,11 +383,11 @@ nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 }
 
 static int
-nfs3_proc_remove(struct inode *dir, const struct qstr *name)
+nfs3_proc_remove(struct inode *dir, struct dentry *dentry)
 {
 	struct nfs_removeargs arg = {
 		.fh = NFS_FH(dir),
-		.name = *name,
+		.name = dentry->d_name,
 	};
 	struct nfs_removeres res;
 	struct rpc_message msg = {
@@ -397,7 +397,7 @@ nfs3_proc_remove(struct inode *dir, const struct qstr *name)
 	};
 	int status = -ENOMEM;
 
-	dprintk("NFS call  remove %s\n", name->name);
+	dprintk("NFS call  remove %pd2\n", dentry);
 	res.dir_attr = nfs_alloc_fattr();
 	if (res.dir_attr == NULL)
 		goto out;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8290a04907b0..69a2428eef10 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4200,10 +4200,28 @@ static int _nfs4_proc_remove(struct inode *dir, const struct qstr *name)
 	return status;
 }
 
-static int nfs4_proc_remove(struct inode *dir, const struct qstr *name)
+static int nfs4_proc_remove(struct inode *dir, struct dentry *dentry)
 {
 	struct nfs4_exception exception = { };
+	struct inode *inode = d_inode(dentry);
 	int err;
+
+	if (inode)
+		nfs4_inode_return_delegation(inode);
+	do {
+		err = _nfs4_proc_remove(dir, &dentry->d_name);
+		trace_nfs4_remove(dir, &dentry->d_name, err);
+		err = nfs4_handle_exception(NFS_SERVER(dir), err,
+				&exception);
+	} while (exception.retry);
+	return err;
+}
+
+static int nfs4_proc_rmdir(struct inode *dir, const struct qstr *name)
+{
+	struct nfs4_exception exception = { };
+	int err;
+
 	do {
 		err = _nfs4_proc_remove(dir, name);
 		trace_nfs4_remove(dir, name, err);
@@ -9596,7 +9614,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.link		= nfs4_proc_link,
 	.symlink	= nfs4_proc_symlink,
 	.mkdir		= nfs4_proc_mkdir,
-	.rmdir		= nfs4_proc_remove,
+	.rmdir		= nfs4_proc_rmdir,
 	.readdir	= nfs4_proc_readdir,
 	.mknod		= nfs4_proc_mknod,
 	.statfs		= nfs4_proc_statfs,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index f7fd9192d4bc..b2e81a110133 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -300,11 +300,11 @@ nfs_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 }
   
 static int
-nfs_proc_remove(struct inode *dir, const struct qstr *name)
+nfs_proc_remove(struct inode *dir, struct dentry *dentry)
 {
 	struct nfs_removeargs arg = {
 		.fh = NFS_FH(dir),
-		.name = *name,
+		.name = dentry->d_name,
 	};
 	struct rpc_message msg = { 
 		.rpc_proc = &nfs_procedures[NFSPROC_REMOVE],
@@ -312,7 +312,7 @@ nfs_proc_remove(struct inode *dir, const struct qstr *name)
 	};
 	int			status;
 
-	dprintk("NFS call  remove %s\n", name->name);
+	dprintk("NFS call  remove %pd2\n",dentry);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 	nfs_mark_for_revalidate(dir);
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6959968dc36a..3ebf14b3bf0b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1590,7 +1590,7 @@ struct nfs_rpc_ops {
 			    unsigned int);
 	int	(*create)  (struct inode *, struct dentry *,
 			    struct iattr *, int);
-	int	(*remove)  (struct inode *, const struct qstr *);
+	int	(*remove)  (struct inode *, struct dentry *);
 	void	(*unlink_setup)  (struct rpc_message *, struct inode *dir);
 	void	(*unlink_rpc_prepare) (struct rpc_task *, struct nfs_unlinkdata *);
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
-- 
2.14.3

