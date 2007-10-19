From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] NFS client fixes for 2.6.23++
Date: Fri, 19 Oct 2007 17:23:13 -0400
Message-ID: <1192828993.7466.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S967037AbXJSVXY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/delegation.c    |    3 +-
 fs/nfs/dir.c           |   14 +++++-
 fs/nfs/file.c          |    2 +-
 fs/nfs/inode.c         |   25 +++++++++--
 fs/nfs/nfs4_fs.h       |    3 +-
 fs/nfs/nfs4proc.c      |   19 ++++++--
 fs/nfs/nfs4state.c     |   14 +++++-
 fs/nfs/unlink.c        |  114 +++++++++++++++++++++++++++++++++++++++++------
 fs/nfs/write.c         |   17 +++++--
 include/linux/nfs_fs.h |    8 +++
 10 files changed, 183 insertions(+), 36 deletions(-)

commit 603c83da19cf42d0f94022ac2fa389a431e32b84
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 18 19:59:20 2007 -0400

    NFSv4: Fix an rpc_cred reference leakage in fs/nfs/delegation.c
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a49c3c7736a2e77931dabc5bc4a83fb4b2da013e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 18 18:03:27 2007 -0400

    NFSv4: Ensure that we wait for the CLOSE request to complete
    
    Otherwise, we do end up breaking close-to-open semantics. We also end up
    breaking some of the silly-rename tests in Connectathon on some setups.
    
    Please refer to the bug-report at
    	http://bugzilla.linux-nfs.org/show_bug.cgi?id=150
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 565277f63c616e11c37309a1e98c052d18ebbb55
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 15 18:17:53 2007 -0400

    NFS: Fix a race in sillyrename
    
    lookup() and sillyrename() can race one another because the sillyrename()
    completion cannot take the parent directory's inode->i_mutex since the
    latter may be held by whoever is calling dput().
    
    We therefore have little option but to add extra locking to ensure that
    nfs_lookup() and nfs_atomic_open() do not race with the sillyrename
    completion.
    If somebody has looked up the sillyrenamed file in the meantime, we just
    transfer the sillydelete information to the new dentry.
    
    Please refer to the bug-report at
    	http://bugzilla.linux-nfs.org/show_bug.cgi?id=150
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 61e930a904966cc37e0a3404276f0b73037e57ca
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 18 17:08:05 2007 -0400

    NFS: Fix a writeback race...
    
    This patch fixes a regression that was introduced by commit
    44dd151d5c21234cc534c47d7382f5c28c3143cd
    
    We cannot zero the user page in nfs_mark_uptodate() any more, since
    
      a) We'd be modifying the page without holding the page lock
      b) We can race with other updates of the page, most notably
         because of the call to nfs_wb_page() in nfs_writepage_setup().
    
    Instead, we do the zeroing in nfs_update_request() if we see that we're
    creating a request that might potentially be marked as up to date.
    
    Thanks to Olivier Paquet for reporting the bug and providing a test-case.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index af8b235..11833f4 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -168,7 +168,8 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	spin_unlock(&inode->i_lock);
 
 	spin_unlock(&clp->cl_lock);
-	kfree(delegation);
+	if (delegation != NULL)
+		nfs_free_delegation(delegation);
 	return status;
 }
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8ec7fbd..3533453 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -562,6 +562,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	nfs_fattr_init(&fattr);
 	desc->entry = &my_entry;
 
+	nfs_block_sillyrename(dentry);
 	while(!desc->entry->eof) {
 		res = readdir_search_pagecache(desc);
 
@@ -592,6 +593,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 			break;
 		}
 	}
+	nfs_unblock_sillyrename(dentry);
 	unlock_kernel();
 	if (res > 0)
 		res = 0;
