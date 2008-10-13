From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd (and lock) patches for 2.6.28
Date: Mon, 13 Oct 2008 17:38:13 -0400
Message-ID: <20081013213813.GG31876@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50278 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437AbYJMViP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Oct 2008 17:38:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes are available in the git repository at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.28

More preparation for ipv6 support, fast memory registration for the
server rdma code, grace period fixes, and various bugfixes and cleanups.

Also one pure file-locking patch, to make vfs support for file-locking
configurable.

--b.

Benny Halevy (9):
      nfsd: properly xdr-encode stateid4.seqid as uint32_t for cb_recall
      nfsd: properly xdr-encode deleg stateid returned from open
      nfsd: fix nfsd4_encode_open buffer space reservation
      nfsd: nfs4xdr encode_stateid helper function
      nfsd: don't declare p in ENCODE_SEQID_OP_HEAD
      nfsd: properly xdr-decode NFS4_OPEN_CLAIM_DELEGATE_CUR stateid
      nfsd: nfs4xdr decode_stateid helper function
      nfsd: do_probe_callback should not clear rpc stats
      nfsd: use nfs client rpc callback program

Chuck Lever (32):
      SUNRPC: Add address family field to svc_serv data structure
      SUNRPC: Use proper INADDR_ANY when setting up RPC services on IPv6
      SUNRPC: Set V6ONLY socket option for RPC listener sockets
      SUNRPC: Simplify rpcb_register() API
      SUNRPC: Split portmap unregister API into separate function
      SUNRPC: Support IPv6 when registering kernel RPC services
      NLM: Clean up before introducing new debugging messages
      lockd: address-family independent printable addresses
      lockd: Specify address family for source address
      lockd: Add address family-agnostic helper for zeroing the port number
      SUNRPC: Make svc_addr's argument a constant
      lockd: Use sockaddr_storage + length for h_addr field
      lockd: Use sockaddr_storage for h_saddr field
      NSM: Use sockaddr_storage for sm_addr field
      lockd: Teach nlm_cmp_addr() to support AF_INET6 addresses
      lockd: Support AF_INET6 when hashing addresses in nlm_lookup_host
      lockd: Combine __nsm_find() and nsm_find().
      lockd: Update nsm_find() to support non-AF_INET addresses
      SUNRPC: Register both netids for AF_INET6 servers
      SUNRPC: Use short-hand IPv6 ANYADDR for RPCB_SET
      SUNRPC: Fix up svc_unregister()
      SUNRPC: Clean up debug messages in rpcb_clnt.c
      NLM: Convert nlm_lookup_host() to use a single argument
      lockd: Support non-AF_INET addresses in nlm_lookup_host()
      lockd: Adjust nlmclnt_lookup_host() signature to accomodate non-AF_INET
      lockd: Adjust nlmsvc_lookup_host() to accomodate AF_INET6 addresses
      lockd: change nlmclnt_grant() to take a "struct sockaddr *"
      lockd: Add helper to sanity check incoming NOTIFY requests
      lockd: Remove unused fields in the nlm_reboot structure
      NLM: Always start both UDP and TCP listeners
      NLM: Remove "proto" argument from lockd_up()
      NLM: Remove unused argument from svc_addsock() function

J. Bruce Fields (7):
      nfsd: permit unauthenticated stat of export root
      locks: allow lockd to process blocked locks during grace period
      lockd: don't depend on lockd main loop to end grace
      nfsd: common grace period control
      lockd: move grace period checks to common code
      lockd: reject reclaims outside the grace period
      Merge branch 'from-tomtucker' into for-2.6.28

Jeff Layton (1):
      knfsd: allocate readahead cache in individual chunks

Thomas Petazzoni (1):
      Configure out file locking features

Tom Tucker (10):
      svcrdma: Add Fast Reg MR Data Types
      svcrdma: Add FRMR get/put services
      svcrdma: Query device for Fast Reg support during connection setup
      svcrdma: Add a service to register a Fast Reg MR with the device
      svcrdma: Modify post recv path to use local dma key
      svcrdma: Add support to svc_rdma_send to handle chained WR
      svcrdma: Modify the RPC recv path to use FRMR when available
      svcrdma: Modify the RPC reply path to use FRMR when available
      svcrdma: Update svc_rdma_send_error to use DMA LKEY
      svcrdma: Fix IRD/ORD polarity

 fs/Kconfig                               |   30 +++
 fs/Makefile                              |    3 +-
 fs/lockd/Makefile                        |    2 +-
 fs/lockd/clntlock.c                      |   13 +-
 fs/lockd/grace.c                         |   59 +++++
 fs/lockd/host.c                          |  350 +++++++++++++++++++++--------
 fs/lockd/mon.c                           |    2 +-
 fs/lockd/svc.c                           |   88 +++----
 fs/lockd/svc4proc.c                      |   31 +--
 fs/lockd/svclock.c                       |   18 ++-
 fs/lockd/svcproc.c                       |   31 +--
 fs/lockd/svcsubs.c                       |    2 +-
 fs/lockd/xdr.c                           |    2 -
 fs/lockd/xdr4.c                          |    2 -
 fs/nfs/callback.c                        |    3 +-
 fs/nfsd/lockd.c                          |    1 -
 fs/nfsd/nfs3proc.c                       |    8 +-
 fs/nfsd/nfs4callback.c                   |    7 +-
 fs/nfsd/nfs4proc.c                       |    8 +-
 fs/nfsd/nfs4state.c                      |   34 ++--
 fs/nfsd/nfs4xdr.c                        |  171 +++++++-------
 fs/nfsd/nfsctl.c                         |    5 +-
 fs/nfsd/nfsfh.c                          |   30 ++-
 fs/nfsd/nfsproc.c                        |    6 +-
 fs/nfsd/nfssvc.c                         |   20 +-
 fs/nfsd/vfs.c                            |   63 +++--
 fs/proc/proc_misc.c                      |    4 +
 include/linux/fs.h                       |   65 +++++-
 include/linux/lockd/bind.h               |   11 +-
 include/linux/lockd/lockd.h              |  137 ++++++++++-
 include/linux/lockd/xdr.h                |    2 -
 include/linux/nfsd/nfsd.h                |    3 +-
 include/linux/sunrpc/clnt.h              |    5 +-
 include/linux/sunrpc/svc.h               |   19 +-
 include/linux/sunrpc/svc_rdma.h          |   27 ++-
 include/linux/sunrpc/svcsock.h           |    5 +-
 kernel/sys_ni.c                          |    1 +
 kernel/sysctl.c                          |    6 +-
 net/sunrpc/clnt.c                        |    2 +-
 net/sunrpc/rpcb_clnt.c                   |   81 +++----
 net/sunrpc/svc.c                         |  251 ++++++++++++++++++---
 net/sunrpc/svc_xprt.c                    |   39 +++-
 net/sunrpc/svcsock.c                     |   17 ++-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  187 ++++++++++++++--
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  255 ++++++++++++++++++----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  364 +++++++++++++++++++++++++-----
 46 files changed, 1842 insertions(+), 628 deletions(-)
 create mode 100644 fs/lockd/grace.c
