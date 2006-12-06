From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: asynchronous locks for cluster exports
Date: Wed,  6 Dec 2006 00:34:10 -0500
Message-ID: <11653832602203-git-send-email-bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

We'd like an asynchronous posix locking interface so that we can provide NFS
clients with cluster-coherent locking without blocking lockd while the
filesystem goes off and talks to other nodes.

So, here's one attempt.  It also includes an draft implementation of the
filesystem side for GFS2, which may well be wrong--it's not even tested
yet--but hopefully gives some idea what would be necessary.

A few points, among others, that I'm unsure of:

	- We added a new ->lock() export operation, figuring this was a feature
	  that only lockd and nfsd care about for now, and that we'd rather not
	  muck about with common locking code.  But the export operation is
	  pretty much identical to the file ->lock() operation; would it make
	  more sense to use that?

	- The filesystem returns the lock results to lockd using the
	  ->fl_notify() callback.  We add a few arguments to fl_notify() to
	  pass the results, and add a return value so the filesystem can
	  recognize the case where the callback comes after lockd has given up
	  waiting and returned an error to the user.  Presumably the filesystem
	  needs to have a way to cancel the lock in this case.  (Our GFS code
	  ignores this problem for now.)  Maybe it would be better to just poke
	  lockd when the result is ready and let it discover what happened by
	  retrying the original ->lock() call?  Or maybe we should use a
	  separate callback?

	- We're ignoring the blocking lock case for now under the assumption
	  it's always OK for lockd to return an immediate "denied" in that
	  case, then use the granted callback, even in cases where it doesn't
	  know for sure that there's a conflicting lock.

Thoughts?  Better ideas?

--b.