@@ -866,6 +868,7 @@ struct dentry_operations nfs_dentry_operations = {
 static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
 {
 	struct dentry *res;
+	struct dentry *parent;
 	struct inode *inode = NULL;
 	int error;
 	struct nfs_fh fhandle;
@@ -894,26 +897,31 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 		goto out_unlock;
 	}
 
+	parent = dentry->d_parent;
+	/* Protect against concurrent sillydeletes */
+	nfs_block_sillyrename(parent);
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
 	if (error == -ENOENT)
 		goto no_entry;
 	if (error < 0) {
 		res = ERR_PTR(error);
-		goto out_unlock;
+		goto out_unblock_sillyrename;
 	}
 	inode = nfs_fhget(dentry->d_sb, &fhandle, &fattr);
 	res = (struct dentry *)inode;
 	if (IS_ERR(res))
-		goto out_unlock;
+		goto out_unblock_sillyrename;
 
 no_entry:
 	res = d_materialise_unique(dentry, inode);
 	if (res != NULL) {
 		if (IS_ERR(res))
-			goto out_unlock;
+			goto out_unblock_sillyrename;
 		dentry = res;
 	}
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+out_unblock_sillyrename:
+	nfs_unblock_sillyrename(parent);
 out_unlock:
 	unlock_kernel();
 out:
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d29f90d..b3bb89f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -131,7 +131,7 @@ nfs_file_release(struct inode *inode, struct file *filp)
 {
 	/* Ensure that dirty pages are flushed out with the right creds */
 	if (filp->f_mode & FMODE_WRITE)
-		filemap_fdatawrite(filp->f_mapping);
+		nfs_wb_all(filp->f_path.dentry->d_inode);
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
 	return NFS_PROTO(inode)->file_release(inode, filp);
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6d2f2a3..db5d96d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -514,7 +514,7 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 	return ctx;
 }
 
-void put_nfs_open_context(struct nfs_open_context *ctx)
+static void __put_nfs_open_context(struct nfs_open_context *ctx, int wait)
 {
 	struct inode *inode = ctx->path.dentry->d_inode;
 
@@ -522,8 +522,12 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
 		return;
 	list_del(&ctx->list);
 	spin_unlock(&inode->i_lock);
-	if (ctx->state != NULL)
-		nfs4_close_state(&ctx->path, ctx->state, ctx->mode);
+	if (ctx->state != NULL) {
+		if (wait)
+			nfs4_close_sync(&ctx->path, ctx->state, ctx->mode);
+		else
+			nfs4_close_state(&ctx->path, ctx->state, ctx->mode);
+	}
 	if (ctx->cred != NULL)
 		put_rpccred(ctx->cred);
 	dput(ctx->path.dentry);
@@ -531,6 +535,16 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
 	kfree(ctx);
 }
 
+void put_nfs_open_context(struct nfs_open_context *ctx)
+{
+	__put_nfs_open_context(ctx, 0);
+}
+
+static void put_nfs_open_context_sync(struct nfs_open_context *ctx)
+{
+	__put_nfs_open_context(ctx, 1);
+}
+
 /*
  * Ensure that mmap has a recent RPC credential for use when writing out
  * shared pages
@@ -577,7 +591,7 @@ static void nfs_file_clear_open_context(struct file *filp)
 		spin_lock(&inode->i_lock);
 		list_move_tail(&ctx->list, &NFS_I(inode)->open_files);
 		spin_unlock(&inode->i_lock);
-		put_nfs_open_context(ctx);
+		put_nfs_open_context_sync(ctx);
 	}
 }
 
@@ -1169,6 +1183,9 @@ static void init_once(struct kmem_cache * cachep, void *foo)
 	INIT_RADIX_TREE(&nfsi->nfs_page_tree, GFP_ATOMIC);
 	nfsi->ncommit = 0;
 	nfsi->npages = 0;
+	atomic_set(&nfsi->silly_count, 1);
+	INIT_HLIST_HEAD(&nfsi->silly_list);
+	init_waitqueue_head(&nfsi->waitqueue);
 	nfs4_init_once(nfsi);
 }
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d2802b1..a4e3b96 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -178,7 +178,7 @@ extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struc
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
-extern int nfs4_do_close(struct path *path, struct nfs4_state *state);
+extern int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
@@ -209,6 +209,7 @@ extern void nfs4_drop_state_owner(struct nfs4_state_owner *);
 extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
 extern void nfs4_put_open_state(struct nfs4_state *);
 extern void nfs4_close_state(struct path *, struct nfs4_state *, mode_t);
+extern void nfs4_close_sync(struct path *, struct nfs4_state *, mode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, mode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cb99fd9..f03d9d5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1305,7 +1305,7 @@ static const struct rpc_call_ops nfs4_close_ops = {
  *
  * NOTE: Caller must be holding the sp->so_owner semaphore!
  */
-int nfs4_do_close(struct path *path, struct nfs4_state *state)
+int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_closedata *calldata;
@@ -1333,8 +1333,11 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state)
 	task = rpc_run_task(server->client, RPC_TASK_ASYNC, &nfs4_close_ops, calldata);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
