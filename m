Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33908 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756201Ab2DTWqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 18:46:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/3] Fix use_ipaddr race
Date: Fri, 20 Apr 2012 18:46:15 -0400
Message-Id: <1334961978-2843-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We have a report of failed upcalls that occur when use_ipaddr is
toggled.  The problem appears to be that for example after turning on
use_ipaddr, the kernel may still see upcalls for clients such as "*".

The following patches (untested except to check that they compile...)
attempt to fix that by just letting nfsd_fh() accept either client type;
does anyone see a problem with that?


The current code actually attempts to avoid tihs problem by flushing
caches on a use_ipaddr change (see the cache_flush() call in
utils/mountd/auth.c:check_useipaddr().  But that doesn't work, because a
write to a cache/flush file doesn't actually provide useful guarantees
to the caller on return:

	- as far as I can tell, cache_clean leaves alone any entries
	  that were created in the current second.
	- cache_clean only removes entries from the cache, it doesn't
	  wait for them to actually be destroyed: so an in-progress nfsd
	  thread could still make an upcall using information from one
	  of the flushed entries.

These seem like bugs in their own right to me: a cache-flush operation
that actually guaranteed the entries were gone on return would be more
useful.  And I wonder whether this doesn't also cause exportfs bugs....

I'm not sure what to do about it, though.

I don't think the existing interface is really fixable, since fixing the
second problem above would (I think) require the cache/flush write to
wait on in-progress rpc's, but those in-progress rpc's could be waiting
on mountd, creating a deadlock.

A new interface shouldn't need to accept a time--every actual user just
wants to cache flushed now.

Maybe the first problem could be solved by replacing the time by a
counter incremented on each insert of a cache entry.

And the second could be fixed by waiting on in-progress rpc's.  That
might not help mountd, but it would help exportfs at least.

--b.

J. Bruce Fields (3):
  mountd: unconditionally resolve ip address
  mountd: helper function for export upcall's client matching
  mountd: ignore use_ipaddr and just try both client types

 utils/mountd/cache.c |   38 +++++++++++++++++++++++++-------------
 1 files changed, 25 insertions(+), 13 deletions(-)

-- 
1.7.7.6

