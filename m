Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759821Ab3JOVDV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 17:03:21 -0400
Date: Tue, 15 Oct 2013 17:03:16 -0400
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH] nfs: use IS_ROOT not DCACHE_DISCONNECTED
Message-ID: <20131015210316.GA11616@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This check was added by Al Viro with
d9e80b7de91db05c1c4d2e5ebbfd70b3b3ba0e0f "nfs d_revalidate() is too
trigger-happy with d_drop()", with the explanation that we don't want to
remove the root of a disconnected tree, which will still be included on
the s_anon list.

But DCACHE_DISCONNECTED does *not* actually identify dentries that are
disconnected from the dentry tree or hashed on s_anon.  IS_ROOT() is the
way to do that.

Also add a comment from Al's commit to remind us why this check is
there.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/dir.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index de434f3..2acc77a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1139,7 +1139,13 @@ out_zap_parent:
 	if (inode && S_ISDIR(inode->i_mode)) {
 		/* Purge readdir caches. */
 		nfs_zap_caches(inode);
-		if (dentry->d_flags & DCACHE_DISCONNECTED)
+		/*
+		 * We can't d_drop the root of a disconnected tree:
+		 * its d_hash is on the s_anon list and d_drop() would hide
+		 * it from shrink_dcache_for_unmount(), leading to busy
+		 * inodes on unmount and further oopses.
+		 */
+		if (IS_ROOT(dentry))
 			goto out_valid;
 	}
 	/* If we have submounts, don't unhash ! */
-- 
1.7.9.5