+	status = 0;
+	if (wait)
+		status = rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
-	return 0;
+	return status;
 out_free_calldata:
 	kfree(calldata);
 out:
@@ -1365,13 +1368,14 @@ static int nfs4_intent_set_file(struct nameidata *nd, struct path *path, struct
 	}
 	ret = PTR_ERR(filp);
 out_close:
-	nfs4_close_state(path, state, nd->intent.open.flags);
+	nfs4_close_sync(path, state, nd->intent.open.flags);
 	return ret;
 }
 
 struct dentry *
 nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 {
+	struct dentry *parent;
 	struct path path = {
 		.mnt = nd->mnt,
 		.dentry = dentry,
@@ -1394,6 +1398,9 @@ nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 	cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
 	if (IS_ERR(cred))
 		return (struct dentry *)cred;
+	parent = dentry->d_parent;
+	/* Protect against concurrent sillydeletes */
+	nfs_block_sillyrename(parent);
 	state = nfs4_do_open(dir, &path, nd->intent.open.flags, &attr, cred);
 	put_rpccred(cred);
 	if (IS_ERR(state)) {
@@ -1401,12 +1408,14 @@ nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 			d_add(dentry, NULL);
 			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 		}
+		nfs_unblock_sillyrename(parent);
 		return (struct dentry *)state;
 	}
 	res = d_add_unique(dentry, igrab(state->inode));
 	if (res != NULL)
 		path.dentry = res;
 	nfs_set_verifier(path.dentry, nfs_save_change_attribute(dir));
+	nfs_unblock_sillyrename(parent);
 	nfs4_intent_set_file(nd, &path, state);
 	return res;
 }
@@ -1444,7 +1453,7 @@ nfs4_open_revalidate(struct inode *dir, struct dentry *dentry, int openflags, st
 		nfs4_intent_set_file(nd, &path, state);
 		return 1;
 	}
-	nfs4_close_state(&path, state, openflags);
+	nfs4_close_sync(&path, state, openflags);
 out_drop:
 	d_drop(dentry);
 	return 0;
@@ -1898,7 +1907,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	if (status == 0 && (nd->flags & LOOKUP_OPEN) != 0)
 		status = nfs4_intent_set_file(nd, &path, state);
 	else
-		nfs4_close_state(&path, state, flags);
+		nfs4_close_sync(&path, state, flags);
 out:
 	return status;
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index bfb3626..23a9a36 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -425,7 +425,7 @@ void nfs4_put_open_state(struct nfs4_state *state)
 /*
  * Close the current file.
  */
-void nfs4_close_state(struct path *path, struct nfs4_state *state, mode_t mode)
+static void __nfs4_close(struct path *path, struct nfs4_state *state, mode_t mode, int wait)
 {
 	struct nfs4_state_owner *owner = state->owner;
 	int call_close = 0;
@@ -466,7 +466,17 @@ void nfs4_close_state(struct path *path, struct nfs4_state *state, mode_t mode)
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
 	} else
