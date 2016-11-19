Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Address readdirplus performance
Date: Sat, 19 Nov 2016 11:54:54 -0500
Message-Id: <1479574497-38268-1-git-send-email-trond.myklebust@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

Attempt to address two performance issues:
1) The regression pointed out by Ben when doing 'ls -l' on a directory
   that is being modified.
2) When using readdir() to iterate through a directory, avoid lookups
   using the same method we use to avoid attribute revalidation.

The last patch is a cleanup.

Trond Myklebust (3):
  NFS: Fix a performance regression in readdir
  NFS: Be more targeted about readdirplus use when doing
    lookup/revalidation
  NFS: Replace nfs_force_use_readdirplus() with
    nfs_advise_use_readdirplus()

 fs/nfs/dir.c      | 47 ++++++++++++++---------------------------------
 fs/nfs/inode.c    |  2 +-
 fs/nfs/internal.h |  2 +-
 3 files changed, 16 insertions(+), 35 deletions(-)

-- 
2.7.4
