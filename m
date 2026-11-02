Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793651483;
	b=o3jbdN0KoFok5q94uw5w3lSrolCPRDqlfnydyupZ89HzrbyVY277M3+uxxjIrJqQyZWs
	 5W+yWQiP1SP7tXhcXGUk8lTB0lHpokkiQy74InFRNve8bZVexc0AYr6D6Pp8LTlYmo4Nz
	 YtWlw/zT/DWrWSTr5tmmwq2J4FeceCJmFQ0Ka/nnzsaQ1iIwWSmC71KUUDMbc0egeUftP
	 D2tEc5fbSJ89x2Ew+sehf44pWScKhSUuFPuXUj4m73AFaS/sNU+nXQUtb39NM3D/gS68e
	 keVzqkDaMULvD6ORaRFRgoM6EL8bp8/bdEG3wiRZhHK861gsyTaMIUd7oKhu7S6f2OQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793651483;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=7xcbpz3qOJJh9IzKBxf6M4aE91StvLXvkrlMkjuFTNk=;
	b=fhRobSuDw88emNAZwwSweDnJ3+rlxpZJ9rTlY5CneLxB8kHI4B2zk3Kj2uDgxCnsVrdo
	 pfHQCszuTy7QQyEOG1jJqu876CL1RjUGGTgEa+5I66WeTDzKdlCJ03x8i6Z6Hk8HH8B2S
	 LlUHn7baZKZem68fcnYLi4p0GG5BdsQvTjTvuPhBtGJNFVKwNo8pkwpVJWcY20gmwJ/zL
	 6U5gpnoIM8uKD+6SuAEsEUIGm4f0+eZCXJNNmhMV5akcoUfPwTXYJFQq6ZKH86zQbZs9l
	 BwJVCMPynN+SzMvdK1kyNeuTwFCXOhmDy6p2lRLYR8oeA6WGGrZzLP2jHDr6g8KUKIg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VopOkLVv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88A39606D81D
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 20:31:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VopOkLVv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0738B1F00A17;
	Mon,  2 Nov 2026 20:31:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793651483;
	bh=7xcbpz3qOJJh9IzKBxf6M4aE91StvLXvkrlMkjuFTNk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VopOkLVvAoeHj/ttgzhKO+EMTrSCQLY+Ae9/8m+ZRIcTxVE3U567yNXiwTUkJO/s9
	 he6wslcPQSX4OcNYb+H/Zkri/FWnl0KsUt10wAJhkKR32wSTz0zfLRl4bEzz//c8Ty
	 eEZRje52Wk57Vu75xRQpoNe4fkt91sMzXk+VI4kIMN2QNMSbd3ahIXJzPbrXlfc6i/
	 U5nkxpfHriVukTIjXy741AIYfD+P87psa+U41dKLQkfck3jxqiOYnfVMwl4nvQDmX2
	 W65U/Vpsv2NLXWDjqMD6kUI+wsVDnSZb/jatCw0B2T2tqe47yCvUJTokzyi0SuQoLq
	 KZZg3yBg9MJQQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/4] NFS: don't release the open context of a failed write from writeback
Date: Mon,  2 Nov 2026 15:31:17 -0500
Message-ID: <20261102203120.14600-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261102203120.14600-1-snitzer@kernel.org>
References: <20261102203120.14600-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
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
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/inode.c         | 37 ++++++++++++++++++++++++++++++++++---
 fs/nfs/internal.h      |  1 +
 fs/nfs/write.c         |  5 +++++
 include/linux/nfs_fs.h |  2 ++
 4 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe7a05dec02fc..67114c4344942 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1237,13 +1237,11 @@ struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx)
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
@@ -1260,12 +1258,45 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
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
index f6f7f70b21e24..cdf77ca012cee 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -527,6 +527,7 @@ extern int __init register_nfs_fs(void);
 extern void __exit unregister_nfs_fs(void);
 extern bool nfs_sb_active(struct super_block *sb);
 extern void nfs_sb_deactive(struct super_block *sb);
+void put_nfs_open_context_async(struct nfs_open_context *ctx);
 extern int nfs_client_for_each_server(struct nfs_client *clp,
 				      int (*fn)(struct nfs_server *, void *),
 				      void *data);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7f173dbbeb9d9..f38bbebffe4d7 100644
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
index b85a73ae7919f..32a46de106cd5 100644
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

