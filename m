Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:41491 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751708AbcJMUVa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Oct 2016 16:21:30 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client changes for Linux 4.9
Message-ID: <a0b6ab28-1a8a-8a0e-aebb-b750807707d5@Netapp.com>
Date: Thu, 13 Oct 2016 16:21:26 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 3be7988674ab33565700a37b210f502563d932e6:

  Linux 4.8-rc7 (2016-09-18 17:27:41 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.9-1

for you to fetch changes up to 3f807e5ae5597bd65a6fff684083e8eaa21f3fa7:

  NFSv4.2: Fix a reference leak in nfs42_proc_layoutstats_generic (2016-10-04 16:30:54 -0400)

The patch "nfs: add a new NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant" is also included in Bruce's NFSD pull request since it modifies shared code between the client and the server.

Thanks,
Anna

----------------------------------------------------------------
Amitoj Kaur Chawla (1):
      sunrpc: Remove unnecessary variable

Andy Adamson (12):
      NFS setup async exchange_id
      NFS refactor nfs4_match_clientids
      NFS refactor nfs4_check_serverowner_major_id
      NFS detect session trunking
      SUNRPC remove rpc_task_release_client from rpc_task_set_client
      SUNRPC rpc_clnt_xprt_switch_put
      SUNRPC rpc_clnt_xprt_switch_add_xprt
      SUNRPC search xprt switch for sockaddr
      SUNRPC: rpc_clnt_add_xprt setup function for NFS layer
      NFS add xprt switch addrs test to match client
      NFS test session trunking with exchange id
      NFS pnfs data server multipath session trunking

Chao Yu (1):
      nfs: cover ->migratepage with CONFIG_MIGRATION

Chuck Lever (22):
      xprtrdma: Eliminate INLINE_THRESHOLD macros
      SUNRPC: Refactor rpc_xdr_buf_init()
      SUNRPC: Generalize the RPC buffer allocation API
      SUNRPC: Generalize the RPC buffer release API
      SUNRPC: Separate buffer pointers for RPC Call and Reply messages
      SUNRPC: Add a transport-specific private field in rpc_rqst
      xprtrdma: Initialize separate RPC call and reply buffers
      xprtrdma: Use smaller buffers for RPC-over-RDMA headers
      xprtrdma: Replace DMA_BIDIRECTIONAL
      xprtrdma: Delay DMA mapping Send and Receive buffers
      xprtrdma: Eliminate "ia" argument in rpcrdma_{alloc, free}_regbuf
      xprtrdma: Simplify rpcrdma_ep_post_recv()
      xprtrdma: Move send_wr to struct rpcrdma_req
      xprtrdma: Move recv_wr to struct rpcrdma_rep
      rpcrdma: RDMA/CM private message data structure
      xprtrdma: Client-side support for rpcrdma_connect_private
      xprtrdma: Basic support for Remote Invalidation
      xprtrdma: Use gathered Send for large inline messages
      xprtrdma: Support larger inline thresholds
      xprtrmda: Report address of frmr, not mw
      xprtrdma: Rename rpcrdma_receive_wc()
      xprtrdma: Eliminate rpcrdma_receive_worker()

Daniel Wagner (3):
      NFS: direct: use complete() instead of complete_all()
      NFS: cache_lib: use complete() instead of complete_all()
      xprtrdma: use complete() instead complete_all()

David Vrabel (1):
      sunrpc: fix write space race causing stalls

Deepa Dinamani (1):
      fs: nfs: Make nfs boot time y2038 safe

Frank Sorenson (5):
      sunrpc: add hash_cred() function to rpc_authops struct
      sunrpc: add generic_auth hash_cred() function
      sunrpc: add auth_unix hash_cred() function
      sunrpc: add RPCSEC_GSS hash_cred() function
      sunrpc: replace generic auth_cred hash with auth-specific function

Jeff Layton (12):
      pnfs: track multiple layout types in fsinfo structure
      pnfs: add a new mechanism to select a layout driver according to an ordered list
      nfs: the length argument to read_buf should be unsigned
      nfs: eliminate pointless and confusing do_vfs_lock wrappers
      nfs: use safe, interruptible sleeps when waiting to retry LOCK
      nfs: add a new NFS4_OPEN_RESULT_MAY_NOTIFY_LOCK constant
      nfs: track whether server sets MAY_NOTIFY_LOCK flag
      nfs: add handling for CB_NOTIFY_LOCK in client
      nfs: move nfs4_set_lock_state call into caller
      nfs: move nfs4 lock retry attempt loop to a separate function
      nfs: allow blocking locks to be awoken by lock callbacks
      NFSv4.2: Fix a reference leak in nfs42_proc_layoutstats_generic

Ke Wang (1):
      sunrpc: queue work on system_power_efficient_wq

Olga Kornievskaia (1):
      Retry operation on EREMOTEIO on an interrupted slot

Trond Myklebust (40):
      NFSv4.x: Set up struct svc_serv_ops for the callback channel
      SUNRPC: Initialise struct svc_serv backchannel fields during __svc_create()
      NFSv4.x: Fix up the global tracking of the callback server
      NFSv4.x: Switch to using svc_set_num_threads() to manage the callback threads
      NFSv4.x: Add kernel parameter to control the callback server
      NFS: nfs_prime_dcache must validate the filename
      SUNRPC: Fix corruption of xdr->nwords in xdr_copy_to_scratch
      SUNRPC: Fix setting of buffer length in xdr_set_next_buffer()
      NFSv4.1: Don't deadlock the state manager on the SEQUENCE status flags
      NFS: Fix inode corruption in nfs_prime_dcache()
      NFSv4: Don't report revoked delegations as valid in nfs_have_delegation()
      NFSv4: nfs4_copy_delegation_stateid() must fail if the delegation is invalid
      NFSv4.1: Don't check delegations that are already marked as revoked
      NFSv4.1: Allow test_stateid to handle session errors without waiting
      NFSv4.1: Add a helper function to deal with expired stateids
      NFSv4.x: Allow callers of nfs_remove_bad_delegation() to specify a stateid
      NFSv4.1: Test delegation stateids when server declares "some state revoked"
      NFSv4.1: Deal with server reboots during delegation expiration recovery
      NFSv4.1: Don't recheck delegations that have already been checked
      NFSv4.1: Allow revoked stateids to skip the call to TEST_STATEID
      NFSv4.1: Ensure we always run TEST/FREE_STATEID on locks
      NFSv4.1: FREE_STATEID can be asynchronous
      NFSv4.1: Ensure we call FREE_STATEID if needed on close/delegreturn/locku
      NFSv4: Ensure we don't re-test revoked and freed stateids
      NFSv4: nfs_inode_find_state_and_recover() should check all stateids
      NFSv4: nfs4_handle_delegation_recall_error() handle expiration as revoke case
      NFSv4: nfs4_handle_setlk_error() handle expiration as revoke case
      NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
      NFSv4: Pass the stateid to the exception handler in nfs4_read/write_done_cb
      NFSv4: Fix a race in nfs_inode_reclaim_delegation()
      NFSv4: Fix a race when updating an open_stateid
      NFS: Always call nfs_inode_find_state_and_recover() when revoking a delegation
      NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single stateid
      NFSv4: Don't test open_stateid unless it is set
      NFSv4: Mark the lock and open stateids as invalid after freeing them
      NFSv4: Open state recovery must account for file permission changes
      NFSv4: Fix retry issues with nfs41_test/free_stateid
      NFSv4: If recovery failed for a specific open stateid, then don't retry
      NFSv4.1: Even if the stateid is OK, we may need to recover the open modes
      pNFS: Fix atime updates on pNFS clients

 Documentation/kernel-parameters.txt        |  12 +
 fs/nfs/cache_lib.c                         |   2 +-
 fs/nfs/callback.c                          | 136 ++---
 fs/nfs/callback.h                          |  12 +
 fs/nfs/callback_proc.c                     |  16 +
 fs/nfs/callback_xdr.c                      |  53 +-
 fs/nfs/client.c                            |  10 +-
 fs/nfs/delegation.c                        | 213 ++++++-
 fs/nfs/delegation.h                        |   8 +-
 fs/nfs/dir.c                               |  24 +-
 fs/nfs/direct.c                            |   2 +-
 fs/nfs/file.c                              |  11 +-
 fs/nfs/flexfilelayout/flexfilelayout.c     |   2 +-
 fs/nfs/internal.h                          |   7 +-
 fs/nfs/netns.h                             |   2 +-
 fs/nfs/nfs42proc.c                         |   1 +
 fs/nfs/nfs4_fs.h                           |  15 +-
 fs/nfs/nfs4client.c                        | 118 +++-
 fs/nfs/nfs4proc.c                          | 901 ++++++++++++++++++++---------
 fs/nfs/nfs4session.h                       |   2 +
 fs/nfs/nfs4state.c                         |  84 ++-
 fs/nfs/nfs4xdr.c                           |  42 +-
 fs/nfs/pnfs.c                              |  73 ++-
 fs/nfs/pnfs.h                              |   5 +-
 fs/nfs/pnfs_nfs.c                          |  58 +-
 fs/nfs/super.c                             |  10 +
 include/linux/nfs4.h                       |   1 +
 include/linux/nfs_fs_sb.h                  |   3 +
 include/linux/nfs_xdr.h                    |   8 +-
 include/linux/sunrpc/auth.h                |   1 +
 include/linux/sunrpc/clnt.h                |  17 +
 include/linux/sunrpc/rpc_rdma.h            |  39 ++
 include/linux/sunrpc/sched.h               |   4 +-
 include/linux/sunrpc/xdr.h                 |  12 +
 include/linux/sunrpc/xprt.h                |  12 +-
 include/linux/sunrpc/xprtmultipath.h       |   2 +
 include/linux/sunrpc/xprtrdma.h            |   4 +-
 include/uapi/linux/nfs4.h                  |   5 +-
 net/sunrpc/auth.c                          |   2 +-
 net/sunrpc/auth_generic.c                  |   9 +
 net/sunrpc/auth_gss/auth_gss.c             |   7 +
 net/sunrpc/auth_unix.c                     |   9 +
 net/sunrpc/backchannel_rqst.c              |   8 +-
 net/sunrpc/cache.c                         |   5 +-
 net/sunrpc/clnt.c                          | 132 ++++-
 net/sunrpc/sched.c                         |  35 +-
 net/sunrpc/svc.c                           |  17 +
 net/sunrpc/xdr.c                           |  11 +-
 net/sunrpc/xprt.c                          |   2 +-
 net/sunrpc/xprtmultipath.c                 |  24 +-
 net/sunrpc/xprtrdma/backchannel.c          |  53 +-
 net/sunrpc/xprtrdma/fmr_ops.c              |   7 +-
 net/sunrpc/xprtrdma/frwr_ops.c             |  28 +-
 net/sunrpc/xprtrdma/rpc_rdma.c             | 323 ++++++-----
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  19 +-
 net/sunrpc/xprtrdma/transport.c            | 202 ++++---
 net/sunrpc/xprtrdma/verbs.c                | 237 ++++----
 net/sunrpc/xprtrdma/xprt_rdma.h            | 108 ++--
 net/sunrpc/xprtsock.c                      |  34 +-
 59 files changed, 2233 insertions(+), 966 deletions(-)
