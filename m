Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Thu, 13 Oct 2016 15:26:47 +1100
Subject: [PATCH 0/6] NFSv4: Fix stateid used when flock locks in use. - V2
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <147633263771.766.17853370901003798934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

Thanks to prompting from Jeff I discovered that I could
access the correct open-state when ftrunctate() is being used.
That improves the setattr handling, removing some special cases.

This series is based on the linux-next branch of
	git://git.linux-nfs.org/projects/anna/linux-nfs.git

NeilBrown

---

NeilBrown (6):
      NFS: remove l_pid field from nfs_lockowner
      NFSv4: add flock_owner to open context
      NFSv4: change nfs4_do_setattr to take an open_context instead of a nfs4_state.
      NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner
      NFSv4: enhance nfs4_copy_lock_stateid to use a flock stateid if there is one
      NFS: discard nfs_lockowner structure.


 fs/nfs/dir.c           |    6 +++---
 fs/nfs/inode.c         |   14 +++++++-------
 fs/nfs/nfs4_fs.h       |    2 +-
 fs/nfs/nfs4file.c      |    2 +-
 fs/nfs/nfs4proc.c      |   44 +++++++++++++++++++-------------------------
 fs/nfs/nfs4state.c     |   25 ++++++++++++++-----------
 fs/nfs/pagelist.c      |    3 +--
 fs/nfs/write.c         |    3 +--
 include/linux/nfs_fs.h |   10 +++-------
 9 files changed, 50 insertions(+), 59 deletions(-)

--
Signature
