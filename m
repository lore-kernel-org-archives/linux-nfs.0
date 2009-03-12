From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/40] Proposed patches for 2.6.30
Date: Thu, 12 Mar 2009 12:06:56 -0400
Message-ID: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:29906 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbZCLQHp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:07:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond-

Here are the IPv6-related patches I'd like to propose for inclusion
in 2.6.30.  These include fixes for IPv6 support in the kernel's
rpcbind client, in lockd, and in the NFSv4 callback server, plus a
lot of clean up.  Many of these have had some revision since the
patches you [Bruce] looked at yesterday (which were sent a couple of
weeks ago).

I'm reserving the final few NFSD IPv6 patches until we have user space
IPv6 support on the server side and we can start testing.

Note that there are two patches Trond sent for 2.6.29-rc that don't
seem to be in Linus' tree yet.  That may cause a little heartburn if
you try to add these to your tree today.  However, since 2.6.30 is
imminent, I thought it best to present these for review now.

The main feature of these patches is that the single address family
listener strategy is abandoned in favor of using separate listeners
for AF_INET and AF_INET6.  This has two main benefits:

 1.  Kernel RPC servers no longer have to deal with mapped v4 addresses
     coming from the network layer, and

 2.  PF_INET listeners are always started; PF_INET6 listeners are
     started if possible.  This allows people to disable IPv6
     support cleanly by blacklisting ipv6.ko, but should have no
     affect on normal IPv4 operation.

This new scheme can be used to add support for additional address
families, unlike the single-listener-per-af scheme.

We also get rid of CONFIG_SUNRPC_REGISTER_V4 entirely.  The kernel can
handle either portmapper or rpcbind in user space automatically now.

These have seen light testing, and previous versions of this patch set
have been exercised at Connectathon.

---

Chuck Lever (40):
      NFSD: Prevent buffer overflow in write_recoverydir()
      NFSD: Prevent buffer overflow in write_leasetime()
      NFSD: Prevent buffer overflow in write_maxblksize()
      NFSD: Prevent buffer overflow in write_versions()
      NFSD: Prevent buffer overflow in write_threads()
      NFSD: Support IPv6 addresses in write_failover_ip()
      NFS: Move NFS client's IP address parser to nfs_common/
      SUNRPC: Clean up one_sock_name()
      SUNRPC: Support PF_INET6 in one_sock_name()
      SUNRPC: Switch one_sock_name() to use snprintf()
      SUNRPC: pass buffer size to svc_sock_names()
      SUNRPC: pass buffer size to svc_addsock()
      NFSD: Prevent a buffer overflow in svc_xprt_names()
      NFSD: move lockd_up() before svc_addsock()
      NFSD: Finish refactoring __write_ports()
      NFSD: Note an additional requirement when passing TCP sockets to portlist
      NFSD: Refactor socket creation out of __write_ports()
      NFSD: Refactor portlist socket closing into a helper
      NFSD: Refactor transport addition out of __write_ports()
      NFSD: Refactor transport removal out of __write_ports()
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
      SUNRPC: Clean up static inline functions in svc_xprt.h
      SUNRPC: Fix return type of svc_addr_len()


 fs/lockd/clntlock.c                      |   51 -----
 fs/lockd/svc.c                           |   42 ++--
 fs/nfs/callback.c                        |   31 ++-
 fs/nfs/callback.h                        |    1 
 fs/nfs/client.c                          |   69 +++----
 fs/nfs/internal.h                        |    3 
 fs/nfs/nfs4namespace.c                   |    2 
 fs/nfs/nfs4state.c                       |   10 +
 fs/nfs/super.c                           |  121 ------------
 fs/nfs_common/Makefile                   |    1 
 fs/nfs_common/nfs_addr_parse.c           |  151 +++++++++++++++
 fs/nfsd/nfsctl.c                         |  298 +++++++++++++++++-------------
 fs/nfsd/nfssvc.c                         |    5 -
 include/linux/nfs_addr_parse.h           |   29 +++
 include/linux/sunrpc/svc.h               |    9 -
 include/linux/sunrpc/svc_xprt.h          |   57 +++---
 include/linux/sunrpc/svcsock.h           |    7 +
 net/sunrpc/Kconfig                       |   22 --
 net/sunrpc/rpcb_clnt.c                   |   92 +++++----
 net/sunrpc/svc.c                         |  158 +++++++---------
 net/sunrpc/svc_xprt.c                    |   87 ++++++---
 net/sunrpc/svcsock.c                     |   94 +++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 +-
 23 files changed, 743 insertions(+), 613 deletions(-)
 create mode 100644 fs/nfs_common/nfs_addr_parse.c
 create mode 100644 include/linux/nfs_addr_parse.h

-- 
Chuck Lever
