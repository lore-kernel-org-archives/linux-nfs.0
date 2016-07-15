Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:38509 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbcGOUx4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2016 16:53:56 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [GIT PULL] Please pull NFSoRDMA client changes for 4.8
Message-ID: <a8a33481-f0cd-118b-acd0-6cbd945ac240@Netapp.com>
Date: Fri, 15 Jul 2016 16:53:52 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit 92d21ac74a9e3c09b0b01c764e530657e4c85c49:

  Linux 4.7-rc7 (2016-07-10 20:24:59 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-4.8-1

for you to fetch changes up to a4e187d83d88eeaba6252aac0a2ffe5eaa73a818:

  NFS: Don't drop CB requests with invalid principals (2016-07-11 15:50:43 -0400)

Thanks,
Anna

----------------------------------------------------------------
Chuck Lever (24):
      xprtrdma: Remove FMRs from the unmap list after unmapping
      xprtrdma: Create common scatterlist fields in rpcrdma_mw
      xprtrdma: Move init and release helpers
      xprtrdma: Rename fields in rpcrdma_fmr
      xprtrdma: Use scatterlist for DMA mapping and unmapping under FMR
      xprtrdma: Refactor MR recovery work queues
      xprtrdma: Do not leak an MW during a DMA map failure
      xprtrdma: Remove ALLPHYSICAL memory registration mode
      xprtrdma: Remove rpcrdma_map_one() and friends
      xprtrdma: Clean up device capability detection
      xprtrdma: Reply buffer exhaustion can be catastrophic
      xprtrdma: Honor ->send_request API contract
      xprtrdma: Chunk list encoders must not return zero
      xprtrdma: Allocate MRs on demand
      xprtrdma: Release orphaned MRs immediately
      xprtrdma: Place registered MWs on a per-req list
      xprtrdma: Chunk list encoders no longer share one rl_segments array
      xprtrdma: rpcrdma_inline_fixup() overruns the receive page list
      xprtrdma: Do not update {head, tail}.iov_len in rpcrdma_inline_fixup()
      xprtrdma: Update only specific fields in private receive buffer
      xprtrdma: Clean up fixup_copy_count accounting
      xprtrdma: No direct data placement with krb5i and krb5p
      svc: Avoid garbage replies when pc_func() returns rpc_drop_reply
      NFS: Don't drop CB requests with invalid principals

 fs/nfs/callback_xdr.c                 |   6 +-
 include/linux/sunrpc/auth.h           |   3 +
 include/linux/sunrpc/gss_api.h        |   2 +
 net/sunrpc/auth_gss/auth_gss.c        |   2 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |   2 +
 net/sunrpc/auth_gss/gss_mech_switch.c |  12 ++
 net/sunrpc/svc.c                      |   8 +-
 net/sunrpc/xprtrdma/Makefile          |   2 +-
 net/sunrpc/xprtrdma/fmr_ops.c         | 378 +++++++++++++++++++----------------------
 net/sunrpc/xprtrdma/frwr_ops.c        | 369 +++++++++++++++-------------------------
 net/sunrpc/xprtrdma/physical_ops.c    | 122 -------------
 net/sunrpc/xprtrdma/rpc_rdma.c        | 274 +++++++++++++++--------------
 net/sunrpc/xprtrdma/transport.c       |  40 +++--
 net/sunrpc/xprtrdma/verbs.c           | 242 ++++++++++++++++++--------
 net/sunrpc/xprtrdma/xprt_rdma.h       | 118 +++++--------
 15 files changed, 728 insertions(+), 852 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/physical_ops.c
