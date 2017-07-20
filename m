Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53354 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935971AbdGTTma (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jul 2017 15:42:30 -0400
From: Jeff Layton <jlayton@kernel.org>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        NeilBrown <neilb@suse.com>
Subject: [PATCH] nfs: track writeback errors with errseq_t
Date: Thu, 20 Jul 2017 15:42:27 -0400
Message-Id: <20170720194227.7830-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

There is some ambiguity in nfs about how writeback errors are tracked.

For instance, nfs_pageio_add_request calls mapping_set_error when the
add fails, but we track errors that occur after adding the request
with a dedicated int error in the open context.

Now that we have better infrastructure for the vfs layer, this
latter int is now unnecessary. Just have nfs_context_set_write_error set
the error in the mapping when one occurs.

Have NFS use file_write_and_wait_range to initiate and wait on writeback
of the data, and then check again after issuing the commit(s).

With this, we also don't need to pay attention to the ERROR_WRITE
flag for reporting, and just clear it to indicate to subsequent
writers that they should try to go asynchronous again.

In nfs_page_async_flush, sample the error before locking and joining
the requests, and check for errors since that point.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/file.c          | 24 +++++++++++-------------
 fs/nfs/inode.c         |  3 +--
 fs/nfs/write.c         |  8 ++++++--
 include/linux/nfs_fs.h |  1 -
 4 files changed, 18 insertions(+), 18 deletions(-)

I have a baling wire and duct tape solution for testing this with
xfstests (using iptables REJECT targets and soft mounts). This seems to
make nfs do the right thing.

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5713eb32a45e..15d3c6faafd3 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -212,25 +212,23 @@ nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	struct inode *inode = file_inode(file);
-	int have_error, do_resend, status;
-	int ret = 0;
+	int do_resend, status;
+	int ret;
 
 	dprintk("NFS: fsync file(%pD2) datasync %d\n", file, datasync);
 
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
 	do_resend = test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
-	have_error = test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
-	status = nfs_commit_inode(inode, FLUSH_SYNC);
-	have_error |= test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
-	if (have_error) {
-		ret = xchg(&ctx->error, 0);
-		if (ret)
-			goto out;
-	}
-	if (status < 0) {
+	clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
+	ret = nfs_commit_inode(inode, FLUSH_SYNC);
+
+	/* Recheck and advance after the commit */
+	status = file_check_and_advance_wb_err(file);
+	if (!ret)
 		ret = status;
+	if (ret)
 		goto out;
-	}
+
 	do_resend |= test_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
 	if (do_resend)
 		ret = -EAGAIN;
@@ -247,7 +245,7 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	trace_nfs_fsync_enter(inode);
 
 	do {
-		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+		ret = file_write_and_wait_range(file, start, end);
 		if (ret != 0)
 			break;
 		ret = nfs_file_fsync_commit(file, start, end, datasync);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 109279d6d91b..c48f673c5cc9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -900,7 +900,6 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
 	ctx->state = NULL;
 	ctx->mode = f_mode;
 	ctx->flags = 0;
-	ctx->error = 0;
 	ctx->flock_owner = (fl_owner_t)filp;
 	nfs_init_lock_context(&ctx->lock_context);
 	ctx->lock_context.open_context = ctx;
@@ -1009,7 +1008,7 @@ void nfs_file_clear_open_context(struct file *filp)
 		 * We fatal error on write before. Try to writeback
 		 * every page again.
 		 */
-		if (ctx->error < 0)
+		if (filemap_check_wb_err(inode->i_mapping, filp->f_wb_err))
 			invalidate_inode_pages2(inode->i_mapping);
 		filp->private_data = NULL;
 		spin_lock(&inode->i_lock);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b1af5dee5e0a..c2fcaf07cd24 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -149,7 +149,9 @@ static void nfs_io_completion_put(struct nfs_io_completion *ioc)
 
 static void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
 {
-	ctx->error = error;
+	struct inode *inode = d_inode(ctx->dentry);
+
+	mapping_set_error(inode->i_mapping, error);
 	smp_wmb();
 	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
 }
@@ -628,6 +630,8 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 {
 	struct nfs_page *req;
 	int ret = 0;
+	struct address_space *mapping = page_file_mapping(page);
+	errseq_t since = filemap_sample_wb_err(mapping);
 
 	req = nfs_lock_and_join_requests(page, nonblock);
 	if (!req)
@@ -641,7 +645,7 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 
 	ret = 0;
 	/* If there is a fatal error that covers this write, just exit */
-	if (nfs_error_is_fatal_on_server(req->wb_context->error))
+	if (nfs_error_is_fatal_on_server(filemap_check_wb_err(mapping, since)))
 		goto out_launder;
 
 	if (!nfs_pageio_add_request(pgio, req)) {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e52cc55ac300..a96b0bd52b32 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -77,7 +77,6 @@ struct nfs_open_context {
 #define NFS_CONTEXT_RESEND_WRITES	(1)
 #define NFS_CONTEXT_BAD			(2)
 #define NFS_CONTEXT_UNLOCK	(3)
-	int error;
 
 	struct list_head list;
 	struct nfs4_threshold	*mdsthreshold;
-- 
2.13.3

