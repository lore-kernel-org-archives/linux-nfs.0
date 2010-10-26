Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60254 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759027Ab0JZQpu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 12:45:50 -0400
Date: Tue, 26 Oct 2010 12:45:50 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for 2.6.37
Message-ID: <20101026164549.GD19445@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Please pull the following nfsd updates from the for-2.6.37 branch at:

	git://linux-nfs.org/~bfields/linux.git for-2.6.37

Neil Brown modifed the way we wait for upcalls to solve a performance
problem and a long-standing NFSv4 correctness problem.

Pavel Emelyanov started the job of making the NFS client and server
container-aware.  (Note that for the sake of keeping his work in one
tree, Trond and I agreed to merge it through my tree, though it includes
client as well as server changes.)  Thanks to Chuck Lever for help with
review.

Thanks also to Tom Tucker for some rdma fixes (and review help).

I'm continuing work to bring the NFSv4.1 server close enough to the spec
that we could turn it on by default without risking future
interoperability problems.  We're not quite there yet.

A moment's silence for the spkm3 code, please.  It's been lying unused
for years now, so we decided to finally put it out of its misery.

We're also deprecating (not removing quite yet) the old nfsd control
interfaces.

I have a few last-minute changes still under testing that I may try to
sneak in later in the week, but given the short merge window I thought
it would make more sense to send the bulk of the changes now.

--b.

Andy Adamson (1):
      nfsd: remove duplicate NFS4_STATEID_SIZE declaration

Andy Shevchenko (1):
      sunrpc/cache: don't use custom hex_to_bin() converter

Benny Halevy (1):
      nfsd4: adjust buflen for encoded attrs bitmap based on actual bitmap length

Bryan Schumaker (1):
      lockd: Mostly remove BKL from the server

Chuck Lever (2):
      SUNRPC: Use conventional switch statement when reclassifying sockets
      SUNRPC: Properly initialize sock_xprt.srcaddr in all cases

J. Bruce Fields (39):
      svcrpc: minor cache cleanup
      svcrpc: cache deferral cleanup
      Merge remote branch 'trond/bugfixes' into for-2.6.37
      nfsd4: fix hang on fast-booting nfs servers
      nfsd: fix /proc/net/rpc/nfsd.export/content display
      nfsd4: remove spkm3
      nfsd4: minor variable renaming (cb -> conn)
      nfsd4: combine nfs4_rpc_args and nfsd4_cb_sequence
      nfsd4: rename nfs4_rpc_args->nfsd4_cb_args
      nfsd4: generic callback code
      nfsd4: use generic callback code in null case
      nfsd4: remove separate cb_args struct
      nfsd4: Move callback setup to callback queue
      nfsd4: fix alloc_init_session BUILD_BUG_ON()
      nfsd4: fix alloc_init_session return type
      nfsd4: clean up session allocation
      nfsd4: keep per-session list of connections
      nfsd: provide callbacks on svc_xprt deletion
      nfsd4: use callbacks on svc_xprt_deletion
      nfsd4: refactor connection allocation
      nfsd4: add new connections to session
      nfsd4: return expired on unfound stateid's
      nfsd4: expire clients more promptly
      nfsd4: don't cache seq_misordered replies
      nfsd4: move callback setup into session init code
      nfsd4: use client pointer to backchannel session
      nfsd4: make backchannel sequence number per-session
      nfsd4: confirm only on succesful create_session
      nfsd4: track backchannel connections
      nfsd4: callback program number is per-session
      nfsd4: separate callback change and callback probe
      nfsd4: delay session removal till free_client
      nfsd4: move minorversion to client
      nfsd4: only require krb5 principal for NFSv4.0 callbacks
      nfsd4: fix connection allocation in sequence()
      svcrpc: never clear XPT_BUSY on dead xprt
      svcrpc: assume svc_delete_xprt() called only once
      svcrpc: no need for XPT_DEAD check in svc_xprt_enqueue
      svcrpc: svc_tcp_sendto XPT_DEAD check is redundant

