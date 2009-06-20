Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60581 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743AbZFTTgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Jun 2009 15:36:53 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH attempt=3 0/5] NFS private namespace patchset
To: Al Viro <viro@ZenIV.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 20 Jun 2009 15:33:45 -0400
Message-ID: <20090620193344.14142.22774.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following series is a resend of a set of patches that were
originally targetted for inclusion in 2.6.30-rc1. They build upon
Al Viro's "Cache root in nameidata" patches, and add the ability to
create a private mount namespace that is not visible to user
processes.
As stated before, the goal is to allow reuse of vfs_path_lookup() in
order to allow the nfs client to walk down NFSv4 mount paths, and locate
the directory that needs to be mounted.

This version of the patches uninlines the function put_mnt_ns() in order
to avoid the need to export vfsmount_lock, and merges it with
__put_mnt_ns().

Cheers
  Trond

---

Trond Myklebust (5):
      NFS: Correct the NFS mount path when following a referral
      NFS: Fix nfs_path() to always return a '/' at the beginning of the path
      NFSv4: Replace nfs4_path_walk() with VFS path lookup in a private namespace
      VFS: Add VFS helper functions for setting up private namespaces
      VFS: Uninline the function put_mnt_ns()


 fs/namespace.c                |   53 +++++++++--
 fs/nfs/namespace.c            |    5 +
 fs/nfs/super.c                |  202 +++++++++++++++++++++++++++++++++++++----
 include/linux/mnt_namespace.h |   10 --
 4 files changed, 231 insertions(+), 39 deletions(-)

-- 
Signature
