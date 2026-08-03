Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54329234994;
	Mon,  3 Aug 2026 01:37:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721045; cv=none; b=rRv0xN6oC8CBWvQMnHNRjh7bCaBk5WAYF16QCDGSWef3nxiv/leCC5ly8qfW6Xq6Zj0PMR6OLLgxKJT99QQYSdp0BciaI8DbkRJhwI92qIG04kAFHI++6DYlSCwgdNMzXVMsA2pAZdmLJV0/UcOu0Ttu/MRXWR8rh7hx/8s4vD4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721045; c=relaxed/simple;
	bh=401i6Z5GG9cTsjdVxnD7qFGHqGrtRGtNTRuNnVOuIbE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dGRvrnk6vkNEmHVJE/14rVPuyNTmLBW7CGnvGcuHYuqUGDOl8N1omeY4SF4pKSQliUe7griJ5qiYszUJOpIKDZbA9cipFqniBY9jjl3zFm+ChTS+hGuHO1Mqx5l9h7FeWHB8ShXRTXiseU4Gfl/K19p06OO//3JhF98khvvRp+0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=SFTTrsHR; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=UH2KPqA5; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="SFTTrsHR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UH2KPqA5"
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailflow.stl.internal (Postfix) with ESMTP id 34D2213000F6;
	Sun,  2 Aug 2026 21:37:23 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-07.internal (MEProxy); Sun, 02 Aug 2026 21:37:23 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721043;
	 x=1785728243; bh=KKcnwC8Mb4fIQv7KY/kS1ANG9v3IccJuytYcwXx5Xqo=; b=
	SFTTrsHRCfjKEuFoG73XY+QWDij4Y+67yvj6WJRZVtP2G52UqifGuZyEh7dNz7m0
	MbR2CYvy2+6il5GxxEoYO7LNm5zKenJS9o0S33lYFv59bkJSYHMTwIWWv09ls+rB
	vd/fcZsA5jIPWYH4HzMT33PvYPgkcJhJKHmskCfiDexwkz2j7z7M+YnMzVsUi8eL
	Xfw9VrCLNAa17eukch4oeP7RR4giOuLmLTwDfJowAh8MCWXOThj/IWFgSFtRXQ7x
	VV4DPmXSDxXfUucgvoL7ep11mWt9fQimfP2RR03QfQXtOY0dA+T3WZECx6Y8jbpP
	+VtQZuqWb84Hxx32QS7gaA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721043; x=1785728243; bh=K
	KcnwC8Mb4fIQv7KY/kS1ANG9v3IccJuytYcwXx5Xqo=; b=UH2KPqA5m/eshrS/o
	3cEi/iJCLA2eiWhR4mqGKsMiBhrHbQfe12qw+X0HRN4ZdKrnHGLAartGGHQSO/jh
	PRqGHHMIKqh+9DQp1Uixzfsrl8Vd8aemMFgkp6CJrjVepmHZ9nMFF0OzMj6A7/2w
	Rn663aSw2U7SHBVDYfDw0tiiLfdSBFW45+RUlcip7MpbwklfVAN73cUKDdLws7qN
	PPxxk/6trgjChh80hPQP/H+WDIXMwMMjJyrxPBLc/OInrg/qJJSE81vzDAaUck13
	LikM8LWNdBKYV3jrrcwAzp6DXViAEfiK4Vv8/yReWkc84qFylHddj0llojG5RwS5
	bX/dg==
X-ME-Sender: <xms:0vBvan4Yiv9jDpjMM_bnWSQA52_F7k5Tjj3dIwtLf84ARkgx2j33OQ>
    <xme:0vBvan6y0SmTMYDVKrA9uVNTVrWZfiyWE1KXkHEDso74jTACjDWnkIewMgwCFjOx6
    5_7y_Zzc7pX880ZJIidXgkwaJDqct2C37LITgAg3XV26dfsXw>
