From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd patches for 2.6.25
Date: Fri, 1 Feb 2008 18:28:29 -0500
Message-ID: <20080201232828.GE1233@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:53939 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761564AbYBAX2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2008 18:28:48 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes are available from the for-linus branch of the git
repository at:

  git://linux-nfs.org/~bfields/linux.git for-linus

The largest single change is the addition of rdma support for nfsd, and
the preceding major refactoring of the server rpc code to add a
transport api.  The rest is mostly smaller cleanup and bugfixes.

--b.

Chuck Lever (10):
      SUNRPC: Prevent length underflow in read_flush()
      SUNRPC: Use unsigned string lengths in xdr_decode_string_inplace
      NLM: Fix sign of length of NLM variable length strings
      NFSD: Use unsigned length argument for decode_filename
      NFSD: File name length signage in nfsd request argument structures
      NFSD: Adjust filename length argument of nfsd_lookup
      NFSD: Use unsigned length argument for decode_pathname
      NFSD: Fix mixed sign comparison in nfs3svc_decode_symlinkargs
      NFSD: Path name length signage in nfsd request argument structures
      SUNRPC: RPC program information is stored in unsigned integers

Frank Filz (1):
      nfsd: Allow AIX client to read dir containing mountpoints

J. Bruce Fields (34):
      nfsd4: probe callback channel only once
      nfsd: move callback rpc_client creation into separate thread
      knfsd: fix broken length check in nfs4idmap.c
      knfsd: fix cache.c comment
      nfsd: Fix handling of negative lengths in read_buf()
      knfsd: cleanup nfsd4 properly on module init failure
      nfsd: cleanup nfsd module initialization cleanup
      nfsd: fail module init on reply cache init failure
      knfsd: cache unregistration needn't return error
      nfsd: select CONFIG_PROC_FS in nfsv4 and gss server cases
      nfsd: fail init on /proc/fs/nfs/exports creation failure
      nfsd: move cache proc (un)registration to separate function
      knfsd: allow cache_register to return error on failure
      nfsd: move nfsd/auth.h into fs/nfsd
      nfsd: minor fs/nfsd/auth.h cleanup
      nfsd4: kill some unneeded setclientid comments
      nfsd: eliminate final bogus case from setclientid logic
      nfsd: uniquify cl_confirm values
      nfsd4: kill unnecessary same_name() in setclientid_confirm
      nfsd4: remove unnecessary cl_verifier check from setclientid_confirm
      nfsd4: kill unneeded cl_confirm check
      nfsd: fix encode_entryplus_baggage() indentation
      nfsd4: make current_clientid local
      nfsd4: miscellaneous nfs4state.c style fixes
      nfsd4: recognize callback channel failure earlier
      nfsd4: fix bad seqid on lock request incompatible with open mode
      nfsd: allow root to set uid and gid on create
      nfsd: fix rsi_cache reference count leak
      sunrpc: gss: simplify rsi_parse logic
      nfsd4: clean up access_valid, deny_valid checks.
      svcrpc: ensure gss DESTROY tokens free contexts from cache
      knfsd: don't bother mapping putrootfh enoent to eperm
      lockd: minor log message fix
      nfsd: more careful input validation in nfsctl write methods

Jeff Layton (2):
      SUNRPC: spin svc_rqst initialization to its own function
      NLM: tear down RPC clients in nlm_shutdown_hosts

Neil Brown (1):
      knfsd: change mailing list for nfsd in MAINTAINERS

Oleg Drokin (3):
      lockd: fix reference count leaks in async locking case
      lockd: fix a leak in nlmsvc_testlock asynchronous request handling
      Leak in nlmsvc_testlock for async GETFL case

Prasad P (1):
      nfsd: Fix inconsistent assignment

Tom Tucker (47):
      svc: Add an svc transport class
      svc: Make svc_sock the tcp/udp transport
      svc: Change the svc_sock in the rqstp structure to a transport
      svc: Add a max payload value to the transport
      svc: Move sk_sendto and sk_recvfrom to svc_xprt_class
      svc: Add transport specific xpo_release function
      svc: Add per-transport delete functions
      svc: Add xpo_prep_reply_hdr
      svc: Add a transport function that checks for write space
      svc: Move close processing to a single place
      svc: Add xpo_accept transport function
      svc: Remove unnecessary call to svc_sock_enqueue
      svc: Move connection limit checking to its own function
      svc: Add a generic transport svc_create_xprt function
      svc: Change services to use new svc_create_xprt service
      svc: Change sk_inuse to a kref
      svc: Move sk_flags to the svc_xprt structure
      svc: Move sk_server and sk_pool to svc_xprt
      svc: Make close transport independent
      svc: Move sk_reserved to svc_xprt
      svc: Make the enqueue service transport neutral and export it.
      svc: Make svc_send transport neutral
      svc: Change svc_sock_received to svc_xprt_received and export it
      svc: Move accept call to svc_xprt_received to common code
      svc: Remove sk_lastrecv
      svc: Move the authinfo cache to svc_xprt.
      svc: Make deferral processing xprt independent
      svc: Move the sockaddr information to svc_xprt
      svc: Make svc_sock_release svc_xprt_release
      svc: Make svc_recv transport neutral
      svc: Make svc_age_temp_sockets svc_age_temp_transports
      svc: Move create logic to common code
      svc: Removing remaining references to rq_sock in rqstp
      svc: Make svc_check_conn_limits xprt independent
      svc: Move the xprt independent code to the svc_xprt.c file
      svc: Add transport hdr size for defer/revisit
      svc: Add /proc/sys/sunrpc/transport files
      svc: Add svc API that queries for a transport instance
      knfsd: Support adding transports by writing portlist file
      svc: Add svc_xprt_names service to replace svc_sock_names
      rdma: SVCRMDA Header File
      rdma: SVCRDMA Transport Module
      rdma: SVCRDMA Core Transport Services
      rdma: SVCRDMA recvfrom
      rdma: SVCRDMA sendto
      rdma: ONCRPC RDMA protocol marshalling
      rdma: makefile

