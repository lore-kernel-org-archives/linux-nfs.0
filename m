Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 403512D77E6;
	Sat, 15 Aug 2026 04:28:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768103; cv=none; b=MSTNi31Ltw5ZtuUcywHEz6nG8AbwntRDKQdyfuh2tC8msGQLTRBXK/+OriYIZQz0dYuiL5vdang/NdJirSl0gT2omfoE/CjIhYgI0Spjy5pe+FW0FOgxWl5QJ1ggzPyUNZN4j5gmrewKBz1SltLJ9lebNGypdvRCXfEoHVgqS+M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768103; c=relaxed/simple;
	bh=CqMFuZ3pzG+/7E/ejH9BKoyQXHKBIfn5fWqIQ6sInLc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=i59tGy2+DTMqK2+jCEvEbYjzl6RQOz2eVy7gXhDMU6BUxT86cqfdyjZd10kfVU+xsSda9NwqsgNno8RrAg5s1/s+YrFrNQ7I01u+atnRmpvxsZjkzr/iSMr1d5BsHJJbFNNGuYdH7mOIg3PsrS3Kg7A2D24fxZyMuP0ky0Ug5Sg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=WBmtwnu9; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=M7sTg89Q; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="WBmtwnu9";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="M7sTg89Q"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.phl.internal (Postfix) with ESMTP id 6ADD013803F8;
	Sat, 15 Aug 2026 00:28:20 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Sat, 15 Aug 2026 00:28:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768100;
	 x=1786775300; bh=+JhGCUNFMj7JKQCtgUbCKJqkxMSu7hV462ntB5fltj8=; b=
	WBmtwnu9grbU9MYGLvFiQ34CNP/ce343WNKHd0uUKE7K4U/RQaX4eOS5j+u8V0DJ
	0NTjYvwKn91C6/usK6IpifIDingbwTDAoUVkaYuQs4m2R6Q5q802L2m75rZ02h7u
	VXvOJe1mJuYBIuEws0orroi7Ky5MqPGpeuGuM+AEhVk8WSHtbozueAKAZhOenKJg
	gBWpmE7zgpPibOVE5wqKqMOP0aKp/MJqBnFvihBO+nbOnMoSKv2gRWHzLEOLJSzx
	spZJ5ymX9+q7c2onqdm8+C8D0gFQmrJI/CpsoZfKb73zyqP+36Jc9albg+OBZUAG
	nE/baWffKmnIeM8UJqbI6Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768100; x=1786775300; bh=+
	JhGCUNFMj7JKQCtgUbCKJqkxMSu7hV462ntB5fltj8=; b=M7sTg89QucaM4zPH5
	GHCpotQIrWqZxKxSwJ9x5TxwzTtOCq6Blqp3aEWgyDiXMjQI1GXj6mSN4DgkdCm3
	2wi+m4LjlQHeKZIfRshB0DYCPMXEDqJkCWtv8GQIWKog6osIG6hmEkUC9U+aZb1e
	Wr9I2WJSGm7I3vX+TpZEDCkeKzDr4nQ7WpHJtPBrzcJW2guv+dUpOPt8kGvzWWT+
	xfEMBtGFHLZf7yRW0ZR5UP8/6KRgUKop24muIGjf2Q+4kvT0C7E2ASmrtc7mAsy6
	/5YEs6EPbwVqewYC3w2CqNXaKuhcyL0sw5GocVJHzyqpWcOKGpIt0nJKGXufsIU1
	4zJXw==
X-ME-Sender: <xms:4-p_atJVC9VKa5eBzEBPMmQNj1UzAsLEDkUPnIuesETEQhgxGv0usw>
    <xme:4-p_akJHYpA9zYRiZ6HKIqIh-DtHGtPTSb8_0cMN_jyaxCxqN8BBBKvhkTe-XjeU-
    UenCOi9JXwCNmhxokS-mgNXrA9hHfwek8viLOdOPHL-pbaLZw>
