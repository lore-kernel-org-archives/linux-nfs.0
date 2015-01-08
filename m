Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:44279 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278AbbAHSem (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 13:34:42 -0500
Received: by mail-qc0-f177.google.com with SMTP id x3so3651409qcv.8
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 10:34:40 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        hch@infradead.org
Subject: [PATCH v2 00/10] locks: saner method for managing file locks
Date: Thu,  8 Jan 2015 10:34:15 -0800
Message-Id: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- bugfix to the flc_posix list ordering that broke the split/merge code
- don't use i_lock to manage the i_flctx pointer. Do so locklessly
  via cmpxchg().
- reordering of the patches to make the set bisectable. As a result
  the new spinlock is not introduced until near the end of the set
- some cleanup of the lm_change operation was added, made possible
  by the move to standard list_heads for tracking locks
- it takes greater pains to avoid spinlocking by checking when the
  lists are empty in addition to whether the i_flctx pointer is NULL
- a patch was added to keep count of the number of locks, so we can
  avoid having to do count/alloc/populate in ceph and cifs

This is the second iteration of this patchset. The first was posted
back in September under the cover letter:

    [RFC PATCH 00/12] locks: saner method for managing file locks

I see this code as a good start for bringing sanity to the file locking
code.  One of the nice things about moving to separate lists for
different types of locks is that we can eventually move to using
different structures for different types of locks.

For instance, there's no need to keep track of ranges in a flock lock or
lease, and there are a number of lease specific fields that are of
little interest to other lock types.  I haven't taken that step in this
set, but I'd eventually like to make that sort of change later.

This code is only lightly tested, but it seems to work fine with local
filesystems, nfs (client and server) and cifs. I don't have a great way
to test the ceph changes, but they're pretty straightforward. I'll plan
to push this into linux-next soon with an eye toward merge in 3.20
unless there are objections.

Cover letter from the original RFC posting follows:

------------------------[snip]-------------------------

We currently manage all file_locks via a singly-linked list. This is
problematic for a number of reasons:

- we have to protect all file locks with the same spinlock (or
  equivalent). Currently that uses the i_lock, but Christoph has voiced
  objections due to the potential for contention with other i_lock
  users. He'd like to see us move to using a different lock.

- we have to walk through irrelevant file locks in order to get to the
  ones we're interested in. For instance, POSIX locks are at the end
  of the list, so we have to skip over all of the flock locks and
  leases before we can work with them.

- the singly-linked list is primitive and difficult to work with. We
  have to keep track of the "before" pointer and it's easy to get that
  wrong.

Cleaning all of this up is complicated by the fact that no one really
wants to grow struct inode in order to do so. We have a single pointer
in the inode now and I don't think we want to use any more.

One possibility that Trond raised was to move this to an hlist, but
that doesn't do anything about the desire for a new spinlock.

This patchset takes the approach of replacing the i_flock list with a
new struct file_lock_context that is allocated when we intend to add a
new file lock to an inode. The file_lock_context is only freed when we
destroy the inode.

Within that, we have separate (and standard!) lists for each lock type,
and a dedicated spinlock for managing those lists. In principle we could
even consider adding separate locks for each, but I didn't bother with
that for now.

For now, the code is still pretty "raw" and isn't bisectable. This is
just a RFC for the basic approach. This is probably v3.19 material at
best.

Anyone have thoughts or comments on the basic approach?

clone of "locks-3.18"

Jeff Layton (10):
  locks: add new struct list_head to struct file_lock
  locks: have locks_release_file use flock_lock_file to release generic
    flock locks
  locks: add a new struct file_locking_context pointer to struct inode
  locks: move flock locks to file_lock_context
  locks: convert posix locks to file_lock_context
  locks: convert lease handling to file_lock_context
  locks: remove i_flock field from struct inode
  locks: add a dedicated spinlock to protect i_flctx lists
  locks: clean up the lm_change prototype
  locks: keep a count of locks on the flctx lists

 fs/ceph/locks.c      |  65 +++---
 fs/ceph/mds_client.c |   4 -
 fs/cifs/file.c       |  34 ++--
 fs/inode.c           |   3 +-
 fs/lockd/svcsubs.c   |  26 ++-
 fs/locks.c           | 542 +++++++++++++++++++++++++++------------------------
 fs/nfs/delegation.c  |  23 ++-
 fs/nfs/nfs4state.c   |  23 ++-
 fs/nfs/pagelist.c    |   5 +-
 fs/nfs/write.c       |  37 +++-
 fs/nfsd/nfs4state.c  |  20 +-
 fs/read_write.c      |   2 +-
 include/linux/fs.h   |  34 +++-
 13 files changed, 449 insertions(+), 369 deletions(-)

-- 
2.1.0