-		nfs4_do_close(path, state);
+		nfs4_do_close(path, state, wait);
+}
+
+void nfs4_close_state(struct path *path, struct nfs4_state *state, mode_t mode)
+{
+	__nfs4_close(path, state, mode, 0);
+}
+
+void nfs4_close_sync(struct path *path, struct nfs4_state *state, mode_t mode)
+{
+	__nfs4_close(path, state, mode, 1);
 }
 
 /*
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 1aed850..6ecd46c 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -14,6 +14,7 @@
 
 
 struct nfs_unlinkdata {
+	struct hlist_node list;
 	struct nfs_removeargs args;
 	struct nfs_removeres res;
 	struct inode *dir;
@@ -52,6 +53,20 @@ static int nfs_copy_dname(struct dentry *dentry, struct nfs_unlinkdata *data)
 	return 0;
 }
 
+static void nfs_free_dname(struct nfs_unlinkdata *data)
+{
+	kfree(data->args.name.name);
+	data->args.name.name = NULL;
+	data->args.name.len = 0;
+}
+
+static void nfs_dec_sillycount(struct inode *dir)
+{
+	struct nfs_inode *nfsi = NFS_I(dir);
+	if (atomic_dec_return(&nfsi->silly_count) == 1)
+		wake_up(&nfsi->waitqueue);
+}
+
 /**
  * nfs_async_unlink_init - Initialize the RPC info
  * task: rpc_task of the sillydelete
@@ -95,6 +110,8 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 static void nfs_async_unlink_release(void *calldata)
 {
 	struct nfs_unlinkdata	*data = calldata;
+
+	nfs_dec_sillycount(data->dir);
 	nfs_free_unlinkdata(data);
 }
 
@@ -104,33 +121,100 @@ static const struct rpc_call_ops nfs_unlink_ops = {
 	.rpc_release = nfs_async_unlink_release,
 };
 
-static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
+static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct nfs_unlinkdata *data)
 {
 	struct rpc_task *task;
+	struct dentry *alias;
+
+	alias = d_lookup(parent, &data->args.name);
+	if (alias != NULL) {
+		int ret = 0;
+		/*
+		 * Hey, we raced with lookup... See if we need to transfer
+		 * the sillyrename information to the aliased dentry.
+		 */
+		nfs_free_dname(data);
+		spin_lock(&alias->d_lock);
+		if (!(alias->d_flags & DCACHE_NFSFS_RENAMED)) {
+			alias->d_fsdata = data;
+			alias->d_flags ^= DCACHE_NFSFS_RENAMED;
+			ret = 1;
+		}
+		spin_unlock(&alias->d_lock);
+		nfs_dec_sillycount(dir);
+		dput(alias);
+		return ret;
+	}
+	data->dir = igrab(dir);
+	if (!data->dir) {
+		nfs_dec_sillycount(dir);
+		return 0;
+	}
+	data->args.fh = NFS_FH(dir);
+	nfs_fattr_init(&data->res.dir_attr);
+
+	task = rpc_run_task(NFS_CLIENT(dir), RPC_TASK_ASYNC, &nfs_unlink_ops, data);
+	if (!IS_ERR(task))
+		rpc_put_task(task);
+	return 1;
+}
+
+static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
+{
 	struct dentry *parent;
 	struct inode *dir;
+	int ret = 0;
 
-	if (nfs_copy_dname(dentry, data) < 0)
-		goto out_free;
 
 	parent = dget_parent(dentry);
 	if (parent == NULL)
 		goto out_free;
-	dir = igrab(parent->d_inode);
+	dir = parent->d_inode;
+	if (nfs_copy_dname(dentry, data) == 0)
+		goto out_dput;
+	/* Non-exclusive lock protects against concurrent lookup() calls */
+	spin_lock(&dir->i_lock);
+	if (atomic_inc_not_zero(&NFS_I(dir)->silly_count) == 0) {
+		/* Deferred delete */
+		hlist_add_head(&data->list, &NFS_I(dir)->silly_list);
+		spin_unlock(&dir->i_lock);
+		ret = 1;
+		goto out_dput;
+	}
+	spin_unlock(&dir->i_lock);
+	ret = nfs_do_call_unlink(parent, dir, data);
+out_dput:
 	dput(parent);
-	if (dir == NULL)
-		goto out_free;
+out_free:
+	return ret;
+}
 