NeilBrown (14):
      sunrpc: extract some common sunrpc_cache code from nfsd
      sunrpc: use seconds since boot in expiry cache
      sunrpc/cache: allow threads to block while waiting for cache update.
      sunrpc: close connection when a request is irretrievably lost.
      nfsd: disable deferral for NFSv4
      nfsd/idmap: drop special request deferal in favour of improved default.
      svcauth_gss: replace a trivial 'switch' with an 'if'
      sunrpc/cache: change deferred-request hash table to use hlist.
      sunrpc/cache: fix recent breakage of cache_clean_deferred
      nfsd: formally deprecate legacy nfsd syscall interface
      nfsd: allow deprecated interface to be compiled out.
      sunrpc: fix race in new cache_wait code.
      sunrpc: Simplify cache_defer_req and related functions.
      sunrpc/cache: centralise handling of size limit on deferred list.

Pavel Emelyanov (37):
      nfsd: Export get_task_comm for nfsd
      sunrpc: Pass the ip_map_parse's cd to lower calls
      sunrpc: Make xprt auth cache release work with the xprt
      sunrpc: Pass xprt to cached get/put routines
      sunrpc: Add net to pure API calls
      sunrpc: Add routines that allow registering per-net caches
      sunrpc: Tag svc_xprt with net
      sunrpc: The per-net skeleton
      sunrpc: Make the /proc/net/rpc appear in net namespaces
      sunrpc: Make the ip_map_cache be per-net
      sunrpc: Factor out rpc_xprt allocation
      sunrpc: Factor out rpc_xprt freeing
      sunrpc: Add net argument to svc_create_xprt
      sunrpc: Pull net argument downto svc_create_socket
      sunrpc: Add net to rpc_create_args
      sunrpc: Add net to xprt_create
      sunrpc: Tag rpc_xprt with net
      net: Export __sock_create
      sunrpc: Create sockets in net namespaces
      sunrpc: Use helper to set v4 mapped addr in ip_map_parse
      sunrpc: Remove unused sock arg from xs_get_srcport
      sunrpc: Remove unused sock arg from xs_next_srcport
      sunrpc: Get xprt pointer once in xs_tcp_setup_socket
      sunrpc: Remove duplicate xprt/transport arguments from calls
      sunrpc: Factor out udp sockets creation
      sunrpc: Factor out v4 sockets creation
      sunrpc: Factor out v6 sockets creation
      sunrpc: Call xs_create_sockX directly from setup_socket
      sunrpc: Merge the xs_bind code
      sunrpc: Merge xs_create_sock code
      sunrpc: Pass family to setup_socket calls
      sunrpc: Remove TCP worker wrappers
      sunrpc: Remove UDP worker wrappers
      sunrpc: Remove useless if (task == NULL) from xprt_reserve_xprt
      sunrpc: Don't return NULL from rpcb_create
      sunrpc: Remove dead "else" branch from bc xprt creation
      sunrpc: Turn list_for_each-s into the ..._entry-s

Stephen Rothwell (1):
      sunrpc: fix up rpcauth_remove_module section mismatch

Tejun Heo (1):
      sunrpc/xprtrdma: clean up workqueue usage

