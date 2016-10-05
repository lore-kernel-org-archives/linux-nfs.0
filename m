Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Wed, 05 Oct 2016 17:15:31 +1100
Subject: [PATCH/RFC 0/3] NFSv4: Fix stateid used when flock locks in use.
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147564712849.1201.16474326551460993904.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

As mentioned in a previous email, NFSv4 currently uses the wrong
stateid when a 'flock' lock is active.
It should use the stateid returned for the LOCK request, but it
actually uses the stateid returned by the OPEN request.
If a server implements mandatory locks, this causes an error on
read/write requests.

This is a regression introduced by
 Commit: 8003d3c4aaa5 ("nfs4: treat lock owners as opaque values")

This patch set fixes the problem but is not perfect.

I added a second 'nfs_lock_context' to 'struct nfs_open_context'
to represent the flock context.
Only the lockowner.l_owner field of this nfs_lock_context is used,
so we could get away with only adding a 'fl_owner_t flock_owner'
field.  I left the full nfs_lock_context as I wasn't sure about
the io_count field...

I haven't made any changes to the ->io_count handling.  This is
because it isn't at all clear to me that the current code is correct.

I assume the io_count tracking is there to ensure that we don't
unlock a lock while there are outstanding reads that might be using
the stateid - there shouldn't be any writes because we just called
fsync.

However I see two problems:
1/ the io_count is per-process and per-'struct file'.  It is quite
  possible for a process to open the same file twice, so it has
  two 'struct file' on the same file, and thus two nfs_open_context
  and two nfs_lock_context, and two io_count.  Both of these would
  use the one per-process/per-inode stateid.
  Waiting for one io_count to reach zero doesn't help if the other
  io_count is not zero.

2/ I cannot see any locking that would prevent the stateid from
   being used again (e.g. by another thread) immediately after
   the call to nfs_iocounter_wait().

I wonder if the io_count should be attached to the nfs4_lock_state
rather than the nfs_lock_context???
Maybe I am misunderstanding the whole point of io_count, but in any
case I did not think I could make any useful changes there, so I
haven't.

I haven't considered how these changes interact with OFD locks.
They might just transparently start working once flock locks
are working again.  Of course we still have the issue that
if a process has a Posix lock on one byte-range and an OFD lock
on another byte range, then that is difficult to cope with.
I doubt the value for "fixing" this is worth the cost.

Comments very welcome.

Thanks,
NeilBrown


---

NeilBrown (3):
      NFSv4: add flock_context to open context
      NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner
      NFSv4: enhance nfs4_copy_lock_stateid to use a flock stateid if there is one


 fs/nfs/dir.c           |    6 +++---
 fs/nfs/inode.c         |   16 ++++++++++++++--
 fs/nfs/nfs4_fs.h       |    2 +-
 fs/nfs/nfs4file.c      |    2 +-
 fs/nfs/nfs4proc.c      |   12 +++---------
 fs/nfs/nfs4state.c     |   34 +++++++++++++++++++++-------------
 include/linux/nfs_fs.h |    3 ++-
 7 files changed, 45 insertions(+), 30 deletions(-)

--
Signature
