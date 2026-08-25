Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DC5E499F05;
	Tue, 25 Aug 2026 22:17:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696246; cv=none; b=cy3bh4/rayaD3YHbhfQUAbauDhtA7sCdxBXt8t121rqSqS8AKGAMzwelwHsna4CyWpgx87JBUPfy4Bq1mMJEr7n0KE2sPaUYGrOAHynhEUD372zNu0U0u/6PbuQ6IwFZ08y+xDdh7zK6o4VUpHwLnJ1EW6ewGBriLDd96ylr0j0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696246; c=relaxed/simple;
	bh=a2CabzHJoTG+hhKHw3vEvynX0oIaEA+hEsH2xlg70iY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EwGt3c139mjj0kT1Tzk94bQ/UOMFCe0di2LlRcflfCDyMi9rwyXjO6ReLL2zH3L8HVOl80q0NZap6eh0T6yTRL15mLL5Kf8xv3/gZYGA6ulun6HLFYAqHNk44G+3rmAIWUe3YzpwH8Qq/6ekJfH6AxCGZ1k8Xvl6fmQuFj0Y19Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=JvEQi1cg; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=XUoZeTMb; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="JvEQi1cg";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="XUoZeTMb"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailflow.stl.internal (Postfix) with ESMTP id C42B8130017A;
	Tue, 25 Aug 2026 18:17:23 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Tue, 25 Aug 2026 18:17:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696243;
	 x=1787703443; bh=UBHpINBx7VpvzE09q7PdBwOx6AkTQUjP/c1v2gUqMPs=; b=
	JvEQi1cgFHv6FAZVbFI8HXZFC11AyoNiJU/kCFBmy7Vx7cm6BHGlP/2Q8wJ3reW5
	5ELj22h5lnbmM/X6Fq3zrGqz6RFXyaSuLXpc3MePK1mEjyfTRQ21pmUOm7jTBFln
	yZlO84r6K5g8MMCpEeiRXqi6uC8uRCWoEBJCIFKsay/BtQBjwp3dxTu1P4khlVwd
	C+81DiwpnpCN+rDWrcpANOv/LOQkOzYHBoSTCd0iqQKwDanq8BDtpYSxmozNos6x
	JsKAQCR6twXDjaxE5ZzuWaC7O0uoV0Obt0SKbcbWSQvuCvUh5IqJcviZRvXsH8/z
	B9q1vZlJ9is+5D6YQIZq+w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696243; x=1787703443; bh=U
	BHpINBx7VpvzE09q7PdBwOx6AkTQUjP/c1v2gUqMPs=; b=XUoZeTMbUiUVy9QXZ
	aFyxsv9uZdg3cvwe112ySQUPWWzSGqX4CXtHhepHlM5Z2HhLdkLieVfj3l9X1cR2
	x5YOk4xiXTjCwejuXip+Yda3JGKikSIXgGAdGlHw9CPcJpRY4clx9PsmBnIIYRXv
	s9QhbaH1v+L9SUk+h34IYr++YPtGOfQf4l+laFJfv1QoJlqbsz2KggSmWEnq2B3y
	sohGzvy9A4WunuTMucs4WSQ2wm9JuWJzekMQNkZlCaxWZWki9m2oCCJo6TTpoSKR
	O2BirXfNHAqkiPUQ6z9eVZ7+FeCZEldomBUbgVHx3U9BN1c1IjpTjeNDfdE2qUaU
	BKcIw==
X-ME-Sender: <xms:cxSOajqG8Fyl2pjUVgywaOi7i18HGJP2PtrC-WA4jFNTRxyt-oLuGA>
    <xme:cxSOaopTVSbMAPs7e7k3z7r1NV2bL0z-rcCQHHhBkPiPG9ItX_FzWtXgzEmgsa2vG
    rMDS5_Y1FVxxeXb6RwZB2lKb51wzWwt-JzZi4mTvENcq4eN_w>
