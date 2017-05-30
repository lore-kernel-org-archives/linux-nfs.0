Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34520 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750985AbdE3Qbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 12:31:43 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org
Cc: Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] fs/locks: Set fl_nspid at file_lock allocation
Date: Tue, 30 May 2017 12:31:39 -0400
Message-Id: <023c1dee0b4aa73bdadb32ae1a614a33733bd8ec.1496161312.git.bcodding@redhat.com>
In-Reply-To: <cover.1496161312.git.bcodding@redhat.com>
References: <cover.1496161312.git.bcodding@redhat.com>
In-Reply-To: <cover.1496161312.git.bcodding@redhat.com>
References: <cover.1496161312.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit c69899a17ca4 "NFSv4: Update of VFS byte range lock must be
atomic with the stateid update", NFSv4 has been inserting locks in rpciod
worker context.  The result is that the file_lock's fl_nspid is the
kworker's pid instead of the original userspace pid.  We can fix that up by
setting fl_nspid in locks_allocate_lock, and tranfer it to the file_lock
that's eventually recorded.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c | 29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index d7daa6c8932f..0f5a461b8da6 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -249,7 +249,9 @@ locks_dump_ctx_list(struct list_head *list, char *list_type)
 	struct file_lock *fl;
 
 	list_for_each_entry(fl, list, fl_list) {
-		pr_warn("%s: fl_owner=%p fl_flags=0x%x fl_type=0x%x fl_pid=%u\n", list_type, fl->fl_owner, fl->fl_flags, fl->fl_type, fl->fl_pid);
+		pr_warn("%s: fl_owner=%p fl_flags=0x%x fl_type=0x%x fl_pid=%u fl_nspid=%u\n",
+			list_type, fl->fl_owner, fl->fl_flags, fl->fl_type,
+			fl->fl_pid, pid_vnr(fl->fl_nspid));
 	}
 }
 
@@ -294,8 +296,10 @@ struct file_lock *locks_alloc_lock(void)
 {
 	struct file_lock *fl = kmem_cache_zalloc(filelock_cache, GFP_KERNEL);
 
-	if (fl)
+	if (fl) {
 		locks_init_lock_heads(fl);
+		fl->fl_nspid = get_pid(task_tgid(current));
+	}
 
 	return fl;
 }
@@ -328,6 +332,8 @@ void locks_free_lock(struct file_lock *fl)
 	BUG_ON(!hlist_unhashed(&fl->fl_link));
 
 	locks_release_private(fl);
+	if (fl->fl_nspid)
+		put_pid(fl->fl_nspid);
 	kmem_cache_free(filelock_cache, fl);
 }
 EXPORT_SYMBOL(locks_free_lock);
@@ -357,8 +363,15 @@ EXPORT_SYMBOL(locks_init_lock);
  */
 void locks_copy_conflock(struct file_lock *new, struct file_lock *fl)
 {
+	struct pid *replace_pid = new->fl_nspid;
+
 	new->fl_owner = fl->fl_owner;
 	new->fl_pid = fl->fl_pid;
+	if (fl->fl_nspid) {
+		new->fl_nspid = get_pid(fl->fl_nspid);
+		if (replace_pid)
+			put_pid(replace_pid);
+	}
 	new->fl_file = NULL;
 	new->fl_flags = fl->fl_flags;
 	new->fl_type = fl->fl_type;
@@ -733,7 +746,6 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 static void
 locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
 {
-	fl->fl_nspid = get_pid(task_tgid(current));
 	list_add_tail(&fl->fl_list, before);
 	locks_insert_global_locks(fl);
 }
@@ -743,10 +755,6 @@ locks_unlink_lock_ctx(struct file_lock *fl)
 {
 	locks_delete_global_locks(fl);
 	list_del_init(&fl->fl_list);
-	if (fl->fl_nspid) {
-		put_pid(fl->fl_nspid);
-		fl->fl_nspid = NULL;
-	}
 	locks_wake_up_blocks(fl);
 }
 
@@ -823,8 +831,6 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 	list_for_each_entry(cfl, &ctx->flc_posix, fl_list) {
 		if (posix_locks_conflict(fl, cfl)) {
 			locks_copy_conflock(fl, cfl);
-			if (cfl->fl_nspid)
-				fl->fl_pid = pid_vnr(cfl->fl_nspid);
 			goto out;
 		}
 	}
@@ -2452,6 +2458,7 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 	lock.fl_end = OFFSET_MAX;
 	lock.fl_owner = owner;
 	lock.fl_pid = current->tgid;
+	lock.fl_nspid = get_pid(task_tgid(current));
 	lock.fl_file = filp;
 	lock.fl_ops = NULL;
 	lock.fl_lmops = NULL;
@@ -2460,6 +2467,7 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 
 	if (lock.fl_ops && lock.fl_ops->fl_release_private)
 		lock.fl_ops->fl_release_private(&lock);
+	put_pid(lock.fl_nspid);
 	trace_locks_remove_posix(inode, &lock, error);
 }
 
@@ -2482,6 +2490,8 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
 	if (list_empty(&flctx->flc_flock))
 		return;
 
+	fl.fl_nspid = get_pid(task_tgid(current));
+
 	if (filp->f_op->flock && is_remote_lock(filp))
 		filp->f_op->flock(filp, F_SETLKW, &fl);
 	else
@@ -2489,6 +2499,7 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
 
 	if (fl.fl_ops && fl.fl_ops->fl_release_private)
 		fl.fl_ops->fl_release_private(&fl);
+	put_pid(fl.fl_nspid);
 }
 
 /* The i_flctx must be valid when calling into here */
-- 
2.9.3

