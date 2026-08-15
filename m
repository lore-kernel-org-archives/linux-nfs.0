Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36D0E2222CC;
	Sat, 15 Aug 2026 04:29:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768142; cv=none; b=Io8gcUmnBHLAzgpElI8U5tcVHZaIlL3HJPaIEyjQnzEZ9HcSZtM0kYbqKFQnlXVTccVj2TzH9BlpiaPhv/Zf7MPLjITMdOvgUEC6nspE45r7K2d5RE9V1RMZsXBd2KPwo5+gIrphHVkwX+7kxp+QD5pgt0AJYRnUulpOEStMQX8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768142; c=relaxed/simple;
	bh=p1mMn9qOZZwguR9yZ3qRBputr4xWHGS+mAUHVqwEuY8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YmnImghSoC6PyhU/cbF79nmGNSaZvgkpFFf0PWp13kwBST+44sSmRWtp80pP2b4jcZGWtJM7MXfAhS+yO4VR9/GKdbIveehxkAJVDWwGVHNaMNs10bCuc7cqLSezU+v/Yn1/XNBpnukukOs3jKo0DU02vfJ+aSAL8XaAA8twtOM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=UREgnDyb; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=KlA2fVSz; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="UREgnDyb";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="KlA2fVSz"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id 09C701380411;
	Sat, 15 Aug 2026 00:29:00 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Sat, 15 Aug 2026 00:29:00 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768140;
	 x=1786775340; bh=AH8tVpPfOZN5UyDdOxfXJOmbn3oiZz5KgirDEs++h9M=; b=
	UREgnDybw91X4mYtsrUAXc4ebAHvCtDn23OpUXls2m9FbLZZgKFEZsdzoViCnTri
	bvIqHKHF2pDIbvHzVOzkCYRoRjZzN581suOLOL0uKfz5cRf89MElOVSTCe1DNOZx
	T5CASOB6nAk/QVVrMDYhlGqHzaTpc+ooi8NiKG9CdtJ7GnBQTNhBWIDVVoJYdoqm
	jYcoIJ8Aplu+s+gnh7b5sqn2QWOKmznVJJ5eIJOFYjNYDYjBxijUdTl6gN3YJAFu
	k3wjucWcFIcUQUGsuDuokupkLg16f6gH8Q+h/BhTP9GplCODWU+FQKnLxc/lK7J3
	lH+JLYLcyqp5TICEUBsFEg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768140; x=1786775340; bh=A
	H8tVpPfOZN5UyDdOxfXJOmbn3oiZz5KgirDEs++h9M=; b=KlA2fVSznUU1V+Wc8
	o4aJV0CCLOZxof1D3YpapXdcX9kovbGQIEg9lk3ov/oc7rTIb9r5mKqPYhF9xvWH
	Lgti6mQ17Nwm79Ckm1Tf5A1lipL3kaeukOUGM8MCt0R1EYpOJF77mX4deplo89NA
	7xHNPdQgz64J2XUVpMLWHgyK9KOg7XBz/ve8giSs3kU2nGFjZ2JzeywfTBpBh1ey
	Sz2RUvaO2F01oDhuyTN/Ch4DDCuhKQw+VA/k5pmlnc4qeoNBZTcE6D8H6lqwXPqY
	QNNeYoie1jNf5DzENJZg7S46Ok6Kgd+TObOzwEMQ7Z08F6s1TVepDxF5JLStyzix
	KQrtA==
X-ME-Sender: <xms:C-t_akznLn78dQ-N6g1xwG5K423p1GSv5WuVwGt-vaDW0EovdWh32A>
    <xme:C-t_agcWn84AtXYcixxRfGB_A3gwcdjI_eabLp-sZa_obtSLC1kqd1npM6h5cutJ2
    nMyc2wKCpxh41zF7naKMlBGu5BnpDKj7DW4gk9NfrwccEDzOg>
X-ME-Received: <xmr:C-t_atq8Q0e6zhtU9iHSbD1jnzKuC6m8cyhGNvJ_PC4_LQzSbIXmWNjBJPqXwC9sQJJoQ09-aKMg6qzSjGy46BV4LL2oIYI>
X-ME-Proxy-Cause: dmFkZTE846WIQAeAfC2svQKIx1rsRetJ1LqZbsylzr9Pg5j2zb0C1579PSws3yCQ5R+Olu
    b4zipOSfuqPCCaiDU3QS41htHgbbUHbw+9IzWKPPDnBCHa6LTRLmDA4RjMkkHbUX8AcF+A
    MaOV82BKDsir/tMJG7jGbG0WSaN6GMmU4sezvndaPTX2rOOXNVUsNv6YabWiNiTF4FcJlI
    4RfFT7jjBx2dFRn3NgR5XxWgsk6mzpLzO8biU/naSZJT+ZXMzU/K2WBbpybV+o2TIlRRCb
    KSueBiL5GSYxcW7IeiZ+C1vDelgggOSZL/+/q2EWxFhEhtw6QnwbZ3VRg5nZrTdYUceOGJ
    QLpHXKd9HHznugxMz98kj3me/NvtT9doUUxsnNXicuRJZ/aAZd3fqQ9H28qACe5K4RyzWU
    QWxbensHeA8lFkRtEdj2ZXW+0Gp3giu8YTDrGdqxdahIQHF7iqJsSwrnE+0omSdvjc2Tck
    3wfFX3hXRIUu+oSs4mTOUWy/aDS7Qoqop9SLGyZUh2qTdDoBA4KjU8JFWJtTPYilcA8Ozj
    WZ76pmEavFTNNg54YU8f5IcyfYm2yV1hLzLed5vRbWaGjDA0yKv2Cgd5rO3iHFn4DnYxXo
    4SN4nYxbPHaHeaYVDhLTHLf5WC0oyJsMXEG7KfD6WwA3OSNannI5BVCu2k7w
