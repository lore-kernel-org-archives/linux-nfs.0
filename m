Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4891 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966427Ab3E2UFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 May 2013 16:05:31 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4: Move dentry instantiation into the NFSv4-specific atomic open code
Date: Wed, 29 May 2013 16:05:24 -0400
Message-Id: <1369857925-42068-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369857925-42068-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1369857925-42068-1-git-send-email-Trond.Myklebust@netapp.com>
 <1369857925-42068-2-git-send-email-Trond.Myklebust@netapp.com>
 <1369857925-42068-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      | 19 +++----------------
 fs/nfs/nfs4file.c |  1 -
 fs/nfs/nfs4proc.c | 19 +++++++++++++++----
 3 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index bf4e5f4..c662ff6 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1357,11 +1357,6 @@ static int nfs_finish_open(struct nfs_open_context *ctx,
 {
 	int err;
 
-	if (ctx->dentry != dentry) {
-		dput(ctx->dentry);
-		ctx->dentry = dget(dentry);
-	}
-
 	err = finish_open(file, dentry, do_open, opened);
 	if (err)
 		goto out;
@@ -1420,13 +1415,13 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 
 	nfs_block_sillyrename(dentry->d_parent);
 	inode = NFS_PROTO(dir)->open_context(dir, ctx, open_flags, &attr);
-	d_drop(dentry);
+	nfs_unblock_sillyrename(dentry->d_parent);
 	if (IS_ERR(inode)) {
-		nfs_unblock_sillyrename(dentry->d_parent);
 		put_nfs_open_context(ctx);
 		err = PTR_ERR(inode);
 		switch (err) {
 		case -ENOENT:
+			d_drop(dentry);
 			d_add(dentry, NULL);
 			break;
 		case -EISDIR:
@@ -1442,16 +1437,8 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		}
 		goto out;
 	}
-	res = d_add_unique(dentry, inode);
-	if (res != NULL)
-		dentry = res;
-
-	nfs_unblock_sillyrename(dentry->d_parent);
-	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-
-	err = nfs_finish_open(ctx, dentry, file, open_flags, opened);
 
-	dput(res);
+	err = nfs_finish_open(ctx, ctx->dentry, file, open_flags, opened);
 out:
 	return err;
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 13e6bb3..e5b804d 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -69,7 +69,6 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 			goto out_drop;
 		}
 	}
-	iput(inode);
 	if (inode != dentry->d_inode)
 		goto out_drop;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 57df6c9..3225149 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1964,6 +1964,7 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 {
 	struct nfs4_state_owner *sp = opendata->owner;
 	struct nfs_server *server = sp->so_server;
+	struct dentry *dentry;
 	struct nfs4_state *state;
 	unsigned int seq;
 	int ret;
@@ -1981,6 +1982,19 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 
+	dentry = opendata->dentry;
+	if (dentry->d_inode == NULL) {
+		/* FIXME: Is this d_drop() ever needed? */
+		d_drop(dentry);
+		dentry = d_add_unique(dentry, igrab(state->inode));
+		if (dentry != ctx->dentry) {
+			dput(ctx->dentry);
+			ctx->dentry = dget(dentry);
+		}
+		nfs_set_verifier(dentry,
+				nfs_save_change_attribute(opendata->dir->d_inode));
+	}
+
 	ret = nfs4_opendata_access(sp->so_cred, opendata, state, fmode, flags);
 	if (ret != 0)
 		goto out;
@@ -2444,7 +2458,7 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags
 	state = nfs4_do_open(dir, ctx, open_flags, attr);
 	if (IS_ERR(state))
 		return ERR_CAST(state);
-	return igrab(state->inode);
+	return state->inode;
 }
 
 static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
@@ -3050,13 +3064,10 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 
 	sattr->ia_mode &= ~current_umask();
 	state = nfs4_do_open(dir, ctx, flags, sattr);
-	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
 		goto out;
 	}
-	d_add(dentry, igrab(state->inode));
-	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 out:
 	put_nfs_open_context(ctx);
 	return status;
-- 
1.8.1.4

