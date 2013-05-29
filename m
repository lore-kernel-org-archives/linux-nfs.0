Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4891 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966380Ab3E2UF3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 May 2013 16:05:29 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4: Cleanup: pass the nfs_open_context to nfs4_do_open
Date: Wed, 29 May 2013 16:05:22 -0400
Message-Id: <1369857925-42068-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369857925-42068-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1369857925-42068-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All the callers have an open_context at this point, and since we always
need one in order to do state recovery, it makes sense to use it as the
basis for the nfs4_do_open() call.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0468d50..9fecb2b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1996,18 +1996,19 @@ out:
  * Returns a referenced nfs4_state
  */
 static int _nfs4_do_open(struct inode *dir,
-			struct dentry *dentry,
-			fmode_t fmode,
+			struct nfs_open_context *ctx,
 			int flags,
 			struct iattr *sattr,
-			struct rpc_cred *cred,
-			struct nfs4_state **res,
-			struct nfs4_threshold **ctx_th)
+			struct nfs4_state **res)
 {
 	struct nfs4_state_owner  *sp;
 	struct nfs4_state     *state = NULL;
 	struct nfs_server       *server = NFS_SERVER(dir);
 	struct nfs4_opendata *opendata;
+	struct dentry *dentry = ctx->dentry;
+	struct rpc_cred *cred = ctx->cred;
+	struct nfs4_threshold **ctx_th = &ctx->mdsthreshold;
+	fmode_t fmode = ctx->mode & (FMODE_READ|FMODE_WRITE|FMODE_EXEC);
 	enum open_claim_type4 claim = NFS4_OPEN_CLAIM_NULL;
 	int status;
 
@@ -2079,22 +2080,17 @@ out_err:
 
 
 static struct nfs4_state *nfs4_do_open(struct inode *dir,
-					struct dentry *dentry,
-					fmode_t fmode,
+					struct nfs_open_context *ctx,
 					int flags,
-					struct iattr *sattr,
-					struct rpc_cred *cred,
-					struct nfs4_threshold **ctx_th)
+					struct iattr *sattr)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs4_exception exception = { };
 	struct nfs4_state *res;
 	int status;
 
-	fmode &= FMODE_READ|FMODE_WRITE|FMODE_EXEC;
 	do {
-		status = _nfs4_do_open(dir, dentry, fmode, flags, sattr, cred,
-				       &res, ctx_th);
+		status = _nfs4_do_open(dir, ctx, flags, sattr, &res);
 		if (status == 0)
 			break;
 		/* NOTE: BAD_SEQID means the server and client disagree about the
@@ -2446,8 +2442,7 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags
 	struct nfs4_state *state;
 
 	/* Protect against concurrent sillydeletes */
-	state = nfs4_do_open(dir, ctx->dentry, ctx->mode, open_flags, attr,
-			     ctx->cred, &ctx->mdsthreshold);
+	state = nfs4_do_open(dir, ctx, open_flags, attr);
 	if (IS_ERR(state))
 		return ERR_CAST(state);
 	ctx->state = state;
@@ -3056,9 +3051,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		return PTR_ERR(ctx);
 
 	sattr->ia_mode &= ~current_umask();
-	state = nfs4_do_open(dir, dentry, ctx->mode,
-			flags, sattr, ctx->cred,
-			&ctx->mdsthreshold);
+	state = nfs4_do_open(dir, ctx, flags, sattr);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
-- 
1.8.1.4