X-ME-Received: <xmr:cxSOam3gYnmUORuOjDqTWlx2u1w11yuAAALo_SZsUaMyyCrrzPDcl8EkAYcKNNL3lPf-YZhyZR_nPid-MG5U8jsi-8WWYO8>
X-ME-Proxy-Cause: dmFkZTG3XHstY7oCKVsQdeqHBdBuufcL/CA2QIo6EvAmZ4DJma5jqyLguXmtZz1oV5gGKM
    JCEjUhdv7rmdEGEOLAaZLpBU1Q66TxI/zZMqNpIt0C13TEMeyhIfscK1jE7F1qNOMydH0t
    A5dAmKrJhtCAdCa7hg9xvPxRe0dE/zk1kxscLUDttafsczEWN7oOwsWP0kH42KqwbOw+CV
    S1Ja8pCR8OZYPPoh75DaFRX4LyMBuZHB81G3BkZTKJQySTwonosPQytaGGN+xVjh52eonq
    ej95qkgeaTpeb6AvXzkRFTQqDaqGPeC86IY9QcPV0uy78rknTA3sPKayiCUxSyZoFPTwIB
    LBkBfoNJWtzlw0foJAyWxYZuf+BUwcnddJUeibn0Aci9cFsUfz2sXUyHQrEPWGXfjwEsF/
    FZCbrOkW+LZGBJf6XsPkvq6OKja0QYyQSMdR4Udsdyjn/T91mS/qDRNf8VxUvjcvJBk9+P
    QUgk7nOFMQkVGzPFwbmtAAueMvGk6RleUnzwinuSJzbyuNriB8OKrqlmFt2zGwFY61R2U8
    f2CZwa4YYDHFPAoDWV1/cjfKZKuzeK8UqMjBY8kvUljSyPX/ulnPnR/kPpT389BB7wuJg8
    PYbym9lkrPiva2q97zGQnbuX9lXp01jYMD0jogD4bsqWK652N5CtGX/eoBOw
X-ME-Proxy: <xmx:cxSOakiOgO78IZ4kRz28mIyzGhFdnW8HQR78oCM5IU5LJwMpU8UDeQ>
    <xmx:cxSOatlq4vYkdNSAedxzE1Zc2S8oCNyvI-z2cWCa0RVjE4vPiryf5g>
    <xmx:cxSOak-jFJEtMxcDIqr3u--3ld0J_QWumCrZF8lLkIViKOvdcF34JQ>
    <xmx:cxSOavfOoIdhQx0WdlFodHkTxuteiF6znTpPExOD4cQSh_ul5XzgiA>
    <xmx:cxSOasApdNPksRmCWXLeZeYpMYLzMykXo06ota7S2Lab44DiUYHHMtaF>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:17:17 -0400 (EDT)
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
Subject: [PATCH v3 11/11] Call cond_reshed() as needed in d_for_each_positive_child().
Date: Wed, 26 Aug 2026 08:06:28 +1000
Message-ID: <20260825221459.966875-12-neilb@ownmail.net>
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

There are reports that large numbers of negative dentries can lead to
soft lockups when walking the d_children/d_sib list, particularly in
fsnotify_set_children_dentry_flags(). (See link below)

This can be addressed by allowing a schedule during the walk in the same
way that scan_positives() (in libfs.c) already does.

As we now walk the list in common code, we can add that schedule call to
all places that walk the list using d_for_each_positive_child iterators.

Doing this involves using an on-stack dentry (about 330 bytes) which is
not standard practice but should be safe since

Commit 3df5153c5f12 ("make cursors NORCU")

made cursors NORCU, confirming that they can safely be released without
waiting.  Also importantly nothing ever takes a reference on a cursor
that it doesn't own.

To facilitate this, a new __d_init() is split out of __d_alloc() and
used in d_init_cursor() which can be called on an on-stack dentry as is
done in the new d_next_sibling_sched().

d_for_each_positive_child*() now use d_next_sibling_sched() if appropriate
and they now assert they might_sleep().

Note that d_walk() also walks this list and does not use the new helper.
Some instances of d_walk() do abort when a resched is needed, others do
not.  This patch does not help with those.