X-ME-Received: <xmr:0vBvalGGltOHNQQKSaJvF6cX0wMx8FOg2e7eOKiipgs7ussdzRhGi6hS0lzM3rKNE2lm3STz6yk1KMGa3pCxOAFP-I1WZUA>
X-ME-Proxy-Cause: dmFkZTEu0UNNG3Y5ooWE0RW0hb4az30oOOCqiR21A+NF5dBXRIXwF7e1ZQQcPeI1Y+2g3G
    2p5taGZPwiaaM3/xeTLW1FCz9U/vJJJskTdg41lYE8VUiZH3MPaQbRkjgX9sOC9ECG/cTt
    EsmfJCIwMKXkPJdCSK/JXV+uNx8CZDrRBVBEoFtsVP6zXAB6qeB8/w/DykMlOqIBtf3Btj
    xISH9DdsaZIjdYArnJRbVHFMU7yzbJxCLAWmCc9hUaSiSdlTAIOT4N2Kv8CS0tgpHV+N+f
    k8nNXssq6c7SmtuWSNjzKUGklZ3BjLsq0xMUopueJIhR+ZPYvLBJVSK2Tqb5Oui4sXj8gj
    6lGUmWKiQq5QWvtujIW75gIJM8qapI3KgTP+zsOJP96YF9urjRaChN7TbSXYgSHFLFLB+o
    T8Kq0E8oAF9UzHiNVaf18Jy0vkeobxFf8c7zeYcswgmkL4rmV1SjocuhyKy72otqvwtpdW
    qiEIWC+V+icGKH8CBd30ikuUj1Y1pcR0RtJIFtNWkla5bp1uwbqZKR/fS+GmVoTI2ScrkD
    vQrc50Ez4FuA97dgnA+0hy36RFezvTI4QN1eUcq6zToe9kIqJDYh2M6bPMNmngtPGOOP0L
    Zu7rE48zBnsHzVSFEZPytQgqm07VXYDh18IcDCyw9PZqhS2VBwWK6Eppcirg
X-ME-Proxy: <xmx:0vBvalwIuWM5tZXty8pxtyEi5utxv3pdJqDGPhxxCvXmr7qpQTPQ6Q>
    <xmx:0vBval1dDIArmfjCLqyu739sQeke16uSiN84KvazOpJ21g_j5trlbA>
    <xmx:0vBvaoN9g7HYYyIsbXgPlJZD5KBtqs63ZvBtYbJhvZYLYg3x9Gj3tQ>
    <xmx:0vBvahtvzi4HmKjgTHM1yHx1ZBLI02i7X5vCXuyquh1BOEfXImQhfg>
    <xmx:0_BvajR5k6nq7Wf-LihGfZMtvl2WfsudxdmLhSQ9iC9HsRFt3RaFZlwg>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:37:15 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Ian Kent <raven@themaw.net>,
	Chuck Lever <cel@kernel.org>,
	Jake Edge <jake@lwn.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	coda@cs.cmu.edu,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	codalist@coda.cs.cmu.edu,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v1 02/12] Add and use d_for_each_positive_child family of iterators
Date: Mon,  3 Aug 2026 11:21:11 +1000
Message-ID: <20260803012648.2195405-3-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260803012648.2195405-1-neilb@ownmail.net>
References: <20260803012648.2195405-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Provide iterators for the d_children/d_sib lists.  These iterators only
report dentries that are positive (though they could be negative by the
time they are used).  As DCACHE_DENTRY_CURSOR dentries are never
positive they are never reported.

d_for_each_positive_child() takes the parent lock and sets the iterator
to each positive child in turn.

d_for_each_positive_child_continue() can continue after an existing
dentry, or (when initialised to NULL) behave like
d_for_each_positive_child().  This requires that something prevent the
start dentry from being moved before
d_for_each_positive_child_continue() can take the parent lock -
typically ->i_rwsem.

The use of scoped_guard() in these macros makes it safe to "break" or
"goto" out of the loop - the lock will be dropped in that case.

These are then used everywhere outside of dcache.c and libfs.c where
d_children/d_sib iteration is needed.

coda_flag_children() doesn't need rcu_read_lock() as holding any
spinlock prevents an RCU critical section from finishing.

nfs_clear_verifier_directory() is changed slightly so the parent lock is
dropped and retaken between clearing the verifier on the parent and on
all the children.  I think this is safe.

get_next_postive_dentry() in autofs now holds the parent lock a bit
less.  The only non-trivial code that is no locked any more is
   parent = p->d_parent
