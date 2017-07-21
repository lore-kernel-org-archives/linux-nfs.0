Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:43556 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753111AbdGUUel (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 16:34:41 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull NFS client fixes for 4.13
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Message-ID: <d339dd77-a96c-ad9a-17e2-7dacdfd2eb67@Netapp.com>
Date: Fri, 21 Jul 2017 16:34:35 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 5b5faaf6df73412af0278997db36dbcb51011d9d:

  nfs4: add NFSv4 LOOKUPP handlers (2017-07-13 16:00:15 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-2

for you to fetch changes up to 1ebf980127924c639e2b85c08468311ba1c95b70:

  NFS/filelayout: Fix racy setting of fl->dsaddr in filelayout_check_deviceid() (2017-07-21 14:08:45 -0400)

----------------------------------------------------------------
Stable bugfixes:
- Fix error reporting regression

Bugfixes:
- Fix setting filelayout ds address race
- Fix subtle access bug when using ACLs
- Fix setting mnt3_counts array size
- Fix a couple of pNFS commit races

gpg claims it was able to sync my key with the keyserver, so hopefully
you're able to update it now.  Have a good weekend!

Anna

----------------------------------------------------------------
Eryu Guan (1):
      nfs: count correct array for mnt3_counts array size

NeilBrown (1):
      net/sunrpc/xprt_sock: fix regression in connection error reporting.

Peng Tao (1):
      nfs: add export operations

Steve Dickson (1):
      mount: copy the port field into the cloned nfs_server structure.

Trond Myklebust (10):
      NFS: Don't run wake_up_bit() when nobody is waiting...
      NFS: Fix a COMMIT race in pNFS
      NFS: Fix another COMMIT race in pNFS
      pNFS/flexfiles: Handle expired layout segments in ff_layout_initiate_commit()
      Revert commit 722f0b891198 ("pNFS: Don't send COMMITs to the DSes if...")
      NFS: Refactor NFS access to kernel access mask calculation
      NFSv3: Convert nfs3_proc_access() to use nfs_access_set_mask()
      NFS: Store the raw NFS access mask in the inode's access cache
      NFS: Be more careful about mapping file permissions
      NFS/filelayout: Fix racy setting of fl->dsaddr in filelayout_check_deviceid()

 fs/nfs/Makefile                        |   2 +-
 fs/nfs/client.c                        |   1 +
 fs/nfs/dir.c                           |  47 +++++++--
 fs/nfs/export.c                        | 177 +++++++++++++++++++++++++++++++++
 fs/nfs/filelayout/filelayout.c         |  13 ++-
 fs/nfs/flexfilelayout/flexfilelayout.c |   4 +
 fs/nfs/internal.h                      |   2 +
 fs/nfs/mount_clnt.c                    |   2 +-
 fs/nfs/nfs3proc.c                      |  11 +-
 fs/nfs/pagelist.c                      |  17 +++-
 fs/nfs/pnfs_nfs.c                      |  24 +++--
 fs/nfs/super.c                         |   2 +
 include/linux/nfs_fs.h                 |   2 +-
 include/linux/nfs_page.h               |   2 +
 net/sunrpc/xprtsock.c                  |   2 +
 15 files changed, 272 insertions(+), 36 deletions(-)
 create mode 100644 fs/nfs/export.c
