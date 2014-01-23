Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52950 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbaAWV13 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jan 2014 16:27:29 -0500
Date: Thu, 23 Jan 2014 16:27:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>
Subject: [PATCH] dcache: make d_splice_alias use d_materialise_unique
Message-ID: <20140123212700.GA30466@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <20140117121723.GA18375@infradead.org>
 <20140117153917.GA26636@fieldses.org>
 <20140117210343.GD26636@fieldses.org>
 <20140117212655.GE26636@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140117212655.GE26636@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

d_splice_alias can create duplicate directory aliases (in the !new
case), or (in the new case) d_move directories without holding
appropriate locks.

d_materialise_unique deals with both of these problems.  (The latter
seems to be dealt by trylocks (see __d_unalias), which look like they
could cause spurious lookup failures--but that's at least better than
corrupting the dcache.)

We have to fix up a couple minor differences between d_splice_alias and
d_materialise_unique:
	- d_splice_alias also handles IS_ERR(inode)
	- d_splice_alias allows already-hashed dentries in one special
	  case.

We keep the d_splice_alias name and calling convention and deprecate
d_materialise_unique, which has fewer callers.

Also add some documentation.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |   96 ++++++++++++++++++++++-------------------------------------
 1 file changed, 35 insertions(+), 61 deletions(-)

Here's a revised patch.

If it looks reasonable then there are some further minor simplifications
possible.  (See git://linux-nfs.org/~bfields/linux-topics.git for-viro.)

diff --git a/fs/dcache.c b/fs/dcache.c
index 4bdb300..ec43194 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1765,7 +1765,7 @@ EXPORT_SYMBOL(d_instantiate_unique);
  * @inode: inode to attach to this dentry
  *
  * Fill in inode information in the entry.  If a directory alias is found, then
- * return an error (and drop inode).  Together with d_materialise_unique() this
+ * return an error (and drop inode).  Together with d_splice_alias() this
  * guarantees that a directory inode may never have more than one alias.
  */
 int d_instantiate_no_diralias(struct dentry *entry, struct inode *inode)
@@ -1905,58 +1905,6 @@ struct dentry *d_obtain_alias(struct inode *inode)
 EXPORT_SYMBOL(d_obtain_alias);
 
 /**
- * d_splice_alias - splice a disconnected dentry into the tree if one exists
- * @inode:  the inode which may have a disconnected dentry
- * @dentry: a negative dentry which we want to point to the inode.
- *
- * If inode is a directory and has a 'disconnected' dentry (i.e. IS_ROOT and
- * DCACHE_DISCONNECTED), then d_move that in place of the given dentry
- * and return it, else simply d_add the inode to the dentry and return NULL.
- *
- * This is needed in the lookup routine of any filesystem that is exportable
- * (via knfsd) so that we can build dcache paths to directories effectively.
- *
- * If a dentry was found and moved, then it is returned.  Otherwise NULL
- * is returned.  This matches the expected return value of ->lookup.
- *
- * Cluster filesystems may call this function with a negative, hashed dentry.
- * In that case, we know that the inode will be a regular file, and also this
- * will only occur during atomic_open. So we need to check for the dentry
- * being already hashed only in the final case.
- */
-struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
-{
-	struct dentry *new = NULL;
-
-	if (IS_ERR(inode))
-		return ERR_CAST(inode);
-
-	if (inode && S_ISDIR(inode->i_mode)) {
-		spin_lock(&inode->i_lock);
-		new = __d_find_alias(inode, 1);
-		if (new) {
-			BUG_ON(!(new->d_flags & DCACHE_DISCONNECTED));
-			spin_unlock(&inode->i_lock);
-			security_d_instantiate(new, inode);
-			d_move(new, dentry);
-			iput(inode);
-		} else {
-			/* already taking inode->i_lock, so d_add() by hand */
-			__d_instantiate(dentry, inode);
-			spin_unlock(&inode->i_lock);
-			security_d_instantiate(dentry, inode);
-			d_rehash(dentry);
-		}
-	} else {
-		d_instantiate(dentry, inode);
-		if (d_unhashed(dentry))
-			d_rehash(dentry);
-	}
-	return new;
-}
-EXPORT_SYMBOL(d_splice_alias);
-
-/**
  * d_add_ci - lookup or allocate new dentry with case-exact name
  * @inode:  the inode case-insensitive lookup has found
  * @dentry: the negative dentry that was passed to the parent's lookup func
@@ -2716,19 +2664,37 @@ static void __d_materialise_dentry(struct dentry *dentry, struct dentry *anon)
 }
 
 /**
- * d_materialise_unique - introduce an inode into the tree
- * @dentry: candidate dentry
+ * d_splice_alias - introduce an inode into the tree
  * @inode: inode to bind to the dentry, to which aliases may be attached
+ * @dentry: candidate dentry
+ *
+ * Introduces a dentry into the tree, using either the provided dentry
+ * or, if appropriate, a preexisting alias for the same inode.  Caller must
+ * hold the i_mutex of the parent directory.
+ *
+ * The inode may also be an error or NULL; in the former case the error is
+ * just passed through, in the latter we hash and instantiate the negative
+ * dentry.  This allows filesystems to use d_splice_alias as the
+ * unconditional last step of their lookup method.
+ *
+ * d_splice_alias guarantees that directories will continue to have at
+ * most one alias, by moving an existing alias if necessary.  If doing
+ * so would create a directory loop, it will fail with -ELOOP.
+ *
+ * d_splice_alias makes no such guarantee for files, but may still
+ * use a preexisting alias when it's convenient.
  *
- * Introduces an dentry into the tree, substituting an extant disconnected
- * root directory alias in its place if there is one. Caller must hold the
- * i_mutex of the parent directory.
+ * Note that d_splice_alias normally expects an unhashed dentry, the single
+ * exception being that cluster filesystems may call this function
+ * during atomic_open with a negative hashed dentry, and with inode a
+ * regular file.
  */
-struct dentry *d_materialise_unique(struct dentry *dentry, struct inode *inode)
+struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 {
 	struct dentry *actual;
 
-	BUG_ON(!d_unhashed(dentry));
+	if (IS_ERR(inode))
+		return ERR_CAST(inode);
 
 	if (!inode) {
 		actual = dentry;
@@ -2788,7 +2754,8 @@ struct dentry *d_materialise_unique(struct dentry *dentry, struct inode *inode)
 
 	spin_lock(&actual->d_lock);
 found:
-	_d_rehash(actual);
+	if (d_unhashed(actual))
+		_d_rehash(actual);
 	spin_unlock(&actual->d_lock);
 	spin_unlock(&inode->i_lock);
 out_nolock:
@@ -2800,6 +2767,13 @@ out_nolock:
 	iput(inode);
 	return actual;
 }
+EXPORT_SYMBOL(d_splice_alias);
+
+/* deprecated synonym for d_splice_alias(inode, dentry): */
+struct dentry *d_materialise_unique(struct dentry *dentry, struct inode *inode)
+{
+	return d_splice_alias(inode, dentry);
+}
 EXPORT_SYMBOL_GPL(d_materialise_unique);
 
 static int prepend(char **buffer, int *buflen, const char *str, int namelen)
-- 
1.7.9.5

