Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:35692 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbbHTLR1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:27 -0400
Received: by ykbi184 with SMTP id i184so33650881ykb.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:27 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 00/20] nfsd: open file caching
Date: Thu, 20 Aug 2015 07:17:00 -0400
Message-Id: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

This is the third iteration of the open file cache for knfsd. This one
has some major changes from the last revision. The files are now hashed
on inode pointer instead of the filehandle. An inode can have several
filehandles, and we really only do want to open it once. I've dropped a
lot of the filehandle manipulation patches from the last set since they
are no longer needed here.

I've also removed the recurring workqueue job that cleans out the cache
in favor of a scheme that uses a LRU list and shrinker, plus a new
notifier chain in the lease setting code. With this, knfsd will
basically keep files open indefinitely as long as memory is available
and no one wants to set a lease on the file, or until the exports cache
is flushed. I've dropped most of the changes to the laundry_wq, but
I did leave in the patch that changes it to allow multiple jobs to
run in parallel.

Finally, the other big change is that I've gone ahead and hooked up NFSv4
to use this cache as well. This allows us to finally rip out the raparms
cache which is done in the last patch.

Original cover letter follows:

---------------------[snip]------------------------

Hi Bruce!

This patchset adds a new open file cache for knfsd. As you well know,
nfsd basically does an open() - read/write() - close() cycle for every
nfsv3 READ or WRITE. It's also common for clients to "spray" several
read and write requests in parallel or in quick succession, so we could
skip a lot of that by simply caching these open filps.

The idea here is to cache them in a hashtable for a little while (1s by
default) in the expectation that clients may try to issue more reads or
writes in quick succession. When there are any entries in the hashtable,
there is a recurring workqueue job that will clean the cache.

I've also added some hooks into sunrpc cache code that should allow us
to purge the cache on an unexport event, so this shouldn't cause any
problems with unmounting once you've unexported the fs.

I did a little testing with it, but my test rig is pretty slow, and I
couldn't measure much of a performance difference on a bog standard
local fs.

We do have some patches that allow the reexporting of NFSv4.1 via knfsd.
Since NFS has a relatively slow open routine, this provides a rather
large speedup.

Without these patches:
$ dd if=/dev/urandom of=/mnt/dp01/ddfile bs=4k count=256 oflag=direct
256+0 records in
256+0 records out
1048576 bytes (1.0 MB) copied, 54.3109 s, 19.3 kB/s

With these patches:
$ dd if=/dev/urandom of=/mnt/dp01/ddfile bs=4k count=256 oflag=direct
256+0 records in
256+0 records out
1048576 bytes (1.0 MB) copied, 1.05437 s, 995 kB/s

It should also be possible to hook this code up to the nfs4_file too,
but I haven't done that in this set. I'd like to get this in and settled
before we start looking at that, since it'll mean a bit of reengineering
of the NFSv4 code not to pass around struct file pointers.

I'd like to have these considered for the v4.3 merge window if they look
reasonable.

Jeff Layton (20):
  nfsd: allow more than one laundry job to run at a time
  nfsd: add a new struct file caching facility to nfsd
  list_lru: add list_lru_rotate
  nfsd: add a LRU list for nfsd_files
  nfsd: add a shrinker to the nfsd_file cache
  locks/nfsd: create a new notifier chain for lease attempts
  nfsd: hook up nfsd_write to the new nfsd_file cache
  nfsd: hook up nfsd_read to the nfsd_file cache
  sunrpc: add a new cache_detail operation for when a cache is flushed
  nfsd: handle NFSD_MAY_NOT_BREAK_LEASE in open file cache
  nfsd: hook nfsd_commit up to the nfsd_file cache
  nfsd: move include of state.h from trace.c to trace.h
  nfsd: add new tracepoints for nfsd_file cache
  nfsd: close cached files prior to a REMOVE or RENAME that would
    replace target
  nfsd: call flush_delayed_fput from nfsd_file_close_fh
  nfsd: convert nfs4_file->fi_fds array to use nfsd_files
  nfsd: have nfsd_test_lock use the nfsd_file cache
  nfsd: convert fi_deleg_file and ls_file fields to nfsd_file
  nfsd: hook up nfs4_preprocess_stateid_op to the nfsd_file cache
  nfsd: rip out the raparms cache

 fs/file_table.c              |   1 +
 fs/locks.c                   |  15 ++
 fs/nfsd/Makefile             |   3 +-
 fs/nfsd/filecache.c          | 465 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/filecache.h          |  33 +++
 fs/nfsd/nfs3proc.c           |   2 +-
 fs/nfsd/nfs4layouts.c        |  12 +-
 fs/nfsd/nfs4proc.c           |  32 +--
 fs/nfsd/nfs4state.c          | 178 ++++++++---------
 fs/nfsd/nfs4xdr.c            |  16 +-
 fs/nfsd/nfsproc.c            |   2 +-
 fs/nfsd/nfssvc.c             |  16 +-
 fs/nfsd/state.h              |  10 +-
 fs/nfsd/trace.c              |   2 -
 fs/nfsd/trace.h              | 118 +++++++++++
 fs/nfsd/vfs.c                | 282 ++++++++------------------
 fs/nfsd/vfs.h                |   8 +-
 fs/nfsd/xdr4.h               |  15 +-
 include/linux/fs.h           |   1 +
 include/linux/list_lru.h     |  13 ++
 include/linux/sunrpc/cache.h |   1 +
 mm/list_lru.c                |  15 ++
 net/sunrpc/cache.c           |   3 +
 23 files changed, 886 insertions(+), 357 deletions(-)
 create mode 100644 fs/nfsd/filecache.c
 create mode 100644 fs/nfsd/filecache.h

-- 
2.4.3

