Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:38571 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757318Ab3EWBr2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 May 2013 21:47:28 -0400
From: Waiman Long <Waiman.Long@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>
Subject: [PATCH 3/3 v3] dcache: change rename_lock to a sequence read/write lock
Date: Wed, 22 May 2013 21:37:28 -0400
Message-Id: <1369273048-60256-4-git-send-email-Waiman.Long@hp.com>
In-Reply-To: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
        Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The d_path() and related kernel functions currently take a writer
lock on rename_lock because they need to follow pointers. By changing
rename_lock to be the new sequence read/write lock, a reader lock
can be taken and multiple d_path() threads can proceed concurrently
without blocking each other.

It is unlikely that the frequency of filesystem changes and d_path()
name lookup will be high enough to cause writer starvation, the current
limitation of the read/write lock should be acceptable in that case.

All the sites where rename_lock is referenced were modified to use the
sequence read/write lock declaration and access functions.

This patch will have merge conflict When applying to kernel version
earlier than 3.10.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 fs/autofs4/waitq.c     |    6 ++--
 fs/ceph/mds_client.c   |    4 +-
 fs/cifs/dir.c          |    4 +-
 fs/dcache.c            |   83 ++++++++++++++++++++++++-----------------------
 fs/nfs/namespace.c     |    6 ++--
 include/linux/dcache.h |    4 +-
 kernel/auditsc.c       |    4 +-
 7 files changed, 56 insertions(+), 55 deletions(-)

diff --git a/fs/autofs4/waitq.c b/fs/autofs4/waitq.c
index 3db70da..3afc4db 100644
--- a/fs/autofs4/waitq.c
+++ b/fs/autofs4/waitq.c
@@ -197,7 +197,7 @@ rename_retry:
 	buf = *name;
 	len = 0;
 
-	seq = read_seqbegin(&rename_lock);
+	seq = read_seqrwbegin(&rename_lock);
 	rcu_read_lock();
 	spin_lock(&sbi->fs_lock);
 	for (tmp = dentry ; tmp != root ; tmp = tmp->d_parent)
@@ -206,7 +206,7 @@ rename_retry:
 	if (!len || --len > NAME_MAX) {
 		spin_unlock(&sbi->fs_lock);
 		rcu_read_unlock();
-		if (read_seqretry(&rename_lock, seq))
+		if (read_seqrwretry(&rename_lock, seq))
 			goto rename_retry;
 		return 0;
 	}
@@ -222,7 +222,7 @@ rename_retry:
 	}
 	spin_unlock(&sbi->fs_lock);
 	rcu_read_unlock();
