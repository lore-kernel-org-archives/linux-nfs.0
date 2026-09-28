Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1CA44257827
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 18:57:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790621876; cv=none; b=XFlpiHW7l2nGgIT3jDnnUDhBzzdxAaF8vOpwvmAmS1cqwHpA3BnI4ILuqkZRoGoYpYs4eL904cA7guhIL0B8jqOceA5uF2eWhGk2q3RLuretClj76pYgVfrLGP0R2kK7xwIA5sOWQzWiUHAA1Xth74zZC7XYehlKmqfw/cCrsxI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790621876; c=relaxed/simple;
	bh=TtyjFj3zFB34PTlorv0lotDz3qnfTxfTbF1UWW+kfM0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=V5OdKsB+MqbEi7xBWV3RkG9L6mmovLwwF9Z6Ije8VLOiEW/qSN74myNYT6XDmJbOLAl/4+ToMb92Ijh6D0JJ6cYY9eeaYTDnew1un7hsG+q3gJLzuV2M4J9bcPoSM4ll5eF2lgHeHrE3nObUlrZtIqgf5OMc+xsxpJbukjsFKkQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AJaml7av; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AJaml7av"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 592AE1F00893;
	Mon, 28 Sep 2026 18:57:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790621874;
	bh=PuuMgbg9S0h/NOiLk27XRLMtHv4VkSHwllS/5W+C+wc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AJaml7avl7Yo2/yj0h3m/sXLN+gZFoTPVIyLpR6LodmLVXHEluSuplTb9tixqPfaD
	 Xfdndz0yYNdc6v90+MaF6I1n1hCLihjcCn/ZFbKSB+4Riflfy1JfVoIRZJWRfkYwga
	 C6mxMdRO7CztSEeXFydWor08wCj7a0kay1hF3COCQwLmW2gAQ3RO1mEtv+Vutwe7ew
	 gcN7/RnKmch7v/lHrCLgsfovplHB/qN+GlTM12f/ow8RpcmkUWzAaVEQY5J1tAvHSC
	 ZRqkTFmr1bwrmcrrj5BfFiCoLmlCptqf2Xlb2tnVUzKFFdQ3kCchyf6xjVvOMb0x1d
	 I9HFZdJMo/V5A==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] NFS: don't release the open context of a failed write from writeback
Date: Mon, 28 Sep 2026 14:57:49 -0400
Message-ID: <20260928185751.98682-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260928185751.98682-1-snitzer@kernel.org>
References: <20260928185751.98682-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a write fails with an error that nfs_error_is_fatal_on_server()
accepts, nfs_do_writepage() and nfs_async_write_error() complete the
request in the submitting thread: nfs_write_error() removes the request
from the inode and drops the last reference to it. The request owns a
reference to its open context, so if the file has already been closed
this is also where the open context is released.

