Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54C992AD3C;
	Sat, 15 Aug 2026 04:30:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768226; cv=none; b=Pn5/QejCvTfZLzaCi6O6SaDUypeipmJNhTyxFXyG+3HTLe8tnuC9eRPGc7MQDul21Gk2rJdVwa3ORh5fF8dBCQI92BOKbZbW5A6rIGHpT2jnW/mi4dBOxWNy5u6TaEVh4zUGYKhIL+K/V77j0EoCMeIVLt9o2mI8WFoNGIl+16Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768226; c=relaxed/simple;
	bh=WM32gv8y32TBXdzBdBZEPnqOA6Hn/lbJ/5x8jb4D33Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GYELmT3ovW13E5H82rxYLnPhYrpl6hpzgxNorwSG191F2CchINPovwAGjVDpeRj/DiGDjBN42nVJG4sx8+P0P+i6o8jssJ66cVYCyPruYUw9cgccfSucN3j2QT4BD3/iCQQAxIXHwPAKLhTMPa2Rsuo79jKZepcD8fGJAx5KN6g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=SAte4HO+; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=ZhLfHdoJ; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="SAte4HO+";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ZhLfHdoJ"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailflow.phl.internal (Postfix) with ESMTP id 6F96E13803F8;
	Sat, 15 Aug 2026 00:30:24 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-08.internal (MEProxy); Sat, 15 Aug 2026 00:30:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768224;
	 x=1786775424; bh=UsX1H1FvrdcE03UajthEohSKFBjuFpKXnOBS2Iq2Qx8=; b=
	SAte4HO+ap8+GvmLs+BoqP34dNJR38N0emrWUcufy9bclUadCfytvCnK3JHDiVFU
	6n/7Gv1AJH2hZoM04yL3jzlW4FtFvLrmj8xcdyxy8mZSPFhl1i44S0/ym9qiYRUK
	1IVJPga3bSAovz/oLzPtJV6B9/vmr3UHUyd7kx+nHqtHNSchNW2LO8TRypncQYyP
	kUWdY4KPscSYrIeVMdp8HnvAe/gXf0ePJIh7PEX+4imcnZKtQR9u37vSoEI/GyoJ
	NN+jn1slBcyTcwXv3MIdEWELiqKQ5UlreqXRnFib3e6frulhhub5duw3EYFA9l1N
	0eizl+OcABEBtlvhp+vlPw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768224; x=1786775424; bh=U
	sX1H1FvrdcE03UajthEohSKFBjuFpKXnOBS2Iq2Qx8=; b=ZhLfHdoJvwmU0CoyO
	C7auQVfeWpwkOLloajLvUKQ0nPh14HfK+SJxkpC4V53UIm/BoxtTnJ95ubbWCHOM
	Lgb+MNUrGASivMD9S/tw4p0Wy06Q5AllOKVBRPL6K5phsqG6bnWoOpUcfzDK7EiF
	Wld69BbVUJ5r+mbCqe0ecR5wb9IgZBJ/x6TqoWO3wiGXzas9eXY8KFwIgeKrhDB2
	D/wguBXqgCZ9X9aGGxiL5SsNDGHgn94pYTemmJTO4Q3KE9yNDcC0eHRt9dizIXKc
	IjP4zBHcZ9vZKGBttuBbfS39r9DaOztWDkWnnN4HGCox6vjTU+IHWqJf3JlFIQcw
	6YX3g==
X-ME-Sender: <xms:YOt_ar4druAyiNvs-J_7kveOlBbTTwHQk9S6Ac1ag04JrLlaAHk6NA>
    <xme:YOt_ar5u37nW6Ajo5KwZN4kSwd0ClGlytMqZQ8tNJPuWa319ucYw4aVkfyr2ktBze
    NuqZFB-i750Ry6F4HmSTt7_6hZqBDEC2rl6MxD0MJBOdmb2Pw>
X-ME-Received: <xmr:YOt_apEtkYvLSUCWumJ2rcHQWozP6g8jK2Bied35Zm5H6uxKV-CfW0vGyx-6cVqiv6E72S5HkgxE2RnG3nPTsXOs19gc5cE>
X-ME-Proxy-Cause: dmFkZTF35pNQvdHifAS72EypUM+sj4MgVnoYznd+MkmT2mxm0S5KeaXRXN1BftM9su3AO2
    L0DE1tpks9ipdnLwrMjtaxoW7Jm3CmxFNWqRz+iT2MzRHv1XvZNIWQAV/Tixn7l805cF3+
    Q8b4gpZ5fobrYKJtdmv/+GQNQ9iuDB5NCQuckvHoxAEPiLjJJdcp2eJd2z7c0HfFptq2lb
    TJFjgDc6cWPJb4ntMivJOZ1sXgZqLUzD/YRGyB79ZazUQXiMjVzdOUJLoaebwTyoZBJmy6
    kBdOAkJxOpHMtG6MuKXXU/Ve6NDZzrFEVaMt3ut4hZmQYS3N5+VbGkJdqLENAwza7VOuQe
    demolYo+8A0so4cOwtrWaAo7fXw1wNikGUTxUYNiXy4CWZfGtcPzoZ4o+nrlm/zUrkPA86
    kwPNHd4RnNl4s4835oMvh1Yd7kCWEH7LtEHpjUnEUfqtt9rfJDp6V2CvxSQWf7iPprDFLV
    V9Px96Y9DE85R1/wmFWU1xjXLn7KHWVUFALObH4W7uYhkY5iHNQr/pnelV9MP+AFNYid13
    zUYK0TqlagvmZK40ww/dN4vJ0HK0du0TIkxxp6fJjP+4kSk6GNYERDbqM69KB5B7ADYJZF
    xSVNIBI8ped5ihSLOPQUWLzc5pc06mo/9dZOgIIIBdqapImCjZ1utb0RufGA
X-ME-Proxy: <xmx:YOt_apy-tZpWDgs3FE1mE94-UvvOffKfCiKSHoUmQChi--ZIQEb95w>
    <xmx:YOt_ap12Y3gc4MqU32y9yGnWmIeJ7srECjWu92A32wl-nU0R-zpDgQ>
    <xmx:YOt_asO9SHbRZe6kOWIzb1WtZPzNpWuPlRQ9X8G6tPXDDHKrfeiUEQ>
    <xmx:YOt_altKhOkVSk5PKGaNxWRGVGxGINeL2w69JvfLRI8LhhGN_35cIQ>
    <xmx:YOt_arJu26pW_2-4n0Di8sdmRztS3utGdYNycf1znc6EqTFYUB8JRjTu>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:30:18 -0400 (EDT)
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
Subject: [PATCH v2 14/18] Call cond_reshed() as needed in d_for_each_positive_child().
Date: Sat, 15 Aug 2026 14:21:31 +1000
Message-ID: <20260815042707.2535717-15-neilb@ownmail.net>
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
index 50fbbcceca01..38a726472d4a 100644
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
@@ -1969,6 +1973,75 @@ static struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
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

