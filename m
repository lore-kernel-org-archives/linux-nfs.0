Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40151 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754124AbaKRPpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 10:45:05 -0500
Date: Tue, 18 Nov 2014 10:45:03 -0500
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [TROLL PATCH] namei: retry -EBUSY returns to workaround distributed
 fs race
Message-ID: <20141118154503.GD7419@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

On a distributed filesystem it's possible for lookup to discover that
the directory it has looked up is cached elsewhere in the heirarchy.
Moving the dentry into place requires all the locks to do a
cross-directory rename, but we're already holding a parent's i_mutex and
it's too late to acquire those locks in the right order.

The solution in __d_unalias is to trylock() the required locks and
return -EBUSY if we fail.  I can reproduce that case pretty reliably:

	ssh root@$client '
		mount -olookupcache=pos '$server':'$export' /mnt/
		mkdir /mnt/TO
		mkdir /mnt/DIR
		touch /mnt/DIR/test.txt
		while true; do
			strace -e open cat /mnt/DIR/test.txt 2>&1 | grep EBUSY
		done
	'
	ssh root@$server '
		while true; do
			mv $export/DIR $export/TO/DIR
			mv $export/TO/DIR $export/DIR
		done
	'

The following is a hack that's wrong for several reasons but that does
eliminate the EBUSY's in practice, by returning up to the caller that
took the i_mutex and having it drop the i_mutex and retry.

Even if we were actually going to do something like this, we'd probably
also need to patch lookup_slow, kern_path_create, do_rmdir, do_unlinkat,
renameat2, mountpoint_last, atomic_open, and all the callers of
lookup_one_len that look like they might deal with a distributed
filesystem--on a quick check that's probably another 8 callers in nfsd
and exportfs.

Is there any real fix, or do we just need to document that operations on
a distributed filesystem can temporarily return -EBUSY?
---
 fs/namei.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index 43927d14db67..e9222dac8ee6 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1466,10 +1466,13 @@ static int lookup_slow(struct nameidata *nd, struct path *path)
 	parent = nd->path.dentry;
 	BUG_ON(nd->inode != parent->d_inode);
 
+retry:
 	mutex_lock(&parent->d_inode->i_mutex);
 	dentry = __lookup_hash(&nd->last, parent, nd->flags);
 	mutex_unlock(&parent->d_inode->i_mutex);
-	if (IS_ERR(dentry))
+	if (PTR_ERR(dentry) == -EBUSY)
+		goto retry;
+	else if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 	path->mnt = nd->path.mnt;
 	path->dentry = dentry;
-- 
1.9.3

