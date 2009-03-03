From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/17] Proposed fix for blacklisted ipv6.ko
Date: Tue, 03 Mar 2009 17:32:06 -0500
Message-ID: <20090303220539.2933.15015.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org, steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:52913 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959AbZCCWdG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 17:33:06 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm prototyping a different solution for handling the case where the
ipv6 module is not loadable at run-time.

Instead of the single RPC listener socket model that handles requests
of both address families, I've changed the kernel RPC server to use
PF_INET-only and PF_INET6-only sockets.  Each service always starts
PF_INET listeners, then tries to start PF_INET6 listeners.  If the
PF_INET6 transport creation call fails with -EAFNOSUPPORT, the error
is ignored and we are left with just the PF_INET listener.

For the case when no IPv6 support is built into the kernel, this
degenerates to exactly the same code paths and behaviors we have
today with PF_INET.

This solution is a bit more general than using a single listener.  If
we ever have to support another address family (say, AF_IPX, for
example) we just add another svc_create_xprt() call where needed.

This is also much the same as TI-RPC -- inet6 listeners run alongside
IPv4 listeners, and do not handle the same traffic.

This has the benefit that requests coming in on a PF_INET6 listener
will never see mapped IPv4 addresses.  Thus we can always use a simple
straightforward address comparison for NFSv4 and NLM callbacks -- both
addresses (the incoming request and the server host address) have to
be of the same family.

This approach adopts the same internal API changes as before:
svc_create() no longer takes an address family argument.  It's passed
in to svc_create_xprt().  This matches up with svc_find_xprt(), which
takes an address family when searching for an existing transport.

I've done some light testing, so how about a little review of this
approach?  Some of these patches are recycled, thus it won't be
entirely unfamiliar if you've looked at earlier proposals.

I'd appreciate some quick perusal of this work since 2.6.30 is coming
soon.  I'd like to have a decision between this approach and the
previous approach (retry with PF_INET if PF_INET6 creation fails)
so we can proceed with addressing this in 2.6.30.

Thanks!

---

Chuck Lever (17):
      NFS: Start PF_INET6 callback listener only if IPv6 support is available
      lockd: Start PF_INET6 listener only if IPv6 support is available
      SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
      SUNRPC: rpcb_register() should handle errors silently
      SUNRPC: Simplify kernel RPC service registration
      SUNRPC: Simplify svc_unregister()
      SUNRPC: Allow callers to pass rpcb_v4_register a NULL address
      SUNRPC: Use "0" as r_owner
      SUNRPC: Clean up address type casts in rpcb_v4_register()
      SUNRPC: Don't return EPROTONOSUPPORT in svc_register()'s helpers
      SUNRPC: Use IPv4 loopback for registering AF_INET6 kernel RPC services
      SUNRPC: Set IPV6ONLY flag on PF_INET6 RPC listener sockets
      NFS: Revert creation of IPv6 listeners for lockd and NFSv4 callbacks
      SUNRPC: Remove @family argument from svc_create() and svc_create_pooled()
      SUNRPC: Change svc_create_xprt() to take a @family argument
      SUNRPC: svc_setup_socket() gets protocol family from socket
      SUNRPC: Pass a family argument to svc_register()


 fs/lockd/svc.c                  |   40 +++++-----
 fs/nfs/callback.c               |   31 ++++----
 fs/nfs/callback.h               |    1 
 fs/nfs/nfs4state.c              |   10 ++
 fs/nfsd/nfsctl.c                |    2 
 fs/nfsd/nfssvc.c                |    5 -
 include/linux/sunrpc/svc.h      |    9 +-
 include/linux/sunrpc/svc_xprt.h |    3 -
 net/sunrpc/Kconfig              |   22 -----
 net/sunrpc/rpcb_clnt.c          |   85 +++++++++++----------
 net/sunrpc/svc.c                |  158 ++++++++++++++++++---------------------
 net/sunrpc/svc_xprt.c           |   15 ++--
 net/sunrpc/svcsock.c            |   14 +--
 13 files changed, 188 insertions(+), 207 deletions(-)

-- 
Chuck Lever
