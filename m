Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B2822571A0;
	Mon,  3 Aug 2026 01:39:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721147; cv=none; b=rWi9uoja/W953YMWC+aCXwpQltLViLYVQtmauzZYKZFXiBkrne3mr0tZvdm/hDsDnbQ/MTtXznPQViYbW2k1WMTzfNwWNT8KHvJrh/fpFdrJfAeCWtk5/BHUFFvRyKoAhLPK8fJdirnvbe8fooToR6k7NlJg8M6P2AKH9T6dq4E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721147; c=relaxed/simple;
	bh=80x5dRqEVgRZsTTLHRvw75oA1m3g+7bZHj0ZG8oOnKA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fqYS1HvkRDtPWg6iruxnzizyVoy1q/+cS88dNlA1FrYUSQycaOhC5qmcT6KBQUE7RbEht5dYiGuCrdzR5SBZ/P5h5boyO4PXddnEBqRdondI0iBl5sQjSmYmr0ULUR8vRHINTDHpRPeIaYnjC9PV1aInomGmSMfBchQbwkurVS8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=A6Rmhhhf; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Eh76sA7a; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="A6Rmhhhf";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Eh76sA7a"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailflow.stl.internal (Postfix) with ESMTP id 40A731300120;
	Sun,  2 Aug 2026 21:39:04 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-09.internal (MEProxy); Sun, 02 Aug 2026 21:39:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721144;
	 x=1785728344; bh=S3v8RX+VmBHxPtS8fSNJM421/tOiLSUqqUod+SOCtME=; b=
	A6Rmhhhf0nO1XtDsEoDaMtKjAPwdXKOI1sEE9w5rnodRZEclpfCO5IE8XnTg35H2
	rTj0Qfr1zNC2zHS36usP+Dx/09CwAkYseKjSAPxQPOLWzqqLc8P3Ejz1xgLD/qRR
	rlUFzINLzBRSW7g9/VSqBNOxcN8TDn2aTtdngBRnExovkGFJrD/ENcAky4eLC9bT
	vh9P0+lF8YIGloSysx513T/rbLrB91oY1NsclNKwvSzUHS4BhWCNoNE9Qfd0jWJj
	oW08QozXbipYVX0t0D6H+lnQ68kjinSQsVPCT3beL5/iP1el1sy5CFAvCuptLZ5C
	UZ3F9eRQzah03h46i5vQ9A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721144; x=1785728344; bh=S
	3v8RX+VmBHxPtS8fSNJM421/tOiLSUqqUod+SOCtME=; b=Eh76sA7axP5FH1G6I
	MTzLs4OF0dDWwZejFEwU4Er5K5gTyCjewiJUMLyrKNB8WZwmJyCc3nEqCNKPmw3S
	QreJx9No+JUEcfxqXPdZdqbnL71fpwSPCF3moc9KpY443NraOHbhLfYG2PH6/fk6
	1TtBEvnEQnxOtiGPfNWmeFYIbCaZdg9ci0bs7ZfKpujDZYLx/hb1b+3Ttd8411gz
	lT2JNNFOqNehlmvLE3j/THHgo3MY3Ak2EFKaUmNPlLOjhp4GZIrEtFPh9JJsKPbT
	XH/eBhZIg1etNggSP553UdAt9t/6LtT8JpP5DL759iNG0vnn2Y4D59edWHlwV3h7
	Xvq3g==
X-ME-Sender: <xms:N_Fvas6mKsDf2KvNGZ0gR2S7UIeE8s1VMlpir7kW4JbNDt32u4duNQ>
    <xme:N_Fvao4qyv87B2U1mQ9w7m-AaK-hVYiZ9O5BQaxX4HgYasAIq7RhN5m26m0-G71_K
    nabdCyQsKDfuyNZl_3pRXZgTFn2wrwxN-Nw4p_Vr6E0_TlcOg>
