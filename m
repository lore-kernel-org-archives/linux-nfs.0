Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbbL1Q2I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Dec 2015 11:28:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 09/10] NFS: Deferred unlocks - always unlock on FL_CLOSE
Date: Mon, 28 Dec 2015 11:28:05 -0500
Message-Id: <17159b5f35d7b3b3829c53f2bc7fa0f039d4a563.1451319354.git.bcodding@redhat.com>
In-Reply-To: <cover.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
In-Reply-To: <cover.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS unlock procedures will wait for IO to complete before sending an
unlock.  In the case that this wait is interrupted, an unlock may never be
sent if the unlock is in the close path.

On NFSv3, this lost lock will then cause other clients to be blocked from
acquiring a conflicting lock indefinitely.  On NFSv4, the nfs4_lock_state
may never be released resulting in the use of invalid stateids for lock
operations after a subsequent open by the same process.

Fix this by setting a flag on the lock context to send an unlock for the
entire file as soon as outstanding IO for that lock context has completed.
A call into NFS_PROTO(inode)->lock() for both posix and flock style locks
is made no matter which original lock type was held, since the FL_EXISTS
check will return the operation early for a non-existent lock.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c          |   26 +++++++++++++++++++++-----
 fs/nfs/inode.c         |   22 ++++++++++++++++++++++
 fs/nfs/pagelist.c      |    8 ++++++--
 include/linux/nfs_fs.h |    3 +++
 4 files changed, 52 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5dec0fb..57fbbb1 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -743,6 +743,22 @@ static int do_vfs_lock(struct file *file, struct file_lock *fl)
 }
 
 static int
+defer_close_unlk(struct inode *inode, struct nfs_lock_context *l_ctx)
+{
+	struct nfs_io_counter *c = &l_ctx->io_count;
+	int status = 0;
+
+	if (test_bit(NFS_LOCK_CLOSE_UNLOCK, &l_ctx->flags))
+		return -EINPROGRESS;
+
+	if (atomic_read(&c->io_count) != 0) {
+		set_bit(NFS_LOCK_CLOSE_UNLOCK, &l_ctx->flags);
+		status = -EINPROGRESS;
+	}
+	return status;
+}
+
+static int
 do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
@@ -758,16 +774,16 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 
 	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
 	if (!IS_ERR(l_ctx)) {
-		status = nfs_iocounter_wait(&l_ctx->io_count);
+		if (fl->fl_flags & FL_CLOSE)
+			status = defer_close_unlk(inode, l_ctx);
+		else
+			status = nfs_iocounter_wait(&l_ctx->io_count);
+
 		nfs_put_lock_context(l_ctx);
 		if (status < 0)
 			return status;
 	}
 
-	/* NOTE: special case
-	 * 	If we're signalled while cleaning up locks on process exit, we
-	 * 	still need to complete the unlock.
-	 */
 	/*
 	 * Use local locking if mounted with "-onolock" or with appropriate
 	 * "-olocal_lock="
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 31b0a52..065c8a9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -699,6 +699,7 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 	l_ctx->lockowner.l_owner = current->files;
 	l_ctx->lockowner.l_pid = current->tgid;
 	INIT_LIST_HEAD(&l_ctx->list);
+	l_ctx->flags = 0;
 	nfs_iocounter_init(&l_ctx->io_count);
 }
 
@@ -759,6 +760,27 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 }
 EXPORT_SYMBOL_GPL(nfs_put_lock_context);
 
+void nfs_unlock_lock_context(struct nfs_lock_context *l_ctx)
+{
+	struct inode *inode = d_inode(l_ctx->open_context->dentry);
+	struct file_lock fl = {
+		.fl_type = F_UNLCK,
+		.fl_start = 0,
+		.fl_end = OFFSET_MAX,
+		.fl_owner = l_ctx->lockowner.l_owner,
+		.fl_pid = l_ctx->lockowner.l_pid,
+	};
+
+	fl.fl_flags = FL_POSIX | FL_CLOSE;
+	NFS_PROTO(inode)->lock(l_ctx->open_context, F_SETLK, &fl);
+	if (fl.fl_ops)
+		fl.fl_ops->fl_release_private(&fl);
+	fl.fl_flags = FL_FLOCK | FL_CLOSE;
+	NFS_PROTO(inode)->lock(l_ctx->open_context, F_SETLK, &fl);
+	if (fl.fl_ops)
+		fl.fl_ops->fl_release_private(&fl);
+}
+
 /**
  * nfs_close_context - Common close_context() routine NFSv2/v3
  * @ctx: pointer to context
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index fe3ddd2..f914fbe 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -108,9 +108,13 @@ nfs_iocounter_inc(struct nfs_io_counter *c)
 }
 
 static void
-nfs_iocounter_dec(struct nfs_io_counter *c)
+nfs_iocounter_dec(struct nfs_lock_context *l_ctx)
 {
+	struct nfs_io_counter *c = &l_ctx->io_count;
+
 	if (atomic_dec_and_test(&c->io_count)) {
+		if (test_and_clear_bit(NFS_LOCK_CLOSE_UNLOCK, &l_ctx->flags))
+			nfs_unlock_lock_context(l_ctx);
 		clear_bit(NFS_IO_INPROGRESS, &c->flags);
 		smp_mb__after_atomic();
 		wake_up_bit(&c->flags, NFS_IO_INPROGRESS);
@@ -431,7 +435,7 @@ static void nfs_clear_request(struct nfs_page *req)
 		req->wb_page = NULL;
 	}
 	if (l_ctx != NULL) {
-		nfs_iocounter_dec(&l_ctx->io_count);
+		nfs_iocounter_dec(l_ctx);
 		nfs_put_lock_context(l_ctx);
 		req->wb_lock_context = NULL;
 	}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c0e9614..b105144 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -72,6 +72,8 @@ struct nfs_lock_context {
 	struct nfs_open_context *open_context;
 	struct nfs_lockowner lockowner;
 	struct nfs_io_counter io_count;
+#define NFS_LOCK_CLOSE_UNLOCK 0
+	unsigned long flags;
 };
 
 struct nfs4_state;
@@ -373,6 +375,7 @@ extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context
 extern void nfs_file_clear_open_context(struct file *flip);
 extern struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx);
 extern void nfs_put_lock_context(struct nfs_lock_context *l_ctx);
+extern void nfs_unlock_lock_context(struct nfs_lock_context *l_ctx);
 extern u64 nfs_compat_user_ino64(u64 fileid);
 extern void nfs_fattr_init(struct nfs_fattr *fattr);
 extern void nfs_fattr_set_barrier(struct nfs_fattr *fattr);
-- 
1.7.1