X-ME-Proxy: <xmx:C-t_agNrbKhLIYgznJa7ioAjcUyY7B0pm98n1Z880WA8GdiFoRAYyA>
    <xmx:C-t_ajFxtLcDf0QblhZ5iQtW2ArzM0LX_kHMZgtC0of5zWggOOWdhQ>
    <xmx:C-t_ajGE_FSaD7TL_M4LPu49h5pOVilZ699Xpyo37D-5a0MaiR3A-g>
    <xmx:C-t_aiDq0PzD5pjdRPqOPvQGkVxQhAmAtIR4aLC1uf8EFSgE7alDdA>
    <xmx:DOt_auj0qImOLb81N6JY7WSooZWm8NzjRQMnm_aJNypZrMwqbFJiOgt_>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:28:53 -0400 (EDT)
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
Subject: [PATCH v2 05/18] Add and use d_for_each_positive_child family of iterators
Date: Sat, 15 Aug 2026 14:21:22 +1000
Message-ID: <20260815042707.2535717-6-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260815042707.2535717-1-neilb@ownmail.net>
References: <20260815042707.2535717-1-neilb@ownmail.net>
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

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c     |  7 +----
 fs/ceph/mds_client.c   | 10 +++-----
 fs/coda/cache.c        |  4 +--
 fs/libfs.c             |  4 +--
 fs/nfs/dir.c           |  7 +----
 fs/notify/fsnotify.c   |  7 +----
 include/linux/dcache.h | 58 ++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 66 insertions(+), 31 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index 909622eeb8a0..ba1a3a2bfc9a 100644
--- a/fs/autofs/expire.c
+++ b/fs/autofs/expire.c
@@ -72,10 +72,7 @@ static int autofs_mount_busy(struct vfsmount *mnt,
 
 static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 {
-	spin_lock(&p->d_lock);
-	child = child ? d_next_sibling(child) : d_first_child(p);
-
-	hlist_for_each_entry_from(child, d_sib) {
+	d_for_each_positive_child_continue(child, p) {
 		spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
 		if (simple_positive(child)) {
 			dget_dlock(child);
@@ -84,8 +81,6 @@ static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 		}
 		spin_unlock(&child->d_lock);
 	}
-	spin_unlock(&p->d_lock);
-
 	return NULL;
 }
 
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
index 970f0022ec52..dca88d749b86 100644
--- a/fs/coda/cache.c
+++ b/fs/coda/cache.c
@@ -92,14 +92,12 @@ static void coda_flag_children(struct dentry *parent, int flag)
 {
 	struct dentry *de;
 
-	spin_lock(&parent->d_lock);
-	hlist_for_each_entry(de, &parent->d_children, d_sib) {
+	d_for_each_positive_child(de, parent) {
 		struct inode *inode = d_inode_rcu(de);
 		/* don't know what to do with negative dentries */
 		if (inode)
 			coda_flag_inode(inode, flag);
 	}
-	spin_unlock(&parent->d_lock);
 }
 
 void coda_flag_inode_children(struct inode *inode, int flag)
diff --git a/fs/libfs.c b/fs/libfs.c
index 7cd816b8e2a0..8e99067079e8 100644
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
index bba5d996413c..3aa874626299 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1494,11 +1494,7 @@ static void nfs_clear_verifier_directory(struct inode *dir)
 	nfs_unset_verifier_delegated(&this_parent->d_time);
 	spin_unlock(&this_parent->d_lock);
 
-	spin_lock(&this_parent->d_lock);
-	dentry = d_first_child(this_parent);
-	hlist_for_each_entry_from(dentry, d_sib) {
-		if (unlikely(dentry->d_flags & DCACHE_DENTRY_CURSOR))
-			continue;
+	d_for_each_positive_child(dentry, this_parent) {
 		inode = d_inode_rcu(dentry);
 		if (inode &&
 		    NFS_PROTO(inode)->have_delegation(inode, FMODE_READ, 0))
@@ -1507,7 +1503,6 @@ static void nfs_clear_verifier_directory(struct inode *dir)
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

