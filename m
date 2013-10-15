Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933997Ab3JOUkA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 16:40:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org
Subject: simplify reconnecting dentries looked up by filehandle
Date: Tue, 15 Oct 2013 16:39:28 -0400
Message-Id: <1381869574-10662-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we lookup a filehandle for a directory not already in the dentry
cache, fs/exportfs/expfs.c:reconnect_path() is what populates the dentry
cache with the directory and its parents.

The current code looks more complicated than necessary:

	- after looking up the parent, it searches the parent directory
	  for our target dentry.  If that search fails with -ENOENT, it
	  retries up to 10 times.  I don't understand why.  This should
	  only happen if there's a concurrent rename or rmdir, in which
	  case that concurrent operation should have reconnected the
	  dentry for us, and we're done.

	- each time it succesfully connects a dentry to its parent, it
	  restarts from scratch with the original dentry.  Why not
	  continue working with the parent we just found?

Have I missed some reason that we need the more complicated approach?

Patches showing my attempted simplification follow.

Most of the work is in the last patch (which I didn't manage to break up
as well as I'd like), but there's also a smaller optimization in the
first patch.

I tested performance with a script that creates an N-deep directory
tree, gets a filehandle for the bottom directory, writes 2 to
/proc/sys/vm/drop_caches, then times an open_by_handle_at() of the
filehandle.  Code at

	git://linux-nfs.org/~bfields/fhtests.git

For directories of various depths, some example observed times (median
results of 3 similar runs, in seconds), were:

		depth:	8000	2000	200
	no patches:	11	0.7	0.02
	first patch:	 6	0.4	0.01
	all patches:	 0.1	0.03	0.01

For depths < 2000 I used an ugly hack to shrink_slab_node() to force
drop_caches to free more dentries.  Difference look lost in the noise
for much smaller depths.

Nesting that deep sounds crazy to me, and cold lookup of a
filehandle isn't the common case.  But maybe it's worth not having to
worry about the awful performance in these pathalogical cases.  And it
does simplify the code.

--b.