Tom Tucker (2):
      svcrdma: Change DMA mapping logic to avoid the page_address kernel API
      svcrdma: Cleanup DMA unmapping in error paths.

 Documentation/feature-removal-schedule.txt |   10 +
 fs/Makefile                                |    5 +-
 fs/compat.c                                |    2 +-
 fs/lockd/host.c                            |    1 +
 fs/lockd/mon.c                             |    1 +
 fs/lockd/svc.c                             |    2 +-
 fs/lockd/svc4proc.c                        |    2 -
 fs/lockd/svclock.c                         |   31 ++-
 fs/lockd/svcproc.c                         |    2 -
 fs/nfs/callback.c                          |    4 +-
 fs/nfs/client.c                            |    1 +
 fs/nfs/dns_resolve.c                       |    6 +-
 fs/nfs/mount_clnt.c                        |    2 +
 fs/nfsd/Kconfig                            |   12 +
 fs/nfsd/export.c                           |   73 +++--
 fs/nfsd/nfs4callback.c                     |  245 ++++++++------
 fs/nfsd/nfs4idmap.c                        |  105 +------
 fs/nfsd/nfs4proc.c                         |    7 +-
 fs/nfsd/nfs4state.c                        |  491 ++++++++++++++++++----------
 fs/nfsd/nfs4xdr.c                          |   18 +-
 fs/nfsd/nfsctl.c                           |   26 ++-
 fs/nfsd/nfsd.h                             |    2 +-
 fs/nfsd/nfssvc.c                           |    5 +-
 fs/nfsd/state.h                            |   52 ++-
 include/linux/net.h                        |    2 +
 include/linux/nfs4.h                       |    3 +
 include/linux/sunrpc/auth.h                |    4 +-
 include/linux/sunrpc/cache.h               |   37 ++-
 include/linux/sunrpc/clnt.h                |    1 +
 include/linux/sunrpc/gss_spkm3.h           |   55 ---
 include/linux/sunrpc/stats.h               |   23 +-
 include/linux/sunrpc/svc_xprt.h            |   32 ++-
 include/linux/sunrpc/svcauth.h             |   17 +-
 include/linux/sunrpc/xprt.h                |    4 +
 net/socket.c                               |    3 +-
 net/sunrpc/Kconfig                         |   19 -
 net/sunrpc/auth.c                          |    2 +-
 net/sunrpc/auth_generic.c                  |    2 +-
 net/sunrpc/auth_gss/Makefile               |    5 -
 net/sunrpc/auth_gss/gss_spkm3_mech.c       |  247 --------------
 net/sunrpc/auth_gss/gss_spkm3_seal.c       |  186 -----------
 net/sunrpc/auth_gss/gss_spkm3_token.c      |  267 ---------------
 net/sunrpc/auth_gss/gss_spkm3_unseal.c     |  127 -------
 net/sunrpc/auth_gss/svcauth_gss.c          |   51 ++--
 net/sunrpc/cache.c                         |  288 ++++++++++++-----
 net/sunrpc/clnt.c                          |    1 +
 net/sunrpc/netns.h                         |   19 +
 net/sunrpc/rpcb_clnt.c                     |    4 +-
 net/sunrpc/stats.c                         |   43 ++-
 net/sunrpc/sunrpc_syms.c                   |   58 +++-
 net/sunrpc/svc.c                           |    3 +
 net/sunrpc/svc_xprt.c                      |   59 +++--
 net/sunrpc/svcauth_unix.c                  |  194 ++++++++---
 net/sunrpc/svcsock.c                       |   27 +-
 net/sunrpc/xprt.c                          |   39 ++-
 net/sunrpc/xprtrdma/svc_rdma.c             |   11 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   19 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   82 ++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   49 ++--
 net/sunrpc/xprtrdma/transport.c            |   25 +-
 net/sunrpc/xprtsock.c                      |  358 +++++++-------------
 61 files changed, 1534 insertions(+), 1937 deletions(-)
 delete mode 100644 include/linux/sunrpc/gss_spkm3.h
 delete mode 100644 net/sunrpc/auth_gss/gss_spkm3_mech.c
 delete mode 100644 net/sunrpc/auth_gss/gss_spkm3_seal.c
 delete mode 100644 net/sunrpc/auth_gss/gss_spkm3_token.c
 delete mode 100644 net/sunrpc/auth_gss/gss_spkm3_unseal.c
 create mode 100644 net/sunrpc/netns.h
