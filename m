From: Waiman Long <Waiman.Long@hp.com>
Subject: [PATCH v2 1/4] dcache: Don't take unnecessary lock in d_count update
Date: Fri,  5 Apr 2013 12:57:38 -0400
Message-ID: <1365181061-30787-2-git-send-email-Waiman.Long__10265.8912925564$1366020494$gmane$org@hp.com>
References: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, "Norton,
	Scott J" <scott.norton@hp.com>, autofs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	"Chandramouleeswaran, Aswin" <aswin@hp.com>,
	Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>,
	linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org
Return-path: <samba-technical-bounces@lists.samba.org>
To: 
In-Reply-To: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk> , Jeff Layton <jlayton@redhat.com>,
	Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
	Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Eric Paris <eparis@redhat.com>
List-Unsubscribe: <https://lists.samba.org/mailman/options/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces@lists.samba.org
Errors-To: samba-technical-bounces@lists.samba.org
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

This patch has a particular big impact on the short workload of
the AIM7 benchmark with ramdisk filesystem. The table below show the
performance improvement due to this patch on an 8-socket 80-core x86-64
system with a 3.8.5 kernel in a 1/2/4/8 node configuration by using
numactl to restrict the execution of the workload on certain nodes.

+-----------------+------------------+------------------+----------+
|  Configuration  | Mean Transaction | Mean Transaction | % Change |
|                 |  Rate w/o patch  | Rate with patch  |          |
+-----------------+------------------------------------------------+
|                 |              User Range 10 - 100               |
+-----------------+------------------------------------------------+
| 8 nodes, HT off |     1929234      |     2966230      |  +53.8%  |
| 4 nodes, HT off |     1700737      |     3177040      |  +86.8%  |
| 2 nodes, HT off |     1964055      |     3088446      |  +57.3%  |
| 1 node , HT off |     2187851      |     2127176      |   -2.8%  |
+-----------------+------------------------------------------------+
|                 |              User Range 200 - 1000             |
+-----------------+------------------------------------------------+
| 8 nodes, HT off |     1096000      |     2474223      | +125.8%  |
| 4 nodes, HT off |     1369181      |     2731234      |  +99.5%  |
| 2 nodes, HT off |      967425      |     2867641      | +196.4%  |
| 1 node , HT off |     2052671      |     2042276      |   -0.5%  |
+-----------------+------------------------------------------------+
|                 |              User Range 1100 - 2000            |
+-----------------+------------------------------------------------+
| 8 nodes, HT off |     1088118      |     2235631      | +105.5%  |
| 4 nodes, HT off |     1380696      |     2518980      |  +82.4%  |
| 2 nodes, HT off |      839542      |     2743082      | +226.7%  |
| 1 node , HT off |     1970821      |     1980873      |   +0.5%  |
+-----------------+------------------+------------------+----------+

It can be seen that with 20 CPUs (2 nodes) or more, this patch can
significantly improve the short workload performance. With only 1
node, the performance is similar with or without the patch.

A perf call-graph report of the short workload at 800 users without
the patch on 8 nodes indicates that about 88% of the workload's total
time were spent in the _raw_spin_lock() function. Almost all of which
can be attributed to the following 2 kernel functions:
 1. dget_parent (50.14%)
 2. dput (49.48%)

With this patch on, the time spent on _raw_spin_lock() is only 1.31%
which is a huge improvement.

This impact of this patch on other AIM7 workloads were much more
modest.  The table below show the mean %change due to this patch on
the same 8-socket system with a 3.7.10 kernel.

+--------------+---------------+----------------+-----------------+
|   Workload   | mean % change | mean % change  | mean % change   |
|              | 10-100 users  | 200-1000 users | 1100-2000 users |
+--------------+---------------+----------------+-----------------+
| alltests     |     +0.6%     |     +9.7%      |     +2.9%       |
| five_sec     |     +0.4%     |      0.0%      |     +0.3%       |
| fserver      |     +0.7%     |     +2.4%      |     +2.0%       |
| high_systime |     -1.5%     |    -15.2%      |    -38.0%       |
| new_fserver  |     -2.2%     |     +6.5%      |     +0.4%       |
| shared       |     +3.9%     |     +1.1%      |     +6.1%       |
+--------------+---------------+----------------+-----------------+

