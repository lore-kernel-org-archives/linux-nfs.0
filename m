Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80BB6234994;
	Mon,  3 Aug 2026 01:38:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721112; cv=none; b=AI94oDPDamSv2oJBhNAnFNnLqW9rfMbjm/hpgu8XKepyiSusv7xnyFf0mTlH25erkfjSbPPF6FlThfpMfIUUR35WwXZ9SKqjTolWkLjq+8EJJGKyW3zNl/H54K4NdcMRXQ82n91Q6M87SbCzBCdbIhD+bzH/pCZk5JVo4fG3VFA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721112; c=relaxed/simple;
	bh=abwJDLnaCl8gUqs8UAbpVAsHe0p+acH/jodii6vvHPs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BhlDLGzrOZU0rWSFuPZO6urOIbKI9ITS6n8sSDF/tcbEvkLDFpFFSNRB2fwN/4AlduifGHakviXLndvOnQAw7AM6HVP2O+3sb3kKrSZEl8GD6Yg+8SUVUs010aSKtuwj7dw3A8twuVGs26BMA4xEBtPU4QE1q1WDM1pZkTTJ+wY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=LXv/amUy; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=lFIJh9nS; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="LXv/amUy";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lFIJh9nS"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.stl.internal (Postfix) with ESMTP id 498E0130010C;
	Sun,  2 Aug 2026 21:38:30 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Sun, 02 Aug 2026 21:38:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721110;
	 x=1785728310; bh=31JtnpcYZd4fsPZ94hZjJrOdT1mohnvAR1GVbqnnzZE=; b=
	LXv/amUyruIWD5YRtJNQ+u8/ikBBOH55JsdAqKlhJsDoCG3VXkPJQj3nHJmhBU+B
	9ig7ynSr2OJMPVMF86fdJ84EWFtglhCWftTeoA8Nbmp2jYrj4BhWhVyAHpImxUlf
	X8HMfRafgUadyAEoKZsQOgaBnHbaHykj6S69pYE5XDUZhlfXc98FnjIhwhUOMVQs
	TE9Q0On+K9DcqWUkiESG2hhQWUjxmXRKLV1NT/Ua0O42S6Zg3/iC3yYJu7XUhYxv
	xv9ssWMktM7uRFcF+YnwXoQVcgK15v5F7HxRTC0J+ORsWWjAPHFrBEUd+aEjGZwH
	0tNoaeZIixJziOJoFh5ibQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721110; x=1785728310; bh=3
	1JtnpcYZd4fsPZ94hZjJrOdT1mohnvAR1GVbqnnzZE=; b=lFIJh9nSNN6QWA4Yw
	v7jNnKIaay4DdVAZqUlHrM9IgjL0DyrWnx4l7FV5zevU6h3Kkj70Tnw0Q5nZSRqn
	YxRnuFxhSLiFJYSZoaIaPg2hBKjXbY0o1GdrK8FJhupzMWyzwcKDpEV03z5k2di9
	53TrP8Rlhgu7VU41dz1NsI1aTnzvIAySFkMOhOJMLJz8snxKZr8TdqEuHEeWv6kJ
	162XL6xDNP1i2WBsm5QKBpHnQBqPD+eV5PqIP5RIllnWeK93xRvcmMKJTVdRtIna
	nvvaPnm6v76IizWzAGKSXLazZNc6XOKQ0zeAU3DTCKZbkzuUUO4oiCyB13BOwPoU
	gfjlA==
X-ME-Sender: <xms:FfFvak2BF_dl_-kiSOtz1X8NGDpsxqPDrI7ruMqAzVLDHCkTMaC3Yw>
    <xme:FfFvaqFMBb54ICCvKHSOv3XC7l9ZS77jn29mQciXXeh9sRsTdok2g4U_AZmQhqmcB
    UCnTNQHzgkCEnkt75C3YPTU3i458bpYG74H1wgQN6zL1CkurlQ>
X-ME-Received: <xmr:FfFvajiZTrzJWg1tUp-Q2w8G9f5yofqza4Eur_isNowWmLCajyBag6ocqpoJ-LPKtjdwnWHXNWYDs2loOdVI1oiMsyRAGwM>
X-ME-Proxy-Cause: dmFkZTFswjlVGtOMO0DJ/yAygp0kikcHV2WSXHSGnlIkcuf0k9rLUdswY4SNsXMvUWMhfJ
    kpfPtsQuVQ8vSHADhVm4IRY0nolbqOkRQBDAEaT6PViWtUiGaZ1RuyP3TKdnsto1GxdvO6
    EDjVnoxMaix/qwxYa/EnmBrWSMWR71Xsepg0lYJWsNgdazP7uMjE+vSD+hiwoRYUCYwqMd
    8UCnzcTzoJOqEB2P0a4xlmt6Vi448YXJsDRRsyN3s901toR6OrLn7/rtKpBURTUpkDqxh0
    ISJdNDy7NZx3er7DV1F6c9yJO9k8PkZEqBrF2awe8iwc4c7xBw+lDoz5IzuZ4fXetXOOYO
    d0TuZyYFDkUdlU/167fU6rLQ0XBnvJBQ+tdUWsoWVaxciR0e3eqm9HJiRyRFtrqkYYdMhJ
    tkB4gIy/paGwaxvydaAPU5GL6X7A8uhYQpUBjU1LyKn+3qy7u596xwMDK/44LWGghfs+Dz
    lZUS7UEf2JbZz6+0/YZdDoMtjFJ7mgbYo9GL011Aa7cJXO222GKJj2lL95was32WrMKCFA
    ukEeQwABzklkGvKmgOifr91AJUVscQDoyi5P6axmFaQclD5l7FewqQAnlHtVINw1bZWjzp
    xdsYXdwOFhwI4qUiCS/cs2YU0MqCt1+QAMKD13oTh/pQLh9+vZGE6QvoJAng
X-ME-Proxy: <xmx:FfFvareeCJpy5AAjQW2VO8SgrRqTRK-NFlTLWXWZ7tzGiK7PClC6Vg>
    <xmx:FfFvahwk6aYMFIo6GUqI0ctwAOR7iqRyG7xk7IEsZWqQ5UWfqHfvQw>
    <xmx:FfFvata2J3Ipl9EUt1sf0z-1GtrdUQ_leezTiBcjW8Ofh_drig7tSw>
    <xmx:FfFvanJpv5K3nxAm70LbYvSdW-2TQU0XGcPIHLNJbSgy3gGyH0tSVg>
    <xmx:FvFvajfDjSQnAnsA7l1AHhzaJUnPnsMHs2jYyRGtug4jKGUbfxQzFvXd>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:38:22 -0400 (EDT)
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
Subject: [PATCH v1 08/12] libfs: replace find_positive_dentry() with scan_positives()
Date: Mon,  3 Aug 2026 11:21:17 +1000
Message-ID: <20260803012648.2195405-9-neilb@ownmail.net>
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
index 260f56863742..c0771e8b645c 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -435,47 +435,39 @@ static loff_t offset_dir_llseek(struct file *file, loff_t offset, int whence)
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
+			 * which isn't a cursor.
+			 */
+			hlist_for_each_entry_from(found, d_sib) {
+				if (!(found->d_flags & DCACHE_DENTRY_CURSOR) &&
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
@@ -497,18 +489,14 @@ static void offset_iterate_dir(struct file *file, struct dir_context *ctx)
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

