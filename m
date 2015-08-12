Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:24192 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbbHLTQn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2015 15:16:43 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [GIT PULL] Please pull NFSoRDMA Client
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <55CB9B92.9010407@Netapp.com>
Date: Wed, 12 Aug 2015 15:16:34 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes since commit 74d33293e467df61de1b1d8b2fbe29e550dec33b:

  Linux 4.2-rc5 (2015-08-02 18:34:55 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-for-4.3

for you to fetch changes up to d0f36c46deea97bd16b9277be2f1acac74d76037:

  xprtrdma: take HCA driver refcount at client (2015-08-05 16:22:56 -0400)

----------------------------------------------------------------
Chuck Lever (15):
      xprtrdma: Make xprt_setup_rdma() agnostic to family of server address
      xprtrdma: Raise maximum payload size to one megabyte
      xprtrdma: Increase default credit limit
      xprtrdma: Don't fall back to PHYSICAL memory registration
      xprtrdma: Remove last ib_reg_phys_mr() call site
      xprtrdma: Clean up rpcrdma_ia_open()
      xprtrdma: Remove logic that constructs RDMA_MSGP type calls
      xprtrdma: Account for RPC/RDMA header size when deciding to inline
      xprtrdma: Always provide a write list when sending NFS READ
      xprtrdma: Don't provide a reply chunk when expecting a short reply
      xprtrdma: Fix XDR tail buffer marshalling
      xprtrdma: Fix large NFS SYMLINK calls
      xprtrdma: Clean up xprt_rdma_print_stats()
      xprtrdma: Count RDMA_NOMSG type calls
      core: Remove the ib_reg_phys_mr() and ib_rereg_phys_mr() verbs

Devesh Sharma (1):
      xprtrdma: take HCA driver refcount at client

 drivers/infiniband/core/verbs.c    |  67 -------------------------
 fs/nfs/nfs3xdr.c                   |   1 +
 fs/nfs/nfs4xdr.c                   |   4 +-
 include/linux/sunrpc/xprtrdma.h    |   2 +-
 include/rdma/ib_verbs.h            |  46 -----------------
 net/sunrpc/xprtrdma/fmr_ops.c      |  19 +++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   5 ++
 net/sunrpc/xprtrdma/physical_ops.c |  25 ++++++++-
 net/sunrpc/xprtrdma/rpc_rdma.c     | 197 ++++++++++++++++++++++++++++++++++++-----------------------------------
 net/sunrpc/xprtrdma/transport.c    |  77 +++++++++++++---------------
 net/sunrpc/xprtrdma/verbs.c        | 234 +++++++++++++++++++++++++++++--------------------------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |  27 +++++-----
 12 files changed, 281 insertions(+), 423 deletions(-)
