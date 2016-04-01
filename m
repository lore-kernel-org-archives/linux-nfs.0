Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298AbcDARRi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 13:17:38 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3 V2] Include OFD lock owners when looking up state
Date: Fri,  1 Apr 2016 13:17:34 -0400
Message-Id: <cover.1459530606.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client sends IO only under the open stateid when using OFD (and flock)
locking instead of the appropriate lock stateid because the nfs_lock_context
only tracks POSIX lockowners, which is the reference to the process' file
table.

This is a problem for two reasons.  The first is that rfc7530,
section-9.1.4.5 states that IO sent by an entity corresponding to the
lock-owner which holds a byte-range lock should be sent under the lock
stateid for that lock.  Otherwise, a server enforcing mandatory byte-range
locking might reject that operation.  Secondly, not tracking OFD lock owners
means that accounting for IO sent under those owners is broken.  That
creates a problem for some work to guarantee an unlock will be sent after
operations scheduled under a lock complete.

To fix this, this set starts tracking the OFD lock owner within the
nfs_lock_context.  Unique nfs_lock_contexts are created on distinct
combinations of current->files, struct file, and pid.  In order to do this,
some re-arrangement of when to create or lookup the nfs_lock_context was
needed since the struct file pointer must be included during that creation
or lookup.

It is possible for a process to hold both an OFD and a POSIX lock on a file
as long as they do not conflict.  There would be two stateids that could be
selected for IO operations on that file.  In that case only the first
stateid found to match the current lock context will ever be used.  The
result of this is that mixed OFD and POSIX locks within the same process on
a server enforcing mandatory locking should be avoided.  The fix for this
probably would require a byte-range lookup of stateid when scheduling an IO
operation, and the ability to split IO that crossed lock ranges with
different owners.

Comments and critique is welcomed.

V2: fix a rebase mistake that broke builds of 1/3 and 2/3.

Benjamin Coddington (3):
  NFS: add get_nfs_lock_context, find_nfs_lock_context
  NFS: add OFD lock owners to nfs_lock_context
  NFSv4: use OFD lock owners in lock state lookup

 fs/nfs/direct.c          |    8 ++++----
 fs/nfs/file.c            |    2 +-
 fs/nfs/fscache-index.c   |    4 ++--
 fs/nfs/fscache.h         |   12 ++++++------
 fs/nfs/inode.c           |   32 ++++++++++++++++++++++----------
 fs/nfs/nfs42proc.c       |    8 ++++----
 fs/nfs/nfs4proc.c        |    3 ++-
 fs/nfs/nfs4state.c       |   21 ++++++++++++---------
 fs/nfs/pagelist.c        |   22 ++++++++--------------
 fs/nfs/read.c            |   38 +++++++++++++++++++++++---------------
 fs/nfs/write.c           |   17 ++++++++++-------
 include/linux/nfs_fs.h   |    8 +++++---
 include/linux/nfs_page.h |    2 +-
 13 files changed, 100 insertions(+), 77 deletions(-)

