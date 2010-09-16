Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42499 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755517Ab0IPVCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:02:06 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, hch@infradead.org
Subject: [PATCH 2/6] NFSv4: Further minor cleanups for nfs4_atomic_open()
Date: Thu, 16 Sep 2010 17:01:39 -0400
Message-Id: <1284670903-28475-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1284670903-28475-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1284670903-28475-1-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      |   21 +++++++++++++++------
 fs/nfs/nfs4_fs.h  |    2 +-
 fs/nfs/nfs4proc.c |   28 ++++------------------------
 3 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 17529b5..194676c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1084,8 +1084,8 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 	struct nfs_open_context *ctx;
 	struct iattr attr;
 	struct dentry *res = NULL;
+	struct inode *inode;
 	int open_flags;
-	int error;
 
 	dfprintk(VFS, "NFS: atomic_lookup(%s/%ld), %s\n",
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
@@ -1125,13 +1125,15 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 	}
 
 	/* Open the file on the server */
-	res = nfs4_atomic_open(dir, ctx, open_flags, &attr);
-	if (IS_ERR(res)) {
+	nfs_block_sillyrename(dentry->d_parent);
+	inode = nfs4_atomic_open(dir, ctx, open_flags, &attr);
+	if (IS_ERR(inode)) {
+		nfs_unblock_sillyrename(dentry->d_parent);
 		put_nfs_open_context(ctx);
-		error = PTR_ERR(res);
-		switch (error) {
+		switch (PTR_ERR(inode)) {
 			/* Make a negative dentry */
 			case -ENOENT:
+				d_add(dentry, NULL);
 				res = NULL;
 				goto out;
 			/* This turned out not to be a regular file */
@@ -1143,13 +1145,20 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 					goto no_open;
 			/* case -EINVAL: */
 			default:
+				res = ERR_CAST(inode);
 				goto out;
 		}
 	}
-	if (res != NULL)
+	res = d_add_unique(dentry, inode);
+	if (res != NULL) {
+		dput(ctx->path.dentry);
+		ctx->path.dentry = dget(res);
 		dentry = res;
+	}
 	nfs_intent_set_file(nd, ctx);
+	nfs_unblock_sillyrename(dentry->d_parent);
 out:
+	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	return res;
 no_open:
 	return nfs_lookup(dir, dentry, nd);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c5cc2a6..8e1f639 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -242,7 +242,7 @@ extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
-extern struct dentry *nfs4_atomic_open(struct inode *, struct nfs_open_context *, int, struct iattr *);
+extern struct inode *nfs4_atomic_open(struct inode *, struct nfs_open_context *, int, struct iattr *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 38c3bed..f8d41ee 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2024,37 +2024,17 @@ out_close:
 	return ret;
 }
 
-struct dentry *
+struct inode *
 nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
 {
-	struct dentry *dentry = ctx->path.dentry;
-	struct dentry *parent;
 	struct nfs4_state *state;
-	struct dentry *res;
 
-	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
-	nfs_block_sillyrename(parent);
 	state = nfs4_do_open(dir, &ctx->path, ctx->mode, open_flags, attr, ctx->cred);
-	if (IS_ERR(state)) {
-		if (PTR_ERR(state) == -ENOENT) {
-			d_add(dentry, NULL);
-			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-		}
-		nfs_unblock_sillyrename(parent);
-		return (struct dentry *)state;
-	}
-	res = d_add_unique(dentry, igrab(state->inode));
-	if (res != NULL) {
-		struct dentry *dummy = ctx->path.dentry;
-
-		ctx->path.dentry = dget(res);
-		dput(dummy);
-	}
+	if (IS_ERR(state))
+		return ERR_CAST(state);
 	ctx->state = state;
-	nfs_set_verifier(ctx->path.dentry, nfs_save_change_attribute(dir));
-	nfs_unblock_sillyrename(parent);
-	return res;
+	return igrab(state->inode);
 }
 
 int
-- 
1.7.2.3

