Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8FF13148C9;
	Sat, 15 Aug 2026 04:29:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768197; cv=none; b=LCI9oUh9HXNxHNQptlgnltlKuULrY1EqjlBhkuB6yvrlGy6ub6wXAcCaZOoUJCdCQSYaUtNZWPpdziQG8xT0nenBOldKdQWb++TPQyCu1gMzxwwaTYAqxYkbv+6SNckGBgnXRnwjNgYw9DVies/ze01azl1d7efoopujxSyxQwI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768197; c=relaxed/simple;
	bh=Iw3VALCpZlU5FoCwNGf9vMOQGrtTMvPWAyD6VVPWZnQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cPe2syUOP5EV2J5Sso+BDOFRBU44dxsehunk50Shrdz3wLKMuodpzo4tCx0f6RJZbJvnk7mT8Ty6RWF7BZuVhH6GGpJigt7p0YYMOCSu2jCRMlRN9w8pnC6+Ihc+UUb6Lt2jiOkgrWeltmDsvL1VhyyWleJoMEcgbMqe2jNjheM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Vau827fi; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=B0I1+2iu; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Vau827fi";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="B0I1+2iu"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.phl.internal (Postfix) with ESMTP id CECF01380415;
	Sat, 15 Aug 2026 00:29:54 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Sat, 15 Aug 2026 00:29:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768194;
	 x=1786775394; bh=ipVqCw+8UnsuKe/hZ8nVpr7wwOvOMF0TbptTc3tK3HQ=; b=
	Vau827fixuD0uFsqSIYWVABs5FAKMTfHxa1uHY652TuKM1fxMil8ZAZin4n1bUfF
	MKhbf0pdP+TZiOHy5piffVp1m42V+BsL2Amuxt4fZtQNJ1uEVOn5FELgdqsZGtHS
	H4PeBnBjnKv+I5oZWWfwS73llJzB3Z9kLnka+WaE+nnFlUGjDgdjHHW/mXxj5Ms6
	JEoD59T8F9JdV7Oi5Ng0J+NpsI+wHoupn+/u8MWhpSGH0s+gLw81tGsYRvfwyhMO
	OPtI7oEixQgqwktzqwNpYorNnoh7mfbx0N+ZCHbNkpRxBGYm47IJ0nx+hYBlLGh2
	cBbmeNJ52nON3ojH+WaixQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768194; x=1786775394; bh=i
	pVqCw+8UnsuKe/hZ8nVpr7wwOvOMF0TbptTc3tK3HQ=; b=B0I1+2iu+030Hltrv
	5gs4XjIBIQc44/0jsYIRyfL634tHP8c4gzATlYzfGShVWK9k5mO3HVz7riCQpshf
	F4CoqUDKmlnnINAJxMVqgU3O5fazijrbPCwQxAYVkWzMGsb74unHHjUsA4bAE9bZ
	V3pJ3NjjqovbMLSdlrX3P9DZEpRvPHmtdsKBRgq+jhiMG+sm7XbtuWlRSL+Ebt5b
	hAdK6Mc6ugB+jipSrf2DEmCSR4aDw4Ast072I20L+rAZFLj763VooKOSqAwDYBhR
	fxun3CrOQSL48hY9FmL8Pb4tlzAwoPPpARWJAlKsX/zXSvqWVIPa3XAhFgg9X7tK
	nyc3Q==
X-ME-Sender: <xms:Qut_arpTbLKLV78A44ImQ-zibhNE2X87CTy7W3zRGVWzwmPiVnP9Qg>
    <xme:Qut_agrTrDhnGJV3-1GvmTXc2sq6pQrUEgt-5IvZK6HEaIbdGnrPYjM_oSW6Y8KzV
    BmWkMicvNSMSzDwDAVkWczNeITsRU2vwUiG4nfK312tluB22Q>
