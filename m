Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461AbbJNSXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:23:39 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@poochiereds.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Subject: [PATCH 10/10] NFS: Deferred unlocks - always unlock on FL_CLOSE
Date: Wed, 14 Oct 2015 14:23:37 -0400
Message-Id: <93c4aa68a777b232075b9b8252d671635bb1c320.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
In-Reply-To: <cover.1444846590.git.bcodding@redhat.com>
References: <cover.1444846590.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS unlock procedures will wait for IO to complete before sending an unlock.
In the case that this wait is interrupted, an unlock may never be sent if
the unlock is part of cleaning up locks during a close.  This lost lock can
then prevent other clients from locking the file.

Fix this by deferring an unlock that should wait for IO during FL_CLOSE by
copying it to a list on the nfs_lock_context, which can then be used to
release the lock when the IO has completed.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c          |   36 +++++++++++++++++++++++++++++++++++-
 fs/nfs/inode.c         |    1 +
 fs/nfs/pagelist.c      |   23 ++++++++++++++++++++---
 include/linux/nfs_fs.h |    7 +++++++
 4 files changed, 63 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d16c50f..460311a 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -738,6 +738,36 @@ out_noconflict:
 }
 
 static int
+defer_unlk(struct nfs_lock_context *l_ctx, int cmd, struct file_lock *fl)
+{
+	struct inode *inode = d_inode(l_ctx->open_context->dentry);
+	struct nfs_io_counter *c = &l_ctx->io_count;
+	struct nfs_deferred_unlock *dunlk;
+	int status = 0;
+
+	if (atomic_read(&c->io_count) == 0)
+		return 0;
+
+	/* free in nfs_iocounter_dec */
+	dunlk = kmalloc(sizeof(*dunlk), GFP_NOFS);
+	if (dunlk == NULL)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&dunlk->list);
+	dunlk->cmd = cmd;
+	memcpy(&dunlk->fl, fl, sizeof(dunlk->fl));
+	spin_lock(&inode->i_lock);
+	if (atomic_read(&c->io_count) != 0) {
+		list_add_tail(&dunlk->list, &l_ctx->dunlk_list);
+		status = -EINPROGRESS;
+	} else {
+		kfree(dunlk);
+	}
+	spin_unlock(&inode->i_lock);
+	return status;
+}
+
+static int
 do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
@@ -753,7 +783,11 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 
 	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
 	if (!IS_ERR(l_ctx)) {
-		status = nfs_iocounter_wait(&l_ctx->io_count);
+		if (fl->fl_flags & FL_CLOSE)
+			status = defer_unlk(l_ctx, cmd, fl);
+		else
+			status = nfs_iocounter_wait(&l_ctx->io_count);
+
 		nfs_put_lock_context(l_ctx);
 		if (status < 0)
 			return status;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 326d9e1..af4f846 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -696,6 +696,7 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 	l_ctx->lockowner.l_owner = current->files;
 	l_ctx->lockowner.l_pid = current->tgid;
 	INIT_LIST_HEAD(&l_ctx->list);
+	INIT_LIST_HEAD(&l_ctx->dunlk_list);
 	nfs_iocounter_init(&l_ctx->io_count);
 }
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index fe3ddd2..17dd6c0 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -108,9 +108,26 @@ nfs_iocounter_inc(struct nfs_io_counter *c)
 }
 
 static void
-nfs_iocounter_dec(struct nfs_io_counter *c)
+nfs_iocounter_dec(struct nfs_lock_context *l_ctx)
 {
-	if (atomic_dec_and_test(&c->io_count)) {
+	struct nfs_io_counter *c = &l_ctx->io_count;
+	struct inode *inode = d_inode(l_ctx->open_context->dentry);
+
+	if (atomic_dec_and_lock(&c->io_count, &inode->i_lock)) {
+		if (unlikely(!list_empty(&l_ctx->dunlk_list))) {
+			struct nfs_deferred_unlock *dunlk, *tmp;
+			LIST_HEAD(dunlk_list);
+			list_replace_init(&l_ctx->dunlk_list, &dunlk_list);
+			spin_unlock(&inode->i_lock);
+
+			list_for_each_entry_safe(dunlk, tmp, &dunlk_list, list) {
+				NFS_PROTO(inode)->lock(l_ctx->open_context, dunlk->cmd, &dunlk->fl);
+				locks_release_private(&dunlk->fl);
+				kfree(dunlk);
+			}
+		} else {
+			spin_unlock(&inode->i_lock);
+		}
 		clear_bit(NFS_IO_INPROGRESS, &c->flags);
 		smp_mb__after_atomic();
 		wake_up_bit(&c->flags, NFS_IO_INPROGRESS);
@@ -431,7 +448,7 @@ static void nfs_clear_request(struct nfs_page *req)
 		req->wb_page = NULL;
 	}
 	if (l_ctx != NULL) {
-		nfs_iocounter_dec(&l_ctx->io_count);
+		nfs_iocounter_dec(l_ctx);
 		nfs_put_lock_context(l_ctx);
 		req->wb_lock_context = NULL;
 	}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c0e9614..ba36498 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -66,12 +66,19 @@ struct nfs_io_counter {
 	atomic_t io_count;
 };
 
+struct nfs_deferred_unlock {
+	struct list_head list;
+	int cmd;
+	struct file_lock fl;
+};
+
 struct nfs_lock_context {
 	atomic_t count;
 	struct list_head list;
 	struct nfs_open_context *open_context;
 	struct nfs_lockowner lockowner;
 	struct nfs_io_counter io_count;
+	struct list_head dunlk_list;
 };
 
 struct nfs4_state;
-- 
1.7.1

