Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:42687
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751864AbZHETjz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 15:39:55 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] Add generic socket address management to sunrpc.ko
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2009 15:39:49 -0400
Message-ID: <20090805193709.3359.34559.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

This set of patches, for 2.6.32, introduces a set of exported
functions to sunrpc.ko for converting between a socket address and
either a standard presentation address string or an RPC universal
address.

This is the second take for this set.  I hope I've responded
appropriately to your review comments.

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


 fs/lockd/host.c                 |   14 --
 fs/lockd/mon.c                  |   44 +----
 fs/nfs/internal.h               |   22 --
 fs/nfs/nfs4namespace.c          |    8 -
 fs/nfs/super.c                  |  154 ++---------------
 fs/nfsd/nfsctl.c                |   21 +-
 include/linux/sunrpc/clnt.h     |   38 ++++
 include/linux/sunrpc/msg_prot.h |   17 ++
 include/linux/sunrpc/xprt.h     |    1 
 net/sunrpc/Makefile             |    2 
 net/sunrpc/addr.c               |  364 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/rpcb_clnt.c          |  104 ++++++-----
 net/sunrpc/xprtrdma/transport.c |   53 ++----
 net/sunrpc/xprtsock.c           |  127 ++++----------
 14 files changed, 570 insertions(+), 399 deletions(-)
 create mode 100644 net/sunrpc/addr.c

-- 
Chuck Lever <chuck.lever@oracle.com>
