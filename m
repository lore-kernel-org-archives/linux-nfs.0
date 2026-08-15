Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80A8131986C;
	Sat, 15 Aug 2026 04:30:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768245; cv=none; b=PXENN8ev7YWVIKexlu/CuSj0doHzj3GkjEdhBGXKqKxzoj+oNCfZICifIVLWZluxEDljKrS7pLDEkTHLzP39ChWMOBHig1jTTzYFj8cLQSqTk67P9BwQCkR5gzdrZC2h8KwxYfNcmX1KslvhneARHUXz8aDNCzJVo4fgzlt4xFE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768245; c=relaxed/simple;
	bh=nGuTFIwa64Q5IMqunT4+fPd2YQmG03yGK+KuZmFRVLU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ocl2I9upiYrvCy0a1lijtvvildXk7d3rw9QawPClmsnAh2DAFDXC6VZAJwZbtAuA7A0PRe+/n+3RzRAoTYetZt4am9EkSnkeO1YwtdwZC5/Y64psNQAxDyFSGM7h4kGOOVEh3h5OkcFYgsLQq+HcJ0gv82WsZ+cj3r1z8jgPIfc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=CkYQsbIZ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=KxyRihOy; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="CkYQsbIZ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="KxyRihOy"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailflow.phl.internal (Postfix) with ESMTP id 8EA91138041A;
	Sat, 15 Aug 2026 00:30:42 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Sat, 15 Aug 2026 00:30:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768242;
	 x=1786775442; bh=4uxv7U2UBafJPVlMxOjjLgs98T4HdcbtcWkA9Y7XY28=; b=
	CkYQsbIZLEM4ihp84qZvq5Hy0eWydToXVogocCx5IkZjzbPGORNuIy7xFKyjjzTA
	iuaqlXkvrbvh4faeQx0+eSYtn0iFNN6KoQjgYgHLl5th61iyhnjKzTjjRUjjX/DG
	7fCZY5nVD3tLHmnBhT93CJIANhbLWRf7fBVGsPRDNTh5NJvp8QLWxUG9mX/YGT2Q
	CwLnh+EHkT5Y0QRZ+lXOKOeEUkqdgpboZo7IqM1SG/nu5+ROgZbt5PfVQ/sCtwG/
	I07eoQoTakzS15tbEKVtSATC5BlVlLBWwH2bRXMOeNWwdZn/b+5h2rWHZZad7er7
	79YZ0nOwoKpC7Pn/T9HojA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768242; x=1786775442; bh=4
	uxv7U2UBafJPVlMxOjjLgs98T4HdcbtcWkA9Y7XY28=; b=KxyRihOyHXsthM7Gi
	cJ8RGVQuH6hSTbKcaudbjADWIfh4oNaVvChnPw3hQ26oW5Jhh0jQshAramBtBXy0
	8a1AADlt6A59i9z1ijpQytOMAXgLnzoQRVQHHLuRzxeHwQzo3lUOJlCFhGh3eAnu
	klVClS4iXTIkfFJ8/j/BeHPdw+XCwVtHBwN5zbR7YSN9163X5NDRL/tbOttxClE4
	6EKmXglywqvm8OFowcZQqTU29J10BTFA9leouDO1QRnlDA2BaP2seuNUmXvfIvk3
	XrScDL52eNfSkR7eiZ8ipuPmsrZVu/Xh0hkjeglEohy2rtOp0ZR2jCZQgnYEw25f
	MAgWA==
X-ME-Sender: <xms:cut_aqmU6bAHggRhzy8oGF0i1k-XeMKD8QMjbFeqYEnCGX9ASHwcDA>
    <xme:cut_as0yrDrY7P3V76mKXuMOo69izdEgbU5SKsuF0tlpHTdO-0cTD6IFCmoeMAFMn
    qNLHu9uCNJiUo_30sl29sID1oIUGW6LcHi73PM25tWAaJ0q>
