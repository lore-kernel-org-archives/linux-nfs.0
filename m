From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/23] Shorter series for 2.6.30
Date: Wed, 18 Mar 2009 20:45:17 -0400
Message-ID: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:65509 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757355AbZCSAqa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:46:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond, Bruce-

Since Trond has sent some late-breaking patches for 2.6.29, I had to
fix some merge problems with my latest patch set.  Jeff also found a
minor bug with rpcbind version 4 replies that I'd like to include.

I've stripped this patch set down so it is just 23 patches.
Unfortunately, it touches server-side RPC stuff and client-side NFSv4
callback and lockd support.  I don't see a clean way to split these up.

Can we discuss how to get these into 2.6.30?  Perhaps, since these have
the greatest impact on client behavior, Trond should take all of these?

---

Chuck Lever (23):
      NFS: Simplify logic to compare socket addresses in client.c
      NFS: Start PF_INET6 callback listener only if IPv6 support is available
      lockd: Start PF_INET6 listener only if IPv6 support is available
      SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
      SUNRPC: rpcb_register() should handle errors silently
      SUNRPC: Simplify kernel RPC service registration
      SUNRPC: Simplify svc_unregister()
      SUNRPC: Allow callers to pass rpcb_v4_register a NULL address
      SUNRPC: rpcbind actually interprets r_owner string
      SUNRPC: Clean up address type casts in rpcb_v4_register()
      SUNRPC: Don't return EPROTONOSUPPORT in svc_register()'s helpers
      SUNRPC: Use IPv4 loopback for registering AF_INET6 kernel RPC services
      SUNRPC: Set IPV6ONLY flag on PF_INET6 RPC listener sockets
      NFS: Revert creation of IPv6 listeners for lockd and NFSv4 callbacks
      SUNRPC: Remove @family argument from svc_create() and svc_create_pooled()
      SUNRPC: Change svc_create_xprt() to take a @family argument
      SUNRPC: svc_setup_socket() gets protocol family from socket
      SUNRPC: Pass a family argument to svc_register()
      SUNRPC: Clean up svc_find_xprt() calling sequence
      NFSD: If port value written to /proc/fs/nfsd/portlist is invalid, return EINVAL
      SUNRPC: Clean up static inline functions in svc_xprt.h
      SUNRPC: Fix return type of svc_addr_len()
      SUNRPC: Don't flag empty RPCB_GETADDR reply as bogus


 fs/lockd/clntlock.c                      |   51 ----------
 fs/lockd/svc.c                           |   42 ++++----
 fs/nfs/callback.c                        |   31 +++---
 fs/nfs/callback.h                        |    1 
 fs/nfs/client.c                          |  116 ++++++++++------------
 fs/nfs/nfs4state.c                       |   10 ++
 fs/nfsd/nfsctl.c                         |    6 +
 fs/nfsd/nfssvc.c                         |    5 -
 include/linux/sunrpc/svc.h               |    9 +-
 include/linux/sunrpc/svc_xprt.h          |   55 ++++++----
 net/sunrpc/Kconfig                       |   22 ----
 net/sunrpc/rpcb_clnt.c                   |  103 +++++++++++---------
 net/sunrpc/svc.c                         |  158 ++++++++++++++----------------
 net/sunrpc/svc_xprt.c                    |   31 ++++--
 net/sunrpc/svcsock.c                     |   14 +--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 +++
 16 files changed, 314 insertions(+), 356 deletions(-)

-- 
Chuck Lever
