Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40305 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752329AbdLKEly (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 10 Dec 2017 23:41:54 -0500
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 19E05AAB5
        for <linux-nfs@vger.kernel.org>; Mon, 11 Dec 2017 04:41:53 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 11 Dec 2017 15:40:18 +1100
Subject: [PATCH 14/19] NFS: struct nfs_open_dir_context: convert rpc_cred
 pointer to cred.
Message-ID: <151296721796.24753.8881928226094144866.stgit@noble>
In-Reply-To: <151296579813.24753.5905981862981613395.stgit@noble>
References: <151296579813.24753.5905981862981613395.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the common 'struct cred' to pass credentials for readdir.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/dir.c            |   15 +++++----------
 fs/nfs/nfs3proc.c       |   11 +++++++++--
 fs/nfs/nfs4proc.c       |   13 ++++++++++---
 fs/nfs/proc.c           |   11 +++++++++--
 include/linux/nfs_fs.h  |    2 +-
 include/linux/nfs_xdr.h |    2 +-
 6 files changed, 35 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c4a79923c873..850e948fd741 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -67,7 +67,7 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct inode *dir, struct rpc_cred *cred)
+static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct inode *dir, const struct cred *cred)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
 	struct nfs_open_dir_context *ctx;
@@ -77,7 +77,7 @@ static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct inode *dir
 		ctx->attr_gencount = nfsi->attr_gencount;
 		ctx->dir_cookie = 0;
 		ctx->dup_cookie = 0;
-		ctx->cred = get_rpccred(cred);
+		ctx->cred = get_cred(cred);
 		spin_lock(&dir->i_lock);
 		list_add(&ctx->list, &nfsi->open_files);
 		spin_unlock(&dir->i_lock);
@@ -91,7 +91,7 @@ static void put_nfs_open_dir_context(struct inode *dir, struct nfs_open_dir_cont
 	spin_lock(&dir->i_lock);
 	list_del(&ctx->list);
 	spin_unlock(&dir->i_lock);
-	put_rpccred(ctx->cred);
+	put_cred(ctx->cred);
 	kfree(ctx);
 }
 
@@ -103,23 +103,18 @@ nfs_opendir(struct inode *inode, struct file *filp)
 {
 	int res = 0;
 	struct nfs_open_dir_context *ctx;
-	struct rpc_cred *cred;
 
 	dfprintk(FILE, "NFS: open dir(%pD2)\n", filp);
 
 	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 
-	cred = rpc_lookup_cred();
-	if (IS_ERR(cred))
-		return PTR_ERR(cred);
-	ctx = alloc_nfs_open_dir_context(inode, cred);
+	ctx = alloc_nfs_open_dir_context(inode, current_cred());
 	if (IS_ERR(ctx)) {
 		res = PTR_ERR(ctx);
 		goto out;
 	}
 	filp->private_data = ctx;
 out:
-	put_rpccred(cred);
 	return res;
 }
 
@@ -334,7 +329,7 @@ int nfs_readdir_xdr_filler(struct page **pages, nfs_readdir_descriptor_t *desc,
 			struct nfs_entry *entry, struct file *file, struct inode *inode)
 {
 	struct nfs_open_dir_context *ctx = file->private_data;
-	struct rpc_cred	*cred = ctx->cred;
+	const struct cred *cred = ctx->cred;
 	unsigned long	timestamp, gencount;
 	int		error;
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 682f22946975..2b1291396162 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -606,7 +606,7 @@ nfs3_proc_rmdir(struct inode *dir, const struct qstr *name)
  * readdirplus.
  */
 static int
-nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
+nfs3_proc_readdir(struct dentry *dentry, const struct cred *cred,
 		  u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
 	struct inode		*dir = d_inode(dentry);
@@ -623,11 +623,15 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.verf		= verf,
 		.plus		= plus
 	};
+	struct auth_cred acred = {
+		.cred		= cred,
+	};
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_READDIR],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
-		.rpc_cred	= cred
+		.rpc_cred	= rpc_lookup_generic_cred(&acred,
+							  0, GFP_NOFS),
 	};
 	int status = -ENOMEM;
 
