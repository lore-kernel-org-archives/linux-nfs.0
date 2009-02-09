From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [RFC PATCH 0/2] Add VFS support for looking up paths on remote
 servers using a temporary mount namespace
Date: Mon, 09 Feb 2009 13:45:34 -0500
Message-ID: <20090209184534.23040.82605.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following two patches attempt to improve NFSv4's ability to look up
the mount path on a remote server.

The first patch adds VFS support for walking the remote path, using a
temporary mount namespace to represent the server's namespace, so that
symlinks and referrals can be followed across remote filesystem and
server boundaries.
The second patch then uses this VFS helper in the NFSv4 mount code.

A later set of patches will clean out the legacy nfs4_path_walk, however
I'm hoping for some commentary from the VFS folks on whether or not this
approach is acceptable before I continue.

Cheers
  Trond

---

Trond Myklebust (2):
      NFSv4: Use vfs_path_lookup() instead of nfs4_path_walk()
      VFS: Add a VFS helper function vfs_remote_path_lookup()


 fs/namei.c                    |   75 ++++++++++++++++++++-
 fs/namespace.c                |   56 +++++++++++++--
 fs/nfs/super.c                |  149 +++++++++++++++++++++++++++++++++++------
 include/linux/mnt_namespace.h |    2 +
 include/linux/namei.h         |    2 +
 include/linux/nsproxy.h       |    1 
 kernel/nsproxy.c              |   11 +++
 7 files changed, 267 insertions(+), 29 deletions(-)

-- 
Signature