X-ME-Received: <xmr:cut_avQhuhrD_xGCpLgyb8RwyjJ_acnl8JIPOOGM-OOMQDDbUe8UF1hbZO8DgmWxpYyDv6TFxbR3njrGHe_XLGrZIXAxyGQ>
X-ME-Proxy-Cause: dmFkZTEYOd3tLu5dATIbifwhlYvY0qyYOt7s1LgDprEXebOtP02E/NfWDhmB6dUHRD18Mw
    M/OVd5zhrG+UTD+zvSQphReiWNJaCd0AqwUD63tHfAJF2OAEGvFg1iC8SkfXHW4Cbq3Pnv
    XZPdOI+4XvyfDrMe9ntOWfnHEDm7Vl4MwVM6/98uzVFr9W5lPBzuk8llcQfOSsZLGGgf8M
    1akEE1al0EFoJJ4d9fnySO8LzXZFHrFib9IETFD1LEL7DAdqppQ7UcHFMAN4HHBzYumdeq
    UmiiM2nwa1tgBmTDGFT6cgwcylPb6+Qw0oEVRuLdEgoMQRjiQsSj7nR2Cv5Z5tDGgputXM
    X6RF2cOJZTeJ07dPQW6G7k4SIBGBZnJbxFi3yyqLFAnvZuNtNmI1x6fRn1qYGzLLxk/GLU
    G7To3eDabc57GBDejhJhEq/fJUCqLBGXmgaUpf1usszqSTBMbFXJRfXnm2R1V7EOVqYDG6
    9LMIsA1pG6F8OH0Qp1nL0Vc+OuWfjYqIfiJtoLdCQ1cAa04teE0vUdWAo84gWpjVmHXP11
    0jI8Z9B3Kr64Wy+iC5JAMxETHAoNB9n/PODF7N0kbOLXXklasqR7ZDh+ul6g4VbUT/Zgml
    3OCMP5Akd5Y0h2aPvGdXGCpPW2edPqfDsFLaM4LrQwfcc1zFxchp2t5yl69Q
X-ME-Proxy: <xmx:cut_asO--n892YtXiSH-ipthQKxbcslgK7cfkGC9LHtu33z8P44XBQ>
    <xmx:cut_ajiR2wpr5VBMsodZeZzzcWPfy_6LiVqQF-WDiSZA_NyIYVMFfQ>
    <xmx:cut_asJTN6zUYAfPlTuyK6oaENRAzBegcm2kqDtHFDevlJR-BIXCDw>
    <xmx:cut_au5B8aPqucYJJct8W6FDOOPM2Jv2H3sjghgWhFETv_Py5b8DHA>
    <xmx:cut_auOsDm03mJT3lqa0An1ecrbkjWuEm37NFHNWsXWRiq2vu7PXvPQ7>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:30:36 -0400 (EDT)
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
Subject: [PATCH v2 16/18] libfs: rename and export scan_positives()
Date: Sat, 15 Aug 2026 14:21:33 +1000
Message-ID: <20260815042707.2535717-17-neilb@ownmail.net>
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

autofs has code nearly identical to scan_positives().  To avoid code
duplication, export scan_positives().

Rename it to "d_scan_positives()" to make it more obviously dcache
related.

Change the "count" argument to "skip" which starts from 0 rather than 1.
This makes it a little easier to document the purpose, and makes it less
likely that "0" will be passed when "1" was intended.

For aesthetic consistency, all calls of d_scan_positives() now pass as
the "prev" arg the variable that the result is being assigned to.
This was already the case except when NULL was passed, but in the two
cases where NULL was passed, the target variable already had been
initialised to NULL.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/libfs.c             | 49 ++++++++++++++++++++++++++----------------
 include/linux/dcache.h |  4 ++++
 2 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 15dd470198dd..20cc94b41075 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -97,37 +97,48 @@ int dcache_dir_close(struct inode *inode, struct file *file)
 }
 EXPORT_SYMBOL(dcache_dir_close);
 
