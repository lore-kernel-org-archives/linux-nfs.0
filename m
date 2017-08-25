Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38312 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755253AbdHYVwj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 17:52:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/3] Eliminate delegation self-conflicts
Date: Fri, 25 Aug 2017 17:52:35 -0400
Message-Id: <1503697958-6122-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is my attempt to fix the NFS server so we don't unnecessarily
recall delegations when the operation breaking the delegation comes from
the same client that holds the delegation.

To do that we need some way to pass the identity of the breaker down
through the VFS.

I didn't feel like adding another argument to all the VFS functions that
this might need to be passed down through.  But all of those functions
already take a struct inode **delegated inode, so instead I turned that
into a single-member struct deleg_ctrl *, which I then added a second
member to.

I dunno, welcome any more straightforward ways of doing this if anyone
has suggestions.

My first attempt was to do this by instead checking for conflicts in the
caller (nfsd) and then passing down one just one bit telling the lease
code conflicts had already been checked so it didn't need to.  But
that's much too early to check for conflicts, since the caller doesn't
have the necessary inode locks yet.

I'm still missing testing.  Regression tests pass, but I haven't
actually confirmed that the self-conflicts are gone!  Off to go hack on
pynfs....

--b.

J. Bruce Fields (3):
  fs: cleanup to hide some details of delegation logic
  fs: hide another detail of delegation logic
  nfsd: clients don't need to break their own delegations

 Documentation/filesystems/Locking |  2 ++
 fs/attr.c                         | 10 +++---
 fs/locks.c                        |  7 +++-
 fs/namei.c                        | 70 ++++++++++++++++++---------------------
 fs/nfsd/nfs4state.c               | 40 ++++++++++++++++++++++
 fs/nfsd/vfs.c                     | 26 ++++++++++++---
 fs/open.c                         | 24 ++++++--------
 fs/utimes.c                       | 12 +++----
 include/linux/fs.h                | 61 +++++++++++++++++++++-------------
 9 files changed, 159 insertions(+), 93 deletions(-)

-- 
2.13.5

