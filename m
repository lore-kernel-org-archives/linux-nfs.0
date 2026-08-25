Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C994C4908CD;
	Tue, 25 Aug 2026 22:16:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696192; cv=none; b=YlDJUdQHJAOVv2qp64iswkYHzgMQKrVn/BBlm8DupMO19OT4ccceNCMlwDkkEEkcJP73jfzFcMNkZaqHXJUni1W353Dy3Ob+fkCJgagIzNeoVrWHQ9dwZWE+BuVVF3PD8PHbcQVG9D5Sa6Y03qd6U8VlAPq4R0eQVI9XeMFJP1g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696192; c=relaxed/simple;
	bh=6aoCjyg6MIezqiXigoJU19gujPvcZ2a+krqzaN6R7uQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gv1MTt9BuNeN5Mqdg4qY1snP14i83zrMpVkmR28deP+YmOuJk7E/coPy7mEaj5oRlPIeoWy07gi4n46ARDsvss/EvGLqFnPmp9QU42GSGszFzpxb4MTVs2CpfCSDbTLHcGqGKGGTVGa4m83XfScADjzMQM8TGc2ccE+lwI/cIzs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=R8/HMe9t; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=b+IG9EwO; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="R8/HMe9t";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="b+IG9EwO"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.stl.internal (Postfix) with ESMTP id 66845130017A;
	Tue, 25 Aug 2026 18:16:28 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Tue, 25 Aug 2026 18:16:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696188;
	 x=1787703388; bh=Djw9koOjpUMNVE7yG/oVlhtyHMqwB/kRtf5a4gs2snM=; b=
	R8/HMe9t0DuC6WhIDn1i3MxG6qvcQ+N7j4Oq3UXORNFBHGhZIbp+mNr/PtwvRiC4
	Wi9qOzTMEAsytql54wU06pitrO8g5t/c9GvQA6TV4w77YQq9PE5b4sWuOrnJYx+2
	sqqF4hkdtRR06Ds7ohYF4xpUpCWse3nYdDXWs6wew2khpWNPSSoVaC0FbHF3C9n+
	Q8sjXgvS7BnMtpFRWRYLm79RrVY5m/AA5+wa3UjY/vBJEtQGxVmTIqcPgEo4jz+X
	6QYig2CQ0GjEJ4a3A8ribvq4xicbWcs7yYaAujqeDkyZx8XUyA8kuHd1QlzakbYo
	30j8GOwQYEvkd/ZpDCmY8w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696188; x=1787703388; bh=D
	jw9koOjpUMNVE7yG/oVlhtyHMqwB/kRtf5a4gs2snM=; b=b+IG9EwOYvbw4v5se
	dbPgqEN9zLtAuQpc1zRKal92aGISj1MOrQlz4mQiSiU+HnRBPJa3Oai1qzDLEdFv
	k9Ukmp8HgaEArKrfqiwuPRmiM/o7tmgEy3uApooQUNcnZzQhNV4Jo1cdNBRkNPeL
	zoOyxOJACUx47Ukc28Elwc3nYoUcS1qMt5cO2cHdyvoRb85H4sa6r/bQvDKXWxwq
	QtvgWHy/o5M7tJ8Qw7v2iBdeTiy9rCSI4YE8DD5w/Qu9qgJHofq2fUOwsjSiVGuu
	OzO9jCDOD4KCrB78ddQxDIz0SpDcm0WgVs3SWog4fibmNkMYk7DkAk0u8veUGAS2
	8gN4g==
X-ME-Sender: <xms:PBSOagjLF-sK1FH536jraB9hMZUaUGy1eteQ-BGKPxV9il0ElRl1aA>
    <xme:PBSOahP1smO8AjWfKfuTz-Vi59uN59Gw_4zQe2DxH5ceS3612JIxio73VKPpOe96P
    yl0HBlqhm8uCAha6FnSgBZPaVJ1IoI4YX4QUfG-xM5nWSSnCUM>
X-ME-Received: <xmr:PBSOavZ8LqJ2bgW9lBp2GaIwnohUfZcdC_VIXapaHwrk2Lkoj7p7M6DTsKHq-aLDP5WEpEIKztQs81Rrnwn4qkN5oFLQ9Lo>
X-ME-Proxy-Cause: dmFkZTE1D9RHiQxYEMTZM66ZwYWPXMa5da/YLC+asllp2LW/9AzO59nDbIWZ/WJDafUyFp
    uQaTnJVoM5zeNV7PU3Y5Sxe6sA3KXuzbkNtIeFEk21vnmQNZ++SlHK1xc12Wi6N9bKT3Nd
    l2Jew0OcpEW6pknEcsl3U5kWlcxIcGyDVCcdakxFha864vAOuxadUTtnPo9vV8kQZOtGh4
    t615j3/PJH3yhet8tW8bKj0XWaL55deZWQpLJVbikNK8UvNeSeZ0y75HchjkQdooZXWGuR
    agEorB2pRIG2wLJFguZ3GUkqAvVfWJvN2myN34TtgOMsQRUTFpr+RStZVbDkRTC4KoXuhX
    jNd7XF10/oFgci/zNfw6syDIXcdujrrXxcHZeaO6Fb9BRacT/HsWb+a7LnUSfFvEjlvd4z
    l2cpz2NdTohM0ibINNUxxjkExeO1duYw4JV8c9/RQaQbHyji5kO1Lp+moRS5hO5gWLvsIY
    h6KJ4ZurLgmmc8sygexVAWAYx1nQhps2aGJ0A8mQBYMq1w5BD6+d7SonVRbu79w5hmMTPa
    EON5byxmjWA8ypjM8yVIT4fvPeSJXwaElXOo1sp5h88bzrzekF7l9ZZUi8kIWkd6C0c3wT
    0y0SXbkjNH8z44SWzFfJxWZyOtDbQiNK8GfA59RYMVbkH0cQfwZp7pzmmSVw
X-ME-Proxy: <xmx:PBSOau9eyai3Oit7ZmNWzAiRNOHnEolUONkZpDN41eIFdSn3IbLcaQ>
    <xmx:PBSOaq1U_udHiTIi0zwr-iEwisSlFwXu_-NSXMffOVQ0LdIT5v4i9A>
    <xmx:PBSOav3HI4X10BE5EjQ8QW429HqBIG72MoJzuCSQgQaOm50xLWbSBA>
    <xmx:PBSOavwPgixKl1ichv873AhL3IdsR5PRrDISB_vSm3h9NlSONcoykg>
    <xmx:PBSOan4LT4APOIHczozDmYTFixyQ1wPKiiu4LcSUxvDoayaTjRdOgPA8>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:16:21 -0400 (EDT)
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
Subject: [PATCH v3 05/11] Add and use d_for_each_positive_child family of iterators
Date: Wed, 26 Aug 2026 08:06:22 +1000
Message-ID: <20260825221459.966875-6-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260825221459.966875-1-neilb@ownmail.net>
References: <20260825221459.966875-1-neilb@ownmail.net>
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
index bc2be7428158..3a70f861ad32 100644
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
@@ -85,8 +82,6 @@ static struct dentry *positive_after(struct dentry *p, struct dentry *child)
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
index 60586fe65895..427f5686decb 100644
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
index ef708bbb8acc..748c8388c4f0 100644
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
index 3b595adff7b4..010d9d47ac01 100644
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

