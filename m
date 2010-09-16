Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29752 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755435Ab0IPVCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:02:06 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, hch@infradead.org
Subject: [PATCH 1/6] NFSv4: Clean up nfs4_atomic_open
Date: Thu, 16 Sep 2010 17:01:38 -0400
Message-Id: <1284670903-28475-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1284670903-28475-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1284670903-28475-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Start moving the 'struct nameidata' dependent code out of the lower level
NFS code in preparation for the removal of open intents.

Instead of the struct nameidata, we pass down a partially initialised
struct nfs_open_context that will be fully initialised by the atomic open
upon success.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c           |   77 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/inode.c         |    8 ++--
 fs/nfs/nfs4_fs.h       |    2 +-
 fs/nfs/nfs4proc.c      |   40 +++++++------------------
 include/linux/nfs_fs.h |    2 +
 5 files changed, 93 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e257172..17529b5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -38,6 +38,7 @@
 #include "delegation.h"
 #include "iostat.h"
 #include "internal.h"
+#include "fscache.h"
 
 /* #define NFS_DEBUG_VERBOSE 1 */
 
@@ -1029,9 +1030,61 @@ static int is_atomic_open(struct nameidata *nd)
 	return 1;
 }
 
+static struct nfs_open_context *nameidata_to_nfs_open_context(struct dentry *dentry, struct nameidata *nd)
+{
+	struct path path = {
+		.mnt = nd->path.mnt,
+		.dentry = dentry,
+	};
+	struct nfs_open_context *ctx;
+	struct rpc_cred *cred;
+	fmode_t fmode = nd->intent.open.flags & (FMODE_READ | FMODE_WRITE | FMODE_EXEC);
+
+	cred = rpc_lookup_cred();
+	if (IS_ERR(cred))
+		return ERR_CAST(cred);
+	ctx = alloc_nfs_open_context(&path, cred, fmode);
+	put_rpccred(cred);
+	if (ctx == NULL)
+		return ERR_PTR(-ENOMEM);
+	return ctx;
+}
+
+static int do_open(struct inode *inode, struct file *filp)
+{
+	nfs_fscache_set_inode_cookie(inode, filp);
+	return 0;
+}
+
+static int nfs_intent_set_file(struct nameidata *nd, struct nfs_open_context *ctx)
+{
+	struct file *filp;
+	int ret = 0;
+
+	/* If the open_intent is for execute, we have an extra check to make */
+	if (ctx->mode & FMODE_EXEC) {
+		ret = nfs_may_open(ctx->path.dentry->d_inode,
+				ctx->cred,
+				nd->intent.open.flags);
+		if (ret < 0)
+			goto out;
+	}
+	filp = lookup_instantiate_filp(nd, ctx->path.dentry, do_open);
+	if (IS_ERR(filp))
+		ret = PTR_ERR(filp);
+	else
+		nfs_file_set_open_context(filp, ctx);
+out:
+	put_nfs_open_context(ctx);
+	return ret;
+}
+
 static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 {
+	struct nfs_open_context *ctx;
+	struct iattr attr;
 	struct dentry *res = NULL;
+	int open_flags;
 	int error;
 
 	dfprintk(VFS, "NFS: atomic_lookup(%s/%ld), %s\n",
@@ -1054,9 +1107,27 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 		goto out;
 	}
 
+	ctx = nameidata_to_nfs_open_context(dentry, nd);
+	res = ERR_CAST(ctx);
+	if (IS_ERR(ctx))
+		goto out;
+
+	open_flags = nd->intent.open.flags;
+	if (nd->flags & LOOKUP_CREATE) {
+		attr.ia_mode = nd->intent.open.create_mode;
+		attr.ia_valid = ATTR_MODE;
+		if (!IS_POSIXACL(dir))
+			attr.ia_mode &= ~current_umask();
+	} else {
+		open_flags &= ~O_EXCL;
+		attr.ia_valid = 0;
+		BUG_ON(open_flags & O_CREAT);
+	}
+
 	/* Open the file on the server */
-	res = nfs4_atomic_open(dir, dentry, nd);
+	res = nfs4_atomic_open(dir, ctx, open_flags, &attr);
 	if (IS_ERR(res)) {
+		put_nfs_open_context(ctx);
 		error = PTR_ERR(res);
 		switch (error) {
 			/* Make a negative dentry */
@@ -1074,8 +1145,10 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 			default:
 				goto out;
 		}
-	} else if (res != NULL)
+	}
+	if (res != NULL)
 		dentry = res;
