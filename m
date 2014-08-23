Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:50573 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbaHWOl2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 10:41:28 -0400
Received: by mail-qa0-f45.google.com with SMTP id cm18so10622603qab.18
        for <linux-nfs@vger.kernel.org>; Sat, 23 Aug 2014 07:41:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: bfields@fieldses.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 00/10] locks/nfsd: internal lease API overhaul
Date: Sat, 23 Aug 2014 10:41:08 -0400
Message-Id: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The internal "API" for handling leases has a lot of problems. The main
one is that on success it can return a pointer to a lease that sits on
the inode's i_flock list. That pointer is only guaranteed to be valid
until the i_lock is dropped, which makes it a bit dangerous to use.

Also, the i_lock is held over much too much of the code, which
precludes any hope of ever adding proper support for leases to
distributed filesystems.

This patchset is a cleanup and overhaul of the internal lease API. It
fixes a number of problems in that code and makes an attempt at making
that API more sane to use.

The only real consumer of that API is knfsd, but this should make it
easier for others to do so, reduce and clarify the spinlocking involved
in handling leases, and get us a step closer toward allowing lease
implementations that can block.

I'm targeting this work for v3.18. Review would be welcome...

Jeff Layton (10):
  locks: close potential race in lease_get_mtime
  nfsd: fix potential lease memory leak in nfs4_setlease
  locks: generic_delete_lease doesn't need a file_lock at all
  locks: clean up vfs_setlease kerneldoc comments
  nfsd: don't keep a pointer to the lease in nfs4_file
  locks: plumb an "aux" pointer into the setlease routines
  locks: define a lm_setup handler for leases
  locks: move i_lock acquisition into generic_*_lease handlers
  locks: move freeing of leases outside of i_lock
  locks: update Documentation/filesystems with lease API changes

 Documentation/filesystems/Locking |  21 ++--
 Documentation/filesystems/vfs.txt |   7 +-
 fs/cifs/cifsfs.c                  |   7 +-
 fs/gfs2/file.c                    |   3 +-
 fs/locks.c                        | 237 +++++++++++++++++++++-----------------
 fs/nfs/file.c                     |   2 +-
 fs/nfs/internal.h                 |   2 +-
 fs/nfsd/nfs4state.c               |  24 ++--
 fs/nfsd/state.h                   |   1 -
 include/linux/fs.h                |  18 +--
 10 files changed, 172 insertions(+), 150 deletions(-)

-- 
1.9.3

