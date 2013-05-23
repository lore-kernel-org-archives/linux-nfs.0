Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:33308 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756992Ab3EWBih (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 May 2013 21:38:37 -0400
From: Waiman Long <Waiman.Long@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>
Subject: [PATCH 1/3 v3] dcache: Don't take unnecessary lock in d_count update
Date: Wed, 22 May 2013 21:37:26 -0400
Message-Id: <1369273048-60256-2-git-send-email-Waiman.Long@hp.com>
In-Reply-To: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
        Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code takes the dentry's d_lock lock whenever the d_count
reference count is being updated. In reality, nothing big really
happens until d_count goes to 0 in dput(). So it is not necessary to
take the lock if the reference count won't go to 0.

Without using a lock, multiple threads may update d_count
simultaneously.  Therefore, atomic instructions must be used to
ensure consistency except in shrink_dcache_for_umount*() where the
whole superblock is being dismounted and locking is not needed.

The worst case scenarios are:

1. d_lock taken in dput with d_count = 2 in one thread and another
   thread comes in to atomically decrement d_count without taking
   the lock. This may result in a d_count of 0 with no deleting
   action taken.

2. d_lock taken in dput with d_count = 1 in one thread and another
   thread comes in to atomically increment d_count without taking
   the lock. This may result in the dentry in the deleted state while
   having a d_count of 1.

Without taking a lock, we need to make sure the decrementing or
incrementing action should not be taken while other threads are
updating d_count simultaneously. This can be done by using the
atomic cmpxchg instruction which will fail if the underlying value
is changed.  If the lock is taken, it should be safe to use a simpler
atomic increment or decrement instruction.

To make sure that the above worst case scenarios will not happen,
the dget() function must take the lock if d_count <= 1. Similarly,
the dput() function must take the lock if d_count <= 2. The cmpxchg()
call to update d_count will be tried twice before falling back to
using the lock as there is a fairly good chance that the cmpxchg()
may fail in a busy situation.

Finally, the CPU must have an instructional level cmpxchg instruction
or the emulated cmpxchg() function may be too expensive to
use. Therefore, the above mentioned changes will only be applied if
the __HAVE_ARCH_CMPXCHG flag is set. Most of the major architectures
supported by Linux have this flag set with the notation exception
of ARM.

As for the performance of the updated reference counting code, it
all depends on whether the cmpxchg instruction is used or not. The
original code has 2 atomic instructions to lock and unlock the
spinlock. The new code path has either 1 atomic cmpxchg instruction
or 3 atomic instructions if the lock has to be taken. Depending on
how frequent the cmpxchg instruction is used (d_count > 1 or 2),
the new code can be faster or slower than the original one.

This patch has a particular big impact on the short workload of the
AIM7 benchmark with ramdisk filesystem. The table below show the
performance improvement to the JPM (jobs per minutes) throughput due
to this patch on an 8-socket 80-core x86-64 system with a 3.10-rc1
kernel in a 1/2/4/8 node configuration by using numactl to restrict
the execution of the workload on certain nodes.

+-----------------+----------------+-----------------+----------+
|  Configuration  |    Mean JPM    |    Mean JPM     | % Change |
|                 | Rate w/o patch | Rate with patch |          |
+-----------------+---------------------------------------------+
|                 |              User Range 10 - 100            |
+-----------------+---------------------------------------------+
| 8 nodes, HT off |    1546813     |     5080126     | +228.4%  |
| 4 nodes, HT off |    1663439     |     4703083     | +182.7%  |
| 2 nodes, HT off |    2545389     |     3790995     |  +48.9%  |
| 1 node , HT off |    2374488     |     2394846     |   +0.9%  |
+-----------------+---------------------------------------------+
|                 |              User Range 200 - 1000          |
+-----------------+---------------------------------------------+
| 8 nodes, HT off |    1064184     |     7391382     | +594.6%  |
| 4 nodes, HT off |    1362447     |     7325475     | +437.7%  |
| 2 nodes, HT off |    1851198     |     4539511     | +145.2%  |
| 1 node , HT off |    2477537     |     2457513     |   -0.8%  |
+-----------------+---------------------------------------------+
|                 |              User Range 1100 - 2000         |
+-----------------+---------------------------------------------+
| 8 nodes, HT off |    1056243     |     7067282     | +569.1%  |
| 4 nodes, HT off |    1354505     |     6930437     | +411.7%  |
| 2 nodes, HT off |    1735881     |     4581847     | +164.0%  |
| 1 node , HT off |    2511547     |     2496594     |   -0.6%  |
+-----------------+----------------+-----------------+----------+

It can be seen that with 20 CPUs (2 nodes) or more, this patch can
significantly improve the short workload performance. With only 1
node, the performance is similar with or without the patch. The short
workload also scales pretty well up to 4 nodes with this patch.

A perf call-graph report of the short workload at 1500 users without
the patch on 8 nodes indicates that about 79% of the workload's total
time were spent in the _raw_spin_lock() function. Almost all of which
can be attributed to the following 2 kernel functions:
 1. dget_parent (49.91%)
 2. dput (49.82%)

With this patch on, the time spent on _raw_spin_lock() is only 1.38%
which is a huge improvement. Of the 1.38%, only a small portion of it
is related to the dcache lock. However, the _raw_spin_lock_irqsave()
of the tty_ldisc_lock now dominates with 24.5% of the total time.

This impact of this patch on other AIM7 workloads were much more
modest.  The table below show the mean %change due to this patch on
the same 8-socket system with a 3.10-rc1 kernel.

+--------------+---------------+----------------+-----------------+
|   Workload   | mean % change | mean % change  | mean % change   |
|              | 10-100 users  | 200-1000 users | 1100-2000 users |
+--------------+---------------+----------------+-----------------+
| alltests     |     -0.2%     |     -0.5%      |     -2.7%       |
| five_sec     |     -1.0%     |     +2.6%      |     +2.4%       |
| fserver      |     +1.3%     |     +1.9%      |     +1.0%       |
| high_systime |     +0.1%     |     +1.3%      |     +4.8%       |
| new_fserver  |     -1.5%     |     +0.8%      |     +1.1%       |
| shared       |     +0.5%     |     +0.4%      |     -0.1%       |
+--------------+---------------+----------------+-----------------+

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 fs/dcache.c            |   37 ++++++++---------
 fs/namei.c             |    2 +-
 include/linux/dcache.h |  101 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 117 insertions(+), 23 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index f09b908..470b06f 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -467,7 +467,7 @@ relock:
 	}
 
 	if (ref)