-	if (read_seqretry(&rename_lock, seq))
+	if (read_seqrwretry(&rename_lock, seq))
 		goto rename_retry;
 
 	return len;
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 4f22671..b0c266f 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -1489,7 +1489,7 @@ char *ceph_mdsc_build_path(struct dentry *dentry, int *plen, u64 *base,
 
 retry:
 	len = 0;
-	seq = read_seqbegin(&rename_lock);
+	seq = read_seqrwbegin(&rename_lock);
 	rcu_read_lock();
 	for (temp = dentry; !IS_ROOT(temp);) {
 		struct inode *inode = temp->d_inode;
@@ -1539,7 +1539,7 @@ retry:
 		temp = temp->d_parent;
 	}
 	rcu_read_unlock();
-	if (pos != 0 || read_seqretry(&rename_lock, seq)) {
+	if (pos != 0 || read_seqrwretry(&rename_lock, seq)) {
 		pr_err("build_path did not end path lookup where "
 		       "expected, namelen is %d, pos is %d\n", len, pos);
 		/* presumably this is only possible if racing with a
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index 5699b50..b672c02 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -96,7 +96,7 @@ build_path_from_dentry(struct dentry *direntry)
 		dfsplen = 0;
 cifs_bp_rename_retry:
 	namelen = dfsplen;
-	seq = read_seqbegin(&rename_lock);
+	seq = read_seqrwbegin(&rename_lock);
 	rcu_read_lock();
 	for (temp = direntry; !IS_ROOT(temp);) {
 		namelen += (1 + temp->d_name.len);
@@ -136,7 +136,7 @@ cifs_bp_rename_retry:
 		}
 	}
 	rcu_read_unlock();
-	if (namelen != dfsplen || read_seqretry(&rename_lock, seq)) {
+	if (namelen != dfsplen || read_seqrwretry(&rename_lock, seq)) {
 		cifs_dbg(FYI, "did not end path lookup where expected. namelen=%ddfsplen=%d\n",
 			 namelen, dfsplen);
 		/* presumably this is only possible if racing with a rename
diff --git a/fs/dcache.c b/fs/dcache.c
index 470b06f..c96bdb1 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -29,6 +29,7 @@
 #include <asm/uaccess.h>
 #include <linux/security.h>
 #include <linux/seqlock.h>
+#include <linux/seqrwlock.h>
 #include <linux/swap.h>
 #include <linux/bootmem.h>
 #include <linux/fs_struct.h>
@@ -82,7 +83,7 @@ int sysctl_vfs_cache_pressure __read_mostly = 100;
 EXPORT_SYMBOL_GPL(sysctl_vfs_cache_pressure);
 
 static __cacheline_aligned_in_smp DEFINE_SPINLOCK(dcache_lru_lock);
-__cacheline_aligned_in_smp DEFINE_SEQLOCK(rename_lock);
+__cacheline_aligned_in_smp DEFINE_SEQRWLOCK(rename_lock);
 
 EXPORT_SYMBOL(rename_lock);
 
@@ -1009,7 +1010,7 @@ static struct dentry *try_to_ascend(struct dentry *old, int locked, unsigned seq
 	 */
 	if (new != old->d_parent ||
 		 (old->d_flags & DCACHE_DENTRY_KILLED) ||
-		 (!locked && read_seqretry(&rename_lock, seq))) {
+		 (!locked && read_seqrwretry(&rename_lock, seq))) {
 		spin_unlock(&new->d_lock);
 		new = NULL;
 	}
@@ -1038,7 +1039,7 @@ int have_submounts(struct dentry *parent)
 	unsigned seq;
 	int locked = 0;
 
-	seq = read_seqbegin(&rename_lock);
+	seq = read_seqrwbegin(&rename_lock);
 again:
 	this_parent = parent;
 
@@ -1081,23 +1082,23 @@ resume:
 		goto resume;
 	}
 	spin_unlock(&this_parent->d_lock);
-	if (!locked && read_seqretry(&rename_lock, seq))
+	if (!locked && read_seqrwretry(&rename_lock, seq))
 		goto rename_retry;
 	if (locked)
-		write_sequnlock(&rename_lock);
+		write_seqrwunlock(&rename_lock);
 	return 0; /* No mount points found in tree */
 positive:
-	if (!locked && read_seqretry(&rename_lock, seq))
+	if (!locked && read_seqrwretry(&rename_lock, seq))
 		goto rename_retry;
 	if (locked)
-		write_sequnlock(&rename_lock);
+		write_seqrwunlock(&rename_lock);
 	return 1;
 
 rename_retry:
 	if (locked)
 		goto again;
 	locked = 1;
-	write_seqlock(&rename_lock);
+	write_seqrwlock(&rename_lock);
 	goto again;
 }
 EXPORT_SYMBOL(have_submounts);
@@ -1124,7 +1125,7 @@ static int select_parent(struct dentry *parent, struct list_head *dispose)
 	int found = 0;
 	int locked = 0;
 
-	seq = read_seqbegin(&rename_lock);
+	seq = read_seqrwbegin(&rename_lock);
 again:
 	this_parent = parent;
 	spin_lock(&this_parent->d_lock);
@@ -1189,10 +1190,10 @@ resume:
 	}
 out:
 	spin_unlock(&this_parent->d_lock);
-	if (!locked && read_seqretry(&rename_lock, seq))
+	if (!locked && read_seqrwretry(&rename_lock, seq))
 		goto rename_retry;
 	if (locked)
-		write_sequnlock(&rename_lock);
+		write_seqrwunlock(&rename_lock);
 	return found;
 
 rename_retry:
@@ -1201,7 +1202,7 @@ rename_retry:
 	if (locked)
 		goto again;
 	locked = 1;
