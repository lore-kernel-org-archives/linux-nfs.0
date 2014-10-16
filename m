Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f173.google.com ([209.85.212.173]:58528 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbaJPJFV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 05:05:21 -0400
Received: by mail-wi0-f173.google.com with SMTP id fb4so875951wid.6
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 02:05:19 -0700 (PDT)
Message-ID: <1413450315.4062.4.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client bugfixes and SEEK_HOLE/SEEK_DATA
 feature
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Thu, 16 Oct 2014 12:05:15 +0300
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 72c23f0819977d37924af92a42a9b7fbfd1c95d8:

  Merge branch 'bugfixes' into linux-next (2014-09-30 17:21:41 -0400)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.18-2

for you to fetch changes up to b8fb9c30f25e45dab5d2cd310ab6913b6861d00f:

  NFS: Fix a bogus warning in nfs_generic_pgio (2014-10-13 11:04:02 -0400)

Note the tree does include a partial merge of Bruce's tree. That was
done in order to resolve an include file dependency issue for the SEEK
patch.

Cheers
  Trond

----------------------------------------------------------------
NFS client updates for Linux 3.18

Highlights include:

Stable fixes:
- Fix an uninitialised pointer Oops in the writeback error path
- Fix a bogus warning (and early exit from the loop) in nfs_generic_pgio

Features:
- Add NFSv4.2 SEEK feature and client support for lseek(SEEK_HOLE/SEEK_DATA)

Other fixes:
- pnfs: replace broken pnfs_put_lseg_async
- Remove dead prototype for nfs4_insert_deviceid_node

----------------------------------------------------------------
Anna Schumaker (1):
      NFS: Implement SEEK

Tom Haynes (1):
      NFSv4: Remove dead prototype for nfs4_insert_deviceid_node()

Trond Myklebust (5):
      Merge commit '24bab491220f' into client-4.2
      Merge branch 'client-4.2' into linux-next
      NFSv4.1/pnfs: replace broken pnfs_put_lseg_async
      NFS: Fix an uninitialised pointer Oops in the writeback error path
      NFS: Fix a bogus warning in nfs_generic_pgio

 fs/Kconfig                               |   6 +-
 fs/lockd/Makefile                        |   3 +-
 fs/lockd/netns.h                         |   1 -
 fs/lockd/procfs.c                        |  92 +++++++++++++
 fs/lockd/procfs.h                        |  28 ++++
 fs/lockd/svc.c                           |  16 ++-
 fs/nfs/Makefile                          |   1 +
 fs/nfs/callback.c                        |   4 +-
 fs/nfs/filelayout/filelayout.c           |   2 +-
 fs/nfs/inode.c                           |   2 +
 fs/nfs/nfs42.h                           |  14 ++
 fs/nfs/nfs42proc.c                       |  69 ++++++++++
 fs/nfs/nfs42xdr.c                        |  98 ++++++++++++++
 fs/nfs/nfs4_fs.h                         |   3 +
 fs/nfs/nfs4file.c                        |  25 ++++
 fs/nfs/nfs4proc.c                        |   4 +-
 fs/nfs/nfs4xdr.c                         |   7 +
 fs/nfs/pagelist.c                        |  10 +-
 fs/nfs/pnfs.c                            |  33 ++++-
 fs/nfs/pnfs.h                            |   7 +-
 fs/nfs_common/Makefile                   |   3 +-
 fs/{lockd => nfs_common}/grace.c         |  68 ++++++++--
 fs/nfsd/Kconfig                          |   4 +-
 fs/nfsd/cache.h                          |   1 -
 fs/nfsd/export.c                         |   1 +
 fs/nfsd/nfs3proc.c                       |  13 +-
 fs/nfsd/nfs4callback.c                   | 145 ++++++---------------
 fs/nfsd/nfs4idmap.c                      |  20 ++-
 fs/nfsd/nfs4proc.c                       |  49 +++++++
 fs/nfsd/nfs4recover.c                    | 205 +++++++++++++++++++++++------
 fs/nfsd/nfs4state.c                      | 118 +++++++++++++----
 fs/nfsd/nfs4xdr.c                        |  75 ++++++++++-
 fs/nfsd/nfscache.c                       | 214 ++++++++++++++++---------------
 fs/nfsd/nfsctl.c                         |  45 +++++++
 fs/nfsd/nfsd.h                           |   2 +-
 fs/nfsd/nfsfh.c                          |   6 +-
 fs/nfsd/state.h                          |  28 +++-
 fs/nfsd/vfs.c                            |  37 ++++--
 fs/nfsd/xdr4.h                           |  14 ++
 include/linux/nfs4.h                     |  29 ++++-
 include/linux/nfs_fs_sb.h                |   1 +
 include/linux/nfs_xdr.h                  |  19 +++
 include/linux/proc_fs.h                  |   2 +
 include/linux/sunrpc/svc.h               |   1 -
 include/uapi/linux/nfsd/export.h         |   5 +-
 net/sunrpc/svc.c                         |   2 -
 net/sunrpc/svc_xprt.c                    |  81 +++++-------
 net/sunrpc/svcsock.c                     |  25 +---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   2 +-
 net/sunrpc/xprtrdma/xprt_rdma.h          |   7 +
 50 files changed, 1222 insertions(+), 425 deletions(-)
 create mode 100644 fs/lockd/procfs.c
 create mode 100644 fs/lockd/procfs.h
 create mode 100644 fs/nfs/nfs42.h
 create mode 100644 fs/nfs/nfs42proc.c
 create mode 100644 fs/nfs/nfs42xdr.c
 rename fs/{lockd => nfs_common}/grace.c (50%)


