Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f44.google.com ([209.85.214.44]:41663 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865Ab3HFOaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 10:30:21 -0400
Received: by mail-bk0-f44.google.com with SMTP id mz10so186711bkb.17
        for <linux-nfs@vger.kernel.org>; Tue, 06 Aug 2013 07:30:20 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: rwheeler@redhat.com, avati@redhat.com, viro@ZenIV.linux.org.uk
Cc: bfoster@redhat.com, dhowells@redhat.com, eparis@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        swhiteho@redhat.com, mszeredi@suse.cz
Subject: [PATCH 1/4] vfs: check submounts and drop atomically
Date: Tue,  6 Aug 2013 16:30:00 +0200
Message-Id: <1375799403-28544-2-git-send-email-miklos@szeredi.hu>
In-Reply-To: <1375799403-28544-1-git-send-email-miklos@szeredi.hu>
References: <1375799403-28544-1-git-send-email-miklos@szeredi.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Miklos Szeredi <mszeredi@suse.cz>

We check submounts before doing d_drop() on a non-empty directory dentry in
NFS (have_submounts()), but we do not exclude a racing mount.

 Process A: have_submounts() -> returns false
 Process B: mount() -> success
 Process A: d_drop()

This patch prepares the ground for the fix by doing the following
operations all under the same rename lock:

  have_submounts()
  shrink_dcache_parent()
  d_drop()

This is actually an optimization since have_submounts() and
shrink_dcache_parent() both traverse the same dentry tree separately.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/afs/dir.c           |   6 +--
 fs/dcache.c            | 131 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/gfs2/dentry.c       |   6 +--
 fs/nfs/dir.c           |  10 ++--
 fs/sysfs/dir.c         |   6 +--
 include/linux/dcache.h |   1 +
 6 files changed, 146 insertions(+), 14 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 34494fb..968f50d 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -687,14 +687,14 @@ not_found:
 out_bad:
 	if (dentry->d_inode) {
 		/* don't unhash if we have submounts */
-		if (have_submounts(dentry))
+		if (check_submounts_and_drop(dentry) != 0)
 			goto out_skip;
+	} else {
+		d_drop(dentry);
 	}
 
 	_debug("dropping dentry %s/%s",
 	       parent->d_name.name, dentry->d_name.name);
-	shrink_dcache_parent(dentry);
-	d_drop(dentry);
 	dput(parent);
 	key_put(key);
 
diff --git a/fs/dcache.c b/fs/dcache.c
index 87bdb53..ba429d9 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1224,6 +1224,137 @@ void shrink_dcache_parent(struct dentry * parent)
 }
 EXPORT_SYMBOL(shrink_dcache_parent);
 
