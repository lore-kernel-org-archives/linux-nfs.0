Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56187 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756100Ab2EIVSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 17:18:11 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] vfs: remove unused __d_splice_alias argument
Date: Wed,  9 May 2012 17:18:06 -0400
Message-Id: <1336598286-28636-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1336598286-28636-1-git-send-email-bfields@redhat.com>
References: <1336598286-28636-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Nobody sets want_disconn any more.

Reported-by: Peng Tao <bergwolf@gmail.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 2434c1e..8e34e91 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -649,8 +649,6 @@ EXPORT_SYMBOL(dget_parent);
 /**
  * d_find_alias - grab a hashed alias of inode
  * @inode: inode in question
- * @want_discon:  flag, used by d_splice_alias, to request
- *          that only a DISCONNECTED alias be returned.
  *
  * If inode has a hashed alias, or is a directory and has any alias,
  * acquire the reference to alias and return it. Otherwise return NULL.
@@ -659,10 +657,9 @@ EXPORT_SYMBOL(dget_parent);
  * of a filesystem.
  *
  * If the inode has an IS_ROOT, DCACHE_DISCONNECTED alias, then prefer
- * any other hashed alias over that one unless @want_discon is set,
- * in which case only return an IS_ROOT, DCACHE_DISCONNECTED alias.
+ * any other hashed alias over that.
  */
-static struct dentry *__d_find_alias(struct inode *inode, int want_discon)
+static struct dentry *__d_find_alias(struct inode *inode)
 {
 	struct dentry *alias, *discon_alias;
 
@@ -674,7 +671,7 @@ again:
 			if (IS_ROOT(alias) &&
 			    (alias->d_flags & DCACHE_DISCONNECTED)) {
 				discon_alias = alias;
-			} else if (!want_discon) {
+			} else {
 				__dget_dlock(alias);
 				spin_unlock(&alias->d_lock);
 				return alias;
@@ -705,7 +702,7 @@ struct dentry *d_find_alias(struct inode *inode)
 
 	if (!list_empty(&inode->i_dentry)) {
 		spin_lock(&inode->i_lock);
-		de = __d_find_alias(inode, 0);
+		de = __d_find_alias(inode);
 		spin_unlock(&inode->i_lock);
 	}
 	return de;
@@ -2395,7 +2392,7 @@ struct dentry *d_materialise_unique(struct dentry *dentry, struct inode *inode)
 		struct dentry *alias;
 
 		/* Does an aliased dentry already exist? */
-		alias = __d_find_alias(inode, 0);
+		alias = __d_find_alias(inode);
 		if (alias) {
 			actual = alias;
 			write_seqlock(&rename_lock);
-- 
1.7.9.5

