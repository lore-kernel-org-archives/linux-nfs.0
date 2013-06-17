Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998Ab3FQPOd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 11:14:33 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v3 00/13] locks: scalability improvements for file locking
Date: Mon, 17 Jun 2013 11:13:43 -0400
Message-Id: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Summary of Significant Changes:
-------------------------------
v3:
- Change spinlock handling to avoid the need to traverse the global
  blocked_hash when doing output of /proc/locks. This means that the
  fl_block list must continue to be protected by a global lock, but
  the fact that the i_lock is also held in most cases means that we
  can avoid taking it in certain situations.

v2:
- Fix potential races in deadlock detection. Manipulation of global
  blocked_hash and deadlock detection are now atomic. This is a
  little slower than the earlier set, but is provably correct. Also,
  the patch that converts to using the i_lock has been split out from
  most of the other changes. That should make it easier to review, but
  it does leave a potential race in the deadlock detection that is fixed
  up by the following patch. It may make sense to fold patches 7 and 8
  together before merging.

- Add percpu hlists and lglocks for global file_lock_list. This gives
  us some speedup since this list is seldom read.

Abstract (tl;dr version):
-------------------------
This patchset represents an overhaul of the file locking code with an
aim toward improving its scalability and making the code a bit easier to
understand.

Longer version:
---------------
When the BKL was finally ripped out of the kernel in 2010, the strategy
taken for the file locking code was to simply turn it into a new
file_lock_locks spinlock. It was an expedient way to deal with the file
locking code at the time, but having a giant spinlock around all of this
code is clearly not great for scalability. Red Hat has bug reports that
go back into the 2.6.18 era that point to BKL scalability problems in
the file locking code and the file_lock_lock suffers from the same
issues.

This patchset is my first attempt to make this code less dependent on
global locking. The main change is to switch most of the file locking
code to be protected by the inode->i_lock instead of the file_lock_lock.

While that works for most things, there are a couple of global data
structures (lists in the current code) that need a global lock to
protect them. So we still need a global lock in order to deal with
those. The remaining patches are intended to make that global locking
less painful. The big gains are made by turning the blocked_list into a
hashtable, which greatly speeds up the deadlock detection code and
making the file_lock_list percpu.

This is not the first attempt at doing this. The conversion to the
i_lock was originally attempted by Bruce Fields a few years ago. His
approach was NAK'ed since it involved ripping out the deadlock
detection. People also really seem to like /proc/locks for debugging, so
keeping that in is probably worthwhile.

There's more work to be done in this area and this patchset is just a
start. There's a horrible thundering herd problem when a blocking lock
is released, for instance. There was also interest in solving the goofy
"unlock on any close" POSIX lock semantics at this year's LSF. I think
this patchset will help lay the groundwork for those changes as well.

While file locking is not usually considered to be a high-performance
codepath, it *is* an IPC mechanism and I think it behooves us to try to
make it as fast as possible.

I'd like to see this considered for 3.11, but some soak time in -next
would be good. Comments and suggestions welcome.

Performance testing and results:
--------------------------------
In order to measure the benefit of this set, I've written some locking
performance tests that I've made available here:

    git://git.samba.org/jlayton/lockperf.git

Here are the results from the same 32-way, 4 NUMA node machine that I
used to generate the v2 patch results. The first number is the mean
time spent in locking for the test. The number in parenthesis is the
standard deviation.

		3.10.0-rc5-00219-ga2648eb	3.10.0-rc5-00231-g7569869
---------------------------------------------------------------------------
flock01		24119.96 (266.08)		24542.51 (254.89)
flock02		 1345.09  (37.37)		    8.60   (0.31)
posix01		31217.14 (320.91)		24899.20 (254.27)
posix02		 1348.60  (36.83)		   12.70   (0.44)

I wasn't able to reserve the exact same smaller machine for testing this
set, but this one is comparable with 4 CPUs and UMA architecture:

		3.10.0-rc5-00219-ga2648eb	3.10.0-rc5-00231-g7569869
---------------------------------------------------------------------------
flock01		1787.51 (11.23)			1797.75  (9.27)
flock02		 314.90	 (8.84)			  34.87  (2.82)
posix01		1843.43 (11.63)			1880.47 (13.47)
posix02		 325.13  (8.53)			  54.09  (4.02)

I think the conclusion we can draw here is that this patchset it roughly
as fast as the previous one. In addition, the posix02 test saw a vast
increase in performance.

I believe that's mostly due to the fact that with this set I added a
patch that allows the code to avoid taking the global blocked_lock_lock
when waking up waiters if there aren't any. With that, the
blocked_lock_lock never has to be taken at all if there's no contention
for the file_lock (as is the case in the posix02 and flock02 tests).

Jeff Layton (13):
  cifs: use posix_unblock_lock instead of locks_delete_block
  locks: make generic_add_lease and generic_delete_lease static
  locks: comment cleanups and clarifications
  locks: make "added" in __posix_lock_file a bool
  locks: encapsulate the fl_link list handling
  locks: protect most of the file_lock handling with i_lock
  locks: avoid taking global lock if possible when waking up blocked
    waiters
  locks: convert fl_link to a hlist_node
  locks: turn the blocked_list into a hashtable
  locks: add a new "lm_owner_key" lock operation
  locks: give the blocked_hash its own spinlock
  seq_file: add seq_list_*_percpu helpers
  locks: move file_lock_list to a set of percpu hlist_heads and convert
    file_lock_lock to an lglock

 Documentation/filesystems/Locking |   27 +++-
 fs/afs/flock.c                    |    5 +-
 fs/ceph/locks.c                   |    2 +-
 fs/ceph/mds_client.c              |    8 +-
 fs/cifs/cifsfs.c                  |    2 +-
 fs/cifs/file.c                    |   15 +-
 fs/gfs2/file.c                    |    2 +-
 fs/lockd/svclock.c                |   12 ++
 fs/lockd/svcsubs.c                |   12 +-
 fs/locks.c                        |  310 +++++++++++++++++++++++++-----------
 fs/nfs/delegation.c               |   10 +-
 fs/nfs/nfs4state.c                |    8 +-
 fs/nfsd/nfs4state.c               |    8 +-
 fs/seq_file.c                     |   54 +++++++
 include/linux/fs.h                |   38 +++--
 include/linux/seq_file.h          |    6 +
 16 files changed, 365 insertions(+), 154 deletions(-)

