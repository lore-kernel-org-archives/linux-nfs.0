Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29752 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756258Ab0IPVCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:02:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, hch@infradead.org
Subject: [PATCH 5/6] NFS: Clean up nfs4_proc_create()
Date: Thu, 16 Sep 2010 17:01:42 -0400
Message-Id: <1284670903-28475-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1284670903-28475-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1284670903-28475-1-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-2-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-3-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-4-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Remove all remaining references to the struct nameidata from the low level
NFS layers. Again pass down a partially initialised struct nfs_open_context
when we want to do atomic open+create.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c            |   47 ++++++++++++++++++++++++++++++++++-----
 fs/nfs/nfs3proc.c       |    2 +-
 fs/nfs/nfs4proc.c       |   56 +++++++++++-----------------------------------
 fs/nfs/proc.c           |    2 +-
 include/linux/nfs_xdr.h |    2 +-
 5 files changed, 58 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index dc93d35..e37ffdd 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -105,8 +105,9 @@ const struct inode_operations nfs3_dir_inode_operations = {
 #ifdef CONFIG_NFS_V4
 
 static struct dentry *nfs_atomic_lookup(struct inode *, struct dentry *, struct nameidata *);
+static int nfs_open_create(struct inode *dir, struct dentry *dentry, int mode, struct nameidata *nd);
 const struct inode_operations nfs4_dir_inode_operations = {
-	.create		= nfs_create,
+	.create		= nfs_open_create,
 	.lookup		= nfs_atomic_lookup,
 	.link		= nfs_link,
 	.unlink		= nfs_unlink,
@@ -1239,6 +1240,44 @@ no_open_dput:
 no_open:
 	return nfs_lookup_revalidate(dentry, nd);
 }
+
+static int nfs_open_create(struct inode *dir, struct dentry *dentry, int mode,
+		struct nameidata *nd)
+{
+	struct nfs_open_context *ctx = NULL;
+	struct iattr attr;
+	int error;
+	int open_flags = 0;
+
+	dfprintk(VFS, "NFS: create(%s/%ld), %s\n",
+			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
+
+	attr.ia_mode = mode;
+	attr.ia_valid = ATTR_MODE;
+
+	if ((nd->flags & LOOKUP_CREATE) != 0) {
+		open_flags = nd->intent.open.flags;
+
+		ctx = nameidata_to_nfs_open_context(dentry, nd);
+		error = PTR_ERR(ctx);
+		if (IS_ERR(ctx))
+			goto out_err;
+	}
+
+	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags, ctx);
+	if (error != 0)
+		goto out_put_ctx;
+	if (ctx != NULL)
+		nfs_intent_set_file(nd, ctx);
+	return 0;
+out_put_ctx:
+	if (ctx != NULL)
+		put_nfs_open_context(ctx);
+out_err:
+	d_drop(dentry);
+	return error;
+}
+
 #endif /* CONFIG_NFSV4 */
 
 static struct dentry *nfs_readdir_lookup(nfs_readdir_descriptor_t *desc)
@@ -1369,7 +1408,6 @@ static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 {
 	struct iattr attr;
 	int error;
-	int open_flags = 0;
 
 	dfprintk(VFS, "NFS: create(%s/%ld), %s\n",
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
@@ -1377,10 +1415,7 @@ static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
-	if ((nd->flags & LOOKUP_CREATE) != 0)
-		open_flags = nd->intent.open.flags;
-
-	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags, nd);
+	error = NFS_PROTO(dir)->create(dir, dentry, &attr, 0, NULL);
 	if (error != 0)
 		goto out_err;
 	return 0;
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index fabb4f2..2be4a7f 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -313,7 +313,7 @@ static void nfs3_free_createdata(struct nfs3_createdata *data)
  */
 static int
 nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
-		 int flags, struct nameidata *nd)
+		 int flags, struct nfs_open_context *ctx)
 {
 	struct nfs3_createdata *data;
 	mode_t mode = sattr->ia_mode;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 83c5ef6..617b149 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1998,32 +1998,6 @@ out:
 	return status;
 }
 
-static int nfs4_intent_set_file(struct nameidata *nd, struct path *path, struct nfs4_state *state, fmode_t fmode)
-{
-	struct file *filp;
-	int ret;
-
-	/* If the open_intent is for execute, we have an extra check to make */
-	if (fmode & FMODE_EXEC) {
-		ret = nfs_may_open(state->inode,
-				state->owner->so_cred,
-				nd->intent.open.flags);
-		if (ret < 0)
-			goto out_close;
-	}
-	filp = lookup_instantiate_filp(nd, path->dentry, NULL);
-	if (!IS_ERR(filp)) {
-		struct nfs_open_context *ctx;
-		ctx = nfs_file_open_context(filp);
-		ctx->state = state;
-		return 0;
-	}
-	ret = PTR_ERR(filp);
-out_close:
-	nfs4_close_sync(path, state, fmode & (FMODE_READ|FMODE_WRITE));
-	return ret;
-}
-
 struct inode *
 nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
 {
@@ -2491,36 +2465,34 @@ static int nfs4_proc_readlink(struct inode *inode, struct page *page,
 
 static int
 nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
-                 int flags, struct nameidata *nd)
+                 int flags, struct nfs_open_context *ctx)
 {
-	struct path path = {
-		.mnt = nd->path.mnt,
+	struct path my_path = {
 		.dentry = dentry,
 	};
+	struct path *path = &my_path;
 	struct nfs4_state *state;
-	struct rpc_cred *cred;
-	fmode_t fmode = flags & (FMODE_READ | FMODE_WRITE);
+	struct rpc_cred *cred = NULL;
+	fmode_t fmode = 0;
 	int status = 0;
 
-	cred = rpc_lookup_cred();
-	if (IS_ERR(cred)) {
-		status = PTR_ERR(cred);
-		goto out;
+	if (ctx != NULL) {
+		cred = ctx->cred;
+		path = &ctx->path;
+		fmode = ctx->mode;
 	}
-	state = nfs4_do_open(dir, &path, fmode, flags, sattr, cred);
+	state = nfs4_do_open(dir, path, fmode, flags, sattr, cred);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
-		goto out_putcred;
+		goto out;
 	}
 	d_add(dentry, igrab(state->inode));
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-	if (status == 0 && (nd->flags & LOOKUP_OPEN) != 0)
-		status = nfs4_intent_set_file(nd, &path, state, fmode);
+	if (ctx != NULL)
+		ctx->state = state;
 	else
-		nfs4_close_sync(&path, state, fmode);
-out_putcred:
-	put_rpccred(cred);
+		nfs4_close_sync(path, state, fmode);
 out:
 	return status;
 }
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 611bec2..4ef39ae 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -258,7 +258,7 @@ static void nfs_free_createdata(const struct nfs_createdata *data)
 
 static int
 nfs_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
-		int flags, struct nameidata *nd)
+		int flags, struct nfs_open_context *ctx)
 {
 	struct nfs_createdata *data;
 	struct rpc_message msg = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index fc46192..b1484da 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1032,7 +1032,7 @@ struct nfs_rpc_ops {
 	int	(*readlink)(struct inode *, struct page *, unsigned int,
 			    unsigned int);
 	int	(*create)  (struct inode *, struct dentry *,
-			    struct iattr *, int, struct nameidata *);
+			    struct iattr *, int, struct nfs_open_context *);
 	int	(*remove)  (struct inode *, struct qstr *);
 	void	(*unlink_setup)  (struct rpc_message *, struct inode *dir);
 	int	(*unlink_done) (struct rpc_task *, struct inode *);
-- 
1.7.2.3

