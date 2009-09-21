From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd changes for 2.6.32
Date: Mon, 21 Sep 2009 16:57:41 -0400
Message-ID: <20090921205741.GJ12827@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245AbZIUU5h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2009 16:57:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following nfsd changes from the for-2.6.32 branch at:

	git://linux-nfs.org/~bfields/linux.git for-2.6.32

Incremental nfsv4.1 progress continues, with a rewrite (and
simplification) of the new sessions-based duplicate reply cache, and
addition of preliminary support for the nfsv4.1 backchannel, which will
allow rpc callbacks to the client--used for recall of delegations or,
eventually, pnfs layouts--to use the client's preexisting tcp
connection.

Also some ipv6 work, and miscellaneous bug fixes and cleanup.

Thanks to all contributors!

--b.

Alexandros Batsakis (3):
      nfsd41: sunrpc: svc_tcp_recv_record()
      nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel
      nfsd41: modify nfsd4.1 backchannel to use new xprt class

Andy Adamson (16):
      nfsd41: use globals for DRC limits
      nfsd41: reclaim DRC memory on session free
      nfsd41: minor set_forechannel_maxreqs cleanup
      nfsd41: reserve less memory for DRC
      nfsd41: hange from page to memory based drc limits
      nfsd41: remove redundant forechannel max requests check
      nfsd41: change check_slot_seqid parameters
      nfsd41: Use separate DRC for setclientid
      nfsd41: rename nfsd4_enc_uncached_replay
      nfsd41: encode replay sequence from the slot values
      nfsd41: expand solo sequence check
      nfsd41: bound forechannel drc size by memory usage
      nfsd41: use session maxreqs for sequence target and highest slotid
      nfsd41: replace nfserr_resource in pure nfs41 responses
      nfsd41: replace page based DRC with buffer based DRC
      nfsd41: Backchannel: callback infrastructure

Benny Halevy (5):
      nfsd41: gather and report statistics also for v4.1 ops
      nfsd41: renew_client must be called under the state lock
      nfsd41: sunrpc: move struct rpc_buffer def into sunrpc.h
      nfsd4: fix whitespace in NFSPROC4_CLNT_CB_NULL definition
      nfsd41: Backchannel: cb_sequence callback

Chuck Lever (1):
      SUNRPC: handle IPv6 PKTINFO when extracting destination address

Eric Sesterhenn (1):
      Fix memory leak in write_pool_threads

Frank Filz (2):
      nfsd: Fix unnecessary deny bits in NFSv4 ACL
      nfsd4: remove ACE4_IDENTIFIER_GROUP flag from GROUP@ entry

J. Bruce Fields (11):
      nfsd: minor write_pool_threads exit cleanup
      Merge branch 'nfs-for-2.6.32' of git://git.linux-nfs.org/projects/trondmy/nfs-2.6 into for-2.6.32-incoming
      nfsd: move some of fh_compose into helper functions
      nfsd: move fsid_type choice out of fh_compose
      nfsd4: filehandle leak or error exit from fh_compose()
      nfsd: clean up readdirplus encoding
      nfsd: fix leak on error in nfsv3 readdir
      nfsd4: fix null dereference creating nfsv4 callback client
      nfsd4: allow nfs4 state startup to fail
      nfsd4: use common rpc_cred for all callbacks
      nfsd: revise 4.1 status documentation

Jeff Layton (6):
      sunrpc: add routine for comparing addresses
      sunrpc: add common routine for copying address portion of a sockaddr
      nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
      nfsd: convert nfs4_cb_conn struct to hold address in sockaddr_storage
      nfsd: add support for NFSv4 callbacks over IPv6
      nfsd: populate sin6_scope_id on callback address with scopeid from rq_addr on SETCLIENTID call

NeilBrown (8):
      sunrpc/cache: rename queue_loose to cache_dequeue
      sunrpc/cache: make sure deferred requests eventually get revisited.
      sunrpc/cache: recheck cache validity after cache_defer_req
      sunrpc: fix memory leak in unix_gid cache.
      sunrpc/cache: change cache_defer_req to return -ve error, not boolean.
      sunrpc/cache: simplify cache_fresh_locked and cache_fresh_unlocked.
      sunrpc/cache: use list_del_init for the list_head entries in cache_deferred_req
      sunrpc/cache: avoid variable over-loading in cache_defer_req

