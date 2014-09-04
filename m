Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:48590 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaIDMiy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:38:54 -0400
Received: by mail-qa0-f42.google.com with SMTP id dc16so5473632qab.29
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:38:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 00/17] locks: internal lease API overhaul
Date: Thu,  4 Sep 2014 08:38:26 -0400
Message-Id: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- cleanups and fixes in response to HCH's review
- make security_file_set_fowner a void return operation
- consolidate "nosetlease" routines
- remove "deadlock protection" from generic_add_lease routine
- add return value to lm_break op to allow for direct lease removal

The internal "API" for handling leases has a lot of problems. The main
one is that on success it can return a pointer to a lease that sits on
the inode's i_flock list. That pointer is only guaranteed to be valid
until the i_lock is dropped, which makes it a bit dangerous to use.

Also, the i_lock is held over much too much of the code, which
precludes any hope of ever adding proper support for leases to
distributed filesystems.

This patchset is a cleanup and overhaul of the internal lease API, and a
few stray locking-related patches. It fixes a number of problems in that
code and makes an attempt at making that API more sane to use.

The only real consumer of that API is knfsd, but this should make it
easier for others to do so, reduce and clarify the spinlocking involved
in handling leases, and get us a step closer toward allowing lease
implementations that can block.

I'm targeting this work for v3.18. Review would be welcome...

Jeff Layton (17):
  locks: consolidate "nolease" routines
  security: make security_file_set_fowner, f_setown and __f_setown void
    return
  locks: close potential race in lease_get_mtime
  nfsd: fix potential lease memory leak in nfs4_setlease
  locks: generic_delete_lease doesn't need a file_lock at all
  locks: clean up vfs_setlease kerneldoc comments
  nfsd: don't keep a pointer to the lease in nfs4_file
  locks: plumb a "priv" pointer into the setlease routines
  locks: define a lm_setup handler for leases
  locks: move i_lock acquisition into generic_*_lease handlers
  locks: move freeing of leases outside of i_lock
  locks: update Documentation/filesystems with new setlease semantics
  locks: remove i_have_this_lease check from __break_lease
  locks: __break_lease cleanup in preparation of allowing direct removal
    of leases
  locks: give lm_break a return value
  locks: set fl_owner for leases to filp instead of current->files
  locks: clean up comments over fl_owner_t definition

 Documentation/filesystems/Locking |  11 +-
 Documentation/filesystems/vfs.txt |   7 +-
 drivers/net/tun.c                 |   4 +-
 drivers/tty/tty_io.c              |   3 +-
 fs/cifs/cifsfs.c                  |   7 +-
 fs/fcntl.c                        |  21 +--
 fs/gfs2/file.c                    |  22 +--
 fs/libfs.c                        |  18 +++
 fs/locks.c                        | 297 ++++++++++++++++++++------------------
 fs/nfs/file.c                     |  13 +-
 fs/nfs/internal.h                 |   1 -
 fs/nfs/nfs4file.c                 |   2 +-
 fs/nfsd/nfs4state.c               |  44 +++---
 fs/nfsd/state.h                   |   1 -
 fs/notify/dnotify/dnotify.c       |   8 +-
 include/linux/fs.h                |  41 ++++--
 include/linux/security.h          |   8 +-
 include/trace/events/filelock.h   |  14 +-
 net/socket.c                      |   3 +-
 security/capability.c             |   4 +-
 security/security.c               |   2 +-
 security/selinux/hooks.c          |   4 +-
 security/smack/smack_lsm.c        |   3 +-
 23 files changed, 269 insertions(+), 269 deletions(-)

-- 
1.9.3