-		dentry->d_count--;
+		dcount_dec(dentry);
 	/*
 	 * inform the fs via d_prune that this dentry is about to be
 	 * unhashed and destroyed.
@@ -515,10 +515,13 @@ void dput(struct dentry *dentry)
 repeat:
 	if (dentry->d_count == 1)
 		might_sleep();
+	if (dcount_dec_cmpxchg(dentry))
+		return;
+
 	spin_lock(&dentry->d_lock);
 	BUG_ON(!dentry->d_count);
 	if (dentry->d_count > 1) {
-		dentry->d_count--;
+		dcount_dec(dentry);
 		spin_unlock(&dentry->d_lock);
 		return;
 	}
@@ -535,7 +538,7 @@ repeat:
 	dentry->d_flags |= DCACHE_REFERENCED;
 	dentry_lru_add(dentry);
 
-	dentry->d_count--;
+	dcount_dec(dentry);
 	spin_unlock(&dentry->d_lock);
 	return;
 
@@ -606,11 +609,13 @@ EXPORT_SYMBOL(d_invalidate);
 /* This must be called with d_lock held */
 static inline void __dget_dlock(struct dentry *dentry)
 {
-	dentry->d_count++;
+	dcount_inc(dentry);
 }
 
 static inline void __dget(struct dentry *dentry)
 {
+	if (dcount_inc_cmpxchg(dentry))
+		return;
 	spin_lock(&dentry->d_lock);
 	__dget_dlock(dentry);
 	spin_unlock(&dentry->d_lock);
@@ -620,22 +625,16 @@ struct dentry *dget_parent(struct dentry *dentry)
 {
 	struct dentry *ret;
 
-repeat:
-	/*
-	 * Don't need rcu_dereference because we re-check it was correct under
-	 * the lock.
-	 */
 	rcu_read_lock();
-	ret = dentry->d_parent;
-	spin_lock(&ret->d_lock);
-	if (unlikely(ret != dentry->d_parent)) {
-		spin_unlock(&ret->d_lock);
+	ret = rcu_dereference(dentry->d_parent);
+	if (dcount_inc_cmpxchg(ret)) {
 		rcu_read_unlock();
-		goto repeat;
+		return ret;
 	}
+	spin_lock(&ret->d_lock);
 	rcu_read_unlock();
 	BUG_ON(!ret->d_count);
-	ret->d_count++;
+	dcount_inc(ret);
 	spin_unlock(&ret->d_lock);
 	return ret;
 }
@@ -765,7 +764,7 @@ static void try_prune_one_dentry(struct dentry *dentry)
 	while (dentry) {
 		spin_lock(&dentry->d_lock);
 		if (dentry->d_count > 1) {
-			dentry->d_count--;
+			dcount_dec(dentry);
 			spin_unlock(&dentry->d_lock);
 			return;
 		}
@@ -1970,7 +1969,7 @@ struct dentry *__d_lookup(const struct dentry *parent, const struct qstr *name)
 				goto next;
 		}
 
-		dentry->d_count++;
+		dcount_inc(dentry);
 		found = dentry;
 		spin_unlock(&dentry->d_lock);
 		break;
@@ -2937,7 +2936,7 @@ resume:
 		}
 		if (!(dentry->d_flags & DCACHE_GENOCIDE)) {
 			dentry->d_flags |= DCACHE_GENOCIDE;
-			dentry->d_count--;
+			dcount_dec(dentry);
 		}
 		spin_unlock(&dentry->d_lock);
 	}