@@ -637,6 +641,8 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 	dprintk("NFS call  readdir%s %d\n",
 			plus? "plus" : "", (unsigned int) cookie);
 
+	if (!msg.rpc_cred)
+		return -ENOMEM;
 	res.dir_attr = nfs_alloc_fattr();
 	if (res.dir_attr == NULL)
 		goto out;
@@ -648,6 +654,7 @@ nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 
 	nfs_free_fattr(res.dir_attr);
 out:
+	put_rpccred(msg.rpc_cred);
 	dprintk("NFS reply readdir%s: %d\n",
 			plus? "plus" : "", status);
 	return status;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2327e2e8c71f..5477b4f291bb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4490,7 +4490,7 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 	return err;
 }
 
-static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
+static int _nfs4_proc_readdir(struct dentry *dentry, const struct cred *cred,
 		u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
 	struct inode		*dir = d_inode(dentry);
@@ -4503,17 +4503,23 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.plus = plus,
 	};
 	struct nfs4_readdir_res res;
+	struct auth_cred acred = {
+		.cred		= cred,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READDIR],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
-		.rpc_cred = cred,
+		.rpc_cred = rpc_lookup_generic_cred(&acred,
+						    0, GFP_NOFS),
 	};
 	int			status;
 
 	dprintk("%s: dentry = %pd2, cookie = %Lu\n", __func__,
 			dentry,
 			(unsigned long long)cookie);
+	if (!msg.rpc_cred)
+		return -ENOMEM;
 	nfs4_setup_readdir(cookie, NFS_I(dir)->cookieverf, dentry, &args);
 	res.pgbase = args.pgbase;
 	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
@@ -4524,11 +4530,12 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 
 	nfs_invalidate_atime(dir);
 
+	put_rpccred(msg.rpc_cred);
 	dprintk("%s: returns %d\n", __func__, status);
 	return status;
 }
 
-static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
+static int nfs4_proc_readdir(struct dentry *dentry, const struct cred *cred,
 		u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
 	struct nfs4_exception exception = { };
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index f7fd9192d4bc..70df66a72d15 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -485,7 +485,7 @@ nfs_proc_rmdir(struct inode *dir, const struct qstr *name)
  * from nfs_readdir by calling the decode_entry function directly.
  */
 static int
-nfs_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
+nfs_proc_readdir(struct dentry *dentry, const struct cred *cred,
 		 u64 cookie, struct page **pages, unsigned int count, bool plus)
 {
 	struct inode		*dir = d_inode(dentry);
@@ -495,18 +495,25 @@ nfs_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.count		= count,
 		.pages		= pages,
 	};
+	struct auth_cred acred = {
+		.cred		= cred,
+	};
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_READDIR],
 		.rpc_argp	= &arg,
-		.rpc_cred	= cred,
+		.rpc_cred	= rpc_lookup_generic_cred(&acred,
+							  0, GFP_NOFS),
 	};
 	int			status;
 
 	dprintk("NFS call  readdir %d\n", (unsigned int)cookie);
+	if (!msg.rpc_cred)
+		return -ENOMEM;
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 
 	nfs_invalidate_atime(dir);
 
+	put_rpccred(msg.rpc_cred);
 	dprintk("NFS reply readdir: %d\n", status);
 	return status;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 0a7e66efe212..702b6fe5d642 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -87,7 +87,7 @@ struct nfs_open_context {
 
 struct nfs_open_dir_context {
 	struct list_head list;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	unsigned long attr_gencount;
 	__u64 dir_cookie;
 	__u64 dup_cookie;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6959968dc36a..b33a7f3577e1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1602,7 +1602,7 @@ struct nfs_rpc_ops {
 			    unsigned int, struct iattr *);
 	int	(*mkdir)   (struct inode *, struct dentry *, struct iattr *);
 	int	(*rmdir)   (struct inode *, const struct qstr *);
-	int	(*readdir) (struct dentry *, struct rpc_cred *,
+	int	(*readdir) (struct dentry *, const struct cred *,
 			    u64, struct page **, unsigned int, bool);
 	int	(*mknod)   (struct inode *, struct dentry *, struct iattr *,
 			    dev_t);


