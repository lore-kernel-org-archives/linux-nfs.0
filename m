Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:34928 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751412AbeDFUAI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Apr 2018 16:00:08 -0400
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Subject: [GIT PULL] fscache: Fixes, traces and development
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 06 Apr 2018 21:00:04 +0100
Message-ID: <14829.1523044804@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Here are some patches that fix some of AFS's usage of fscache, two of which
conflict with later patches in this series, so I've included them here:

 (1) Need to invalidate the cache if a foreign data change is detected on
     the server.

 (2) Move the vnode ID uniquifier (equivalent to i_generation) from the
     auxiliary data to the index key to prevent a race between file delete
     and a subsequent file create seeing the same index key.

 (3) Need to retire cookies that correspond to files that we think got
     deleted on the server.

There are some patches to fix some things in fscache and cachefiles:

 (4) Fix a couple of checker warnings.

 (5) Correctly indicate to the end-of-operation callback whether an
     operation completed or was cancelled.

 (6) Add a check for multiple cookie relinquishment.

 (7) Fix a path through the asynchronous write that doesn't wake up a
     waiter for a page if the cache decides not to write that page, but
     discards it instead.

There a couple of patches to add tracepoints to fscache and cachefiles:

 (8) Add tracepoints for cookie operators, object state machine execution,
     cachefiles object management and cachefiles VFS operations.

 (9) Add tracepoints for fscache operation management and page wrangling.

And then three development patches:

(10) Attach the index key and auxiliary data to the cookie, pass this
     information through various fscache-netfs API functions and get rid of
     the callbacks to the netfs to get it.

     This means that the cache can get at this information, even if the
     netfs goes away.  It also means that the cache can be lazy in updating
     the coherency data.

(11) Pass the object data size through various fscache-netfs API rather
     than calling back to the netfs for it, and store the value in the
     object.

     This makes it easier to correctly resize the object, as the size is
     updated on writes to the cache, rather than calling back out to the
     netfs.

(12) Maintain a catalogue of allocated cookies.  This makes it possible to
     catch cookie collision up front rather than down in the bowels of the
     cache being run from a service thread from the object state machine.

     This will also make it possible in the future to reconnect to a cookie
     that's not gone dead yet because it's waiting for finalisation of the
     storage and also make it possible to bring cookies online if the cache
     is added after the cookie has been obtained.

I modified this from the previous post to fix a bug found by the kbuild test
robot.

David
---
The following changes since commit 17dec0a949153d9ac00760ba2f5b78cb583e995f:

  Merge branch 'userns-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace (2018-04-03 19:15:32 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/fscache-next-20180406

for you to fetch changes up to ec0328e46d6e5d0f17372eb90ab8e333c2ac7ca9:

  fscache: Maintain a catalogue of allocated cookies (2018-04-06 14:05:14 +0100)

----------------------------------------------------------------
fscache development

----------------------------------------------------------------
David Howells (12):
      afs: Invalidate cache on server data change
      afs: Use the vnode ID uniquifier in the cache key not the aux data
      afs: Be more aggressive in retiring cached vnodes
      fscache, cachefiles: Fix checker warnings
      fscache: Pass the correct cancelled indications to fscache_op_complete()
      fscache: Detect multiple relinquishment of a cookie
      fscache: Fix hanging wait on page discarded by writeback
      fscache: Add tracepoints
      fscache: Add more tracepoints
      fscache: Attach the index key and aux data to the cookie
      fscache: Pass object size in rather than calling back for it
      fscache: Maintain a catalogue of allocated cookies

 Documentation/filesystems/caching/netfs-api.txt | 157 ++++---
 fs/9p/cache.c                                   | 100 ++---
 fs/afs/cache.c                                  | 150 +------
 fs/afs/cell.c                                   |   6 +-
 fs/afs/file.c                                   |   6 +-
 fs/afs/inode.c                                  |  49 ++-
 fs/afs/internal.h                               |   7 +
 fs/afs/volume.c                                 |   6 +-
 fs/cachefiles/interface.c                       |  61 ++-
 fs/cachefiles/internal.h                        |   2 +
 fs/cachefiles/main.c                            |   1 +
 fs/cachefiles/namei.c                           |  75 ++--
 fs/cachefiles/rdwr.c                            |   1 +
 fs/cachefiles/xattr.c                           |   8 +-
 fs/ceph/cache.c                                 | 113 ++---
 fs/cifs/cache.c                                 | 168 +-------
 fs/cifs/fscache.c                               | 130 +++++-
 fs/cifs/fscache.h                               |  13 +
 fs/fscache/cache.c                              |   2 +-
 fs/fscache/cookie.c                             | 386 ++++++++++++++---
 fs/fscache/fsdef.c                              |  55 +--
 fs/fscache/internal.h                           |  44 +-
 fs/fscache/main.c                               |   1 +
 fs/fscache/netfs.c                              |  71 +---
 fs/fscache/object-list.c                        |  28 +-
 fs/fscache/object.c                             |  66 ++-
 fs/fscache/operation.c                          |  26 +-
 fs/fscache/page.c                               |  84 +++-
 fs/fscache/stats.c                              |   1 -
 fs/nfs/fscache-index.c                          | 159 +------
 fs/nfs/fscache.c                                |  89 +++-
 fs/nfs/fscache.h                                |  15 +
 include/linux/fscache-cache.h                   |  26 +-
 include/linux/fscache.h                         | 142 ++++---
 include/trace/events/cachefiles.h               | 325 ++++++++++++++
 include/trace/events/fscache.h                  | 537 ++++++++++++++++++++++++
 36 files changed, 2029 insertions(+), 1081 deletions(-)
 create mode 100644 include/trace/events/cachefiles.h
 create mode 100644 include/trace/events/fscache.h