Link https://lwn.net/Articles/1079407/
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/dcache.c            | 107 ++++++++++++++++++++++++++++++++++-------
 include/linux/dcache.h |  23 ++++++---
 2 files changed, 106 insertions(+), 24 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 16b9ea6b0dba..59c936d30dee 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1890,6 +1890,24 @@ void d_invalidate(struct dentry *dentry)
 }
 EXPORT_SYMBOL(d_invalidate);
 
+static void __d_init(struct dentry *dentry, struct super_block *sb)
+{
+	dentry->d_flags = 0;
+	lockref_init(&dentry->d_lockref);
+	seqcount_spinlock_init(&dentry->d_seq, &dentry->d_lock);
+	dentry->d_inode = NULL;
+	dentry->d_parent = dentry;
+	dentry->d_sb = sb;
+	dentry->d_op = sb->__s_d_op;
+	dentry->d_flags = sb->s_d_flags;
+	dentry->d_fsdata = NULL;
+	INIT_HLIST_BL_NODE(&dentry->d_hash);
+	INIT_LIST_HEAD(&dentry->d_lru);
+	INIT_HLIST_HEAD(&dentry->d_children);
+	dentry->waiters = NULL;
+	INIT_HLIST_NODE(&dentry->d_sib);
+}
+
 /**
  * __d_alloc - allocate a dcache entry
  * @sb: filesystem it will belong to
@@ -1899,7 +1917,6 @@ EXPORT_SYMBOL(d_invalidate);
  * available. On a success the dentry is returned. The name passed in is
  * copied and the copy passed in may be reused after this call.
  */
- 
 static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 {
 	struct dentry *dentry;
@@ -1927,14 +1944,14 @@ static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 		p = kmalloc_flex(*p, name, name->len + 1,
 				 GFP_KERNEL_ACCOUNT | __GFP_RECLAIMABLE);
 		if (!p) {
-			kmem_cache_free(dentry_cache, dentry); 
+			kmem_cache_free(dentry_cache, dentry);
 			return NULL;
 		}
 		atomic_set(&p->count, 1);
 		dname = p->name;
 	} else  {
 		dname = dentry->d_shortname.string;
-	}	
+	}
 
 	dentry->__d_name.len = name->len;
 	dentry->__d_name.hash = name->hash;
@@ -1944,20 +1961,7 @@ static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	/* Make sure we always see the terminating NUL character */
 	smp_store_release(&dentry->__d_name.name, dname); /* ^^^ */
 
-	dentry->d_flags = 0;
-	lockref_init(&dentry->d_lockref);
-	seqcount_spinlock_init(&dentry->d_seq, &dentry->d_lock);
-	dentry->d_inode = NULL;
-	dentry->d_parent = dentry;
-	dentry->d_sb = sb;
-	dentry->d_op = sb->__s_d_op;
-	dentry->d_flags = sb->s_d_flags;
-	dentry->d_fsdata = NULL;
-	INIT_HLIST_BL_NODE(&dentry->d_hash);
-	INIT_LIST_HEAD(&dentry->d_lru);
-	INIT_HLIST_HEAD(&dentry->d_children);
-	dentry->waiters = NULL;
-	INIT_HLIST_NODE(&dentry->d_sib);
+	__d_init(dentry, sb);
 
 	if (dentry->d_op && dentry->d_op->d_init) {
 		err = dentry->d_op->d_init(dentry);
@@ -1974,6 +1978,75 @@ static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	return dentry;
 }
 
