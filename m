Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36746 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161111AbcFGTqU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:46:20 -0400
Subject: [PATCH v1 00/20] NFS/RDMA client patches proposed for v4.8
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:46:17 -0400
Message-ID: <20160607194001.18401.88592.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series implements the following:

- Removal of the insecure ALLPHYSICAL memory registration mode
- Fixes to FMR disconnect recovery
- Significant reductions in per-transport memory consumption
- Support for sec=krb5, sec=krb5i, and sec=krb5p with NFS/RDMA
   (with no performance impact on sec=sys)
- More pre-requisites for device removal support

Kerberos with NFS/RDMA is useful mainly for secure authentication of
each RPC transaction (sec=krb5). The Kerberos integrity and privacy
services are also available, providing feature parity with TCP in
environments where the use of sec=krb5i or sec=krb5p are mandated by
IT policy.


Available in the "nfs-rdma-for-4.8" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.8


---

Chuck Lever (20):
      xprtrdma: Remove ALLPHYSICAL memory registration mode
      xprtrdma: Refactor ->ro_init
      xprtrdma: Create common scatterlist fields in rpcrdma_mw
      xprtrdma: Use scatterlist for DMA mapping and unmapping under FMR
      xprtrdma: Remove rpcrdma_map_one() and friends
      xprtrdma: Refactor MR recovery work queues
      xprtrdma: Place registered MWs on a per-req list
      xprtrdma: Reply buffer exhaustion can be catastrophic
      xprtrdma: Limit the number of rpcrdma_mws
      xprtrdma: Chunk list encoders no longer share one rl_segments array
      xprtrdma: rpcrdma_inline_fixup() overruns the receive page list
      xprtrdma: Do not update {head,tail}.iov_len in rpcrdma_inline_fixup()
      xprtrdma: Update only specific fields in private receive buffer
      xprtrdma: Clean up fixup_copy_count accounting
      xprtrdma: No direct data placement with krb5i and krb5p
      svc: Avoid garbage replies when pc_func() returns rpc_drop_reply
      NFS: Don't drop CB requests with invalid principals
      xprtrdma: Eliminate rpcrdma_receive_worker()
      xprtrdma: Eliminate INLINE_THRESHOLD macros
      xprtrdma: Relocate connection helper functions


 fs/nfs/callback_xdr.c                 |    6 +
 include/linux/sunrpc/auth.h           |    5 -
 include/linux/sunrpc/gss_api.h        |    2 
 net/sunrpc/auth_gss/auth_gss.c        |    5 -
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    2 
 net/sunrpc/auth_gss/gss_mech_switch.c |   12 +
 net/sunrpc/svc.c                      |    8 +
 net/sunrpc/xprtrdma/Makefile          |    2 
 net/sunrpc/xprtrdma/backchannel.c     |    4 
 net/sunrpc/xprtrdma/fmr_ops.c         |  270 +++++++++++++-----------------
 net/sunrpc/xprtrdma/frwr_ops.c        |  231 +++++++++----------------
 net/sunrpc/xprtrdma/physical_ops.c    |  122 -------------
 net/sunrpc/xprtrdma/rpc_rdma.c        |  301 ++++++++++++++++-----------------
 net/sunrpc/xprtrdma/transport.c       |   48 ++++-
 net/sunrpc/xprtrdma/verbs.c           |   86 +++++----
 net/sunrpc/xprtrdma/xprt_rdma.h       |  134 +++++----------
 16 files changed, 512 insertions(+), 726 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/physical_ops.c

--
Chuck Lever
