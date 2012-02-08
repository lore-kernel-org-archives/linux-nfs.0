Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863Ab2BHVQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:16:50 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 00/17] Fix assorted FS-Cache problems
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:16:40 +0000
Message-ID: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Following the mail is a series of patches to fix a number of FS-Cache problems,
including a number of oopses.  The patches can also be found at:

	http://git.kernel.org/?p=linux/kernel/git/dhowells/linux-fscache.git;a=shortlog;h=refs/heads/fixes

The patches are as follows:

 (*) A patch to correctly mark cached netfs pages.  This fixes an oops that
     shows up in the page allocator with PG_private_2 still being set on pages.

 (*) A patch to downgrade memory allocation levels in the cache to not try so
     hard and to be more willing to abort with ENOMEM.  It's a cache - it
     doesn't matter if we can't store something.

 (*) A patch to check that there are no read operations outstanding on a
     cookie when it is relinquished.

 (*) A patch to make conditional some debugging prints.

 (*) A patch to make cookie relinquishment log a warning and wait for any
     outstanding reads.

 (*) A patch to fix up operation state handling and accounting.  This fixes a
     BUG in __fscache_relinquish_cookie() that occurs when cache operation
     completion gets out of sync with the netfs releasing a cookie back to
     fscache.

 (*) Four patches to provide proper invalidation facilities so that the netfs
     can request a cache object be invalidated rather than retiring the cookie
     it has and then getting a new one.

     The first patch provides the hooks and management in the FS-Cache module.

     The second patch splits do_sys_truncate() to create a vfs_truncate() for
     cachefiles's invalidation to call.

     The third patch makes cachefiles honour invalidation requests.

     The fourth patch makes NFS use the invalidation call.

     These fix a BUG() in __fscache_read_or_alloc_pages() that occurs when an
     object that has operations outstanding on it gets its cookie removed.

 (*) Add some missing calls to note completion of retrieval operations in
     cachefiles.  These cause an assertion failure BUG in
     fscache_put_operation() when it tries to destroy an operation that is
     still live.

 (*) Three patches to clean up object event IDs in FS-Cache and to stop masking
     off bits that needn't be masked off.

 (*) A patch to limit the number of I/O errors reported on a cache to 1.  This
     prevents a lot of noise being generated from a busy cache when it is
     aborted.

 (*) A patch to handle an unexpected state in exclusive op submission in
     FS-Cache.  This fixes a BUG that occurs in fscache_submit_exclusive_op()
     if it sees the cache in an aborted state due to an I/O error having
     occurred.

 (*) A patch to make nfs_migrate_page() wait for FS-Cache to finish with a
     page.  This fixes a bad page state BUG in the memory allocator due to NFS
     trying to migrate a page that FS-Cache is doing stuff to.

David
---
David Howells (17):
      NFS: nfs_migrate_page() does not wait for FS-Cache to finish with a page
      FS-Cache: Exclusive op submission can BUG if there's been an I/O error
      FS-Cache: Limit the number of I/O error reports for a cache
      FS-Cache: Don't mask off the object event mask when printing it
      FS-Cache: Initialise the object event mask with the calculated mask
      FS-Cache: Convert the object event ID #defines into an enum
      CacheFiles: Add missing retrieval completions
      NFS: Use FS-Cache invalidation
      CacheFiles: Implement invalidation
      VFS: Make more complete truncate operation available to CacheFiles
      FS-Cache: Provide proper invalidation
      FS-Cache: Fix operation state management and accounting
      FS-Cache: Make cookie relinquishment wait for outstanding reads
      CacheFiles: Make some debugging statements conditional
      FS-Cache: Check that there are no read ops when cookie relinquished
      CacheFiles: Downgrade the requirements passed to the allocator
      CacheFiles: Fix the marking of cached pages


 Documentation/filesystems/caching/backend-api.txt |   38 +++++
 Documentation/filesystems/caching/netfs-api.txt   |   46 +++++-
 Documentation/filesystems/caching/object.txt      |   23 ++-
 Documentation/filesystems/caching/operations.txt  |    2 
 fs/cachefiles/interface.c                         |   57 +++++++-
 fs/cachefiles/internal.h                          |    2 
 fs/cachefiles/key.c                               |    2 
 fs/cachefiles/namei.c                             |    3 
 fs/cachefiles/rdwr.c                              |  114 +++++++++------
 fs/cachefiles/xattr.c                             |    2 
 fs/fscache/cache.c                                |    8 +
 fs/fscache/cookie.c                               |   78 ++++++++++
 fs/fscache/internal.h                             |   12 ++
 fs/fscache/object-list.c                          |    2 
 fs/fscache/object.c                               |   98 ++++++++++++-
 fs/fscache/operation.c                            |  134 ++++++++++++++----
 fs/fscache/page.c                                 |  158 +++++++++++++++++----
 fs/fscache/stats.c                                |   17 ++
 fs/nfs/fscache.h                                  |   20 +++
 fs/nfs/inode.c                                    |   20 ++-
 fs/nfs/nfs4proc.c                                 |    2 
 fs/nfs/write.c                                    |    4 -
 fs/open.c                                         |   50 ++++---
 include/linux/fs.h                                |    1 
 include/linux/fscache-cache.h                     |   71 ++++++++-
 include/linux/fscache.h                           |   50 ++++++-
 26 files changed, 813 insertions(+), 201 deletions(-)

