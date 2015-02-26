Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45279 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932254AbbBZOCA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 09:02:00 -0500
Subject: [PATCH 00/13] FS-Cache: Fix a number of bugs that occur when the
 cache runs out of space
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:01:55 +0000
Message-ID: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Attached are a bunch of patches that progressively fix bugs that can occur
when the cache hits the hard "must maintain X free space" limit and starts
rejecting requests.

The commit ensubjected "FS-Cache: Synchronise object death state change vs
operation submission" is the main bug I was looking for.  Some of the other
patches fix other bugs I found along the way and the remaining patches are
changes pulled out of the bugfixes to make the bugfix commits more narrowly
targeted.

Note that I added some new stats:

	Ops    : ini=836360 dfr=19 rel=836360 gc=19

The ini=N field here indicates the number of fscache_operation structs that
were initialised and should match the rel=M value.

	CacheEv: nsp=3425 stl=0 rtr=0 cul=0

Indicates counts of certain cache backend events: nsp=N shows how many objects
were rejected due to lack of space in the cache, stl=N shows how many objects
were found to be stale upon reuse and thus discarded, rtr=N how many objects
were retired and cul=N shows how many inactive objects were culled.

These can also be found here:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache-fixes

tagged with:

	fscache-fixes-20150226

David
---
David Howells (13):
      FS-Cache: Count culled objects and objects rejected due to lack of space
      FS-Cache: Move fscache_report_unexpected_submission() to make it more available
      FS-Cache: When submitting an op, cancel it if the target object is dying
      FS-Cache: Handle a new operation submitted against a killed object
      FS-Cache: Synchronise object death state change vs operation submission
      FS-Cache: fscache_object_is_dead() has wrong logic, kill it
      FS-Cache: Permit fscache_cancel_op() to cancel in-progress operations too
      FS-Cache: Out of line fscache_operation_init()
      FS-Cache: Count the number of initialised operations
      FS-Cache: Fix cancellation of in-progress operation
      FS-Cache: Put an aborted initialised op so that it is accounted correctly
      FS-Cache: The operation cancellation method needs calling in more places
      FS-Cache: Retain the netfs context in the retrieval op earlier


 Documentation/filesystems/caching/backend-api.txt |   23 ++
 Documentation/filesystems/caching/fscache.txt     |    7 -
 fs/cachefiles/internal.h                          |    1 
 fs/cachefiles/namei.c                             |   33 ++-
 fs/fscache/cookie.c                               |    8 -
 fs/fscache/internal.h                             |   12 +
 fs/fscache/object.c                               |   69 +++++-
 fs/fscache/operation.c                            |  254 ++++++++++++++-------
 fs/fscache/page.c                                 |   86 ++++---
 fs/fscache/stats.c                                |   14 +
 include/linux/fscache-cache.h                     |   55 ++---
 11 files changed, 378 insertions(+), 184 deletions(-)

