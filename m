Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33931 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbKITcz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Nov 2015 14:32:55 -0500
Received: by iody8 with SMTP id y8so196582869iod.1
        for <linux-nfs@vger.kernel.org>; Mon, 09 Nov 2015 11:32:54 -0800 (PST)
Message-ID: <1447097552.8645.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client changes for 4.4
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 09 Nov 2015 14:32:32 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 7379047d5585187d1288486d4627873170d0005a:

  Linux 4.3-rc6 (2015-10-18 16:08:42 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.4-1

for you to fetch changes up to 941c3ff3102ccce440034d59cf9e4e9cc10b720d:

  Sunrpc: Supports hexadecimal number for sysctl files of sunrpc debug (2015-11-03 15:56:49 -0500)

----------------------------------------------------------------
NFS client updates for Linux 4.4

Highlights include:

Features:
- RDMA client backchannel from Chuck
- Support for NFSv4.2 file CLONE using the btrfs ioctl

Bugfixes + cleanups
- Move socket data receive out of the bottom halves and into a workqueue
- Refactor NFSv4 error handling so synchronous and asynchronous RPC handles
  errors identically.
- Fix a panic when blocks or object layouts reads return a bad data length
- Fix nfsroot so it can handle a 1024 byte long path.
- Fix bad usage of page offset in bl_read_pagelist
- Various NFSv4 callback cleanups+fixes
- Fix GETATTR bitmap verification
- Support hexadecimal number for sunrpc debug sysctl files

----------------------------------------------------------------
Andreas Gruenbacher (2):
      nfs: Remove unused xdr page offsets in getacl/setacl arguments
      nfs: Fix GETATTR bitmap verification

Andrzej Hajda (1):
      SUNRPC: fix variable type

Chuck Lever (16):
      xprtrdma: Enable swap-on-NFS/RDMA
      xprtrdma: Re-arm after missed events
      xprtrdma: Prevent loss of completion signals
      xprtrdma: Refactor reply handler error handling
      xprtrdma: Replace send and receive arrays
      xprtrdma: Use workqueue to process RPC/RDMA replies
      xprtrdma: Remove reply tasklet
      xprtrdma: Saving IRQs no longer needed for rb_lock
      SUNRPC: Abstract backchannel operations
      xprtrdma: Pre-allocate backward rpc_rqst and send/receive buffers
      xprtrdma: Pre-allocate Work Requests for backchannel
      xprtrdma: Add support for sending backward direction RPC replies
      xprtrdma: Handle incoming backward direction RPC calls
      svcrdma: Add backward direction service for RPC/RDMA transport
      SUNRPC: Remove the TCP-only restriction in bc_svc_process()
      NFS: Enable client side NFSv4.1 backchannel to use other transports

Kinglong Mee (11):
      NFS: Get rid of the unneeded addr stored in callback arguments
      NFS: Remove the left global variable nfs_callback_tcpport
      NFS: Remove the left function defines in callback.h
      NFS: Remove unneeded NFS_DEBUG checking before define NFSDBG_FACILITY
      NFS: Use NFS4_MAX_SESSIONID_LEN directly for decode/encode sessionid
      NFS: Fix bad defines of callback response maxsize
      NFS: Fix bad checking of max taglen in callback request
      NFS: Return directly if encode_sessionid fail
      nfs/blocklayout: Fix bad using of page offset in bl_read_pagelist
      NFSv4.1/pnfs: Retry through MDS when getting bad length of data
      Sunrpc: Supports hexadecimal number for sysctl files of sunrpc debug

Li RongQing (1):
      nfsroot: make nfsroot to accept the 1024 bytes long directory name

Peng Tao (7):
      nfs42: add CLONE xdr functions
      nfs42: add CLONE proc functions
      nfs42: add NFS_IOC_CLONE ioctl
      nfs: get clone_blksize when probing fsinfo
      nfs42: respect clone_blksize
      nfs42: add NFS_IOC_CLONE_RANGE ioctl
      nfs: add missing linux/types.h

Steve Wise (1):
      xprtrdma: don't log warnings for flushed completions

Trond Myklebust (17):
      SUNRPC: Refactor TCP receive
      SUNRPC: Move TCP receive data path into a workqueue context
      SUNRPC: Move UDP receive data path into a workqueue context
      SUNRPC: Move AF_LOCAL receive data path into a workqueue context
      SUNRPC: Use MSG_SENDPAGE_NOTLAST in xs_send_pagedata()
      NFSv4: Refactor NFSv4 error handling
      NFSv4: Update the delay statistics counter for synchronous delays
      NFSv4: nfs4_async_handle_error should take a non-const nfs_server
      NFSv4: Don't use synchronous delegation recall in exception handling
      NFSv4: Unify synchronous and asynchronous error handling
      Merge branch 'sunrpc'
      NFS: Fix an 'unused variable' complaint when #ifndef CONFIG_NFS_V4_2
      Merge branch 'nfsclone'
      Merge branch 'bugfixes'
      pNFS/flexfiles: When mirrored, retry failed reads by switching mirrors
      pNFS/flexfiles: Add support for FF_FLAGS_NO_IO_THRU_MDS
      Merge tag 'nfs-rdma-4.4-2' of git://git.linux-nfs.org/projects/anna/nfs-rdma

Yaowei Bai (1):
      fs/nfs: remove unnecessary new_valid_dev check

 fs/nfs/blocklayout/blocklayout.c         |   7 +-
 fs/nfs/callback.c                        |  40 +--
 fs/nfs/callback.h                        |  12 -
 fs/nfs/callback_proc.c                   |   2 -
 fs/nfs/callback_xdr.c                    |  39 ++-
 fs/nfs/client.c                          |   1 +
 fs/nfs/delegation.c                      |   6 +-
 fs/nfs/dir.c                             |   3 -
 fs/nfs/flexfilelayout/flexfilelayout.c   |  40 ++-
 fs/nfs/flexfilelayout/flexfilelayout.h   |   7 +
 fs/nfs/mount_clnt.c                      |   4 +-
 fs/nfs/nfs42.h                           |   1 +
 fs/nfs/nfs42proc.c                       |  71 +++++
 fs/nfs/nfs42xdr.c                        |  97 ++++++-
 fs/nfs/nfs4_fs.h                         |   6 +-
 fs/nfs/nfs4file.c                        | 136 +++++++++
 fs/nfs/nfs4proc.c                        | 182 ++++++------
 fs/nfs/nfs4xdr.c                         |  53 +++-
 fs/nfs/nfsroot.c                         |   2 +-
 fs/nfs/pnfs.c                            |  12 +-
 fs/nfs/read.c                            |   9 +-
 fs/nfs/super.c                           |   2 -
 fs/nfs/write.c                           |   7 +
 include/linux/nfs4.h                     |   3 +
 include/linux/nfs_fs_sb.h                |   2 +
 include/linux/nfs_xdr.h                  |  28 +-
 include/linux/sunrpc/bc_xprt.h           |   5 +
 include/linux/sunrpc/svc_rdma.h          |   6 +-
 include/linux/sunrpc/xprt.h              |   9 +
 include/linux/sunrpc/xprtsock.h          |   2 +
 include/uapi/linux/nfs.h                 |  13 +
 net/sunrpc/backchannel_rqst.c            |  24 +-
 net/sunrpc/svc.c                         |   5 -
 net/sunrpc/sysctl.c                      |  23 +-
 net/sunrpc/xprtrdma/Makefile             |   1 +
 net/sunrpc/xprtrdma/backchannel.c        | 394 +++++++++++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c           |   7 +-
 net/sunrpc/xprtrdma/rpc_rdma.c           | 148 +++++++---
 net/sunrpc/xprtrdma/svc_rdma.c           |   6 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  58 ++++
 net/sunrpc/xprtrdma/transport.c          |  18 +-
 net/sunrpc/xprtrdma/verbs.c              | 479 ++++++++++++++++---------------
 net/sunrpc/xprtrdma/xprt_rdma.h          |  54 +++-
 net/sunrpc/xprtsock.c                    | 260 ++++++++++++-----
 44 files changed, 1687 insertions(+), 597 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/backchannel.c
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



