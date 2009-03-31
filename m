From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/4] Allow NFS to use ordinary path lookup when mounting
 NFSv4
Date: Tue, 31 Mar 2009 14:52:12 -0400
Message-ID: <cover.1238525532.git.Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	hch@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series of patches contain a VFS change, and hence I'm sending
them via mail instead of as a git pull. The first two patches have been
posted earlier (see http://thread.gmane.org/gmane.linux.file-systems/29663).

To recap:
The first patch adds VFS support for walking the remote path, using a
temporary mount namespace to represent the server's namespace, so that
symlinks and referrals can be followed across remote filesystem and
server boundaries.
The second patch then uses this VFS helper in the NFSv4 mount code.

The last two patches fix issues with referrals that turned up during testing
at Connectathon.

Please apply after pulling the NFS client git tree as requested earlier today,
or you can pull the full set of changes from
   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git vfs-changes

Cheers
  Trond


Trond Myklebust (4):
  VFS: Add a VFS helper function vfs_remote_path_lookup()
  NFSv4: Use vfs_path_lookup() instead of nfs4_path_walk()
  NFS: Fix nfs_path() to always return a '/' at the beginning of the
    path
  NFS: Correct the NFS mount path when following a referral

 fs/namei.c                    |   75 ++++++++++++++++-
 fs/namespace.c                |   56 ++++++++++--
 fs/nfs/namespace.c            |    5 +
 fs/nfs/super.c                |  192 ++++++++++++++++++++++++++++++++++++-----
 include/linux/mnt_namespace.h |    2 +
 include/linux/namei.h         |    2 +
 include/linux/nsproxy.h       |    1 +
 kernel/nsproxy.c              |   11 +++
 8 files changed, 314 insertions(+), 30 deletions(-)
