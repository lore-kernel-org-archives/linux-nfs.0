Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753389AbbJNSXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2015 14:23:39 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@poochiereds.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Subject: [PATCH 00/10] locking fixups for NFS
Date: Wed, 14 Oct 2015 14:23:27 -0400
Message-Id: <cover.1444846590.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This set addresses a few NFS related locking issues as well as a couple
minor cleanups.  It does a bit of plumbing to make sure we can complete
unlocks after close when the fl_file may be unavailable, and it attempts to
always release locks even when a wait for oustanding IO is interrupted
before sending an unlock.  This can orphan a lock on a server, which might
mean a delay for matching lock NFS4, or require a server restart to clean up
that lock for NFS3.

Benjamin Coddington (10):
  NFS: keep nfs4_state for nfs4_lock_state cleanup
  NFS4: remove a redundant lock range checks
  NFS: Move the flock open mode check into nfs_flock()
  NFS: Pass nfs_open_context instead of file to the lock procs
  NFSv4: Pass nfs_open_context instead of nfs4_state to
    nfs4_proc_unlck()
  lockd: Plumb nfs_open_context into nlm client unlock
  lockd: Send the inode to nlmclnt_setlockargs()
  NFS: Move do_vfs_lock to shared inline
  locks: Use more file_inode and fix a comment
  NFS: Deferred unlocks - always unlock on FL_CLOSE

 fs/lockd/clntproc.c        |   50 +++++++++++-------------------
 fs/locks.c                 |    8 ++---
 fs/nfs/file.c              |   72 +++++++++++++++++++++++++++++++++-----------
 fs/nfs/inode.c             |    1 +
 fs/nfs/nfs3proc.c          |    6 +--
 fs/nfs/nfs4proc.c          |   43 +++-----------------------
 fs/nfs/nfs4state.c         |    2 +
 fs/nfs/pagelist.c          |   23 ++++++++++++--
 fs/nfs/proc.c              |    6 +--
 include/linux/fs.h         |   16 ++++++++++
 include/linux/lockd/bind.h |    3 +-
 include/linux/nfs_fs.h     |    7 ++++
 include/linux/nfs_xdr.h    |    2 +-
 13 files changed, 134 insertions(+), 105 deletions(-)

