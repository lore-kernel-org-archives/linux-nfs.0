Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:30425 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934981AbcKJVSO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 16:18:14 -0500
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull a few more NFS client bugfixes
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Message-ID: <5ded1ab5-f3d1-fc50-a6a8-55afd367a38b@Netapp.com>
Date: Thu, 10 Nov 2016 16:18:02 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 83aa3e0f791d458a28f91d7a50f92926f971ef7c:

  nfs4: fix missing-braces warning (2016-10-19 14:39:15 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.9-3

for you to fetch changes up to 62bdf94a2049822ef8c6d4b0e83cd9c3a1663ab4:

  xprtrdma: Fix DMAR failure in frwr_op_map() after reconnect (2016-11-10 11:04:54 -0500)

----------------------------------------------------------------
Most of these fix regressions in 4.9, and none are going to stable this time around:

- Trim extra slashes in v4 nfs_paths to fix tools that use this
- Fix a -Wmaybe-uninitialized warnings
- Fix suspicious RCU usages
- Fix Oops when mounting multiple servers at once
- Suppress a false-positive pNFS error
- Fix a DMAR failure in NFS over RDMA

Thanks,
Anna
----------------------------------------------------------------
Anna Schumaker (2):
      SUNRPC: Fix suspicious RCU usage
      NFS: Don't print a pNFS error if we aren't using pNFS

Arnd Bergmann (1):
      NFSv4.1: work around -Wmaybe-uninitialized warning

Benjamin Coddington (1):
      NFS: Trim extra slash in v4 nfs_path

Chuck Lever (1):
      xprtrdma: Fix DMAR failure in frwr_op_map() after reconnect

Petr Vandrovec (1):
      NFS: Ignore connections that have cl_rpcclient uninitialized

Shuah Khan (1):
      fs/nfs: Fix used uninitialized warn in nfs4_slot_seqid_in_use()

 fs/nfs/client.c                 |  3 ++-
 fs/nfs/namespace.c              |  2 +-
 fs/nfs/nfs4session.c            | 12 +++++++-----
 fs/nfs/pnfs.c                   |  2 ++
 net/sunrpc/clnt.c               |  7 +++++--
 net/sunrpc/xprtrdma/frwr_ops.c  | 37 ++++++++++++++++++++++---------------
 net/sunrpc/xprtrdma/xprt_rdma.h |  3 ++-
 7 files changed, 41 insertions(+), 25 deletions(-)