Rahul Iyer (1):
      nfsd41: sunrpc: Added rpc server-side backchannel handling

Ricardo Labiaga (5):
      nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
      nfsd41: Backchannel: Server backchannel RPC wait queue
      nfsd41: Backchannel: Setup sequence information
      nfsd41: Backchannel: Implement cb_recall over NFSv4.1
      nfsd41: Refactor create_client()

Ryusei Yamaguchi (1):
      knfsd: Replace lock_kernel with a mutex in nfsd pool stats.

Stephen Rothwell (1):
      nfsd: return success for non-NFS4 nfs4_state_start

Steve Dickson (1):
      nfsd4: nfsv4 clients should cross mountpoints

Trond Myklebust (3):
      NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory attribute
      NFSd: Fix filehandle leak in exp_pseudoroot() and nfsd4_path()
      SUNRPC: Defer the auth_gss upcall when the RPC call is asynchronous

Wei Yongjun (3):
      svcrdma: fix error handling of rdma_alloc_frmr()
      sunrpc: reply AUTH_BADCRED to RPCSEC_GSS with unknown service
      sunrpc: move the close processing after do recvfrom method

Yu Zhiguo (1):
      NFSv4: ACL in operations 'open' and 'create' should be used

 Documentation/filesystems/nfs41-server.txt |   54 +++
 fs/lockd/clntlock.c                        |    2 +-
 fs/lockd/host.c                            |    4 +-
 fs/lockd/mon.c                             |    2 +-
 fs/lockd/svcsubs.c                         |    2 +-
 fs/nfsd/export.c                           |    2 +
 fs/nfsd/nfs3xdr.c                          |   75 ++--
 fs/nfsd/nfs4acl.c                          |    4 +-
 fs/nfsd/nfs4callback.c                     |  263 +++++++++--
 fs/nfsd/nfs4proc.c                         |   89 ++--
 fs/nfsd/nfs4state.c                        |  681 +++++++++++++---------------
 fs/nfsd/nfs4xdr.c                          |   42 +-
 fs/nfsd/nfsctl.c                           |    8 +-
 fs/nfsd/nfsfh.c                            |  158 ++++---
 fs/nfsd/nfssvc.c                           |   54 ++-
 fs/nfsd/vfs.c                              |    9 +-
 include/linux/lockd/lockd.h                |   43 --
 include/linux/nfs4.h                       |    2 +-
 include/linux/nfsd/nfsd.h                  |    7 +-
 include/linux/nfsd/state.h                 |   77 +++-
 include/linux/nfsd/xdr4.h                  |   19 +-
 include/linux/sunrpc/auth.h                |    4 +-
 include/linux/sunrpc/clnt.h                |  114 +++++
 include/linux/sunrpc/svc.h                 |    2 -
 include/linux/sunrpc/svc_xprt.h            |    1 +
 include/linux/sunrpc/svcsock.h             |    1 +
 include/linux/sunrpc/xprt.h                |   19 +
 include/linux/sunrpc/xprtrdma.h            |    5 -
 include/linux/sunrpc/xprtsock.h            |   11 -
 net/sunrpc/auth.c                          |   20 +-
 net/sunrpc/auth_generic.c                  |    4 +-
 net/sunrpc/auth_gss/svcauth_gss.c          |    6 +-
 net/sunrpc/cache.c                         |  109 +++--
 net/sunrpc/clnt.c                          |    1 +
 net/sunrpc/sched.c                         |    7 +-
 net/sunrpc/sunrpc.h                        |   14 +
 net/sunrpc/svc_xprt.c                      |   25 +-
 net/sunrpc/svcauth_unix.c                  |    1 +
 net/sunrpc/svcsock.c                       |  335 ++++++++++----
 net/sunrpc/xprt.c                          |   15 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |    4 +-
 net/sunrpc/xprtsock.c                      |  242 ++++++++++-
 42 files changed, 1640 insertions(+), 897 deletions(-)
