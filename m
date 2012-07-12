Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41137 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603Ab2GLW2v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 18:28:51 -0400
Date: Thu, 12 Jul 2012 18:28:49 -0400
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: DCACHE_DISCONNECTED use in try_to_ascend/d_kill
Message-ID: <20120712222849.GE24162@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been trying to figure out if we can pare down DCACHE_DISCONNECTED
uses to only those required by exportfs, and ran across this one.

Is there another test that would work instead?

(E.g., checking list_empty(&dentry->d_u.d_child)?)

--b.

commit c83ce989cb5ff86575821992ea82c4df5c388ebc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 15 13:36:43 2011 -0400

    VFS: Fix the nfs sillyrename regression in kernel 2.6.38
    
    The new vfs locking scheme introduced in 2.6.38 breaks NFS sillyrename
    because the latter relies on being able to determine the parent
    directory of the dentry in the ->iput() callback in order to send the
    appropriate unlink rpc call.
    
    Looking at the code that cares about races with dput(), there doesn't
    seem to be anything that specifically uses d_parent as a test for
    whether or not there is a race:
      - __d_lookup_rcu(), __d_lookup() all test for d_hashed() after d_parent
      - shrink_dcache_for_umount() is safe since nothing else can rearrange
        the dentries in that super block.
      - have_submount(), select_parent() and d_genocide() can test for a
        deletion if we set the DCACHE_DISCONNECTED flag when the dentry
        is removed from the parent's d_subdirs list.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org (2.6.38, needs commit c826cb7dfce8 "dcache.c:
    	create helper function for duplicated functionality" )
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/fs/dcache.c b/fs/dcache.c
index 361882a..a39fe47 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -296,8 +296,12 @@ static struct dentry *d_kill(struct dentry *dentry, struct dentry *parent)
 	__releases(parent->d_lock)
 	__releases(dentry->d_inode->i_lock)
 {
-	dentry->d_parent = NULL;
 	list_del(&dentry->d_u.d_child);
+	/*
+	 * Inform try_to_ascend() that we are no longer attached to the
+	 * dentry tree
+	 */
+	dentry->d_flags |= DCACHE_DISCONNECTED;
 	if (parent)
 		spin_unlock(&parent->d_lock);
 	dentry_iput(dentry);
@@ -1030,6 +1034,7 @@ static struct dentry *try_to_ascend(struct dentry *old, int locked, unsigned seq
 	 * or deletion
 	 */
 	if (new != old->d_parent ||
+		 (old->d_flags & DCACHE_DISCONNECTED) ||
 		 (!locked && read_seqretry(&rename_lock, seq))) {
 		spin_unlock(&new->d_lock);
 		new = NULL;
