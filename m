From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/4] NFS private namespace patchset
Date: Thu, 18 Jun 2009 12:25:00 -0700
Message-ID: <20090618192500.19433.16770.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series is a resend of a set of patches that were originally
targetted for inclusion in 2.6.30-rc1. They build upon Al Viro's "Cache
root in nameidata" patches, and add the ability to create a private
mount namespace that is not visible to user processes.

As stated before, the goal is to allow reuse of vfs_path_lookup() in
order to allow the nfs client to walk down NFSv4 mount paths, and locate
the directory that needs to be mounted.

Cheers
  Trond

---

Trond Myklebust (4):
      NFS: Correct the NFS mount path when following a referral
      NFS: Fix nfs_path() to always return a '/' at the beginning of the path
      NFSv4: Replace nfs4_path_walk() with VFS path lookup in a private namespace
      VFS: Add VFS helper functions for setting up private namespaces


 fs/namespace.c                |   46 ++++++++-
 fs/nfs/namespace.c            |    5 +
 fs/nfs/super.c                |  202 +++++++++++++++++++++++++++++++++++++----
 include/linux/mnt_namespace.h |    1 
 4 files changed, 225 insertions(+), 29 deletions(-)

-- 
Signature
