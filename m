Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26E381531C8;
	Tue, 25 Aug 2026 22:15:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696153; cv=none; b=R6NyGFwPvsqRGJ1Xu0N5fwVFHwb4ikmdNEgMp9YKxdf1k2tD0TTC/nVS8awv8P4dCMCfuEJAZJLUZaL9ba6VC2ON+TtsDjNFEC3qM6TJw/udpQ5Obgk2tD0HpQWrSigGGx0viv3Xb8jRojCmCoARAqoL0dMQJZlA6nvO6QXMgMw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696153; c=relaxed/simple;
	bh=UCAAok+BZYu6YTH3Wj/Brqpfukp54ANy80JXJV2mDhI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DDeWqplLrhKDvI6fXPCY34qk4OLH2IjT1KpZvv4zhkYEEdqksYAwJvIyh1QXIAsRQKGX01o/PbqfB5K4T2xU68nQKxUQZZNPYXaDm0rbGDxne5j2KVhC8/hyBPmZskpfTXMqrKz0a8U6tOXi/bMFVT3qJldA2iP/hbenOI1brc4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=k0bGwqEp; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eD8wFb41; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="k0bGwqEp";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eD8wFb41"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.stl.internal (Postfix) with ESMTP id E5289130017A;
	Tue, 25 Aug 2026 18:15:50 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Tue, 25 Aug 2026 18:15:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696150;
	 x=1787703350; bh=QuYNRtqRuLgD/wM/mc74+AFvPzaBrC7/+rJ+XyEW874=; b=
	k0bGwqEpMDqSR+rBvaXuUqnr29LP/l8X/TkvNqeFG/KL3Vulwnz3IY67alvtPtLf
	XaqWNV/34pXY/hpoZmKVIsyPgl/1H3kh1fRSvznEV/3G8kkeN0PRAXOpOkyUN4by
	K5bBbF25+F/cwjARaNlb8zDe4HhGKU0m0gWUwVTU82CK3v3aRUAbi7xXMTTIcnGm
	6WBfgLARSX0fm8qPbdnzHVb9OdWt32AQywrcfA1Pr0bb1XtXdgpoXD6R9EpS/xXV
	v2w+HbAdlishlfa+hBhVtAjipF2BzswnyB5Vg8XmnApsCbqt+3iGGiwHfCAAJzqy
	F2/9piT6Mzje8P5pztYRSg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696150; x=1787703350; bh=Q
	uYNRtqRuLgD/wM/mc74+AFvPzaBrC7/+rJ+XyEW874=; b=eD8wFb41DN38Y+0vM
	BFW2D07E9U4O2TMf121UZ4yj59BYT4Mjk/KtP6IA/JBTuXphLMrl6swgnH6Gotf8
	xtoMqg9VS6ZZh4HIGa+SIFbcsivZIvMDQmrpH7yZ+8OLoKWazmTmEOKRMnbx/v9a
	4lUY5gFlll725XURahz3XOvKfNjQco2PRotNYPNwlH6AS4SOAiOzIOT68YvbL17C
	bxPP1NwbKIVUZxqaO6/z/9iuxT9OVd7YsRh292H2B7x3ZO2HBH8aCs1pHjVfyu4+
	NWzhQuawNbmoT47fr488ubQ1hZH6kVjQ9opi1YFqFc01BYEqrnaQSBclYnRGqs5b
	+ssGw==
X-ME-Sender: <xms:FhSOahhGfCdfSizP4OfPcI9ACaBkeTw957BhDYuc2s2zSL4sirbk7w>
    <xme:FhSOauO6y7PVfJVzc1n6MFqIxqwTEcGtMsTBkA7vwJxuPX6Dg_Ark1UGkV2DaHvhO
    XCdTCEWPNF301FVtTEivqA-ieS0mLIJ_pX7Hf_s0jJfxPF->
