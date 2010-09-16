Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29752 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984Ab0IPVCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:02:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, hch@infradead.org
Subject: [PATCH 3/6] NFSv4: Clean up nfs4_open_revalidate
Date: Thu, 16 Sep 2010 17:01:40 -0400
Message-Id: <1284670903-28475-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1284670903-28475-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1284670903-28475-1-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-2-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Remove references to 'struct nameidata' from the low-level open_revalidate
code, and replace them with a struct nfs_open_context which will be
correctly initialised upon success.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      |   11 ++++++++++-
 fs/nfs/nfs4_fs.h  |    2 +-
 fs/nfs/nfs4proc.c |   23 ++++++-----------------
 3 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 194676c..196775c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1169,6 +1169,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	struct dentry *parent = NULL;
 	struct inode *inode = dentry->d_inode;
 	struct inode *dir;
+	struct nfs_open_context *ctx;
 	int openflags, ret = 0;
 
 	if (!is_atomic_open(nd) || d_mountpoint(dentry))
@@ -1194,12 +1195,20 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	/* We can't create new files, or truncate existing ones here */
 	openflags &= ~(O_CREAT|O_EXCL|O_TRUNC);
 
+	ctx = nameidata_to_nfs_open_context(dentry, nd);
+	ret = PTR_ERR(ctx);
+	if (IS_ERR(ctx))
+		goto out;
 	/*
 	 * Note: we're not holding inode->i_mutex and so may be racing with
 	 * operations that change the directory. We therefore save the
 	 * change attribute *before* we do the RPC call.
 	 */
-	ret = nfs4_open_revalidate(dir, dentry, openflags, nd);
+	ret = nfs4_open_revalidate(dir, ctx, openflags);
+	if (ret == 1)
+		nfs_intent_set_file(nd, ctx);
+	else
+		put_nfs_open_context(ctx);
 out:
 	dput(parent);
 	if (!ret)
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 8e1f639..76ec1c6 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -243,7 +243,7 @@ extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
 extern struct inode *nfs4_atomic_open(struct inode *, struct nfs_open_context *, int, struct iattr *);
-extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
+extern int nfs4_open_revalidate(struct inode *, struct nfs_open_context *, int);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f8d41ee..b476246 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2038,21 +2038,11 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags
 }
 
 int
-nfs4_open_revalidate(struct inode *dir, struct dentry *dentry, int openflags, struct nameidata *nd)
+nfs4_open_revalidate(struct inode *dir, struct nfs_open_context *ctx, int openflags)
 {
-	struct path path = {
-		.mnt = nd->path.mnt,
-		.dentry = dentry,
-	};
-	struct rpc_cred *cred;
 	struct nfs4_state *state;
-	fmode_t fmode = openflags & (FMODE_READ | FMODE_WRITE);
 
-	cred = rpc_lookup_cred();
-	if (IS_ERR(cred))
-		return PTR_ERR(cred);
-	state = nfs4_do_open(dir, &path, fmode, openflags, NULL, cred);
-	put_rpccred(cred);
+	state = nfs4_do_open(dir, &ctx->path, ctx->mode, openflags, NULL, ctx->cred);
 	if (IS_ERR(state)) {
 		switch (PTR_ERR(state)) {
 			case -EPERM:
@@ -2065,14 +2055,13 @@ nfs4_open_revalidate(struct inode *dir, struct dentry *dentry, int openflags, st
 				goto out_drop;
 		}
 	}
-	if (state->inode == dentry->d_inode) {
-		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-		nfs4_intent_set_file(nd, &path, state, fmode);
+	ctx->state = state;
+	if (state->inode == ctx->path.dentry->d_inode) {
+		nfs_set_verifier(ctx->path.dentry, nfs_save_change_attribute(dir));
 		return 1;
 	}
-	nfs4_close_sync(&path, state, fmode);
 out_drop:
-	d_drop(dentry);
+	d_drop(ctx->path.dentry);
 	return 0;
 }
 
-- 
1.7.2.3

