Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56189 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756355Ab2EIVSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 17:18:11 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] vfs: stop d_splice_alias creating directory aliases
Date: Wed,  9 May 2012 17:18:05 -0400
Message-Id: <1336598286-28636-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1336598286-28636-1-git-send-email-bfields@redhat.com>
References: <1336598286-28636-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

A directory should never have more than one dentry pointing to it.

But d_splice_alias() will add one if it finds a directory with an
already-existing non-DISCONNECTED dentry.

I can't find an obvious reproducer, but I also can't see what prevents
d_splice_alias() from encountering such a case.

It therefore seems safest to allow d_splice_alias to use any dentry it
finds.

(Prior to the removal of dentry_unhash() from vfs_rmdir(), around v3.0,
this could cause an nfsd deadlock like this:

	- Somebody attempts to remove a non-empty directory.
	- The dentry_unhash() in vfs_rmdir() unhashes the dentry
	  pointing to the non-empty directory.
	- ->rmdir() then fails with -ENOTEMPTY
	- Before the vfs_rmdir() caller reaches dput(), an nfsd process
	  in rename looks up the directory by filehandle; at the end of
	  that lookup, this dentry is found by d_alloc_anon(), and a
	  reference is taken on it, preventing dput() from removing it.
	- A regular lookup of the directory calls d_splice_alias(),
	  finds only an unhashed (not a DISCONNECTED) dentry, and
	  insteads adds a new one, so the directory now has two
	  dentries.
	- The nfsd process in rename, which was previously looking up
	  the source directory of the rename, now looks up the target
	  directory (which is the same), and gets the dentry newly
	  created by the previous lookup.
	- The rename, seeing two different dentries, assumes this is a
	  cross-directory rename and attempts to take the i_mutex on the
	  directory twice.

That reproducer no longer exists, but I don't think there was anything
fundamentally incorrect about the vfs_rmdir() behavior there, so I think
the real fault was here in d_splice_alias().)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index b60ddc4..2434c1e 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1606,9 +1606,8 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 
 	if (inode && S_ISDIR(inode->i_mode)) {
 		spin_lock(&inode->i_lock);
-		new = __d_find_alias(inode, 1);
+		new = __d_find_any_alias(inode);
 		if (new) {
-			BUG_ON(!(new->d_flags & DCACHE_DISCONNECTED));
 			spin_unlock(&inode->i_lock);
 			security_d_instantiate(new, inode);
 			d_move(new, dentry);
-- 
1.7.9.5

