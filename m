From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/23] Clean ups and bug fixes for 2.6.30
Date: Thu, 05 Mar 2009 16:31:22 -0500
Message-ID: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:24979 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbZCEVcq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:32:46 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

These patches are ready for consideration for 2.6.30.  They've seen
only very light testing.  Many of these you've seen before.

---

Chuck Lever (23):
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
      SUNRPC: Clean up svc_find_xprt() calling sequence
      SUNRPC: Clean up static inline functions in svc_xprt.h
      SUNRPC: Fix return type of svc_addr_len()


 fs/nfs/internal.h                        |    3 
 fs/nfs/nfs4namespace.c                   |    2 
 fs/nfs/super.c                           |  121 ------------
 fs/nfs_common/Makefile                   |    1 
 fs/nfs_common/nfs_addr_parse.c           |  151 +++++++++++++++
 fs/nfsd/nfsctl.c                         |  298 +++++++++++++++++-------------
 include/linux/nfs_addr_parse.h           |   29 +++
 include/linux/sunrpc/svc_xprt.h          |   54 +++--
 include/linux/sunrpc/svcsock.h           |    7 +
 net/sunrpc/svc_xprt.c                    |   75 +++++---
 net/sunrpc/svcsock.c                     |   80 ++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 +-
 12 files changed, 521 insertions(+), 316 deletions(-)
 create mode 100644 fs/nfs_common/nfs_addr_parse.c
 create mode 100644 include/linux/nfs_addr_parse.h

-- 
Chuck Lever
