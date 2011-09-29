Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692Ab1I2Oqk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 10:46:40 -0400
From: David Howells <dhowells@redhat.com>
Subject: [RFC][PATCH 00/13] Fix FS-Cache problems
To: moseleymark@gmail.com, mark@pogo.org.uk, jlayton@redhat.com,
        steved@redhat.com
Cc: linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2011 15:45:36 +0100
Message-ID: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Here are some patches to debug and fix FS-Cache problems.

 (1) A debugging patch to add a predictable pattern generator with a filesystem
     interface.  Can be used to generate regular apparent changes on the NFS
     server.  This was very useful in breaking FS-Cache.

 (2) A patch to correctly mark cached netfs pages.

 (3) A debugging patch to validate page->mapping on a page for which retrieval
     was requested.

 (4) A patch to downgrade memory allocation levels in the cache to not try so
     hard and to be more willing to abort with ENOMEM.  It's a cache - it
     doesn't matter if we can't store something.

 (5) A debugging patch to check that there are no read operations outstanding
     on a cookie when it is relinquished.

 (6) A debugging patch to check that the object cookie pointer doesn't get
     cleared whilst we're trying to read for it.

 (7) A patch to make conditional some debugging prints.

 (8) A patch to make cookie relinquishment log a warning and wait for any
     outstanding reads.

 (9) A patch to fix up operation state handling and accounting.

(10) A patch to provide proper invalidation facilities.

(11) A patch to make a vfs_truncate() for cachefiles's invalidation to call.

     Question: CacheFiles uses truncation in a couple of places.  It has been
     using notify_change() rather than sys_truncate() or something similar.
     This means it bypasses a bunch of checks and suchlike that it possibly
     should be making (security, file locking, lease breaking, vfsmount write).
     Should it be using vfs_truncate() as added by a preceding patch or should
     it use notify_write() and assume that anyone poking around in the cache
     files on disk gets everything they deserve?

(12) A patch to provide invalidation for cachefiles.

(13) A patch to make NFS use the invalidation call.

David
---
David Howells (13):
      NFS: Use FS-Cache invalidation
      CacheFiles: Implement invalidation
      VFS: Make more complete truncate operation available to CacheFiles
      FS-Cache: Provide proper invalidation
      FS-Cache: Fix operation state management and accounting
      FS-Cache: Make cookie relinquishment wait for outstanding reads
      CacheFiles: Make some debugging statements conditional
      FS-Cache: Check cookie is still correct in __fscache_read_or_alloc_pages()
      FS-Cache: Check that there are no read ops when cookie relinquished
      CacheFiles: Downgrade the requirements passed to the allocator
      FS-Cache: Validate page mapping pointer value
      CacheFiles: Fix the marking of cached pages
      Noisefs: A predictable noise producing fs for testing things


 Documentation/filesystems/caching/backend-api.txt |   38 ++
 Documentation/filesystems/caching/netfs-api.txt   |   46 ++-
 Documentation/filesystems/caching/object.txt      |   23 +
 Documentation/filesystems/caching/operations.txt  |    2 
 fs/Kconfig                                        |    1 
 fs/Makefile                                       |    1 
 fs/cachefiles/interface.c                         |   57 +++-
 fs/cachefiles/internal.h                          |    2 
 fs/cachefiles/key.c                               |    2 
 fs/cachefiles/rdwr.c                              |  118 ++++---
 fs/cachefiles/xattr.c                             |    2 
 fs/fscache/cookie.c                               |   78 +++++
 fs/fscache/internal.h                             |   10 +
 fs/fscache/object.c                               |   74 +++++
 fs/fscache/operation.c                            |  135 ++++++---
 fs/fscache/page.c                                 |  188 ++++++++++--
 fs/fscache/stats.c                                |   11 +
 fs/nfs/fscache.h                                  |   20 +
 fs/nfs/inode.c                                    |   20 +
 fs/nfs/nfs4proc.c                                 |    2 
 fs/noisefs/Kconfig                                |   20 +
 fs/noisefs/Makefile                               |    7 
 fs/noisefs/file.c                                 |  331 +++++++++++++++++++++
 fs/noisefs/inode.c                                |  171 +++++++++++
 fs/noisefs/internal.h                             |   59 ++++
 fs/noisefs/super.c                                |  302 +++++++++++++++++++
 fs/open.c                                         |   50 ++-
 include/linux/fs.h                                |    1 
 include/linux/fscache-cache.h                     |   53 +++
 include/linux/fscache.h                           |   50 +++
 mm/page-writeback.c                               |    1 
 31 files changed, 1696 insertions(+), 179 deletions(-)
 create mode 100644 fs/noisefs/Kconfig
 create mode 100644 fs/noisefs/Makefile
 create mode 100644 fs/noisefs/file.c
 create mode 100644 fs/noisefs/inode.c
 create mode 100644 fs/noisefs/internal.h
 create mode 100644 fs/noisefs/super.c

