Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:38677 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbcF2RwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2016 13:52:07 -0400
Subject: [PATCH v4 00/24] NFS/RDMA client patches proposed for v4.8
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 29 Jun 2016 13:52:03 -0400
Message-ID: <20160629173231.15094.52660.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series implements the following:

- Fixes to FMR disconnect recovery
- Removal of the insecure ALLPHYSICAL memory registration mode
- Significant reductions in per-transport memory consumption
- Support for sec=krb5, sec=krb5i, and sec=krb5p with NFS/RDMA
  (with no performance impact on sec=sys)
- Pre-requisites for device removal support

Kerberos with NFS/RDMA is useful mainly for secure authentication of
each RPC transaction (sec=krb5). The Kerberos integrity and privacy
services are also available, providing feature parity with TCP in
environments where the use of sec=krb5i or sec=krb5p is mandated by
IT policy.

No changes to the Linux server are needed to use Kerberos with
NFS/RDMA.

The mlx4_alloc_priv_pages workaround has been dropped, as it was
merged into v4.7-rc5.

Otherwise, there are only a few minor clean-ups to the series,
listed below. Anna, these are ready for you to pop into linux-next
and then consider for the 4.8 merge window.


Available in the "nfs-rdma-for-4.8" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.8


Changes since v3:
- Rebased on v4.7-rc5
- Dropped mlx4_alloc_priv_pages fix, was merged into v4.7-rc5
- Added Tested-by: Steve Wise
- Factored destroy_mrs helper out of buffer_destroy
- More clean-up in rpcrdma_ia_open
- Remove arbitrary "+ 2" from loop that allocates receive buffers
- Removed unneeded INIT_LIST_HEAD in fmr_op_init


Changes since v2:
- Rebased on v4.7-rc4
- Reworked the mlx4_alloc_priv_pages patch
- Refactored registration mode checking
- Allocate 32 MRs at a time


Changes since v1:
- Rebased on v4.7-rc3
- Re-ordered series so FMR fixes come first
- Fix ib_unmap_fmr list handling
- Replaced the bogus 256-MRs-per-QP patch with dynamic MR allocation
- Add performance counters to expose MR allocation and recovery behavior
- Included Sagi's proposed mlx4 priv pages fix
- Make it easier to merge my datatouch patch with Scott's bug fix
- Split some patches for readability
- Dropped some clean-up patches to keep the series patch count down

---

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
      xprtrdma: Do not update {head,tail}.iov_len in rpcrdma_inline_fixup()
      xprtrdma: Update only specific fields in private receive buffer
      xprtrdma: Clean up fixup_copy_count accounting
      xprtrdma: No direct data placement with krb5i and krb5p
      svc: Avoid garbage replies when pc_func() returns rpc_drop_reply
      NFS: Don't drop CB requests with invalid principals


 fs/nfs/callback_xdr.c                 |    6 -
 include/linux/sunrpc/auth.h           |    3 
 include/linux/sunrpc/gss_api.h        |    2 
 net/sunrpc/auth_gss/auth_gss.c        |    2 
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    2 
 net/sunrpc/auth_gss/gss_mech_switch.c |   12 +
 net/sunrpc/svc.c                      |    8 +
 net/sunrpc/xprtrdma/Makefile          |    2 
 net/sunrpc/xprtrdma/fmr_ops.c         |  378 +++++++++++++++------------------
 net/sunrpc/xprtrdma/frwr_ops.c        |  369 ++++++++++++--------------------
 net/sunrpc/xprtrdma/physical_ops.c    |  122 -----------
 net/sunrpc/xprtrdma/rpc_rdma.c        |  274 +++++++++++++-----------
 net/sunrpc/xprtrdma/transport.c       |   40 ++-
 net/sunrpc/xprtrdma/verbs.c           |  242 +++++++++++++++------
 net/sunrpc/xprtrdma/xprt_rdma.h       |  118 ++++------
 15 files changed, 728 insertions(+), 852 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/physical_ops.c

--
Chuck Lever
