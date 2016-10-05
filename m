Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Wed, 05 Oct 2016 17:15:31 +1100
Subject: [PATCH 1/3] NFSv4: add flock_context to open context
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147564813165.1201.1763939224234530957.stgit@noble>
In-Reply-To: <147564712849.1201.16474326551460993904.stgit@noble>
References: <147564712849.1201.16474326551460993904.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

An open file description (struct file) can have two possible lock contexts.

It can have a Posix lock context which will be different in each process
that has a fd on the file.
It can have a Flock context which will be the same in all processes.

When searching for a lock stateid to use, we need to consider both of these
contexts.

So add a new "flock_contex" to the "nfs_open_context" (of which there
is one for each open file description).

This flock_context does not need to be reference-counted (as we will
use the refcount for the primary lock_context), and will never be part
of a list of contexts.  So initilization is minimal.

When creating an open_context for a non-openning create call, we don't have
a 'struct file' to passing, so the lock context gets initialized with
a NULL owner, but this will never be used.

The flock_context is not used at all in this patch, that will come later.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/dir.c           |    6 +++---
 fs/nfs/inode.c         |   16 ++++++++++++++--
 fs/nfs/nfs4file.c      |    2 +-
 fs/nfs/nfs4proc.c      |    2 +-
 include/linux/nfs_fs.h |    3 ++-
 5 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 177fefb26c18..797dbaf1ebe4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1453,9 +1453,9 @@ static fmode_t flags_to_mode(int flags)
 	return res;
 }
 
-static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags)
+static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags, struct file *filp)
 {
-	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags));
+	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags), filp);
 }
 
 static int do_open(struct inode *inode, struct file *filp)
@@ -1540,7 +1540,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 			return finish_no_open(file, dentry);
 	}
 
-	ctx = create_nfs_open_context(dentry, open_flags);
+	ctx = create_nfs_open_context(dentry, open_flags, file);
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bf4ec5ecc97e..40e7b88f680d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -708,6 +708,14 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 	atomic_set(&l_ctx->io_count, 0);
 }
 
+static void nfs_init_flock_context(struct nfs_lock_context *l_ctx, struct file *filp)
+{
+	atomic_set(&l_ctx->count, 0);
+	l_ctx->lockowner.l_owner = filp;
+	l_ctx->lockowner.l_pid = 0;
+	atomic_set(&l_ctx->io_count, 0);
+}
+
 static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx)
 {
 	struct nfs_lock_context *head = &ctx->lock_context;
@@ -799,7 +807,9 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 }
 EXPORT_SYMBOL_GPL(nfs_close_context);
 
-struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode)
+struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
+						fmode_t f_mode,
+						struct file *filp)
 {
 	struct nfs_open_context *ctx;
 	struct rpc_cred *cred = rpc_lookup_cred();
@@ -819,7 +829,9 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f
 	ctx->flags = 0;
 	ctx->error = 0;
 	nfs_init_lock_context(&ctx->lock_context);
+	nfs_init_flock_context(&ctx->flock_context, filp);
 	ctx->lock_context.open_context = ctx;
+	ctx->flock_context.open_context = ctx;
 	INIT_LIST_HEAD(&ctx->list);
 	ctx->mdsthreshold = NULL;
 	return ctx;
@@ -942,7 +954,7 @@ int nfs_open(struct inode *inode, struct file *filp)
 {
 	struct nfs_open_context *ctx;
 
-	ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
+	ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode, filp);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	nfs_file_set_open_context(filp, ctx);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index d085ad794884..13b899b9347e 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -57,7 +57,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	parent = dget_parent(dentry);
 	dir = d_inode(parent);
 
-	ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
+	ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode, filp);
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a9dec32ba9ba..a8f8b4720c90 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3793,7 +3793,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	struct nfs4_state *state;
 	int status = 0;
 
-	ctx = alloc_nfs_open_context(dentry, FMODE_READ);
+	ctx = alloc_nfs_open_context(dentry, FMODE_READ, NULL);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 810124b33327..a9fb754fff34 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -71,6 +71,7 @@ struct nfs_lock_context {
 struct nfs4_state;
 struct nfs_open_context {
 	struct nfs_lock_context lock_context;
+	struct nfs_lock_context flock_context;
 	struct dentry *dentry;
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
@@ -358,7 +359,7 @@ extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
-extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode);
+extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode, struct file *filp);
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
 extern void nfs_file_clear_open_context(struct file *flip);
