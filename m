Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35633 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbbJELCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 07:02:49 -0400
Received: by qkap81 with SMTP id p81so66922633qka.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 04:02:48 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v5 00/20] nfsd: open file caching
Date: Mon,  5 Oct 2015 07:02:22 -0400
Message-Id: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v5:
- switch to using flush_delayed_fput instead of __fput_sync
- hash on inode->i_ino instead of inode pointer
- add /proc/fs/nfsd/file_cache_stats file to track stats on the hash
- eliminate extra fh_verify in nfsd_file_acquire

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

This is the fifth iteration of the open file cache patches for nfsd.
The main changes from the v4 set are the conversion of the code to
use flush_delayed_fput instead of __fput_sync, and some changes to
improve performance.

The kbuild test robot noted a drop in performance with this set,
which turned out to be lousy hash distribution due to hashing on
inode pointer value. Hashing on inode->i_ino gives a much better
distribution.

For those seeing this for the first time, main impetus here is to help
speed up NFSv3 I/O. nfsd will do an open+read/write+close for every READ
or WRITE RPC. This patchset allows us to cache those open files more or
less indefinitely, and close them out in response to certain vfs-layer
activity (unlinks and setlease attempts primarily).

The first few patches in the series make (small) changes to several
subsystems to enable the caching infrastructure. The tenth patch adds
the cache itself, and then the remaining patches hook the nfsd code
up to the cache. The final patch rips out the raparms cache since it's
no longer needed with these changes.

Again, the most controversial part of the set is probably the changes
to allow normal user processes to use the delayed_fput infrastructure.
Al, if you could weigh in on those, then that would be helpful. We
really do need a way to allow a thread to flush the final fput work
without returning to userland.

Jeff Layton (20):
  list_lru: add list_lru_rotate
  fs: have flush_delayed_fput flush the workqueue job
  fs: add a kerneldoc header to fput
  fs: add fput_queue
  fs: export flush_delayed_fput
  fsnotify: export several symbols
  locks: create a new notifier chain for lease attempts
  nfsd: move include of state.h from trace.c to trace.h
  sunrpc: add a new cache_detail operation for when a cache is flushed
  nfsd: add a new struct file caching facility to nfsd
  nfsd: keep some rudimentary stats on nfsd_file cache
  nfsd: allow filecache open to skip fh_verify check
  nfsd: hook up nfsd_write to the new nfsd_file cache
  nfsd: hook up nfsd_read to the nfsd_file cache
  nfsd: hook nfsd_commit up to the nfsd_file cache
  nfsd: convert nfs4_file->fi_fds array to use nfsd_files
  nfsd: have nfsd_test_lock use the nfsd_file cache
  nfsd: convert fi_deleg_file and ls_file fields to nfsd_file
  nfsd: hook up nfs4_preprocess_stateid_op to the nfsd_file cache
  nfsd: rip out the raparms cache

 fs/file_table.c              |  76 +++++-
 fs/locks.c                   |  37 +++
 fs/nfsd/Kconfig              |   2 +
 fs/nfsd/Makefile             |   3 +-
 fs/nfsd/export.c             |  14 +
 fs/nfsd/filecache.c          | 613 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/filecache.h          |  38 +++
 fs/nfsd/nfs3proc.c           |   2 +-
 fs/nfsd/nfs4layouts.c        |  12 +-
 fs/nfsd/nfs4proc.c           |  32 +--
 fs/nfsd/nfs4state.c          | 174 ++++++------
 fs/nfsd/nfs4xdr.c            |  16 +-
 fs/nfsd/nfsctl.c             |  10 +
 fs/nfsd/nfsproc.c            |   2 +-
 fs/nfsd/nfssvc.c             |  16 +-
 fs/nfsd/state.h              |  10 +-
 fs/nfsd/trace.c              |   2 -
 fs/nfsd/trace.h              | 129 +++++++++
 fs/nfsd/vfs.c                | 269 +++++--------------
 fs/nfsd/vfs.h                |  11 +-
 fs/nfsd/xdr4.h               |  15 +-
 fs/notify/group.c            |   2 +
 fs/notify/mark.c             |   3 +
 include/linux/file.h         |   1 +
 include/linux/fs.h           |   1 +
 include/linux/list_lru.h     |  13 +
 include/linux/sunrpc/cache.h |   1 +
 mm/list_lru.c                |  15 ++
 net/sunrpc/cache.c           |   3 +
 29 files changed, 1149 insertions(+), 373 deletions(-)
 create mode 100644 fs/nfsd/filecache.c
 create mode 100644 fs/nfsd/filecache.h

-- 
2.4.3