X-ME-Received: <xmr:FhSOaoaWM7qm8cm3hQgbmglOEH3jB3jUSeRuEVpqW90_y_MQEGeLYp8WW5DWL3oM1UpBkhs9ZIfmCyMLS_oqlOSCH_nCWKc>
X-ME-Proxy-Cause: dmFkZTEp9gD1tNJOvQDhtypWMDariy1lQZzyPCbTbVWnxI6bdpy2XSc1MIE8cjy3IG5prk
    7eXXKQ1+AzawqwVafFnkSQVq3nCftIMNELyf+GmUuKYTB18VwsCSA8x1h9bnf7yYLuIe9s
    5/khboCUq8wQeamlgoG70tpcU6O9vPbdw1ApHAaCVlIPXTbjfAhkfSz569KefjxusIkwqg
    JSlqRrJD0X07dcItAiTmSeecqH/sccyG90oRqGAhsyPnna+gbbNa6u+OTNC0+oiLPN9Hl5
    FMsl0L+8C6nVE/5D5EiMbFYLm13buMsfddxLmGjqhI2v2n1p1xvAzA+rwFt4OQHM6ek8TS
    LROdH5ITYNym7DYMThd5ytddkEUPE9ow9ATan8jyC06t0IkTL6qRs/GiOFfb7o83PkWAjX
    bhfUQdDUbo0EGqxsJRY5q3MQLNHgFGIZLlxMYjj8siCmdFvzz1cfxA3WaIQHH4+jGxSAbT
    x8/b00HZNGyJmRG6+Cx8xJ8JttmdjGZdswazMrgv/AclpQnXMyRH5es9dsirbIHgLlIMAL
    bzkwIRRdvBfZGoMTZcTmhdckZw2qn20/ltdDd2eemBtgCUiq5HMSok/pH8p7rplYOWnUYm
    s3jeBfBd1S596LVwOoxa1VNzy76436DycfwNnCnzX0bl/bVm43pfskPlJG5g
X-ME-Proxy: <xmx:FhSOaj-hrOgu6Avl-9caTp10w-Vq1haQpsFCktfB43ogVMwqPQ-SSg>
    <xmx:FhSOar1wFcuaDfmxUs8hKk2QKIgK1U4SMDWs6DbFPhfOKLfLlhEthg>
    <xmx:FhSOas0a8bfdern8Tr00mJw7c__Tw9FOzKKDlbZIUhL1YDP-hlN4Sw>
    <xmx:FhSOaowyFf7syXlW7DC40r3UV23C-vJfMhNqfwL6D82whIE79ImCCA>
    <xmx:FhSOakRrY2FwnITUbjQkhVMalJeufr4SmwAhC3onZKfOyVaQ6bzdPMmO>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:15:44 -0400 (EDT)
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
Subject: [PATCH v3 01/11] VFS: don't count references through ->d_parent
Date: Wed, 26 Aug 2026 08:06:18 +1000
Message-ID: <20260825221459.966875-2-neilb@ownmail.net>
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

The number of negative child dentries that a given dentry can have is
effectively unbounded, so counting the references through ->d_parent can
overflow ->d_lockref.count.

We only use this count so that we can know when there are no remaining
references including from children.  However most children appear on the
->d_children list and the few remaining children (inactive
DCACHE_DENTRY_CURSORs) only exist in a context were a separate reference
is held on the parent.

So if we count whether d_children is nonempty (i.e.  dget() when it
becomes non-empty, dput() when it comes empty) and require children not
on ->d_children to have a reference on the parent some other way (which
they already do), then ->d_lockref.count will not overflow and we can
still know exactly when all references, including through ->d_parent,
are gone.

__d_move() allows that dentries might not be on any d_children list as
is the case for IS_ROOT() dentries.  Rather than track when this is the
case we dget() either parent if they have an empty d_children before
children are moved around, then dput() if they turn out to be empty
afterwards.  This will increment dentry if it IS_ROOT(), and then
decrement it afterwards, and will decrement the refcount on old_parent
if its ->d_children becomes empty.

To help with this, dput_dlock() is added which warns rather than
decrementing to zero (which should never happen).

When a DCACHE_CURSOR dentry is added to d_children, it is only ever
added "before" or "behind" an existing child, so it will never be the
first and so never needs to adjust the refcount on the parent.  If it
remains on the list until dput() it could be the last child to be
removed, in which case normal handling applies in dentry_unlist() (where
it has been moved from dentry_kill().  When a cursor is deliberately
removed from the d_children list the refcount must be decremented if that
leaves the list empty.

hlist_move_behind() and hlist_move_before() are added to simplify moving
a cursor within the d_children list.  This result in some duplicate code
as they share a common prefix with d_detach_cursor() (hlist_del)
which is currently factored out.  We can expect the compiler to optimise
this away and don't need to clutter the C code with it.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/dcache.c            | 40 +++++++++++++++++++++++++++++++++-------
 fs/internal.h          | 10 ++++++++++
 fs/libfs.c             | 14 +++++++-------
 include/linux/dcache.h | 17 ++++++++++++++++-
 include/linux/list.h   | 30 ++++++++++++++++++++++++++++++
 5 files changed, 96 insertions(+), 15 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 1b1a81f10da6..241a686f7c5f 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -670,6 +670,8 @@ static inline void dentry_unlist(struct dentry *dentry)
 		return;
 	}
 	__hlist_del(&dentry->d_sib);