+	nfs_intent_set_file(nd, ctx);
 out:
 	return res;
 no_open:
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7d2d6c7..2f92664 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -623,7 +623,7 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 	nfs_revalidate_inode(server, inode);
 }
 
-static struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct rpc_cred *cred)
+struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct rpc_cred *cred, fmode_t f_mode)
 {
 	struct nfs_open_context *ctx;
 
@@ -633,6 +633,7 @@ static struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct
 		path_get(&ctx->path);
 		ctx->cred = get_rpccred(cred);
 		ctx->state = NULL;
+		ctx->mode = f_mode;
 		ctx->flags = 0;
 		ctx->error = 0;
 		ctx->dir_cookie = 0;
@@ -673,7 +674,7 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
  * Ensure that mmap has a recent RPC credential for use when writing out
  * shared pages
  */
-static void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx)
+void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx)
 {
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -730,11 +731,10 @@ int nfs_open(struct inode *inode, struct file *filp)
 	cred = rpc_lookup_cred();
 	if (IS_ERR(cred))
 		return PTR_ERR(cred);
-	ctx = alloc_nfs_open_context(&filp->f_path, cred);
+	ctx = alloc_nfs_open_context(&filp->f_path, cred, filp->f_mode);
 	put_rpccred(cred);
 	if (ctx == NULL)
 		return -ENOMEM;
-	ctx->mode = filp->f_mode;
 	nfs_file_set_open_context(filp, ctx);
 	put_nfs_open_context(ctx);
 	nfs_fscache_set_inode_cookie(inode, filp);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 311e15c..c5cc2a6 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -242,7 +242,7 @@ extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
-extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
+extern struct dentry *nfs4_atomic_open(struct inode *, struct nfs_open_context *, int, struct iattr *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 089da5b..38c3bed 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2025,39 +2025,17 @@ out_close:
 }
 
 struct dentry *
-nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
+nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
 {
-	struct path path = {
-		.mnt = nd->path.mnt,
-		.dentry = dentry,
-	};
+	struct dentry *dentry = ctx->path.dentry;
 	struct dentry *parent;
-	struct iattr attr;
-	struct rpc_cred *cred;
 	struct nfs4_state *state;
 	struct dentry *res;
-	int open_flags = nd->intent.open.flags;
-	fmode_t fmode = open_flags & (FMODE_READ | FMODE_WRITE | FMODE_EXEC);
-
-	if (nd->flags & LOOKUP_CREATE) {
-		attr.ia_mode = nd->intent.open.create_mode;
-		attr.ia_valid = ATTR_MODE;
-		if (!IS_POSIXACL(dir))
-			attr.ia_mode &= ~current_umask();
-	} else {
-		open_flags &= ~O_EXCL;
-		attr.ia_valid = 0;
-		BUG_ON(open_flags & O_CREAT);
-	}
 
-	cred = rpc_lookup_cred();
-	if (IS_ERR(cred))
-		return (struct dentry *)cred;
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
-	state = nfs4_do_open(dir, &path, fmode, open_flags, &attr, cred);
-	put_rpccred(cred);
+	state = nfs4_do_open(dir, &ctx->path, ctx->mode, open_flags, attr, ctx->cred);
 	if (IS_ERR(state)) {
 		if (PTR_ERR(state) == -ENOENT) {
 			d_add(dentry, NULL);
@@ -2067,11 +2045,15 @@ nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 		return (struct dentry *)state;
 	}
 	res = d_add_unique(dentry, igrab(state->inode));
-	if (res != NULL)
-		path.dentry = res;
-	nfs_set_verifier(path.dentry, nfs_save_change_attribute(dir));
+	if (res != NULL) {
+		struct dentry *dummy = ctx->path.dentry;
+
+		ctx->path.dentry = dget(res);
+		dput(dummy);
+	}
+	ctx->state = state;
+	nfs_set_verifier(ctx->path.dentry, nfs_save_change_attribute(dir));
 	nfs_unblock_sillyrename(parent);
-	nfs4_intent_set_file(nd, &path, state, fmode);
 	return res;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 508f8cf..39cb70b 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -360,6 +360,8 @@ extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
+extern struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct rpc_cred *cred, fmode_t f_mode);
+extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
 extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
 extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
 extern u64 nfs_compat_user_ino64(u64 fileid);
-- 
1.7.2.3