-/* parent is locked at least shared */
-/*
- * Returns an element of siblings' list.
- * We are looking for <count>th positive after <p>; if
- * found, dentry is grabbed and returned to caller.
- * If no such element exists, NULL is returned.
- * If last has been removed from the d_children list
- * (i.e. last->d_sib is unhashed) then it is treated like
+/**
+ * d_scan_positives - return next positive dentry after skipping some.
+ * @dentry: the parent dentry to scan
+ * @last: the place to start search, or %NULL to begin at start.
+ * @skip: number of positive dentries to skip over
+ *
+ * Returns the next, or first, positive element of siblings list after
+ * skipping over @skip positive elements.
+ * The child dentry is grabbed and returned to caller.
+ * If no such element exists, %NULL is returned.
+ *
+ * Caller must ensure returned dentry cannot be moved from
+ * the parent, possibly by holding i_rwsem.
+ *
+ * If @last has been removed from the d_children list
+ * (i.e. @last->d_sib is unhashed) then it is treated like
  * the last element of the list and %NULL is returned.
+ *
+ * Returns: a counted ref to a dentry, or %NULL
  */
-static struct dentry *scan_positives(struct dentry *dentry,
-				     struct dentry *last,
-				     loff_t count)
+struct dentry *d_scan_positives(struct dentry *dentry,
+				struct dentry *last,
+				loff_t skip)
 {
 	struct dentry *found = NULL;
 	struct dentry *d = last;
 
 	d_for_each_positive_child_continue(d, dentry) {
-		if (simple_positive(d) && !--count) {
+		if (simple_positive(d) && !skip--) {
 			spin_lock_nested(&d->d_lock, DENTRY_D_LOCK_NESTED);
 			if (simple_positive(d))
 				found = dget_dlock(d);
 			spin_unlock(&d->d_lock);
 			if (likely(found))
 				break;
-			count = 1;
+			skip = 0;
 		}
 	}
 	dput(last);
 	return found;
 }
+EXPORT_SYMBOL(d_scan_positives);
 
 loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 {
@@ -149,8 +160,8 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 
 		inode_lock_shared(dentry->d_inode);
 
-		if (offset > 2)
-			to = scan_positives(dentry, NULL, offset - 2);
+		if (offset >= 3)
+			to = d_scan_positives(dentry, to, offset - 3);
 		spin_lock(&dentry->d_lock);
 		if (to)
 			hlist_move_behind(&cursor->d_sib, &to->d_sib);
@@ -185,7 +196,7 @@ int dcache_readdir(struct file *file, struct dir_context *ctx)
 	if (ctx->pos > 2)
 		next = dget(cursor);
 
-	while ((next = scan_positives(dentry, next, 1)) != NULL) {
+	while ((next = d_scan_positives(dentry, next, 0)) != NULL) {
 		if (!dir_emit(ctx, next->d_name.name, next->d_name.len,
 			      d_inode(next)->i_ino,
 			      fs_umode_to_dtype(d_inode(next)->i_mode)))
@@ -440,7 +451,7 @@ offset_dir_lookup(struct dentry *parent, loff_t offset)
 	MA_STATE(mas, &octx->mt, offset, offset);
 
 	if (offset == DIR_OFFSET_FIRST)
-		found = scan_positives(parent, NULL, 1);
+		found = d_scan_positives(parent, found, 0);
 	else {
 		rcu_read_lock();
 		spin_lock(&parent->d_lock);
@@ -462,7 +473,7 @@ offset_dir_lookup(struct dentry *parent, loff_t offset)
 		spin_unlock(&parent->d_lock);
 		rcu_read_unlock();
 		if (found && !simple_positive(found))
-			found = scan_positives(parent, found, 1);
+			found = d_scan_positives(parent, found, 0);
 	}
 	return found;
 }
@@ -488,7 +499,7 @@ static void offset_iterate_dir(struct file *file, struct dir_context *ctx)
 		if (!offset_dir_emit(ctx, dentry))
 			break;
 
-		dentry = scan_positives(dir, dentry, 1);
+		dentry = d_scan_positives(dir, dentry, 0);
 
 		if (!dentry)
 			goto out_eod;
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index f7d5954c58da..a978d1c4936a 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -723,6 +723,10 @@ static inline struct dentry *d_first_positive(const struct dentry *parent,
 			     child;					\
 			     child = d_next_positive(child))
 
+struct dentry *d_scan_positives(struct dentry *dentry,
+				struct dentry *last,
+				loff_t skip);
+
 void set_default_d_op(struct super_block *, const struct dentry_operations *);
 struct dentry *d_make_persistent(struct dentry *, struct inode *);
 void d_make_discardable(struct dentry *dentry);
-- 
2.50.0.107.gf914562f5916.dirty

