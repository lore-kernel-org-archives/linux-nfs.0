Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:39385 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408AbbCFDqh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2015 22:46:37 -0500
Received: by qcvs11 with SMTP id s11so13885739qcv.6
        for <linux-nfs@vger.kernel.org>; Thu, 05 Mar 2015 19:46:36 -0800 (PST)
Message-ID: <1425613593.12704.0.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Thu, 05 Mar 2015 22:46:33 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit c517d838eb7d07bbe9507871fab3931deccff539:

  Linux 4.0-rc1 (2015-02-22 18:21:14 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.0-3

for you to fetch changes up to e11259f920d8cb3550e0f311c064bdabe1bc3aaf:

  NFSv4.1: Clear the old state by our client id before establishing a new lease (2015-03-03 21:52:30 -0500)

----------------------------------------------------------------
NFS client bugfixes for Linux 4.0

Highlights include:

- Fix a regression in the NFSv4 open state recovery code
- Fix a regression in the NFSv4 close code
- Fix regressions and side-effects of the loop-back mounted NFS fixes
  in 3.18, that cause the NFS read() syscall to return EBUSY.
- Fix regressions around the readdirplus code and how it interacts with
  the VFS lazy unmount changes that went into v3.18.
- Fix issues with out-of-order RPC call replies replacing updated
  attributes with stale ones (particularly after a truncate()).
- Fix an underflow checking issue with RPC/RDMA credits
- Fix a number of issues with the NFSv4 delegation return/free code.
- Fix issues around stale NFSv4.1 leases when doing a mount

----------------------------------------------------------------
Anna Schumaker (1):
      NFS: Fix stateid used for NFS v4 closes

Chuck Lever (1):
      xprtrdma: Store RDMA credits in unsigned variables

Trond Myklebust (23):
      Merge tag 'nfs-rdma-for-4.0-3' of git://git.linux-nfs.org/projects/anna/nfs-rdma
      NFSv4: nfs4_open_recover_helper() must set share access
      NFS: Ensure that buffered writes wait for O_DIRECT writes to complete
      NFS: Add a helper to set attribute barriers
      NFS: Add attribute update barriers to nfs_setattr_update_inode()
      NFS: Set an attribute barrier on all updates
      NFS: Add attribute update barriers to NFS writebacks
      NFSv4: Add attribute update barriers to delegreturn and pNFS layoutcommit
      NFS: Remove size hack in nfs_inode_attrs_need_update()
      NFS: Fix nfs_post_op_update_inode() to set an attribute barrier
      NFSv4: Set a barrier in the update_changeattr() helper
      NFS: Don't invalidate a submounted dentry in nfs_prime_dcache()
      NFSv3: Use the readdir fileid as the mounted-on-fileid
      NFS: Don't require a filehandle to refresh the inode in nfs_prime_dcache()
      NFSv4: Don't call put_rpccred() under the rcu_read_lock()
      NFSv4: Ensure that we don't reap a delegation that is being returned
      NFSv4: Ensure we honour NFS_DELEGATION_RETURNING in nfs_inode_set_delegation()
      NFSv4: Pin the superblock while we're returning the delegation
      NFSv4: Ensure we skip delegations that are already being returned
      NFS: Fix a regression in the read() syscall
      NFS: Don't write enable new pages while an invalidation is proceeding
      NFSv4: Fix a race in NFSv4.1 server trunking discovery
      NFSv4.1: Clear the old state by our client id before establishing a new lease

 fs/nfs/client.c                 |   2 +-
 fs/nfs/delegation.c             |  45 ++++++++++++----
 fs/nfs/dir.c                    |  22 ++++++--
 fs/nfs/file.c                   |  11 +++-
 fs/nfs/inode.c                  | 111 +++++++++++++++++++++++++++++++++-------
 fs/nfs/internal.h               |   1 +
 fs/nfs/nfs3proc.c               |   4 +-
 fs/nfs/nfs3xdr.c                |   5 ++
 fs/nfs/nfs4client.c             |   9 ++--
 fs/nfs/nfs4proc.c               |  31 +++++++----
 fs/nfs/nfs4session.h            |   1 +
 fs/nfs/nfs4state.c              |  18 ++++++-
 fs/nfs/proc.c                   |   6 +--
 fs/nfs/write.c                  |  30 +++++++++++
 include/linux/nfs_fs.h          |   5 +-
 net/sunrpc/xprtrdma/rpc_rdma.c  |   3 +-
 net/sunrpc/xprtrdma/xprt_rdma.h |   2 +-
 17 files changed, 244 insertions(+), 62 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