X-ME-Received: <xmr:N_FvaiEFALnHc9HyBPsRgPUGc4qjIUbSMAwvxMX9blUpObhNL7asp3FtBAR7GtxPZQVUwpbYBQ9qjY_RMYB0qq1gELdBVNg>
X-ME-Proxy-Cause: dmFkZTFA/0zm7OzeplXRNvaNNmULnG0bsSwLfs+E1fp/q4OBdNvpsKhweFt4elT9lXHd+G
    hTM4MVvIxFfT4f1Y7HBQ1gMr4yL539AvDYksd/SsisrtMNq+EqTkOTQTuzQd8lMMFdAmse
    D1YJ0L60HAoZcUzOgHo9DuzP/4Ow8ItiPyTEjn1bK4Jn1nUlo/POLPXyt3mK9JNNNPqU7Y
    mubipfwUkLYy5ewC3+/+p9hwcyapoHG+ZZ5DTw872VYmOR7ZRvjLOxdnM0/DOmk3uvO26k
    9qw+ssl1tYKsL3hrlaerGXMHiVZx0h5rxUc2yzrUGeaNiWDuoRhf7M39GqD2tmd17RvPGA
    Nr/VxsXZBplXEAzBChxm88250A1v7ImXXn9vSt/kjZ/fLZMvNZFxcO7wit8ESUGvRJbroT
    dco1dZxYhxEva7KW0Mh7TTDpH7gTLCJQV4jppJl/pYrCEI3+FaPMpeVLdDUxRfCeHNFDrC
    vt+Xuwj7p2ZtAvCIZ/h3nKpW6Eagc0h45M1fqYM5z3bWcoRliflVWoWDDtQuKbTnftf4N4
    AK3R4b+vDLPWp59zNLSVq8UprwFtD1cQwyO7/noMDm+ZaF2YZsTxomZcIu2KT+XpTfFPtR
    zsxUZa0fgLNil6LtdGWmrCIJaUpCJ1+wJpydsM7+UIWiCnHO3qPtzb6ssi5w
X-ME-Proxy: <xmx:N_FvauzmUiEeqXbpwZpU5hFiljVUQkgo4yWZVfdyZNcxeqkgU4ckMw>
    <xmx:OPFvaq2ARYW_NDL1euuhBl1_4h6efRRvOdVM3byt56kso8Gnw-ATBw>
    <xmx:OPFvapNmUS4qFlYhZP2QGTFZPrdUwkt31HZVl79fi6BOTMbwOTeJQw>
    <xmx:OPFvausKnww1IWu6dBqS960lDKTRTTmddEcGrLng3Eix_SyeWVDl9Q>
    <xmx:OPFvakLgv9klWiox17V9SaLwbRF5eXHzFlbbqhRr1eOMHdYfHlNHuZ2A>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:38:56 -0400 (EDT)
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
Subject: [PATCH v1 11/12] Call cond_reshed() as needed in d_for_each_positive_child().
Date: Mon,  3 Aug 2026 11:21:20 +1000
Message-ID: <20260803012648.2195405-12-neilb@ownmail.net>
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
and they now assert they might_sleep()).

Note that d_walk() also walks this list and does not use the new helper.
Some instances of d_walk() do abort when a resched is needed, others do
not.  This patch does not help with those.

Link https://lwn.net/Articles/1079407/
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/dcache.c            | 109 ++++++++++++++++++++++++++++++++++-------
 include/linux/dcache.h |  23 ++++++---
 2 files changed, 108 insertions(+), 24 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 50fbbcceca01..3678f86fe693 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1885,6 +1885,24 @@ void d_invalidate(struct dentry *dentry)
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
@@ -1894,7 +1912,6 @@ EXPORT_SYMBOL(d_invalidate);
  * available. On a success the dentry is returned. The name passed in is
  * copied and the copy passed in may be reused after this call.
  */
- 
 static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 {
 	struct dentry *dentry;
@@ -1922,14 +1939,14 @@ static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
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
@@ -1939,20 +1956,7 @@ static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
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
@@ -1969,6 +1973,77 @@ static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
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
+	__hlist_del(&cursor.d_sib);
+	if (hlist_empty(&cursor.d_parent->d_children))
+		dput_dlock(cursor.d_parent);
+	WARN_ON(d_count(&cursor) != 1);
+	return child;
+}
+EXPORT_SYMBOL(d_next_sibling_sched);
+
 /**
  * d_alloc - allocate a dcache entry
  * @parent: parent of entry to allocate
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index cabf05e74b1f..f7d5954c58da 100644
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