Trond Myklebust (1):
      SUNRPC: Move exported symbol definitions after function declaration part 2

 MAINTAINERS                              |    2 +-
 fs/Kconfig                               |    2 +
 fs/lockd/host.c                          |   26 +-
 fs/lockd/svc.c                           |   39 +-
 fs/lockd/svc4proc.c                      |   20 +-
 fs/lockd/svclock.c                       |   20 +-
 fs/lockd/svcproc.c                       |   22 +-
 fs/lockd/svcsubs.c                       |    2 +-
 fs/nfs/callback.c                        |    4 +-
 {include/linux => fs}/nfsd/auth.h        |    5 -
 fs/nfsd/export.c                         |   20 +-
 fs/nfsd/nfs2acl.c                        |    7 +-
 fs/nfsd/nfs3xdr.c                        |   21 +-
 fs/nfsd/nfs4callback.c                   |   92 +--
 fs/nfsd/nfs4idmap.c                      |   28 +-
 fs/nfsd/nfs4proc.c                       |    2 +-
 fs/nfsd/nfs4state.c                      |  257 +++----
 fs/nfsd/nfs4xdr.c                        |   36 +-
 fs/nfsd/nfscache.c                       |   28 +-
 fs/nfsd/nfsctl.c                         |  124 +++-
 fs/nfsd/nfsfh.c                          |    1 +
 fs/nfsd/nfssvc.c                         |    8 +-
 fs/nfsd/nfsxdr.c                         |    9 +-
 fs/nfsd/vfs.c                            |   51 +-
 include/linux/lockd/lockd.h              |    9 +-
 include/linux/lockd/xdr.h                |    4 +-
 include/linux/nfsd/Kbuild                |    1 -
 include/linux/nfsd/cache.h               |    4 +-
 include/linux/nfsd/export.h              |    2 +-
 include/linux/nfsd/nfsd.h                |    5 +-
 include/linux/nfsd/syscall.h             |    1 -
 include/linux/nfsd/xdr.h                 |   14 +-
 include/linux/nfsd/xdr3.h                |   16 +-
 include/linux/nfsd/xdr4.h                |    2 +-
 include/linux/nfsd_idmap.h               |   11 +-
 include/linux/sunrpc/cache.h             |    4 +-
 include/linux/sunrpc/debug.h             |    2 +-
 include/linux/sunrpc/svc.h               |   10 +-
 include/linux/sunrpc/svc_rdma.h          |  262 ++++++
 include/linux/sunrpc/svc_xprt.h          |  159 ++++
 include/linux/sunrpc/svcsock.h           |   43 +-
 include/linux/sunrpc/xdr.h               |    3 +-
 net/sunrpc/Makefile                      |    3 +-
 net/sunrpc/auth_gss/svcauth_gss.c        |   93 ++-
 net/sunrpc/cache.c                       |  152 +++--
 net/sunrpc/stats.c                       |    7 +-
 net/sunrpc/sunrpc_syms.c                 |   52 +--
 net/sunrpc/svc.c                         |   90 ++-
 net/sunrpc/svc_xprt.c                    | 1055 ++++++++++++++++++++++++
 net/sunrpc/svcauth.c                     |    6 +
 net/sunrpc/svcauth_unix.c                |   61 +-
 net/sunrpc/svcsock.c                     | 1311 +++++++-----------------------
 net/sunrpc/sysctl.c                      |   31 +
 net/sunrpc/xdr.c                         |    8 +-
 net/sunrpc/xprtrdma/Makefile             |    5 +
 net/sunrpc/xprtrdma/svc_rdma.c           |  266 ++++++
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |  412 ++++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  586 +++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  520 ++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 1080 ++++++++++++++++++++++++
 60 files changed, 5451 insertions(+), 1665 deletions(-)
 rename {include/linux => fs}/nfsd/auth.h (87%)
 create mode 100644 include/linux/sunrpc/svc_rdma.h
 create mode 100644 include/linux/sunrpc/svc_xprt.h
 create mode 100644 net/sunrpc/svc_xprt.c
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma.c
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_marshal.c
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_sendto.c
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_transport.c