X-ME-Received: <xmr:4-p_asX1fYG1z_-Y0YoyZS_WLAtjSiOD9Nay-9C4HEJKnD38EJDxbZLad1EkgA58h7EO4yHq6x-5j8OqQodRANPraiqUnxI>
X-ME-Proxy-Cause: dmFkZTF9KskX6ORZkk2qDbanJAqhpO1c3Xju1rB/XGbwQvOGWemlAS7RTfehH6z/blxuZu
    ndq9JpuBON/sKJpHNFmlA8NZthzZuohefFsXvvzkhDLNc/boPY1CbYwGZ3ejocQdZP5Ev/
    BXLTdsGGIGk/QWYctoHjfRUZGHXRv5et6FUSLml8RkvDkfsb7WSgppX3LyXjWcFTLwfp/k
    XOfgf9r/SZsCIW4bEY4xzTmE8sCd1BMMrUIBiSLPUM5HPZAu9IGndquxD0N2k1kJS4EkJO
    uSSxartPr+p/2sBY7kb8VaiOyCHt8JoqHMJjX2cNsGCbf1T449z1owAvKjvcnWl37FvYNI
    5V2Fq5xnU4qiJ86juIkAnHH/ib4mvr1oRQ5r5JT9yS74qMtPQWW9MrI/LVsQJRYLBzoCdd
    wPAZVvts902FpM1rjp5wDya9Oc72p9a+x4jknzOZP5KTMxATsXh+TgaW5dKEsKdGXvW5P1
    cSOg5rJ2EpdK8GR5Cq2nAmz5H2q9Lqxyd9qh/za82UZ/kSoFh4C7QnTnbU7IgxSI79vRf0
    n/CBg8V0DSdsssnNFxBDrCUUaPN4iZgdClqQtkJM8aGns92G+LLIhz4yjunDp5V3SLmuDX
    f9uR8Bs2aqePXaFNkGKpByEVboIh3iFkcfIhuUSyGgH+vr3FMir2iQLltzhQ
X-ME-Proxy: <xmx:4-p_asC0VbRXNKjmjLN4Fa7cNOEM1NxonXUbJaGqpOMu6XQlY__4FQ>
    <xmx:5Op_avGb0zmQcOtuvlPFBmFX5gYMe7YjDkyVhSbV6lUGZby9ns7row>
    <xmx:5Op_aocaAtYeaT4JcmLuEXUbpWyVQOg0i8aKlQOhT7HLGxn6eKbWiQ>
    <xmx:5Op_as_heLGJ57UyQNehEukjfgkScvbLQZNHjzhcj9Z9PgH308r2Hg>
    <xmx:5Op_angAU8iiwSK0FcfLEsg7fJAVvLwlY3E5vT_clWUyfjsBhPCVTA1G>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:28:13 -0400 (EDT)
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
Subject: [PATCH v2 01/18] VFS: don't count references through ->d_parent
Date: Sat, 15 Aug 2026 14:21:18 +1000
Message-ID: <20260815042707.2535717-2-neilb@ownmail.net>
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
index 3e9af9de7074..ae726f3ff0cb 100644
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
@@ -1986,7 +1988,9 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 	 * don't need child lock because it is not subject
 	 * to concurrency here
 	 */
-	dentry->d_parent = dget_dlock(parent);
+	dentry->d_parent = parent;
+	if (hlist_empty(&parent->d_children))
+		dget_dlock(parent);
 	hlist_add_head(&dentry->d_sib, &parent->d_children);
 	spin_unlock(&parent->d_lock);
 
@@ -2005,7 +2009,7 @@ struct dentry *d_alloc_cursor(struct dentry * parent)
 	struct dentry *dentry = d_alloc_anon(parent->d_sb);
 	if (dentry) {
 		dentry->d_flags |= DCACHE_DENTRY_CURSOR | DCACHE_NORCU;
-		dentry->d_parent = dget(parent);
+		dentry->d_parent = parent;
 	}
 	return dentry;
 }
@@ -2767,7 +2771,9 @@ struct dentry *d_alloc_parallel(struct dentry *parent,
 
 	new->d_flags |= DCACHE_PAR_LOOKUP;
 	spin_lock(&parent->d_lock);
-	new->d_parent = dget_dlock(parent);
+	new->d_parent = parent;
+	if (hlist_empty(&parent->d_children))
+		dget_dlock(parent);
 	hlist_add_head(&new->d_sib, &parent->d_children);
 	if (parent->d_flags & DCACHE_DISCONNECTED)
 		new->d_flags |= DCACHE_DISCONNECTED;
@@ -3095,12 +3101,21 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
 
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
@@ -3113,6 +3128,17 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
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
index 355d93f92208..8646fd6d55ef 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -234,6 +234,16 @@ extern struct dentry *__d_lookup(const struct dentry *, const struct qstr *);
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
index 5a0d276379d1..7cd816b8e2a0 100644
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
index 4b1ff99608e0..64d64bab16fe 100644
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
+	if (!WARN_ON(dentry->d_lockref.count == 0))
+		dentry->d_lockref.count--;
+	return dentry;
+}
 
 /**
  * dget - get a reference to a dentry
diff --git a/include/linux/list.h b/include/linux/list.h
index 09d979976b3b..8db89117e959 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -1107,6 +1107,36 @@ static inline void hlist_add_behind(struct hlist_node *n,
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

base-commit: dac3e89a2c90c2feeb471e1f22a2512ad424b792
-- 
2.50.0.107.gf914562f5916.dirty

