From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/5] NFSv4: Ensure that we track the NFSv4 lock state in read/write requests.
Date: Wed, 30 Jun 2010 17:25:34 -0400
Message-ID: <1277933137-6955-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1277933137-6955-1-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-2-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4193 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569Ab0F3VZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jun 2010 17:25:55 -0400
In-Reply-To: <1277933137-6955-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch fixes bugzilla entry 14501:
  https://bugzilla.kernel.org/show_bug.cgi?id=14501

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c           |   70 +++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4xdr.c         |    8 ++--
 fs/nfs/pagelist.c        |    8 ++++-
 fs/nfs/read.c            |    1 +
 fs/nfs/write.c           |    5 ++-
 include/linux/nfs_fs.h   |   13 +++++++-
 include/linux/nfs_page.h |    1 +
 include/linux/nfs_xdr.h  |    2 +
 8 files changed, 96 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 099b351..ec7a8f9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -530,6 +530,68 @@ out:
 	return err;
 }
 
+static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
+{
+	atomic_set(&l_ctx->count, 1);
+	l_ctx->lockowner = current->files;
+	l_ctx->pid = current->tgid;
+	INIT_LIST_HEAD(&l_ctx->list);
+}
+
+static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx)
+{
+	struct nfs_lock_context *pos;
+
+	list_for_each_entry(pos, &ctx->lock_context.list, list) {
+		if (pos->lockowner != current->files)
+			continue;
+		if (pos->pid != current->tgid)
+			continue;
+		atomic_inc(&pos->count);
+		return pos;
+	}
+	return NULL;
+}
+
+struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
+{
+	struct nfs_lock_context *res, *new = NULL;
+	struct inode *inode = ctx->path.dentry->d_inode;
+
+	spin_lock(&inode->i_lock);
+	res = __nfs_find_lock_context(ctx);
+	if (res == NULL) {
+		spin_unlock(&inode->i_lock);
+		new = kmalloc(sizeof(*new), GFP_KERNEL);
+		if (new == NULL)
+			return NULL;
+		nfs_init_lock_context(new);
+		spin_lock(&inode->i_lock);
+		res = __nfs_find_lock_context(ctx);
+		if (res == NULL) {
+			list_add_tail(&new->list, &ctx->lock_context.list);
+			new->open_context = ctx;
+			res = new;
+			new = NULL;
+		}
+	}
+	spin_unlock(&inode->i_lock);
+	kfree(new);
+	return res;
+}
+
+void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
+{
+	struct nfs_open_context *ctx = l_ctx->open_context;
+	struct inode *inode = ctx->path.dentry->d_inode;
+
+	if (!atomic_dec_and_lock(&l_ctx->count, &inode->i_lock))
+		return;
+	list_del(&l_ctx->list);
+	spin_unlock(&inode->i_lock);
+	kfree(l_ctx);
+}
+
 /**
  * nfs_close_context - Common close_context() routine NFSv2/v3
  * @ctx: pointer to context
@@ -566,11 +628,11 @@ static struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct
 		path_get(&ctx->path);
 		ctx->cred = get_rpccred(cred);
 		ctx->state = NULL;
-		ctx->lockowner = current->files;
 		ctx->flags = 0;
 		ctx->error = 0;
 		ctx->dir_cookie = 0;
-		atomic_set(&ctx->count, 1);
+		nfs_init_lock_context(&ctx->lock_context);
+		ctx->lock_context.open_context = ctx;
 	}
 	return ctx;
 }
@@ -578,7 +640,7 @@ static struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct
 struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 {
 	if (ctx != NULL)
-		atomic_inc(&ctx->count);
+		atomic_inc(&ctx->lock_context.count);
 	return ctx;
 }
 
@@ -586,7 +648,7 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 {
 	struct inode *inode = ctx->path.dentry->d_inode;
 
-	if (!atomic_dec_and_lock(&ctx->count, &inode->i_lock))
+	if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
 		return;
 	list_del(&ctx->list);
 	spin_unlock(&inode->i_lock);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1f7781d..873b62f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1324,14 +1324,14 @@ static void encode_putrootfh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	hdr->replen += decode_putrootfh_maxsz;
 }
 
-static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx)
+static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context *ctx, const struct nfs_lock_context *l_ctx)
 {
 	nfs4_stateid stateid;
 	__be32 *p;
 
 	p = reserve_space(xdr, NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
-		nfs4_copy_stateid(&stateid, ctx->state, ctx->lockowner);
+		nfs4_copy_stateid(&stateid, ctx->state, l_ctx->lockowner);
 		xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
 	} else
 		xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
@@ -1344,7 +1344,7 @@ static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args,
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(OP_READ);
 
-	encode_stateid(xdr, args->context);
+	encode_stateid(xdr, args->context, args->lock_context);
 
 	p = reserve_space(xdr, 12);
 	p = xdr_encode_hyper(p, args->offset);
@@ -1523,7 +1523,7 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(OP_WRITE);
 
-	encode_stateid(xdr, args->context);
+	encode_stateid(xdr, args->context, args->lock_context);
 
 	p = reserve_space(xdr, 16);
 	p = xdr_encode_hyper(p, args->offset);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a3654e5..9194902 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -79,6 +79,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
+	req->wb_lock_context = nfs_get_lock_context(ctx);
 	kref_init(&req->wb_kref);
 	return req;
 }
@@ -141,11 +142,16 @@ void nfs_clear_request(struct nfs_page *req)
 {
 	struct page *page = req->wb_page;
 	struct nfs_open_context *ctx = req->wb_context;
+	struct nfs_lock_context *l_ctx = req->wb_lock_context;
 
 	if (page != NULL) {
 		page_cache_release(page);
 		req->wb_page = NULL;
 	}
+	if (l_ctx != NULL) {
+		nfs_put_lock_context(l_ctx);
+		req->wb_lock_context = NULL;
+	}
 	if (ctx != NULL) {
 		put_nfs_open_context(ctx);
 		req->wb_context = NULL;
@@ -235,7 +241,7 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
 {
 	if (req->wb_context->cred != prev->wb_context->cred)
 		return 0;
-	if (req->wb_context->lockowner != prev->wb_context->lockowner)
+	if (req->wb_lock_context->lockowner != prev->wb_lock_context->lockowner)
 		return 0;
 	if (req->wb_context->state != prev->wb_context->state)
 		return 0;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 5a33a92..87adc27 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -190,6 +190,7 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
 	data->args.context = get_nfs_open_context(req->wb_context);
+	data->args.lock_context = req->wb_lock_context;
 
 	data->res.fattr   = &data->fattr;
 	data->res.count   = count;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 03df228..5eccea1 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -689,7 +689,9 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			return 0;
-		do_flush = req->wb_page != page || req->wb_context != ctx;
+		do_flush = req->wb_page != page || req->wb_context != ctx ||
+			req->wb_lock_context->lockowner != current->files ||
+			req->wb_lock_context->pid != current->tgid;
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
@@ -813,6 +815,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
 	data->args.context = get_nfs_open_context(req->wb_context);
+	data->args.lock_context = req->wb_lock_context;
 	data->args.stable  = NFS_UNSTABLE;
 	if (how & FLUSH_STABLE) {
 		data->args.stable = NFS_DATA_SYNC;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 77c2ae5..a9d8026 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -72,13 +72,20 @@ struct nfs_access_entry {
 	int			mask;
 };
 
+struct nfs_lock_context {
+	atomic_t count;
+	struct list_head list;
+	struct nfs_open_context *open_context;
+	fl_owner_t lockowner;
+	pid_t pid;
+};
+
 struct nfs4_state;
 struct nfs_open_context {
-	atomic_t count;
+	struct nfs_lock_context lock_context;
 	struct path path;
 	struct rpc_cred *cred;
 	struct nfs4_state *state;
-	fl_owner_t lockowner;
 	fmode_t mode;
 
 	unsigned long flags;
@@ -353,6 +360,8 @@ extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
+extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
+extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
 extern u64 nfs_compat_user_ino64(u64 fileid);
 extern void nfs_fattr_init(struct nfs_fattr *fattr);
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 3c60685..f8b60e7 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -39,6 +39,7 @@ struct nfs_page {
 	struct list_head	wb_list;	/* Defines state of page: */
 	struct page		*wb_page;	/* page to read in/write out */
 	struct nfs_open_context	*wb_context;	/* File state context info */
+	struct nfs_lock_context	*wb_lock_context;	/* lock context info */
 	atomic_t		wb_complete;	/* i/os we're waiting for */
 	pgoff_t			wb_index;	/* Offset >> PAGE_CACHE_SHIFT */
 	unsigned int		wb_offset,	/* Offset & ~PAGE_CACHE_MASK */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a319cb9..87202c7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -334,6 +334,7 @@ struct nfs4_delegreturnres {
 struct nfs_readargs {
 	struct nfs_fh *		fh;
 	struct nfs_open_context *context;
+	struct nfs_lock_context *lock_context;
 	__u64			offset;
 	__u32			count;
 	unsigned int		pgbase;
@@ -354,6 +355,7 @@ struct nfs_readres {
 struct nfs_writeargs {
 	struct nfs_fh *		fh;
 	struct nfs_open_context *context;
+	struct nfs_lock_context *lock_context;
 	__u64			offset;
 	__u32			count;
 	enum nfs3_stable_how	stable;
-- 
1.7.0.1

