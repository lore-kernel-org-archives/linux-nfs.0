Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50197 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753272Ab3JYUaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/8] simplify reconnecting dentries looked up by filehandle (v2)
Date: Fri, 25 Oct 2013 16:29:57 -0400
Message-Id: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is a revised version of patches to simplify the code that
reconnects directories looked up by filehandle.  Thanks to Christoph for
review.  Changes since v1 include:

	- BUG_ON finding a filesystem root with DCACHE_DISCONNECTED
	- fix some dentry reference leaks
	- only do the dentry_connected() check when we actually hit a
	  race--it's redundant in the normal case.
	- simplify some of the logic
	- add detail to changelogs and comments
	- sequence the patches slightly differently (hopefully it's
	  clearer)

Christoph, I credited one minor patch to you, and I ignored several
Reviewed-by's you posted since I wasn't sure if you'd want them on the
revised patches.

The following explanation is mostly unchanged from before, including the
performance results.  (I didn't redo them, but a couple quick checks
didn't suggest any significant difference from the revisions.)

--b.

When we lookup a filehandle for a directory not already in the dentry
cache, fs/exportfs/expfs.c:reconnect_path() is what populates the dentry
cache with the directory and its parents.

The current code is more complicated than necessary:

	- after looking up the parent, it searches the parent directory
	  for our target dentry.  If that search fails with -ENOENT, it
	  retries up to 10 times.  I don't understand why.  This should
	  only happen if there's a concurrent rename or rmdir, in which
	  case that concurrent operation should have reconnected the
	  dentry for us, and we're done.

	- each time it succesfully connects a dentry to its parent, it
	  restarts from scratch with the original dentry.  Why not
	  continue working with the parent we just found?

Patches showing the resulting simplification follow.

I tested performance with a script that creates an N-deep directory
tree, gets a filehandle for the bottom directory, writes 2 to
/proc/sys/vm/drop_caches, then times an open_by_handle_at() of the
filehandle.  Code at

	git://linux-nfs.org/~bfields/fhtests.git

For directories of various depths, some example observed times (median
results of 3 similar runs, in seconds), were:

		depth:	8000	2000	200
	no patches:	11	0.7	0.02
	all patches:	 0.1	0.03	0.01

For depths < 2000 I used an ugly hack to shrink_slab_node() to force
drop_caches to free more dentries.  Difference look lost in the noise
for much smaller depths.

Nesting that deep sounds crazy to me, and cold lookup of a
filehandle isn't the common case.  But maybe it's worth not having to
worry about the awful performance in these pathalogical cases.  And it
does simplify the code.

Christoph Hellwig (1):
  exportfs: BUG_ON in crazy corner case

J. Bruce Fields (7):
  exportfs: more detailed comment for path_reconnect
  exportfs: clear DISCONNECTED on all parents sooner
  exportfs: stop retrying once we race with rename/remove
  exportfs: eliminate unused "noprogress" counter
  exportfs: move most of reconnect_path to helper function
  exportfs: better variable name
  exportfs: fix quadratic behavior in filehandle lookup

 fs/exportfs/expfs.c |  249 +++++++++++++++++++++++++++------------------------
 1 file changed, 133 insertions(+), 116 deletions(-)

-- 
1.7.9.5

