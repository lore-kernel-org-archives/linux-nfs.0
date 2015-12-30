Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752AbbL3NOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Dec 2015 08:14:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 00/10] locking fixups for NFS
Date: Wed, 30 Dec 2015 08:13:56 -0500
Message-Id: <cover.1451480826.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This set addresses a few NFS related locking issues as well as a couple
minor cleanups.  It does a bit of plumbing to make sure we can complete
unlocks after close when the fl_file may be unavailable, and it attempts to
always release locks even when a wait for oustanding IO is interrupted
before sending an unlock.  This can orphan a lock on a server, which might
mean a delay for matching lock NFS4, or require a server restart to clean up
that lock for NFS3.

Change for v4:
	- combine tests for fl_type into single switch on 02/10

Change for v3:
	- update a comment on open mode checking for flock() locks

Changes for v2:
	- the change to move do_vfs_lock() to a shared inline has been removed
	- added patch to set FL_CLOSE for flock unlock on close (08/10)
	- instead of keeping a copied list of deferred file_locks to unlock,
	  just send an unlock for the entire file if FL_CLOSE is set.


Benjamin Coddington (10):
  NFS4: remove a redundant lock range check
  NFS: Move the flock open mode check into nfs_flock()
  NFS: Pass nfs_open_context instead of file to the lock procs
  NFSv4: Pass nfs_open_context instead of nfs4_state to
    nfs4_proc_unlck()
  lockd: Plumb nfs_open_context into nlm client unlock
  lockd: Send the inode to nlmclnt_setlockargs()
  lockd: do_vfs_lock() only needs the inode
  locks: Set FL_CLOSE when removing flock locks on close()
  NFS: Deferred unlocks - always unlock on FL_CLOSE
  NFS: cleanup do_vfs_lock()

 fs/lockd/clntproc.c        |   41 ++++++++++++++++---------------
 fs/locks.c                 |    2 +-
 fs/nfs/file.c              |   58 ++++++++++++++++++++++++++++++++-----------
 fs/nfs/inode.c             |   22 ++++++++++++++++
 fs/nfs/nfs3proc.c          |    6 +---
 fs/nfs/nfs4proc.c          |   45 ++++++++++------------------------
 fs/nfs/pagelist.c          |    8 ++++-
 fs/nfs/proc.c              |    6 +---
 include/linux/lockd/bind.h |    3 +-
 include/linux/nfs_fs.h     |    3 ++
 include/linux/nfs_xdr.h    |    2 +-
 11 files changed, 116 insertions(+), 80 deletions(-)

