Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34409 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbaKIBOH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 20:14:07 -0500
Subject: [PATCH v2 00/10] NFS/RDMA patches for 3.19
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 08 Nov 2014 20:14:03 -0500
Message-ID: <20141109010328.8806.5861.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

This is a set of fixes and clean-ups for xprtrdma. Also available
in the nfs-rdma-for-3.19 topic branch at

  git://linux-nfs.org/projects/cel/cel-2.6.git

I've run cthon04, iozone, dbench, multi-process kernel build and
xfstests with NFSv3 and NFSv4.0 against a Linux and a Solaris
NFS server via RDMA, with all three memory registration modes.

Changes since v1:

- Merged up to v3.18-rc3
- Dropped patches that enable NFSv4.1 support for now
- CQ completion vector spinning dropped for now
- Addressed Anna's review comments
- Several bug fixes

---

Chuck Lever (10):
      xprtrdma: Return an errno from rpcrdma_register_external()
      xprtrdma: Cap req_cqinit
      xprtrdma: unmap all FMRs during transport disconnect
      xprtrdma: Refactor tasklet scheduling
      xprtrdma: Re-write rpcrdma_flush_cqs()
      xprtrdma: Enable pad optimization
      xprtrdma: Display async errors
      SUNRPC: serialize iostats updates
      NFS: SETCLIENTID XDR buffer sizes are incorrect
      NFS: Clean up nfs4_init_callback()


 fs/nfs/nfs4client.c             |   31 +++++------
 fs/nfs/nfs4xdr.c                |   10 ++-
 include/linux/sunrpc/metrics.h  |    3 +
 net/sunrpc/stats.c              |   21 +++++--
 net/sunrpc/xprtrdma/transport.c |    4 +
 net/sunrpc/xprtrdma/verbs.c     |  114 ++++++++++++++++++++++++++++++++++-----
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 ++
 7 files changed, 146 insertions(+), 43 deletions(-)

--
Chuck Lever
