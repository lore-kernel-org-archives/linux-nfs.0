Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18807 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754642Ab3IZVpT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:19 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4: Honour the 'opened' parameter in the atomic_open() filesystem method
Date: Thu, 26 Sep 2013 17:44:59 -0400
Message-ID: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Determine if we've created a new file by examining the directory change
attribute and/or the O_EXCL flag.

This fixes a regression when doing a non-exclusive create of a new file.
If the FILE_CREATED flag is not set, the atomic_open() command will
perform full file access permissions checks instead of just checking
for MAY_OPEN.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c            |  2 +-
 fs/nfs/nfs4file.c       |  3 ++-
 fs/nfs/nfs4proc.c       | 26 +++++++++++++++++++-------
 include/linux/nfs_xdr.h |  3 ++-
 4 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 854a8f0..02b0df7 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1458,7 +1458,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 
 	trace_nfs_atomic_open_enter(dir, ctx, open_flags);
 	nfs_block_sillyrename(dentry->d_parent);
-	inode = NFS_PROTO(dir)->open_context(dir, ctx, open_flags, &attr);
+	inode = NFS_PROTO(dir)->open_context(dir, ctx, open_flags, &attr, opened);
 	nfs_unblock_sillyrename(dentry->d_parent);
 	if (IS_ERR(inode)) {
 		err = PTR_ERR(inode);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index e5b804d..77efaf1 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -19,6 +19,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	struct inode *dir;
 	unsigned openflags = filp->f_flags;
 	struct iattr attr;
+	int opened = 0;
 	int err;
 
 	/*
@@ -55,7 +56,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 		nfs_wb_all(inode);
 	}
 
-	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, &attr);
+	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, &attr, &opened);
 	if (IS_ERR(inode)) {
 		err = PTR_ERR(inode);
 		switch (err) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 989bb9d..488ef9b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -912,6 +912,7 @@ struct nfs4_opendata {
 	struct iattr attrs;
 	unsigned long timestamp;
 	unsigned int rpc_done : 1;
+	unsigned int file_created : 1;
 	unsigned int is_recover : 1;
 	int rpc_status;
 	int cancelled;
@@ -1946,8 +1947,13 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 
 	nfs_fattr_map_and_free_names(server, &data->f_attr);
 
-	if (o_arg->open_flags & O_CREAT)
+	if (o_arg->open_flags & O_CREAT) {
 		update_changeattr(dir, &o_res->cinfo);
+		if (o_arg->open_flags & O_EXCL)
+			data->file_created = 1;
+		else if (o_res->cinfo.before != o_res->cinfo.after)
+			data->file_created = 1;
+	}
 	if ((o_res->rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) == 0)
 		server->caps &= ~NFS_CAP_POSIX_LOCK;
 	if(o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
@@ -2191,7 +2197,8 @@ static int _nfs4_do_open(struct inode *dir,
 			struct nfs_open_context *ctx,
 			int flags,
 			struct iattr *sattr,
-			struct nfs4_label *label)
+			struct nfs4_label *label,
+			int *opened)
 {
 	struct nfs4_state_owner  *sp;
 	struct nfs4_state     *state = NULL;
@@ -2261,6 +2268,8 @@ static int _nfs4_do_open(struct inode *dir,
 			nfs_setsecurity(state->inode, opendata->o_res.f_attr, olabel);
 		}
 	}
+	if (opendata->file_created)
+		*opened |= FILE_CREATED;
 
 	if (pnfs_use_threshold(ctx_th, opendata->f_attr.mdsthreshold, server))
 		*ctx_th = opendata->f_attr.mdsthreshold;
@@ -2289,7 +2298,8 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 					struct nfs_open_context *ctx,
 					int flags,
 					struct iattr *sattr,
-					struct nfs4_label *label)
+					struct nfs4_label *label,
+					int *opened)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs4_exception exception = { };
@@ -2297,7 +2307,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 	int status;
 
 	do {
-		status = _nfs4_do_open(dir, ctx, flags, sattr, label);
+		status = _nfs4_do_open(dir, ctx, flags, sattr, label, opened);
 		res = ctx->state;
 		trace_nfs4_open_file(ctx, flags, status);
 		if (status == 0)
@@ -2659,7 +2669,8 @@ out:
 }
 
 static struct inode *
-nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
+nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx,
+		int open_flags, struct iattr *attr, int *opened)
 {
 	struct nfs4_state *state;
 	struct nfs4_label l = {0, 0, 0, NULL}, *label = NULL;
@@ -2667,7 +2678,7 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags
 	label = nfs4_label_init_security(dir, ctx->dentry, attr, &l);
 
 	/* Protect against concurrent sillydeletes */
-	state = nfs4_do_open(dir, ctx, open_flags, attr, label);
+	state = nfs4_do_open(dir, ctx, open_flags, attr, label, opened);
 
 	nfs4_label_release_security(label);
 
@@ -3332,6 +3343,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	struct nfs4_label l, *ilabel = NULL;
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
+	int opened = 0;
 	int status = 0;
 
 	ctx = alloc_nfs_open_context(dentry, FMODE_READ);
@@ -3341,7 +3353,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	ilabel = nfs4_label_init_security(dir, dentry, sattr, &l);
 
 	sattr->ia_mode &= ~current_umask();
-	state = nfs4_do_open(dir, ctx, flags, sattr, ilabel);
+	state = nfs4_do_open(dir, ctx, flags, sattr, ilabel, &opened);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
 		goto out;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 01fd84b..49f52c8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1455,7 +1455,8 @@ struct nfs_rpc_ops {
 	struct inode * (*open_context) (struct inode *dir,
 				struct nfs_open_context *ctx,
 				int open_flags,
-				struct iattr *iattr);
+				struct iattr *iattr,
+				int *);
 	int (*have_delegation)(struct inode *, fmode_t);
 	int (*return_delegation)(struct inode *);
 	struct nfs_client *(*alloc_client) (const struct nfs_client_initdata *);
-- 
1.8.3.1