@@ -2945,7 +2944,7 @@ resume:
 		struct dentry *child = this_parent;
 		if (!(this_parent->d_flags & DCACHE_GENOCIDE)) {
 			this_parent->d_flags |= DCACHE_GENOCIDE;
-			this_parent->d_count--;
+			dcount_dec(this_parent);
 		}
 		this_parent = try_to_ascend(this_parent, locked, seq);
 		if (!this_parent)
diff --git a/fs/namei.c b/fs/namei.c
index 85e40d1..03dcaed 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -537,7 +537,7 @@ static int unlazy_walk(struct nameidata *nd, struct dentry *dentry)
 		 */
 		BUG_ON(!IS_ROOT(dentry) && dentry->d_parent != parent);
 		BUG_ON(!parent->d_count);
-		parent->d_count++;
+		dcount_inc(parent);
 		spin_unlock(&dentry->d_lock);
 	}
 	spin_unlock(&parent->d_lock);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 1a6bb81..99da5e2 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -258,6 +258,99 @@ extern int have_submounts(struct dentry *);
 extern void d_rehash(struct dentry *);
 
 /**
+ * 	dcount_inc, dcount_dec - increment or decrement the dentry reference
+ * 				 count
+ * 	@dentry: dentry to get a reference to
+ */
+static inline void dcount_inc(struct dentry *dentry)
+{
+#ifdef  __HAVE_ARCH_CMPXCHG
+	atomic_inc((atomic_t *)&dentry->d_count);
+#else
+	dentry->d_count++;
+#endif
+}
+
+static inline void dcount_dec(struct dentry *dentry)
+{
+#ifdef  __HAVE_ARCH_CMPXCHG
+	atomic_dec((atomic_t *)&dentry->d_count);
+#else
+	dentry->d_count--;
+#endif
+}
+
+/**
+ * 	dcount_inc_cmpxchg - increment dentry reference count using cmpxchg
+ * 	@dentry: dentry to get a reference to
+ * 	Return : 0 on failure, else 1
+ *
+ * 	N.B. For architectures that do not have a cmpxchg instruction, the
+ * 	     substitute code may not perform better than taking the lock.
+ * 	     So this cmpxchg code path is disabled for those cases.
+ */
+static inline int dcount_inc_cmpxchg(struct dentry *dentry)
+{
+#ifdef	__HAVE_ARCH_CMPXCHG
+	int oldc, newc;
+
+	if ((oldc = dentry->d_count) > 1) {
+		/*
+		 * If reference count > 1, we can safely increment its
+		 * value using atomic cmpxchg without locking. If the
+		 * operation fails, fall back to using the lock.
+		 */
+		newc = oldc + 1;
+		if (cmpxchg(&dentry->d_count, oldc, newc) == oldc)
+			return 1;
+		cpu_relax();
+		/* Retry one more time */
+		if (likely((oldc = ACCESS_ONCE(dentry->d_count)) > 1)) {
+			newc = oldc + 1;
+			if (cmpxchg(&dentry->d_count, oldc, newc) == oldc)
+				return 1;
+			cpu_relax();
+		}
+	}
+#endif
+	return 0;
+}
+
+/**
+ * 	dcount_dec_cmpxchg - decrement dentry reference count using cmpxchg
+ * 	@dentry: dentry to get a reference to
+ * 	Return : 0 on failure, else 1
+ */
+static inline int dcount_dec_cmpxchg(struct dentry *dentry)
+{
+#ifdef	__HAVE_ARCH_CMPXCHG
+	int	oldc, newc;
+
+	/*
+	 * If d_count is bigger than 2, we can safely decrement the
+	 * reference count using atomic cmpxchg instruction without locking.
+	 * Even if d_lock is taken by a thread running dput() with a parallel
+	 * atomic_dec(), the reference count won't go to 0 without anyone
+	 * noticing.
+	 */
+	if ((oldc = dentry->d_count) > 2) {
+		newc = oldc - 1;
+		if (cmpxchg(&dentry->d_count, oldc, newc) == oldc)
+			return 1;
+		cpu_relax();
+		/* Retry one more time */
+		if (likely((oldc = ACCESS_ONCE(dentry->d_count)) > 2)) {
+			newc = oldc - 1;
+			if (cmpxchg(&dentry->d_count, oldc, newc) == oldc)
+				return 1;
+			cpu_relax();
+		}
+	}
+#endif
+	return 0;
+}
+
+/**
  * d_add - add dentry to hash queues
  * @entry: dentry to add
  * @inode: The inode to attach to this dentry
@@ -319,7 +412,7 @@ static inline int __d_rcu_to_refcount(struct dentry *dentry, unsigned seq)
 	assert_spin_locked(&dentry->d_lock);
 	if (!read_seqcount_retry(&dentry->d_seq, seq)) {
 		ret = 1;
-		dentry->d_count++;
+		dcount_inc(dentry);
 	}
 
 	return ret;
@@ -340,7 +433,6 @@ extern char *dentry_path_raw(struct dentry *, char *, int);
 extern char *dentry_path(struct dentry *, char *, int);
 
 /* Allocation counts.. */
-
 /**
  *	dget, dget_dlock -	get a reference to a dentry
  *	@dentry: dentry to get a reference to
@@ -352,13 +444,16 @@ extern char *dentry_path(struct dentry *, char *, int);
 static inline struct dentry *dget_dlock(struct dentry *dentry)
 {
 	if (dentry)
-		dentry->d_count++;
+		dcount_inc(dentry);
 	return dentry;
 }
 
 static inline struct dentry *dget(struct dentry *dentry)
 {
 	if (dentry) {
+		if (dcount_inc_cmpxchg(dentry))
+			return dentry;
+
 		spin_lock(&dentry->d_lock);
 		dget_dlock(dentry);
 		spin_unlock(&dentry->d_lock);
-- 
1.7.1

