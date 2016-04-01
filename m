Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbcDAPew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 11:34:52 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: add OFD lock owners to nfs_lock_context
Date: Fri,  1 Apr 2016 11:34:49 -0400
Message-Id: <14db791eb1cde17ca9260cd09221b64f1f56a13f.1459512820.git.bcodding@redhat.com>
In-Reply-To: <cover.1459512819.git.bcodding@redhat.com>
References: <cover.1459512819.git.bcodding@redhat.com>
In-Reply-To: <cover.1459512819.git.bcodding@redhat.com>
References: <cover.1459512819.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OFD locks use the file pointer for lock ownership.  Change lock context
lookup to take a file pointer which will create distinct lock contexts for
operations on separate files.  This allows us to retain the OFD lock owner
so we can find a matching nfs4_lock_state later.

IO paths are modified to lookup or create the lock context earlier in the
call path where we have a reference to a file pointer.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/direct.c          |    8 ++++----
 fs/nfs/file.c            |    2 +-
 fs/nfs/fscache-index.c   |    4 ++--
 fs/nfs/fscache.h         |   12 ++++++------
 fs/nfs/inode.c           |   23 ++++++++++++++---------
 fs/nfs/nfs42proc.c       |    8 ++++----
 fs/nfs/nfs4proc.c        |    3 ++-
 fs/nfs/nfs4state.c       |    2 +-
 fs/nfs/pagelist.c        |   21 +++++++--------------
 fs/nfs/read.c            |   38 +++++++++++++++++++++++---------------
 fs/nfs/write.c           |   16 +++++++++-------
 include/linux/nfs_fs.h   |    5 +++--
 include/linux/nfs_page.h |    2 +-
 13 files changed, 77 insertions(+), 67 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 5f833fa..8f49e95 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -499,7 +499,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			struct nfs_page *req;
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 			/* XXX do we need to do the eof zeroing found in async_filler? */
-			req = nfs_create_request(dreq->ctx, pagevec[i], NULL,
+			req = nfs_create_request(dreq->l_ctx, pagevec[i], NULL,
 						 pgbase, req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
@@ -596,7 +596,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
 	dreq->bytes_left = count;
 	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
-	l_ctx = nfs_find_lock_context(dreq->ctx);
+	l_ctx = nfs_find_lock_context(file);
 	if (IS_ERR(l_ctx)) {
 		result = PTR_ERR(l_ctx);
 		goto out_release;
@@ -915,7 +915,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			struct nfs_page *req;
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 
-			req = nfs_create_request(dreq->ctx, pagevec[i], NULL,
+			req = nfs_create_request(dreq->l_ctx, pagevec[i], NULL,
 						 pgbase, req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
@@ -1029,7 +1029,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	dreq->bytes_left = iov_iter_count(iter);
 	dreq->io_start = pos;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
-	l_ctx = nfs_find_lock_context(dreq->ctx);
+	l_ctx = nfs_find_lock_context(file);
 	if (IS_ERR(l_ctx)) {
 		result = PTR_ERR(l_ctx);
 		goto out_release;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index f99c085..c1361c6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -754,7 +754,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 */
 	vfs_fsync(filp, 0);
 
-	l_ctx = nfs_find_lock_context(nfs_file_open_context(filp));
+	l_ctx = nfs_find_lock_context(filp);
 	if (!IS_ERR(l_ctx)) {
 		status = nfs_iocounter_wait(l_ctx);
 		nfs_put_lock_context(l_ctx);
diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 777b055..c182d57 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -300,7 +300,7 @@ static void nfs_fscache_inode_now_uncached(void *cookie_netfs_data)
  */
 static void nfs_fh_get_context(void *cookie_netfs_data, void *context)
 {
-	get_nfs_open_context(context);
+	get_nfs_lock_context(context);
 }
 
 /*
@@ -311,7 +311,7 @@ static void nfs_fh_get_context(void *cookie_netfs_data, void *context)
 static void nfs_fh_put_context(void *cookie_netfs_data, void *context)
 {
 	if (context)
-		put_nfs_open_context(context);
+		put_nfs_lock_context(context);
 }
 
 /*
diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index d7fe3e7..5e08751 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -114,26 +114,26 @@ static inline void nfs_fscache_invalidate_page(struct page *page,
 /*
  * Retrieve a page from an inode data storage object.
  */
-static inline int nfs_readpage_from_fscache(struct nfs_open_context *ctx,
+static inline int nfs_readpage_from_fscache(struct nfs_lock_context *l_ctx,
 					    struct inode *inode,
 					    struct page *page)
 {
 	if (NFS_I(inode)->fscache)
-		return __nfs_readpage_from_fscache(ctx, inode, page);
+		return __nfs_readpage_from_fscache(l_ctx, inode, page);
 	return -ENOBUFS;
 }
 
 /*
  * Retrieve a set of pages from an inode data storage object.
  */
-static inline int nfs_readpages_from_fscache(struct nfs_open_context *ctx,
+static inline int nfs_readpages_from_fscache(struct nfs_lock_context *l_ctx,
 					     struct inode *inode,
 					     struct address_space *mapping,
 					     struct list_head *pages,
 					     unsigned *nr_pages)
 {
 	if (NFS_I(inode)->fscache)
-		return __nfs_readpages_from_fscache(ctx, inode, mapping, pages,
+		return __nfs_readpages_from_fscache(l_ctx, inode, mapping, pages,
 						    nr_pages);
 	return -ENOBUFS;
 }
@@ -199,13 +199,13 @@ static inline void nfs_fscache_invalidate_page(struct page *page,
 static inline void nfs_fscache_wait_on_page_write(struct nfs_inode *nfsi,
 						  struct page *page) {}
 
-static inline int nfs_readpage_from_fscache(struct nfs_open_context *ctx,
+static inline int nfs_readpage_from_fscache(struct nfs_lock_context *l_ctx,
 					    struct inode *inode,
 					    struct page *page)
 {
 	return -ENOBUFS;
 }
-static inline int nfs_readpages_from_fscache(struct nfs_open_context *ctx,
+static inline int nfs_readpages_from_fscache(struct nfs_lock_context *l_ctx,
 					     struct inode *inode,
 					     struct address_space *mapping,
 					     struct list_head *pages,
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5d484e5..a703a02 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -700,22 +700,25 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_getattr);
 
-static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
+static void nfs_init_lock_context(struct nfs_lock_context *l_ctx, struct file *file)
 {
 	atomic_set(&l_ctx->count, 1);
-	l_ctx->lockowner.l_owner = current->files;
+	l_ctx->lockowner.l_owner_posix = current->files;
+	l_ctx->lockowner.l_owner_ofd = file;
 	l_ctx->lockowner.l_pid = current->tgid;
 	INIT_LIST_HEAD(&l_ctx->list);
 	atomic_set(&l_ctx->io_count, 0);
 }
 
-static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx)
+static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx, struct file *file)
 {
 	struct nfs_lock_context *head = &ctx->lock_context;
 	struct nfs_lock_context *pos = head;
 
 	do {
-		if (pos->lockowner.l_owner != current->files)
+		if (pos->lockowner.l_owner_posix != current->files)
+			continue;
+		if (pos->lockowner.l_owner_ofd != file)
 			continue;
 		if (pos->lockowner.l_pid != current->tgid)
 			continue;
@@ -725,21 +728,22 @@ static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context
 	return NULL;
 }
 
-struct nfs_lock_context *nfs_find_lock_context(struct nfs_open_context *ctx)
+struct nfs_lock_context *nfs_find_lock_context(struct file *file)
 {
+	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct nfs_lock_context *res, *new = NULL;
 	struct inode *inode = d_inode(ctx->dentry);
 
 	spin_lock(&inode->i_lock);
-	res = __nfs_find_lock_context(ctx);
+	res = __nfs_find_lock_context(ctx, file);
 	if (res == NULL) {
 		spin_unlock(&inode->i_lock);
 		new = kmalloc(sizeof(*new), GFP_KERNEL);
 		if (new == NULL)
 			return ERR_PTR(-ENOMEM);
-		nfs_init_lock_context(new);
+		nfs_init_lock_context(new, file);
 		spin_lock(&inode->i_lock);
-		res = __nfs_find_lock_context(ctx);
+		res = __nfs_find_lock_context(ctx, file);
 		if (res == NULL) {
 			list_add_tail(&new->list, &ctx->lock_context.list);
 			new->open_context = ctx;
@@ -826,7 +830,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f
 	ctx->mode = f_mode;
 	ctx->flags = 0;
 	ctx->error = 0;
-	nfs_init_lock_context(&ctx->lock_context);
+	nfs_init_lock_context(&ctx->lock_context, NULL);
 	ctx->lock_context.open_context = ctx;
 	INIT_LIST_HEAD(&ctx->list);
 	ctx->mdsthreshold = NULL;
@@ -893,6 +897,7 @@ EXPORT_SYMBOL_GPL(nfs_inode_attach_open_context);
 void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx)
 {
 	filp->private_data = get_nfs_open_context(ctx);
+	ctx->lock_context.lockowner.l_owner_ofd = filp;
 	if (list_empty(&ctx->list))
 		nfs_inode_attach_open_context(ctx);
 }
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index f9b0f25..107a182 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -61,7 +61,7 @@ static int nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 	struct nfs_lock_context *lock;
 	int err;
 
-	lock = nfs_find_lock_context(nfs_file_open_context(filep));
+	lock = nfs_find_lock_context(filep);
 	if (IS_ERR(lock))
 		return PTR_ERR(lock);
 
@@ -171,7 +171,7 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 	struct nfs_lock_context *lock;
 	loff_t err;
 
-	lock = nfs_find_lock_context(nfs_file_open_context(filep));
+	lock = nfs_find_lock_context(filep);
 	if (IS_ERR(lock))
 		return PTR_ERR(lock);
 
@@ -365,14 +365,14 @@ int nfs42_proc_clone(struct file *src_f, struct file *dst_f,
 	if (!nfs_server_capable(inode, NFS_CAP_CLONE))
 		return -EOPNOTSUPP;
 
-	src_lock = nfs_find_lock_context(nfs_file_open_context(src_f));
+	src_lock = nfs_find_lock_context(src_f);
 	if (IS_ERR(src_lock))
 		return PTR_ERR(src_lock);
 
 	src_exception.inode = file_inode(src_f);
 	src_exception.state = src_lock->open_context->state;
 
-	dst_lock = nfs_find_lock_context(nfs_file_open_context(dst_f));
+	dst_lock = nfs_find_lock_context(dst_f);
 	if (IS_ERR(dst_lock)) {
 		err = PTR_ERR(dst_lock);
 		goto out_put_src_lock;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1488159..cb5b326 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2694,7 +2694,8 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 		/* Use that stateid */
 	} else if (truncate && state != NULL) {
 		struct nfs_lockowner lockowner = {
-			.l_owner = current->files,
+			.l_owner_posix = current->files,
+			.l_owner_ofd = sattr->ia_file,
 			.l_pid = current->tgid,
 		};
 		if (!nfs4_valid_open_stateid(state))
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d854693..b7f4509 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -952,7 +952,7 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 	if (test_bit(LK_STATE_IN_USE, &state->flags) == 0)
 		goto out;
 
-	fl_owner = lockowner->l_owner;
+	fl_owner = lockowner->l_owner_posix;
 	spin_lock(&state->state_lock);
 	lsp = __nfs4_find_lock_state(state, fl_owner);
 	if (lsp && test_bit(NFS_LOCK_LOST, &lsp->ls_flags))
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b3e5366..2b28dff 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -314,27 +314,20 @@ nfs_page_group_destroy(struct kref *kref)
  * User should ensure it is safe to sleep in this function.
  */
 struct nfs_page *
-nfs_create_request(struct nfs_open_context *ctx, struct page *page,
+nfs_create_request(struct nfs_lock_context *l_ctx, struct page *page,
 		   struct nfs_page *last, unsigned int offset,
 		   unsigned int count)
 {
 	struct nfs_page		*req;
-	struct nfs_lock_context *l_ctx;
 
-	if (test_bit(NFS_CONTEXT_BAD, &ctx->flags))
+	if (test_bit(NFS_CONTEXT_BAD, &l_ctx->open_context->flags))
 		return ERR_PTR(-EBADF);
 	/* try to allocate the request struct */
 	req = nfs_page_alloc();
 	if (req == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	/* get lock context early so we can deal with alloc failures */
-	l_ctx = nfs_find_lock_context(ctx);
-	if (IS_ERR(l_ctx)) {
-		nfs_page_free(req);
-		return ERR_CAST(l_ctx);
-	}
-	req->wb_lock_context = l_ctx;
+	req->wb_lock_context = get_nfs_lock_context(l_ctx);
 	atomic_inc(&l_ctx->io_count);
 
 	/* Initialize the request struct. Initially, we assume a
@@ -346,7 +339,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
-	req->wb_context = get_nfs_open_context(ctx);
+	req->wb_context = get_nfs_open_context(l_ctx->open_context);
 	kref_init(&req->wb_kref);
 	nfs_page_group_init(req, last);
 	return req;
@@ -865,7 +858,7 @@ static void nfs_pageio_cleanup_mirroring(struct nfs_pageio_descriptor *pgio)
 static bool nfs_match_lock_context(const struct nfs_lock_context *l1,
 		const struct nfs_lock_context *l2)
 {
-	return l1->lockowner.l_owner == l2->lockowner.l_owner
+	return l1->lockowner.l_owner_posix == l2->lockowner.l_owner_posix
 		&& l1->lockowner.l_pid == l2->lockowner.l_pid;
 }
 
@@ -1024,7 +1017,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 		pgbase += subreq->wb_bytes;
 
 		if (bytes_left) {
-			subreq = nfs_create_request(req->wb_context,
+			subreq = nfs_create_request(req->wb_lock_context,
 					req->wb_page,
 					subreq, pgbase, bytes_left);
 			if (IS_ERR(subreq))
@@ -1115,7 +1108,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			     lastreq = lastreq->wb_this_page)
 				;
 
-			dupreq = nfs_create_request(req->wb_context,
+			dupreq = nfs_create_request(req->wb_lock_context,
 					req->wb_page, lastreq, pgbase, bytes);
 
 			if (IS_ERR(dupreq)) {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index eb31e23..704effd 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -102,7 +102,7 @@ static void nfs_readpage_release(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
+int nfs_readpage_async(struct nfs_lock_context *l_ctx, struct inode *inode,
 		       struct page *page)
 {
 	struct nfs_page	*new;
@@ -113,7 +113,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	new = nfs_create_request(ctx, page, NULL, 0, len);
+	new = nfs_create_request(l_ctx, page, NULL, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
 		return PTR_ERR(new);
@@ -291,6 +291,7 @@ static void nfs_readpage_result(struct rpc_task *task,
 int nfs_readpage(struct file *file, struct page *page)
 {
 	struct nfs_open_context *ctx;
+	struct nfs_lock_context *l_ctx;
 	struct inode *inode = page_file_mapping(page)->host;
 	int		error;
 
@@ -321,19 +322,22 @@ int nfs_readpage(struct file *file, struct page *page)
 		ctx = nfs_find_open_context(inode, NULL, FMODE_READ);
 		if (ctx == NULL)
 			goto out_unlock;
-	} else
-		ctx = get_nfs_open_context(nfs_file_open_context(file));
+		l_ctx = get_nfs_lock_context(&ctx->lock_context);
+		put_nfs_open_context(ctx);
+	} else {
+		l_ctx = nfs_find_lock_context(file);
+	}
 
 	if (!IS_SYNC(inode)) {
-		error = nfs_readpage_from_fscache(ctx, inode, page);
+		error = nfs_readpage_from_fscache(l_ctx, inode, page);
 		if (error == 0)
 			goto out;
 	}
 
-	error = nfs_readpage_async(ctx, inode, page);
+	error = nfs_readpage_async(l_ctx, inode, page);
 
 out:
-	put_nfs_open_context(ctx);
+	nfs_put_lock_context(l_ctx);
 	return error;
 out_unlock:
 	unlock_page(page);
@@ -342,7 +346,7 @@ out_unlock:
 
 struct nfs_readdesc {
 	struct nfs_pageio_descriptor *pgio;
-	struct nfs_open_context *ctx;
+	struct nfs_lock_context *l_ctx;
 };
 
 static int
@@ -357,7 +361,7 @@ readpage_async_filler(void *data, struct page *page)
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, page, NULL, 0, len);
+	new = nfs_create_request(desc->l_ctx, page, NULL, 0, len);
 	if (IS_ERR(new))
 		goto out_error;
 
@@ -382,6 +386,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 {
 	struct nfs_pageio_descriptor pgio;
 	struct nfs_pgio_mirror *pgm;
+	struct nfs_open_context *ctx;
 	struct nfs_readdesc desc = {
 		.pgio = &pgio,
 	};
@@ -399,16 +404,19 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 		goto out;
 
 	if (filp == NULL) {
-		desc.ctx = nfs_find_open_context(inode, NULL, FMODE_READ);
-		if (desc.ctx == NULL)
+		ctx = nfs_find_open_context(inode, NULL, FMODE_READ);
+		if (ctx == NULL)
 			return -EBADF;
-	} else
-		desc.ctx = get_nfs_open_context(nfs_file_open_context(filp));
+		desc.l_ctx = get_nfs_lock_context(&ctx->lock_context);
+		put_nfs_open_context(ctx);
+	} else {
+		desc.l_ctx = nfs_find_lock_context(filp);
+	}
 
 	/* attempt to read as many of the pages as possible from the cache
 	 * - this returns -ENOBUFS immediately if the cookie is negative
 	 */
-	ret = nfs_readpages_from_fscache(desc.ctx, inode, mapping,
+	ret = nfs_readpages_from_fscache(desc.l_ctx, inode, mapping,
 					 pages, &nr_pages);
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
@@ -428,7 +436,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 		 PAGE_CACHE_SHIFT;
 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 read_complete:
-	put_nfs_open_context(desc.ctx);
+	nfs_put_lock_context(desc.l_ctx);
 out:
 	return ret;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5754835..935244c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1101,7 +1101,7 @@ out_err:
  * if we have to add a new request. Also assumes that the caller has
  * already called nfs_flush_incompatible() if necessary.
  */
-static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
+static struct nfs_page * nfs_setup_write_request(struct nfs_lock_context *l_ctx,
 		struct page *page, unsigned int offset, unsigned int bytes)
 {
 	struct inode *inode = page_file_mapping(page)->host;
@@ -1110,7 +1110,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 	req = nfs_try_to_update_request(inode, page, offset, bytes);
 	if (req != NULL)
 		goto out;
-	req = nfs_create_request(ctx, page, NULL, offset, bytes);
+	req = nfs_create_request(l_ctx, page, NULL, offset, bytes);
 	if (IS_ERR(req))
 		goto out;
 	nfs_inode_add_request(inode, req);
@@ -1118,12 +1118,12 @@ out:
 	return req;
 }
 
-static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
+static int nfs_writepage_setup(struct nfs_lock_context *l_ctx, struct page *page,
 		unsigned int offset, unsigned int count)
 {
 	struct nfs_page	*req;
 
-	req = nfs_setup_write_request(ctx, page, offset, count);
+	req = nfs_setup_write_request(l_ctx, page, offset, count);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 	/* Update file length */
@@ -1161,7 +1161,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		if (l_ctx && flctx &&
 		    !(list_empty_careful(&flctx->flc_posix) &&
 		      list_empty_careful(&flctx->flc_flock))) {
-			do_flush |= l_ctx->lockowner.l_owner != current->files
+			do_flush |= l_ctx->lockowner.l_owner_posix != current->files
 				|| l_ctx->lockowner.l_pid != current->tgid;
 		}
 		nfs_release_request(req);
@@ -1279,7 +1279,7 @@ static int nfs_can_extend_write(struct file *file, struct page *page, struct ino
 int nfs_updatepage(struct file *file, struct page *page,
 		unsigned int offset, unsigned int count)
 {
-	struct nfs_open_context *ctx = nfs_file_open_context(file);
+	struct nfs_lock_context *l_ctx = nfs_find_lock_context(file);
 	struct inode	*inode = page_file_mapping(page)->host;
 	int		status = 0;
 
@@ -1293,12 +1293,14 @@ int nfs_updatepage(struct file *file, struct page *page,
 		offset = 0;
 	}
 
-	status = nfs_writepage_setup(ctx, page, offset, count);
+	status = nfs_writepage_setup(l_ctx, page, offset, count);
 	if (status < 0)
 		nfs_set_pageerror(page);
 	else
 		__set_page_dirty_nobuffers(page);
 
+	nfs_put_lock_context(l_ctx);
+
 	dprintk("NFS:       nfs_updatepage returns %d (isize %lld)\n",
 			status, (long long)i_size_read(inode));
 	return status;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e93e285..cf43e23 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -56,7 +56,8 @@ struct nfs_access_entry {
 };
 
 struct nfs_lockowner {
-	fl_owner_t l_owner;
+	fl_owner_t l_owner_posix;
+	fl_owner_t l_owner_ofd;
 	pid_t l_pid;
 };
 
@@ -542,7 +543,7 @@ nfs_have_writebacks(struct inode *inode)
 extern int  nfs_readpage(struct file *, struct page *);
 extern int  nfs_readpages(struct file *, struct address_space *,
 		struct list_head *, unsigned);
-extern int  nfs_readpage_async(struct nfs_open_context *, struct inode *,
+extern int  nfs_readpage_async(struct nfs_lock_context *, struct inode *,
 			       struct page *);
 
 /*
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index f2f650f..3b0cbcd 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -110,7 +110,7 @@ struct nfs_pageio_descriptor {
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
 
-extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
+extern	struct nfs_page *nfs_create_request(struct nfs_lock_context *l_ctx,
 					    struct page *page,
 					    struct nfs_page *last,
 					    unsigned int offset,
-- 
1.7.1