-	write_seqlock(&rename_lock);
+	write_seqrwlock(&rename_lock);
 	goto again;
 }
 
@@ -1816,7 +1817,7 @@ struct dentry *__d_lookup_rcu(const struct dentry *parent,
 	 * It is possible that concurrent renames can mess up our list
 	 * walk here and result in missing our dentry, resulting in the
 	 * false-negative result. d_lookup() protects against concurrent
-	 * renames using rename_lock seqlock.
+	 * renames using rename_lock seqrwlock.
 	 *
 	 * See Documentation/filesystems/path-lookup.txt for more details.
 	 */
@@ -1884,11 +1885,11 @@ struct dentry *d_lookup(const struct dentry *parent, const struct qstr *name)
 	unsigned seq;
 
         do {
-                seq = read_seqbegin(&rename_lock);
+                seq = read_seqrwbegin(&rename_lock);
                 dentry = __d_lookup(parent, name);
                 if (dentry)
 			break;
-	} while (read_seqretry(&rename_lock, seq));
+	} while (read_seqrwretry(&rename_lock, seq));
 	return dentry;
 }
 EXPORT_SYMBOL(d_lookup);
@@ -1902,7 +1903,7 @@ EXPORT_SYMBOL(d_lookup);
  * __d_lookup is like d_lookup, however it may (rarely) return a
  * false-negative result due to unrelated rename activity.
  *
- * __d_lookup is slightly faster by avoiding rename_lock read seqlock,
+ * __d_lookup is slightly faster by avoiding rename_lock read seqrwlock,
  * however it must be used carefully, eg. with a following d_lookup in
  * the case of failure.
  *
@@ -1934,7 +1935,7 @@ struct dentry *__d_lookup(const struct dentry *parent, const struct qstr *name)
 	 * It is possible that concurrent renames can mess up our list
 	 * walk here and result in missing our dentry, resulting in the
 	 * false-negative result. d_lookup() protects against concurrent
-	 * renames using rename_lock seqlock.
+	 * renames using rename_lock seqrwlock.
 	 *
 	 * See Documentation/filesystems/path-lookup.txt for more details.
 	 */
@@ -2309,9 +2310,9 @@ static void __d_move(struct dentry * dentry, struct dentry * target)
  */
 void d_move(struct dentry *dentry, struct dentry *target)
 {
-	write_seqlock(&rename_lock);
+	write_seqrwlock(&rename_lock);
 	__d_move(dentry, target);
-	write_sequnlock(&rename_lock);
+	write_seqrwunlock(&rename_lock);
 }
 EXPORT_SYMBOL(d_move);
 
