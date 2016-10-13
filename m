Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Thu, 13 Oct 2016 15:26:47 +1100
Subject: [PATCH 2/6] NFSv4: add flock_owner to open context
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147633280739.766.12741993527873062860.stgit@noble>
In-Reply-To: <147633263771.766.17853370901003798934.stgit@noble>
References: <147633263771.766.17853370901003798934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

An open file description (struct file) in a given process can be
associated with two different lock owners.

It can have a Posix lock owner which will be different in each process
that has a fd on the file.
It can have a Flock owner which will be the same in all processes.

When searching for a lock stateid to use, we need to consider both of these
owners

So add a new "flock_owner" to the "nfs_open_context" (of which there
is one for each open file description).

This flock_owner does not need to be reference-counted as there is a
1-1 relation between 'struct file' and nfs open contexts,
and it will never be part of a list of contexts.  So there is no need
for a 'flock_context' - just the owner is enough.

The io_count included in the (Posix) lock_context provides no
guarantee that all read-aheads that could use the state have
completed, so not supporting it for flock locks in not a serious
problem.  Synchronization between flock and read-ahead can be added
later if needed.

When creating an open_context for a non-openning create call, we don't have
a 'struct file' to pass in, so the lock context gets initialized with
a NULL owner, but this will never be used.

The flock_owner is not used at all in this patch, that will come later.

Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/dir.c           |    6 +++---
 fs/nfs/inode.c         |    7 +++++--
 fs/nfs/nfs4file.c      |    2 +-
 fs/nfs/nfs4proc.c      |    2 +-
 include/linux/nfs_fs.h |    3 ++-
 5 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5f1af4cd1a33..f1ecfcc632eb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1467,9 +1467,9 @@ static fmode_t flags_to_mode(int flags)
 	return res;
 }
 
-static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags)
+static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, int open_flags, struct file *filp)
 {
-	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags));
+	return alloc_nfs_open_context(dentry, flags_to_mode(open_flags), filp);
 }
 
 static int do_open(struct inode *inode, struct file *filp)
@@ -1554,7 +1554,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 			return finish_no_open(file, dentry);
 	}
 
-	ctx = create_nfs_open_context(dentry, open_flags);
+	ctx = create_nfs_open_context(dentry, open_flags, file);
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1752fc7c0024..2138027eaba9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -796,7 +796,9 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync)
 }
 EXPORT_SYMBOL_GPL(nfs_close_context);
 
-struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode)
+struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
+						fmode_t f_mode,
+						struct file *filp)
 {
 	struct nfs_open_context *ctx;
 	struct rpc_cred *cred = rpc_lookup_cred();
@@ -815,6 +817,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f
 	ctx->mode = f_mode;
 	ctx->flags = 0;
 	ctx->error = 0;
+	ctx->flock_owner = (fl_owner_t)filp;
 	nfs_init_lock_context(&ctx->lock_context);
 	ctx->lock_context.open_context = ctx;
 	INIT_LIST_HEAD(&ctx->list);
@@ -939,7 +942,7 @@ int nfs_open(struct inode *inode, struct file *filp)
 {
 	struct nfs_open_context *ctx;
 
-	ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
+	ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode, filp);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	nfs_file_set_open_context(filp, ctx);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 89a77950e0b0..0efba77789b9 100644
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
index 3c164f9a3983..3d85ab7b56bf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3957,7 +3957,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	struct nfs4_state *state;
 	int status = 0;
 
-	ctx = alloc_nfs_open_context(dentry, FMODE_READ);
+	ctx = alloc_nfs_open_context(dentry, FMODE_READ, NULL);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index bf8a713c45b4..0adb02c4744d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -70,6 +70,7 @@ struct nfs_lock_context {
 struct nfs4_state;
 struct nfs_open_context {
 	struct nfs_lock_context lock_context;
+	fl_owner_t flock_owner;
 	struct dentry *dentry;
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
@@ -357,7 +358,7 @@ extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
-extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode);
+extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode, struct file *filp);
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
 extern void nfs_file_clear_open_context(struct file *flip);