This cannot need the lock as autofs doesn't support rename and
a ref is held on a descendent of parent, so ->d_parent cannot
change.  And if it could, the lock wouldn't help.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c     | 11 +-------
 fs/ceph/mds_client.c   | 10 +++-----
 fs/coda/cache.c        |  6 +----
 fs/libfs.c             |  4 +--
 fs/nfs/dir.c           |  7 ++---
 fs/notify/fsnotify.c   |  7 +----
 include/linux/dcache.h | 58 ++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 67 insertions(+), 36 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index 5c2d459e1e48..7b0a22629415 100644
--- a/fs/autofs/expire.c
+++ b/fs/autofs/expire.c
@@ -70,12 +70,9 @@ static int autofs_mount_busy(struct vfsmount *mnt,
 	return status;
 }
 
-/* p->d_lock held */
 static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 {
-	child = child ? d_next_sibling(child) : d_first_child(p);
-
-	hlist_for_each_entry_from(child, d_sib) {
+	d_for_each_positive_child_continue(child, p) {
 		spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
 		if (simple_positive(child)) {
 			dget_dlock(child);
@@ -98,9 +95,7 @@ static struct dentry *get_next_positive_subdir(struct dentry *prev,
 	struct dentry *q;
 
 	spin_lock(&sbi->lookup_lock);
-	spin_lock(&root->d_lock);
 	q = positive_after(root, prev);
-	spin_unlock(&root->d_lock);
 	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return q;
@@ -119,7 +114,6 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 		return dget(root);
 
 	spin_lock(&sbi->lookup_lock);
-	spin_lock(&p->d_lock);
 	while (1) {
 		struct dentry *parent;
 
@@ -127,12 +121,9 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 		if (ret || p == root)
 			break;
 		parent = p->d_parent;
-		spin_unlock(&p->d_lock);
-		spin_lock(&parent->d_lock);
 		d = p;
 		p = parent;
 	}
-	spin_unlock(&p->d_lock);
 	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return ret;
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 3c692ad02c85..5c4e72c3b110 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -2182,14 +2182,10 @@ static bool drop_negative_children(struct dentry *dentry)
 	if (!d_is_dir(dentry))
 		goto out;
 
-	spin_lock(&dentry->d_lock);
-	hlist_for_each_entry(child, &dentry->d_children, d_sib) {
-		if (d_really_is_positive(child)) {
-			all_negative = false;
-			break;
-		}
+	d_for_each_positive_child(child, dentry) {
+		all_negative = false;
+		break;
 	}
-	spin_unlock(&dentry->d_lock);
 
 	if (all_negative)
 		shrink_dcache_parent(dentry);
diff --git a/fs/coda/cache.c b/fs/coda/cache.c
index 245131296300..dca88d749b86 100644
--- a/fs/coda/cache.c
+++ b/fs/coda/cache.c
@@ -92,16 +92,12 @@ static void coda_flag_children(struct dentry *parent, int flag)
 {
 	struct dentry *de;
 
-	spin_lock(&parent->d_lock);
-	rcu_read_lock();
-	hlist_for_each_entry(de, &parent->d_children, d_sib) {
+	d_for_each_positive_child(de, parent) {
 		struct inode *inode = d_inode_rcu(de);
 		/* don't know what to do with negative dentries */
 		if (inode)
 			coda_flag_inode(inode, flag);
 	}
-	rcu_read_unlock();
-	spin_unlock(&parent->d_lock);
 }
 
 void coda_flag_inode_children(struct inode *inode, int flag)
diff --git a/fs/libfs.c b/fs/libfs.c
index 5a0d276379d1..fc283e0a7c3a 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -768,8 +768,7 @@ int simple_empty(struct dentry *dentry)
 	struct dentry *child;
 	int ret = 0;
 
-	spin_lock(&dentry->d_lock);
-	hlist_for_each_entry(child, &dentry->d_children, d_sib) {
+	d_for_each_positive_child(child, dentry) {
 		spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
 		if (simple_positive(child)) {
 			spin_unlock(&child->d_lock);
@@ -779,7 +778,6 @@ int simple_empty(struct dentry *dentry)
 	}
 	ret = 1;
 out:
-	spin_unlock(&dentry->d_lock);
 	return ret;
 }
 EXPORT_SYMBOL(simple_empty);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c7caffb31935..7a7419458c6a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1492,10 +1492,8 @@ static void nfs_clear_verifier_directory(struct inode *dir)
 
 	spin_lock(&this_parent->d_lock);
 	nfs_unset_verifier_delegated(&this_parent->d_time);
-	dentry = d_first_child(this_parent);
-	hlist_for_each_entry_from(dentry, d_sib) {
-		if (unlikely(dentry->d_flags & DCACHE_DENTRY_CURSOR))
-			continue;
+	spin_unlock(&this_parent->d_lock);
+	d_for_each_positive_child(dentry, this_parent) {
 		inode = d_inode_rcu(dentry);
 		if (inode &&
 		    NFS_PROTO(inode)->have_delegation(inode, FMODE_READ, 0))
@@ -1504,7 +1502,6 @@ static void nfs_clear_verifier_directory(struct inode *dir)
 		nfs_unset_verifier_delegated(&dentry->d_time);
 		spin_unlock(&dentry->d_lock);
 	}
-	spin_unlock(&this_parent->d_lock);
 }
 
 /**
diff --git a/fs/notify/fsnotify.c b/fs/notify/fsnotify.c
index 7e2f330fd283..90a2121fc54a 100644
--- a/fs/notify/fsnotify.c
+++ b/fs/notify/fsnotify.c
@@ -85,16 +85,11 @@ void fsnotify_set_children_dentry_flags(struct inode *inode)
 		/* run all of the children of the original inode and fix their
 		 * d_flags to indicate parental interest (their parent is the
 		 * original inode) */
-		spin_lock(&alias->d_lock);
-		hlist_for_each_entry(child, &alias->d_children, d_sib) {
-			if (!child->d_inode)
-				continue;
-
+		d_for_each_positive_child(child, alias) {
 			spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
 			child->d_flags |= DCACHE_FSNOTIFY_PARENT_WATCHED;
 			spin_unlock(&child->d_lock);
 		}
-		spin_unlock(&alias->d_lock);
 	}
 	spin_unlock(&inode->i_lock);
 }
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 64d64bab16fe..cabf05e74b1f 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -656,6 +656,64 @@ static inline struct dentry *d_next_sibling(const struct dentry *dentry)
 	return hlist_entry_safe(dentry->d_sib.next, struct dentry, d_sib);
 }
 
+static inline struct dentry *d_next_positive(struct dentry *child)
+{
+	do {
+		child = d_next_sibling(child);
+	} while (child && !d_really_is_positive(child));
+	return child;
+}
+
+static inline struct dentry *d_first_positive(const struct dentry *parent,
+					      struct dentry *child)
+{
+	if (!child)
+		child = d_first_child(parent);
+	else
+		child = d_next_sibling(child);
+	if (child && !d_really_is_positive(child))
+		child = d_next_positive(child);
+	return child;
+}
+
+/**
+ * d_for_each_positive_child - iterate over positive children in the dcache
+ * @child: iterator dentry
+ * @parent: dentry of parent
+ *
+ * Iteratively set @child to each positive child of @parent.
+ * @parent->d_lock should NOT be held.
+ * @child may no longer be positive when the caller examines it
+ * so care is still needed which could involve locking the child
+ * or using d_inode_rcu() to access the inode.
+ *
+ * DCACHE_DENTRY_CURSOR dentries will never be returned, only true children
+ * which have at some point in the past been positive.
+ */
+#define d_for_each_positive_child(child, parent)			\
+	scoped_guard(spinlock, &parent->d_lock)				\
+		for (child = d_first_positive(parent, NULL); child;	\
+		     child = d_next_positive(child))
+
+/**
+ * d_for_each_positive_child_continue - iterate over remaining positive children
+ * @child: iterator dentry and starting point.
+ * @parent: dentry of parent
+ *
+ * If @child is %NULL this behaves identically to d_for_each_positive_child().
+ * Otherwise @child must be an existing child of %parent and subsequent children
+ * in the d_children list of @parent are returned.
+ *
+ * Safely using this requires that something prevents @child from being
+ * renamed to a different directory before we get the lock.  Holding
+ * i_rwsem on the @parent is sufficient.
+ *
+ */
+#define d_for_each_positive_child_continue(child, parent)		\
+	scoped_guard(spinlock, &parent->d_lock)				\
+		for (child = d_first_positive(parent, child); child;	\
+		     child = d_next_positive(child))
+
 void set_default_d_op(struct super_block *, const struct dentry_operations *);
 struct dentry *d_make_persistent(struct dentry *, struct inode *);
 void d_make_discardable(struct dentry *dentry);
-- 
2.50.0.107.gf914562f5916.dirty