+	if (hlist_empty(&dentry->d_parent->d_children))
+		dentry->d_parent->d_lockref.count--;
 	/*
 	 * Cursors can move around the list of children.  While we'd been
 	 * a normal list member, it didn't matter - ->d_sib.next would've
@@ -843,7 +845,7 @@ static struct dentry *dentry_kill(struct dentry *dentry)
 	spin_unlock(&dentry->d_lock);
 	if (likely(can_free))
 		dentry_free(dentry);
-	if (parent && --parent->d_lockref.count) {
+	if (parent && parent->d_lockref.count) {
 		spin_unlock(&parent->d_lock);
 		return NULL;
 	}
@@ -1991,7 +1993,9 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 	 * don't need child lock because it is not subject
 	 * to concurrency here
 	 */
-	dentry->d_parent = dget_dlock(parent);
+	dentry->d_parent = parent;
+	if (hlist_empty(&parent->d_children))
+		dget_dlock(parent);
 	hlist_add_head(&dentry->d_sib, &parent->d_children);
 	spin_unlock(&parent->d_lock);
 
@@ -2010,7 +2014,7 @@ struct dentry *d_alloc_cursor(struct dentry * parent)
 	struct dentry *dentry = d_alloc_anon(parent->d_sb);
 	if (dentry) {
 		dentry->d_flags |= DCACHE_DENTRY_CURSOR | DCACHE_NORCU;
-		dentry->d_parent = dget(parent);
+		dentry->d_parent = parent;
 	}
 	return dentry;
 }