+/**
+ * d_init_cursor - initialise an on-stack dentry cursor
+ * @dentry: the dentry to be initialised
+ * @parent: dentry of parent where cursor will be used.
+ *
+ * A DCACHE_DENTRY_CURSOR is initalised for use in marking
+ * a place in the d_children/d_sib list.  While sb-related
+ * fields are filled in, they should never be used.
+ * The filesystems d_init is not called and a final d_put()
+ * should not be called, else d_release would be called.
+ */
+static void d_init_cursor(struct dentry *dentry, struct dentry *parent)
+{
+	const struct qstr *name = &slash_name;
+	char *dname;
+
+	/*
+	 * We guarantee that the inline name is always NUL-terminated.
+	 * This way the memcpy() done by the name switching in rename
+	 * will still always have a NUL at the end, even if we might
+	 * be overwriting an internal NUL character
+	 */
+	dentry->d_shortname.string[DNAME_INLINE_LEN-1] = 0;
+	name = &slash_name;
+	dname = dentry->d_shortname.string;
+
+	dentry->__d_name.len = name->len;
+	dentry->__d_name.hash = name->hash;
+	memcpy(dname, name->name, name->len);
+	dname[name->len] = 0;
+
+	/* Make sure we always see the terminating NUL character */
+	smp_store_release(&dentry->__d_name.name, dname); /* ^^^ */
+
+	__d_init(dentry, parent->d_sb);
+	dentry->d_parent = parent;
+	dentry->d_flags |= DCACHE_DENTRY_CURSOR | DCACHE_NORCU;
+}
+
+/**
+ * d_next_sibling_sched - return next sibling, but schedule() first
+ * @child:  current child
+ *
+ * This behaves like d_next_sibling(), but drops the parent d_lock
+ * and calls cond_resched() to avoid any soft-lockup.  A cursor
+ * is inserted as place holder.
+ *
+ * Caller must hold the parents d_lock, and must hold a counted
+ * reference on the parent.
+ *
+ * Returns: the next sibling, or NULL if there is none.
+ */
+struct dentry *d_next_sibling_sched(struct dentry *child)
+__must_hold(&child->d_parent->d_lock)
+{
+	struct dentry cursor;
+
+	d_init_cursor(&cursor, child->d_parent);
+	hlist_add_behind(&cursor.d_sib, &child->d_sib);
+	spin_unlock(&cursor.d_parent->d_lock);
+	cond_resched();
+	spin_lock(&cursor.d_parent->d_lock);
+	child = d_next_sibling(&cursor);
+	d_detach_cursor(&cursor);
+	WARN_ON(d_count(&cursor) != 1);
+	return child;
+}
+EXPORT_SYMBOL(d_next_sibling_sched);
+
 /**
  * d_alloc - allocate a dcache entry
  * @parent: parent of entry to allocate
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 010d9d47ac01..2923a8ab16f5 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -656,10 +656,15 @@ static inline struct dentry *d_next_sibling(const struct dentry *dentry)
 	return hlist_entry_safe(dentry->d_sib.next, struct dentry, d_sib);
 }
 
+struct dentry *d_next_sibling_sched(struct dentry *child);
+
 static inline struct dentry *d_next_positive(struct dentry *child)
 {
 	do {
-		child = d_next_sibling(child);
+		if (need_resched())
+			child = d_next_sibling_sched(child);
+		else
+			child = d_next_sibling(child);
 	} while (child && !d_really_is_positive(child));
 	return child;
 }
@@ -691,9 +696,11 @@ static inline struct dentry *d_first_positive(const struct dentry *parent,
  * which have at some point in the past been positive.
  */
 #define d_for_each_positive_child(child, parent)			\
-	scoped_guard(spinlock, &parent->d_lock)				\
-		for (child = d_first_positive(parent, NULL); child;	\
-		     child = d_next_positive(child))
+	if (({might_sleep();0;})) ; else				\
+		scoped_guard(spinlock, &parent->d_lock)			\
+			for (child = d_first_positive(parent, NULL);	\
+			     child;					\
+			     child = d_next_positive(child))
 
 /**
  * d_for_each_positive_child_continue - iterate over remaining positive children
@@ -710,9 +717,11 @@ static inline struct dentry *d_first_positive(const struct dentry *parent,
  *
  */
 #define d_for_each_positive_child_continue(child, parent)		\
-	scoped_guard(spinlock, &parent->d_lock)				\
-		for (child = d_first_positive(parent, child); child;	\
-		     child = d_next_positive(child))
+	if (({might_sleep();0;})) ; else				\
+		scoped_guard(spinlock, &parent->d_lock)			\
+			for (child = d_first_positive(parent, child);	\
+			     child;					\
+			     child = d_next_positive(child))
 
 void set_default_d_op(struct super_block *, const struct dentry_operations *);
 struct dentry *d_make_persistent(struct dentry *, struct inode *);
-- 
2.50.0.107.gf914562f5916.dirty

