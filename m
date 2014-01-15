Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43246 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbaAOPRu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jan 2014 10:17:50 -0500
Date: Wed, 15 Jan 2014 10:17:49 -0500
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>
Subject: [PATCH] dcache: fix d_splice_alias handling of aliases
Message-ID: <20140115151749.GF23999@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

d_splice_alias can create duplicate directory aliases (in the !new
case), or (in the new case) d_move without holding appropriate locks.

d_materialise_unique deals with both of these problems.  (The latter
seems to be dealt by trylocks (see __d_unalias), which look like they
could cause spurious lookup failures--but that's at least better than
corrupting the dcache.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |   25 +------------------------
 1 file changed, 1 insertion(+), 24 deletions(-)

Only lightly tested....  If this is right, then we can also just ditch
d_splice_alias completely, and clean up the various d_find_alias's.

I think the only reason we have both d_splice_alias and
d_materialise_unique is that the former was written for exportable
filesystems and the latter for distributed filesystems.

But we have at least one exportable filesystem (fuse) using
d_materialise_unique.  And I doubt d_splice_alias was ever completely
correct even for on-disk filesystems.

Am I missing some subtlety?

--b.

diff --git a/fs/dcache.c b/fs/dcache.c
index 4bdb300..da82fa9 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1926,33 +1926,10 @@ EXPORT_SYMBOL(d_obtain_alias);
  */
 struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 {
-	struct dentry *new = NULL;
-
 	if (IS_ERR(inode))
 		return ERR_CAST(inode);
 
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
+	return d_materialise_unique(dentry, inode);
 }
 EXPORT_SYMBOL(d_splice_alias);
 
-- 
1.7.9.5