+static int __check_submounts_and_drop(struct dentry *parent,
+					     struct list_head *dispose)
+{
+	struct dentry *this_parent;
+	struct list_head *next;
+	unsigned seq;
+	int found = 0;
+	int locked = 0;
+
+	seq = read_seqbegin(&rename_lock);
+again:
+	this_parent = parent;
+	spin_lock(&this_parent->d_lock);
+repeat:
+	next = this_parent->d_subdirs.next;
+resume:
+	while (next != &this_parent->d_subdirs) {
+		struct list_head *tmp = next;
+		struct dentry *dentry;
+
+		dentry = list_entry(tmp, struct dentry, d_u.d_child);
+		next = tmp->next;
+
+		spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
+		if (d_mountpoint(dentry)) {
+			spin_unlock(&dentry->d_lock);
+			found = -EBUSY;
+			goto out;
+		}
+
+		/*
+		 * move only zero ref count dentries to the dispose list.
+		 *
+		 * Those which are presently on the shrink list, being processed
+		 * by shrink_dentry_list(), shouldn't be moved.  Otherwise the
+		 * loop in shrink_dcache_parent() might not make any progress
+		 * and loop forever.
+		 */
+		if (dentry->d_count) {
+			dentry_lru_del(dentry);
+		} else if (!(dentry->d_flags & DCACHE_SHRINK_LIST)) {
+			dentry_lru_move_list(dentry, dispose);
+			dentry->d_flags |= DCACHE_SHRINK_LIST;
+			found++;
+		}
+		/*
+		 * We can return to the caller if we have found some (this
+		 * ensures forward progress). We'll be coming back to find
+		 * the rest.
+		 */
+		if (found && need_resched()) {
+			spin_unlock(&dentry->d_lock);
+			goto out;
+		}
+
+		/*
+		 * Descend a level if the d_subdirs list is non-empty.
+		 */
+		if (!list_empty(&dentry->d_subdirs)) {
+			spin_unlock(&this_parent->d_lock);
+			spin_release(&dentry->d_lock.dep_map, 1, _RET_IP_);
+			this_parent = dentry;
+			spin_acquire(&this_parent->d_lock.dep_map, 0, 1, _RET_IP_);
+			goto repeat;
+		}
+
+		spin_unlock(&dentry->d_lock);
+	}
+	/*
+	 * All done at this level ... ascend and resume the search.
+	 */
+	if (this_parent != parent) {
+		struct dentry *child = this_parent;
+		this_parent = try_to_ascend(this_parent, locked, seq);
+		if (!this_parent)
+			goto rename_retry;
+		next = child->d_u.d_child.next;
+		goto resume;
+	}
+out:
+	if (!locked && read_seqretry(&rename_lock, seq)) {
+		spin_unlock(&this_parent->d_lock);
+		goto rename_retry;
+	}
+	__d_drop(this_parent);
+	spin_unlock(&this_parent->d_lock);
+
+	if (locked)
+		write_sequnlock(&rename_lock);
+	return found;
+
+
+rename_retry:
+	if (found)
+		return found;
+	if (locked)
+		goto again;
+	locked = 1;
+	write_seqlock(&rename_lock);
+	goto again;
+}
+
+/**
+ * check_submounts_and_drop - prune dcache, check for submounts and drop
+ *
+ * All done as a single atomic operation relative to has_unlinked_ancestor().
+ * Returns 0 if successfully unhashed @parent.  If there were submounts then
+ * return -EBUSY.
+ *
+ * @dentry: dentry to prune and drop
+ */
+int check_submounts_and_drop(struct dentry *dentry)
+{
+	int found;
+
+	for (;;) {
+		LIST_HEAD(dispose);
+		found = __check_submounts_and_drop(dentry, &dispose);
+		if (!list_empty(&dispose))
+			shrink_dentry_list(&dispose);
+
+		if (found <= 0)
+			break;
+
+		cond_resched();
+	}
+
+	return found;
+}
+EXPORT_SYMBOL(check_submounts_and_drop);
+
 /**
  * __d_alloc	-	allocate a dcache entry
  * @sb: filesystem it will belong to
diff --git a/fs/gfs2/dentry.c b/fs/gfs2/dentry.c
index f2448ab..6964725 100644
--- a/fs/gfs2/dentry.c
+++ b/fs/gfs2/dentry.c
@@ -94,11 +94,11 @@ invalid_gunlock:
 		gfs2_glock_dq_uninit(&d_gh);
 invalid:
 	if (inode && S_ISDIR(inode->i_mode)) {
-		if (have_submounts(dentry))
+		if (check_submounts_and_drop(dentry) != 0)
 			goto valid;
-		shrink_dcache_parent(dentry);
+	} else {
+		d_drop(dentry);
 	}
-	d_drop(dentry);
 	dput(parent);
 	return 0;
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e474ca2b..a2fd681 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1135,14 +1135,14 @@ out_zap_parent:
 	if (inode && S_ISDIR(inode->i_mode)) {
 		/* Purge readdir caches. */
 		nfs_zap_caches(inode);
-		/* If we have submounts, don't unhash ! */
-		if (have_submounts(dentry))
-			goto out_valid;
 		if (dentry->d_flags & DCACHE_DISCONNECTED)
 			goto out_valid;
-		shrink_dcache_parent(dentry);
+		/* If we have submounts, don't unhash ! */
+		if (check_submounts_and_drop(dentry) != 0)
+			goto out_valid;
+	} else {
+		d_drop(dentry);
 	}
-	d_drop(dentry);
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) is invalid\n",
 			__func__, dentry->d_parent->d_name.name,
diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index e068e74..1778320 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -348,11 +348,11 @@ out_bad:
 		 * to lie about the state of the filesystem to prevent
 		 * leaks and other nasty things.
 		 */
-		if (have_submounts(dentry))
+		if (check_submounts_and_drop(dentry) != 0)
 			goto out_valid;
-		shrink_dcache_parent(dentry);
+	} else {
+		d_drop(dentry);
 	}
-	d_drop(dentry);
 	return 0;
 }
 
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index b90337c..41b21ca 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -251,6 +251,7 @@ extern void d_prune_aliases(struct inode *);
 
 /* test whether we have any submounts in a subdir tree */
 extern int have_submounts(struct dentry *);
+extern int check_submounts_and_drop(struct dentry *);
 
 /*
  * This adds the entry to the hash queues.
-- 
1.8.1.4

