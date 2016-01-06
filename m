Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbcAFPkT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2016 10:40:19 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, David Howells <dhowells@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Use wait_on_atomic_t() for unlock after readahead
Date: Wed,  6 Jan 2016 10:40:18 -0500
Message-Id: <2eb3d218075ac12cf0a9b18c75df03b15ed52491.1452094588.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The use of wait_on_atomic_t() for waiting on I/O to complete before
unlocking allows us to git rid of the NFS_IO_INPROGRESS flag, and thus the
nfs_iocounter's flags member, and finally the nfs_iocounter altogether.
The count of I/O is moved to the lock context, and the counter
increment/decrement functions become simple enough to open-code.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c          |    2 +-
 fs/nfs/inode.c         |   18 ++++++++++++------
 fs/nfs/internal.h      |    9 ++-------
 fs/nfs/pagelist.c      |   48 +++++++-----------------------------------------
 include/linux/nfs_fs.h |    8 +-------
 5 files changed, 23 insertions(+), 62 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 93e2364..37ded36 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -756,7 +756,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 
 	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
 	if (!IS_ERR(l_ctx)) {
-		status = nfs_iocounter_wait(&l_ctx->io_count);
+		status = nfs_iocounter_wait(l_ctx);
 		nfs_put_lock_context(l_ctx);
 		if (status < 0)
 			return status;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c7e8b87..c1bfee4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -71,19 +71,25 @@ nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
 	return nfs_fileid_to_ino_t(fattr->fileid);
 }
 
-/**
- * nfs_wait_bit_killable - helper for functions that are sleeping on bit locks
- * @word: long word containing the bit lock
- */
-int nfs_wait_bit_killable(struct wait_bit_key *key, int mode)
+static int nfs_wait_killable(int mode)
 {
 	freezable_schedule_unsafe();
 	if (signal_pending_state(mode, current))
 		return -ERESTARTSYS;
 	return 0;
 }
+
+int nfs_wait_bit_killable(struct wait_bit_key *key, int mode)
+{
+	return nfs_wait_killable(mode);
+}
 EXPORT_SYMBOL_GPL(nfs_wait_bit_killable);
 
+int nfs_wait_atomic_killable(atomic_t *p)
+{
+	return nfs_wait_killable(TASK_KILLABLE);
+}
+
 /**
  * nfs_compat_user_ino64 - returns the user-visible inode number
  * @fileid: 64-bit fileid
@@ -699,7 +705,7 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 	l_ctx->lockowner.l_owner = current->files;
 	l_ctx->lockowner.l_pid = current->tgid;
 	INIT_LIST_HEAD(&l_ctx->list);
-	nfs_iocounter_init(&l_ctx->io_count);
+	atomic_set(&l_ctx->io_count, 0);
 }
 
 static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9dea85f..6c9b72f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -238,7 +238,7 @@ extern void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 			      struct nfs_pgio_header *hdr,
 			      void (*release)(struct nfs_pgio_header *hdr));
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos);
-int nfs_iocounter_wait(struct nfs_io_counter *c);
+int nfs_iocounter_wait(struct nfs_lock_context *l_ctx);
 
 extern const struct nfs_pageio_ops nfs_pgio_rw_ops;
 struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *);
@@ -252,12 +252,6 @@ void nfs_free_request(struct nfs_page *req);
 struct nfs_pgio_mirror *
 nfs_pgio_current_mirror(struct nfs_pageio_descriptor *desc);
 
-static inline void nfs_iocounter_init(struct nfs_io_counter *c)
-{
-	c->flags = 0;
-	atomic_set(&c->io_count, 0);
-}
-
 static inline bool nfs_pgio_has_mirroring(struct nfs_pageio_descriptor *desc)
 {
 	WARN_ON_ONCE(desc->pg_mirror_count < 1);
@@ -380,6 +374,7 @@ extern void nfs_clear_inode(struct inode *);
 extern void nfs_evict_inode(struct inode *);
 void nfs_zap_acl_cache(struct inode *inode);
 extern int nfs_wait_bit_killable(struct wait_bit_key *key, int mode);
+extern int nfs_wait_atomic_killable(atomic_t *p);
 
 /* super.c */
 extern const struct super_operations nfs_sops;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 452a011..abf1dad 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -101,53 +101,18 @@ nfs_page_free(struct nfs_page *p)
 	kmem_cache_free(nfs_page_cachep, p);
 }
 