Releasing an open context closes NFSv4 state and drops what may be the
last reference to the dentry, the inode and the superblock. The
submitting thread is usually the flusher, which may do none of that:

 - It holds sb->s_umount shared, or works on behalf of a sync(2) caller
   that does. An open context does not keep a filesystem mounted, so
   once it has been unmounted the open context can hold the last active
   reference to the superblock, and deactivate_super() then waits for
   s_umount forever:

     wb_workfn
       __writeback_inodes_wb
         super_trylock_shared(sb)          <- s_umount held shared
         writeback_sb_inodes
           nfs_writepages
             nfs_do_writepage              <- fatal error: out_launder
               nfs_write_error
                 nfs_release_request
                   nfs_put_lock_context
                     __put_nfs_open_context
                       nfs_sb_deactive
                         deactivate_super
                           down_write(&sb->s_umount)   <- deadlock

 - Since commit 169ebd90131b ("writeback: Avoid iput() from flusher
   thread") it pins the inode with I_SYNC instead of a reference, so
   that it never does the final iput(). evict() waits for I_SYNC, so if
   dput() drops the last reference to a stale or sillyrenamed inode,
   the flusher waits for itself:

     wb_workfn
       __writeback_inodes_wb
         writeback_sb_inodes               <- sets I_SYNC
           nfs_writepages
             nfs_do_writepage
               nfs_write_error
                 nfs_release_request
                   nfs_put_lock_context
                     __put_nfs_open_context
                       dput
                         nfs_dentry_iput
                           iput
                             evict
                               inode_wait_for_writeback   <- deadlock

The first of these was hit on a 6.12-based client whose server began
rejecting requests with AUTH_TOOWEAK (-EACCES). The flush worker hung in
deactivate_super(), and every later automount of the same filesystem
blocked in grab_super() behind it. The second was reproduced by failing
the writeback of a sillyrenamed file that had been closed.

A write that was sent is normally released by the RPC release callback,
which runs on nfsiod; the next patch closes the case where it is not.
Do the same for a write that fails before it is sent. Have
nfs_write_error() hold the open context across the release of the
request, and drop that reference with put_nfs_open_context_async(),
which hands the release of the context to nfsiod if the reference is
the last one.

This does not change when or how a filesystem is shut down. Since
commit 3d4ff43d895c ("nfs_open_context doesn't need struct path
either") an open context pins the superblock instead of a mount, so an
open context that outlives the last mount shuts the filesystem down
when it is released. The completion of a write already does that from
nfsiod.

Fixes: a6598813a4c5 ("NFS: Don't write back further requests if there is a pending write error")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/inode.c         | 37 ++++++++++++++++++++++++++++++++++---
 fs/nfs/internal.h      |  1 +
 fs/nfs/write.c         |  5 +++++
 include/linux/nfs_fs.h |  2 ++
 4 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3022454f7698..c91334dd7e3e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1231,13 +1231,11 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
 }
 EXPORT_SYMBOL_GPL(get_nfs_open_context);
 
-static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
+static void nfs_free_open_context(struct nfs_open_context *ctx, int is_sync)
 {
 	struct inode *inode = d_inode(ctx->dentry);
 	struct super_block *sb = ctx->dentry->d_sb;
 
-	if (!refcount_dec_and_test(&ctx->lock_context.count))
-		return;
 	if (!list_empty(&ctx->list)) {
 		spin_lock(&inode->i_lock);
 		list_del_rcu(&ctx->list);
@@ -1254,12 +1252,45 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 	kfree_rcu(ctx, rcu_head);
 }
 
+static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
+{
+	if (refcount_dec_and_test(&ctx->lock_context.count))
+		nfs_free_open_context(ctx, is_sync);
+}
+
 void put_nfs_open_context(struct nfs_open_context *ctx)
 {
 	__put_nfs_open_context(ctx, 0);
 }
 EXPORT_SYMBOL_GPL(put_nfs_open_context);
 
+static void nfs_free_open_context_work(struct work_struct *work)
+{
+	struct nfs_open_context *ctx =
+		container_of(work, struct nfs_open_context, free_work);
+
+	nfs_free_open_context(ctx, 0);
+}
+
+/**
+ * put_nfs_open_context_async - drop a reference from a caller that must not
+ *				release the open context itself
+ * @ctx: open context to drop
+ *
+ * Releasing an open context closes NFSv4 state and drops what may be the
+ * last reference to the dentry, the inode and the superblock. None of that
+ * is allowed in writeback, which holds sb->s_umount and has set I_SYNC on
+ * the inode. If this is the last reference, release the context from nfsiod,
+ * which is where the completion of a write releases it.
+ */
+void put_nfs_open_context_async(struct nfs_open_context *ctx)
+{
+	if (!refcount_dec_and_test(&ctx->lock_context.count))
+		return;
+	INIT_WORK(&ctx->free_work, nfs_free_open_context_work);
+	queue_work(nfsiod_workqueue, &ctx->free_work);
+}
+
 static void put_nfs_open_context_sync(struct nfs_open_context *ctx)
 {
 	__put_nfs_open_context(ctx, 1);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 48f7c0e25da1..94d61a42c7ee 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -525,6 +525,7 @@ extern int __init register_nfs_fs(void);
 extern void __exit unregister_nfs_fs(void);
 extern bool nfs_sb_active(struct super_block *sb);
 extern void nfs_sb_deactive(struct super_block *sb);
+extern void put_nfs_open_context_async(struct nfs_open_context *ctx);
 extern int nfs_client_for_each_server(struct nfs_client *clp,
 				      int (*fn)(struct nfs_server *, void *),
 				      void *data);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7f173dbbeb9d..f38bbebffe4d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -568,11 +568,16 @@ static struct nfs_page *nfs_lock_and_join_requests(struct folio *folio)
 
 static void nfs_write_error(struct nfs_page *req, int error)
 {
+	struct nfs_open_context *ctx;
+
+	/* The caller may be writeback, which must not release the context */
+	ctx = get_nfs_open_context(nfs_req_openctx(req));
 	trace_nfs_write_error(nfs_page_to_inode(req), req, error);
 	nfs_mapping_set_error(nfs_page_to_folio(req), error);
 	nfs_inode_remove_request(req);
 	nfs_page_end_writeback(req);
 	nfs_release_request(req);
+	put_nfs_open_context_async(ctx);
 }
 
 /*
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b85a73ae7919..32a46de106cd 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -26,6 +26,7 @@
 #include <linux/refcount.h>
 #include <linux/rwsem.h>
 #include <linux/wait.h>
+#include <linux/workqueue.h>
 
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/auth.h>
@@ -115,6 +116,7 @@ struct nfs_open_context {
 	struct nfs4_threshold	*mdsthreshold;
 	struct list_head list;
 	struct rcu_head	rcu_head;
+	struct work_struct free_work;
 	struct nfs_file_localio nfl;
 };
 
-- 
2.52.0

