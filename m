Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49524 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbaLQT7M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 14:59:12 -0500
Date: Wed, 17 Dec 2014 14:59:11 -0500
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Jeff Layton <jlayton@primarydata.com>
Subject: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs race
Message-ID: <20141217195911.GF9617@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

On a distributed filesystem it's possible for lookup to discover that a
directory it just found is already cached elsewhere in the directory
heirarchy.  The dcache won't let us keep the directory in both places,
so we have to move the dentry to the new location from the place we
previously had it cached.

If the parent has changed, then this requires all the same locks as we'd
need to do a cross-directory rename.  But we're already in lookup
holding one parent's i_mutex, so it's too late to acquire those locks in
the right order.

The (unreliable) solution in __d_unalias is to trylock() the required
locks and return -EBUSY if it fails.

I see no particular reason for returning -EBUSY, and -ESTALE is already
the result of some other lookup races on NFS.  I think -ESTALE is the
more helpful error return.  It also allows us to take advantage of the
logic Jeff Layton added in c6a9428401c0 "vfs: fix renameat to retry on
ESTALE errors" and ancestors, which hopefully resolves some of these
errors before they're returned to userspace.

I can reproduce these cases using NFS with:

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

It also helps to add some other concurrent use of the directory on the
client (e.g., "ls /mnt/TO").  And you can replace the server-side mv's
by client-side mv's that are repeatedly killed.  (If the client is
interrupted while waiting for the RENAME response then it's left with a
dentry that has to go under one parent or the other, but it doesn't yet
know which.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 5bc72b07fde2..b7de7f1ae38f 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2612,7 +2612,7 @@ static struct dentry *__d_unalias(struct inode *inode,
 		struct dentry *dentry, struct dentry *alias)
 {
 	struct mutex *m1 = NULL, *m2 = NULL;
-	struct dentry *ret = ERR_PTR(-EBUSY);
+	struct dentry *ret = ERR_PTR(-ESTALE);
 
 	/* If alias and dentry share a parent, then no extra locks required */
 	if (alias->d_parent == dentry->d_parent)
-- 
1.9.3

