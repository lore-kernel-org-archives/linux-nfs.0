Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.229]:37279 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753436AbbAVO3S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:29:18 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 11/13] locks: keep a count of locks on the flctx lists
Date: Thu, 22 Jan 2015 09:27:55 -0500
Message-Id: <1421936877-27529-12-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

This makes things a bit more efficient in the cifs and ceph lock
pushing code.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 fs/ceph/locks.c    | 11 ++---------
 fs/cifs/file.c     | 14 ++++----------
 fs/locks.c         | 45 +++++++++++++++++++++++++++++----------------
 include/linux/fs.h |  3 +++
 4 files changed, 38 insertions(+), 35 deletions(-)

diff --git a/fs/ceph/locks.c b/fs/ceph/locks.c
index 0303da8e3233..06ea5cd05cd9 100644
--- a/fs/ceph/locks.c
+++ b/fs/ceph/locks.c
@@ -242,12 +242,9 @@ int ceph_flock(struct file *file, int cmd, struct file_lock *fl)
 /*
  * Fills in the passed counter variables, so you can prepare pagelist metadata
  * before calling ceph_encode_locks.
- *
- * FIXME: add counters to struct file_lock_context so we don't need to do this?
  */
 void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
 {
-	struct file_lock *lock;
 	struct file_lock_context *ctx;
 
 	*fcntl_count = 0;
@@ -255,12 +252,8 @@ void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
 
 	ctx = inode->i_flctx;
 	if (ctx) {
-		spin_lock(&ctx->flc_lock);
-		list_for_each_entry(lock, &ctx->flc_posix, fl_list)
-			++(*fcntl_count);
-		list_for_each_entry(lock, &ctx->flc_flock, fl_list)
-			++(*flock_count);
-		spin_unlock(&ctx->flc_lock);
+		*fcntl_count = ctx->flc_posix_cnt;
+		*flock_count = ctx->flc_flock_cnt;
 	}
 	dout("counted %d flock locks and %d fcntl locks",
 	     *flock_count, *fcntl_count);
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index b65166eb111e..8c2ca6f62bad 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1125,7 +1125,7 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 	struct cifs_tcon *tcon = tlink_tcon(cfile->tlink);
 	struct file_lock *flock;
 	struct file_lock_context *flctx = inode->i_flctx;
-	unsigned int count = 0, i;
+	unsigned int i;
 	int rc = 0, xid, type;
 	struct list_head locks_to_send, *el;
 	struct lock_to_push *lck, *tmp;
@@ -1136,20 +1136,14 @@ cifs_push_posix_locks(struct cifsFileInfo *cfile)
 	if (!flctx)
 		goto out;
 
-	spin_lock(&flctx->flc_lock);
-	list_for_each(el, &flctx->flc_posix) {
-		count++;
-	}
-	spin_unlock(&flctx->flc_lock);
-
 	INIT_LIST_HEAD(&locks_to_send);
 
 	/*
-	 * Allocating count locks is enough because no FL_POSIX locks can be
-	 * added to the list while we are holding cinode->lock_sem that
+	 * Allocating flc_posix_cnt locks is enough because no FL_POSIX locks
+	 * can be added to the list while we are holding cinode->lock_sem that
 	 * protects locking operations of this inode.
 	 */
-	for (i = 0; i < count; i++) {
+	for (i = 0; i < flctx->flc_posix_cnt; i++) {
 		lck = kmalloc(sizeof(struct lock_to_push), GFP_KERNEL);
 		if (!lck) {
 			rc = -ENOMEM;
diff --git a/fs/locks.c b/fs/locks.c
index 864f2460a0ad..bd578700342d 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -681,18 +681,21 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 }
 
 static void
-locks_insert_lock_ctx(struct file_lock *fl, struct list_head *before)
+locks_insert_lock_ctx(struct file_lock *fl, int *counter,
+		      struct list_head *before)
 {
 	fl->fl_nspid = get_pid(task_tgid(current));
 	list_add_tail(&fl->fl_list, before);
+	++*counter;
 	locks_insert_global_locks(fl);
 }
 
 static void
-locks_unlink_lock_ctx(struct file_lock *fl)
+locks_unlink_lock_ctx(struct file_lock *fl, int *counter)
 {
 	locks_delete_global_locks(fl);
 	list_del_init(&fl->fl_list);
+	--*counter;
 	if (fl->fl_nspid) {
 		put_pid(fl->fl_nspid);
 		fl->fl_nspid = NULL;
@@ -701,9 +704,10 @@ locks_unlink_lock_ctx(struct file_lock *fl)
 }
 
 static void
-locks_delete_lock_ctx(struct file_lock *fl, struct list_head *dispose)
+locks_delete_lock_ctx(struct file_lock *fl, int *counter,
+		      struct list_head *dispose)
 {
-	locks_unlink_lock_ctx(fl);
+	locks_unlink_lock_ctx(fl, counter);
 	if (dispose)
 		list_add(&fl->fl_list, dispose);
 	else
@@ -891,7 +895,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 		if (request->fl_type == fl->fl_type)
 			goto out;
 		found = true;
-		locks_delete_lock_ctx(fl, &dispose);
+		locks_delete_lock_ctx(fl, &ctx->flc_flock_cnt, &dispose);
 		break;
 	}
 
@@ -925,7 +929,7 @@ find_conflict:
 	if (request->fl_flags & FL_ACCESS)
 		goto out;
 	locks_copy_lock(new_fl, request);
-	locks_insert_lock_ctx(new_fl, &ctx->flc_flock);
+	locks_insert_lock_ctx(new_fl, &ctx->flc_flock_cnt, &ctx->flc_flock);
 	new_fl = NULL;
 	error = 0;
 
@@ -1042,7 +1046,8 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			else
 				request->fl_end = fl->fl_end;
 			if (added) {
-				locks_delete_lock_ctx(fl, &dispose);
+				locks_delete_lock_ctx(fl, &ctx->flc_posix_cnt,
+							&dispose);
 				continue;
 			}
 			request = fl;
@@ -1071,7 +1076,8 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				 * one (This may happen several times).
 				 */
 				if (added) {
-					locks_delete_lock_ctx(fl, &dispose);
+					locks_delete_lock_ctx(fl,
+						&ctx->flc_posix_cnt, &dispose);
 					continue;
 				}
 				/*
@@ -1087,8 +1093,10 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				locks_copy_lock(new_fl, request);
 				request = new_fl;
 				new_fl = NULL;
-				locks_insert_lock_ctx(request, &fl->fl_list);
-				locks_delete_lock_ctx(fl, &dispose);
+				locks_insert_lock_ctx(request,
+					&ctx->flc_posix_cnt, &fl->fl_list);
+				locks_delete_lock_ctx(fl,
+					&ctx->flc_posix_cnt, &dispose);
 				added = true;
 			}
 		}
@@ -1116,7 +1124,8 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			goto out;
 		}
 		locks_copy_lock(new_fl, request);
-		locks_insert_lock_ctx(new_fl, &fl->fl_list);
+		locks_insert_lock_ctx(new_fl, &ctx->flc_posix_cnt,
+					&fl->fl_list);
 		new_fl = NULL;
 	}
 	if (right) {
@@ -1127,7 +1136,8 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			left = new_fl2;
 			new_fl2 = NULL;
 			locks_copy_lock(left, right);
-			locks_insert_lock_ctx(left, &fl->fl_list);
+			locks_insert_lock_ctx(left, &ctx->flc_posix_cnt,
+						&fl->fl_list);
 		}
 		right->fl_start = request->fl_end + 1;
 		locks_wake_up_blocks(right);
@@ -1311,6 +1321,7 @@ static void lease_clear_pending(struct file_lock *fl, int arg)
 /* We already had a lease on this file; just change its type */
 int lease_modify(struct file_lock *fl, int arg, struct list_head *dispose)
 {
+	struct file_lock_context *flctx;
 	int error = assign_type(fl, arg);
 
 	if (error)
@@ -1320,6 +1331,7 @@ int lease_modify(struct file_lock *fl, int arg, struct list_head *dispose)
 	if (arg == F_UNLCK) {
 		struct file *filp = fl->fl_file;
 
+		flctx = file_inode(filp)->i_flctx;
 		f_delown(filp);
 		filp->f_owner.signum = 0;
 		fasync_helper(0, fl->fl_file, 0, &fl->fl_fasync);
@@ -1327,7 +1339,7 @@ int lease_modify(struct file_lock *fl, int arg, struct list_head *dispose)
 			printk(KERN_ERR "locks_delete_lock: fasync == %p\n", fl->fl_fasync);
 			fl->fl_fasync = NULL;
 		}
-		locks_delete_lock_ctx(fl, dispose);
+		locks_delete_lock_ctx(fl, &flctx->flc_lease_cnt, dispose);
 	}
 	return 0;
 }
@@ -1442,7 +1454,8 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 			fl->fl_downgrade_time = break_time;
 		}
 		if (fl->fl_lmops->lm_break(fl))
-			locks_delete_lock_ctx(fl, &dispose);
+			locks_delete_lock_ctx(fl, &ctx->flc_lease_cnt,
+						&dispose);
 	}
 
 	if (list_empty(&ctx->flc_lease))
@@ -1678,7 +1691,7 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	if (!leases_enable)
 		goto out;
 
-	locks_insert_lock_ctx(lease, &ctx->flc_lease);
+	locks_insert_lock_ctx(lease, &ctx->flc_lease_cnt, &ctx->flc_lease);
 	/*
 	 * The check in break_lease() is lockless. It's possible for another
 	 * open to race in after we did the earlier check for a conflicting
@@ -1691,7 +1704,7 @@ generic_add_lease(struct file *filp, long arg, struct file_lock **flp, void **pr
 	smp_mb();
 	error = check_conflicting_open(dentry, arg);
 	if (error) {
-		locks_unlink_lock_ctx(lease);
+		locks_unlink_lock_ctx(lease, &ctx->flc_lease_cnt);
 		goto out;
 	}
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 94e706a0a408..f87cb2f03103 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -972,6 +972,9 @@ struct file_lock_context {
 	struct list_head	flc_flock;
 	struct list_head	flc_posix;
 	struct list_head	flc_lease;
+	int			flc_flock_cnt;
+	int			flc_posix_cnt;
+	int			flc_lease_cnt;
 };
 
 /* The following constant reflects the upper bound of the file/locking space */
-- 
2.1.0

