Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49680 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758638Ab2HUVhT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 17:37:19 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>,
        Nick Piggin <npiggin@kernel.dk>
Subject: [PATCH 1/2] dcache: use IS_ROOT to decide where dentry is hashed
Date: Tue, 21 Aug 2012 17:37:11 -0400
Message-Id: <1345585032-19119-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1345585032-19119-1-git-send-email-bfields@redhat.com>
References: <1345585032-19119-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Every hashed dentry is either hashed in the dentry_hashtable, or a
superblock's s_anon list.

__d_shrink assumes it can determine which is the case by checking
DCACHE_DISCONNECTED; this is not true.

It is true that when DCACHE_DISCONNECTED is cleared, the dentry is not
only hashed on dentry_hashtable, but is fully connected to its parents
back to the root.

But the converse is *not* true: fs/exportfs/expfs.c:reconnect_path()
attempts to connect a directory (found by filehandle lookup) back to
root by ascending to parents and performing lookups one at a time.  It
does not clear DCACHE_DISCONNECTED until its done, and that is not at
all an atomic process.

In particular, it is possible for DCACHE_DISCONNECTED to be set on a
dentry which is hashed on the dentry_hashtable.

Instead, use IS_ROOT() to check which hash chain a dentry is on.  This
*does* work:

Dentries are hashed only by:

	- d_obtain_alias, which adds an IS_ROOT() dentry to sb_anon.

	- __d_rehash, called by _d_rehash: hashes to the dentry's
	  parent, and all callers of _d_rehash appear to have d_parent
	  set to a "real" parent.
	- __d_rehash, called by __d_move: rehashes the moved dentry to
	  hash chain determined by target, and assigns target's d_parent
	  to its d_parent, before dropping the dentry's d_lock.

Therefore I believe it's safe for a holder of a dentry's d_lock to
assume that it is hashed on sb_anon if and only if IS_ROOT(dentry) is
true.

I believe the incorrect assumption about DCACHE_DISCONNECTED was
originally introduced by ceb5bdc2d246 "fs: dcache per-bucket dcache hash
locking".

Cc: Nick Piggin <npiggin@kernel.dk>
Reviewed-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 8086636..ea2fcfa 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -410,7 +410,7 @@ static void __d_shrink(struct dentry *dentry)
 {
 	if (!d_unhashed(dentry)) {
 		struct hlist_bl_head *b;
-		if (unlikely(dentry->d_flags & DCACHE_DISCONNECTED))
+		if (unlikely(IS_ROOT(dentry)))
 			b = &dentry->d_sb->s_anon;
 		else
 			b = d_hash(dentry->d_parent, dentry->d_name.hash);
-- 
1.7.11.4

