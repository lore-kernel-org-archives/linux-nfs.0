Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422697Ab3FUM7H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jun 2013 08:59:07 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v4 14/14] locks: move file_lock_list to a set of percpu hlist_heads and convert file_lock_lock to an lglock
Date: Fri, 21 Jun 2013 08:58:22 -0400
Message-Id: <1371819502-26363-15-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
References: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The file_lock_list is only used for /proc/locks. The vastly common case
is for locks to be put onto the list and come off again, without ever
being traversed.

Help optimize for this use-case by moving to percpu hlist_head-s. At the
same time, we can make the locking less contentious by moving to an
lglock. When iterating over the lists for /proc/locks, we must take the
global lock and then iterate over each CPU's list in turn.

This change necessitates a new fl_link_cpu field to keep track of which
CPU the entry is on. On x86_64 at least, this field is placed within an
existing hole in the struct to avoid growing the size.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/locks.c         |   69 +++++++++++++++++++++++++++++++++++++---------------
 include/linux/fs.h |    1 +
 2 files changed, 50 insertions(+), 20 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 04e2c1f..0f544cd 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -127,6 +127,8 @@
 #include <linux/rcupdate.h>
 #include <linux/pid_namespace.h>
 #include <linux/hashtable.h>
+#include <linux/percpu.h>
+#include <linux/lglock.h>
 
 #include <asm/uaccess.h>
 
@@ -155,11 +157,13 @@ int lease_break_time = 45;
 	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
 
 /*
- * The global file_lock_list is only used for displaying /proc/locks. Protected
- * by the file_lock_lock.
+ * The global file_lock_list is only used for displaying /proc/locks, so we
+ * keep a list on each CPU, with each list protected by its own spinlock via
+ * the file_lock_lglock. Note that alterations to the list also require that
+ * the relevant i_lock is held.
  */
-static HLIST_HEAD(file_lock_list);
-static DEFINE_SPINLOCK(file_lock_lock);
+DEFINE_STATIC_LGLOCK(file_lock_lglock);
+static DEFINE_PER_CPU(struct hlist_head, file_lock_list);
 
 /*
  * The blocked_hash is used to find POSIX lock loops for deadlock detection.
@@ -506,20 +510,30 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 	return fl1->fl_owner == fl2->fl_owner;
 }
 
+/* Must be called with the i_lock held! */
 static inline void
 locks_insert_global_locks(struct file_lock *fl)
 {
-	spin_lock(&file_lock_lock);
-	hlist_add_head(&fl->fl_link, &file_lock_list);
-	spin_unlock(&file_lock_lock);
+	lg_local_lock(&file_lock_lglock);
+	fl->fl_link_cpu = smp_processor_id();
+	hlist_add_head(&fl->fl_link, this_cpu_ptr(&file_lock_list));
+	lg_local_unlock(&file_lock_lglock);
 }
 
+/* Must be called with the i_lock held! */
 static inline void
 locks_delete_global_locks(struct file_lock *fl)
 {
-	spin_lock(&file_lock_lock);
+	/*
+	 * Avoid taking lock if already unhashed. This is safe since this check
+	 * is done while holding the i_lock, and new insertions into the list
+	 * also require that it be held.
+	 */
+	if (hlist_unhashed(&fl->fl_link))
+		return;
+	lg_local_lock_cpu(&file_lock_lglock, fl->fl_link_cpu);
 	hlist_del_init(&fl->fl_link);
-	spin_unlock(&file_lock_lock);
+	lg_local_unlock_cpu(&file_lock_lglock, fl->fl_link_cpu);
 }
 
 static unsigned long
@@ -2243,6 +2257,11 @@ EXPORT_SYMBOL_GPL(vfs_cancel_lock);
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
+struct locks_iterator {
+	int	li_cpu;
+	loff_t	li_pos;
+};
+
 static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 			    loff_t id, char *pfx)
 {
@@ -2316,39 +2335,41 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 
 static int locks_show(struct seq_file *f, void *v)
 {
+	struct locks_iterator *iter = f->private;
 	struct file_lock *fl, *bfl;
 
 	fl = hlist_entry(v, struct file_lock, fl_link);
 
-	lock_get_status(f, fl, *((loff_t *)f->private), "");
+	lock_get_status(f, fl, iter->li_pos, "");
 
 	list_for_each_entry(bfl, &fl->fl_block, fl_block)
-		lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
+		lock_get_status(f, bfl, iter->li_pos, " ->");
 
 	return 0;
 }
 
 static void *locks_start(struct seq_file *f, loff_t *pos)
 {
-	loff_t *p = f->private;
+	struct locks_iterator *iter = f->private;
 
-	spin_lock(&file_lock_lock);
+	iter->li_pos = *pos + 1;
+	lg_global_lock(&file_lock_lglock);
 	spin_lock(&blocked_lock_lock);
-	*p = (*pos + 1);
-	return seq_hlist_start(&file_lock_list, *pos);
+	return seq_hlist_start_percpu(&file_lock_list, &iter->li_cpu, *pos);
 }
 
 static void *locks_next(struct seq_file *f, void *v, loff_t *pos)
 {
-	loff_t *p = f->private;
-	++*p;
-	return seq_hlist_next(v, &file_lock_list, pos);
+	struct locks_iterator *iter = f->private;
+
+	++iter->li_pos;
+	return seq_hlist_next_percpu(v, &file_lock_list, &iter->li_cpu, pos);
 }
 
 static void locks_stop(struct seq_file *f, void *v)
 {
 	spin_unlock(&blocked_lock_lock);
-	spin_unlock(&file_lock_lock);
+	lg_global_unlock(&file_lock_lglock);
 }
 
 static const struct seq_operations locks_seq_operations = {
@@ -2360,7 +2381,8 @@ static const struct seq_operations locks_seq_operations = {
 
 static int locks_open(struct inode *inode, struct file *filp)
 {
-	return seq_open_private(filp, &locks_seq_operations, sizeof(loff_t));
+	return seq_open_private(filp, &locks_seq_operations,
+					sizeof(struct locks_iterator));
 }
 
 static const struct file_operations proc_locks_operations = {
@@ -2460,9 +2482,16 @@ EXPORT_SYMBOL(lock_may_write);
 
 static int __init filelock_init(void)
 {
+	int i;
+
 	filelock_cache = kmem_cache_create("file_lock_cache",
 			sizeof(struct file_lock), 0, SLAB_PANIC, NULL);
 
+	lg_lock_init(&file_lock_lglock, "file_lock_lglock");
+
+	for_each_possible_cpu(i)
+		INIT_HLIST_HEAD(per_cpu_ptr(&file_lock_list, i));
+
 	return 0;
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e42e04f..039f2ae 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -953,6 +953,7 @@ struct file_lock {
 	unsigned int fl_flags;
 	unsigned char fl_type;
 	unsigned int fl_pid;
+	int fl_link_cpu;		/* what cpu's list is this on? */
 	struct pid *fl_nspid;
 	wait_queue_head_t fl_wait;
 	struct file *fl_file;
-- 
1.7.1

