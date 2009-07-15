Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38849
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751801AbZGOVgx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:36:53 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] Add generic socket address management to sunrpc.ko
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Jul 2009 17:36:32 -0400
Message-ID: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

This set of patches, for 2.6.32, introduces a set of exported
functions to sunrpc.ko for converting between a socket address and
either a standard presentation address string or an RPC universal
address.

The universal address functions will be used to encode and decode
RPCB_FOO and NFSv4 SETCLIENTID arguments.  The other functions are
part of a previous promise to deliver shared functions that can be
used by upper-layer protocols to display and manipulate IP
addresses.

The kernel's current printf formatters for IP addresses (%pI4 and
%pI6) were designed specifically for kernel to user-space APIs that
require a particular string format for socket addresses.  Thus they
are somewhat limited for the purposes of RPC.  The formatter for IPv6
addresses, %pI6, does not support short-handing (see RFC 4291) or
IPv6 scope IDs.  Also, these printf formatters are unique per address
family, so separate formatter strings are required for printing
AF_INET and AF_INET6 addresses.

These patches have seen light testing here, and are also available
in the cel-2.6.git linux.nfs.org repository under cel-ipv6-07152009.

The last patch in this series might go to Bruce, but it depends on
the previous 9 here.

---

Chuck Lever (10):
      NFSD: Support IPv6 addresses in write_failover_ip()
      lockd: Replace nsm_display_address() with rpc_ntop()
      lockd: Replace nlm_clear_port()
      NFS: Replace nfs_set_port() with rpc_set_port()
      NFS: Replace nfs_parse_ip_address() with rpc_pton()
      SUNRPC: Use rpc_ntop() for constructing transport address strings
      SUNRPC: Remove duplicate universal address generation
      SUNRPC: Provide functions for managing universal addresses
      SUNRPC: Move XDR data type size macros
      SUNRPC: Clean up RPCBIND_MAXUADDRLEN definitions


 fs/lockd/host.c                 |   14 -
 fs/lockd/mon.c                  |   44 ---
 fs/nfs/internal.h               |   22 --
 fs/nfs/nfs4namespace.c          |    8 -
 fs/nfs/super.c                  |  154 ++---------
 fs/nfsd/nfsctl.c                |   21 +-
 include/linux/sunrpc/clnt.h     |   12 +
 include/linux/sunrpc/msg_prot.h |   18 +
 include/linux/sunrpc/xprt.h     |    1 
 net/sunrpc/Makefile             |    2 
 net/sunrpc/addr.c               |  524 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/rpcb_clnt.c          |  104 ++++----
 net/sunrpc/xprtrdma/transport.c |   53 +---
 net/sunrpc/xprtsock.c           |  127 +++------
 14 files changed, 705 insertions(+), 399 deletions(-)
 create mode 100644 net/sunrpc/addr.c

-- 
Chuck Lever <chuck.lever@oracle.com>