-	data->dir = dir;
-	data->args.fh = NFS_FH(dir);
-	nfs_fattr_init(&data->res.dir_attr);
+void nfs_block_sillyrename(struct dentry *dentry)
+{
+	struct nfs_inode *nfsi = NFS_I(dentry->d_inode);
 
-	task = rpc_run_task(NFS_CLIENT(dir), RPC_TASK_ASYNC, &nfs_unlink_ops, data);
-	if (!IS_ERR(task))
-		rpc_put_task(task);
-	return 1;
-out_free:
-	return 0;
+	wait_event(nfsi->waitqueue, atomic_cmpxchg(&nfsi->silly_count, 1, 0) == 1);
+}
+
+void nfs_unblock_sillyrename(struct dentry *dentry)
+{
+	struct inode *dir = dentry->d_inode;
+	struct nfs_inode *nfsi = NFS_I(dir);
+	struct nfs_unlinkdata *data;
+
+	atomic_inc(&nfsi->silly_count);
+	spin_lock(&dir->i_lock);
+	while (!hlist_empty(&nfsi->silly_list)) {
+		if (!atomic_inc_not_zero(&nfsi->silly_count))
+			break;
+		data = hlist_entry(nfsi->silly_list.first, struct nfs_unlinkdata, list);
+		hlist_del(&data->list);
+		spin_unlock(&dir->i_lock);
+		if (nfs_do_call_unlink(dentry, dir, data) == 0)
+			nfs_free_unlinkdata(data);
+		spin_lock(&dir->i_lock);
+	}
+	spin_unlock(&dir->i_lock);
 }
 
 /**
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0cf9d1c..89527a4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -174,8 +174,6 @@ static void nfs_mark_uptodate(struct page *page, unsigned int base, unsigned int
 		return;
 	if (count != nfs_page_length(page))
 		return;
-	if (count != PAGE_CACHE_SIZE)
-		zero_user_page(page, count, PAGE_CACHE_SIZE - count, KM_USER0);
 	SetPageUptodate(page);
 }
 
@@ -627,7 +625,8 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 				return ERR_PTR(error);
 			}
 			spin_unlock(&inode->i_lock);
-			return new;
+			req = new;
+			goto zero_page;
 		}
 		spin_unlock(&inode->i_lock);
 
@@ -655,13 +654,23 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 	if (offset < req->wb_offset) {
 		req->wb_offset = offset;
 		req->wb_pgbase = offset;
-		req->wb_bytes = rqend - req->wb_offset;
+		req->wb_bytes = max(end, rqend) - req->wb_offset;
+		goto zero_page;
 	}
 
 	if (end > rqend)
 		req->wb_bytes = end - req->wb_offset;
 
 	return req;
+zero_page:
+	/* If this page might potentially be marked as up to date,
+	 * then we need to zero any uninitalised data. */
+	if (req->wb_pgbase == 0 && req->wb_bytes != PAGE_CACHE_SIZE
+			&& !PageUptodate(req->wb_page))
+		zero_user_page(req->wb_page, req->wb_bytes,
+				PAGE_CACHE_SIZE - req->wb_bytes,
+				KM_USER0);
+	return req;
 }
 
 int nfs_flush_incompatible(struct file *file, struct page *page)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c5164c2..e82a6eb 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -160,6 +160,12 @@ struct nfs_inode {
 	/* Open contexts for shared mmap writes */
 	struct list_head	open_files;
 
+	/* Number of in-flight sillydelete RPC calls */
+	atomic_t		silly_count;
+	/* List of deferred sillydelete requests */
+	struct hlist_head	silly_list;
+	wait_queue_head_t	waitqueue;
+
 #ifdef CONFIG_NFS_V4
 	struct nfs4_cached_acl	*nfs4_acl;
         /* NFSv4 state */
@@ -394,6 +400,8 @@ extern void nfs_release_automount_timer(void);
  */
 extern int  nfs_async_unlink(struct inode *dir, struct dentry *dentry);
 extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
+extern void nfs_block_sillyrename(struct dentry *dentry);
+extern void nfs_unblock_sillyrename(struct dentry *dentry);
 
 /*
  * linux/fs/nfs/write.c
