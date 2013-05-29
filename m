Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4891 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966427Ab3E2UFa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 May 2013 16:05:30 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFSv4: Refactor _nfs4_open_and_get_state to set ctx->state
Date: Wed, 29 May 2013 16:05:23 -0400
Message-Id: <1369857925-42068-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369857925-42068-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1369857925-42068-1-git-send-email-Trond.Myklebust@netapp.com>
 <1369857925-42068-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of having the callers set ctx->state, do it inside
_nfs4_open_and_get_state.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9fecb2b..57df6c9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1960,7 +1960,7 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata, struct
 static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 		fmode_t fmode,
 		int flags,
-		struct nfs4_state **res)
+		struct nfs_open_context *ctx)
 {
 	struct nfs4_state_owner *sp = opendata->owner;
 	struct nfs_server *server = sp->so_server;
@@ -1985,9 +1985,9 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	if (ret != 0)
 		goto out;
 
+	ctx->state = state;
 	if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 		nfs4_schedule_stateid_recovery(server, state);
-	*res = state;
 out:
 	return ret;
 }
@@ -1998,8 +1998,7 @@ out:
 static int _nfs4_do_open(struct inode *dir,
 			struct nfs_open_context *ctx,
 			int flags,
-			struct iattr *sattr,
-			struct nfs4_state **res)
+			struct iattr *sattr)
 {
 	struct nfs4_state_owner  *sp;
 	struct nfs4_state     *state = NULL;
@@ -2041,9 +2040,10 @@ static int _nfs4_do_open(struct inode *dir,
 	if (dentry->d_inode != NULL)
 		opendata->state = nfs4_get_open_state(dentry->d_inode, sp);
 
-	status = _nfs4_open_and_get_state(opendata, fmode, flags, &state);
+	status = _nfs4_open_and_get_state(opendata, fmode, flags, ctx);
 	if (status != 0)
 		goto err_opendata_put;
+	state = ctx->state;
 
 	if ((opendata->o_arg.open_flags & O_EXCL) &&
 	    (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
@@ -2066,7 +2066,6 @@ static int _nfs4_do_open(struct inode *dir,
 
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
-	*res = state;
 	return 0;
 err_opendata_put:
 	kfree(opendata->f_attr.mdsthreshold);
@@ -2074,7 +2073,6 @@ err_opendata_put:
 err_put_state_owner:
 	nfs4_put_state_owner(sp);
 out_err:
-	*res = NULL;
 	return status;
 }
 
@@ -2090,7 +2088,8 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 	int status;
 
 	do {
-		status = _nfs4_do_open(dir, ctx, flags, sattr, &res);
+		status = _nfs4_do_open(dir, ctx, flags, sattr);
+		res = ctx->state;
 		if (status == 0)
 			break;
 		/* NOTE: BAD_SEQID means the server and client disagree about the
@@ -2445,7 +2444,6 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags
 	state = nfs4_do_open(dir, ctx, open_flags, attr);
 	if (IS_ERR(state))
 		return ERR_CAST(state);
-	ctx->state = state;
 	return igrab(state->inode);
 }
 
@@ -3059,7 +3057,6 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	}
 	d_add(dentry, igrab(state->inode));
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-	ctx->state = state;
 out:
 	put_nfs_open_context(ctx);
 	return status;
-- 
1.8.1.4