X-ME-Received: <xmr:Qut_au0pMW-IUiOtmLMolKLMPgIKZZvTJcR57olRsJ0BSIEed_5-VLzh0YmYKxLAy1-tatb9zIkPeOiD4GbsTNK95JLl9Ao>
X-ME-Proxy-Cause: dmFkZTECw6EEPYbx+7BaaLSeXge8TL0IFS/e22W0DFWlbDFG9eII2nLkfnvZprtL9LDp1m
    HNcIj6bmqu83Qm/YUapqU6PBN6WcNm8P6Gy6RDWT6cAAmyaKdoJVe4WWntEcEJw7UAQpab
    Ivov0q9n39VXDrfptfrf0jUwc+MgicKL4WCNr5zVI2XTGGzlh1W80uuvtEo9Ovpf8kur1R
    vP/VXSxnYRhNfcG7+F4fSgFn0Gt4iNMYjiANVHauJEWjElKvMPdOxk4oexwOk01N0r04qi
    8M218+E0MCoqYMSR4rZhl0wfvSlTNBrLCF/rmquNqRbB0zK7AmmuLtO4fjAl8K2V5bn2Ju
    AkPgxmk04sv0SEleau/gWRpcN9fQrqXpmy9K17LojMc+D7IS+ERklte0Egn2YkzKsSXell
    FR52E1sdUw2TizUIpW4CEZcLbUJBhNvYBFS+2dvY093H2f8p4N5j8fgjdIebRRd/FJGjbB
    djQb4dbqK67dbUq7WVngecIPIps8ykAO0KLmpOYpLSwCd90mOAtZmRVIQHEm5zZR305rko
    Zzh899W5OkAR69cb95xBD4+5R9sG3O94/j9jk8Y1PlTsYCwdV2n2p7ZgbvwPygbpYg3XbA
    dXWNy7bJhPiXQtzZglXYUm7766vkbKqSY4J4LlwQX07M90uIC4o33mWR2I8Q
X-ME-Proxy: <xmx:Qut_asjZXq_S-RO6s18NhAo0y8-gVR1zBEFl_FLjWsibFFCaPzPRYw>
    <xmx:Qut_almQXWciEF9-BqsAFq7fXiJjJ5eVe-z-fBoFQ9oR4m-Ajc9HZw>
    <xmx:Qut_as-aNKt10uYsfZ3pluWkDYHVD_gzmKNaNVV3tUiOKU4hCHypsw>
    <xmx:Qut_ancwmolcTj9IiOVqCSIiAf2tiPdsd6ELUYYmrpDlfgZTVj6cmQ>
    <xmx:Qut_akBZDIPmjt7RE_hZXK_EODRWvyCN5-9rQYIRPijOUDGcNMLUskdf>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:29:49 -0400 (EDT)
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
Subject: [PATCH v2 11/18] libfs: replace find_positive_dentry() with scan_positives()
Date: Sat, 15 Aug 2026 14:21:28 +1000
Message-ID: <20260815042707.2535717-12-neilb@ownmail.net>
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

scan_positives() can be used in place of find_positive_dentry().

This makes offset_iterate_dir() simpler as 'next' is no longer needed.

offset_dir_lookup() needs an extra loop to find a child on which a ref
can be taken, as scan_positives() requires a dentry with a ref.  I think
this makes a cleaner separation as the RCU read lock no longer needs to
be held over the scan call.  This will be important in a future patch.

Using scan_positives() means, after the next patch, that cursors can
appear on the d_sib list, so when finding a dentry from the offset,
which might be dead by now (dentry_kill()) we need to step over any
cursors to find something we can take a reference on.  This requires
parent->d_lock as cursors are not RCU-safe.

We add lockref_get_not_dead_nested() so that we can opportunistically
get a ref on a child while holding the lock on the parent.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/libfs.c              | 58 ++++++++++++++++-------------------------
 include/linux/lockref.h | 12 ++++++++-
 lib/lockref.c           | 10 ++++---
 3 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 21abe0074c77..44e8dec51237 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -438,47 +438,39 @@ static loff_t offset_dir_llseek(struct file *file, loff_t offset, int whence)
 	return vfs_setpos(file, offset, LONG_MAX);
 }
 
