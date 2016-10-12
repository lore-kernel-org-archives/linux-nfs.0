Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Wed, 12 Oct 2016 13:39:18 +1100
Subject: [PATCH 0/5] NFSv4: Fix stateid used when flock locks in use.
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147623977637.19592.12766016823334433969.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

I received no comments for my RFC series I sent a week ago, so I'll
assume no-one objects :-)

I've revised the series a little.  In particular I just add a
lockowner rather than a whole nfs_lock_context to the open_context.
I've also added to patches which combine to remove the nfs_lockowner
structure.

I think this is ready to be queued for -next

Thanks,
NeilBrown


---

NeilBrown (5):
      NFS: remove l_pid field from nfs_lockowner
      NFSv4: add flock_owner to open context
      NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner
      NFSv4: enhance nfs4_copy_lock_stateid to use a flock stateid if there is one
      NFS: discard nfs_lockowner structure.


 fs/nfs/dir.c           |    6 +++---
 fs/nfs/inode.c         |   14 +++++++-------
 fs/nfs/nfs4_fs.h       |    2 +-
 fs/nfs/nfs4file.c      |    2 +-
 fs/nfs/nfs4proc.c      |   14 +++-----------
 fs/nfs/nfs4state.c     |   34 +++++++++++++++++++++-------------
 fs/nfs/pagelist.c      |    3 +--
 fs/nfs/write.c         |    3 +--
 include/linux/nfs_fs.h |   10 +++-------
 9 files changed, 41 insertions(+), 47 deletions(-)

--
Signature