-static void
-nfs_iocounter_inc(struct nfs_io_counter *c)
-{
-	atomic_inc(&c->io_count);
-}
-
-static void
-nfs_iocounter_dec(struct nfs_io_counter *c)
-{
-	if (atomic_dec_and_test(&c->io_count)) {
-		clear_bit(NFS_IO_INPROGRESS, &c->flags);
-		smp_mb__after_atomic();
-		wake_up_bit(&c->flags, NFS_IO_INPROGRESS);
-	}
-}
-
-static int
-__nfs_iocounter_wait(struct nfs_io_counter *c)
-{
-	wait_queue_head_t *wq = bit_waitqueue(&c->flags, NFS_IO_INPROGRESS);
-	DEFINE_WAIT_BIT(q, &c->flags, NFS_IO_INPROGRESS);
-	int ret = 0;
-
-	do {
-		prepare_to_wait(wq, &q.wait, TASK_KILLABLE);
-		set_bit(NFS_IO_INPROGRESS, &c->flags);
-		if (atomic_read(&c->io_count) == 0)
-			break;
-		ret = nfs_wait_bit_killable(&q.key, TASK_KILLABLE);
-	} while (atomic_read(&c->io_count) != 0 && !ret);
-	finish_wait(wq, &q.wait);
-	return ret;
-}
-
 /**
  * nfs_iocounter_wait - wait for i/o to complete
- * @c: nfs_io_counter to use
+ * @l_ctx: nfs_lock_context with io_counter to use
  *
  * returns -ERESTARTSYS if interrupted by a fatal signal.
  * Otherwise returns 0 once the io_count hits 0.
  */
 int
-nfs_iocounter_wait(struct nfs_io_counter *c)
+nfs_iocounter_wait(struct nfs_lock_context *l_ctx)
 {
-	if (atomic_read(&c->io_count) == 0)
-		return 0;
-	return __nfs_iocounter_wait(c);
+	return wait_on_atomic_t(&l_ctx->io_count, nfs_wait_atomic_killable,
+			TASK_KILLABLE);
 }
 
 /*
@@ -370,7 +335,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 		return ERR_CAST(l_ctx);
 	}
 	req->wb_lock_context = l_ctx;
-	nfs_iocounter_inc(&l_ctx->io_count);
+	atomic_inc(&l_ctx->io_count);
 
 	/* Initialize the request struct. Initially, we assume a
 	 * long write-back delay. This will be adjusted in
@@ -431,7 +396,8 @@ static void nfs_clear_request(struct nfs_page *req)
 		req->wb_page = NULL;
 	}
 	if (l_ctx != NULL) {
-		nfs_iocounter_dec(&l_ctx->io_count);
+		if (atomic_dec_and_test(&l_ctx->io_count))
+			wake_up_atomic_t(&l_ctx->io_count);
 		nfs_put_lock_context(l_ctx);
 		req->wb_lock_context = NULL;
 	}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c0e9614..de6ba5a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -60,18 +60,12 @@ struct nfs_lockowner {
 	pid_t l_pid;
 };
 
-#define NFS_IO_INPROGRESS 0
-struct nfs_io_counter {
-	unsigned long flags;
-	atomic_t io_count;
-};
-
 struct nfs_lock_context {
 	atomic_t count;
 	struct list_head list;
 	struct nfs_open_context *open_context;
 	struct nfs_lockowner lockowner;
-	struct nfs_io_counter io_count;
+	atomic_t io_count;
 };
 
 struct nfs4_state;
-- 
1.7.1

