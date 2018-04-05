Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45864 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751179AbeDEOXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Apr 2018 10:23:30 -0400
Date: Thu, 5 Apr 2018 10:23:29 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.17
Message-ID: <20180405142329.GR20297@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.17 from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.17

Chuck Lever did a bunch of work on nfsd tracepoints, on RDMA, and on
server xdr decoding (with an eye towards eliminating a data copy in the
RDMA case).

I did some refactoring of the delegation code in preparation for
eliminating some delegation self-conflicts and implementing write
delegations.

--b.

Chuck Lever (21):
      svcrdma: Use pr_err to report Receive errors
      svcrdma: Consult max_qp_init_rd_atom when accepting connections
      svcrdma: Clean up rdma_build_arg_xdr
      sunrpc: Remove unneeded pointer dereference
      svc: Simplify ->xpo_secure_port
      sunrpc: Update show_svc_xprt_flags() to include recently added flags
      sunrpc: Move trace_svc_xprt_dequeue()
      sunrpc: Simplify do_enqueue tracing
      sunrpc: Simplify trace_svc_recv
      sunrpc: Save remote presentation address in svc_xprt for trace events
      sunrpc: Re-purpose trace_svc_process
      sunrpc: Report per-RPC execution stats
      svc: Report xprt dequeue latency
      nfsd: Fix NFSD trace points
      nfsd: Record request byte count, not count of vectors
      nfsd: Add "nfsd_" to trace point names
      nfsd: Add I/O trace points in the NFSv4 write path
      nfsd: Add I/O trace points in the NFSv4 read proc
      nfsd: Trace NFSv4 COMPOUND execution
      NFSD: Clean up legacy NFS WRITE argument XDR decoders
      NFSD: Clean up legacy NFS SYMLINK argument XDR decoders

Colin Ian King (1):
      lockd: make nlm_ntf_refcnt and nlm_ntf_wq static

Eric Biggers (1):
      sunrpc: remove incorrect HMAC request initialization

Fengguang Wu (1):
      nfsd: fix boolreturn.cocci warnings

J. Bruce Fields (11):
      nfsd: remove unsused "cp_consecutive" field
      nfsd: don't require low ports for gss requests
      nfsd: simplify put of fi_deleg_file
      nfsd: simplify nfs4_put_deleg_lease calls
      nfsd4: set fl_owner to delegation, not file pointer
      nfsd4: dp->dl_stid.sc_file doesn't need locking
      nfsd: make nfs4_get_existing_delegation less confusing
      nfsd: factor out common delegation-destruction code
      nfsd: move sc_file assignment into alloc_init_deleg
      nfsd: create a separate lease for each delegation
      nfsd: fix incorrect umasks

James Ettle (1):
      sunrpc: Fix unaligned access on sparc64

Jeff Layton (2):
      nfsd4: send the special close_stateid in v4.0 replies as well
      nfsd: move nfs4_client allocation to dedicated slabcache

NeilBrown (1):
      SUNRPC: cache: ignore timestamp written to 'flush' file.

Stefan Agner (1):
      nfsd: use correct enum type in decode_cb_op_status

 fs/lockd/svc.c                           |   4 +-
 fs/nfsd/nfs3proc.c                       |  18 +-
 fs/nfsd/nfs3xdr.c                        |  67 ++------
 fs/nfsd/nfs4callback.c                   |   4 +-
 fs/nfsd/nfs4layouts.c                    |  16 +-
 fs/nfsd/nfs4proc.c                       |  38 ++--
 fs/nfsd/nfs4state.c                      | 286 ++++++++++++++-----------------
 fs/nfsd/nfs4xdr.c                        |  22 +--
 fs/nfsd/nfsfh.c                          |  12 +-
 fs/nfsd/nfsproc.c                        |  23 ++-
 fs/nfsd/nfsxdr.c                         |  63 ++++---
 fs/nfsd/trace.h                          |  98 +++++++++--
 fs/nfsd/vfs.c                            |  65 +++----
 fs/nfsd/vfs.h                            |  11 +-
 fs/nfsd/xdr.h                            |   3 +-
 fs/nfsd/xdr3.h                           |   3 +-
 fs/nfsd/xdr4.h                           |   5 +-
 include/linux/sunrpc/svc.h               |   6 +
 include/linux/sunrpc/svc_rdma.h          |   3 -
 include/linux/sunrpc/svc_xprt.h          |   6 +-
 include/trace/events/sunrpc.h            | 204 +++++++++++++---------
 net/sunrpc/auth_gss/gss_krb5_crypto.c    |   3 -
 net/sunrpc/auth_gss/gss_krb5_seal.c      |   5 +-
 net/sunrpc/auth_gss/gss_krb5_unseal.c    |   4 +-
 net/sunrpc/cache.c                       |  32 ++--
 net/sunrpc/svc.c                         | 118 ++++++++++++-
 net/sunrpc/svc_xprt.c                    |  34 ++--
 net/sunrpc/svcsock.c                     |   8 +-
 net/sunrpc/xprtrdma/svc_rdma.c           |   4 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  33 ++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  38 ++--
 31 files changed, 721 insertions(+), 515 deletions(-)