-static struct dentry *find_positive_dentry(struct dentry *parent,
-					   struct dentry *dentry,
-					   bool next)
-{
-	struct dentry *found = NULL;
-
-	spin_lock(&parent->d_lock);
-	if (next)
-		dentry = d_next_sibling(dentry);
-	else if (!dentry)
-		dentry = d_first_child(parent);
-	hlist_for_each_entry_from(dentry, d_sib) {
-		if (!simple_positive(dentry))
-			continue;
-		spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
-		if (simple_positive(dentry))
-			found = dget_dlock(dentry);
-		spin_unlock(&dentry->d_lock);
-		if (likely(found))
-			break;
-	}
-	spin_unlock(&parent->d_lock);
-	return found;
-}
-
 static noinline_for_stack struct dentry *
 offset_dir_lookup(struct dentry *parent, loff_t offset)
 {
 	struct inode *inode = d_inode(parent);
 	struct offset_ctx *octx = inode->i_op->get_offset_ctx(inode);
-	struct dentry *child, *found = NULL;
+	struct dentry *found = NULL;
 
 	MA_STATE(mas, &octx->mt, offset, offset);
 
 	if (offset == DIR_OFFSET_FIRST)
-		found = find_positive_dentry(parent, NULL, false);
+		found = scan_positives(parent, NULL, NULL, 1);
 	else {
 		rcu_read_lock();
-		child = mas_find_rev(&mas, DIR_OFFSET_MIN);
-		found = find_positive_dentry(parent, child, false);
+		spin_lock(&parent->d_lock);
+		found = mas_find_rev(&mas, DIR_OFFSET_MIN);
+		if (found) {
+			/*
+			 * parent lock ensures found is still on
+			 * the d_sib list, but it could be have been marked dead.
+			 * So we need to find something we can get a ref on,
+			 * which isn't a cursor, and isn't anything NORCU.
+			 */
+			hlist_for_each_entry_from(found, d_sib) {
+				if (!(found->d_flags & DCACHE_NORCU) &&
+				    lockref_get_not_dead_nested(&found->d_lockref,
+								DENTRY_D_LOCK_NESTED))
+					break;
+			}
+		}
+		spin_unlock(&parent->d_lock);
 		rcu_read_unlock();
+		if (found && !simple_positive(found))
+			found = scan_positives(parent, NULL, found, 1);
 	}
 	return found;
 }
@@ -500,18 +492,14 @@ static void offset_iterate_dir(struct file *file, struct dir_context *ctx)
 	if (!dentry)
 		goto out_eod;
 	while (true) {
-		struct dentry *next;
-
 		ctx->pos = dentry2offset(dentry);
 		if (!offset_dir_emit(ctx, dentry))
 			break;
 
-		next = find_positive_dentry(dir, dentry, true);
-		dput(dentry);
+		dentry = scan_positives(dir, NULL, dentry, 1);
 
-		if (!next)
+		if (!dentry)
 			goto out_eod;
-		dentry = next;
 	}
 	dput(dentry);
 	return;
diff --git a/include/linux/lockref.h b/include/linux/lockref.h
index 6ded24cdb4a8..9da4fbc2cd13 100644
--- a/include/linux/lockref.h
+++ b/include/linux/lockref.h
@@ -52,7 +52,17 @@ bool lockref_get_not_zero(struct lockref *lockref);
 bool lockref_put_or_lock(struct lockref *lockref) __cond_acquires(false, &lockref->lock);
 
 void lockref_mark_dead(struct lockref *lockref);
-bool lockref_get_not_dead(struct lockref *lockref);
+bool lockref_get_not_dead_nested(struct lockref *lockref, int subclass);
+/**
+ * lockref_get_not_dead - Increments count unless the ref is dead
+ * @lockref: pointer to lockref structure
+ *
+ * Return: 1 if count updated successfully or 0 if lockref was dead
+ */
+static inline bool lockref_get_not_dead(struct lockref *lockref)
+{
+	return lockref_get_not_dead_nested(lockref, 0);
+}
 
 /* Must be called under spinlock for reliable results */
 static inline bool __lockref_is_dead(const struct lockref *l)
diff --git a/lib/lockref.c b/lib/lockref.c
index 5d8e3ef3860e..dddd26100a51 100644
--- a/lib/lockref.c
+++ b/lib/lockref.c
@@ -136,11 +136,13 @@ void lockref_mark_dead(struct lockref *lockref)
 EXPORT_SYMBOL(lockref_mark_dead);
 
 /**
- * lockref_get_not_dead - Increments count unless the ref is dead
+ * lockref_get_not_dead_nested - Increments count unless the ref is dead
  * @lockref: pointer to lockref structure
+ * @subclass: lockdep class for taking ->lock
+ *
  * Return: 1 if count updated successfully or 0 if lockref was dead
  */
-bool lockref_get_not_dead(struct lockref *lockref)
+bool lockref_get_not_dead_nested(struct lockref *lockref, int subclass)
 {
 	bool retval = false;
 
@@ -152,7 +154,7 @@ bool lockref_get_not_dead(struct lockref *lockref)
 		return true;
 	);
 
-	spin_lock(&lockref->lock);
+	spin_lock_nested(&lockref->lock, subclass);
 	if (lockref->count >= 0) {
 		lockref->count++;
 		retval = true;
@@ -160,4 +162,4 @@ bool lockref_get_not_dead(struct lockref *lockref)
 	spin_unlock(&lockref->lock);
 	return retval;
 }
-EXPORT_SYMBOL(lockref_get_not_dead);
+EXPORT_SYMBOL(lockref_get_not_dead_nested);
-- 
2.50.0.107.gf914562f5916.dirty