@@ -2439,7 +2440,7 @@ struct dentry *d_materialise_unique(struct dentry *dentry, struct inode *inode)
 		alias = __d_find_alias(inode, 0);
 		if (alias) {
 			actual = alias;
-			write_seqlock(&rename_lock);
+			write_seqrwlock(&rename_lock);
 
 			if (d_ancestor(alias, dentry)) {
 				/* Check for loops */
@@ -2449,7 +2450,7 @@ struct dentry *d_materialise_unique(struct dentry *dentry, struct inode *inode)
 				/* Is this an anonymous mountpoint that we
 				 * could splice into our tree? */
 				__d_materialise_dentry(dentry, alias);
-				write_sequnlock(&rename_lock);
+				write_seqrwunlock(&rename_lock);
 				__d_drop(alias);
 				goto found;
 			} else {
@@ -2457,7 +2458,7 @@ struct dentry *d_materialise_unique(struct dentry *dentry, struct inode *inode)
 				 * aliasing. This drops inode->i_lock */
 				actual = __d_unalias(inode, dentry, alias);
 			}
-			write_sequnlock(&rename_lock);
+			write_seqrwunlock(&rename_lock);
 			if (IS_ERR(actual)) {
 				if (PTR_ERR(actual) == -ELOOP)
 					pr_warn_ratelimited(
@@ -2602,9 +2603,9 @@ char *__d_path(const struct path *path,
 
 	prepend(&res, &buflen, "\0", 1);
 	br_read_lock(&vfsmount_lock);
-	write_seqlock(&rename_lock);
+	read_seqrwlock(&rename_lock);
 	error = prepend_path(path, root, &res, &buflen);
-	write_sequnlock(&rename_lock);
+	read_seqrwunlock(&rename_lock);
 	br_read_unlock(&vfsmount_lock);
 
 	if (error < 0)
@@ -2623,9 +2624,9 @@ char *d_absolute_path(const struct path *path,
 
 	prepend(&res, &buflen, "\0", 1);
 	br_read_lock(&vfsmount_lock);
-	write_seqlock(&rename_lock);
+	read_seqrwlock(&rename_lock);
 	error = prepend_path(path, &root, &res, &buflen);
-	write_sequnlock(&rename_lock);
+	read_seqrwunlock(&rename_lock);
 	br_read_unlock(&vfsmount_lock);
 
 	if (error > 1)
@@ -2691,9 +2692,9 @@ char *d_path(const struct path *path, char *buf, int buflen)
 
 	get_fs_root(current->fs, &root);
 	br_read_lock(&vfsmount_lock);
-	write_seqlock(&rename_lock);
+	read_seqrwlock(&rename_lock);
 	error = path_with_deleted(path, &root, &res, &buflen);
-	write_sequnlock(&rename_lock);
+	read_seqrwunlock(&rename_lock);
 	br_read_unlock(&vfsmount_lock);
 	if (error < 0)
 		res = ERR_PTR(error);
@@ -2761,9 +2762,9 @@ char *dentry_path_raw(struct dentry *dentry, char *buf, int buflen)
 {
 	char *retval;
 
-	write_seqlock(&rename_lock);
+	read_seqrwlock(&rename_lock);
 	retval = __dentry_path(dentry, buf, buflen);
-	write_sequnlock(&rename_lock);
+	read_seqrwunlock(&rename_lock);
 
 	return retval;
 }
@@ -2774,7 +2775,7 @@ char *dentry_path(struct dentry *dentry, char *buf, int buflen)
 	char *p = NULL;
 	char *retval;
 
-	write_seqlock(&rename_lock);
+	read_seqrwlock(&rename_lock);
 	if (d_unlinked(dentry)) {
 		p = buf + buflen;
 		if (prepend(&p, &buflen, "//deleted", 10) != 0)
@@ -2782,7 +2783,7 @@ char *dentry_path(struct dentry *dentry, char *buf, int buflen)
 		buflen++;
 	}
 	retval = __dentry_path(dentry, buf, buflen);
-	write_sequnlock(&rename_lock);
+	read_seqrwunlock(&rename_lock);
 	if (!IS_ERR(retval) && p)
 		*p = '/';	/* restore '/' overriden with '\0' */
 	return retval;
@@ -2821,7 +2822,7 @@ SYSCALL_DEFINE2(getcwd, char __user *, buf, unsigned long, size)
 
 	error = -ENOENT;
 	br_read_lock(&vfsmount_lock);
-	write_seqlock(&rename_lock);
+	read_seqrwlock(&rename_lock);
 	if (!d_unlinked(pwd.dentry)) {
 		unsigned long len;
 		char *cwd = page + PAGE_SIZE;
@@ -2829,7 +2830,7 @@ SYSCALL_DEFINE2(getcwd, char __user *, buf, unsigned long, size)
 
 		prepend(&cwd, &buflen, "\0", 1);
 		error = prepend_path(&pwd, &root, &cwd, &buflen);
-		write_sequnlock(&rename_lock);
+		read_seqrwunlock(&rename_lock);
 		br_read_unlock(&vfsmount_lock);
 
 		if (error < 0)
@@ -2850,7 +2851,7 @@ SYSCALL_DEFINE2(getcwd, char __user *, buf, unsigned long, size)
 				error = -EFAULT;
 		}
 	} else {
-		write_sequnlock(&rename_lock);
+		read_seqrwunlock(&rename_lock);
 		br_read_unlock(&vfsmount_lock);
 	}
 
@@ -2887,7 +2888,7 @@ int is_subdir(struct dentry *new_dentry, struct dentry *old_dentry)
 
 	do {
 		/* for restarting inner loop in case of seq retry */
-		seq = read_seqbegin(&rename_lock);
+		seq = read_seqrwbegin(&rename_lock);
 		/*
 		 * Need rcu_readlock to protect against the d_parent trashing
 		 * due to d_move
@@ -2898,7 +2899,7 @@ int is_subdir(struct dentry *new_dentry, struct dentry *old_dentry)
 		else
 			result = 0;
 		rcu_read_unlock();
-	} while (read_seqretry(&rename_lock, seq));
+	} while (read_seqrwretry(&rename_lock, seq));
 
 	return result;
 }
@@ -2910,7 +2911,7 @@ void d_genocide(struct dentry *root)
 	unsigned seq;
 	int locked = 0;
 
-	seq = read_seqbegin(&rename_lock);
+	seq = read_seqrwbegin(&rename_lock);
 again:
 	this_parent = root;
 	spin_lock(&this_parent->d_lock);
@@ -2953,17 +2954,17 @@ resume:
 		goto resume;
 	}
 	spin_unlock(&this_parent->d_lock);
-	if (!locked && read_seqretry(&rename_lock, seq))
+	if (!locked && read_seqrwretry(&rename_lock, seq))
 		goto rename_retry;
 	if (locked)
-		write_sequnlock(&rename_lock);
+		write_seqrwunlock(&rename_lock);
 	return;
 
 rename_retry:
 	if (locked)
 		goto again;
 	locked = 1;
-	write_seqlock(&rename_lock);
+	write_seqrwlock(&rename_lock);
 	goto again;
 }
 
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index fc8dc20..0eca871 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -60,7 +60,7 @@ rename_retry:
 	*--end = '\0';
 	buflen--;
 
-	seq = read_seqbegin(&rename_lock);
+	seq = read_seqrwbegin(&rename_lock);
 	rcu_read_lock();
 	while (1) {
 		spin_lock(&dentry->d_lock);
@@ -76,7 +76,7 @@ rename_retry:
 		spin_unlock(&dentry->d_lock);
 		dentry = dentry->d_parent;
 	}
-	if (read_seqretry(&rename_lock, seq)) {
+	if (read_seqrwretry(&rename_lock, seq)) {
 		spin_unlock(&dentry->d_lock);
 		rcu_read_unlock();
 		goto rename_retry;
@@ -117,7 +117,7 @@ rename_retry:
 Elong_unlock:
 	spin_unlock(&dentry->d_lock);
 	rcu_read_unlock();
-	if (read_seqretry(&rename_lock, seq))
+	if (read_seqrwretry(&rename_lock, seq))
 		goto rename_retry;
 Elong:
 	return ERR_PTR(-ENAMETOOLONG);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 99da5e2..5f05815 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -6,7 +6,7 @@
 #include <linux/rculist.h>
 #include <linux/rculist_bl.h>
 #include <linux/spinlock.h>
-#include <linux/seqlock.h>
+#include <linux/seqrwlock.h>
 #include <linux/cache.h>
 #include <linux/rcupdate.h>
 
@@ -210,7 +210,7 @@ struct dentry_operations {
 
 #define DCACHE_DENTRY_KILLED	0x100000
 
-extern seqlock_t rename_lock;
+extern seqrwlock_t rename_lock;
 
 static inline int dname_external(struct dentry *dentry)
 {
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 3c8a601..d464b67 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1591,7 +1591,7 @@ retry:
 	drop = NULL;
 	d = dentry;
 	rcu_read_lock();
-	seq = read_seqbegin(&rename_lock);
+	seq = read_seqrwbegin(&rename_lock);
 	for(;;) {
 		struct inode *inode = d->d_inode;
 		if (inode && unlikely(!hlist_empty(&inode->i_fsnotify_marks))) {
@@ -1609,7 +1609,7 @@ retry:
 			break;
 		d = parent;
 	}
-	if (unlikely(read_seqretry(&rename_lock, seq) || drop)) {  /* in this order */
+	if (unlikely(read_seqrwretry(&rename_lock, seq) || drop)) {  /* in this order */
 		rcu_read_unlock();
 		if (!drop) {
 			/* just a race with rename */
-- 
1.7.1

