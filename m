Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42499 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754164Ab0IPVCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:02:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, hch@infradead.org
Subject: [PATCH 4/6] NFSv4: Further cleanups for nfs4_open_revalidate()
Date: Thu, 16 Sep 2010 17:01:41 -0400
Message-Id: <1284670903-28475-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1284670903-28475-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1284670903-28475-1-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-2-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-3-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      |   32 ++++++++++++++++++++++++++------
 fs/nfs/nfs4_fs.h  |    1 -
 fs/nfs/nfs4proc.c |   28 ----------------------------
 3 files changed, 26 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 196775c..dc93d35 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1204,16 +1204,36 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	 * operations that change the directory. We therefore save the
 	 * change attribute *before* we do the RPC call.
 	 */
-	ret = nfs4_open_revalidate(dir, ctx, openflags);
-	if (ret == 1)
+	inode = nfs4_atomic_open(dir, ctx, openflags, NULL);
+	if (IS_ERR(inode)) {
+		ret = PTR_ERR(inode);
+		switch (ret) {
+		case -EPERM:
+		case -EACCES:
+		case -EDQUOT:
+		case -ENOSPC:
+		case -EROFS:
+			goto out_put_ctx;
+		default:
+			goto out_drop;
+		}
+	}
+	iput(inode);
+	if (inode == dentry->d_inode) {
+		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 		nfs_intent_set_file(nd, ctx);
-	else
-		put_nfs_open_context(ctx);
+	} else
+		goto out_drop;
 out:
 	dput(parent);
-	if (!ret)
-		d_drop(dentry);
 	return ret;
+out_drop:
+	d_drop(dentry);
+	ret = 0;
+out_put_ctx:
+	put_nfs_open_context(ctx);
+	goto out;
+
 no_open_dput:
 	dput(parent);
 no_open:
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 76ec1c6..6cf12ba 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -243,7 +243,6 @@ extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
 extern struct inode *nfs4_atomic_open(struct inode *, struct nfs_open_context *, int, struct iattr *);
-extern int nfs4_open_revalidate(struct inode *, struct nfs_open_context *, int);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b476246..83c5ef6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2037,34 +2037,6 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags
 	return igrab(state->inode);
 }
 
-int
-nfs4_open_revalidate(struct inode *dir, struct nfs_open_context *ctx, int openflags)
-{
-	struct nfs4_state *state;
-
-	state = nfs4_do_open(dir, &ctx->path, ctx->mode, openflags, NULL, ctx->cred);
-	if (IS_ERR(state)) {
-		switch (PTR_ERR(state)) {
-			case -EPERM:
-			case -EACCES:
-			case -EDQUOT:
-			case -ENOSPC:
-			case -EROFS:
-				return PTR_ERR(state);
-			default:
-				goto out_drop;
-		}
-	}
-	ctx->state = state;
-	if (state->inode == ctx->path.dentry->d_inode) {
-		nfs_set_verifier(ctx->path.dentry, nfs_save_change_attribute(dir));
-		return 1;
-	}
-out_drop:
-	d_drop(ctx->path.dentry);
-	return 0;
-}
-
 static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 {
 	if (ctx->state == NULL)
-- 
1.7.2.3

