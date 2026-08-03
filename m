Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C140E234994;
	Mon,  3 Aug 2026 01:37:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721034; cv=none; b=kqKF/7Fu8adxP+OpdLF5z9syO13X5WKY3L/+nF0LjWQREMqLVKkkLpiPUEip8/KrFjjXfHxiBeO3ULf5MI1pTO8pjoA3laZy7GEqStVReRcpM0Lm9P0GmlONsV3KklFdrC7m6q4YJh8MyQOLFEqrW0qnTsm6zFHbfAjfI0/VF6s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721034; c=relaxed/simple;
	bh=EbD5w2eeGlbaf9p46vs2K3OwQyCJTl1WmCBJVMY05AE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qaEJGNhJBhKLfOSjijCx9tj9ZG4DxtuV+pskVqvTx2dyS8M95iKN6nzi4RRBR7jcW1M1FmgrFclknJm041gS3yR+Py8A8wzZrXbeytlZOWEps27tw/tz0/gPPD7gH4e1JeklfcYsrR9OqSpY9u4P8Narp61yJacZiW/7nLSWQpU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=P2U6t07s; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eRj1jwxS; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="P2U6t07s";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eRj1jwxS"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.stl.internal (Postfix) with ESMTP id 781DD13000EE;
	Sun,  2 Aug 2026 21:37:11 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Sun, 02 Aug 2026 21:37:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721031;
	 x=1785728231; bh=XcMpOwwDDQgPSkpRR6R3/4paVJIkORHFtV97iS/uiJc=; b=
	P2U6t07sJhEjHQkidyYxiD4jQQJfU5lT2R7KbkLMFPK2BUp66W8cJ6MokSWBOKkx
	Jm2hgAB+bm4bOWJ2VfB0mOWDeRwkWPzAztHnSm9g/a7LjsutgmGwMsjFIlJpDXgc
	t+pJERpALq/tKKknTT1RR+9NKHSunTb6J8rvunOBymq4+wkuxsECVn5qMfs/FDys
	1ByoVR9okh6HmY0ytjX1YLWTNxqxRKnDuUuFAsC+e29BXfH25O2KkB9iH+npEbve
	L8Cgxl5uykYkuUJofBvLcbEWQztvqPD9gWkVuHn/8iNW+bjARuUWBuDPxIuvIYcP
	4nFRKy/AinI+ZmVlcI3GOw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721031; x=1785728231; bh=X
	cMpOwwDDQgPSkpRR6R3/4paVJIkORHFtV97iS/uiJc=; b=eRj1jwxSKB7yQvR9v
	Mx8nM/Rn8b9FlcQURHiU1iQdBfBKIo7rOd874TFYIcknH3F8Ur+rJ8nzymg5K2SQ
	X7gaxbW7uXIx2xy0xxvswsJnVbjnPF+6kW6J5mYAeTLV4C1wy6gYk6cUse7ztvHd
	8wdkrg7652gGZGV0B1NdUKvVjgYdBtCFe/h8Gk5rnLz456e3+62tJ8CO5EZSf5AN
	Kh1wiAqiADW6OmO/YplEV3K2AHtrlYZq6KYil+CuoFqZS+YRpt9/iAjdX2nJQlFF
	bpzelWub0AwNrGEs8ZbZ0/FBdz7Vd1U++zIY7avWXilQPT0+CEv15DlNl2VFwcDf
	3QBiQ==
X-ME-Sender: <xms:xvBvao4_Dh9CmdiwXSgDEQP804z6_oI32xwmSDBroSH7FkmtKsViRg>
    <xme:xvBvak607jL79umcXyIdt0IjceRVfZlkSEraQbG_kPO0WVZEDLpKelZ5TLjYLI6rA
    W3aQ_j7qCmTi2ojMxtm8uJ1zAPeeqlzUXZNOYAGnFrgsli3Ahs>
X-ME-Received: <xmr:xvBvauErUdAMZNp_RtYQN0v3XwR0PE5varx1XLIQ9czk2G5VHs_jCOALj2AaGLFLVogR6rFBxj4BLdimsacYvWHgcSYhKzU>
X-ME-Proxy-Cause: dmFkZTFswjlVGtOMO0DJ/yAygp0kikcHV2WSXHSGnlIkcuf0k9rLUdswY4SNsXMvUWMhfJ
    kpfPtsQuVQ8vSHADhVm4IRY0nolbqOkRQBDAEaT6PViWtUiGaZ1RuyP3TKdnsto1GxdvO6
    EDjVnoxMaix/qwxYa/EnmBrWSMWR71Xsepg0lYJWsNgdazP7uMjE+vSD+hiwoRYUCYwqMd
    8UCnzcTzoJOqEB2P0a4xlmt6Vi448YXJsDRRsyN3s901toR6OrLn7/rtKpBURTUpkDqxh0
    ISJdNDy7NZx3er7DV1F6c9yJO9k8PkZEqBrF2awe8iwc4c7xBw+lDoz5IzuZ4fXetXOOeD
    XW5ROghAbYM1zOQv2FZiIJBpE+A2JHdbTH0yZXq9CseRXGe5RVTddJcB11sUYtqQmIRKbC
    dP6YOhQRrnjIYR9XS+C1c++XSFBMJtTyX/P+sAvvWkOooYyGh2Zu9n/i44qF/5m9Ukg+JI
    oMcUNLnzRAjt3G4oSl63HcB01QF0RW9ZjEFE0T/B61V//D8ebEpWh7YhEqWuX3BzUfGQbm
    oOxQwMHUQ7HL6gHvh5moDinXkzXzaBiL3N54iTVMtyH4hlh8KX15FYn8cnSL+gHFoV6PA7
    CLC333YamaKY2LB6Sbxq8lngDAldV0r/KKB44S9oKzUjbgkaM1pYbPL86i9A
X-ME-Proxy: <xmx:xvBvaqzmsDBZxHHDVFLPxmrQt7M8p-jGylji03dWqMMoiK1B4mOliA>
    <xmx:xvBvam3lEckI_WkgBeRa7_x4JXmoJn4wwoyf5r3HqMrkCAgDBOBRgA>
    <xmx:xvBvalPM3A9pcZXxfOF5UvuKAvdXLpWDDf5PucvHsJFK_5uhU-TuaQ>
    <xmx:xvBvaqvdY58x_4fQvZ5Bm9DIFyVcPY_8Ma4Hy4mmoJ83YqTKhiitCQ>
    <xmx:x_BvagK_YzKiI_pIOzdBk-0_P5zbdJGAGfEtibnGD85_dEASczpGZWrD>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:37:03 -0400 (EDT)
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
Subject: [PATCH v1 01/12] VFS: don't count references through ->d_parent
Date: Mon,  3 Aug 2026 11:21:10 +1000
Message-ID: <20260803012648.2195405-2-neilb@ownmail.net>
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
it has been moved from dentry_kill().

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/dcache.c            | 40 +++++++++++++++++++++++++++++++++-------
 include/linux/dcache.h | 17 ++++++++++++++++-
 2 files changed, 49 insertions(+), 8 deletions(-)

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
-- 
2.50.0.107.gf914562f5916.dirty

