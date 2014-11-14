Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:57021 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422639AbaKNXEk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 18:04:40 -0500
Received: by mail-ie0-f175.google.com with SMTP id at20so3514817iec.20
        for <linux-nfs@vger.kernel.org>; Fri, 14 Nov 2014 15:04:39 -0800 (PST)
Message-ID: <1416006273.12920.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Fri, 14 Nov 2014 18:04:33 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 0df1f2487d2f0d04703f142813d53615d62a1da4:

  Linux 3.18-rc3 (2014-11-02 15:01:51 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.18-3

for you to fetch changes up to b3ecba096729f521312d1863ad22530695527aed:

  sunrpc: fix sleeping under rcu_read_lock in gss_stringify_acceptor (2014-11-13 13:15:49 -0500)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.18

Highlights include:

- Stable patches to fix NFSv4.x delegation reclaim error paths
- Fix a bug whereby we were advertising NFSv4.1 but using NFSv4.2 features
- Fix a use-after-free problem with pNFS block layouts
- Fix a memory leak in the pNFS files O_DIRECT code
- Replace an intrusive and Oops-prone performance fix in the NFSv4 atomic
  open code with a safer one-line version and revert the two original patches.

----------------------------------------------------------------
Anna Schumaker (1):
      NFS: SEEK is an NFS v4.2 feature

Christoph Hellwig (1):
      pnfs/blocklayout: serialize GETDEVICEINFO calls

Jan Kara (2):
      nfs: Remove bogus assignment
      nfs: Fix use of uninitialized variable in nfs_getattr()

Jeff Layton (1):
      sunrpc: fix sleeping under rcu_read_lock in gss_stringify_acceptor

Peng Tao (1):
      nfs: fix pnfs direct write memory leak

Trond Myklebust (8):
      NFSv4: Ensure nfs_atomic_open set the dentry verifier on ENOENT
      Revert "NFS: remove BUG possibility in nfs4_open_and_get_state"
      Revert "NFS: nfs4_do_open should add negative results to the dcache."
      NFSv4: Ensure that we remove NFSv4.0 delegations when state has expired
      NFSv4.1: nfs41_clear_delegation_stateid shouldn't trust NFS_DELEGATED_STATE
      NFSv4: Fix races between nfs_remove_bad_delegation() and delegation return
      NFSv4: Ensure that we call FREE_STATEID when NFSv4.x stateids are revoked
      NFS: Don't try to reclaim delegation open state if recovery failed

Weston Andros Adamson (1):
      nfs: remove spurious WARN_ON_ONCE in write path

 fs/nfs/blocklayout/blocklayout.c |  2 +-
 fs/nfs/blocklayout/rpc_pipefs.c  | 14 +++---
 fs/nfs/delegation.c              | 25 ++++++++++-
 fs/nfs/delegation.h              |  1 +
 fs/nfs/dir.c                     |  1 +
 fs/nfs/direct.c                  |  1 +
 fs/nfs/filelayout/filelayout.c   |  3 --
 fs/nfs/inode.c                   |  2 +-
 fs/nfs/netns.h                   |  1 +
 fs/nfs/nfs4proc.c                | 95 +++++++++++++++++++---------------------
 fs/nfs/write.c                   |  2 -
 include/linux/nfs_xdr.h          | 11 +++++
 net/sunrpc/auth_gss/auth_gss.c   | 35 ++++++++++++---
 13 files changed, 124 insertions(+), 69 deletions(-)


