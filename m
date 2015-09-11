Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:36710 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbbIKKyx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 06:54:53 -0400
Received: by ykdt18 with SMTP id t18so66771399ykd.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 03:54:53 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v4 00/16] nfsd: open file caching
Date: Fri, 11 Sep 2015 06:54:26 -0400
Message-Id: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4:
- squash some of the patches down into one patch to reduce churn
- close cached open files after unlink instead of before
- don't just close files after nfsd does an unlink, must do it
  after any vfs-layer unlink. Use fsnotify to handle that.
- use a SRCU notifier chain for setlease
- add patch to allow non-kthreads to do a fput_sync

v3:
- open files are now hashed on inode pointer instead of fh
- eliminate the recurring workqueue job in favor of shrinker/LRU and
  notifier from lease setting code
- have nfsv4 use the cache as well
- removal of raparms cache

v2:
- changelog cleanups and clarifications
- allow COMMIT to use cached open files
- tracepoints for nfsd_file cache
- proactively close open files prior to REMOVE, or a RENAME over a
  positive dentry

This is the fourth iteration of the open file cache patches for nfsd.
There are some rather major changes here vs. the earlier sets,
particularly in how we close cached open files when there is vfs-layer
activity (unlinks or setlease calls in particular).

For those seeing this for the first time, main impetus here is to help
speed up NFSv3 I/O. nfsd will do an open+read/write+close for every READ
or WRITE RPC. This patchset allows us to cache those open files more or
less indefinitely, and close them out in response to certain vfs-layer
activity (unlinks and setlease attempts primarily).

The first few patches in the series make (small) changes to several
subsystems to enable the caching infrastructure. The 8th patch adds
the cache itself, and then the remaining patches hook the nfsd code
up to the cache. The final patch rips out the raparms cache since it's
no longer needed with these changes.

The most controversial piece here I think will be the 3rd patch in the
series which allows fput_sync to run in non-kthread context. This is
necessary to allow userland threads to close out cached nfsd files in
advance of setlease attempts. Al, I'd appreciate it if you could weigh
in on that one. I'm fine with adding more scary warnings to the comment
above it if you think it's warranted.

Jeff Layton (16):
  locks: change tracepoint for generic_add_lease
  list_lru: add list_lru_rotate
  fs: allow __fput_sync to be used by non-kthreads and in modules
  fsnotify: export several symbols
  locks: create a new notifier chain for lease attempts
  nfsd: move include of state.h from trace.c to trace.h
  sunrpc: add a new cache_detail operation for when a cache is flushed
  nfsd: add a new struct file caching facility to nfsd
  nfsd: hook up nfsd_write to the new nfsd_file cache
  nfsd: hook up nfsd_read to the nfsd_file cache
  nfsd: hook nfsd_commit up to the nfsd_file cache
  nfsd: convert nfs4_file->fi_fds array to use nfsd_files
  nfsd: have nfsd_test_lock use the nfsd_file cache
  nfsd: convert fi_deleg_file and ls_file fields to nfsd_file
  nfsd: hook up nfs4_preprocess_stateid_op to the nfsd_file cache
  nfsd: rip out the raparms cache

 fs/file_table.c                 |  27 +-
 fs/locks.c                      |  37 +++
 fs/nfsd/Kconfig                 |   2 +
 fs/nfsd/Makefile                |   3 +-
 fs/nfsd/export.c                |  14 +
 fs/nfsd/filecache.c             | 552 ++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/filecache.h             |  37 +++
 fs/nfsd/nfs3proc.c              |   2 +-
 fs/nfsd/nfs4layouts.c           |  12 +-
 fs/nfsd/nfs4proc.c              |  32 +--
 fs/nfsd/nfs4state.c             | 174 ++++++-------
 fs/nfsd/nfs4xdr.c               |  16 +-
 fs/nfsd/nfsproc.c               |   2 +-
 fs/nfsd/nfssvc.c                |  16 +-
 fs/nfsd/state.h                 |  10 +-
 fs/nfsd/trace.c                 |   2 -
 fs/nfsd/trace.h                 | 129 ++++++++++
 fs/nfsd/vfs.c                   | 220 +++-------------
 fs/nfsd/vfs.h                   |   8 +-
 fs/nfsd/xdr4.h                  |  15 +-
 fs/notify/group.c               |   2 +
 fs/notify/mark.c                |   3 +
 include/linux/file.h            |   2 +-
 include/linux/fs.h              |   1 +
 include/linux/list_lru.h        |  13 +
 include/linux/sunrpc/cache.h    |   1 +
 include/trace/events/filelock.h |  38 ++-
 kernel/acct.c                   |   2 +-
 mm/list_lru.c                   |  15 ++
 net/sunrpc/cache.c              |   3 +
 30 files changed, 1027 insertions(+), 363 deletions(-)
 create mode 100644 fs/nfsd/filecache.c
 create mode 100644 fs/nfsd/filecache.h

-- 
2.4.3