@@ -2772,7 +2776,9 @@ struct dentry *d_alloc_parallel(struct dentry *parent,
 
 	new->d_flags |= DCACHE_PAR_LOOKUP;
 	spin_lock(&parent->d_lock);
-	new->d_parent = dget_dlock(parent);
+	new->d_parent = parent;
+	if (hlist_empty(&parent->d_children))
+		dget_dlock(parent);
 	hlist_add_head(&new->d_sib, &parent->d_children);
 	if (parent->d_flags & DCACHE_DISCONNECTED)
 		new->d_flags |= DCACHE_DISCONNECTED;
@@ -3100,12 +3106,21 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
 
 	/* ... and switch them in the tree */
 	dentry->d_parent = target->d_parent;
+
+	/*
+	 * Ensure ref count on parents reflect d_children being non-empty,
+	 * which they almost certainly are.  If either end up being empty,
+	 * this is handled below after the moves.
+	 */
+	if (hlist_empty(&old_parent->d_children))
+		dget_dlock(old_parent);
+	if (dentry->d_parent != old_parent &&
+	    hlist_empty(&dentry->d_parent->d_children))
+		dget_dlock(dentry->d_parent);
+
 	if (!exchange) {
 		copy_name(dentry, target);
 		target->d_hash.pprev = NULL;
-		dentry->d_parent->d_lockref.count++;
-		if (dentry != old_parent) /* wasn't IS_ROOT */
-			WARN_ON(!--old_parent->d_lockref.count);
 	} else {
 		target->d_parent = old_parent;
 		swap_names(dentry, target);
@@ -3118,6 +3133,17 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
 	if (!hlist_unhashed(&dentry->d_sib))
 		__hlist_del(&dentry->d_sib);
 	hlist_add_head(&dentry->d_sib, &dentry->d_parent->d_children);
+
+	/*
+	 * Adjust parent refcounts if either d_children ended up empty.
+	 * This should only ever be old_parent.
+	 */
+	if (hlist_empty(&old_parent->d_children))
+		dput_dlock(old_parent);
+	if (dentry->d_parent != old_parent &&
+	    hlist_empty(&dentry->d_parent->d_children))
+		dput_dlock(dentry->d_parent);
+
 	__d_rehash(dentry);
 	fsnotify_update_flags(dentry);
 	fscrypt_handle_d_move(dentry);
diff --git a/fs/internal.h b/fs/internal.h
index c658c8a5ebd5..59b2b8030b6c 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -235,6 +235,16 @@ extern struct dentry *__d_lookup(const struct dentry *, const struct qstr *);
 extern struct dentry *__d_lookup_rcu(const struct dentry *parent,
 				const struct qstr *name, unsigned *seq);
 
+static inline void d_detach_cursor(struct dentry *cursor)
+{
+	if (hlist_unhashed(&cursor->d_sib))
+		return;
+	hlist_del_init(&cursor->d_sib);
+	if (hlist_empty(&cursor->d_parent->d_children))
+		/* That was the last child, must drop implied reference */
+		dput_dlock(cursor->d_parent);
+}
+
 /*
  * pipe.c
  */
diff --git a/fs/libfs.c b/fs/libfs.c
index 27d7dc16fcb0..60586fe65895 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -128,9 +128,7 @@ static struct dentry *scan_positives(struct dentry *cursor,
 			count = 1;
 		}
 		if (need_resched()) {
-			if (!hlist_unhashed(&cursor->d_sib))
-				__hlist_del(&cursor->d_sib);
-			hlist_add_behind(&cursor->d_sib, &d->d_sib);
+			hlist_move_behind(&cursor->d_sib, &d->d_sib);
 			p = &cursor->d_sib.next;
 			spin_unlock(&dentry->d_lock);
 			cond_resched();
@@ -166,9 +164,10 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 			to = scan_positives(cursor, &dentry->d_children.first,
 					    offset - 2, NULL);
 		spin_lock(&dentry->d_lock);
-		hlist_del_init(&cursor->d_sib);
 		if (to)
-			hlist_add_behind(&cursor->d_sib, &to->d_sib);
+			hlist_move_behind(&cursor->d_sib, &to->d_sib);
+		else
+			d_detach_cursor(cursor);
 		spin_unlock(&dentry->d_lock);
 		dput(to);
 
@@ -210,9 +209,10 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
 		p = &next->d_sib.next;
 	}
 	spin_lock(&dentry->d_lock);
-	hlist_del_init(&cursor->d_sib);
 	if (next)
-		hlist_add_before(&cursor->d_sib, &next->d_sib);
+		hlist_move_before(&cursor->d_sib, &next->d_sib);
+	else
+		d_detach_cursor(cursor);
 	spin_unlock(&dentry->d_lock);
 	dput(next);
 
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 4b1ff99608e0..3b595adff7b4 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -324,7 +324,7 @@ extern char *dentry_path(const struct dentry *, char *, int);
 /* Allocation counts.. */
 
 /**
- * dget_dlock -	get a reference to a dentry
+ * dget_dlock -	get a reference to a dentry while locked
  * @dentry: dentry to get a reference to
  *
  * Given a live dentry, increment the reference count and return the dentry.
@@ -339,6 +339,21 @@ static inline struct dentry *dget_dlock(struct dentry *dentry)
 	return dentry;
 }
 
+/**
+ * dput_dlock -	put a reference to a dentry while locked
+ * @dentry: dentry to get a reference to
+ *
+ * Given a live dentry, decrement the reference count and return the dentry.
+ * Caller must hold @dentry->d_lock.  The dentry must still have
+ * a reference after the decrement.  This can be used when two
+ * references are held and one must be dropped.
+ */
+static inline struct dentry *dput_dlock(struct dentry *dentry)
+{
+	if (!WARN_ON(dentry->d_lockref.count <= 1))
+		dentry->d_lockref.count--;
+	return dentry;
+}
 
 /**
  * dget - get a reference to a dentry
diff --git a/include/linux/list.h b/include/linux/list.h
index 77fb62f79928..a94eec20275f 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -1123,6 +1123,36 @@ static inline void hlist_add_behind(struct hlist_node *n,
 		WRITE_ONCE(n->next->pprev, &n->next);
 }
 
+/**
+ * hlist_move_behind - move an hlist node to a new location in list
+ * @n: hlist node to be moved
+ * @prev: hlist node after which @n should be added.
+ *
+ * @n may be on the list or unhashed but must not be @prev.
+ * It is removed if necessary and re-added after @prev.
+ */
+static inline void hlist_move_behind(struct hlist_node *n,
+				     struct hlist_node *prev)
+{
+	hlist_del_init(n);
+	hlist_add_behind(n, prev);
+}
+
+/**
+ * hlist_move_before - move an hlist node to a new location in list
+ * @n: hlist node to be moved
+ * @next: hlist node before which @n should be added.
+ *
+ * @n may be on the list or unhashed but must not be @next.
+ * It is removed if necessary and re-added before @next.
+ */
+static inline void hlist_move_before(struct hlist_node *n,
+				     struct hlist_node *next)
+{
+	hlist_del_init(n);
+	hlist_add_before(n, next);
+}
+
 /**
  * hlist_add_fake - create a fake hlist consisting of a single headless node
  * @n: Node to make a fake list out of

base-commit: 45c13f3f9e3bb15fd89ff2864c6f627a3b4b4229
-- 
2.50.0.107.gf914562f5916.dirty

