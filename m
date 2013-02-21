Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:55178 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757069Ab3BUDiN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2013 22:38:13 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Linux Kernel mailing list" <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
Date: Thu, 21 Feb 2013 03:38:11 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235D8B50@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 88b62b915b0b7e25870eb0604ed9a92ba4bfc9f7:

  Linux 3.8-rc6 (2013-02-01 12:08:14 +1100)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.9-1

for you to fetch changes up to 666b3d803a511fbc9bc5e5ea8ce66010cf03ea13:

  NLM: Ensure that we resend all pending blocking locks after a reclaim (2013-02-19 12:18:27 -0500)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.9

- Fix an Oops in the pNFS layoutget code
- Fix a number of NFSv4 and v4.1 state recovery deadlocks and hangs
  due to the interaction of the session drain lock and state management
  locks.
- Remove task->tk_xprt, which was hiding a lot of RCU dereferencing bugs
- Fix a long standing NFSv3 posix lock recovery bug.
- Revert commit 324d003b0cd82151adbaecefef57b73f7959a469. It turned out
  that the root cause of the deadlock was due to interactions with the
  workqueues that have now been resolved.

----------------------------------------------------------------
Jeff Layton (1):
      sunrpc: silence build warning in gss_fill_context

Tim Gardner (1):
      nfs: remove kfree() redundant null checks

Trond Myklebust (18):
      SUNRPC: Eliminate task->tk_xprt accesses that bypass rcu_dereference()
      SUNRPC: Pass a pointer to struct rpc_xprt to the connect callback
      SUNRPC: Fix an RCU dereference in xs_local_rpcbind
      SUNRPC: Pass pointers to struct rpc_xprt to the congestion window
      SUNRPC: Fix an RCU dereference in xprt_reserve
      SUNRPC: Avoid RCU dereferences in the transport bind and connect code
      SUNRPC: Nuke the tk_xprt macro
      Revert "NFS: add nfs_sb_deactive_async to avoid deadlock"
      SUNRPC: Add missing static declaration to _gss_mech_get_by_name
      NFSv4: Allow the state manager to mark an open_owner as being recovered
      NFSv4.1: Prevent deadlocks between state recovery and file locking
      NFSv4.1: Don't lose locks when a server reboots during delegation return
      NFSv4: Fix up the return values of nfs4_open_delegation_recall
      NFSv4: Ensure delegation recall and byte range lock removal don't conflict
      NFSv4: Fix a reboot recovery race when opening a file
      NFSv4.1: Fix an ABBA locking issue with session and state serialisation
      NFSv4.1: Fix bulk recall and destroy of layouts
      NLM: Ensure that we resend all pending blocking locks after a reclaim

Weston Andros Adamson (1):
      NFSv4.1: Don't decode skipped layoutgets

fanchaoting (1):
      umount oops when remove blocklayoutdriver first

 fs/lockd/clntproc.c                   |   3 +
 fs/nfs/blocklayout/blocklayout.c      |   1 +
 fs/nfs/callback_proc.c                |  61 ++------------
 fs/nfs/delegation.c                   | 154 ++++++++++++++++++++++++----------
 fs/nfs/delegation.h                   |   1 +
 fs/nfs/getroot.c                      |   3 +-
 fs/nfs/inode.c                        |   5 +-
 fs/nfs/internal.h                     |   1 -
 fs/nfs/nfs4_fs.h                      |   4 +
 fs/nfs/nfs4proc.c                     | 133 ++++++++++++++++++++---------
 fs/nfs/nfs4state.c                    |  11 ++-
 fs/nfs/objlayout/objio_osd.c          |   1 +
 fs/nfs/pnfs.c                         | 150 ++++++++++++++++++++++++++++-----
 fs/nfs/pnfs.h                         |   7 +-
 fs/nfs/super.c                        |  49 -----------
 fs/nfs/unlink.c                       |   5 +-
 include/linux/sunrpc/sched.h          |   1 -
 include/linux/sunrpc/xprt.h           |   6 +-
 net/sunrpc/auth_gss/auth_gss.c        |   5 +-
 net/sunrpc/auth_gss/gss_mech_switch.c |   4 +-
 net/sunrpc/clnt.c                     |  16 ++--
 net/sunrpc/xprt.c                     |  21 +++--
 net/sunrpc/xprtrdma/rpc_rdma.c        |   4 +-
 net/sunrpc/xprtrdma/transport.c       |   7 +-
 net/sunrpc/xprtrdma/xprt_rdma.h       |   6 +-
 net/sunrpc/xprtsock.c                 |  16 ++--
 26 files changed, 415 insertions(+), 260 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
