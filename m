Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35551 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbbKQLxR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:17 -0500
Received: by qkao63 with SMTP id o63so1673788qka.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:16 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 00/38] Allow NFS filesystems to be reexported via knfsd
Date: Tue, 17 Nov 2015 06:52:22 -0500
Message-Id: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset adds export operations to nfs, so that it can be
reexported via knfsd. You're probably thinking to yourself: "Why on
earth would I want to do such a thing?". I'm glad you asked...

The primary use case here is to allow clients that do not support newer
NFS versions (and in particular, those that don't support pnfs) to
access servers that do not support older NFS versions. Our main interest
is in allowing NFSv4.2 (particularly with pnfs) to be reexported via
NFSv3.

The traditional way of allowing legacy client access is to simply allow
the MDS to support older NFS versions, but handling in-band I/O can be a
fair bit of work for the MDS. By reexporting we can offload that work
onto a different host and allow the MDS to focus on layout handling.

I can also envision this being useful with the pnfs block protocol to
allow access by clients that don't have access to the SAN on which the
block devices live. An admin could designate a separate host on the SAN
as a "portal" and have the external clients mount that host.

The main part of the set is focused on adding an open file cache to
nfsd. NFSv4 has a pretty slow open codepath, so allowing the server to
cache the open files takes the performance from abyssimal to acceptable.

I've posted that portion of the patchset before so it may look familiar
to some folks. Implementing that involves some changes to a few other
vfs-layer subsystems:

fsnotify's SRCU cleanup needs to be converted to use call_srcu, and we
have to add a function to call srcu_barrier on it. This is so we can be
sure that all the fsnotify marks are gone before we tear down their
slabcache. It also needs some symbols exported so that nfsd can use it.

The fput machinery needs a function that allows non-kthreads to queue
the final __fput to the list that kthreads ordinarily use. This is
mainly to allow us to completely close files in advance of a setlease
attempt.

After that swath of patches, there is a pile of NFS client patches that
add the export operations that are necessary to allow it to be
reexported. Most of these are under the aegis of a new
CONFIG_NFS_REEXPORT option (that defaults to 'n'). There are a number of
caveats to reexporting that I've tried to document as well in a new
Documenation/ file.

I know it's ambitious for such a large set, but I'd like to
see this merged in v4.5 if possible. If not, then it would be helpful
to be able to make some progress toward that by getting the fput and
fsnotify changes merged for that release.

Jeff Layton (32):
  nfsd: add new io class tracepoint
  fs: have flush_delayed_fput flush the workqueue job
  fs: add a kerneldoc header to fput
  fs: rename "delayed_fput" infrastructure to "fput_global"
  fs: add fput_global
  fsnotify: fix a sparse warning
  fsnotify: export several symbols
  fsnotify: destroy marks with call_srcu instead of dedicated thread
  fsnotify: add a srcu barrier for fsnotify
  locks: create a new notifier chain for lease attempts
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
  nfsd: add a new EXPORT_OP_NOWCC flag to struct export_operations
  nfsd: allow lockd to be forcibly disabled
  nfsd: add errno mapping for EREMOTEIO
  nfsd: return EREMOTE if we find an S_AUTOMOUNT inode
  nfsd: allow filesystems to opt out of subtree checking
  nfsd: close cached files prior to a REMOVE or RENAME that would
    replace target
  nfsd: retry once in nfsd_open on an -EOPENSTALE return
  nfs4: add NFSv4 LOOKUPP handlers
  nfs: add a get_parent export operation for NFS
  nfs: add a Kconfig option for NFS reexporting and documentation

Peng Tao (6):
  nfsd: close cached file when underlying file systems says no such file
  nfs: replace d_add with d_splice_alias in atomic_open
  nfs: add encode_fh export op
  nfs: add fh_to_dentry export op
  nfs: nfs_fh_to_dentry() make use of inode cache
  nfs: set export ops

 Documentation/filesystems/nfs/Exporting    |  52 ++
 Documentation/filesystems/nfs/reexport.txt |  95 ++++
 fs/file_table.c                            |  94 +++-
 fs/locks.c                                 |  37 ++
 fs/nfs/Kconfig                             |  11 +
 fs/nfs/Makefile                            |   1 +
 fs/nfs/dir.c                               |   2 +-
 fs/nfs/export.c                            | 169 +++++++
 fs/nfs/inode.c                             |  22 +
 fs/nfs/internal.h                          |   2 +
 fs/nfs/nfs4proc.c                          |  49 ++
 fs/nfs/nfs4trace.h                         |  29 ++
 fs/nfs/nfs4xdr.c                           |  73 +++
 fs/nfs/super.c                             |   4 +
 fs/nfsd/Kconfig                            |   2 +
 fs/nfsd/Makefile                           |   3 +-
 fs/nfsd/export.c                           |  20 +
 fs/nfsd/filecache.c                        | 748 +++++++++++++++++++++++++++++
 fs/nfsd/filecache.h                        |  45 ++
 fs/nfsd/nfs3proc.c                         |   2 +-
 fs/nfsd/nfs3xdr.c                          |   7 +-
 fs/nfsd/nfs4layouts.c                      |  12 +-
 fs/nfsd/nfs4proc.c                         |  32 +-
 fs/nfsd/nfs4state.c                        | 174 +++----
 fs/nfsd/nfs4xdr.c                          |  16 +-
 fs/nfsd/nfsctl.c                           |  10 +
 fs/nfsd/nfsfh.c                            |  14 +
 fs/nfsd/nfsfh.h                            |  28 +-
 fs/nfsd/nfsproc.c                          |   4 +-
 fs/nfsd/nfssvc.c                           |  27 +-
 fs/nfsd/state.h                            |  10 +-
 fs/nfsd/trace.h                            | 181 +++++++
 fs/nfsd/vfs.c                              | 423 ++++++++--------
 fs/nfsd/vfs.h                              |  11 +-
 fs/nfsd/xdr4.h                             |  15 +-
 fs/notify/fdinfo.c                         |   2 +-
 fs/notify/group.c                          |   2 +
 fs/notify/inode_mark.c                     |   1 +
 fs/notify/mark.c                           |  77 +--
 include/linux/exportfs.h                   |  12 +
 include/linux/file.h                       |   3 +-
 include/linux/fs.h                         |   1 +
 include/linux/fsnotify_backend.h           |  12 +-
 include/linux/nfs4.h                       |   1 +
 include/linux/nfs_fs.h                     |   1 +
 include/linux/nfs_xdr.h                    |  17 +-
 include/linux/sunrpc/cache.h               |   1 +
 init/main.c                                |   2 +-
 net/sunrpc/cache.c                         |   3 +
 49 files changed, 2105 insertions(+), 454 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/reexport.txt
 create mode 100644 fs/nfs/export.c
 create mode 100644 fs/nfsd/filecache.c
 create mode 100644 fs/nfsd/filecache.h

-- 
2.4.3