The regression in the high_systime workload was probably caused
by the decrease in spinlock contention led to a larger increase in
mutex contention. In fact, after applying a mutex patch to reduce
mutex contention, the performance difference due to the addition of
this dcache patch changed to:

+--------------+---------------+----------------+-----------------+
|   Workload   | mean % change | mean % change  | mean % change   |
|              | 10-100 users  | 200-1000 users | 1100-2000 users |
+--------------+---------------+----------------+-----------------+
| high_systime |     -0.1%     |     -0.2%      |     +1.2%       |
+--------------+---------------+----------------+-----------------+

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 fs/dcache.c            |   39 ++++++++----------
 fs/namei.c             |    2 +-
 include/linux/dcache.h |  101 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 117 insertions(+), 25 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index fbfae00..48c0680 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -484,7 +484,7 @@ relock:
 	}
 
 	if (ref)
-		dentry->d_count--;
+		dcount_dec(dentry);
 	/*
 	 * if dentry was on the d_lru list delete it from there.
 	 * inform the fs via d_prune that this dentry is about to be
@@ -530,10 +530,13 @@ void dput(struct dentry *dentry)
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
@@ -550,7 +553,7 @@ repeat:
 	dentry->d_flags |= DCACHE_REFERENCED;
 	dentry_lru_add(dentry);
 
-	dentry->d_count--;
+	dcount_dec(dentry);
 	spin_unlock(&dentry->d_lock);
 	return;
 
@@ -621,11 +624,13 @@ EXPORT_SYMBOL(d_invalidate);
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
@@ -635,22 +640,14 @@ struct dentry *dget_parent(struct dentry *dentry)
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
-		rcu_read_unlock();
-		goto repeat;
-	}
+	ret = rcu_dereference(dentry->d_parent);
 	rcu_read_unlock();
+	if (dcount_inc_cmpxchg(ret))
+		return ret;
+	spin_lock(&ret->d_lock);
 	BUG_ON(!ret->d_count);
-	ret->d_count++;
+	dcount_inc(ret);
 	spin_unlock(&ret->d_lock);
 	return ret;
 }
@@ -780,7 +777,7 @@ static void try_prune_one_dentry(struct dentry *dentry)
 	while (dentry) {
 		spin_lock(&dentry->d_lock);
 		if (dentry->d_count > 1) {
-			dentry->d_count--;
+			dcount_dec(dentry);
 			spin_unlock(&dentry->d_lock);
 			return;
 		}
@@ -1981,7 +1978,7 @@ struct dentry *__d_lookup(const struct dentry *parent, const struct qstr *name)
 				goto next;
 		}
 
-		dentry->d_count++;
+		dcount_inc(dentry);
 		found = dentry;
 		spin_unlock(&dentry->d_lock);
 		break;
@@ -2943,7 +2940,7 @@ resume:
 		}
 		if (!(dentry->d_flags & DCACHE_GENOCIDE)) {
 			dentry->d_flags |= DCACHE_GENOCIDE;
-			dentry->d_count--;
+			dcount_dec(dentry);
 		}
 		spin_unlock(&dentry->d_lock);
 	}
@@ -2951,7 +2948,7 @@ resume:
 		struct dentry *child = this_parent;
 		if (!(this_parent->d_flags & DCACHE_GENOCIDE)) {
 			this_parent->d_flags |= DCACHE_GENOCIDE;
-			this_parent->d_count--;
+			dcount_dec(this_parent);
 		}
 		this_parent = try_to_ascend(this_parent, locked, seq);
 		if (!this_parent)
diff --git a/fs/namei.c b/fs/namei.c
index 57ae9c8..6bbd475 100644
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
